-- [[ Editor ]]

local HEIGHT_PADDING = 10
local WIDTH_PADDING = 15

return {
  -- File explorer
  {
    'nvim-tree/nvim-tree.lua',
    version = '*',
    lazy = false, -- replaces netrw, so it must own the FileType handler
    dependencies = {
      'nvim-tree/nvim-web-devicons',
      -- NOTE: float-preview's options used to be written inside this
      -- `dependencies` table, where lazy ignores them, so the 5 MB / is_text
      -- guards below never actually ran.
      {
        'JMarkin/nvim-tree.lua-float-preview',
        lazy = true,
        opts = {
          toggled_on = true,
          wrap_nvimtree_commands = true,
          scroll_lines = 20,
          window = {
            -- Same shallow-merge caveat as `mapping` above: spell out the
            -- defaults rather than relying on them surviving the merge.
            style = 'minimal',
            relative = 'editor',
            border = 'single',
            wrap = false,
            trim_height = false,
            open_win_config = function()
              local screen_w = vim.opt.columns:get()
              local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
              local window_w_f = (screen_w - WIDTH_PADDING * 2 - 1) / 2
              local window_w = math.floor(window_w_f)
              local window_h = screen_h - HEIGHT_PADDING * 2
              return {
                style = 'minimal',
                relative = 'editor',
                border = 'single',
                row = ((vim.opt.lines:get() - window_h) / 2) - vim.opt.cmdheight:get(),
                col = window_w_f + WIDTH_PADDING + 2,
                width = window_w,
                height = window_h,
              }
            end,
          },
          -- NOTE: float-preview merges config with vim.tbl_extend('force'), a
          -- *shallow* merge, so this table replaces the plugin's defaults
          -- wholesale. Every key it reads must be present: attach() iterates
          -- mapping.toggle unconditionally, so omitting it crashes <leader>n
          -- with "bad argument #1 to 'ipairs'". An empty list keeps the
          -- original intent (no toggle key) without the crash.
          mapping = {
            down = { '<C-d>' },
            -- <C-e> is deliberately dropped from the default { '<C-e>', '<C-u>' }
            -- because nvim-tree binds it to open-in-place below.
            up = { '<C-u>' },
            toggle = {},
          },
          hooks = {
            -- Don't preview files over 5 MB or non-text files.
            pre_open = function(path)
              local utils = require 'float-preview.utils'
              local size = utils.get_size(path)
              if type(size) ~= 'number' then
                return false
              end
              return size < 5 and utils.is_text(path)
            end,
            post_open = function()
              return true
            end,
          },
        },
      },
    },
    keys = {
      { '<leader>n', '<cmd>NvimTreeOpen<CR>', desc = 'Open file explorer (NvimTree)' },
    },
    config = function()
      local api = require 'nvim-tree.api'
      local FloatPreview = require 'float-preview'
      local close_wrap = FloatPreview.close_wrap

      local function on_attach(bufnr)
        api.events.subscribe(api.events.Event.FileCreated, function(file)
          vim.cmd('edit ' .. file.fname)
        end)

        FloatPreview.attach_nvimtree(bufnr)

        local function opts(desc)
          return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end
        local map = vim.keymap.set

        map('n', '<C-]>', api.tree.change_root_to_node, opts 'CD')
        map('n', '<C-e>', api.node.open.replace_tree_buffer, opts 'Open: In Place')
        map('n', '<C-k>', api.node.show_info_popup, opts 'Info')
        map('n', '<C-r>', api.fs.rename_sub, opts 'Rename: Omit Filename')
        map('n', '<C-t>', close_wrap(api.node.open.tab), opts 'Open: New Tab')
        map('n', '<C-gv>', close_wrap(api.node.open.vertical), opts 'Open: Vertical Split')
        map('n', '<C-gs>', close_wrap(api.node.open.horizontal), opts 'Open: Horizontal Split')
        map('n', '<BS>', api.node.navigate.parent_close, opts 'Close Directory')
        map('n', '<CR>', api.node.open.edit, opts 'Open')
        map('n', 'l', api.node.open.edit, opts 'Open')
        map('n', '>', api.node.navigate.sibling.next, opts 'Next Sibling')
        map('n', '<', api.node.navigate.sibling.prev, opts 'Previous Sibling')
        map('n', '.', api.node.run.cmd, opts 'Run Command')
        map('n', '-', api.tree.change_root_to_parent, opts 'Up')
        map('n', 'a', close_wrap(api.fs.create), opts 'Create File Or Directory')
        map('n', 'bd', api.marks.bulk.delete, opts 'Delete Bookmarked')
        map('n', 'bt', api.marks.bulk.trash, opts 'Trash Bookmarked')
        map('n', 'bmv', api.marks.bulk.move, opts 'Move Bookmarked')
        map('n', 'B', api.tree.toggle_no_buffer_filter, opts 'Toggle Filter: No Buffer')
        map('n', 'c', api.fs.copy.node, opts 'Copy')
        map('n', 'C', api.tree.toggle_git_clean_filter, opts 'Toggle Filter: Git Clean')
        map('n', '[c', api.node.navigate.git.prev, opts 'Prev Git')
        map('n', ']c', api.node.navigate.git.next, opts 'Next Git')
        map('n', 'd', close_wrap(api.fs.remove), opts 'Delete')
        map('n', 'D', api.fs.trash, opts 'Trash')
        map('n', 'E', api.tree.expand_all, opts 'Expand All')
        map('n', 'e', api.fs.rename_basename, opts 'Rename: Basename')
        map('n', ']e', api.node.navigate.diagnostics.next, opts 'Next Diagnostic')
        map('n', '[e', api.node.navigate.diagnostics.prev, opts 'Prev Diagnostic')
        map('n', 'F', api.live_filter.clear, opts 'Live Filter: Clear')
        map('n', 'f', api.live_filter.start, opts 'Live Filter: Start')
        map('n', 'g?', api.tree.toggle_help, opts 'Help')
        map('n', 'gy', api.fs.copy.absolute_path, opts 'Copy Absolute Path')
        map('n', 'H', api.tree.toggle_hidden_filter, opts 'Toggle Filter: Dotfiles')
        map('n', 'I', api.tree.toggle_gitignore_filter, opts 'Toggle Filter: Git Ignore')
        map('n', 'J', api.node.navigate.sibling.last, opts 'Last Sibling')
        map('n', 'K', api.node.navigate.sibling.first, opts 'First Sibling')
        map('n', 'M', api.tree.toggle_no_bookmark_filter, opts 'Toggle Filter: No Bookmark')
        map('n', 'm', api.marks.toggle, opts 'Toggle Bookmark')
        map('n', 'o', api.node.open.edit, opts 'Open')
        map('n', 'O', api.node.open.no_window_picker, opts 'Open: No Window Picker')
        map('n', 'p', api.fs.paste, opts 'Paste')
        map('n', 'P', api.node.navigate.parent, opts 'Parent Directory')
        map('n', 'q', close_wrap(api.tree.close), opts 'Close')
        map('n', 'r', close_wrap(api.fs.rename), opts 'Rename')
        map('n', 'R', api.tree.reload, opts 'Refresh')
        map('n', 's', api.node.run.system, opts 'Run System')
        map('n', 'S', api.tree.search_node, opts 'Search')
        map('n', 'u', api.fs.rename_full, opts 'Rename: Full Path')
        map('n', 'U', api.tree.toggle_custom_filter, opts 'Toggle Filter: Hidden')
        map('n', 'W', api.tree.collapse_all, opts 'Collapse')
        map('n', 'x', api.fs.cut, opts 'Cut')
        map('n', 'y', api.fs.copy.filename, opts 'Copy Name')
        map('n', 'Y', api.fs.copy.relative_path, opts 'Copy Relative Path')
        map('n', '<2-LeftMouse>', api.node.open.edit, opts 'Open')
        map('n', '<2-RightMouse>', api.tree.change_root_to_node, opts 'CD')

        -- Custom overrides
        map('n', '<C-[>', api.tree.change_root_to_parent, opts 'Up')
        map('n', '?', api.tree.toggle_help, opts 'Help')
        map('n', '<C-d>', api.tree.toggle_hidden_filter, opts 'Toggle Filter: Dotfiles')
        map('n', 'L', close_wrap(api.node.open.edit), opts 'Open')
        map('n', 'h', api.node.navigate.parent_close, opts 'Close')
        map('n', '<C-c>', api.tree.collapse_all, opts 'Collapse All')

        -- Unmap esc to avoid accidentally going up one directory
        pcall(vim.keymap.del, 'n', '<Esc>', { buffer = bufnr })
      end

      require('nvim-tree').setup {
        sort = { sorter = 'case_sensitive' },
        update_focused_file = { enable = true },
        view = {
          float = {
            enable = true,
            open_win_config = function()
              local screen_w = vim.opt.columns:get()
              local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
              local window_w = math.floor((screen_w - WIDTH_PADDING * 2) / 2)
              local window_h = screen_h - HEIGHT_PADDING * 2
              return {
                border = 'single',
                relative = 'editor',
                row = ((vim.opt.lines:get() - window_h) / 2) - vim.opt.cmdheight:get(),
                col = WIDTH_PADDING - 1,
                width = window_w,
                height = window_h,
              }
            end,
          },
          width = function()
            return vim.opt.columns:get() - WIDTH_PADDING * 2
          end,
        },
        renderer = { group_empty = true },
        filters = { dotfiles = true },
        on_attach = on_attach,
        git = { enable = true, ignore = false, timeout = 500 },
      }
    end,
  },

  -- Undo history
  {
    'jiaoshijie/undotree',
    dependencies = 'nvim-lua/plenary.nvim',
    keys = {
      {
        '<leader>u',
        function()
          require('undotree').toggle()
        end,
        desc = 'Toggle undotree',
      },
    },
    opts = {
      float_diff = true,
      layout = 'left_bottom',
      position = 'left',
      ignore_filetype = { 'undotree', 'undotreeDiff', 'qf', 'TelescopePrompt', 'spectre_panel', 'tsplayground' },
      window = { winblend = 30 },
      -- NOTE: the `keymaps` block was removed; it used the deprecated
      -- `{ [lhs] = action }` form and matched the plugin defaults exactly.
    },
  },

  -- Diagnostics list
  {
    'folke/trouble.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    cmd = 'Trouble',
    opts = { auto_close = true },
    keys = {
      { '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Diagnostics (Trouble)' },
      { '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = 'Buffer Diagnostics (Trouble)' },
      { '<leader>xs', '<cmd>Trouble symbols toggle focus=false<cr>', desc = 'Symbols (Trouble)' },
      { '<leader>xl', '<cmd>Trouble lsp toggle focus=false win.position=right<cr>', desc = 'LSP references (Trouble)' },
      { '<leader>xL', '<cmd>Trouble loclist toggle<cr>', desc = 'Location List (Trouble)' },
      { '<leader>xQ', '<cmd>Trouble qflist toggle<cr>', desc = 'Quickfix List (Trouble)' },
    },
  },

  -- Comments
  {
    'numToStr/Comment.nvim',
    dependencies = { 'JoosepAlviste/nvim-ts-context-commentstring' },
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      require('ts_context_commentstring').setup { enable_autocmd = false }
      require('Comment').setup {
        pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
        padding = true,
        sticky = true,
      }
    end,
  },

  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {},
  },

  {
    'ahmedkhalf/project.nvim',
    main = 'project_nvim',
    event = 'VeryLazy',
    opts = {
      manual_mode = true,
      detection_methods = { 'pattern', 'lsp' },
      patterns = { '.csproj', 'package.json' },
    },
  },

  -- Detect tabstop and shiftwidth automatically
  { 'tpope/vim-sleuth', event = { 'BufReadPost', 'BufNewFile' } },
}

-- vim: ts=2 sts=2 sw=2 et
