-- [[ Tools ]]

return {
  -- Terminal
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    -- NOTE: `open_mapping` is deliberately unset. It installs a *buffer-local*
    -- <C-\> on every terminal toggleterm creates - including opencode's - bound
    -- to a bare `:ToggleTerm`. Bare ToggleTerm runs smart_toggle, which closes
    -- every open toggleterm window rather than toggling one, so pressing <C-\>
    -- inside opencode closed opencode instead of opening a shell. And because
    -- the mapping is buffer-local it beat any global override.
    --
    -- `1ToggleTerm` routes to toggle_nth_term(1), which touches only terminal 1.
    -- opencode's terminals start at id 90 (see config/opencode-term.lua), so the
    -- two can be open at once and toggle independently.
    keys = {
      { [[<C-\>]], '<Cmd>1ToggleTerm<CR>', mode = { 'n', 't' }, desc = 'Toggle terminal' },
    },
    cmd = { 'ToggleTerm', 'TermExec' },
    opts = {
      -- Resolved per terminal (ui.lua:408 -> _resolve_size), so branch on
      -- direction: the opencode sidebar wants ~40% of the screen width, a
      -- horizontal split wants a modest number of lines.
      size = function(term)
        if term.direction == 'vertical' then
          return math.floor(vim.o.columns * 0.4)
        end
        return 20
      end,
      hide_numbers = true,
      shade_filetypes = {},
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      persist_size = true,
      -- Always land in terminal mode when toggling back in, rather than
      -- restoring whatever mode was left behind.
      persist_mode = false,
      direction = 'float',
      close_on_exit = true,
      shell = vim.o.shell,
      float_opts = {
        border = 'curved',
        winblend = 0,
        highlights = { border = 'Normal', background = 'Normal' },
      },
    },
  },

  -- Build/run
  {
    'Zeioth/compiler.nvim',
    cmd = { 'CompilerOpen', 'CompilerToggleResults', 'CompilerRedo', 'CompilerStop' },
    dependencies = { 'stevearc/overseer.nvim' },
    opts = {},
    keys = {
      { '<F6>', '<cmd>CompilerOpen<cr>', desc = 'Open compiler' },
      { '<F7>', '<cmd>CompilerStop<cr><cmd>CompilerRedo<cr>', desc = 'Redo last compiler task' },
    },
  },
  {
    'stevearc/overseer.nvim',
    cmd = { 'CompilerOpen', 'CompilerToggleResults', 'CompilerRedo', 'OverseerOpen', 'OverseerClose' },
    opts = {
      task_list = {
        direction = 'bottom',
        min_height = 25,
        max_height = 25,
        default_detail = 1,
      },
    },
  },

  -- Database
  {
    'kndndrj/nvim-dbee',
    dependencies = { 'MunifTanjim/nui.nvim' },
    -- Loaded on demand: dbee calls the deprecated `vim.validate{<table>}` at
    -- require time, which surfaced as a startup warning on every launch.
    cmd = 'Dbee',
    keys = {
      {
        '<leader>db',
        function()
          require('dbee').open()
        end,
        desc = 'Open Database Browser',
      },
    },
    build = function()
      require('dbee').install()
    end,
    config = function()
      require('dbee').setup()
    end,
  },

  -- Markdown preview
  -- NOTE: was <C-p>/<C-s>/<M-s>, which shadowed common motions.
  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    build = 'cd app && yarn install',
    init = function()
      vim.g.mkdp_filetypes = { 'markdown' }
    end,
    ft = { 'markdown' },
    keys = {
      { '<leader>mp', '<cmd>MarkdownPreviewToggle<CR>', desc = 'Markdown [P]review toggle' },
      { '<leader>ms', '<cmd>MarkdownPreview<CR>', desc = 'Markdown preview [S]tart' },
      { '<leader>mx', '<cmd>MarkdownPreviewStop<CR>', desc = 'Markdown preview stop' },
    },
  },

  -- [[ Learning aids ]]
  -- Both ship disabled; the keys below load the plugin and toggle it on.
  {
    'm4xshen/hardtime.nvim',
    dependencies = { 'MunifTanjim/nui.nvim', 'nvim-lua/plenary.nvim' },
    cmd = 'Hardtime',
    keys = {
      { '<leader>ph', '<cmd>Hardtime toggle<CR>', desc = 'Toggle [H]ardtime' },
      {
        '<leader>pb',
        function()
          vim.cmd 'Hardtime toggle'
          require('precognition').toggle()
        end,
        desc = 'Toggle [B]oth (hardtime + precognition)',
      },
    },
    opts = {
      enabled = false,
      disabled_filetypes = {
        'qf',
        'netrw',
        'NvimTree',
        'lazy',
        'mason',
        'oil',
        'Dressing*',
        'notify',
        'Trouble',
        'dapui',
        'TelescopePrompt',
      },
    },
  },
  {
    'tris203/precognition.nvim',
    keys = {
      {
        '<leader>pp',
        function()
          require('precognition').toggle()
        end,
        desc = 'Toggle [P]recognition',
      },
    },
    opts = { startVisible = false },
  },
}

-- vim: ts=2 sts=2 sw=2 et
