vim.keymap.set("n", "<leader>w", function()
    require("conform").format({
        async = false,
        lsp_format = "fallback"
    })
    vim.cmd("write")
end)
