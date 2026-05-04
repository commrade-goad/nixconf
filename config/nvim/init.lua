vim.pack.add({
    { src = "https://github.com/tpope/vim-fugitive"             }, -- maybe will be replaced with neogit (really similar to magit the goats)
    { src = "https://github.com/dhruvasagar/vim-table-mode"     },
    { src = "https://github.com/stevearc/oil.nvim"              },
    { src = "https://github.com/nvim-telescope/telescope.nvim"  },
    { src = "https://github.com/nvim-lua/plenary.nvim"          },
    { src = "https://github.com/neovim/nvim-lspconfig"          },
})

require("second")
