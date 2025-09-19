_G.G = {
	lsp = vim.lsp.config,
	keymap = vim.keymap.set,
	autocmd = vim.api.nvim_create_autocmd,
	augroup = vim.api.nvim_create_augroup,
	usercmd = vim.api.nvim_create_user_command,
	set_warp_title = function()
		local title = vim.fn.expand("%:t")
		if title == "" then
			title = "[No Name]"
		end
		io.stderr:write(string.format("\027]0;%s\007", title))
		io.stderr:flush()
	end,
	gpt = "gpt-4.1",
}
