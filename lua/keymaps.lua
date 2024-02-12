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
vim.keymap.set('n', '<Leader>rq', close_rest_nvim_results,
  { desc = 'Close rest.nvim results panel', noremap = true, silent = true })


vim.keymap.set('n', '<A-h>', "<cmd>wincmd h<CR>",
  { desc = 'Close rest.nvim results panel', noremap = true, silent = true })
vim.keymap.set('n', '<A-j>', "<cmd>wincmd j<CR>",
  { desc = 'Close rest.nvim results panel', noremap = true, silent = true })
vim.keymap.set('n', '<A-k>', "<cmd>wincmd k<CR>",
  { desc = 'Close rest.nvim results panel', noremap = true, silent = true })
vim.keymap.set('n', '<A-l>', "<cmd>wincmd l<CR>",
  { desc = 'Close rest.nvim results panel', noremap = true, silent = true })

--vim.keymap.set('n', '<A-h>', '<cmd>wincmd h<CR>')
local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Move to previous/next
map('n', '<A-,>', '<Cmd>BufferPrevious<CR>', opts)
map('n', '<A-.>', '<Cmd>BufferNext<CR>', opts)
-- Re-order to previous/next
map('n', '<A-<>', '<Cmd>BufferMovePrevious<CR>', opts)
map('n', '<A->>', '<Cmd>BufferMoveNext<CR>', opts)
-- Goto buffer in position...
map('n', '<A-1>', '<Cmd>BufferGoto 1<CR>', opts)
map('n', '<A-2>', '<Cmd>BufferGoto 2<CR>', opts)
map('n', '<A-3>', '<Cmd>BufferGoto 3<CR>', opts)
map('n', '<A-4>', '<Cmd>BufferGoto 4<CR>', opts)
map('n', '<A-5>', '<Cmd>BufferGoto 5<CR>', opts)
map('n', '<A-6>', '<Cmd>BufferGoto 6<CR>', opts)
map('n', '<A-7>', '<Cmd>BufferGoto 7<CR>', opts)
map('n', '<A-8>', '<Cmd>BufferGoto 8<CR>', opts)
map('n', '<A-9>', '<Cmd>BufferGoto 9<CR>', opts)
map('n', '<A-0>', '<Cmd>BufferLast<CR>', opts)
-- Pin/unpin buffer
map('n', '<A-p>', '<Cmd>BufferPin<CR>', opts)
-- Close buffer
map('n', '<A-c>', '<Cmd>BufferClose<CR>', opts)
-- Wipeout buffer
--                 :BufferWipeout
-- Close commands
--                 :BufferCloseAllButCurrent
--                 :BufferCloseAllButPinned
--                 :BufferCloseAllButCurrentOrPinned
--                 :BufferCloseBuffersLeft
--                 :BufferCloseBuffersRight
-- Magic buffer-picking mode
map('n', '<C-A-p>', '<Cmd>BufferPick<CR>', opts)
-- Sort automatically by...
map('n', '<Space>bb', '<Cmd>BufferOrderByBufferNumber<CR>', opts)
map('n', '<Space>bd', '<Cmd>BufferOrderByDirectory<CR>', opts)
map('n', '<Space>bl', '<Cmd>BufferOrderByLanguage<CR>', opts)
map('n', '<Space>bw', '<Cmd>BufferOrderByWindowNumber<CR>', opts)

vim.keymap.set('n', '<leader>u', require('undotree').toggle, { noremap = true, silent = true })
--vim.keymap.set('n', '<leader>uo', require('undotree').open, { noremap = true, silent = true })
--vim.keymap.set('n', '<leader>uc', require('undotree').close, { noremap = true, silent = true })

-- Other:
-- :BarbarEnable - enables barbar (enabled by default)
-- :BarbarDisable - very bad command, should never be used

vim.keymap.set('n', '<C-f>', '<cmd>Format<CR>', { noremap = true, silent = true, desc = 'Format document' })


--vim.keymap.set('n', '<F9>', function() require('dap').continue() end)
--vim.keymap.set('n', '<F10>', function() require('dap').step_over() end)
--vim.keymap.set('n', '<F11>', function() require('dap').step_into() end)
--vim.keymap.set('n', '<F12>', function() require('dap').step_out() end)
--vim.keymap.set('n', '<Leader>db', function() require('dap').toggle_breakpoint() end)
--vim.keymap.set('n', '<Leader>dB', function() require('dap').set_breakpoint() end)
--vim.keymap.set('n', '<Leader>lm',
--  function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end)
--vim.keymap.set('n', '<Leader>dr', function() require('dap').repl.open() end)
--vim.keymap.set('n', '<Leader>dl', function() require('dap').run_last() end)
--vim.keymap.set({ 'n', 'v' }, '<Leader>dh', function()
--  require('dap.ui.widgets').hover()
--end)
--vim.keymap.set({ 'n', 'v' }, '<Leader>dp', function()
--  require('dap.ui.widgets').preview()
--end)
--vim.keymap.set('n', '<Leader>df', function()
--  local widgets = require('dap.ui.widgets')
--  widgets.centered_float(widgets.frames)
--end)
--vim.keymap.set('n', '<Leader>ds', function()
--  local widgets = require('dap.ui.widgets')
--  widgets.centered_float(widgets.scopes)
--end)


-- lsp keymaps
local M = {}

function M.set_lsp_keymaps(_,bufnr)
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  --nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })

end

vim.keymap.set("n", "<A-h>", "<C-w>h")
vim.keymap.set("n", "<A-j>", "<C-w>j")
vim.keymap.set("n", "<A-k>", "<C-w>k")
vim.keymap.set("n", "<A-l>", "<C-w>l")

-- terminal
vim.keymap.set("t", "<A-h>", "<cmd>wincmd h<CR>")
vim.keymap.set("t", "<A-j>", "<cmd>wincmd j<CR>")
vim.keymap.set("t", "<A-k>", "<cmd>wincmd k<CR>")
vim.keymap.set("t", "<A-l>", "<cmd>wincmd l<CR>")

vim.keymap.set("n", "<A-Up>", ":resize -2<CR>")
vim.keymap.set("n", "<A-Down>", ":resize +2<CR>")
vim.keymap.set("n", "<A-Left>", ":vertical resize -2<CR>")
vim.keymap.set("n", "<A-Right>", ":vertical resize +2<CR>")

-- terminal
vim.keymap.set("t", "<A-Up>", "<cmd>resize -2<CR>")
vim.keymap.set("t", "<A-Down>", "<cmd>resize +2<CR>")
vim.keymap.set("t", "<A-Left>", "<cmd>vertical resize -2<CR>")
vim.keymap.set("t", "<A-Right>", "<cmd>vertical resize +2<CR>")

vim.keymap.set("n", "<leader>db", function() require("dbee").open() end, { noremap = true, silent = true, desc = 'Open Database Browser' })


return M
-- vim: ts=2 sts=2 sw=2 et
