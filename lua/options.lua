-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

-- Enable line breaks
vim.opt.linebreak = true
vim.opt.breakat = " \t,-"

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.wo.number = true

-- Enable relative line numbers
vim.wo.relativenumber = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- Set color scheme
vim.cmd.colorscheme "catppuccin"

-- Configure nvim-tree
-- optionally enable 24-bit colour
vim.opt.termguicolors = true

-- setup with some options
local function my_on_attach(bufnr)
  local api = require "nvim-tree.api"

  local FloatPreview = require("float-preview")
  FloatPreview.attach_nvimtree(bufnr)

  local function opts(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  local close_wrap = FloatPreview.close_wrap


  -- default mappings
  -- api.config.mappings.default_on_attach(bufnr)

  -- wrap keymaps that use the following apis in close_wrap
  -- api.node.open.tab
  -- api.node.open.vertical
  -- api.node.open.horizontal
  -- api.node.open.edit
  -- api.node.open.preview
  -- api.node.open.no_window_picker
  -- api.fs.create
  -- api.fs.remove
  -- api.fs.rename

  -- BEGIN_DEFAULT_ON_ATTACH
  vim.keymap.set('n', '<C-]>', api.tree.change_root_to_node, opts('CD'))
  vim.keymap.set('n', '<C-e>', api.node.open.replace_tree_buffer, opts('Open: In Place'))
  vim.keymap.set('n', '<C-k>', api.node.show_info_popup, opts('Info'))
  vim.keymap.set('n', '<C-r>', api.fs.rename_sub, opts('Rename: Omit Filename'))
  vim.keymap.set('n', '<C-t>', close_wrap(api.node.open.tab), opts('Open: New Tab'))
  vim.keymap.set('n', '<C-v>', close_wrap(api.node.open.vertical), opts('Open: Vertical Split'))
  vim.keymap.set('n', '<C-x>', close_wrap(api.node.open.horizontal), opts('Open: Horizontal Split'))
  vim.keymap.set('n', '<BS>', api.node.navigate.parent_close, opts('Close Directory'))
  --vim.keymap.set('n', '<CR>', api.node.open.edit, opts('Open'))
  --vim.keymap.set('n', '<Tab>',   api.node.open.preview,               opts('Open Preview'))
  vim.keymap.set('n', '>', api.node.navigate.sibling.next, opts('Next Sibling'))
  vim.keymap.set('n', '<', api.node.navigate.sibling.prev, opts('Previous Sibling'))
  vim.keymap.set('n', '.', api.node.run.cmd, opts('Run Command'))
  vim.keymap.set('n', '-', api.tree.change_root_to_parent, opts('Up'))
  vim.keymap.set('n', 'a', close_wrap(api.fs.create), opts('Create File Or Directory'))
  vim.keymap.set('n', 'bd', api.marks.bulk.delete, opts('Delete Bookmarked'))
  vim.keymap.set('n', 'bt', api.marks.bulk.trash, opts('Trash Bookmarked'))
  vim.keymap.set('n', 'bmv', api.marks.bulk.move, opts('Move Bookmarked'))
  vim.keymap.set('n', 'B', api.tree.toggle_no_buffer_filter, opts('Toggle Filter: No Buffer'))
  vim.keymap.set('n', 'c', api.fs.copy.node, opts('Copy'))
  vim.keymap.set('n', 'C', api.tree.toggle_git_clean_filter, opts('Toggle Filter: Git Clean'))
  vim.keymap.set('n', '[c', api.node.navigate.git.prev, opts('Prev Git'))
  vim.keymap.set('n', ']c', api.node.navigate.git.next, opts('Next Git'))
  vim.keymap.set('n', 'd', close_wrap(api.fs.remove), opts('Delete'))
  vim.keymap.set('n', 'D', api.fs.trash, opts('Trash'))
  vim.keymap.set('n', 'E', api.tree.expand_all, opts('Expand All'))
  vim.keymap.set('n', 'e', api.fs.rename_basename, opts('Rename: Basename'))
  vim.keymap.set('n', ']e', api.node.navigate.diagnostics.next, opts('Next Diagnostic'))
  vim.keymap.set('n', '[e', api.node.navigate.diagnostics.prev, opts('Prev Diagnostic'))
  vim.keymap.set('n', 'F', api.live_filter.clear, opts('Live Filter: Clear'))
  vim.keymap.set('n', 'f', api.live_filter.start, opts('Live Filter: Start'))
  vim.keymap.set('n', 'g?', api.tree.toggle_help, opts('Help'))
  vim.keymap.set('n', 'gy', api.fs.copy.absolute_path, opts('Copy Absolute Path'))
  vim.keymap.set('n', 'H', api.tree.toggle_hidden_filter, opts('Toggle Filter: Dotfiles'))
  vim.keymap.set('n', 'I', api.tree.toggle_gitignore_filter, opts('Toggle Filter: Git Ignore'))
  vim.keymap.set('n', 'J', api.node.navigate.sibling.last, opts('Last Sibling'))
  vim.keymap.set('n', 'K', api.node.navigate.sibling.first, opts('First Sibling'))
  vim.keymap.set('n', 'M', api.tree.toggle_no_bookmark_filter, opts('Toggle Filter: No Bookmark'))
  vim.keymap.set('n', 'm', api.marks.toggle, opts('Toggle Bookmark'))
  vim.keymap.set('n', 'o', api.node.open.edit, opts('Open'))
  vim.keymap.set('n', 'O', api.node.open.no_window_picker, opts('Open: No Window Picker'))
  vim.keymap.set('n', 'p', api.fs.paste, opts('Paste'))
  vim.keymap.set('n', 'P', api.node.navigate.parent, opts('Parent Directory'))
  vim.keymap.set('n', 'q', api.tree.close, opts('Close'))
  vim.keymap.set('n', 'r', close_wrap(api.fs.rename), opts('Rename'))
  vim.keymap.set('n', 'R', api.tree.reload, opts('Refresh'))
  vim.keymap.set('n', 's', api.node.run.system, opts('Run System'))
  vim.keymap.set('n', 'S', api.tree.search_node, opts('Search'))
  vim.keymap.set('n', 'u', api.fs.rename_full, opts('Rename: Full Path'))
  vim.keymap.set('n', 'U', api.tree.toggle_custom_filter, opts('Toggle Filter: Hidden'))
  vim.keymap.set('n', 'W', api.tree.collapse_all, opts('Collapse'))
  vim.keymap.set('n', 'x', api.fs.cut, opts('Cut'))
  vim.keymap.set('n', 'y', api.fs.copy.filename, opts('Copy Name'))
  vim.keymap.set('n', 'Y', api.fs.copy.relative_path, opts('Copy Relative Path'))
  vim.keymap.set('n', '<2-LeftMouse>', api.node.open.edit, opts('Open'))
  vim.keymap.set('n', '<2-RightMouse>', api.tree.change_root_to_node, opts('CD'))
  -- END_DEFAULT_ON_ATTACH

  local function edit_or_open()
    local node = api.tree.get_node_under_cursor()

    if node.nodes ~= nil then
      -- expand or collapse folder
      close_wrap(api.node.open.edit())
    else
      -- open file
      close_wrap(api.node.open.edit())
      -- Close the tree if file was opened
      api.tree.close()
    end
  end

  -- open as vsplit on current node
  local function vsplit_preview()
    local node = api.tree.get_node_under_cursor()

    if node.nodes ~= nil then
      -- expand or collapse folder
      close_wrap(api.node.open.edit())
    else
      -- open file as vsplit
      close_wrap(api.node.open.vertical())
    end

    -- Finally refocus on tree if it was lost
    api.tree.focus()
  end

  vim.g.mapleader = ' '
  -- custom mappings
  vim.keymap.set('n', '<C-[>', api.tree.change_root_to_parent, opts('Up'))
  vim.keymap.set('n', '?', api.tree.toggle_help, opts('Help'))
  vim.keymap.set('n', '<C-d>', api.tree.toggle_hidden_filter, opts('Toggle Filter: Dotfiles'))
  vim.keymap.set('n', 'L', close_wrap(api.node.open.edit), opts('Open'))
  --vim.keymap.set('n', 'l', api.node.open.preview, opts('Open Preview'))
  --vim.keymap.set("n", "<leader>", api.node.open.preview, opts("Vsplit Preview"))
  -- vim.keymap.set("n", "l",      edit_or_open,                    opts("Edit Or Open"))
  --  vim.keymap.set("n", "L",     vsplit_preview,                  opts("Vsplit Preview"))
  vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close"))
  vim.keymap.set("n", "<C-c>", api.tree.collapse_all, opts("Collapse All"))
  --vim.keymap.set("n", "<C-l>", edit_or_open, opts("Open and Close"))
  vim.keymap.set("n", "l", edit_or_open, opts("Open and Close"))
  vim.keymap.set('n', '<CR>', edit_or_open, opts("Open and Close"))

  -- Unmap esc to avoid accidentally going up one directory
  vim.keymap.del('n', '<Esc>', { buffer = bufnr })
end

require("nvim-tree").setup({
  sort = {
    sorter = "case_sensitive",
  },
  view = {
    width = 30,
  },
  renderer = {
    group_empty = true
  },
  filters = {
    dotfiles = true,
  },
  on_attach = my_on_attach,
  -- Don't use gitignore
  git = {
    enable = true,
    ignore = false,
    timeout = 500,
  },
})

local undotree = require('undotree')

undotree.setup({
  float_diff = true,      -- using float window previews diff, set this `true` will disable layout option
  layout = "left_bottom", -- "left_bottom", "left_left_bottom"
  position = "left",      -- "right", "bottom"
  ignore_filetype = { 'undotree', 'undotreeDiff', 'qf', 'TelescopePrompt', 'spectre_panel', 'tsplayground' },
  window = {
    winblend = 30,
  },
  keymaps = {
    ['j'] = "move_next",
    ['k'] = "move_prev",
    ['gj'] = "move2parent",
    ['J'] = "move_change_next",
    ['K'] = "move_change_prev",
    ['<cr>'] = "action_enter",
    ['p'] = "enter_diffbuf",
    ['q'] = "quit",
  },
})
require("toggleterm").setup({
  size = 20,
  open_mapping = [[<c-\>]],
  hide_numbers = true,
  shade_filetypes = {},
  shade_terminals = true,
  shading_factor = 2,
  start_in_insert = true,
  insert_mappings = true,
  persist_size = true,
  direction = "float",
  close_on_exit = true,
  shell = vim.o.shell,
  float_opts = {
    border = "curved",
    winblend = 0,
    highlights = {
      border = "Normal",
      background = "Normal",
    },
  },
})

-- Set max width for hover window
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  vim.lsp.handlers.hover, {
    -- Set the maximum width
    max_width = 80,
    --max_height = 30,
    border = 'rounded'
  }
)

-- Disable inline diagnostics
vim.diagnostic.config({
  virtual_text = false
})

-- Show line diagnostics automatically in hover window
vim.o.updatetime = 250
vim.cmd [[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]]

require("dbee").setup()

require("colorizer").setup({
  filetypes = { "*" },
  user_default_options = {
    RGB = true,          -- #RGB hex codes
    RRGGBB = true,       -- #RRGGBB hex codes
    names = true,        -- "Name" codes like Blue or blue
    RRGGBBAA = true,     -- #RRGGBBAA hex codes
    AARRGGBB = true,     -- 0xAARRGGBB hex codes
    rgb_fn = true,       -- CSS rgb() and rgba() functions
    hsl_fn = true,       -- CSS hsl() and hsla() functions
    css = true,          -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
    css_fn = true,       -- Enable all CSS *functions*: rgb_fn, hsl_fn
    -- Available modes for `mode`: foreground, background,  virtualtext
    mode = "background", -- Set the display mode.
    -- Available methods are false / true / "normal" / "lsp" / "both"
    -- True is same as normal
    tailwind = true,                                 -- Enable tailwind colors
    -- parsers can contain values used in |user_default_options|
    sass = { enable = false, parsers = { "css" }, }, -- Enable sass colors
    virtualtext = "■",
    -- update color values even if buffer is not focused
    -- example use: cmp_menu, cmp_docs
    always_update = false
  },
  -- all the sub-options of filetypes apply to buftypes
  buftypes = {},
})

require('ts_context_commentstring').setup {
  enable_autocmd = false,
}

require('Comment').setup({
  pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
  ---Add a space b/w comment and the line
  padding = true,
  ---Whether the cursor should stay at its position
  sticky = true,
  ---Lines to be ignored while (un)comment
  ignore = nil,
  ---LHS of toggle mappings in NORMAL mode
  toggler = {
    ---Line-comment toggle keymap
    line = 'gcc',
    ---Block-comment toggle keymap
    block = 'gbc',
  },
  ---LHS of operator-pending mappings in NORMAL and VISUAL mode
  opleader = {
    ---Line-comment keymap
    line = 'gc',
    ---Block-comment keymap
    block = 'gb',
  },
  ---LHS of extra mappings
  extra = {
    ---Add comment on the line above
    above = 'gcO',
    ---Add comment on the line below
    below = 'gco',
    ---Add comment at the end of line
    eol = 'gcA',
  },
  ---Enable keybindings
  ---NOTE: If given `false` then the plugin won't create any mappings
  mappings = {
    ---Operator-pending mapping; `gcc` `gbc` `gc[count]{motion}` `gb[count]{motion}`
    basic = true,
    ---Extra mapping; `gco`, `gcO`, `gcA`
    extra = true,
  },
  ---Function to call before (un)comment
  pre_hook = nil,
  ---Function to call after (un)comment
  post_hook = nil,
})

-- vim: ts=2 sts=2 sw=2 et
