vim.lsp.enable({
	"clangd",
	"efm",
	"lua_ls",
	"rust_analyzer",
	"ts_ls",
})

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				library = { vim.env.VIMRUNTIME, vim.fn.stdpath("config") .. "/lua" },
			},
		},
	},
})

vim.lsp.config("ts_ls", {
	handlers = {
		["textDocument/publishDiagnostics"] = function(_, result, ctx)
			if result.diagnostics == nil then
				return
			end
			-- filter out TS7016 "Could not find a declaration file" errors
			result.diagnostics = vim.tbl_filter(function(diagnostic)
				return diagnostic.code ~= 7016
			end, result.diagnostics)

			vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx)
		end,
	},
})

-- https://github.com/creativenull/efmls-configs-nvim/tree/main/lua/efmls-configs
local clang_format = require("efmls-configs.formatters.clang_format")
local eslint = require("efmls-configs.linters.eslint_d")
local prettier = require("efmls-configs.formatters.prettier")
local prettier_d = require("efmls-configs.formatters.prettier_d")
local shfmt = require("efmls-configs.formatters.shfmt")
local stylelint = require("efmls-configs.linters.stylelint")
local stylua = require("efmls-configs.formatters.stylua")
local typstyle = require("efmls-configs.formatters.typstyle")
local gjf = require("efmls-configs.formatters.google_java_format")
local rustfmt = require("efmls-configs.formatters.rustfmt")
local languages = {
	bash = { shfmt },
	c = { clang_format },
	cpp = { clang_format },
	css = { stylelint, prettier },
	html = { prettier },
	java = { gjf },
	javascript = { eslint, prettier_d },
	javascriptreact = { eslint, prettier_d },
	json = { prettier_d },
	jsonc = { prettier_d },
	lua = { stylua },
	markdown = { prettier },
	rust = { rustfmt },
	sh = { shfmt },
	typescript = { eslint, prettier_d },
	typescriptreact = { eslint, prettier_d },
	typst = { typstyle },
	yaml = { prettier },
	zsh = { shfmt },
}

vim.lsp.config("efm", {
	filetypes = vim.tbl_keys(languages),
	init_options = {
		documentFormatting = true,
		documentRangeFormatting = true,
		hover = true,
		documentSymbol = true,
		codeAction = true,
		completion = true,
	},
	settings = {
		rootMarkers = { ".git/" },
		languages = languages,
	},
})

vim.diagnostic.config({
	virtual_text = false,
	severity_sort = true,
	underline = true,
	signs = false,
	float = {
		style = "minimal",
		max_width = 120,
		header = "",
		border = "none",
		source = false,
	},
})
