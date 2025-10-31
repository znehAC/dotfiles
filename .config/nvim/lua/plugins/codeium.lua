-- lua/plugins/codeium.lua
return {
    "Exafunction/windsurf.vim",
    event = "BufEnter",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "hrsh7th/nvim-cmp",
    },
    config = function()
        -- this is the correct way to configure windsurf.vim
        -- it tells the vimscript plugin not to map its default keys
        -- so that nvim-cmp can take control.
        vim.g.codeium_disable_bindings = 1
    end,
}
