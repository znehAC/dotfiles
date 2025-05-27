require('config.options')
require('config.remap')
if not vim.g.vscode then
    require('config.lazy')
end
