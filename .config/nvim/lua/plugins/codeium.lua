return {
    "Exafunction/windsurf.vim", -- you’re using the Windsurf shim that exposes codeium#*
    event = "BufEnter",
    config = function()
        -- nuke default tab mappings from codeium.vim
        vim.g.codeium_disable_bindings = 1 -- stops all default imaps, including <Tab>
        -- older variants also honor this:
        vim.g.codeium_no_map_tab = 1

        -- your custom bindings
        vim.keymap.set("i", "<C-l>", function() return vim.fn["codeium#Accept"]() end, { expr = true, silent = true })
        vim.keymap.set("i", "<C-,>", function() return vim.fn["codeium#CycleCompletions"](-1) end,
            { expr = true, silent = true })
        vim.keymap.set("i", "<C-x>", function() return vim.fn["codeium#Clear"]() end, { expr = true, silent = true })

        -- optional: show/hide
        vim.keymap.set("n", "<leader>ae", ":CodeiumEnable<CR>", { silent = true })
        vim.keymap.set("n", "<leader>ad", ":CodeiumDisable<CR>", { silent = true })
    end,
}
