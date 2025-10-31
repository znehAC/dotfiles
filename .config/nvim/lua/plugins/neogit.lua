-- lua/plugins/neogit.lua
return {
    "NeogitOrg/neogit",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "sindrets/diffview.nvim",
        "nvim-telescope/telescope.nvim",
    },
    config = function()
        require("neogit").setup({
            disable_signs = true,
            -- All other settings are fine by default
        })

        vim.keymap.set("n", "<leader>gg", function()
            require("neogit").open()
        end, { desc = "Neogit" })
    end,
}
