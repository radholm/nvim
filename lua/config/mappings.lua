-- GENERAL
vim.g.mapleader = " "

-- Wrapper for easy functions
local wrap = function(fn, ...)
	local args = { ... }
	return function()
		return fn(unpack(args))
	end
end

-- General navigation and buffer management
G.keymap("n", "<leader>pv", function()
	require("oil").open_float(nil, {
		preview = {
			horizontal = true,
		},
	})
end, { desc = "Open Oil in float with horizontal preview" })
G.keymap("n", "<leader>cp", "<cmd>Compile<cr>", { desc = "Compile mode" })
G.keymap("n", "<leader>z", "<cmd>Goyo<cr>", { desc = "Zen mode" })
G.keymap("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move selected lines down" })
G.keymap("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move selected lines up" })
G.keymap("n", ":", "q:i", { desc = "Command window" })
G.keymap("n", "/", "q/i", { desc = "Search window" })
G.keymap("n", "n", "nzzzv", { desc = "Next search result centered" })
G.keymap("n", "N", "Nzzzv", { desc = "Prev search result centered" })
G.keymap("n", "<esc>", ":bd<cr>", { desc = "Minimize buffer" })
G.keymap("n", "q", ":bd<cr>", { desc = "Delete buffer" })

-- Contextual <Esc>
G.keymap("n", "<esc>", function()
	local buftype = vim.bo.buftype
	if buftype ~= "" then
		vim.api.nvim_input("q")
	else
		vim.cmd("stopinsert")
	end
end, { desc = "Contextual <Esc> (close special buffer or stop insert)" })

G.autocmd("CmdwinEnter", {
	callback = function()
		G.keymap("n", "<cr>", "<cr>", { desc = "Execute command", buffer = true })
		G.keymap("i", "<esc>", "<c-c><c-w><cr>", { desc = "Exit command-line (Insert)", buffer = true })
		G.keymap("n", "<esc>", "<c-w>c", { desc = "Exit command-line (Normal)", buffer = true })
		G.keymap("i", "<c-c>", "<esc>", { desc = "Escape insert mode", buffer = true })
	end,
})

-- TELESCOPE
local tb = require("telescope.builtin")

G.keymap("n", "<leader>ff", wrap(tb.find_files, { previewer = false }), { desc = "Find files" })
G.keymap("n", "<leader>fr", wrap(tb.resume), { desc = "Resume last Telescope" })
G.keymap("n", "<leader>fg", wrap(tb.live_grep), { desc = "Live grep search" })
G.keymap("n", "<leader><leader>", wrap(tb.buffers), { desc = "List open buffers" })
G.keymap("n", "<leader>fh", wrap(tb.help_tags), { desc = "Find help tags" })
G.keymap("n", "<leader>fu", wrap(tb.lsp_references), { desc = "Find LSP references" })
G.keymap("n", "<leader>o", wrap(tb.oldfiles), { desc = "Open recent files" })

-- Copilot
local ch = require("CopilotChat")

G.keymap("i", "<c-l>", "<Plug>(copilot-accept-word)", { desc = "Copilot accept word" })
G.keymap("i", "<right>", "<Plug>(copilot-accept-word)", { desc = "Copilot accept word (arrow)" })
G.keymap("i", "<c-k>", "<Plug>(copilot-previous)", { desc = "Copilot previous suggestion" })
G.keymap("i", "<c-j>", "<Plug>(copilot-next)", { desc = "Copilot next suggestion" })
G.keymap("n", "<leader>gh", "<cmd>CopilotChatToggle<cr>", { desc = "Open Github Copilot chat" })
G.keymap("n", "<leader>gr", function()
	ch.open()
	ch.ask("How can I optimize or improve this?", {
		model = G.gpt,
		sticky = { "#buffer", "#gitdiff:staged" },
	})
end, { desc = "Get code review on staged files" })
G.keymap("v", "<leader>gh", function()
	local old = { reg = vim.fn.getreg("z"), type = vim.fn.getregtype("z") }
	vim.cmd([[normal! "zy]])
	local selected_text = vim.fn.getreg("z") or ""
	vim.fn.setreg("z", old.reg, old.type)
	ch.toggle()
	vim.schedule(function()
		local window = ch.chat
		window:add_message({ role = "user", content = "\n#buffer\n\n" .. selected_text .. "\n" }, true)
		window:focus()
		window:follow()
		vim.cmd("startinsert")
	end)
end, { desc = "Paste selection in Copilot chat and enter insert mode" })

-- LSP
G.keymap("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
G.keymap("n", "grf", vim.lsp.buf.format, { desc = "Format code" })
G.keymap("n", "grt", vim.lsp.buf.type_definition, { desc = "Go to type definition" })
G.keymap("n", "gri", vim.lsp.buf.implementation, { desc = "Go to implementation" })
G.keymap("n", "K", vim.lsp.buf.hover, { desc = "Show hover info" })
G.keymap("n", "gws", vim.lsp.buf.workspace_symbol, { desc = "Workspace symbol search" })
G.keymap("n", "gof", vim.diagnostic.open_float, { desc = "Open diagnostic float" })
G.keymap("n", "<leader>x", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
G.keymap("n", "<leader>X", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
G.keymap("n", "gra", vim.lsp.buf.code_action, { desc = "Code action" })
G.keymap("n", "grn", vim.lsp.buf.references, { desc = "Find references" })
G.keymap("n", "grr", vim.lsp.buf.rename, { desc = "Rename symbol" })
G.keymap("n", "gri", vim.lsp.buf.incoming_calls, { desc = "Incoming calls" })
G.keymap("n", "gro", vim.lsp.buf.outgoing_calls, { desc = "Outgoing calls" })
G.keymap("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
G.keymap("n", "gO", vim.lsp.buf.document_symbol, { desc = "Document symbols" })
G.keymap("i", "<c-h>", vim.lsp.buf.signature_help, { desc = "Signature help" })

-- GIT
local gitsigns = require("gitsigns")

G.keymap("n", "<leader>h", wrap(gitsigns.nav_hunk, "next"), { desc = "Next hunk" })
G.keymap("n", "<leader>H", wrap(gitsigns.nav_hunk, "prev"), { desc = "Previous hunk" })
G.keymap("n", "<leader>gi", gitsigns.preview_hunk_inline, { desc = "Preview hunk" })
G.keymap("n", "<leader>gg", "<cmd>G<cr>", { desc = "Open fugitive Git" })

-- JUMPING
local fl = require("flash")

G.keymap({ "n", "x", "o" }, "s", wrap(fl.jump), { desc = "Flash" })
G.keymap({ "n", "x", "o" }, "S", wrap(fl.treesitter), { desc = "Flash Treesitter" })
G.keymap("o", "r", wrap(fl.remote), { desc = "Remote Flash" })
G.keymap({ "o", "x" }, "R", wrap(fl.treesitter_search), { desc = "Treesitter Search" })
G.keymap({ "c" }, "<C-l>", wrap(fl.toggle), { desc = "Toggle Flash Search" })

-- MULTICURSOR
local mc = require("multicursor-nvim")

G.keymap({ "n", "x" }, "<up>", wrap(mc.lineAddCursor, -1), { desc = "Add cursor up" })
G.keymap({ "n", "x" }, "<down>", wrap(mc.lineAddCursor, 1), { desc = "Add cursor down" })
G.keymap({ "n", "x" }, "<leader><up>", wrap(mc.lineSkipCursor, -1), { desc = "Skip cursor up" })
G.keymap({ "n", "x" }, "<leader><down>", wrap(mc.lineSkipCursor, 1), { desc = "Skip cursor down" })
G.keymap({ "n", "x" }, "<leader>n", wrap(mc.matchAddCursor, 1), { desc = "Add next match cursor" })
G.keymap({ "n", "x" }, "<leader>s", wrap(mc.matchSkipCursor, 1), { desc = "Skip next match" })
G.keymap({ "n", "x" }, "<leader>N", wrap(mc.matchAddCursor, -1), { desc = "Add prev match cursor" })
G.keymap({ "n", "x" }, "<leader>S", wrap(mc.matchSkipCursor, -1), { desc = "Skip prev match" })

mc.addKeymapLayer(function(layerSet)
	layerSet({ "n", "x" }, "<left>", mc.prevCursor)
	layerSet({ "n", "x" }, "<right>", mc.nextCursor)
	layerSet({ "n", "x" }, "<leader>x", mc.deleteCursor)
	layerSet("n", "<esc>", function()
		if not mc.cursorsEnabled() then
			mc.enableCursors()
		else
			mc.clearCursors()
		end
	end)
end)

-- TREESITTER
local ts = require("nvim-treesitter")
local tsc = require("treesitter-context")

G.keymap("n", "gco", wrap(tsc.go_to_context, vim.v.count1), { desc = "Go to context" })
ts.setup({
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

vim.keymap.set("n", "<leader>asd", "<cmd>Pick files<cr>", { desc = "Pick files" })
