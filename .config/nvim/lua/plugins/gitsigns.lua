-- lua/plugins/gitsigns.lua
return {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        require("gitsigns").setup({
            signs = {
                add = { text = "│" },
                change = { text = "│" },
                delete = { text = "󰍵" },
                topdelete = { text = "󰍵" },
                changedelete = { text = "│" },
            },
            current_line_blame = true,
            current_line_blame_opts = {
                virt_text = true,
                virt_text_pos = "eol",
                delay = 250,
            },
            on_attach = function(bufnr)
                local gs = package.loaded.gitsigns

                local function map(mode, l, r, opts)
                    opts = opts or {}
                    opts.buffer = bufnr
                    vim.keymap.set(mode, l, r, opts)
                end

                -- Navigation
                map("n", "]c", function()
                    if vim.wo.diff then
                        return "]c"
                    end
                    vim.schedule(function()
                        gs.next_hunk()
                    end)
                    return "<Ignore>"
                end, { expr = true, desc = "Next Git Hunk" })

                map("n", "[c", function()
                    if vim.wo.diff then
                        return "[c"
                    end
                    vim.schedule(function()
                        gs.prev_hunk()
                    end)
                    return "<Ignore>"
                end, { expr = true, desc = "Previous Git Hunk" })

                -- Actions
                map("n", "<leader>hs", gs.stage_hunk, { desc = "Git Stage Hunk" })
                map("n", "<leader>hr", gs.reset_hunk, { desc = "Git Reset Hunk" })
                map("v", "<leader>hs", function()
                    gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
                end, { desc = "Git Stage Selected Lines" })
                map("v", "<leader>hr", function()
                    gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
                end, { desc = "Git Reset Selected Lines" })

                map("n", "<leader>hp", gs.preview_hunk, { desc = "Git Preview Hunk" })
                map("n", "<leader>hb", gs.blame_line, { desc = "Git Blame Line" })
            end,
        })
    end,
}
