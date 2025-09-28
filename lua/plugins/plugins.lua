return {
	{
		"RRethy/base16-nvim",
	},
	{
		"tpope/vim-fugitive",
	},
	{
		"github/copilot.vim",
	},
	{
		"neovim/nvim-lspconfig",
	},
	{
		"creativenull/efmls-configs-nvim",
	},
	{
		"nvim-lua/plenary.nvim",
		branch = "master",
	},
	{
		"r0nsha/qfpreview.nvim",
		opts = {},
	},
	{
		"chomosuke/typst-preview.nvim",
		opts = {},
	},
	{
		"mason-org/mason.nvim",
		opts = {},
	},
	{
		"jake-stewart/multicursor.nvim",
		opts = {
			signs = false,
		},
	},
	{
		"nickkadutskyi/jb.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			transparent = false,
		},
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		lazy = false,
		opts = function()
			local ts = require("nvim-treesitter.configs")
			ts.setup({
				auto_install = true,
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = { "markdown" },
				},
				indent = {
					enable = true,
				},
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<CR>",
						--scope_incremental = '<CR>',
						node_incremental = "<TAB>",
						node_decremental = "<S-TAB>",
					},
				},
			})
		end,
	},
	{
		"saghen/blink.cmp",
		dependencies = {
			"rafamadriz/friendly-snippets",
		},
		build = "cargo +nightly build --release",
		version = "1.*",
		opts = {
			keymap = { preset = "default" },
			appearance = {
				nerd_font_variant = "mono",
			},
			cmdline = { enabled = true },
			completion = {
				keyword_length = 2,
				accept = { auto_brackets = { enabled = true } },
				documentation = { auto_show = true },
				menu = {
					auto_show = true,
					draw = {
						columns = {
							{ "kind_icon", "label", gap = 1 },
							-- { "label", gap = 1 },
							{ "kind", "label_description", gap = 1 },
						},
					},
				},
			},
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
				min_keyword_length = function(ctx)
					return ctx.trigger.kind == "manual" and 0 or 2
				end,
			},
		},
		opts_extend = { "sources.default" },
	},
	{
		"nvim-telescope/telescope.nvim",
		opts = {
			defaults = {
				file_ignore_patterns = {
					"node_modules",
					"build",
					".git",
					"package-lock.json",
					"*.vsd*",
					"undodir",
					"target",
					"lazy-lock.json",
					"sessions",
				},
				selection_caret = "  ",
				prompt_prefix = "  ",
				entry_prefix = "  ",
				initial_mode = "insert",
				selection_strategy = "reset",
				sorting_strategy = "ascending",
				layout_strategy = "bottom_pane",
				results_title = false,
				prompt_title = false,
				border = false,
				layout_config = {
					height = 0.2,
					prompt_position = "bottom",
					preview_cutoff = 120,
					width = 0.8,
				},
				pickers = {
					find_files = {
						find_command = {
							"rg",
							"--files",
							"--hidden",
							"--glob",
							"!**/.git/*",
							"-L",
							"--max-depth",
							"10",
						},
					},
				},
				path_display = { "truncate" },
				winblend = 0,
			},
			pickers = {
				colorscheme = {
					enable_preview = true,
				},
				buffers = {
					ignore_current_buffer = true,
					sort_lastused = true,
					mappings = {
						n = {
							["dd"] = require("telescope.actions").delete_buffer,
						},
						i = {
							["<C-d>"] = require("telescope.actions").delete_buffer,
						},
					},
				},
			},
		},
	},
	{
		"nvim-lualine/lualine.nvim",
		opts = {
			options = {
				icons_enabled = true,
				theme = "auto",
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
				ignore_focus = {},
				always_divide_middle = true,
				globalstatus = false,
				refresh = {
					statusline = 100,
				},
			},
			sections = {
				lualine_a = {
					{
						"mode",
						fmt = function(str)
							return str:sub(1, 1)
						end,
					},
				},
				lualine_b = {
					{
						"branch",
						icon = "",
					},
					{
						"filename",
						path = 1,
						symbols = {
							modified = "[ + ]",
							readonly = "[ - ]",
							unnamed = "",
							newfile = "[ New ]",
						},
					},
				},
				lualine_c = {
					G.get_lsp_server_name,
					{
						"diagnostics",
						symbols = { error = "E", warn = "W", info = "I", hint = "H" },
						always_visible = false,
					},
					"searchcount",
				},
				lualine_x = {},
				lualine_y = {},
				lualine_z = {},
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = {},
				lualine_x = {},
				lualine_y = {},
				lualine_z = {},
			},
			tabline = {},
			winbar = {},
			inactive_winbar = {},
			extensions = {},
			disabled_buftypes = { "quickfix", "prompt" },
		},
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			preset = "helix",
			notify = true,
			delay = 500,
			win = {
				border = "none",
				padding = { 0, 0, 0, 0 },
				title = false,
			},
			layout = {
				height = { min = 1, max = 20 },
				width = { min = 1, max = 50 },
				spacing = 1,
				align = "left",
			},
		},
	},
	{
		"ej-shafran/compile-mode.nvim",
		version = "^5.0.0",
		dependencies = {
			{
				"m00qek/baleia.nvim",
				tag = "v1.3.0",
			},
		},
		init = function()
			vim.g.compile_mode = {
				default_command = "npm run ",
				-- auto_jump_to_first_error = true,
				error_regexp_table = {
					typescript = {
						-- regex = "^\\(.\\+\\)(\\([1-9][0-9]*\\),\\([1-9][0-9]*\\)): error TS[1-9][0-9]*:",
						regex = "^\\(.*\\.js\\):\\([0-9]\\{1,4}\\):\\([0-9]\\{1,4}\\)",
						filename = 1,
						row = 2,
						col = 3,
					},
				},
				baleia_setup = true,
			}
		end,
	},
	{
		"stevearc/oil.nvim",
		lazy = false,
		opts = {
			default_file_explorer = true,
			columns = {
				-- "icon",
				-- 'permissions',
				"size",
				"mtime",
			},
			lsp_file_methods = {
				enabled = true,
				timeout_ms = 1000,
				autosave_changes = true,
			},
			win_options = {
				number = false,
				relativenumber = false,
				wrap = false,
				signcolumn = "no",
				cursorcolumn = false,
				foldcolumn = "0",
				spell = false,
				list = false,
				conceallevel = 3,
				concealcursor = "nvic",
			},
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
			delete_to_trash = false,
			skip_confirm_for_simple_edits = true,
			prompt_save_on_select_new_entry = false,
			watch_for_changes = true,
			constrain_cursor = "name",
			keymaps = {
				["q"] = { "actions.close", mode = "n" },
				["<esc>"] = { "actions.close", mode = "n" },
				["l"] = { "actions.select", mode = "n" },
				["h"] = { "actions.parent", mode = "n" },
				["gp"] = {
					callback = function()
						local oil = require("oil")
						local entry = oil.get_cursor_entry()
						if entry then
							local dir = oil.get_current_dir()
							if dir then
								local fullpath = dir .. entry.name
								vim.fn.jobstart({ "open", fullpath }, { detach = true })
							end
						end
					end,
					desc = "Open in macOS Preview",
				},
			},
			use_default_keymaps = true,
			view_options = {
				show_hidden = true,
				natural_order = "fast",
				case_insensitive = true,
				sort = {
					{ "type", "asc" },
					{ "name", "asc" },
				},
			},
			preview_win = {
				update_on_cursor_moved = true,
				preview_method = "fast_scratch",
			},
			confirmation = {
				border = "none",
			},
			progress = {
				border = "none",
			},
			ssh = {
				border = "none",
			},
			keymaps_help = {
				border = "none",
			},
		},
	},
	{
		"rcarriga/nvim-notify",
		config = function()
			vim.notify = require("notify")
			require("notify").setup({
				on_open = function(win)
					vim.api.nvim_win_set_config(win, { border = "none" })
				end,
				fps = 120,
				level = vim.log.levels.INFO,
				render = "minimal",
				stages = "fade",
				timeout = 3000,
				minimum_width = 1.0,
				top_down = true,
				time_formats = {
					notification = "%T",
					notification_history = "%FT%T",
				},
			})
		end,
	},
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		build = "make tiktoken",
		tag = "v4.5.0",
		opts = {
			highlight_headers = true,
			model = G.gpt,
			temperature = 0.1,
			window = {
				--   -- layout = 'float',
				--   width = 0.4,
				--   -- height = 0.8,
				--   border = 'none',
				-- title = "Copilot",
				--   zindex = 100,
			},
			headers = {
				-- user = "👤",
				-- assistant = "🤖",
				-- tool = "🔧",
				user = "> [!NOTE] User ",
				assistant = "> [!HINT] Assistant ",
				-- user = "",
				-- assistant = "",
				tool = "🔧",
			},
			insert_at_end = false,
			-- separator = "\n─",
			separator = " ",
			show_folds = false,
			show_help = false,
			auto_insert_mode = false,
		},
	},
	{
		"MeanderingProgrammer/render-markdown.nvim",
		opts = {
			file_types = { "markdown", "copilot-chat" },
			heading = {
				enabled = true,
				sign = false,
				icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
				position = "overlay",
				signs = { "󰫎 " },
				width = "full",
				left_margin = 0,
				left_pad = 0,
				right_pad = 0,
				min_width = 0,
			},
			code = {
				style = "normal",
			},
			paragraph = {
				enabled = true,
				indent = 0,
			},
			bullet = {
				enabled = true,
				icons = { "●", "○", "◆", "◇" },
				left_pad = 0,
			},
			indent = {
				enabled = true,
				per_level = 4,
				skip_level = 0,
				skip_heading = true,
				icon = "",
			},
			completions = {
				lsp = { enabled = true },
			},
		},
	},
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {
			labels = "asdfghjkl",
			search = {
				multi_window = true,
				exclude = {
					"notify",
					"cmp_menu",
					"noice",
					"flash_prompt",
					function(win)
						return not vim.api.nvim_win_get_config(win).focusable
					end,
				},
			},
			jump = {
				jumplist = true,
				nohlsearch = false,
				autojump = true,
			},
			label = {
				uppercase = true,
				exclude = "",
				current = true,
				distance = true,
				rainbow = {
					enabled = true,
					shade = 2,
				},
			},
			modes = {
				char = {
					enabled = false,
					jump_labels = true,
				},
			},
			prompt = {
				enabled = true,
				prefix = { { "⚡", "FlashPromptIcon" } },
				win_config = {
					relative = "editor",
					width = 1,
					height = 1,
					row = -1,
					col = 0,
					zindex = 1000,
				},
			},
			remote_op = {
				restore = false,
				motion = false,
			},
		},
	},
	{
		"lewis6991/gitsigns.nvim",
		lazy = false,
		opts = {
			signs = {
				add = { text = "┃" },
				change = { text = "┃" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
				untracked = { text = "┆" },
			},
			current_line_blame = true,
			current_line_blame_opts = {
				virt_text = true,
				virt_text_pos = "eol",
				delay = 0,
			},
			numhl = false,
			linehl = false,
			word_diff = false,
		},
	},
	{
		"windwp/nvim-ts-autotag",
		event = "InsertEnter",
		opts = {
			opts = {
				enable_close = true,
				enable_rename = true,
				enable_close_on_slash = true,
			},
		},
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		config = function()
			require("treesitter-context").setup()
		end,
	},
	{
		"junegunn/goyo.vim",
		dependencies = { "junegunn/limelight.vim" },
	},
	{
		"chrisgrieser/nvim-spider",
		lazy = true,
		opts = {
			skipInsignificantPunctuation = false,
			consistentOperatorPending = true,
			subwordMovement = true,
			customPatterns = {},
		},
	},
	{
		"echasnovski/mini.nvim",
		config = function()
			require("mini.surround").setup({
				custom_surroundings = nil,
				highlight_duration = 500,
				mappings = {
					add = "sa",
					delete = "sd",
					replace = "sc",
				},
				respect_selection_type = false,
				search_method = "cover",
				silent = false,
			})
			require("mini.pairs").setup()
			require("mini.icons").setup()
		end,
	},
}
