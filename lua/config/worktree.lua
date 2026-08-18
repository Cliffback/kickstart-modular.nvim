-- [[ Git worktree session switching ]]
--
-- Running `wt switch` (worktrunk) inside a :terminal changes the *shell's*
-- directory, but Neovim knows nothing about it: the cwd, the open buffers and
-- the LSP clients all still point at the previous worktree.
--
-- This module notices the change and moves the whole session across.
--
-- Detection uses OSC 7 rather than anything worktrunk-specific. Shells announce
-- directory changes with that escape sequence, Neovim surfaces it as
-- |TermRequest| (see `:h terminal-osc7`), and oh-my-zsh already emits it from
-- its `precmd` hook (omz_termsupport_cwd), so no shell configuration is needed.
-- It also means plain `cd` between worktrees works, not just `wt switch`.
--
-- opencode needs no special handling. opencode.nvim discovers servers by
-- matching *Neovim's* cwd against each server's cwd, so once we have moved it
-- reconnects to the opencode already running in the new worktree, or starts one
-- there. We only have to drop the current connection; no running session is
-- ever asked to change directory, which would be a mess with subagents.

local M = {}

---Git root for a path. Works for worktrees, where `.git` is a file rather than
---a directory.
---@param path string
---@return string?
local function git_root(path)
  return vim.fs.root(path, '.git')
end

---Move every listed buffer under `old_root` to the same relative path under
---`new_root`, where that file exists.
---@param old_root string
---@param new_root string
---@return integer moved, integer kept
local function remap_buffers(old_root, new_root)
  local moved, kept = 0, 0

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted and vim.bo[buf].buftype == '' then
      local name = vim.api.nvim_buf_get_name(buf)

      if name ~= '' and name:sub(1, #old_root + 1) == old_root .. '/' then
        -- Never touch unsaved work.
        if vim.bo[buf].modified then
          kept = kept + 1
        else
          local rel = name:sub(#old_root + 2)
          local target = new_root .. '/' .. rel

          if vim.uv.fs_stat(target) then
            -- Renaming the buffer keeps its window, cursor position and jumps.
            vim.api.nvim_buf_set_name(buf, target)
            vim.api.nvim_buf_call(buf, function()
              vim.cmd 'silent! edit!'
            end)
            moved = moved + 1
          else
            -- No counterpart in the new worktree (branch-specific file).
            kept = kept + 1
          end
        end
      end
    end
  end

  return moved, kept
end

---Detach LSP clients so they re-root on the next attach.
local function restart_lsp()
  for _, client in ipairs(vim.lsp.get_clients()) do
    client:stop()
  end
end

---Drop the opencode server connection so the next interaction rediscovers one
---matching the new cwd, and shut down the instance we were running for the
---worktree being left, so they do not accumulate one per branch visited.
---
---NOTE: do *not* route the disconnect through
---`opencode.command('server.disconnect')`. That goes through the connect flow
---first, which starts a server when none is found - so "disconnect" would spawn
---an opencode in the worktree we are leaving. Talk to the connected server
---directly, and do nothing if there is none.
---@param old_root string
local function reset_opencode(old_root)
  if package.loaded['opencode.server'] then
    pcall(function()
      local Server = require 'opencode.server'
      if Server.connected then
        Server.connected:disconnect()
      end
    end)
  end

  pcall(function()
    require('config.opencode-term').close(old_root)
  end)
end

---Move the session to `new_root`.
---@param new_root string
function M.switch(new_root)
  local old_root = git_root(vim.fn.getcwd()) or vim.fn.getcwd()

  if vim.fn.isdirectory(new_root) == 0 then
    vim.notify('Worktree: not a directory: ' .. new_root, vim.log.levels.WARN)
    return
  end
  if vim.fs.normalize(new_root) == vim.fs.normalize(old_root) then
    return
  end

  vim.cmd.cd(vim.fn.fnameescape(new_root))
  local moved, kept = remap_buffers(old_root, new_root)
  restart_lsp()
  reset_opencode(old_root)

  local msg = ('Worktree: %s'):format(vim.fs.basename(new_root))
  if moved > 0 or kept > 0 then
    msg = msg .. ('  (%d buffers moved, %d kept)'):format(moved, kept)
  end
  vim.notify(msg)
end

---Prompt before switching, since OSC 7 fires on every shell prompt and an
---unannounced cd + buffer swap is a jarring thing to have happen to you.
---@param new_root string
local function confirm_switch(new_root)
  vim.ui.select({ 'yes', 'no' }, {
    prompt = ('Switch session to worktree "%s"?'):format(vim.fs.basename(new_root)),
  }, function(choice)
    if choice == 'yes' then
      M.switch(new_root)
    end
  end)
end

function M.setup()
  vim.api.nvim_create_autocmd('TermRequest', {
    group = vim.api.nvim_create_augroup('WorktreeOsc7', { clear = true }),
    desc = 'Follow worktree changes announced by a terminal via OSC 7',
    callback = function(ev)
      local dir, n = string.gsub(ev.data.sequence, '\027]7;file://[^/]*', '')
      if n == 0 or vim.fn.isdirectory(dir) == 0 then
        return
      end

      -- Remember the terminal's own cwd for the manual <leader>wt path.
      vim.b[ev.buf].osc7_dir = dir

      local new_root = git_root(dir)
      local cur_root = git_root(vim.fn.getcwd())

      -- Only react to an actual change of worktree. `cd` within the current
      -- one, or into somewhere with no repo at all, is none of our business.
      if not new_root or not cur_root then
        return
      end
      if vim.fs.normalize(new_root) == vim.fs.normalize(cur_root) then
        return
      end

      vim.schedule(function()
        confirm_switch(new_root)
      end)
    end,
  })
end

---Switch to the worktree of the terminal under the cursor (or the shell's last
---known directory), without waiting to be asked.
function M.switch_to_terminal_cwd()
  local dir = vim.b.osc7_dir
  if not dir then
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      dir = dir or vim.b[buf].osc7_dir
    end
  end
  if not dir then
    vim.notify('Worktree: no terminal directory known yet', vim.log.levels.WARN)
    return
  end

  local root = git_root(dir)
  if not root then
    vim.notify('Worktree: no git root under ' .. dir, vim.log.levels.WARN)
    return
  end
  M.switch(root)
end

return M

-- vim: ts=2 sts=2 sw=2 et
