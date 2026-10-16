local M = {}
local hl = function(name, val)
	vim.api.nvim_set_hl(0, name, val)
end

function M.apply()
	local float_bg = vim.api.nvim_get_hl(0, { name = "TelescopeBorder" }).bg
	hl("Folded", { bg = "#43454a" })
	hl("TreesitterContextBottom", { underline = false })
	hl("TreesitterContextLineNumberBottom", { underline = false })
	hl("StatusLine", { bg = "NONE" })
	hl("StatusLineNC", { bg = "NONE" })
	hl("CursorLineNr", { bg = "NONE" })
	hl("TelescopeSelection", { fg = "grey", bg = "NONE" })
	hl("TelescopePromptBorder", { bg = float_bg })
	hl("TelescopePromptNormal", { bg = float_bg })
	hl("TelescopePromptPrefix", { bg = float_bg })
	hl("NormalFloat", { bg = float_bg })
end

-- Hide lualine diagnostic colors in zen mode
function M.omit()
	for _, level in ipairs({ "error", "warn", "info", "hint" }) do
		hl("lualine_c_diagnostics_" .. level .. "_normal", { fg = "NONE", bg = "NONE" })
	end
end

vim.cmd.colorscheme("base16-sandcastle")
M.apply()

return M
