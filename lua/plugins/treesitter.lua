-- [[ Treesitter ]] (main branch)
--
-- The `master` branch is frozen: its final commit, "docs(readme): list support
-- upper bounds", declares support only through Nvim 0.11. On 0.12 it is
-- actively broken here - Neovim removed the `all` compatibility option from
-- add_predicate/add_directive, which every one of master's custom directives
-- relies on:
--
--   query_predicates.lua:19
--     local opts = vim.fn.has "nvim-0.10" == 1 and { force = true, all = false } or true
--
-- With `all` ignored, handlers receive match[id] as a TSNode[] where they
-- expect a single TSNode. html_tags/injections.scm calls
-- `(#set-lang-from-mimetype! @_type)` on every `<script type="...">`, so any
-- HTML file with a typed script tag threw
-- "attempt to call method 'range' (a nil value)" and lost all highlighting.
--
-- `main` deletes query_predicates.lua entirely and rewrites those queries with
-- core-native directives (#gsub!, #eq!), so the crash is gone.
--
-- Two API changes come with it:
--   * highlighting/indent are enabled per-buffer via vim.treesitter, not opts
--   * textobjects keymaps are explicit calls rather than a declarative table
--
-- `incremental_selection` is simply gone, and does not need replacing: Neovim
-- 0.12 ships it natively in visual mode as an / in / ]n / [n, which also takes
-- a count and falls back to LSP selection ranges. See
-- `:h treesitter-incremental-selection`.

local ensure_installed = {
  'bash',
  'c',
  'c_sharp',
  'cmake',
  'cpp',
  'css',
  'csv',
  'diff',
  'go',
  'html',
  'http',
  'javascript',
  'jsdoc',
  'json',
  'kotlin',
  'lua',
  'luadoc',
  'make',
  'markdown',
  'markdown_inline',
  'python',
  'query',
  'regex',
  'rust',
  'scss',
  'sql',
  'toml',
  'tsx',
  'typescript',
  'vim',
  'vimdoc',
  'xml',
  'yaml',
}

---Install the tree-sitter CLI through Mason if it is missing.
---`main` builds parsers from source and will not work without it. Upstream
---explicitly says to install it via a package manager rather than npm; Mason
---ships the official GitHub release binary.
---@param cb fun()
local function ensure_treesitter_cli(cb)
  if vim.fn.executable 'tree-sitter' == 1 then
    return cb()
  end

  local ok, registry = pcall(require, 'mason-registry')
  if not ok then
    vim.notify('nvim-treesitter needs the tree-sitter CLI, and mason is unavailable', vim.log.levels.ERROR)
    return
  end

  registry.refresh(function()
    local pkg = registry.get_package 'tree-sitter-cli'
    if pkg:is_installed() then
      return cb()
    end
    vim.notify 'Installing tree-sitter-cli via mason…'
    pkg:install(
      nil,
      vim.schedule_wrap(function(success)
        if success then
          vim.notify 'Installed tree-sitter-cli'
          cb()
        else
          vim.notify('Failed to install tree-sitter-cli', vim.log.levels.ERROR)
        end
      end)
    )
  end)
end

return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false, -- main does not support lazy-loading
    dependencies = { 'mason-org/mason.nvim' },
    build = function()
      ensure_treesitter_cli(function()
        require('nvim-treesitter').update()
      end)
    end,
    config = function()
      require('nvim-treesitter').setup {}

      ensure_treesitter_cli(function()
        require('nvim-treesitter').install(ensure_installed)
      end)

      -- Highlighting, indentation and folds are Neovim features on `main`;
      -- the plugin only supplies parsers and queries.
      local function start(buf)
        if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].filetype == '' then
          return
        end

        local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
        if not lang or not pcall(vim.treesitter.language.add, lang) then
          return
        end

        if not pcall(vim.treesitter.start, buf, lang) then
          -- Never leave a buffer with no highlighting at all: fall back to the
          -- legacy regex syntax if the parser or its queries misbehave.
          vim.bo[buf].syntax = 'ON'
          return
        end

        if vim.treesitter.query.get(lang, 'indents') then
          vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('TreesitterStart', { clear = true }),
        callback = function(ev)
          start(ev.buf)
        end,
      })

      -- Catch up with buffers that already exist. A file named on the command
      -- line (`nvim foo.ts`) fires FileType before this config runs, so without
      -- this it would open with no treesitter highlighting at all.
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) then
          start(buf)
        end
      end
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      require('nvim-treesitter-textobjects').setup {
        select = { lookahead = true },
        move = { set_jumps = true },
      }

      local select = require 'nvim-treesitter-textobjects.select'
      local move = require 'nvim-treesitter-textobjects.move'
      local swap = require 'nvim-treesitter-textobjects.swap'

      -- NOTE: on `master` these came from a declarative table and carried no
      -- descriptions. Writing them out means they now show up properly in
      -- which-key.
      local textobjects = {
        aa = { '@parameter.outer', 'outer parameter' },
        ia = { '@parameter.inner', 'inner parameter' },
        af = { '@function.outer', 'outer function' },
        ['if'] = { '@function.inner', 'inner function' },
        ac = { '@class.outer', 'outer class' },
        ic = { '@class.inner', 'inner class' },
      }
      for lhs, spec in pairs(textobjects) do
        vim.keymap.set({ 'x', 'o' }, lhs, function()
          select.select_textobject(spec[1], 'textobjects')
        end, { desc = 'Select ' .. spec[2] })
      end

      local movements = {
        { ']m', move.goto_next_start, '@function.outer', 'Next function start' },
        { ']]', move.goto_next_start, '@class.outer', 'Next class start' },
        { ']M', move.goto_next_end, '@function.outer', 'Next function end' },
        { '][', move.goto_next_end, '@class.outer', 'Next class end' },
        { '[m', move.goto_previous_start, '@function.outer', 'Previous function start' },
        { '[[', move.goto_previous_start, '@class.outer', 'Previous class start' },
        { '[M', move.goto_previous_end, '@function.outer', 'Previous function end' },
        { '[]', move.goto_previous_end, '@class.outer', 'Previous class end' },
      }
      for _, m in ipairs(movements) do
        local lhs, fn, query, desc = m[1], m[2], m[3], m[4]
        vim.keymap.set({ 'n', 'x', 'o' }, lhs, function()
          fn(query, 'textobjects')
        end, { desc = desc })
      end

      vim.keymap.set('n', '<leader>a', function()
        swap.swap_next '@parameter.inner'
      end, { desc = 'Swap parameter with next' })
      vim.keymap.set('n', '<leader>A', function()
        swap.swap_previous '@parameter.inner'
      end, { desc = 'Swap parameter with previous' })
    end,
  },
}

-- vim: ts=2 sts=2 sw=2 et
