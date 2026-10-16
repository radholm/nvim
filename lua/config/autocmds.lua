local autocmd = vim.api.nvim_create_autocmd

local function local_opts(opts)
	return function()
		for k, v in pairs(opts) do
			vim.opt_local[k] = v
		end
	end
end

autocmd("TextYankPost", {
	callback = function()
		vim.hl.on_yank({ higroup = "IncSearch", timeout = 300 })
	end,
})

-- Terminal (Warp) title = current file name
autocmd("BufEnter", {
	pattern = "*.*",
	callback = function()
		local title = vim.fn.expand("%:t")
		io.stderr:write(("\027]0;%s\007"):format(title == "" and "[No Name]" or title))
	end,
})

-- Persist folds
autocmd("BufWinLeave", { pattern = "*.*", command = "mkview" })
autocmd("BufWinEnter", { pattern = "*.*", command = "silent! loadview" })

-- Prose
autocmd("BufEnter", {
	pattern = { "*.md", "*.typ" },
	callback = local_opts({ number = false, relativenumber = false, conceallevel = 0, spell = true }),
})
autocmd({ "BufWritePre", "FileChangedRO", "FileChangedShell" }, {
	pattern = "*.typ",
	command = "silent! w!",
})

autocmd("BufEnter", {
	pattern = "copilot-*",
	callback = local_opts({
		number = false,
		relativenumber = false,
		foldmethod = "manual",
		signcolumn = "yes",
		completeopt = "menu,menuone,noselect,noinsert",
	}),
})

autocmd("CmdwinEnter", {
	callback = local_opts({ number = false, relativenumber = false, signcolumn = "no", numberwidth = 1 }),
})

-- Format with efm on save
local format_on_save = {
	c = true, cpp = true, css = true, groovy = true, html = true, java = true,
	javascript = true, javascriptreact = true, json = true, lua = true, markdown = true,
	rust = true, scss = true, typescript = true, typescriptreact = true, typst = true,
	xml = true, yaml = true,
}
autocmd("BufWritePre", {
	callback = function()
		if format_on_save[vim.bo.filetype] then
			vim.lsp.buf.format({ name = "efm" })
		end
	end,
})

-- Autosave
autocmd({ "FocusLost", "BufLeave", "CompleteDone", "InsertLeave", "TextChanged" }, {
	command = "silent! wall!",
})

-- Zen mode
autocmd("User", {
	pattern = "GoyoEnter",
	callback = function()
		require("config.theme").omit()
		vim.cmd("Limelight")
	end,
})
autocmd("User", {
	pattern = "GoyoLeave",
	callback = function()
		require("config.theme").apply()
		vim.cmd("Limelight!")
	end,
})

-- Pause Copilot ghost text while blink menu is open
autocmd("User", { pattern = "BlinkCmpMenuOpen", command = "Copilot disable" })
autocmd("User", { pattern = "BlinkCmpMenuClose", command = "Copilot enable" })
