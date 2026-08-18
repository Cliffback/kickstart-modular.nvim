-- [[ Telescope ]]

-- Find the git root of the current buffer, falling back to cwd.
-- NOTE: the previous implementation shelled out to `git rev-parse` on every
-- invocation; vim.fs.root walks the tree in-process.
local function git_root()
  local buf = vim.api.nvim_buf_get_name(0)
  local start = buf ~= '' and vim.fs.dirname(buf) or vim.fn.getcwd()
  return vim.fs.root(start, '.git') or vim.fn.getcwd()
end

local function builtin(name, opts)
  return function()
    require('telescope.builtin')[name](opts or {})
  end
end

return {
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    cmd = 'Telescope',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
    keys = {
      { '<leader>?', builtin 'oldfiles', desc = '[?] Find recently opened files' },
      { '<leader><space>', builtin 'buffers', desc = '[ ] Find existing buffers' },
      {
        '<leader>/',
        function()
          require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown { winblend = 10, previewer = false })
        end,
        desc = '[/] Fuzzily search in current buffer',
      },
      {
        '<leader>s/',
        builtin('live_grep', { grep_open_files = true, prompt_title = 'Live Grep in Open Files' }),
        desc = '[S]earch [/] in Open Files',
      },
      { '<leader>ss', builtin 'builtin', desc = '[S]earch [S]elect Telescope' },
      { '<leader>gf', builtin 'git_files', desc = 'Search [G]it [F]iles' },
      { '<leader>sf', builtin 'find_files', desc = '[S]earch [F]iles' },
      { '<leader>sh', builtin 'help_tags', desc = '[S]earch [H]elp' },
      { '<leader>sw', builtin 'grep_string', desc = '[S]earch current [W]ord' },
      { '<leader>sg', builtin 'live_grep', desc = '[S]earch by [G]rep' },
      {
        '<leader>sG',
        function()
          require('telescope.builtin').live_grep { search_dirs = { git_root() } }
        end,
        desc = '[S]earch by [G]rep on Git Root',
      },
      { '<leader>sd', builtin 'diagnostics', desc = '[S]earch [D]iagnostics' },
      { '<leader>sr', builtin 'resume', desc = '[S]earch [R]esume' },
      { '<leader>sp', '<cmd>Telescope projects<cr>', desc = '[S]earch Recent [P]rojects' },
    },
    opts = {
      defaults = {
        mappings = {
          i = {
            ['<C-u>'] = false,
            ['<C-d>'] = false,
          },
        },
      },
      pickers = {
        find_files = {
          -- Don't use gitignore with find files
          find_command = {
            'rg',
            '--files',
            '--hidden',
            '--ignore',
            '-u',
            '--glob=!**/.git/*',
            '--glob=!**/node_modules/*',
          },
        },
      },
    },
    config = function(_, opts)
      require('telescope').setup(opts)
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'projects')
    end,
  },
}

-- vim: ts=2 sts=2 sw=2 et
