----------------------------------------------------------------------
-- Autocmds (must be registered before calling vim.pack.add)
----------------------------------------------------------------------

vim.api.nvim_create_autocmd("PackChanged", {
	pattern = "*telescope-fzf-native",
	callback = function(ev)
        if ev.data.kind == "delete" then return end
		local ret = vim.system({ "make" }, { cwd = ev.data.path }):wait()
		if ret.code ~= 0 then
			vim.notify(ret.stderr or "fzf build error", vim.log.levels.ERROR)
			return
		end
	end
})

vim.api.nvim_create_autocmd("PackChanged", {
	pattern = "*nvim-treesitter",
	callback = function(ev)
        if ev.data.kind == "delete" then return end
        vim.cmd.packadd("nvim-treesitter")
        vim.cmd.TSUpdate()
    end
})

vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function() vim.hl.on_yank() end
})

----------------------------------------------------------------------
-- Plugin setup
----------------------------------------------------------------------

vim.pack.add({
	{ src = "https://github.com/rose-pine/neovim", name = "rose-pine" },
	{ src = "https://github.com/nvim-lua/plenary.nvim", name = "plenary" },
	{ src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim", name = "telescope-fzf-native" },
	{ src = "https://github.com/nvim-telescope/telescope.nvim", name = "telescope" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", name = "nvim-treesitter" },
	{ src = "https://github.com/lewis6991/gitsigns.nvim", name = "gitsigns" },
	{ src = "https://github.com/smoka7/hop.nvim", name = "hop" },
})

vim.cmd("colorscheme rose-pine-moon")

require("telescope").setup({
	defaults = { mappings = { i = { ["<esc>"] = require("telescope.actions").close }}},
	pickers = {
		colorscheme = { enable_preview = true },
		find_files = { no_ignore = true },
	}
})
require("telescope").load_extension("fzf")

require("nvim-treesitter.configs").setup({
    ensure_installed = {
        "bash", "c", "cpp", "diff", "html", "javascript",
        "jsdoc", "json", "jsonc", "lua", "luadoc", "luap",
        "markdown", "markdown_inline", "printf", "python",
        "query", "regex", "toml", "tsx", "typescript", "vim",
        "vimdoc", "xml", "yaml", "go"
    },
    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = { enable = true }
})

require("hop").setup({ keys = "etovxqpdygfblzhckisuran" })

----------------------------------------------------------------------
-- Options and keymaps
----------------------------------------------------------------------

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.smartindent = true
vim.opt.number = true
vim.opt.signcolumn = "yes"

local telescope_builtin = require("telescope.builtin")
local treesitter_inc = require("nvim-treesitter.incremental_selection")
local gitsigns = require("gitsigns")
local hop = require("hop")

vim.keymap.set("n", "<leader>f", telescope_builtin.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>/", telescope_builtin.live_grep, { desc = "Live grep" })
vim.keymap.set("n", "<leader>w", telescope_builtin.grep_string, { desc = "Grep word" })
vim.keymap.set("n", "<leader>h", telescope_builtin.help_tags, { desc = "Help" })
vim.keymap.set("n", "<leader>gc", telescope_builtin.git_commits, { desc = "Git commits" })
vim.keymap.set("n", "<leader>gg", telescope_builtin.git_status, { desc = "Git changes" })
vim.keymap.set("n", "<M-o>", treesitter_inc.init_selection, { desc = "Start node selection" })
vim.keymap.set("x", "<M-o>", treesitter_inc.node_incremental, { desc = "Expand node selection" })
vim.keymap.set("x", "<M-i>", treesitter_inc.node_decremental, { desc = "Shrink node selection" })
vim.keymap.set("n", "<leader>]", gitsigns.next_hunk, { desc = "Next hunk" })
vim.keymap.set("n", "<leader>[", gitsigns.prev_hunk, { desc = "Previous hunk" })
vim.keymap.set("n", "<leader>gp", gitsigns.preview_hunk_inline, { desc = "Preview hunk inline" })
vim.keymap.set("n", "<leader>gr", gitsigns.reset_hunk, { desc = "Reset hunk" })
vim.keymap.set("n", "gw", hop.hint_words, { desc = "Goto word" })
vim.keymap.set("n", "H", "^", { remap = false, silent = true, desc = "Start of line"})
vim.keymap.set("n", "L", "$", { remap = false, silent = true, desc = "End of line" })
vim.keymap.set("n", "j", 'v:count ? "j" : "gj"', { expr = true })
vim.keymap.set("v", "j", 'v:count ? "j" : "gj"', { expr = true })
vim.keymap.set("n", "k", 'v:count ? "k" : "gk"', { expr = true })
vim.keymap.set("v", "k", 'v:count ? "k" : "gk"', { expr = true })
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
vim.keymap.set("n", "U", "<cmd>redo<CR>", { desc = "Redo"})
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
