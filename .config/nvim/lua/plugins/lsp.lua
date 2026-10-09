return {
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            { "folke/lazydev.nvim", ft = "lua", opts = {} },
        },
        config = function()
            -- Language servers are installed by Home Manager (rust-analyzer by rustup)
            vim.lsp.config("*", {
                capabilities = require("cmp_nvim_lsp").default_capabilities(),
            })
            vim.lsp.enable({
                "lua_ls",
                "rust_analyzer",
                "ts_ls",
                "pyright",
                "gopls",
            })

            vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
            vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Show hover" })
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename variable" })
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
        end
    }
}
