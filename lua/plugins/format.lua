-- [[ Formatting ]]
--
-- Replaces the old hand-rolled `kickstart/plugins/autoformat.lua`.
--
-- Formatter selection is declarative and driven by what config file the project
-- actually has. Every web formatter below sets `require_cwd = true`, which means
-- conform skips it entirely when it cannot find its config file by walking up
-- from the current buffer. The first one that resolves wins.
--
--   packages/web-components/   has .oxfmtrc.json    -> oxfmt
--   packages/react-components/ has .prettierrc.json -> prettier
--   a project with biome.json                       -> biome
--   a project with none of the above                -> nothing runs
--
-- That last case is deliberate: we never reformat a repo that has not opted in.

-- Order matters: it is the precedence when one directory has several configs
-- (packages/web-components has both .oxfmtrc.json and .prettierrc.json, and its
-- package.json `format` script uses oxfmt, so oxfmt must come first).
local web = { 'oxfmt', 'biome', 'prettierd', 'prettier', stop_after_first = true }

-- Filetypes where LSP formatting is worse than doing nothing (ts_ls, html).
local no_lsp_format = {
  javascript = true,
  javascriptreact = true,
  typescript = true,
  typescriptreact = true,
  html = true,
  vue = true,
  svelte = true,
}

return {
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo', 'Format', 'FormatDisable', 'FormatEnable', 'FormatToggle' },
    opts = function()
      return {
        notify_on_error = true,
        -- Don't spam when a project simply has no formatter configured.
        notify_no_formatters = false,

        formatters = {
          -- conform's builtin oxfmt also treats `vite.config.ts` as a config
          -- marker (for vite-plus). Combined with require_cwd that would
          -- silently enable oxfmt in every Vite project, so narrow it to real
          -- oxfmt config files.
          oxfmt = {
            require_cwd = true,
            cwd = require('conform.util').root_file {
              '.oxfmtrc.json',
              '.oxfmtrc.jsonc',
              'oxfmt.config.ts',
            },
          },
          biome = { require_cwd = true },
          prettierd = { require_cwd = true },
          prettier = { require_cwd = true },
        },

        formatters_by_ft = {
          javascript = web,
          javascriptreact = web,
          typescript = web,
          typescriptreact = web,
          vue = web,
          svelte = web,
          css = web,
          scss = web,
          less = web,
          html = web,
          json = web,
          jsonc = web,
          yaml = web,
          markdown = web,
          graphql = web,

          lua = { 'stylua' },
          sh = { 'shfmt' },
          bash = { 'shfmt' },
          python = { 'ruff_format' },
        },

        format_on_save = function(bufnr)
          -- Respect the :FormatDisable toggle (buffer-local wins over global).
          if vim.b[bufnr].disable_autoformat or vim.g.disable_autoformat then
            return
          end

          -- .kts formatting was explicitly excluded in the old config; keep that.
          if vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':e') == 'kts' then
            return
          end

          return {
            timeout_ms = 3000,
            lsp_format = no_lsp_format[vim.bo[bufnr].filetype] and 'never' or 'fallback',
          }
        end,
      }
    end,
    config = function(_, opts)
      local conform = require 'conform'
      conform.setup(opts)

      -- Unlike the old `format_is_enabled` flag (which biome and eslint
      -- ignored), these gate every on-save path.
      vim.api.nvim_create_user_command('FormatDisable', function(args)
        if args.bang then
          vim.b.disable_autoformat = true
        else
          vim.g.disable_autoformat = true
        end
      end, { desc = 'Disable format-on-save (! for current buffer only)', bang = true })

      vim.api.nvim_create_user_command('FormatEnable', function()
        vim.b.disable_autoformat = false
        vim.g.disable_autoformat = false
      end, { desc = 'Re-enable format-on-save' })

      vim.api.nvim_create_user_command('FormatToggle', function()
        vim.g.disable_autoformat = not vim.g.disable_autoformat
        vim.notify('Format on save: ' .. (vim.g.disable_autoformat and 'off' or 'on'))
      end, { desc = 'Toggle format-on-save' })

      -- Replaces the buffer-local `:Format` the old LSP on_attach created.
      vim.api.nvim_create_user_command('Format', function(args)
        local range = nil
        if args.count ~= -1 then
          local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
          range = { start = { args.line1, 0 }, ['end'] = { args.line2, end_line:len() } }
        end
        conform.format { async = true, lsp_format = 'fallback', range = range }
      end, { desc = 'Format buffer or range', range = true })
    end,
  },
}

-- vim: ts=2 sts=2 sw=2 et
