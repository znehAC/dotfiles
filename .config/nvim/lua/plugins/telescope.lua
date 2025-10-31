-- lua/plugins/telescope.lua
return {
    'nvim-telescope/telescope.nvim',
    dependencies = {
        'nvim-lua/plenary.nvim',
    },
    config = function()
        local actions = require('telescope.actions')
        local builtin = require('telescope.builtin')

        require('telescope').setup({
            defaults = {
                mappings = {
                    i = {
                        ["<C-k>"] = actions.move_selection_previous,                       -- move to prev result
                        ["<C-j>"] = actions.move_selection_next,                           -- move to next result
                        ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist, -- send selected to quickfixlist
                    }
                }
            }
        })

        -- All Telescope keymaps are now in one place
        vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope: Find File' })
        vim.keymap.set('n', '<leader>fg', builtin.git_files, { desc = 'Telescope: Git Files' })
        vim.keymap.set('n', '<leader>fp', builtin.live_grep, { desc = "Telescope: Live Grep" })
        vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope: Buffers' })
        vim.keymap.set('n', '<leader>fo', builtin.oldfiles, { desc = 'Telescope: Old Files' })
        vim.keymap.set('n', '<leader>fs', builtin.lsp_document_symbols, { desc = "Telescope: Doc Symbols" })
        vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope: Help Tags' })
        vim.keymap.set('n', '<leader>fq', builtin.quickfix, { desc = 'Telescope: Quickfix' })

        -- Git maps
        vim.keymap.set('n', '<leader>gc', builtin.git_commits, { desc = 'Telescope: Git Commits' })
        vim.keymap.set('n', '<leader>gb', builtin.git_branches, { desc = 'Telescope: Git Branches' })
        vim.keymap.set('n', '<leader>gt', builtin.git_status, { desc = 'Telescope: Git Status' })

        -- Find instance instance of current view being included
        vim.keymap.set('n', '<leader>fc', function()
            local filename_without_extension = vim.fn.expand('%:t:r')
            builtin.grep_string({ search = filename_without_extension })
        end, { desc = "Telescope: Find current file" })
    end
}
