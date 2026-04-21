local plugins = require 'lib.plugins'

vim.opt.rtp:prepend(plugins.custom_path 'grapelean.nvim')
vim.cmd.colorscheme 'grapelean'
