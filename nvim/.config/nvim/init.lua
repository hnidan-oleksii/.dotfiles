-- Leader keys must be set before lazy.nvim loads plugins
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- The builtin python ftplugin's has('python3') probe spawns an interpreter on every .py buffer just to throw the answer away
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

require("config.options")
require("config.keymaps")
require("config.lazy")
require("config.csv")
require("config.ansi")
