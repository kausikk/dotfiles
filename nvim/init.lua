local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Navigation
vim.keymap.set('n', 'H', '^', { remap = false, silent = true, desc = 'Start of line (non-blank)' })
vim.keymap.set('n', 'L', '$', { remap = false, silent = true, desc = 'End of line' })
vim.keymap.set('n', 'j', 'v:count ? "j" : "gj"', { expr = true })
vim.keymap.set('n', 'k', 'v:count ? "k" : "gk"', { expr = true })
vim.keymap.set('v', 'j', 'v:count ? "j" : "gj"', { expr = true })
vim.keymap.set('v', 'k', 'v:count ? "k" : "gk"', { expr = true })


-- Line wrap
vim.opt.wrap = true
vim.opt.linebreak = true

-- Search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Clipboard
vim.g.clipboard = "osc52"

-- Windows
vim.o.splitright = true
vim.o.splitbelow = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end
})

-- Indent
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4

-- Other
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true
vim.o.number = true
vim.o.mouse = 'a'
vim.o.showmode = false

-- Redo
vim.keymap.set('n', 'U', '<cmd>redo<CR>')

require("lazy").setup({
    spec = {
    {
        "nvim-telescope/telescope.nvim",
        branch = "0.1.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" }
        },
        config = function()
            -- https://www.lazyvim.org/extras/editor/telescope#telescope-fzf-nativenvim
            -- https://github.com/nvim-lua/kickstart.nvim/blob/master/init.lua#L361
            local actions = require("telescope.actions")
            require("telescope").setup({
                -- https://github.com/nvim-telescope/telescope.nvim/wiki/Configuration-Recipes#mapping-esc-to-quit-in-insert-mode
                defaults = { mappings = { i = { ["<esc>"] = actions.close } } },
                pickers = {
                    colorscheme = { enable_preview = true },
                    find_files = { no_ignore = true }
                }
            })
            pcall(require("telescope").load_extension, "fzf")
            local builtin = require("telescope.builtin")
            vim.keymap.set("n", "<leader>f", builtin.find_files, {desc = "find files"})
            vim.keymap.set("n", "<leader>/", builtin.live_grep, {desc = "live grep"})
            vim.keymap.set("n", "<leader>o", builtin.lsp_document_symbols, {desc = "symbols in document"})
            vim.keymap.set("n", "<leader>w", builtin.grep_string, {desc = "grep string"})
            vim.keymap.set("n", "<leader>gc", builtin.git_commits, {desc = "git commits"})
            vim.keymap.set("n", "<leader>gg", builtin.git_status, {desc = "git changes"})
            vim.keymap.set("n", "<leader>b", builtin.buffers, {desc = "buffers"})
            vim.keymap.set("n", "<leader>h", builtin.help_tags, {desc = "help tags"})
        end
    },
    {
        "lewis6991/gitsigns.nvim",
        opts = {
            on_attach = function()
                local gitsigns = require('gitsigns')
                vim.keymap.set("n", "<leader>]", gitsigns.next_hunk, {desc = 'Next hunk'})
                vim.keymap.set("n", "<leader>[", gitsigns.prev_hunk, {desc = 'Previous hunk'})
                vim.keymap.set("n", "<leader>gp", gitsigns.preview_hunk_inline, {desc = 'Preview hunk inline'})
                vim.keymap.set("n", "<leader>gr", gitsigns.reset_hunk, {desc = 'Reset hunk'})
            end
        }
    },
    {
        "rose-pine/neovim", name = "rose-pine", lazy = false, priority = 1000,
        config = function() vim.cmd([[colorscheme rose-pine-moon]]) end
    },
    {
        "folke/which-key.nvim",
        event = "VeryLazy", opts = {},
    },
    {
        "smoka7/hop.nvim",
        config = function()
            require('hop').setup({ keys = "etovxqpdygfblzhckisuran" })
            local hop = require('hop')
            vim.keymap.set("n", "gw", hop.hint_words)
        end
    },
    {
        'windwp/nvim-autopairs',
        event = "InsertEnter",
        config = true
    },
    {
        "nvim-treesitter/nvim-treesitter", branch = 'master', lazy = false, build = ":TSUpdate",
        config = function()
            require('nvim-treesitter.configs').setup {
                ensure_installed = {
                    "bash",
                    "c",
                    "cpp",
                    "diff",
                    "html",
                    "javascript",
                    "jsdoc",
                    "json",
                    "jsonc",
                    "lua",
                    "luadoc",
                    "luap",
                    "markdown",
                    "markdown_inline",
                    "printf",
                    "python",
                    "query",
                    "regex",
                    "toml",
                    "tsx",
                    "typescript",
                    "vim",
                    "vimdoc",
                    "xml",
                    "yaml",
                    "go"
                },
                highlight = { enable = true },
                indent = { enable = true },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                       init_selection = "<M-o>",
                       node_incremental = "<M-o>",
                       node_decremental = "<M-i>",
                    }
                },
            }
        end
    },
    {
        "neovim/nvim-lspconfig",
        config = function()
            vim.lsp.enable('clangd')
            vim.lsp.enable('gopls')
        end
    }
    },
    checker = {enabled = true}
})
