return {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" }, -- for JSX/TSX etc
    config = function()
        require("Comment").setup({
            pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
        })

        -- Insert-mode toggle current line
        vim.keymap.set("i", "<C-/>", function()
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
            require("Comment.api").toggle.linewise.current()
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("a", true, false, true), "n", false)
        end, { silent = true })

        -- Quick normal/visual toggles (besides gcc / gc in visual)
        vim.keymap.set({ "n", "v" }, "<C-_>", "gcc", { remap = true, silent = true }) -- some terminals send C-_ instead of C-/
    end,
}
