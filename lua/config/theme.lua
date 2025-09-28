-- vim.cmd('colorscheme base16-black-metal-gorgoroth')
-- vim.cmd("colorscheme base16-gruvbox-light-soft")
-- vim.cmd("colorscheme base16-mexico-light")
-- vim.cmd("colorscheme jb")
vim.cmd("colorscheme base16-sandcastle")

local function apply_hls()
	local bg = "#43454a"
	local border_bg = vim.api.nvim_get_hl(0, { name = "TelescopeBorder" }).bg
	vim.api.nvim_set_hl(0, "Folded", { bg = bg })
	vim.api.nvim_set_hl(0, "TreesitterContextBottom", { underline = false })
	vim.api.nvim_set_hl(0, "TreesitterContextLineNumberBottom", { underline = false })
	require("lualine").setup({
		options = {
			theme = {
				normal = { a = { bg = "NONE" }, b = { bg = "NONE" }, c = { bg = "NONE" } },
				insert = { a = { bg = "NONE" }, b = { bg = "NONE" }, c = { bg = "NONE" } },
				visual = { a = { bg = "NONE" }, b = { bg = "NONE" }, c = { bg = "NONE" } },
			},
		},
	})
	vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "CursorLineNr", { bg = "NONE" })
	-- vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "TelescopeSelection", { fg = "grey", bg = "NONE" })
	vim.api.nvim_set_hl(0, "TelescopePromptBorder", { bg = border_bg })
	vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = border_bg })
	vim.api.nvim_set_hl(0, "TelescopePromptPrefix", { bg = border_bg })
	vim.api.nvim_set_hl(0, "CursorLineNr", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "CursorLineNr", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = border_bg })
end

local function omit_hls()
	vim.api.nvim_set_hl(0, "lualine_c_diagnostics_warn_normal", { fg = "NONE", bg = "NONE" })
	vim.api.nvim_set_hl(0, "lualine_c_diagnostics_info_normal", { fg = "NONE", bg = "NONE" })
	vim.api.nvim_set_hl(0, "lualine_c_diagnostics_hint_normal", { fg = "NONE", bg = "NONE" })
	vim.api.nvim_set_hl(0, "lualine_c_diagnostics_error_normal", { fg = "NONE", bg = "NONE" })
end

return { apply_hls = apply_hls, omit_hls = omit_hls }
