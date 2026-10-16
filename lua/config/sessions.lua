-- Per-project session + shada, only when nvim is started without file args
if vim.fn.argc() > 0 then
	return
end

local root = vim.fs.root(0, ".git") or vim.uv.cwd()
local name = vim.fs.basename(root):gsub("[^%w_-]", "_"):lower()
local data = vim.fn.stdpath("data")
local session = ("%s/sessions/%s.vim"):format(data, name)
local shada = ("%s/shada/%s.shada"):format(data, name)
vim.fn.mkdir(data .. "/sessions", "p")
vim.fn.mkdir(data .. "/shada", "p")

vim.api.nvim_create_autocmd("VimEnter", {
	nested = true,
	callback = function()
		if vim.uv.fs_stat(session) then
			vim.cmd.source(session)
			vim.notify("Session loaded: " .. name)
		end
		if vim.uv.fs_stat(shada) then
			vim.cmd.rshada(shada)
		end
	end,
})

vim.api.nvim_create_autocmd("VimLeave", {
	callback = function()
		vim.cmd("silent! mksession! " .. vim.fn.fnameescape(session))
		vim.cmd("silent! wshada! " .. vim.fn.fnameescape(shada))
	end,
})
