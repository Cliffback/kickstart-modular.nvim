-- [[ snacks.nvim ]]
--
-- Replaces six plugins:
--   telescope.nvim + telescope-fzf-native -> picker
--   project.nvim                          -> picker.projects
--   dressing.nvim                         -> input + picker (ui_select)
--   nvim-notify                           -> notifier
--   indent-blankline.nvim                 -> indent
--
-- dressing.nvim was the forcing function: it was archived in February 2025.
--
-- It also upgrades opencode.nvim, which is built for snacks: `ask` gets an
-- in-process LSP for @context completion in a cursor-relative float, and
-- `select` gets a preview picker. Both activate automatically from opencode's
-- own defaults once snacks is present - no wiring needed here.

---@param picker string
---@param opts? table
local function pick(picker, opts)
  return function()
    require('snacks').picker[picker](opts or {})
  end
end

return {
  {
    'folke/snacks.nvim',
    priority = 900,
    lazy = false,
    ---@type snacks.Config
    opts = {
      -- vim.ui.input replacement (was dressing.nvim)
      input = { enabled = true },

      -- vim.notify replacement (was nvim-notify)
      notifier = {
        enabled = true,
        timeout = 3000,
        style = 'compact',
      },

      -- indent guides + scope (was indent-blankline.nvim)
      indent = { enabled = true },

      -- Disables treesitter/LSP/etc on very large files. Relevant here: the
      -- generated components.d.ts in the design system is big enough to hurt.
      bigfile = { enabled = true },

      picker = {
        enabled = true,
        -- vim.ui.select replacement (the other half of dressing.nvim)
        ui_select = true,
        sources = {
          files = {
            -- Matches the old telescope find_command: show hidden and
            -- gitignored files, but never .git or node_modules.
            hidden = true,
            ignored = true,
            exclude = { 'node_modules', '.git' },
          },
          explorer = { hidden = true },
        },
      },
    },
    keys = {
      -- [[ Files & buffers ]]
      { '<leader>?', pick 'recent', desc = '[?] Find recently opened files' },
      { '<leader><space>', pick 'buffers', desc = '[ ] Find existing buffers' },
      { '<leader>/', pick 'lines', desc = '[/] Fuzzily search in current buffer' },
      { '<leader>sf', pick 'files', desc = '[S]earch [F]iles' },
      { '<leader>gf', pick 'git_files', desc = 'Search [G]it [F]iles' },
      { '<leader>ss', pick 'pickers', desc = '[S]earch [S]elect picker' },

      -- [[ Grep ]]
      { '<leader>sg', pick 'grep', desc = '[S]earch by [G]rep' },
      { '<leader>sw', pick 'grep_word', mode = { 'n', 'x' }, desc = '[S]earch current [W]ord' },
      { '<leader>s/', pick 'grep_buffers', desc = '[S]earch [/] in Open Files' },
      {
        '<leader>sG',
        function()
          -- Git root of the current buffer, falling back to cwd.
          -- NOTE: the old implementation shelled out to `git rev-parse` on
          -- every invocation; vim.fs.root walks the tree in-process.
          local buf = vim.api.nvim_buf_get_name(0)
          local start = buf ~= '' and vim.fs.dirname(buf) or vim.fn.getcwd()
          require('snacks').picker.grep { cwd = vim.fs.root(start, '.git') or vim.fn.getcwd() }
        end,
        desc = '[S]earch by [G]rep on Git Root',
      },

      -- [[ Misc ]]
      { '<leader>sh', pick 'help', desc = '[S]earch [H]elp' },
      { '<leader>sd', pick 'diagnostics', desc = '[S]earch [D]iagnostics' },
      { '<leader>sr', pick 'resume', desc = '[S]earch [R]esume' },
      { '<leader>sp', pick 'projects', desc = '[S]earch Recent [P]rojects' },
      { '<leader>sk', pick 'keymaps', desc = '[S]earch [K]eymaps' },
      { '<leader>su', pick 'undo', desc = '[S]earch [U]ndo history' },

      -- [[ Notifications ]] (nvim-notify had no equivalent binding)
      {
        '<leader>sn',
        function()
          require('snacks').notifier.show_history()
        end,
        desc = '[S]earch [N]otification history',
      },

      -- [[ Git ]]
      {
        '<leader>gg',
        function()
          require('snacks').lazygit()
        end,
        desc = 'Lazygit',
      },
      { '<leader>gb', pick 'git_branches', desc = '[G]it [B]ranches' },
      { '<leader>gs', pick 'git_status', desc = '[G]it [S]tatus' },
      { '<leader>gL', pick 'git_log', desc = '[G]it [L]og' },
    },
  },
}

-- vim: ts=2 sts=2 sw=2 et
