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
	get_lsp_server_name = function()
		local buf_clients = vim.lsp.get_active_clients({ bufnr = 0 })
		if next(buf_clients) == nil then
			return "No LSP"
		end
		local aliases = {
			["clangd"] = "c c++",
			["efm"] = "efm",
			["groovyls"] = "groovy",
			["lua_ls"] = "lua",
			["rust_analyzer"] = "rust",
			["ts_ls"] = "js ts",
			["GitHub Copilot"] = "copilot",
		}
		local names = {}
		for _, client in pairs(buf_clients) do
			table.insert(names, aliases[client.name] or client.name)
		end
		return "[ " .. table.concat(names, " ") .. " ]"
	end,
	gpt = "gpt-4.1",
}
