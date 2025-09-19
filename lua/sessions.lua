require("globals")

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
		G.set_warp_title()
	end,
})

G.autocmd("VimLeave", {
	callback = function()
		vim.cmd("silent! mksession! " .. session_file)
		vim.cmd("silent! wshada! " .. shada_file)
	end,
})
