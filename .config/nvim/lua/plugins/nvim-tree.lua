return {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        require("nvim-tree").setup({
            sort_by = "name",
            view = {
                width = 30,
            },
            renderer = {
                group_empty = true,
                highlight_git = true,
                highlight_opened_files = "all",
                highlight_modified = "all",
            },
            filters = {
                dotfiles = true,
                custom = { ".git", "node_modules", ".cache" },
            },
        })

        vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", {
            desc = "Toggle file explorer",
        })
    end,
}
