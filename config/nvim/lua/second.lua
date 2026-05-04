vim.g.background = 'dark'
vim.g.netrw_liststyle = 0
vim.g.netrw_banner = 0
vim.g.netrw_sizestyle= 'h'
vim.g.netrw_localcopydircmd = 'cp -r'
vim.g.netrw_localrmdir = 'rm -r'
vim.g.netrw_keepdir = 1
vim.g.mapleader = " "
vim.g.rust_recommended_style = 0

vim.opt.grepprg = "grep -nRH --exclude-dir=.git --binary-files=without-match $*"
vim.opt.grepformat = "%f:%l:%m"
vim.opt.foldmethod = 'syntax'
vim.opt.foldlevelstart = 99
vim.opt.foldlevel = 99
vim.opt.cinoptions = "l1"
vim.opt.title = true
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.swapfile = false
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.rnu = true
vim.opt.smartcase = true
vim.opt.copyindent = true
vim.opt.signcolumn = 'yes:1'
vim.opt.wildignorecase = true
vim.opt.iskeyword:append('-')
vim.opt.wildignore:append {
  "**/node_modules/**",
  "**/target/**",
  "**/.git/**",
  "**/build/**",
}
vim.opt.path:append('**')
vim.opt.completeopt:append('noselect')
vim.opt.winborder = "double"

require('nvim-cc').default_setup()

vim.api.nvim_create_user_command("Rg", function(opts)
    vim.cmd("silent! grep! " .. opts.args .. ".")
    vim.cmd("copen")
end, { nargs = "+" })

vim.api.nvim_create_user_command("TrimWhitespace", function()
  local pos = vim.fn.getpos(".")
  vim.cmd([[%s/\s\+$//e]])
  vim.fn.setpos(".", pos)
end, {})

vim.api.nvim_create_user_command("AlignRegexp", function(opts)
  local re = opts.args
  if re == "" then
    vim.notify("AlignRegexp: missing regexp", vim.log.levels.ERROR)
    return
  end

  local start_line = opts.line1
  local end_line = opts.line2
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

  -- find max match column
  local max_col = 0
  local matches = {}

  for i, line in ipairs(lines) do
    local s, e = string.find(line, re)
    if s then
      matches[i] = s
      max_col = math.max(max_col, s)
    end
  end

  -- realign lines
  for i, line in ipairs(lines) do
    local col = matches[i]
    if col then
      local pad = string.rep(" ", max_col - col)
      lines[i] = line:sub(1, col - 1) .. pad .. line:sub(col)
    end
  end

  vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, lines)
end, {
  nargs = 1,
  range = true,
})

function get_current_dir()
    local bufname = vim.api.nvim_buf_get_name(0)
    local dir

    if bufname:sub(1, 6) == "oil://" then
        dir = bufname:sub(7)
    elseif vim.bo.buftype == "" and bufname ~= "" then
        dir = vim.fn.fnamemodify(bufname, ":p:h")
    else
        dir = vim.fn.getcwd()
    end

    if dir:sub(-1) ~= "/" then
        dir = dir .. "/"
    end
    return dir
end


local builtin = require('telescope.builtin')

vim.lsp.log.set_level 'off'
vim.lsp.enable({ 'clangd', 'rust_analyzer', 'ts_ls', 'intelephense', 'vtls', 'tailwindcss' })

vim.keymap.set({"n", "v"}, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set({"n", "v"}, "<leader>p", '"+p', { desc = "paste from system clipboard" })

vim.keymap.set("n", "<leader>bn", ":bNext<CR>",                     { desc = "Buffer next" })
vim.keymap.set("n", "<leader>bp", ":bprevious<CR>",                 { desc = "Previous next" })
vim.keymap.set("n", "<leader>tn", ":tabNext<CR>",                   { desc = "Tab next" })
vim.keymap.set("n", "<leader>tp", ":tabprevious<CR>",               { desc = "Tab next" })
vim.keymap.set("n", "<leader>tc", ":tabclose<CR>",                  { desc = "Tab close" })
vim.keymap.set("n", "<esc>", ":noh<CR>",                            { desc = "Disable the hlsearch", silent = true })
vim.keymap.set("n", "<C-j>", ":m .+1<CR>==",                        { desc = "Move Line Down" })
vim.keymap.set("n", "<C-k>", ":m .-2<CR>==",                        { desc = "Move Line Up" })
vim.keymap.set("n", "<leader>fs", ":Rg ",                           { desc = "Find String in Files" })
vim.keymap.set("n", "<leader>lfb", ":lua vim.lsp.buf.format()<CR>", { desc = "Format buffer" })
vim.keymap.set("n", "<leader>ff", builtin.find_files,               { desc = "Vim Find files" })
vim.keymap.set("n", "<leader>fb", builtin.buffers,                  { desc = "Vim Find buffer" })
vim.keymap.set("n", "<leader>fe", function()
    vim.api.nvim_feedkeys(":edit " .. get_current_dir(), "n", false)
end , { desc = "Emacs find-files magic" })
vim.keymap.set("n", "-", function()
    vim.api.nvim_input(":edit " .. get_current_dir() .. "<CR>")
end , { desc = "Tpope magic" })

vim.keymap.set("v", "<C-j>", ":m '>+1<CR>gv=gv", { desc = "Move Selection Down" })
vim.keymap.set("v", "<C-k>", ":m '<-2<CR>gv=gv", { desc = "Move Selection Up" })

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit Terminal Mode", silent = true })
vim.keymap.set("i", "jj", "<Esc>",               { desc = "Exit to normal mode", silent = true })

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function (ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client:supports_method('textDocument/completion') then
            vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
        end
        local opts = { buffer = ev.buf }
        vim.keymap.set('n', 'K',    '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
        vim.keymap.set('n', 'gd',   '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
        vim.keymap.set('n', 'gD',   '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
        vim.keymap.set('n', 'gi',   '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
        vim.keymap.set('n', 'go',   '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
        vim.keymap.set('n', 'gl',   '<cmd>lua vim.diagnostic.open_float()<cr>', opts)
        vim.keymap.set('n', 'gr',   '<cmd>lua vim.lsp.buf.references()<cr>', opts)
        vim.keymap.set('n', 'gs',   '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
        vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
        vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
    end
})

vim.api.nvim_create_autocmd({"BufWinEnter", "InsertLeave"}, {
    pattern = "*",
    callback = function()
        vim.schedule(function()
            if vim.bo.buftype == "" then
                vim.fn.clearmatches()
                vim.fn.matchadd('ErrorMsg', [[\v\s+$|^\s+$]])
            else
                vim.fn.clearmatches()
            end
        end)
    end
})

require("oil").setup({
    view_options = {
        show_hidden = true;
    }
})

require("base16").setup()
