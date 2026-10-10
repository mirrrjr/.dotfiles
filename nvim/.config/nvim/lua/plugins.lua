-- Paketlarni yuklash
vim.pack.add({
	{ src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
	{ src = "https://github.com/folke/noice.nvim" },
	{ src = "https://github.com/rcarriga/nvim-notify" },
	{ src = "https://github.com/nvim-mini/mini.statusline" },
	{ src = "https://github.com/MunifTanjim/nui.nvim" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/chomosuke/typst-preview.nvim" },
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/nvim-mini/mini.pick" },
	{ src = "https://github.com/stevearc/conform.nvim" },
	{ src = "https://github.com/windwp/nvim-autopairs" },
	{ src = "https://github.com/nvim-telescope/telescope.nvim" },
	{ src = "https://github.com/folke/snacks.nvim" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/b0o/SchemaStore.nvim" },
})

-- Color theme
-- vim.opt.background = "dark"
vim.cmd([[colorscheme catppuccin-mocha]])

-- Noice & Notify
require("noice").setup({
	presets = {
		bottom_search = true,
		command_palette = true,
		long_message_to_split = true,
	},
})

-- Mini statusline & pick
require("mini.statusline").setup()
require("mini.pick").setup({
	options = {
		use_cache = true,
	},
})

-- Telescope
require("telescope").setup({
	defaults = {
		file_ignore_patterns = {
			"node_modules",
			"%.git/",
			"vendor/",
		},

		layout_config = {
			prompt_position = "top",
		},

		sorting_strategy = "ascending",
	},

	pickers = {
		find_files = {
			hidden = true,
			no_ignore = true,
			find_command = {
				"fd",
				"--type",
				"f",
				"--hidden",
				"--no-ignore",
				"--exclude",
				".git",
				-- "rg", "--files", "--hidden", "--glob", "!**/.git/*"
			},
		},
	},
})

-- Snacks
require("snacks").setup({
	image = { enabled = true },
	picker = {
		enabled = true,
		sources = {
			files = {
				hidden = true, -- nuqtali fayl/papkalarni ko'rsatadi
				ignored = false, -- .gitignore dagilarni yashiradi
				exclude = { ".git", "node_modules" },
			},
			grep = {
				hidden = true,
				exclude = { ".git", "node_modules" },
			},
		},
	},
})

-- Oil.nvim sozlamalari
require("oil").setup({
	default_file_explorer = true,
	columns = { "icon" },
	view_options = { show_hidden = true },
})

-- Conform
require("conform").setup({
	formatters_by_ft = {
		sh = { "shfmt" },
		bash = { "shfmt" },
		zsh = { "shfmt" },
		javascript = { "prettier" },
		typescript = { "prettier" },
		javascriptreact = { "prettier" },
		typescriptreact = { "prettier" },
		rust = { "rustfmt" },
		php = { "pint" },
		blade = { "blade-formatter" },
		html = { "prettier" },
		css = { "prettier" },
		json = { "prettier" },
		lua = { "stylua" },
		go = { "gofumpt" }, -- gofmt dan kuchliroq
		python = { "ruff_format" }, -- black dan tezroq, hamma narsa bir tool
		sql = { "sqlfmt" },
	},
	format_on_save = {
		async = false,
		timeout_ms = 500,
		lsp_fallback = true,
	},
})

-- Autopairs
require("nvim-autopairs").setup({})
