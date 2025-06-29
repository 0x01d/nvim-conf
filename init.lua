-- always set leader first!
vim.keymap.set("n", "<Space>", "<Nop>", { silent = true })
vim.g.mapleader = " "

-- Bootstrap lazy.nvim
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

require("lazy").setup({
	spec = {
		-- add your plugins here
		-- Mason & LSP servers
		{
			"williamboman/mason.nvim",
			cmd = "Mason",
			opts = {
				ui = { border = "rounded" },
				ensure_installed = { "pyright", "lua_ls", "black", "isort", "ruff", "stylua" },
				automatic_installation = true,
			},
		},
		{
			"williamboman/mason-lspconfig.nvim",
			dependencies = "mason.nvim",
			opts = {
				ensure_installed = { "pyright", "lua_ls" },
				automatic_installation = true,
			},
		},
		{
			"j-hui/fidget.nvim",
			tag = "legacy",
			event = "LspAttach",
			opts = {},
		},
		{
			"neovim/nvim-lspconfig",
			event = { "BufReadPre", "BufNewFile" },
			dependencies = { "mason-lspconfig.nvim", "fidget.nvim" },
			config = function()
				local lspconfig = require("lspconfig")

				lspconfig.pyright.setup({
					settings = {
						python = {
							analysis = {
								autoSearchPaths = true,
								useLibraryCodeForTypes = true,
								diagnosticMode = "workspace",
							},
						},
					},
				})

				lspconfig.lua_ls.setup({
					settings = {
						Lua = {
							runtime = { version = "LuaJIT" },
							diagnostics = { globals = { "vim" } },
							workspace = { library = vim.api.nvim_get_runtime_file("", true) },
							telemetry = { enable = false },
						},
					},
				})
			end,
		},

		-- Treesitter
		{
			"nvim-treesitter/nvim-treesitter",
			build = ":TSUpdate",
			event = { "BufReadPre", "BufNewFile" },
			opts = {
				ensure_installed = { "python", "lua", "json", "yaml", "bash" },
				highlight = { enable = true },
				indent = { enable = true },
				incremental_selection = { enable = true },
				playground = { enable = true },
			},
		},
		{ "nvim-treesitter/playground", cmd = "TSPlaygroundToggle" },
	},
	-- Configure any other settings here. See the documentation for more details.
	-- colorscheme that will be used when installing plugins.
	install = { colorscheme = { "habamax" } },
	-- automatically check for plugin updates
	checker = { enabled = true },
})

-- Preferences
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.foldenable = false
vim.opt.wrap = false
vim.opt.cmdheight = 3

vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.tabstop = 4
vim.opt.expandtab = false
vim.opt.smarttab = false
vim.opt.wildignore = '.hg,.svn,*~,*.png,*.jpg,*.gif,*.min.js,*.swp,*.o,vendor,dist,_site'

vim.opt.scrolloff = 2
-- more useful diffs (nvim -d)
--- by ignoring whitespace
vim.opt.diffopt:append('iwhite')
--- and using a smarter algorithm
--- https://vimways.org/2018/the-power-of-diff/
--- https://stackoverflow.com/questions/32365271/whats-the-difference-between-git-diff-patience-and-git-diff-histogram
--- https://luppeng.wordpress.com/2020/10/10/when-to-use-each-of-the-git-diff-algorithms/
vim.opt.diffopt:append('algorithm:histogram')
vim.opt.diffopt:append('indent-heuristic')
-- show a column at 80 characters as a guide for long lines
vim.opt.colorcolumn = '80'

vim.opt.listchars = 'tab:^ ,nbsp:¬,extends:»,precedes:«,trail:•' 
-- <leader><leader> toggles between buffers
vim.keymap.set('n', '<leader><leader>', '<c-^>')
-- <leader>, shows/hides hidden characters
vim.keymap.set('n', '<leader>,', ':set invlist<cr>')

-- case-insensitive search/replace
vim.opt.ignorecase = true
-- unless uppercase in search term
vim.opt.smartcase = true

--" Decent wildmenu
-- in completion, when there is more than one match,
-- list all matches, and only complete to longest common match
vim.opt.wildmode = 'list:longest'

-- keymaps
vim.keymap.set('v', 'Y', '"+y')
vim.keymap.set('n', 'P', '"+p')

-- quick-open
vim.keymap.set('', '<C-p>', '<cmd>Files<cr>')
-- search buffers
vim.keymap.set('n', '<leader>;', '<cmd>Buffers<cr>')
-- quick-save
vim.keymap.set('n', '<leader>w', '<cmd>w<cr>')

-- https://github.com/neovim/neovim/issues/5916
-- So we also map Ctrl+k
-- Ctrl+h to stop searching
vim.keymap.set('v', '<C-h>', '<cmd>nohlsearch<cr>')
vim.keymap.set('n', '<C-h>', '<cmd>nohlsearch<cr>')
-- Jump to start and end of line using the home row keys
vim.keymap.set('', 'H', '^')
vim.keymap.set('', 'L', '$')
vim.keymap.set('', 'R', ':%s/')

-- let the left and right arrows be useful: they can switch buffers
vim.keymap.set('n', '<left>', ':bp<cr>')
vim.keymap.set('n', '<right>', ':bn<cr>')

-- handy keymap for replacing up to next _ (like in variable names)
vim.keymap.set('n', '<leader>m', 'ct_')
-- F1 is pretty close to Esc, so you probably meant Esc
vim.keymap.set('', '<F1>', '<Esc>')
vim.keymap.set('i', '<F1>', '<Esc>')
vim.api.nvim_set_keymap('n', '<C-f>', ':sus<CR>', { noremap = true, silent = true })

vim.cmd 'colorscheme habamax'
