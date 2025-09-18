require("globals")
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

local yank_group = G.augroup("HighlightYank", {})

G.autocmd("TextYankPost", {
	group = yank_group,
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({
			higroup = "IncSearch",
			timeout = 300,
		})
	end,
})

local function set_warp_title()
	local title = vim.fn.expand("%:t")
	if title == "" then
		title = "[No Name]"
	end
	io.stderr:write(string.format("\027]0;%s\007", title))
	io.stderr:flush()
end

G.autocmd({ "BufEnter" }, {
	pattern = { "*.*" },
	callback = set_warp_title,
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

G.autocmd("BufRead", {
	callback = function()
		require("gitsigns").refresh()
	end,
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

G.autocmd("BufWritePost", {
	callback = function(args)
		local filename = vim.fn.fnamemodify(args.file, ":t")
		vim.notify("File written: " .. filename, vim.log.levels.INFO, {
			timeout = 1000,
		})
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

-- Session management

local function get_session_name()
	local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
	local root = (git_root and git_root ~= "" and not git_root:match("fatal")) and git_root or vim.loop.cwd()
	local folder_name = root:match("^.+/(.+)$") or root
	local name = folder_name:gsub("[^%w_-]", "_"):lower()
	return name
end

local session_name = get_session_name()
local shared = vim.fn.stdpath("data")

local session_file = string.format("%s/%s.vim", shared .. "/sessions", session_name)
local shada_file = string.format("%s/%s.shada", shared .. "/shada", session_name)

vim.fn.mkdir(shared .. "/sessions", "p")
vim.fn.mkdir(shared .. "/shada", "p")

G.autocmd("VimEnter", {
	callback = function()
		if vim.fn.filereadable(session_file) == 1 then
			vim.cmd.source(session_file)
			vim.notify("Session loaded: " .. session_name, vim.log.levels.INFO, { timeout = 1000 })
		end
		if vim.fn.filereadable(shada_file) == 1 then
			vim.cmd.rshada(shada_file)
			vim.notify("Shada loaded: " .. session_name, vim.log.levels.INFO, { timeout = 1000 })
		end

		require("config.theme").apply_hls()
		set_warp_title()
	end,
})

G.autocmd("VimLeave", {
	callback = function()
		vim.cmd("silent! mksession! " .. session_file)
		vim.cmd("silent! wshada! " .. shada_file)
	end,
})
