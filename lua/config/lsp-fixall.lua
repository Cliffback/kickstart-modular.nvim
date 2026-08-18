-- [[ On-save LSP "fix all" code actions ]]
--
-- Replaces the three divergent, partly-broken BufWritePre paths that used to
-- live in `kickstart/plugins/autoformat.lua`:
--
--   * `client.request(...)` was dot-called, but Client.request is a *method*
--     (see $VIMRUNTIME/lua/vim/lsp/client.lua). It passed the method name as
--     `self` and errored on every save in a biome project.
--   * a `vim.defer_fn(..., 100)` fired `silent! write` from inside BufWritePre,
--     i.e. a re-entrant write 100ms after the save.
--   * the eslint autocmd used `pattern` instead of `buffer`, so it ran for
--     every JS buffer once any eslint client attached anywhere.
--
-- This does it synchronously, buffer-scoped, with no re-entrancy.

local M = {}

-- Which code action kind to request per client name.
local FIX_ALL = {
  oxlint = 'source.fixAll.oxc',
  eslint = 'source.fixAll.eslint',
  biome = 'source.fixAll.biome',
}

---Apply a `source.fixAll.*` code action synchronously for one client.
---@param client vim.lsp.Client
---@param bufnr integer
---@param only string
local function apply_fix_all(client, bufnr, only)
  local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
  ---@diagnostic disable-next-line: inject-field
  params.context = { only = { only }, diagnostics = {} }

  local results = client:request_sync('textDocument/codeAction', params, 1500, bufnr)
  if not results or results.err or not results.result then
    return
  end

  for _, action in ipairs(results.result) do
    -- A server may hand back an unresolved action; resolve it before applying.
    if not action.edit and action.data and client:supports_method 'codeAction/resolve' then
      local resolved = client:request_sync('codeAction/resolve', action, 1500, bufnr)
      if resolved and not resolved.err and resolved.result then
        action = resolved.result
      end
    end

    if action.edit then
      vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
    end
    if action.command then
      client:exec_cmd(action, { bufnr = bufnr })
    end
  end
end

---@param bufnr integer
local function run(bufnr)
  if vim.b[bufnr].disable_autoformat or vim.g.disable_autoformat then
    return
  end

  -- If the project is a biome project, don't also let eslint rewrite the file:
  -- the two disagree and will fight over the same buffer.
  local has_biome = vim.fs.root(bufnr, { 'biome.json', 'biome.jsonc' }) ~= nil

  for _, client in ipairs(vim.lsp.get_clients { bufnr = bufnr }) do
    local only = FIX_ALL[client.name]
    if only and not (client.name == 'eslint' and has_biome) then
      local ok, err = pcall(apply_fix_all, client, bufnr, only)
      if not ok then
        vim.notify(('%s fixAll failed: %s'):format(client.name, err), vim.log.levels.WARN)
      end
    end
  end
end

function M.setup()
  local group = vim.api.nvim_create_augroup('LspFixAllOnSave', { clear = true })

  -- Attach per-buffer, only for clients that actually offer a fixAll action.
  vim.api.nvim_create_autocmd('LspAttach', {
    group = group,
    callback = function(ev)
      local client = vim.lsp.get_client_by_id(ev.data.client_id)
      if not client or not FIX_ALL[client.name] then
        return
      end
      if vim.b[ev.buf].lsp_fix_all_attached then
        return
      end
      vim.b[ev.buf].lsp_fix_all_attached = true

      vim.api.nvim_create_autocmd('BufWritePre', {
        group = group,
        buffer = ev.buf,
        desc = 'Apply source.fixAll.* code actions before writing',
        callback = function(args)
          run(args.buf)
        end,
      })
    end,
  })
end

return M

-- vim: ts=2 sts=2 sw=2 et
