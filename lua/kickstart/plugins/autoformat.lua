-- autoformat.lua
--
-- Use your language server to automatically format your code on save.
-- Adds additional commands as well to manage the behavior

return {
  'neovim/nvim-lspconfig',
  config = function()
    -- Switch for controlling whether you want autoformatting.
    --  Use :KickstartFormatToggle to toggle autoformatting on or off
    local format_is_enabled = true
    vim.api.nvim_create_user_command('KickstartFormatToggle', function()
      format_is_enabled = not format_is_enabled
      print('Setting autoformatting to: ' .. tostring(format_is_enabled))
    end, {})

    -- Create an augroup that is used for managing our formatting autocmds.
    --      We need one augroup per client to make sure that multiple clients
    --      can attach to the same buffer without interfering with each other.
    local _augroups = {}
    local get_augroup = function(client)
      if not _augroups[client.id] then
        local group_name = 'kickstart-lsp-format-' .. client.name
        local id = vim.api.nvim_create_augroup(group_name, { clear = true })
        _augroups[client.id] = id
      end

      return _augroups[client.id]
    end

    -- Whenever an LSP attaches to a buffer, we will run this function.
    --
    -- See `:help LspAttach` for more information about this autocmd event.
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach-format', { clear = true }),
      -- This is where we attach the autoformatting for reasonable clients
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local bufnr = args.buf

        if not client then
          return
        end

        if client.name == "biome" then
          -- This approach is cleaner, but returns "no code action" when there are no fixes to apply
          --   vim.api.nvim_create_autocmd("BufWritePre", {
          --     group = vim.api.nvim_create_augroup("BiomeFixAll", { clear = true }),
          --     callback = function()
          --       vim.lsp.buf.code_action({
          --         context = {
          --           only = { "source.fixAll.biome" },
          --           diagnostics = {},
          --         },
          --         apply = true,
          --       })
          --     end,
          --   })

          vim.api.nvim_create_autocmd("BufWritePre", {
            group = vim.api.nvim_create_augroup("BiomeFixAll", { clear = true }),
            callback = function()
              if not client then return end

              local params = vim.lsp.util.make_range_params(nil, client.offset_encoding)
              params.context = {
                only = { "source.fixAll.biome" },
                diagnostics = {},
              }

              client.request("textDocument/codeAction", params, function(_, result)
                if result and not vim.tbl_isempty(result) then
                  vim.notify("Applying 'fixAll' actions from Biome")
                  for _, action in pairs(result) do
                    if action.command then
                      client:exec_cmd(action, { bufnr = bufnr })
                    elseif action.edit then
                      vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
                    end
                  end
                else
                  -- No fixAll actions available, fallback to formatting
                  vim.notify("No 'fixAll' actions from Biome, falling back to formatting")
                  vim.lsp.buf.format({
                    bufnr = bufnr,
                    async = false,
                    filter = function(c)
                      return c.name == "biome" or c.id == client.id
                    end,
                  })
                end
              end, bufnr)
            end,
          })
          return
        end

        if client.name == 'eslint' then
          vim.api.nvim_create_autocmd('BufWritePre', {
            pattern = { '*.tsx', '*.ts', '*.jsx', '*.js' },
            command = 'silent! EslintFixAll',
            group = get_augroup(client),
          })
          -- vim.api.nvim_create_autocmd('BufWritePre', {
          --   pattern = { '*.tsx', '*.ts', '*.jsx', '*.js' },
          --   command = 'TSC',
          --   group = get_augroup(client),
          -- })
          return
        end

        -- Tsserver usually works poorly. Sorry you work with bad languages
        local serverOverrides = { 'ts_ls', 'typescript-tools', 'html', 'tsserver' }
        -- Only attach to clients that support document formatting
        if not client.server_capabilities.documentFormattingProvider or vim.tbl_contains(serverOverrides, client.name) then
          return
        end

        -- Exclude .kts files from formatting
        if vim.fn.expand('%:e') == 'kts' then
          return
        end

        -- Create an autocmd that will run *before* we save the buffer.
        --  Run the formatting command for the LSP that has just attached.
        vim.api.nvim_create_autocmd('BufWritePre', {
          group = get_augroup(client),
          buffer = bufnr,
          callback = function()
            if not format_is_enabled then
              return
            end

            vim.lsp.buf.format {
              async = false,
              filter = function(c)
                return c.id == client.id
              end,
            }
          end,
        })
      end,
    })
  end,
}
