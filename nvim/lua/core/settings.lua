local function set(config)
  vim.api.nvim_command('set ' .. config)
end

set('number')

-- Tabs
set('formatoptions=tcqrn1')
set('tabstop=2')
set('shiftwidth=2')
set('softtabstop=2')
set('expandtab')
set('noshiftround')

-- Buffer
set('hidden')

-- Theme
vim.g.tokyonight_style = 'night'
--vim.g.gruvbox_contrast_dark = 'hard'
--vim.g.gruvbox_termcolors = 256 
vim.cmd [[colo tokyonight]]

-- Statusline


-- Telescope
local telescope = require('telescope.builtin')
vim.api.nvim_set_keymap('n', 'ff', ":Telescope find_files<CR>", { silent = true })
vim.api.nvim_set_keymap('n', 'fs', ":Telescope live_grep<CR>", { silent = true })
vim.api.nvim_set_keymap('n', ';', ":Telescope buffers<CR>", { silent = true })

-- Treesitter
local ts = require 'nvim-treesitter.configs'
ts.setup { ensure_installed = { 'c', 'cpp', 'python', 'lua', 'clojure', 'javascript', 'typescript', 'tsx', 'go', 'ruby' }, 
            highlight = {enable = true}}
-- search params, var, imports
vim.api.nvim_set_keymap('n', 'ft', ":Telescope treesitter<CR>", { silent = true })

-- Git
-- git status with diffs via Telescope
vim.api.nvim_set_keymap('n', '<Leader>gs', ":Telescope git_status<CR>", { silent = true })
require('gitsigns').setup {
  signs = {
    add = {hl = 'GitSignsAdd', text = '+'},
    change = {hl = 'GitSignsChange', text = '~'},
    delete = {hl = 'GitSignsDelete', text = '-'},
  },
  keymaps = {
    noremap = true,
    buffer = true,

    ['n <Leader>nh'] = {expr = true, '&diff ? \']g\' : \'<cmd>lua require"gitsigns".next_hunk()<CR>\''},
    ['n <Leader>ph'] = {expr = true, '&diff ? \'[g\' : \'<cmd>lua require"gitsigns".prev_hunk()<CR>\''},
    ['n <Leader>sh'] = {expr = true, '&diff ? \'[g\' : \'<cmd>lua require"gitsigns".stage_hunk()<CR>\''},
    ['n <Leader>ush'] = {expr = true, '&diff ? \'[g\' : \'<cmd>lua require"gitsigns".undo_stage_hunk()<CR>\''},

    ['n <Leader>gd'] = '<cmd>lua require"gitsigns".diffthis()<CR>',
    ['n <Leader>gb'] = '<cmd>lua require"gitsigns".blame_line()<CR>',
  },
  current_line_blame = true,
  current_line_blame_opts = { delay = 200 }
}

local nvim_lsp = require("lspconfig")
local cmp = require("cmp")

-- dap


local dap = require('dap')
dap.adapters.ruby = {
  type = 'executable';
  command = 'bundle';
  args = {'exec', 'readapt', 'serve'};
}

dap.configurations.ruby = {
  {
    type = 'ruby';
    request = 'launch';
    name = 'Rails';
    program = 'bundle';
    programArgs = {'exec', 'rails', 's'};
    useBundler = true;
  },
}

cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
      -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
      -- require'snippy'.expand_snippet(args.body) -- For `snippy` users.
    end,
  },
  mapping = {
    ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
    ['<C-e>'] = cmp.mapping({
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    }),
    -- Accept currently selected item. If none selected, `select` first item.
    -- Set `select` to `false` to only confirm explicitly selected items.
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    -- { name = 'vsnip' }, -- For vsnip users.
    { name = 'luasnip' }, -- For luasnip users.
    -- { name = 'ultisnips' }, -- For ultisnips users.
    -- { name = 'snippy' }, -- For snippy users.
  }, {
    { name = 'buffer' },
  })
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})


-- Setup lspconfig.
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

  opts = { silent = true }

  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap("n", "gi", '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
end

local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

local servers = {
  'solargraph',
  'tsserver',
  'gopls'
}

nvim_lsp['solargraph'].setup {
  capabilities = capabilities,
  on_attach = on_attach
}

nvim_lsp['tsserver'].setup {
  on_attach = on_attach
}

nvim_lsp['gopls'].setup {
  on_attach = on_attach
}

-- IDE? setup
-- require('litee').setup({})

-- Splits
require("focus").setup()
