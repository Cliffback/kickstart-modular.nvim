-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- Nvim-Tree global
-- vim.api.nvim_set_keymap("n", "<C-h>", ":NvimTreeFocus<cr>", {silent = true, noremap = true})
--vim.api.nvim_set_keymap("n", "<C-H>", ":NvimTreeToggle<cr>", {silent = true, noremap = true})
vim.g.mapleader = ' '

vim.api.nvim_set_keymap('n', '<C-h>', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>h', '<cmd>lua ToggleNvimTreeFocus()<CR>', { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<Tab>', ':wincmd w<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<S-Tab>', ':wincmd W<CR>', { noremap = true, silent = true })

function ToggleNvimTreeFocus()
  local nvim_tree_bufnr = tonumber(vim.fn.bufnr('NvimTree'))
  local current_bufnr = tonumber(vim.api.nvim_get_current_buf())

  if nvim_tree_bufnr == -1 then
    vim.cmd('NvimTreeOpen')
  elseif nvim_tree_bufnr == current_bufnr then
    vim.cmd('wincmd p')
  else
    vim.cmd('NvimTreeFocus')
  end
end

-- Open compiler
vim.api.nvim_set_keymap('n', '<F6>', "<cmd>CompilerOpen<cr>", { noremap = true, silent = true })

-- Stop the compiler
vim.api.nvim_set_keymap('n', '<F5>', "<cmd>CompilerStop<cr>", { noremap = true, silent = true })

-- Redo last selected option
vim.api.nvim_set_keymap('n', '<F7>', "<cmd>CompilerStop<cr>" .. "<cmd>CompilerRedo<cr>",
  { noremap = true, silent = true })

-- Toggle compiler results
vim.api.nvim_set_keymap('n', '<F8>', ':lua ToggleOverseer()<CR>', { noremap = true, silent = true })

function ToggleOverseer()
  -- Check if Overseer is loaded (if the 'OverseerOpen' command exists)
  if vim.fn.exists(':OverseerOpen') == 2 then
    if vim.g.overseer_opened == nil then
      vim.g.overseer_opened = true
    end
    -- Check if the global variable for Overseer's state exists and is true
    if vim.g.overseer_opened then
      -- If Overseer is opened, then close it
      vim.cmd('OverseerClose')
      CloseUnnamedBuffers();
      -- Set the global variable to false
      vim.g.overseer_opened = false
    else
      -- If Overseer is not opened, then open it
      vim.cmd('OverseerOpen')
      -- Set the global variable to true
      vim.g.overseer_opened = true
    end
  else
    print("Overseer plugin is not loaded.")
  end
end

function CloseUnnamedBuffers()
  -- Iterate through each buffer
  for _, buf in pairs(vim.api.nvim_list_bufs()) do
    -- Check if the buffer is unnamed
    if vim.api.nvim_buf_get_name(buf) == "" then
      -- Check if the buffer is modified
      if not vim.api.nvim_buf_get_option(buf, "modified") then
        -- Close the buffer
        vim.api.nvim_buf_delete(buf, { force = true })
      else
        -- Optional: Handle modified unnamed buffers
        -- e.g., prompt to save, ignore, etc.
        print("Modified unnamed buffer (bufnr: " .. buf .. ") not closed.")
      end
    end
  end
end

-- Map Rest.nvim
local function close_rest_nvim_results()
  local windows = vim.api.nvim_list_wins()
  for _, win in ipairs(windows) do
    local buf = vim.api.nvim_win_get_buf(win)
    local name = vim.api.nvim_buf_get_name(buf)
    if name:match("rest_nvim_results") then
      vim.api.nvim_win_close(win, false)
    end
  end
end

vim.keymap.set('n', '<Leader>rr', '<Plug>RestNvim',
  { desc = 'Run the HTTP request under the cursor', noremap = true, silent = true })
vim.keymap.set('n', '<Leader>rp', '<Plug>RestNvimPreview',
  { desc = 'Preview the cURL command of the request under the cursor', noremap = true, silent = true })
vim.keymap.set('n', '<Leader>rl', '<Plug>RestNvimLast',
  { desc = 'Re-run the last executed HTTP request', noremap = true, silent = true })
vim.keymap.set('n', '<Leader>rq', close_rest_nvim_results, { desc = 'Close rest.nvim results panel' })

-- vim: ts=2 sts=2 sw=2 et
