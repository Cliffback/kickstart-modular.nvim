-- [[ Global keymaps ]]
--
-- Plugin-specific keymaps live with their plugin in lua/plugins/*.lua so that
-- lazy-loading works. Only genuinely global bindings belong here.
--
-- NOTE: every mapping in this config carries a `desc`. which-key derives both
-- its labels and its icons from those descriptions, so an omitted `desc` shows
-- up as a blank row in the popup.

local map = vim.keymap.set

-- Leader is a no-op on its own so it never inserts a space.
map({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true, desc = 'Leader' })

-- Move by display line when wrapped, unless a count was given.
map('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, desc = 'Up (display line)' })
map('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, desc = 'Down (display line)' })

-- [[ Diagnostics ]]
map('n', '[d', function()
  vim.diagnostic.jump { count = -1, float = true }
end, { desc = 'Go to previous diagnostic message' })
map('n', ']d', function()
  vim.diagnostic.jump { count = 1, float = true }
end, { desc = 'Go to next diagnostic message' })
map('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- [[ Windows ]]
--
-- NOTE: <Tab>/<S-Tab> used to be mapped to :wincmd w/W. In most terminals
-- <Tab> and <C-i> are the same byte, so that silently disabled <C-i> (jump
-- forward in the jumplist). Windows Terminal in particular cannot tell them
-- apart. Built-in <C-w>w / <C-w>W already cycle windows, and <C-h/j/k/l>
-- below covers directional movement, so the maps were simply removed.
map('n', '<C-h>', '<cmd>wincmd h<CR>', { silent = true, desc = 'Move to left window' })
map('n', '<C-j>', '<cmd>wincmd j<CR>', { silent = true, desc = 'Move to lower window' })
map('n', '<C-k>', '<cmd>wincmd k<CR>', { silent = true, desc = 'Move to upper window' })
map('n', '<C-l>', '<cmd>wincmd l<CR>', { silent = true, desc = 'Move to right window' })

map('n', '<A-Up>', '<cmd>resize -2<CR>', { silent = true, desc = 'Shrink window height' })
map('n', '<A-Down>', '<cmd>resize +2<CR>', { silent = true, desc = 'Grow window height' })
map('n', '<A-Left>', '<cmd>vertical resize -2<CR>', { silent = true, desc = 'Shrink window width' })
map('n', '<A-Right>', '<cmd>vertical resize +2<CR>', { silent = true, desc = 'Grow window width' })

-- [[ Terminal ]]
--
-- NOTE: <Esc> is deliberately NOT mapped. A global terminal-mode <Esc> means
-- the key never reaches the program running inside, which breaks every TUI:
-- opencode (Esc interrupts / goes back), lazygit, htop, nested nvim.
-- <Esc><Esc> exits to normal mode instead, leaving single <Esc> to pass
-- through untouched.
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
map('t', '<C-h>', '<cmd>wincmd h<CR>', { desc = 'Move to left window' })
map('t', '<C-j>', '<cmd>wincmd j<CR>', { desc = 'Move to lower window' })
map('t', '<C-k>', '<cmd>wincmd k<CR>', { desc = 'Move to upper window' })
map('t', '<C-l>', '<cmd>wincmd l<CR>', { desc = 'Move to right window' })
map('t', '<A-Up>', '<cmd>resize -2<CR>', { desc = 'Shrink window height' })
map('t', '<A-Down>', '<cmd>resize +2<CR>', { desc = 'Grow window height' })
map('t', '<A-Left>', '<cmd>vertical resize -2<CR>', { desc = 'Shrink window width' })
map('t', '<A-Right>', '<cmd>vertical resize +2<CR>', { desc = 'Grow window width' })

-- [[ Formatting ]]
-- NOTE: was <C-f>, which shadowed the built-in page-forward motion.
map({ 'n', 'v' }, '<leader>f', '<cmd>Format<CR>', { silent = true, desc = 'Format buffer/selection' })

-- [[ Worktrees ]]
map('n', '<leader>wt', function()
  require('config.worktree').switch_to_terminal_cwd()
end, { desc = '[W]ork[t]ree: switch session to terminal cwd' })

-- [[ LSP ]]
-- Applied per-buffer from the LspAttach autocmd in config/lsp.lua.
local M = {}

function M.set_lsp_keymaps(_, bufnr)
  local nmap = function(keys, func, desc)
    map('n', keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('gr', function()
    require('snacks').picker.lsp_references()
  end, '[G]oto [R]eferences')
  nmap('gI', function()
    require('snacks').picker.lsp_implementations()
  end, '[G]oto [I]mplementation')
  nmap('<leader>D', function()
    require('snacks').picker.lsp_type_definitions()
  end, 'Type [D]efinition')
  nmap('<leader>ds', function()
    require('snacks').picker.lsp_symbols()
  end, '[D]ocument [S]ymbols')
  nmap('<leader>ws', function()
    require('snacks').picker.lsp_workspace_symbols()
  end, '[W]orkspace [S]ymbols')

  nmap('K', function()
    vim.lsp.buf.hover { border = 'rounded', max_width = 80 }
  end, 'Hover Documentation')
  nmap('gK', vim.lsp.buf.signature_help, 'Signature Documentation')

  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')
end

-- [[ which-key groups ]]
--
-- Registered here rather than in config/lsp.lua (where they used to live, for
-- no reason). Prefixes with no group render as bare keys in the popup.
function M.setup_which_key()
  local wk = require 'which-key'

  wk.add {
    { '<leader>b', group = '[B]uffer order' },
    { '<leader>c', group = '[C]ode' },
    { '<leader>cc', group = '[C]opilot [C]hat' },
    { '<leader>d', group = '[D]ocument' },
    { '<leader>f', desc = 'Format buffer/selection' },
    { '<leader>g', group = '[G]it' },
    { '<leader>h', group = 'Git [H]unk' },
    { '<leader>m', group = '[M]arkdown' },
    { '<leader>o', group = '[O]pencode' },
    { '<leader>p', group = '[P]ractice' },
    { '<leader>r', group = '[R]ename' },
    { '<leader>s', group = '[S]earch' },
    { '<leader>t', group = '[T]oggle' },
    { '<leader>w', group = '[W]orkspace / [W]orktree' },
    { '<leader>x', group = 'Diagnostics ([X])' },

    -- which-key picks icons by matching the description against its rule
    -- table; these descriptions match no rule, so set them explicitly.
    { '<leader>n', icon = { icon = '󰙅', color = 'green' } },
    { '<leader>u', icon = { icon = '󰕍', color = 'yellow' } },
  }

  wk.add({
    { '<leader>', group = 'VISUAL <leader>' },
    { '<leader>h', group = 'Git [H]unk' },
  }, { mode = 'v' })
end

return M

-- vim: ts=2 sts=2 sw=2 et
