-- OPTIONS
local set = vim.opt

--line nums
set.relativenumber = true
set.number = true

-- indentation and tabs
set.tabstop = 4
set.shiftwidth = 4
set.autoindent = true
set.expandtab = true

vim.api.nvim_create_autocmd("FileType", {
    pattern = {
        "javascript", "typescript", "typescriptreact", "javascriptreact",
        "json", "jsonc", "yaml", "html", "css", "scss", "lua"
    },
    callback = function()
        vim.opt_local.tabstop = 2
        vim.opt_local.softtabstop = 2
        vim.opt_local.shiftwidth = 2
    end
})

-- search settings
set.ignorecase = true
set.smartcase = true

-- appearance
set.termguicolors = true
set.signcolumn = "yes"

-- cursor line
set.cursorline = true

set.wrap = false

set.colorcolumn = "100"

-- clipboard
set.clipboard:append("unnamedplus")

-- backspace
set.backspace = "indent,eol,start"

-- split windows
set.splitbelow = true
set.splitright = true

-- dw/diw/ciw works on full-word
set.iskeyword:append("-")

-- keep cursor at least 8 rows from top/bot
set.scrolloff = 8

-- undo dir settings
set.swapfile = false
set.backup = false
set.undodir = os.getenv("HOME") .. "/.vim/undodir"
set.undofile = true

-- incremental search
set.incsearch = true

-- faster cursor hold
set.updatetime = 50
