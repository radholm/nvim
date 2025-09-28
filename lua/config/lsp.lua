local capabilities = require("blink.cmp").get_lsp_capabilities()

vim.lsp.enable({
	"clangd",
	"efm",
	"groovyls",
	"lua_ls",
	"rust_analyzer",
	"ts_ls",
})

G.lsp("*", {
	capabilities = capabilities,
})

G.lsp("lua_ls", {
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim", "bufnr", "G", "gitsigns" },
			},
			workspace = {
				library = {
					vim.env.VIMRUNTIME,
					vim.fn.expand("$VIMRUNTIME/lua"),
					vim.fn.expand("$XDG_CONFIG_HOME/nvim/lua"),
				},
			},
		},
	},
})

G.lsp("ts_ls", {
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

G.lsp("groovyls", {
	cmd = { "groovy-language-server" },
	on_attach = function(client, bufnr)
		local function get_gradle_classpath()
			local jar_paths = {}
			local handle = io.popen([[find ~/.m2/repository -type f -name "*.jar"]])
			if handle then
				for jar in handle:lines() do
					table.insert(jar_paths, jar)
				end
				handle:close()
			end
			return jar_paths
		end

		local classpath = get_gradle_classpath()
		client.config.settings = client.config.settings or {}
		client.config.settings.groovy = client.config.settings.groovy or {}
		client.config.settings.groovy.classpath = classpath
		client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
		vim.notify("Groovy classpath generated", vim.log.levels.INFO, { title = "Groovy LS" })
	end,
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
	groovy = { gjf },
	javascript = { eslint, prettier_d },
	javascriptreact = { eslint, prettier_d },
	json = { prettier_d },
	jsonc = { prettier_d },
	lua = { stylelint, stylua },
	markdown = { prettier },
	-- python = {
	--   require("efmls-configs.linters.ruff"),
	--   require("efmls-configs.formatters.ruff"),
	--   require("efmls-configs.formatters.ruff_sort"),
	-- },
	rust = { rustfmt },
	sh = { shfmt },
	typescript = { eslint, prettier_d },
	typescriptreact = { eslint, prettier_d },
	typst = { typstyle },
	yaml = { prettier },
	zsh = { shfmt },
}

G.lsp("efm", {
	filetypes = vim.tbl_keys(languages),
	single_file_support = true,
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
		-- prefix = " ",
		-- suffix = " ",
		border = "none",
		source = false,
	},
})
