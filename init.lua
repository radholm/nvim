if vim.g.vscode then
	-- VS Code Neovim: skip plugins/UI config, which break the embedded instance
	vim.opt.clipboard = "unnamedplus"
	vim.opt.ignorecase = true
	vim.opt.smartcase = true
	return
end

require("config.options")
require("plugins")
require("config.keymaps")
require("config.theme")
require("config.lsp")
require("config.autocmds")
require("config.sessions")
