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
vim.g.tokyonight_style = 'storm'
vim.cmd [[colo tokyonight]]

-- Statusline


-- Telescope
local telescope = require('telescope.builtin')
vim.api.nvim_set_keymap('n', 'ff', ":Telescope find_files<CR>", { silent = true })
vim.api.nvim_set_keymap('n', 'fs', ":Telescope live_grep<CR>", { silent = true })
vim.api.nvim_set_keymap('n', ';', ":Telescope buffers<CR>", { silent = true })

-- Treesitter
local ts = require 'nvim-treesitter.configs'
ts.setup { ensure_installed = { 'c', 'cpp', 'python', 'lua', 'clojure', 'javascript', 'typescript', 'tsx' }, 
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
  current_line_blame_delay = 200,
}

-- LSP, stole from https://jose-elias-alvarez.medium.com/configuring-neovims-lsp-client-for-typescript-development-5789d58ea9c
local nvim_lsp = require("lspconfig")
local format_async = function(err, _, result, _, bufnr)
    if err ~= nil or result == nil then return end
    if not vim.api.nvim_buf_get_option(bufnr, "modified") then
        local view = vim.fn.winsaveview()
        vim.lsp.util.apply_text_edits(result, bufnr)
        vim.fn.winrestview(view)
        if bufnr == vim.api.nvim_get_current_buf() then
            vim.api.nvim_command("noautocmd :update")
        end
    end
end
vim.lsp.handlers["textDocument/formatting"] = format_async
_G.lsp_organize_imports = function()
    local params = {
        command = "_typescript.organizeImports",
        arguments = {vim.api.nvim_buf_get_name(0)},
        title = ""
    }
    vim.lsp.buf.execute_command(params)
end
local on_attach = function(client, bufnr)
    local buf_map = vim.api.nvim_buf_set_keymap
    vim.cmd("command! LspDef lua vim.lsp.buf.definition()")
    vim.cmd("command! LspFormatting lua vim.lsp.buf.formatting()")
    vim.cmd("command! LspCodeAction lua vim.lsp.buf.code_action()")
    vim.cmd("command! LspHover lua vim.lsp.buf.hover()")
    vim.cmd("command! LspRename lua vim.lsp.buf.rename()")
    vim.cmd("command! LspOrganize lua lsp_organize_imports()")
    vim.cmd("command! LspRefs lua vim.lsp.buf.references()")
    vim.cmd("command! LspTypeDef lua vim.lsp.buf.type_definition()")
    vim.cmd("command! LspImplementation lua vim.lsp.buf.implementation()")
    vim.cmd("command! LspDiagPrev lua vim.lsp.diagnostic.goto_prev()")
    vim.cmd("command! LspDiagNext lua vim.lsp.diagnostic.goto_next()")
    vim.cmd(
        "command! LspDiagLine lua vim.lsp.diagnostic.show_line_diagnostics()")
    vim.cmd("command! LspSignatureHelp lua vim.lsp.buf.signature_help()")
    buf_map(bufnr, "n", "gd", ":LspDef<CR>", {silent = true})
    buf_map(bufnr, "n", "gr", ":LspRename<CR>", {silent = true})
    buf_map(bufnr, "n", "gR", ":LspRefs<CR>", {silent = true})
    buf_map(bufnr, "n", "gy", ":LspTypeDef<CR>", {silent = true})
    buf_map(bufnr, "n", "K", ":LspHover<CR>", {silent = true})
    buf_map(bufnr, "n", "gs", ":LspOrganize<CR>", {silent = true})
    buf_map(bufnr, "n", "[a", ":LspDiagPrev<CR>", {silent = true})
    buf_map(bufnr, "n", "]a", ":LspDiagNext<CR>", {silent = true})
    buf_map(bufnr, "n", "ga", ":LspCodeAction<CR>", {silent = true})
    buf_map(bufnr, "n", "<Leader>a", ":LspDiagLine<CR>", {silent = true})
    buf_map(bufnr, "i", "<C-x><C-x>", "<cmd> LspSignatureHelp<CR>",
              {silent = true})
if client.resolved_capabilities.document_formatting then
        vim.api.nvim_exec([[
         augroup LspAutocommands
             autocmd! * <buffer>
             autocmd BufWritePost <buffer> LspFormatting
         augroup END
         ]], true)
    end
end
nvim_lsp.tsserver.setup {
    on_attach = function(client)
        client.resolved_capabilities.document_formatting = false
        on_attach(client)
    end
}
local filetypes = {
    typescript = "eslint",
    typescriptreact = "eslint",
    javascript = "eslint",
    javascriptreact = "eslint",
}
local linters = {
    eslint = {
        sourceName = "eslint",
        command = "eslint_d",
        rootPatterns = {".eslintrc.js", "package.json"},
        debounce = 100,
        args = {"--stdin", "--stdin-filename", "%filepath", "--format", "json"},
        parseJson = {
            errorsRoot = "[0].messages",
            line = "line",
            column = "column",
            endLine = "endLine",
            endColumn = "endColumn",
            message = "${message} [${ruleId}]",
            security = "severity"
        },
        securities = {[2] = "error", [1] = "warning"}
    }
}

local formatters = {
    prettier = {command = "prettier", args = {"--stdin-filepath", "%filepath"}},
    prettierEslint = {command = "prettier-eslint", args = {"--stdin"}}
}
local formatFiletypes = {
    typescript = "prettier",
    javascript = "prettierEslint",
    typescriptreact = "prettier",
    javascriptreact = "prettierEslint"
}
nvim_lsp.diagnosticls.setup {
    on_attach = on_attach,
    filetypes = vim.tbl_keys(filetypes),
    init_options = {
        filetypes = filetypes,
        linters = linters,
        formatters = formatters,
        formatFiletypes = formatFiletypes
    }
}

-- Autocomplete
-- use .ts snippets in .tsx files
require"compe".setup {
    preselect = "always",
    source = {
        path = true,
        buffer = true,
        nvim_lsp = true,
        nvim_lua = true
    }
}
local t = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end
_G.tab_complete = function()
    if vim.fn.pumvisible() == 1 then
        return vim.fn["compe#confirm"]()
    --elseif vim.fn.call("vsnip#available", {1}) == 1 then
    --    return t("<Plug>(vsnip-expand-or-jump)")
    else
        return t("<Tab>")
    end
end
vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("i", "<C-Space>", "compe#complete()",
                        {expr = true, silent = true})
vim.api.nvim_set_keymap("i", "<CR>", [[compe#confirm("<CR>")]],
                        {expr = true, silent = true})
vim.api.nvim_set_keymap("i", "<C-e>", [[compe#close("<C-e>")]],
                        {expr = true, silent = true})
