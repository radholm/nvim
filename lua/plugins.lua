-- Build hooks must exist before vim.pack.add() to run on install
vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		local name, kind = ev.data.spec.name, ev.data.kind
		if kind ~= "install" and kind ~= "update" then
			return
		end
		if name == "nvim-treesitter" then
			if not ev.data.active then
				vim.cmd.packadd("nvim-treesitter")
			end
			vim.cmd("TSUpdate")
		elseif name == "CopilotChat.nvim" then
			vim.system({ "make", "tiktoken" }, { cwd = ev.data.path })
		end
	end,
})

vim.g.compile_mode = {
	default_command = "npm run ",
	ansi_color = { kind = "render" },
	error_regexp_table = {
		typescript = {
			regex = "^\\(.*\\.js\\):\\([0-9]\\{1,4}\\):\\([0-9]\\{1,4}\\)",
			filename = 1,
			row = 2,
			col = 3,
		},
	},
}

-- `mod`: skip loading at startup; load on first require(mod) instead
local gh = function(repo, version, mod)
	return { src = "https://github.com/" .. repo, version = version, data = mod }
end

local lazy, setup = {}, {} -- lazy: module -> pack name; setup: module -> fn

vim.pack.add({
	-- Libraries
	gh("nvim-lua/plenary.nvim"),
	gh("nvim-mini/mini.nvim"),
	-- UI
	gh("RRethy/base16-nvim"),
	gh("nvim-lualine/lualine.nvim"),
	gh("folke/which-key.nvim"),
	gh("junegunn/goyo.vim"),
	gh("junegunn/limelight.vim"),
	gh("MeanderingProgrammer/render-markdown.nvim"),
	-- Editing
	gh("nvim-treesitter/nvim-treesitter", "master"),
	gh("nvim-treesitter/nvim-treesitter-context"),
	gh("windwp/nvim-ts-autotag"),
	gh("folke/flash.nvim", nil, "flash"),
	gh("jake-stewart/multicursor.nvim", nil, "multicursor-nvim"),
	gh("rafamadriz/friendly-snippets"),
	gh("saghen/blink.cmp", vim.version.range("1")),
	-- Navigation
	gh("nvim-telescope/telescope.nvim", nil, "telescope"),
	gh("stevearc/oil.nvim"),
	gh("r0nsha/qfpreview.nvim", nil, "qfpreview"),
	-- Git
	gh("tpope/vim-fugitive"),
	gh("lewis6991/gitsigns.nvim"),
	-- LSP / tools
	gh("neovim/nvim-lspconfig"),
	gh("creativenull/efmls-configs-nvim"),
	gh("mason-org/mason.nvim", nil, "mason"),
	gh("m00qek/baleia.nvim", "v1.3.0"),
	gh("ej-shafran/compile-mode.nvim", vim.version.range("5"), "compile-mode"),
	gh("chomosuke/typst-preview.nvim", nil, "typst-preview"),
	-- AI
	gh("github/copilot.vim", "v1.55.0"),
	gh("CopilotC-Nvim/CopilotChat.nvim", "v4.5.0", "CopilotChat"),
}, {
	confirm = false,
	load = function(p)
		if p.spec.data then
			lazy[p.spec.data] = p.spec.name
		else
			vim.cmd.packadd({ p.spec.name, bang = true })
		end
	end,
})

-- On first require of a lazy module: packadd its plugin, then run setup[mod]
table.insert(package.loaders, 2, function(mod)
	local root = mod:match("^[^.]+")
	local pack = lazy[root]
	if not pack then
		return
	end
	lazy[root] = nil
	vim.cmd.packadd(pack)
	local preloaded = package.loaded[mod] -- plugin/ files may already require it
	return function()
		local m = preloaded
		for _, searcher in ipairs(package.loaders) do
			if m then
				break
			end
			local loader = searcher(mod)
			if type(loader) == "function" then
				m = loader(mod)
			end
		end
		package.loaded[mod] = m
		if setup[root] then
			setup[root]()
		end
		return m
	end
end)

local function load_on(event, pattern, mod)
	vim.api.nvim_create_autocmd(event, {
		pattern = pattern,
		once = true,
		callback = function()
			require(mod)
		end,
	})
end
load_on("CmdUndefined", "Telescope", "telescope")
load_on("CmdUndefined", "CopilotChat*", "CopilotChat")
load_on("CmdUndefined", "Mason*", "mason")
load_on("CmdUndefined", { "Compile", "Recompile", "*Error", "QuickfixErrors", "NextErrorFollow" }, "compile-mode")
load_on("FileType", "typst", "typst-preview")
load_on("FileType", "qf", "qfpreview")

local keys = require("config.keymaps")

require("mini.icons").setup()

require("lualine").setup({
	options = {
		theme = {
			normal = { a = { bg = "NONE" }, b = { bg = "NONE" }, c = { bg = "NONE" } },
			insert = { a = { bg = "NONE" }, b = { bg = "NONE" }, c = { bg = "NONE" } },
			visual = { a = { bg = "NONE" }, b = { bg = "NONE" }, c = { bg = "NONE" } },
		},
		component_separators = "",
		section_separators = "",
		disabled_buftypes = { "quickfix", "prompt" },
	},
	sections = {
		lualine_a = { { "mode", fmt = function(s) return s:sub(1, 1) end } },
		lualine_b = {
			{ "branch", icon = "" },
			{
				"filename",
				path = 1,
				symbols = { modified = "[ + ]", readonly = "[ - ]", unnamed = "", newfile = "[ New ]" },
			},
		},
		lualine_c = {
			"lsp_status",
			{ "diagnostics", symbols = { error = "E", warn = "W", info = "I", hint = "H" } },
			"searchcount",
		},
		lualine_x = {},
		lualine_y = {},
		lualine_z = {},
	},
	inactive_sections = {},
})

require("render-markdown").setup({
	file_types = { "markdown", "copilot-chat" },
	heading = {
		sign = false,
		icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
		position = "overlay",
		width = "full",
	},
	code = { style = "normal" },
	paragraph = { indent = 0 },
	bullet = { icons = { "●", "○", "◆", "◇" } },
	indent = { enabled = true, per_level = 4, skip_level = 0, skip_heading = true, icon = "" },
	completions = { lsp = { enabled = true } },
	latex = { enabled = false },
})

require("nvim-treesitter.configs").setup({
	auto_install = true,
	highlight = { enable = true, additional_vim_regex_highlighting = { "markdown" } },
	indent = { enable = true },
})
require("treesitter-context").setup()
require("nvim-ts-autotag").setup({
	opts = { enable_close = true, enable_rename = true, enable_close_on_slash = true },
})

require("oil").setup({
	columns = { "size", "mtime" },
	lsp_file_methods = { autosave_changes = true },
	win_options = { number = false, relativenumber = false },
	float = {
		padding = 0,
		max_width = vim.o.columns,
		max_height = 0.2,
		border = "none",
		override = function(conf)
			conf.anchor = "SW"
			conf.row = vim.o.lines - 1
			conf.col = 0
			return conf
		end,
	},
	skip_confirm_for_simple_edits = true,
	prompt_save_on_select_new_entry = false,
	watch_for_changes = true,
	constrain_cursor = "name",
	keymaps = keys.oil,
	view_options = {
		show_hidden = true,
		natural_order = "fast",
		case_insensitive = true,
		sort = { { "type", "asc" }, { "name", "asc" } },
	},
	preview_win = { preview_method = "fast_scratch" },
	confirmation = { border = "none" },
	progress = { border = "none" },
	ssh = { border = "none" },
	keymaps_help = { border = "none" },
})

require("gitsigns").setup({
	signs = {
		add = { text = "┃" },
		change = { text = "┃" },
		delete = { text = "_" },
		topdelete = { text = "‾" },
		changedelete = { text = "~" },
		untracked = { text = "┆" },
	},
	current_line_blame = true,
	current_line_blame_opts = { delay = 0 },
})

-- What mason.setup() does at startup; full setup waits for :Mason*
vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH
function setup.mason()
	require("mason").setup()
end

-- Lazy plugin setups, run on first require (see package.loaders above)
setup["multicursor-nvim"] = function()
	local mc = require("multicursor-nvim")
	mc.setup({ signs = false })
	keys.multicursor(mc)
end

function setup.flash()
	require("flash").setup({
		labels = "asdfghjkl",
		jump = { autojump = true },
		label = { rainbow = { enabled = true, shade = 2 } },
		modes = { char = { enabled = false } },
	})
end

function setup.telescope()
	require("telescope").setup({
		defaults = {
			file_ignore_patterns = {
				"node_modules",
				"build",
				".git",
				"package-lock.json",
				"*.vsd*",
				"undodir",
				"target",
				"nvim-pack-lock.json",
				"sessions",
			},
			selection_caret = "  ",
			prompt_prefix = "  ",
			entry_prefix = "  ",
			sorting_strategy = "ascending",
			layout_strategy = "bottom_pane",
			results_title = false,
			prompt_title = false,
			border = false,
			layout_config = { height = 0.2, prompt_position = "bottom", preview_cutoff = 120, width = 0.8 },
			path_display = { "truncate" },
		},
		pickers = {
			colorscheme = { enable_preview = true },
			buffers = { ignore_current_buffer = true, sort_lastused = true, mappings = keys.telescope_buffers },
		},
	})
end

function setup.qfpreview()
	require("qfpreview").setup()
end

setup["typst-preview"] = function()
	require("typst-preview").setup()
end

function setup.CopilotChat()
	require("CopilotChat").setup({
		model = "gpt-4.1",
		temperature = 0.1,
		highlight_headers = true,
		headers = { user = "> [!NOTE] User ", assistant = "> [!HINT] Assistant ", tool = "🔧" },
		insert_at_end = false,
		separator = " ",
		show_folds = false,
		show_help = false,
		auto_insert_mode = false,
	})
end

-- Not needed for first draw: set up after startup
vim.schedule(function()
	require("mini.pairs").setup()
	require("mini.surround").setup({ mappings = keys.surround, search_method = "cover" })

	require("which-key").setup({
		preset = "helix",
		delay = 500,
		win = { border = "none", padding = { 0, 0, 0, 0 }, title = false },
		layout = { height = { min = 1, max = 20 }, width = { min = 1, max = 50 }, spacing = 1, align = "left" },
	})

	require("blink.cmp").setup({
		keymap = keys.blink,
		appearance = { nerd_font_variant = "mono" },
		completion = {
			accept = { auto_brackets = { enabled = true } },
			documentation = { auto_show = true },
			menu = {
				draw = {
					columns = { { "kind_icon", "label", gap = 1 }, { "kind", "label_description", gap = 1 } },
				},
			},
		},
		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
			min_keyword_length = function(ctx)
				return ctx.trigger.kind == "manual" and 0 or 2
			end,
		},
	})
end)
