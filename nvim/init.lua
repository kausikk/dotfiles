----------------------------------------------------------------------
-- Autocmds
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

vim.api.nvim_create_autocmd("FileType", {
	callback = function(ev)
		-- from MeanderingProgrammer/treesitter-modules.nvim, <3
		local filetype = ev.match
		local lang = vim.treesitter.language.get_lang(filetype) or filetype
		if not vim.treesitter.language.add(lang) then
			return
		end
		vim.wo.foldmethod = 'expr'
		vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
		vim.treesitter.start(ev.buf, lang)
		vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
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
	{ src = "https://github.com/smoka7/hop.nvim", name = "hop" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", name = "nvim-treesitter" },
	{ src = "https://github.com/nvim-mini/mini.files", name = "mini.files" },
	{ src = "https://github.com/lewis6991/gitsigns.nvim", name = "gitsigns" },
	{ src = "https://github.com/windwp/nvim-autopairs", name = "nvim-autopairs" },
	{ src = "https://github.com/NMAC427/guess-indent.nvim", name = "guess-indent" },
	{ src = "https://github.com/kausikk/nanobufferline", name = "nanobufferline" },
	{ src = "https://github.com/MeanderingProgrammer/treesitter-modules.nvim", name = "treesitter-modules" },
})

vim.cmd("colorscheme rose-pine-moon")

local telescope = require("telescope")
local actions = require("telescope.actions")
local act_state = require("telescope.actions.state")
telescope.setup({
	defaults = { mappings = { i = { ["<esc>"] = "close" }}},
	pickers = {
		colorscheme = { enable_preview = true },
		find_files = { no_ignore = true },
		help_tags = {
			-- Open help in vertical split! Based on a Telescope configuration recipe for cd.
			mappings = { i = { ["<CR>"] = function(prompt_bufnr)
				actions.close(prompt_bufnr)
				vim.cmd("vert rightb help " .. act_state.get_selected_entry().value)
			end }}
		}
	}
})
telescope.load_extension("fzf")

require("mini.files").setup({ mappings = { close = "<Esc>" }})

require("nvim-treesitter").install({
	"bash", "c", "cpp", "diff", "html", "javascript",
	"jsdoc", "json", "jsonc", "lua", "luadoc", "luap",
	"markdown", "markdown_inline", "printf", "python",
	"query", "regex", "toml", "tsx", "typescript", "vim",
	"vimdoc", "xml", "yaml", "go"
})

-- Wrappers for treesitter-modules so that keymaps only need to be
-- set once. Not necessarily the best way to do this, but I like
-- setting my keymaps in one place.
local ts_select = require("treesitter-modules.lib.selection")
function ts_wrap(func)
	local buf = vim.api.nvim_get_current_buf()
	local filetype = vim.api.nvim_get_option_value("filetype", { buf = buf })
	local lang = vim.treesitter.language.get_lang(filetype)
	func(buf, lang)
end
function init_selection() ts_wrap(ts_select.init_selection) end
function node_incremental() ts_wrap(ts_select.node_incremental) end
function node_decremental () ts_wrap(ts_select.node_decremental) end

require("hop").setup({ keys = "etovxqpdygfblzhckisuran" })

require("nvim-autopairs").setup({})

require("guess-indent").setup({ on_tab_options = { ["tabstop"] = 4, ["shiftwidth"] = 4 }})

----------------------------------------------------------------------
-- Options and keymaps
----------------------------------------------------------------------

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.number = true
vim.opt.signcolumn = "yes"
vim.opt.scroll = 20
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.inccommand = "nosplit"
vim.opt.list = true
vim.opt.listchars = { tab = '. ' }
vim.opt.laststatus = 3
vim.opt.foldlevel = 99
vim.opt.statusline = "%=%l,%c"
vim.opt.expandtab = false
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4

local telescope_builtin = require("telescope.builtin")
local minif = require("mini.files")
local gitsigns = require("gitsigns")
local hop = require("hop")
vim.keymap.set("n", "<leader>f", telescope_builtin.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>b", telescope_builtin.buffers, { desc = "Select buffer" })
vim.keymap.set("n", "<leader>/", telescope_builtin.live_grep, { desc = "Live grep" })
vim.keymap.set("n", "<leader>w", telescope_builtin.grep_string, { desc = "Grep word" })
vim.keymap.set("n", "<leader>h", telescope_builtin.help_tags, { desc = "Help" })
vim.keymap.set("n", "<leader>gc", telescope_builtin.git_commits, { desc = "Git commits" })
vim.keymap.set("n", "<leader>gg", telescope_builtin.git_status, { desc = "Git changes" })
vim.keymap.set("n", "<leader>e", minif.open, { desc = "Explore files" })
vim.keymap.set("n", "<M-o>", init_selection, { desc = "Start node selection" })
vim.keymap.set("x", "<M-o>", node_incremental, { desc = "Expand node selection" })
vim.keymap.set("x", "<M-i>", node_decremental, { desc = "Shrink node selection" })
vim.keymap.set("n", "<leader>]", gitsigns.next_hunk, { desc = "Next hunk" })
vim.keymap.set("n", "<leader>[", gitsigns.prev_hunk, { desc = "Previous hunk" })
vim.keymap.set("n", "<leader>gp", gitsigns.preview_hunk_inline, { desc = "Preview hunk inline" })
vim.keymap.set("n", "<leader>gr", gitsigns.reset_hunk, { desc = "Reset hunk" })
vim.keymap.set("n", "gw", function() hop.hint_words({ multi_windows = true }) end, { desc = "Goto word" })
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
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
vim.keymap.set("n", "<Tab>", "<cmd>bn<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<S-Tab>", "<cmd>bp<CR>", { desc = "Previous buffer" })
