vim.opt.signcolumn = 'yes'

local lspconfig_defaults = require('lspconfig').util.default_config
lspconfig_defaults.capabilities = vim.tbl_deep_extend(
    'force',
    lspconfig_defaults.capabilities,
    require('cmp_nvim_lsp').default_capabilities()
)

vim.api.nvim_create_autocmd('LspAttach', {
    desc = 'LSP actions',
    callback = function(event)
        local opts = { buffer = event.buf }
        vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
        vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
        vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
        vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
        vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
        vim.keymap.set('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>', opts)
        vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
        vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
        vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
        vim.keymap.set({ 'n', 'x' }, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
        vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
    end,
})

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local clangd_path = vim.fn.exepath("clangd")
if clangd_path ~= "" then
    require("lspconfig").clangd.setup({
        cmd = {
            clangd_path,
            "--background-index",
            "--all-scopes-completion",
            "--completion-style=detailed",
            "--header-insertion=never",
        },
        capabilities = capabilities
    })
end

local rust_an_path = vim.fn.exepath("rust-analyzer")
if rust_an_path ~= "" then
    require("lspconfig").rust_analyzer.setup({
        capabilities = capabilities
    })
end

local pyright_path = vim.fn.exepath("pyright")
if pyright_path ~= "" then
    require("lspconfig").pyright.setup({
        capabilities = capabilities
    })
end

local lua_ls_path = vim.fn.exepath("lua-language-server")
if lua_ls_path ~= "" then
    require ("lspconfig").lua_ls.setup {
        on_init = function(client)
            local path = client.workspace_folders[1].name
            if vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc') then
                return
            end

            client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
                runtime = {
                    version = 'LuaJIT'
                },
                workspace = {
                    checkThirdParty = false,
                    library = {
                        vim.env.VIMRUNTIME
                    }
                }
            })
        end,
        settings = {
            Lua = {}
        }
    }
end

local cmp = require('cmp')

local completion_mode = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'async_path' },
    { name = 'nvim_lua' },
    { name = 'buffer', keyword_length = 3 },
}

cmp.setup({
    experimental = {
        ghost_text = false
    },
    sources = completion_mode,
    snippet = {
        expand = function(args)
            vim.snippet.expand(args.body)
        end,
    },
    completion = {
        preselect = 'item',
        completeopt = 'menu,menuone,noinsert',
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),

        -- to use tab to autocomplete --
        --[[ ['<Tab>'] = cmp.mapping.confirm({ select = false }),
        ['<C-Tab>'] = cmp.mapping(function(fallback)
            local col = vim.fn.col('.') - 1

            if cmp.visible() then
                cmp.select_next_item({behavior = 'select'})
            elseif col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
                fallback()
            else
                cmp.complete()
            end
        end, {'i', 's'}),
        ['<C-S-Tab>'] = cmp.mapping.select_prev_item({behavior = 'select'}), ]]

        -- to use enter to autocomplete --
        ['<Tab>'] = cmp.mapping(function(fallback)
            local col = vim.fn.col('.') - 1

            if cmp.visible() then
                cmp.select_next_item({ behavior = 'select' })
            elseif col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
                fallback()
            elseif vim.snippet and vim.snippet.active({ direction = 1 }) then
                vim.cmd('lua vim.snippet.jump(1)')
            else
                cmp.complete()
            end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item({ behavior = 'select' })
            elseif vim.snippet and vim.snippet.active({ direction = -1 }) then
                vim.cmd('lua vim.snippet.jump(-1)')
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<CR>'] = cmp.mapping.confirm({ select = false }),

    }),
    formatting = {
        expandable_indicator = true,
        fields = { 'abbr', 'kind', 'menu' },
        format = function(entry, item)
            local menu_icon = {
                nvim_lsp = '[LSP]',
                luasnip = '[SNP]',
                buffer = '[BUF]',
                async_path = '[PTH]',
                nvim_lua = '[NVL]',
            }
            item.menu = menu_icon[entry.source.name]
            return item
        end,
    },
})

vim.lsp.set_log_level("off")

vim.diagnostic.config({
    virtual_text = { current_line = true }
})
