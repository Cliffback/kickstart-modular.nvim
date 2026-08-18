-- [[ UI ]]

return {
  -- Colorscheme. Loaded eagerly and early so nothing renders unstyled.
  -- NOTE: onedark.nvim was removed here; it called load() at startup and was
  -- then immediately overridden by catppuccin.
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    lazy = false,
    config = function()
      require('catppuccin').setup {}
      vim.cmd.colorscheme 'catppuccin'
    end,
  },

  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    opts = {
      options = {
        icons_enabled = false,
        theme = 'auto',
        component_separators = '|',
        section_separators = '',
      },
      sections = {
        lualine_x = {
          -- opencode session status. Shows which instance is connected by
          -- directory, which matters now that there is one per worktree -
          -- the plugin's own statusline() shows `localhost:4096` instead.
          {
            function()
              local ok, status = pcall(require, 'opencode.events.status')
              if not ok then
                return ''
              end
              local server_ok, Server = pcall(require, 'opencode.server')
              local cwd = server_ok and Server.connected and Server.connected.cwd
              return status.icon() .. (cwd and (' ' .. vim.fs.basename(cwd)) or '')
            end,
            cond = function()
              return package.loaded['opencode.server'] ~= nil
            end,
          },
          'encoding',
          'fileformat',
          'filetype',
        },
      },
    },
  },

  -- Buffer line
  {
    'romgrk/barbar.nvim',
    event = 'VeryLazy',
    dependencies = {
      'lewis6991/gitsigns.nvim',
      'nvim-tree/nvim-web-devicons',
    },
    init = function()
      vim.g.barbar_auto_setup = false
    end,
    opts = {
      animation = false,
      tabpages = true,
      insert_at_end = true,
      auto_hide = 0,
      sidebar_filetypes = {
        undotree = { text = 'undotree' },
      },
    },
    version = '^1.0.0',
    keys = {
      { '<A-,>', '<Cmd>BufferPrevious<CR>', desc = 'Previous buffer' },
      { '<A-.>', '<Cmd>BufferNext<CR>', desc = 'Next buffer' },
      { '<A-<>', '<Cmd>BufferMovePrevious<CR>', desc = 'Move buffer left' },
      { '<A->>', '<Cmd>BufferMoveNext<CR>', desc = 'Move buffer right' },
      { '<A-1>', '<Cmd>BufferGoto 1<CR>', desc = 'Go to buffer 1' },
      { '<A-2>', '<Cmd>BufferGoto 2<CR>', desc = 'Go to buffer 2' },
      { '<A-3>', '<Cmd>BufferGoto 3<CR>', desc = 'Go to buffer 3' },
      { '<A-4>', '<Cmd>BufferGoto 4<CR>', desc = 'Go to buffer 4' },
      { '<A-5>', '<Cmd>BufferGoto 5<CR>', desc = 'Go to buffer 5' },
      { '<A-6>', '<Cmd>BufferGoto 6<CR>', desc = 'Go to buffer 6' },
      { '<A-7>', '<Cmd>BufferGoto 7<CR>', desc = 'Go to buffer 7' },
      { '<A-8>', '<Cmd>BufferGoto 8<CR>', desc = 'Go to buffer 8' },
      { '<A-9>', '<Cmd>BufferGoto 9<CR>', desc = 'Go to buffer 9' },
      { '<A-0>', '<Cmd>BufferLast<CR>', desc = 'Go to last buffer' },
      { '<A-p>', '<Cmd>BufferPin<CR>', desc = 'Pin/unpin buffer' },
      { '<A-c>', '<Cmd>BufferClose<CR>', desc = 'Close buffer' },
      { '<C-A-p>', '<Cmd>BufferPick<CR>', desc = 'Pick buffer' },
      -- These four previously had no description and rendered blank in which-key.
      { '<leader>bb', '<Cmd>BufferOrderByBufferNumber<CR>', desc = 'Order by [B]uffer number' },
      { '<leader>bd', '<Cmd>BufferOrderByDirectory<CR>', desc = 'Order by [D]irectory' },
      { '<leader>bl', '<Cmd>BufferOrderByLanguage<CR>', desc = 'Order by [L]anguage' },
      { '<leader>bw', '<Cmd>BufferOrderByWindowNumber<CR>', desc = 'Order by [W]indow number' },
    },
  },

  -- Colour previews.
  -- NOTE: was `filetypes = { '*' }` with `names = true`, which ran on every
  -- buffer and highlighted the words "red", "tan", "navy" in prose and
  -- identifiers. Scoped to filetypes where colours actually appear.
  {
    'NvChad/nvim-colorizer.lua',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      filetypes = {
        'css',
        'scss',
        'sass',
        'less',
        'html',
        'htmldjango',
        'liquid',
        'javascript',
        'javascriptreact',
        'typescript',
        'typescriptreact',
        'vue',
        'svelte',
        'lua',
        'conf',
      },
      user_default_options = {
        RGB = true,
        RRGGBB = true,
        names = false,
        RRGGBBAA = true,
        AARRGGBB = true,
        rgb_fn = true,
        hsl_fn = true,
        css = true,
        css_fn = true,
        mode = 'background',
        tailwind = true,
        sass = { enable = false, parsers = { 'css' } },
        virtualtext = '■',
        always_update = false,
      },
      buftypes = {},
    },
  },

  -- NOTE: indent-blankline.nvim, nvim-notify and dressing.nvim were replaced by
  -- snacks.nvim (indent / notifier / input + picker.ui_select). dressing was
  -- the forcing function: archived February 2025.

  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {},
    config = function(_, opts)
      require('which-key').setup(opts)
      require('config.keymaps').setup_which_key()
    end,
  },

  { 'nvim-tree/nvim-web-devicons', lazy = true },
}

-- vim: ts=2 sts=2 sw=2 et
