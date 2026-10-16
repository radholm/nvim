vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Native message/cmdline UI (experimental in 0.12); replaces nvim-notify
require("vim._core.ui2").enable({})

local o = vim.opt

o.guicursor = ""
o.cmdwinheight = 10
o.wildmode = { "list", "longest" }
o.spelllang = { "en", "sv" }
o.exrc = true
o.errorbells = false
o.laststatus = 0
o.cmdheight = 0
o.autoread = true
o.winborder = "none"
o.conceallevel = 0
o.shortmess:append("I")
o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
o.shada = ""
o.mouse = "nv"
o.clipboard = "unnamedplus"
o.termguicolors = true
o.fileencoding = "utf-8"

-- Gutter
o.number = true
o.relativenumber = true
o.numberwidth = 4
o.signcolumn = "yes"
o.cursorline = false

-- Indent
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.softtabstop = 2
o.smartindent = true

-- Files
o.swapfile = false
o.backup = false
o.writebackup = false
o.writeany = true
o.updatecount = 0
o.undofile = true
o.undodir = vim.fn.stdpath("config") .. "/undodir"

-- Search
o.ignorecase = true
o.smartcase = true
o.inccommand = "nosplit"

-- Windows / scrolling
o.splitbelow = false
o.splitright = true
o.wrap = false
o.scrolloff = 16
o.sidescrolloff = 16

-- Folds
o.foldmethod = "expr"
o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
o.foldcolumn = "0"
o.foldlevel = 99
o.foldlevelstart = 2
o.foldnestmax = 4
o.foldtext = ""
o.fillchars = { fold = " ", foldopen = "", foldclose = "", diff = "╱", eob = " ", vert = " " }

-- Commands
vim.cmd([[
  command! -bang -nargs=? W execute 'silent w' <q-args>
  command! Wq silent write | bd
  command! WQ silent write | bd
  command! Q silent bd!
  cabbrev w w!
]])
