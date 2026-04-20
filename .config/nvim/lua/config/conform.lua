vim.keymap.set("n", "<leader>w", function()
    require("conform").format({
        async = false,
        lsp_fallback = true
    })
    vim.cmd("write")
end)
