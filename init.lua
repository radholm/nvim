require("globals")
require("sessions")
require("config.lazy")
require("config.theme")
require("config.lsp")
require("config.mappings")

local set = vim.opt

set.guicursor = ""
vim.cmd("command! W silent write")
vim.cmd("command! Wq silent write | bd")
vim.cmd("command! WQ silent write | bd")
vim.cmd("command! Q bd")
vim.cmd("command! -bang -nargs=? W execute 'silent w' <q-args>")

-- set.background = "dark"
set.cmdwinheight = 10
set.wildmode = { "list", "longest" }
set.spelllang = { "en", "sv" }

set.exrc = true
set.nu = true

set.errorbells = false
set.laststatus = 0
set.cmdheight = 0
set.autoread = true
set.winborder = "none"
set.conceallevel = 0
set.shortmess:append("I")
-- set.messagesopt = "hit-enter,wait:10000,history:500"
-- set.messagesopt = "wait:0,history:500"
set.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
set.shada = ""
set.signcolumn = "yes"
set.nuw = 4

set.mouse = "nv"

set.expandtab = true
set.smarttab = true
set.shiftwidth = 2
set.smartindent = true
set.autoindent = true
set.tabstop = 2
set.softtabstop = 2

set.swapfile = false
set.backup = false
set.writeany = true
set.updatecount = 0
set.undodir = os.getenv("HOME") .. "/.config/nvim/undodir"
set.undofile = true
set.writebackup = false
set.autowrite = false
vim.cmd("cabbrev w w!")

set.incsearch = true
set.ignorecase = true
set.inccommand = "nosplit"
set.smartcase = true

set.splitbelow = false
set.splitright = true
set.wrap = false
set.fileencoding = "utf-8"
set.termguicolors = true

set.relativenumber = true
set.cursorline = false
set.scrolloff = 16
set.sidescrolloff = 16

set.hidden = true
set.clipboard = "unnamedplus"

set.foldmethod = "expr"
set.foldexpr = "v:lua.vim.treesitter.foldexpr()"
set.foldcolumn = "0"
set.foldlevel = 99
set.foldlevelstart = 2
set.foldnestmax = 4
set.foldtext = ""
set.fillchars = {
	fold = " ",
	foldopen = "",
	foldclose = "",
	diff = "╱",
	eob = " ",
	vert = " ",
}

G.autocmd("TextYankPost", {
	group = G.augroup("HighlightYank", {}),
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({
			higroup = "IncSearch",
			timeout = 300,
		})
	end,
})

G.autocmd({ "BufEnter" }, {
	pattern = { "*.*" },
	callback = G.set_warp_title,
})

G.autocmd({ "BufWritePre", "FileChangedRO", "FileChangedShell" }, {
	pattern = { "*.typ" },
	callback = function()
		vim.cmd("silent! w!")
	end,
})

G.autocmd("BufWinLeave", {
	pattern = { "*.*" },
	desc = "save view (folds), when closing file",
	command = "mkview",
})

G.autocmd("BufWinEnter", {
	pattern = { "*.*" },
	desc = "load view (folds), when opening file",
	command = "silent! loadview",
})

G.autocmd("BufEnter", {
	pattern = "*.md",
	callback = function()
		vim.opt_local.relativenumber = false
		vim.opt_local.number = false
		vim.opt_local.conceallevel = 0
		vim.opt_local.spell = true
	end,
})

G.autocmd("BufEnter", {
	pattern = "*.typ",
	callback = function()
		vim.opt_local.relativenumber = false
		vim.opt_local.number = false
		vim.opt_local.conceallevel = 0
		vim.opt_local.spell = true
	end,
})

G.autocmd("BufEnter", {
	pattern = "copilot-*",
	callback = function()
		vim.opt_local.relativenumber = false
		vim.opt_local.number = false
		vim.opt_local.foldmethod = "manual"
		vim.opt_local.signcolumn = "yes"
		vim.opt_local.completeopt = "menu,menuone,noselect,noinsert"
	end,
})

G.autocmd("CmdwinEnter", {
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.opt_local.signcolumn = "no"
		vim.opt_local.nuw = 1
	end,
})

G.autocmd("BufWritePre", {
	pattern = "*",
	callback = function()
		local whitelist = {
			"c",
			"cpp",
			"css",
			"html",
			"java",
			"groovy",
			"javascript",
			"json",
			"lua",
			"markdown",
			"rust",
			"scss",
			"typescript",
			"typst",
			"xml",
			"yaml",
		}
		if vim.tbl_contains(whitelist, vim.bo.filetype) then
			vim.lsp.buf.format({ name = "efm" })
		end
	end,
})

G.usercmd("Rfinder", function()
	local path = vim.api.nvim_buf_get_name(0)
	os.execute("open -R " .. path)
end, {})

G.autocmd("User", {
	pattern = "GoyoEnter",
	callback = function()
		require("config.theme").omit_hls()
		vim.cmd("Limelight")
	end,
})

G.autocmd("User", {
	pattern = "GoyoLeave",
	callback = function()
		require("config.theme").apply_hls()
		vim.cmd("Limelight!")
	end,
})

G.autocmd("User", {
	pattern = "BlinkCmpMenuOpen",
	callback = function()
		vim.cmd("Copilot disable")
	end,
})

G.autocmd("User", {
	pattern = "BlinkCmpMenuClose",
	callback = function()
		vim.cmd("Copilot enable")
	end,
})

G.autocmd({ "FocusLost", "BufLeave", "CompleteDone", "InsertLeave", "TextChanged" }, {
	callback = function()
		vim.cmd("silent! wall!")
	end,
})
