-- All keymaps. Plugin-local keymaps are exported and passed to setup() in plugins.lua.
local map = vim.keymap.set
local M = {}

local function call(module, fn, ...)
	local args = { ... }
	return function()
		return require(module)[fn](unpack(args))
	end
end

-- General
map("n", "<leader>pv", call("oil", "open_float"), { desc = "Open Oil" })
map("n", "<leader>cp", "<cmd>Compile<cr>", { desc = "Compile mode" })
map("n", "<leader>z", "<cmd>Goyo<cr>", { desc = "Zen mode" })
map("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })
map("n", ":", "q:i", { desc = "Command window" })
map("n", "n", "nzzzv", { desc = "Next match centered" })
map("n", "N", "Nzzzv", { desc = "Prev match centered" })
map("n", "q", "<cmd>bd!<cr>", { desc = "Delete buffer" })
map("n", "<esc>", function()
	if vim.bo.buftype ~= "" then
		vim.api.nvim_input("q")
	else
		vim.cmd("stopinsert")
	end
end, { desc = "Close special buffer" })

vim.api.nvim_create_autocmd("CmdwinEnter", {
	callback = function()
		local opts = { buffer = true }
		map("n", "<cr>", "<cr>", opts)
		map("n", "<esc>", "<c-w>c", opts)
		map("i", "<esc>", "<c-c><c-w><cr>", opts)
		map("i", "<c-c>", "<esc>", opts)
	end,
})

-- Treesitter (native incremental selection: v_an / v_in)
map("n", "<cr>", function()
	if vim.bo.buftype == "" and vim.treesitter.get_parser(nil, nil, { error = false }) then
		return "van"
	end
	return "<cr>"
end, { expr = true, remap = true, desc = "Start node selection" })
map("x", "<tab>", "an", { remap = true, desc = "Grow node selection" })
map("x", "<s-tab>", "in", { remap = true, desc = "Shrink node selection" })
map("n", "gco", function()
	require("treesitter-context").go_to_context(vim.v.count1)
end, { desc = "Go to context" })

-- Telescope
map("n", "<leader>ff", call("telescope.builtin", "find_files", { previewer = false }), { desc = "Find files" })
map("n", "<leader>fr", call("telescope.builtin", "resume"), { desc = "Resume Telescope" })
map("n", "<leader>fg", function()
	require("telescope.builtin").live_grep({ cwd = require("oil").get_current_dir() })
end, { desc = "Live grep (Oil cwd)" })
map("n", "<leader><leader>", call("telescope.builtin", "buffers"), { desc = "Buffers" })
map("n", "<leader>fh", call("telescope.builtin", "help_tags"), { desc = "Help tags" })
map("n", "<leader>fu", call("telescope.builtin", "lsp_references"), { desc = "LSP references" })
map("n", "<leader>o", call("telescope.builtin", "oldfiles"), { desc = "Recent files" })

M.telescope_buffers = {
	n = { ["dd"] = "delete_buffer" },
	i = { ["<c-d>"] = "delete_buffer" },
}

-- Copilot
map("i", "<c-l>", "<Plug>(copilot-accept-word)", { desc = "Copilot accept word" })
map("i", "<right>", "<Plug>(copilot-accept-word)", { desc = "Copilot accept word" })
map("i", "<c-k>", "<Plug>(copilot-previous)", { desc = "Copilot previous" })
map("i", "<c-j>", "<Plug>(copilot-next)", { desc = "Copilot next" })
map("n", "<leader>gh", call("CopilotChat", "toggle"), { desc = "Copilot chat" })
map("n", "<leader>gr", function()
	local chat = require("CopilotChat")
	chat.open()
	chat.ask("How can I optimize or improve this?", { sticky = { "#buffer", "#gitdiff:staged" } })
end, { desc = "Review staged changes" })
map("v", "<leader>gh", function()
	local saved = { vim.fn.getreg("z"), vim.fn.getregtype("z") }
	vim.cmd([[normal! "zy]])
	local text = vim.fn.getreg("z")
	vim.fn.setreg("z", saved[1], saved[2])
	local chat = require("CopilotChat")
	chat.toggle()
	vim.schedule(function()
		chat.chat:add_message({ role = "user", content = "\n#buffer\n\n" .. text .. "\n" }, true)
		chat.chat:focus()
		chat.chat:follow()
		vim.cmd("startinsert")
	end)
end, { desc = "Send selection to Copilot chat" })

-- LSP (gra, grt, gO, K and <c-s> are Neovim defaults)
map("n", "gd", vim.lsp.buf.definition, { desc = "Definition" })
map("n", "gD", vim.lsp.buf.declaration, { desc = "Declaration" })
map("n", "grf", vim.lsp.buf.format, { desc = "Format" })
map("n", "grn", vim.lsp.buf.references, { desc = "References" })
map("n", "grr", vim.lsp.buf.rename, { desc = "Rename" })
map("n", "gri", vim.lsp.buf.incoming_calls, { desc = "Incoming calls" })
map("n", "gro", vim.lsp.buf.outgoing_calls, { desc = "Outgoing calls" })
map("n", "gws", vim.lsp.buf.workspace_symbol, { desc = "Workspace symbols" })
map("i", "<c-h>", vim.lsp.buf.signature_help, { desc = "Signature help" })
map("n", "gof", vim.diagnostic.open_float, { desc = "Diagnostic float" })
map("n", "<leader>x", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next diagnostic" })
map("n", "<leader>X", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Prev diagnostic" })

-- Git
map("n", "<leader>h", call("gitsigns", "nav_hunk", "next"), { desc = "Next hunk" })
map("n", "<leader>H", call("gitsigns", "nav_hunk", "prev"), { desc = "Prev hunk" })
map("n", "<leader>gi", call("gitsigns", "preview_hunk_inline"), { desc = "Preview hunk" })
map("n", "<leader>gro", call("gitsigns", "reset_hunk"), { desc = "Reset hunk" })
map("n", "<leader>gg", "<cmd>G<cr>", { desc = "Fugitive" })

-- Flash
map({ "n", "x", "o" }, "s", call("flash", "jump"), { desc = "Flash" })
map({ "n", "x", "o" }, "S", call("flash", "treesitter"), { desc = "Flash treesitter" })
map("o", "r", call("flash", "remote"), { desc = "Remote flash" })
map({ "o", "x" }, "R", call("flash", "treesitter_search"), { desc = "Treesitter search" })
map("c", "<c-l>", call("flash", "toggle"), { desc = "Toggle flash search" })

-- Multicursor
map({ "n", "x" }, "<up>", call("multicursor-nvim", "lineAddCursor", -1), { desc = "Add cursor up" })
map({ "n", "x" }, "<down>", call("multicursor-nvim", "lineAddCursor", 1), { desc = "Add cursor down" })
map({ "n", "x" }, "<leader><up>", call("multicursor-nvim", "lineSkipCursor", -1), { desc = "Skip cursor up" })
map({ "n", "x" }, "<leader><down>", call("multicursor-nvim", "lineSkipCursor", 1), { desc = "Skip cursor down" })
map({ "n", "x" }, "<leader>n", call("multicursor-nvim", "matchAddCursor", 1), { desc = "Add next match" })
map({ "n", "x" }, "<leader>s", call("multicursor-nvim", "matchSkipCursor", 1), { desc = "Skip next match" })
map({ "n", "x" }, "<leader>N", call("multicursor-nvim", "matchAddCursor", -1), { desc = "Add prev match" })
map({ "n", "x" }, "<leader>S", call("multicursor-nvim", "matchSkipCursor", -1), { desc = "Skip prev match" })
-- Layer needs mc.setup() first; called from plugins.lua
function M.multicursor(mc)
	mc.addKeymapLayer(function(set)
		set({ "n", "x" }, "<left>", mc.prevCursor)
		set({ "n", "x" }, "<right>", mc.nextCursor)
		set({ "n", "x" }, "<leader>x", mc.deleteCursor)
		set("n", "<esc>", function()
			if mc.cursorsEnabled() then
				mc.clearCursors()
			else
				mc.enableCursors()
			end
		end)
	end)
end

-- mini.surround
M.surround = { add = "sa", delete = "sd", replace = "sc" }

-- blink.cmp
M.blink = { preset = "default" }

-- Oil buffer
M.oil = {
	["q"] = { "actions.close", mode = "n" },
	["<esc>"] = { "actions.close", mode = "n" },
	["l"] = { "actions.select", mode = "n" },
	["h"] = { "actions.parent", mode = "n" },
	["gp"] = {
		desc = "Open in macOS default app",
		callback = function()
			local oil = require("oil")
			local entry, dir = oil.get_cursor_entry(), oil.get_current_dir()
			if entry and dir then
				vim.system({ "open", dir .. entry.name }, { detach = true })
			end
		end,
	},
}

return M
