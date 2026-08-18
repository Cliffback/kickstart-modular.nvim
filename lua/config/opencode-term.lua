-- [[ opencode terminals ]]
--
-- opencode.nvim is a bridge, not a UI: it connects to a running `opencode`
-- server and drives its TUI, and owns no window of its own. So we host the TUI
-- in a toggleterm right sidebar.
--
-- Terminals are keyed by directory. A running opencode cannot change its own
-- working directory - and asking it to would be a mess once subagents are
-- involved - so each worktree gets its own instance. Neovim then connects to
-- whichever one matches its cwd (see the strict matcher in plugins/ai.lua).
--
-- Without this, a single shared handle would reveal the *previous* worktree's
-- opencode after a switch: `server.start` calls open(), and open() on a handle
-- whose job is still alive just shows the stale instance.

local M = {}

---@type table<string, table> cwd -> toggleterm Terminal
local terms = {}

-- Terminal ids start high so they can never collide with the shell terminal,
-- which is pinned to 1 and toggled with `1ToggleTerm` (see plugins/tools.lua).
local next_count = 90

---@param cwd? string Defaults to Neovim's cwd.
---@return string
local function normalize(cwd)
  return vim.fs.normalize(cwd or vim.fn.getcwd())
end

---The opencode terminal for a directory, created on first use.
---@param cwd? string
---@return table
function M.get(cwd)
  cwd = normalize(cwd)

  if not terms[cwd] then
    terms[cwd] = require('toggleterm.terminal').Terminal:new {
      cmd = 'opencode --port',
      dir = cwd,
      count = next_count,
      direction = 'vertical', -- toggleterm uses `botright vsplit`, i.e. right
      -- NOTE: width comes from the global `size` function in plugins/tools.lua,
      -- which branches on direction. A `size` field here would be ignored -
      -- Terminal objects do not carry one.
      hidden = true,
      close_on_exit = false,
      on_open = function()
        vim.cmd 'startinsert'
      end,
    }
    next_count = next_count + 1
  end

  return terms[cwd]
end

---Move focus out of a floating window.
---
---A vertical split cannot be created from inside a float: toggleterm silently
---fails and the sidebar never appears. That is the realistic order of events -
---the shell float is open and you then reach for opencode - so normalise focus
---to an ordinary window first.
local function leave_float()
  if vim.api.nvim_win_get_config(0).relative == '' then
    return
  end
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative == '' then
      vim.api.nvim_set_current_win(win)
      return
    end
  end
end

---@param cwd? string
function M.toggle(cwd)
  local term = M.get(cwd)
  if not term:is_open() then
    leave_float()
  end
  term:toggle()
end

---@param cwd? string
function M.open(cwd)
  local term = M.get(cwd)
  if not term:is_open() then
    leave_float()
  end
  term:open()
end

---Whether we already own a live opencode for this directory.
---@param cwd? string
---@return boolean
function M.is_running(cwd)
  local term = terms[normalize(cwd)]
  return term ~= nil and term:is_open() or (term ~= nil and vim.fn.jobwait({ term.job_id or -1 }, 0)[1] == -1)
end

---Shut down the opencode belonging to a directory. Called when leaving a
---worktree, so instances do not pile up one per branch visited.
---@param cwd string
function M.close(cwd)
  cwd = normalize(cwd)
  local term = terms[cwd]
  if not term then
    return
  end

  pcall(function()
    if term:is_open() then
      term:close()
    end
    term:shutdown()
  end)
  terms[cwd] = nil
end

return M

-- vim: ts=2 sts=2 sw=2 et
