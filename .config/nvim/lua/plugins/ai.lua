-- lua/plugins/ai.lua
return {
    'Exafunction/windsurf.nvim',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'hrsh7th/nvim-cmp', -- Make sure cmp loads first
    },
    config = function()
        require('codeium').setup({
            enable_cmp_source = true,
            --
        })
    end,
}
