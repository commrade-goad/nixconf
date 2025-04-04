vim.g.copilot_no_tab_map = true
vim.g.copilot_enabled = 0
vim.api.nvim_set_keymap("i", "<C-J>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
vim.keymap.set("n", "<leader>tgc",
    function()
        if vim.g.copilot_enabled  == 1 then
            vim.g.copilot_enabled = 0
            print("Copilot disabled")
        else
            vim.g.copilot_enabled = 1
            print("Copilot enabled")
        end
    end,
    { silent = true, expr = true, desc = "Toggle copilot on or off" }
)
