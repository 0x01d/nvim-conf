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
                ensure_installed = { 'stylua' },
            },
        },
        {
            "williamboman/mason-lspconfig.nvim",
            dependencies = "mason.nvim",
            opts = {
                ensure_installed = { 
                    -- lua
                    "lua_ls",
                    -- python
                    "pyright",
                    "ruff",
                    -- markdown
                    "ltex",
                    -- terraform
                    "terraformls",
                    -- yaml
                    "yamlls",
                    -- bash
                    "bashls",
                    "ts_ls"
                },
                    automatic_installation = true,
                },
                keys = {
                    {
                        '<leader>en',
                        function() vim.diagnostic.goto_next() end,
                        desc = 'Next LSP Error'
                    },
                    {
                        '<leader>ep',
                        function() vim.diagnostic.goto_prev() end,
                        desc = 'Previous LSP Error'
                    }
                }
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

                    lspconfig.ruff.setup({
                        init_options = {
                            settings = {
                                -- Ruff language server settings go here
                            }
                        }
                    })
                    lspconfig.pyright.setup = {
                        settings = {
                            disableOrganizeImports = true,
                        },
                        python = {
                            analysis = {
                                ignore = {'*'},
                            },
                        },
                    }

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
                    lspconfig.ts_ls.setup({})
                end,
            },
            {
                'stevearc/conform.nvim',
                opts = {
                    -- Define your formatters
                    formatters_by_ft = {
                        lua = { "stylua" },
                        python = { "isort", "black" },
                        javascript = { "prettierd", "prettier", stop_after_first = true },
                    },
                },
            },

            -- Treesitter
            {
                "nvim-treesitter/nvim-treesitter",
                build = ":TSUpdate",
                event = { "BufReadPre", "BufNewFile" },
                opts = {
                    ensure_installed = { 
                        "python",
                        "lua",
                        "json",
                        "yaml",
                        "bash",
                        "markdown",
                        "query",
                        "vim" },
                        highlight = { enable = true },
                        indent = { enable = true },
                        incremental_selection = { enable = true },
                        playground = { enable = true },
                    },
                },

                {
                    "nvim-treesitter/nvim-treesitter-context",
                    dependencies = { "nvim-treesitter/nvim-treesitter" },
                    opts = {
                        -- optional config here
                        max_lines = 1, -- how many lines of context to show
                        enable = true,
                    },
                },
                -- Debugging (DAP)
                { "rcarriga/nvim-dap-ui", dependencies = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio"} },
                {
                    "jay-babu/mason-nvim-dap.nvim",
                    dependencies = "mason.nvim",
                    cmd = { "DapInstall", "DapUninstall" },
                    opts = {
                        -- Makes a best effort to setup the various debuggers with
                        -- reasonable debug configurations
                        automatic_installation = true,

                        -- You can provide additional configuration to the handlers,
                        -- see mason-nvim-dap README for more information
                        handlers = {},

                        -- You'll need to check that you have the required things installed
                        -- online, please don't ask me how to install them :)
                        ensure_installed = {
                            -- Update this to ensure that you have the debuggers for the langs you want
                        },
                    },
                    -- mason-nvim-dap is loaded when nvim-dap loads
                    config = function() end,
                },
                {
                    "mfussenegger/nvim-dap",
                    recommended = true,
                    desc = "Debugging support. Requires language specific adapters to be configured. (see lang extras)",

                    dependencies = {
                        "rcarriga/nvim-dap-ui",
                        -- virtual text for the debugger
                        {
                            "theHamsta/nvim-dap-virtual-text",
                            opts = {},
                        },
                    },

                    -- stylua: ignore
                    keys = {
                        { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
                        { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
                        { "<leader>dc", function() require("dap").continue() end, desc = "Run/Continue" },
                        { "<leader>da", function() require("dap").continue({ before = get_args }) end, desc = "Run with Args" },
                        { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
                        { "<leader>dg", function() require("dap").goto_() end, desc = "Go to Line (No Execute)" },
                        { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
                        { "<leader>dj", function() require("dap").down() end, desc = "Down" },
                        { "<leader>dk", function() require("dap").up() end, desc = "Up" },
                        { "<leader>dl", function() require("dap").run_last() end, desc = "Run Last" },
                        { "<leader>do", function() require("dap").step_out() end, desc = "Step Out" },
                        { "<leader>dO", function() require("dap").step_over() end, desc = "Step Over" },
                        { "<leader>dP", function() require("dap").pause() end, desc = "Pause" },
                        { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
                        { "<leader>ds", function() require("dap").session() end, desc = "Session" },
                        { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
                        { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
                    },

                    config = function()
                        -- Load mason-nvim-dap if it's present in lazy.nvim's plugin list
                        local plugins = require("lazy.core.config").plugins
                        local plugin_def = plugins["mason-nvim-dap.nvim"]

                        if plugin_def then
                            local util = require("lazy.core.util")
                            local opts = plugin_def.opts or (type(plugin_def.config) == "function" and plugin_def.config() or {})
                            require("mason-nvim-dap").setup(opts)
                        end
                        vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })
                    end
                },
                -- Telescope
                {
                    "nvim-telescope/telescope.nvim",
                    cmd = "Telescope",
                    dependencies = {
                        "nvim-lua/plenary.nvim",
                        "nvim-telescope/telescope-fzf-native.nvim",
                    },
                    build = "make",
                    opts = {
                        defaults = {
                            file_ignore_patterns = {
                                ".git/",
                                "node_modules/",
                                "%.lock",
                                "__pycache__/",
                                "%.sqlite3",
                                "%.ipynb",
                                "vendor/",
                            },
                            vimgrep_arguments = {
                                "rg",
                                "--color=never",
                                "--no-heading",
                                "--with-filename",
                                "--line-number",
                                "--column",
                                "--smart-case",
                                "--hidden",
                                "--glob=!.git/",
                            },
                            mappings = {
                                i = {
                                    ["<C-u>"] = false,
                                    ["<C-d>"] = false,
                                },
                            },
                        },
                        pickers = {
                            find_files = {
                                hidden = true,
                            },
                            live_grep = {
                                additional_args = function()
                                    return { "--hidden" }
                                end,
                            },
                        },
                    },
                    config = function(_, opts)
                        require("telescope").setup(opts)
                        require("telescope").load_extension("fzf")
                    end,
                    keys = {
                        {
                            '<leader>fb',
                            function() require("telescope.builtin").buffers({}) end,
                            desc = "Find buffers",
                        },
                        {
                            '<leader>ff',
                            function() require("telescope.builtin").find_files({}) end,
                            desc = "Find files",
                        },
                        {
                            '<leader>fg',
                            function() require("telescope.builtin").live_grep({}) end,
                            desc = "Live grep (ripgrep)",
                        },
                        {
                            '<leader>fw',
                            function() require("telescope.builtin").grep_string({}) end,
                            desc = "Grep word under cursor",
                        },
                        {
                            '<leader>fi',
                            function()
                                require("telescope.builtin").live_grep({
                                    prompt_title = "Search Imports",
                                    default_text = "import ",
                                })
                            end,
                            desc = "Search imports",
                        },
                        {
                            '<leader>fc',
                            function()
                                require("telescope.builtin").live_grep({
                                    prompt_title = "Search Classes/Functions",
                                    default_text = "(class |def |function |const |let |var )",
                                    type_filter = "regex",
                                })
                            end,
                            desc = "Search classes/functions",
                        },
                        {
                            '<leader>fh',
                            function() require("telescope.builtin").help_tags({}) end,
                            desc = "Find help",
                        },
                        {
                            '<leader>fr',
                            function() require("telescope.builtin").resume({}) end,
                            desc = "Resume last search",
                        },
                    }
                },
                {
                    "nvim-telescope/telescope-fzf-native.nvim",
                    build = "make",
                    cond = function()
                        return vim.fn.executable("make") == 1
                    end,
                },

                -- Git & UI
                { "lewis6991/gitsigns.nvim", event = { "BufReadPre", "BufNewFile" }, opts = {} },
                { "nvim-lualine/lualine.nvim", event = "VeryLazy", opts = {} },
                {
                    "lukas-reineke/indent-blankline.nvim",
                    main = "ibl",
                    event = { "BufReadPre", "BufNewFile" },
                    opts = {},
                },
                { "numToStr/Comment.nvim", opts = {} },
                { "folke/which-key.nvim", event = "VeryLazy", opts = {} },

                {"nvim-neotest/nvim-nio"},


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
        vim.opt.foldmethod = 'manual'
        vim.opt.foldlevelstart = 99
        vim.opt.wrap = false
        vim.opt.cmdheight = 1

        vim.opt.shiftwidth = 4
        vim.opt.softtabstop = 4
        vim.opt.tabstop = 4
        vim.opt.expandtab = true
        vim.opt.smarttab = true
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

        vim.keymap.set("n", "gd", vim.lsp.buf.definition)
        vim.keymap.set("n", "K", vim.lsp.buf.hover)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)

        vim.cmd 'colorscheme habamax'

        -- Autocommands
        -- Disable hover ruff 
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup('lsp_attach_disable_ruff_hover', { clear = true }),
            callback = function(args)
                local client = vim.lsp.get_client_by_id(args.data.client_id)
                if client == nil then
                    return
                end
                if client.name == 'ruff' then
                    -- Disable hover in favor of Pyright
                    client.server_capabilities.hoverProvider = false
                end
            end,
            desc = 'LSP: Disable hover capability from Ruff',
        })

        -- Load where you left off
        vim.api.nvim_create_autocmd("BufReadPost", {
            pattern = "*",
            command = 'silent! normal! g`"'
        })
