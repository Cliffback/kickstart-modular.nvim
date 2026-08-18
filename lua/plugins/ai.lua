-- [[ AI ]]

-- opencode.nvim is a bridge, not a UI: it connects to a running `opencode`
-- server and drives its TUI. It deliberately owns no window, which is why it
-- exposes no `toggle()` - the TUI lives in whatever terminal you put it in.
-- We host it in a right sidebar, one instance per directory; see
-- lua/config/opencode-term.lua.

---Is `a` the same path as `b`, or inside it?
---
---This is the boundary-correct version of the comparison opencode.nvim makes
---in server/discovery/init.lua, which uses a bare string prefix:
---
---  server.cwd:find(nvim_cwd, 0, true) == 1 or nvim_cwd:find(server.cwd, 0, true) == 1
---
---With no separator check, `/dev/statnett-designsystem` (the main repo) is a
---prefix of `/dev/statnett-designsystem-wt/<branch>` (every worktree), so a
---single opencode running in the main repo matches *every* worktree session and
---silently receives prompts meant for a different tree.
---@param a string
---@param b string
---@return boolean
local function under(a, b)
  return a == b or a:sub(1, #b + 1) == b .. '/'
end

---Resolve the opencode server whose cwd genuinely corresponds to Neovim's.
---
---`server.url` is consulted before the built-in cwd filter (discovery tries
---connected -> configured -> local+filter), so this bypasses the loose match
---entirely. Resolving nil is safe: it rejects, and discovery falls through to
---`server.start`, which starts one in the current directory. Worst case that is
---an extra instance, never the wrong tree.
---@param cb fun(url: string?)
local function resolve_server_url(cb)
  local ok, discovery = pcall(require, 'opencode.server.discovery.process')
  if not ok then
    return cb(nil)
  end

  local Promise = require 'opencode.promise'
  local Server = require 'opencode.server'
  local nvim_cwd = vim.fs.normalize(vim.fn.getcwd())

  discovery
    .get()
    :next(function(processes)
      if #processes == 0 then
        cb(nil)
        return Promise.resolve()
      end

      return Promise.all_settled(vim.tbl_map(function(process)
        return Server.new('http://localhost:' .. process.port)
      end, processes)):next(function(results)
        local best, best_cwd

        for _, result in ipairs(results) do
          local server = result.status == 'fulfilled' and result.value
          if server and server.cwd then
            local cwd = vim.fs.normalize(server.cwd)
            if under(nvim_cwd, cwd) or under(cwd, nvim_cwd) then
              -- Several can legitimately match (a server in a subdirectory of
              -- the one Neovim sits in). Prefer the most specific.
              if not best_cwd or #cwd > #best_cwd then
                best, best_cwd = server, cwd
              end
            end
          end
        end

        cb(best and best.url or nil)
      end)
    end)
    :catch(function()
      cb(nil)
    end)
end

return {
  -- NOTE: github/copilot.vim was removed. It ran alongside copilot.lua, giving
  -- two ghost-text providers, and claimed <Tab> in insert mode.
  {
    'zbirenbaum/copilot.lua',
    event = 'InsertEnter',
    cmd = 'Copilot',
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        max_width = 80,
        keymap = {
          -- <Tab> is safe here: copilot.lua registers this buffer-locally with
          -- passthrough, so it only accepts while a suggestion is visible and
          -- otherwise falls back to whatever <Tab> was already bound to. Same
          -- behaviour copilot.vim's copilot#Accept() had.
          accept = '<Tab>',
          accept_word = '<M-Right>',
          next = '<M-]>',
          prev = '<M-[>',
          dismiss = '<M-h>',
        },
      },
      panel = { enabled = false },
    },
  },

  {
    'CopilotC-Nvim/CopilotChat.nvim',
    dependencies = {
      'zbirenbaum/copilot.lua',
      { 'nvim-lua/plenary.nvim', branch = 'master' },
    },
    build = 'make tiktoken',
    cmd = {
      'CopilotChat',
      'CopilotChatOpen',
      'CopilotChatClose',
      'CopilotChatToggle',
      'CopilotChatStop',
      'CopilotChatReset',
      'CopilotChatSave',
      'CopilotChatLoad',
      'CopilotChatPrompts',
      'CopilotChatModels',
      'CopilotChatDocs',
      'CopilotChatExplain',
      'CopilotChatFix',
    },
    keys = {
      {
        '<leader>cci',
        function()
          vim.ui.input({ prompt = 'CopilotChat: ' }, function(input)
            if input and input ~= '' then
              vim.cmd('CopilotChat ' .. input)
            end
          end)
        end,
        desc = 'Open chat window with input',
      },
      { '<leader>cco', '<cmd>CopilotChatOpen<CR>', desc = 'Open chat window' },
      { '<leader>ccc', '<cmd>CopilotChatClose<CR>', desc = 'Close chat window' },
      { '<leader>cct', '<cmd>CopilotChatToggle<CR>', desc = 'Toggle chat window' },
      { '<leader>ccx', '<cmd>CopilotChatStop<CR>', desc = 'Stop current copilot output' },
      { '<leader>ccr', '<cmd>CopilotChatReset<CR>', desc = 'Reset chat window' },
      {
        '<leader>ccs',
        function()
          vim.ui.input({ prompt = 'Save chat as: ' }, function(name)
            if name and name ~= '' then
              vim.cmd('CopilotChatSave ' .. name)
            end
          end)
        end,
        desc = 'Save chat history to file',
      },
      {
        '<leader>ccl',
        function()
          vim.ui.input({ prompt = 'Load chat: ' }, function(name)
            if name and name ~= '' then
              vim.cmd('CopilotChatLoad ' .. name)
            end
          end)
        end,
        desc = 'Load chat history from file',
      },
      -- NOTE: <leader>cch/<leader>ccp used to call CopilotChat.actions via
      -- CopilotChat.integrations.telescope, and <leader>ccd called
      -- :CopilotChatDebugInfo. All three were removed upstream, so those
      -- mappings had been silently broken.
      { '<leader>ccp', '<cmd>CopilotChatPrompts<CR>', desc = 'Show [P]rompt actions' },
      { '<leader>ccm', '<cmd>CopilotChatModels<CR>', desc = 'Select [M]odel' },
      { '<leader>ccd', '<cmd>CopilotChatDocs<CR>', mode = { 'n', 'x' }, desc = 'Add [D]ocumentation for selection' },
      { '<leader>cce', '<cmd>CopilotChatExplain<CR>', mode = { 'n', 'x' }, desc = '[E]xplain selection' },
      { '<leader>ccf', '<cmd>CopilotChatFix<CR>', mode = { 'n', 'x' }, desc = '[F]ix selection' },
    },
    opts = {
      model = 'claude-opus-4.5',
      window = {
        layout = 'float',
        relative = 'editor',
        width = 0.5,
        height = 0.5,
      },
      mappings = {
        complete = { insert = '' },
      },
    },
  },

  {
    'nickjvandyke/opencode.nvim',
    version = '*',
    dependencies = { 'akinsho/toggleterm.nvim' },
    keys = {
      {
        '<leader>ot',
        function()
          require('config.opencode-term').toggle()
        end,
        -- NOTE: normal mode only. This used to include terminal mode, which
        -- meant typing a space followed by `ot` in any shell fired the toggle
        -- instead of inserting the text.
        desc = 'Toggle opencode',
      },
      {
        '<leader>oa',
        function()
          -- Show the sidebar when we own the instance, so the reply is visible.
          -- opencode only ever types into its TUI; Neovim never sees the answer.
          local term = require 'config.opencode-term'
          if term.is_running() then
            term.open()
          end
          require('opencode').ask '@this: '
        end,
        mode = { 'n', 'x' },
        desc = 'Ask opencode',
      },
      {
        '<leader>ox',
        function()
          require('opencode').select()
        end,
        mode = { 'n', 'x' },
        desc = 'Execute opencode action',
      },
      {
        '<leader>oo',
        function()
          return require('opencode').operator '@this '
        end,
        mode = { 'n', 'x' },
        expr = true,
        desc = 'Add range to opencode',
      },
      {
        '<leader>ool',
        function()
          return require('opencode').operator '@this ' .. '_'
        end,
        expr = true,
        desc = 'Add line to opencode',
      },
      -- Contexts other than @this had no bindings at all.
      {
        '<leader>od',
        function()
          require('opencode').ask 'Explain @diagnostics: '
        end,
        desc = 'Ask opencode about @[d]iagnostics',
      },
      {
        '<leader>ob',
        function()
          require('opencode').ask '@buffers: '
        end,
        desc = 'Ask opencode about @[b]uffers',
      },
      {
        '<leader>oq',
        function()
          require('opencode').ask '@quickfix: '
        end,
        desc = 'Ask opencode about @[q]uickfix',
      },
      -- Scrolling the TUI from Neovim. Moved off <leader>ou/<leader>od to the
      -- keys upstream recommends, freeing <leader>od for @diagnostics.
      {
        '<C-S-u>',
        function()
          require('opencode').command 'session.half.page.up'
        end,
        desc = 'Scroll opencode up',
      },
      {
        '<C-S-d>',
        function()
          require('opencode').command 'session.half.page.down'
        end,
        desc = 'Scroll opencode down',
      },
    },
    init = function()
      -- Set before the plugin loads: opencode.config resolves vim.g at require
      -- time.
      ---@type opencode.Opts
      vim.g.opencode_opts = {
        server = {
          -- Consulted before the built-in (loose) cwd filter.
          url = resolve_server_url,
          -- Start the TUI in our right sidebar for the current directory,
          -- rather than the default raw `vsplit term://opencode --port`.
          start = function()
            require('config.opencode-term').open()
          end,
        },
      }
      vim.o.autoread = true
    end,
  },
}

-- vim: ts=2 sts=2 sw=2 et
