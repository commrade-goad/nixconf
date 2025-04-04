-- Nvim_cc_start_insert = false
Nvim_cc_blacklist_dir_name = {"src", "bin"}

local nvim_cc = require("mod.nvim-cc")
local bj = require("mod.jumpbuff")
local wk = require("which-key")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("i", "<C-c>", "<Esc>")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

--== NEW NOTES 0.11 BINDINGS ==--

--   grn in Normal mode maps to vim.lsp.buf.rename()
--   grr in Normal mode maps to vim.lsp.buf.references()
--   gri in Normal mode maps to vim.lsp.buf.implementation()
--   gO  in Normal mode maps to vim.lsp.buf.document_symbol()
--   gra in Normal and Visual mode maps to vim.lsp.buf.code_action()
--   [q, ]q, [Q, ]Q, [CTRL-Q, ]CTRL-Q navigate through the quickfix list
--   [a, ]a, [A, ]A navigate through the argument list
--   [b, ]b, [B, ]B navigate through the buffer list
--   [<Space>, ]<Space> add an empty line above and below the cursor

--== END NOTES 0.11 BINDINGS ==--


wk.add({
    { "<leader>", group = "Leader" },
    { "<leader>y", "\"+y", desc = "Yank/Copy to System Clipboard", mode = "v" },
    { "<leader>nt", ":tabe .<CR>", desc = "Open New Tab", mode = "n" },
    { "<leader>os", ":cd ~/.config/nvim | :Telescope find_files<CR>", desc = "Open Nvim Config"},
    { "<leader><Esc>", "<C-\\><C-n>", desc = "Exit Terminal Mode", mode = "t", hidden = true },
    { "<Esc>", ":noh<CR>", desc = "Clear Search Highlight", mode = "n", hidden = true },
    { "<C-j>", ":m '>+1<CR>gv=gv", desc = "Move Selection Down", mode = "v" },
    { "<C-k>", ":m '<-2<CR>gv=gv", desc = "Move Selection Up", mode = "v" },
    { "<C-j>", ":m .+1<CR>==", desc = "Move Line Down", mode = "n" },
    { "<C-k>", ":m .-2<CR>==", desc = "Move Line Up", mode = "n" },
    { "<leader>jj", "<cmd>normal! %<CR>", desc = "Jump Matching Parenthesis", mode = { "n", "v" } },
    { "<leader>jh", "<cmd>normal! ^<CR>", desc = "Jump to Line Start", mode = { "n", "v" } },
    { "<leader>jl", "<cmd>normal! $<CR>", desc = "Jump to Line End", mode = { "n", "v" } },
    { "<leader><leader>x", "<cmd>source %<CR>", desc = "Source Current File (Lua)", mode = "n" },
    -- { "<leader>ut", "<cmd>UndotreeToggle<CR>", desc = "Toggle Undo Tree", mode = "n" },
    { "<leader>.", "<cmd>Ex<CR>", desc = "Open Netrw", mode = "n"},
    {"<leader>mp", "<cmd>Man<CR>", desc = "Open man page of the current word", mode = "n"},

    { "<leader>dl", function()
        local cursor_pos = vim.api.nvim_win_get_cursor(0)
        print(cursor_pos)
        vim.cmd("normal! yyp")
        vim.api.nvim_win_set_cursor(0, { cursor_pos[1] + 1, cursor_pos[2] })
    end,
        desc = "Duplicate Line with Cursor",
        mode = "n",
    },

    { "<leader>gs", ":Git<CR>", desc = "Git Status", mode = "n" },
    { "<leader>gd", ":Git diff<CR>", desc = "Git Diff", mode = "n" },
    { "<leader>gp", ":Git push<CR>", desc = "Git Push", mode = "n" },

    { "<leader>ff", ":Telescope find_files<CR>", desc = "Find Files", mode = "n" },
    { "<leader>fr", ":Telescope oldfiles<CR>", desc = "Recent Files", mode = "n" },
    { "<leader>fp", ":Telescope git_files<CR>", desc = "Git Files", mode = "n" },
    { "<leader>sh", "<cmd>Telescope help_tags<CR>", desc = "Help Tags", mode = "n" },
    { "<leader>ss", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gIc<Left><Left><Left><Left>]], desc = "Substitute Word Globally", mode = "n", remap = true, hidden = false},
    { "<leader>sw", "<cmd>normal! *<CR>", desc = "Search Word Forward", mode = "n" },
    { "<leader>sb", "<cmd>normal! #<CR>", desc = "Search Word Backward", mode = "n" },
    { "<leader>fs", function ()
        -- require("telescope.builtin").grep_string() -- only grep on the current file
        require("telescope.builtin").live_grep()
    end,
        desc = "Search String", mode = "n"
    },
    { "<leader>be", ":enew<CR>", desc = "New Empty Buffer Tab", mode = "n" },
    { "<leader>bs", ":Telescope buffers<CR>", desc = "List Buffers", mode = "n" },
    { "<leader>bc", ":bd!<CR>", desc = "Delete Buffer", mode = "n" },
    -- { "<leader>bn", "<C-^>", desc = "Cycle Buffer", mode = "n" },
    { "<leader>bn", ":bNext<CR>", desc = "Next Buffer", mode = "n" },
    { "<leader>bp", ":bprev<CR>", desc = "Previous Buffer", mode = "n" },

    { "<leader>lr", ":Telescope lsp_references<CR>", desc = "LSP References", mode = "n" },
    { "<leader>la", ":lua vim.lsp.buf.code_action()<CR>", desc = "Code Action", mode = "n" },
    { "<leader>ld", ":Telescope diagnostics<CR>", desc = "Diagnostics", mode = "n" },
    { "<leader>lfb", ":lua vim.lsp.buf.format()<CR>", desc = "Format Code", mode = "n" },
    { "<leader>lqf", ":lua vim.diagnostic.setqflist()<CR>", desc = "Quickfix List", mode = "n" },

    { "<leader>cC", function() nvim_cc.input_compile_command() end, desc = "Input Compile Command", mode = "n" },
    { "<leader>cc", function()
        if Nvim_cc_term_buffn == nil or vim.fn.bufexists(Nvim_cc_term_buffn) ~= 1 then
            nvim_cc.run_compile_command()
        else
            vim.api.nvim_buf_delete(Nvim_cc_term_buffn, { force = true })
            nvim_cc.run_compile_command()
        end
    end,
        desc = "Run Compile Command",
        mode = "n",
    },
    { "<leader>co", function() Nvim_cc_compile_command = ""  end, desc = "Clear compile command", mode = "n" },
    { "<leader>cf", function() nvim_cc.set_compile_command_from_file() end, desc = "Set Compile Command From File", mode = "n" },
    { "<leader>cs", function()
        nvim_cc.sync_directory_to_buffer()
        nvim_cc.set_compile_command_from_file()
        print("cwd & cc set.")
    end,
        desc = "Sync Directory & Set Compile Command",
        mode = "n",
    },
    { "<leader>cw", function() nvim_cc.export_compile_command() end, desc = "Export Compile Command", mode = "n" },
    { "<leader>cj", function() nvim_cc.jump_to_error_position() end, desc = "Jump to Error Position", mode = "n" },

    {"<C-s>a", function() bj.add_jumpbuff() end, desc = "Add current buf to jlist", mode="n"},
    {"<C-s>c", function() JumpBuffTable = {} end, desc = "Clear jlist", mode="n"},
    {"<C-s>p", function() bj.prev_jumpbuff() end, desc = "Go to prev buf", mode="n"},
    {"<C-s>n", function() bj.next_jumpbuff() end, desc = "Go to next buf", mode="n"},
    {"<C-s>r", function() bj.rem_jumpbuff() end, desc = "Remove current buf from jlist", mode="n"},
    {"<C-s>1", function() bj.jumpto_jumpbuff(1) end, desc = "Jump to buf n1", mode="n"},
    {"<C-s>2", function() bj.jumpto_jumpbuff(2) end, desc = "Jump to buf n2", mode="n"},
    {"<C-s>3", function() bj.jumpto_jumpbuff(3) end, desc = "Jump to buf n3", mode="n"},
    {"<C-s>m1", function() bj.move_jumpbuff_to(1) end, desc = "Move CBuf to n1", mode="n"},
    {"<C-s>m2", function() bj.move_jumpbuff_to(2) end, desc = "Move CBuf to n2", mode="n"},
    {"<C-s>m3", function() bj.move_jumpbuff_to(3) end, desc = "Move CBuf to n3", mode="n"},
    { "mf", ":normal mf<CR>", desc = "Mark File (netrw)", mode = "v" },
})
