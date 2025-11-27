-- Automatically install lazy.nvim if not already installed
local install_path = vim.fn.stdpath('data') .. '/site/pack/lazy/start/lazy.nvim'
if not vim.loop.fs_stat(install_path) then
  vim.fn.system({
    'git', 'clone', '--depth', '1', 'https://github.com/folke/lazy.nvim',
    install_path
  })
  print("Installing lazy.nvim...")
  vim.cmd('packadd lazy.nvim')
end

-- Plugins Setup --------------------------------------------------------------
require('lazy').setup({
  -- UI Enhancements
  { "vim-airline/vim-airline" },
  { "vim-airline/vim-airline-themes" },

  -- Essential Utilities
  { "tpope/vim-sensible" },
  { "tpope/vim-surround" },
  { "tpope/vim-unimpaired" },
  { "tomtom/tcomment_vim" },
  { "terryma/vim-multiple-cursors" },

  -- Syntax and Code Quality
  { "honza/vim-snippets" },

  {
    'nvim-treesitter/nvim-treesitter',
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = { "javascript", "tsx", "typescript", "python" },
        highlight = { enable = true },
        indent = { enable = true }
      }
    end
  },
  {
    'prettier/vim-prettier',
    config = function()
      vim.g.prettier_exec_cmd_async = 1
    end
  },
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
    config = function()
      require('telescope').setup {
        defaults = {
          mappings = {
            i = { ['<esc>'] = require('telescope.actions').close },
            i = { ["<C-d>"] = require("telescope.actions").delete_buffer },
            n = { ["<C-d>"] = require("telescope.actions").delete_buffer },
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = 'smart_case',
          },
        },
        pickers = {
          buffers = {
            sort_mru = true,
            previewer = false,
            sorting_strategy = 'ascending',
          },
        },
      }
      pcall(require('telescope').load_extension, 'fzf')
    end,
  },
  { 'nvim-neotest/nvim-nio', },
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",  -- UI for breakpoints, watches, etc.
      "mfussenegger/nvim-dap-python",  -- Python adapter using debugpy
      "theHamsta/nvim-dap-virtual-text",  -- Inline variable values (add this line)
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- Virtual text setup for inline previews (appealing and non-intrusive)
      require("nvim-dap-virtual-text").setup({
        enabled = true,  -- Enable on debug start
        highlight_changed_variables = true,  -- Color changes
        virt_text_pos = "eol",  -- End of line
      })

      -- UI setup with custom layouts for appeal and ease
      dapui.setup({
        icons = { expanded = "▾", collapsed = "▸", current_frame = "→" },  -- Visual icons (requires font support)
        controls = {
          enabled = true,  -- Show control icons in UI
          element = "repl",  -- Attach controls to REPL
        },
        floating = {
          max_height = 0.9,  -- Limit float size for eval windows
          max_width = 0.9,
          border = "single",  -- Appealing border style
        },
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.4 },  -- Larger portion for scopes to handle long values
              { id = "stacks", size = 0.2 },
              { id = "watches", size = 0.2 },
              { id = "breakpoints", size = 0.2 },
            },
            position = "left",  -- Sidebar for structured info
            size = 40,  -- Width in columns (adjust based on your screen)
          },
          {
            elements = {
              { id = "repl", size = 0.5 },
              { id = "console", size = 0.5 },
            },
            position = "bottom",  -- Tray for interactive output
            size = 15,  -- Height in lines
          },
        },
        render = {
          expand_lines = false,  -- Key fix: Prevent auto-expansion of long values to avoid overlaps
          max_value_lines = 50,  -- Cap displayed lines per value when expanded
        },
      })

      -- Auto-open/close UI on debug events
      dap.listeners.before.attach["dapui_config"] = function() dapui.open() end
      dap.listeners.before.launch["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

      -- Your existing Python adapter and configs
      dap.adapters.python = {
        type = 'executable',
        command = 'python',
        args = { '-m', 'debugpy.adapter' },
      }
      dap.configurations.python = {
        {
          type = 'python',
          request = 'launch',
          name = 'Launch file',
          program = '${file}',
        },
      }
      require("dap-python").setup("python")  -- Assumes debugpy via mason/PATH

      -- Additional keymaps for ease (add to your existing ones)
      vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Toggle DAP UI" })
      vim.keymap.set("n", "<leader>de", dapui.eval, { desc = "Evaluate Expression" })  -- Floats at cursor
      vim.keymap.set("n", "<leader>df", function() dapui.float_element() end, { desc = "Float Element" })  -- Pick and float any element

      -- Auto-open/close UI on debug events
      dap.listeners.before.attach["dapui_config"] = function() dapui.open() end
      dap.listeners.before.launch["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

      dap.adapters.python = {
        type = 'executable',
        command = 'python',
        args = { '-m', 'debugpy.adapter' },
      }
      dap.configurations.python = {
        {
          type = 'python',
          request = 'launch',
          name = 'Launch file',
          program = '${file}',
        },
      }

      -- Python setup (installs/uses debugpy automatically via mason if configured)
      require("dap-python").setup("python")  -- Assumes debugpy in PATH; see Step 2 for install

      -- Keymaps (customize as needed)
      -- TODO: I don't know why these binding won't work, the ones defined outside of the function works, would be better to get these work instead
      vim.keymap.set("n", "<leader>dd", dap.disconnect, { desc = "Disconnect from session" })
      vim.keymap.set("n", "<leader>dt", dap.terminate, { desc = "Terminate session" })
      vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
      vim.keymap.set("n", "<F9>", dap.continue, { desc = "Continue/Start Debug" })
      vim.keymap.set("n", "<F8>", dap.step_over, { desc = "Step Over" })
      vim.keymap.set("n", "<F7>", dap.step_into, { desc = "Step Into" })
      vim.keymap.set("n", "<S-F8>", dap.step_out, { desc = "Step Out" })
      vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "Open REPL" })
      vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Toggle DAP UI" })
      vim.keymap.set("n", "<leader>de", dapui.eval, { desc = "Evaluate Expression" })  -- Floats at cursor
      vim.keymap.set("n", "<leader>df", function() dapui.float_element() end, { desc = "Float Element" })  -- Pick and float any element
    end,
  },
  {
    "williamboman/mason.nvim",  -- Optional but recommended: Auto-installs debugpy
    config = function()
      require("mason").setup()
    end,
  },

  -- Themes and Colors
  { "flazz/vim-colorschemes" },

  -- Tmux Navigation
  { "christoomey/vim-tmux-navigator" },

  -- Other Helpful Tools
  { "inside/vim-search-pulse" },
  { "jmcantrell/vim-diffchanges" },
  { "sloria/vim-ped" },

  -- LSP Configuration and Plugins
  { "neovim/nvim-lspconfig" },

  -- Autocompletion Plugin
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },

  -- Added Plugins
  { "windwp/nvim-autopairs", event = "InsertEnter", config = true },
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
  { "stevearc/conform.nvim", config = function() require("conform").setup({ formatters_by_ft = { python = { "black" }, javascript = { "prettier" } } }) end },
  { "mfussenegger/nvim-lint", config = function() require("lint").linters_by_ft = { python = { "pylint" } } vim.api.nvim_create_autocmd({ "BufWritePost" }, { callback = function() require("lint").try_lint() end }) end },
  { "folke/trouble.nvim", config = function() require("trouble").setup() end },
  { "zbirenbaum/copilot.lua", cmd = "Copilot", event = "InsertEnter", config = function() require("copilot").setup({ suggestion = { enabled = true, auto_trigger = true } }) end },
  { "akinsho/toggleterm.nvim", config = true },
})

-- Keybindings Leader ---------------------------------------------------------
vim.g.mapleader = ";"

-- Debugging Keybindings
vim.api.nvim_set_keymap('n', '<leader>dd', ":lua require('dap').disconnect()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>dt', ":lua require('dap').terminate()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>db', ":lua require('dap').toggle_breakpoint()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<F9>', ":lua require('dap').continue()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<F8>', ":lua require('dap').step_over()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<F7>', ":lua require('dap').step_into()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<S-F8>', ":lua require('dap').step_out()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>dr", ":lua require('dap').repl.open()<CR>", { desc = "Open REPL" })
vim.api.nvim_set_keymap("n", "<leader>du", ":lua require('dapui').toggle()<CR>", { desc = "Toggle DAP UI" })
vim.api.nvim_set_keymap("n", "<leader>de", ":lua require('dapui').eval()<CR>", { desc = "Evaluate Expression" })  -- Floats at cursor
vim.api.nvim_set_keymap("n", "<leader>df", ":lua require('dapui').float_element()<CR>", { desc = "Float Element" })  -- Pick and float any element

-- Telescope keymaps
vim.keymap.set('n', '<leader>ff',
  function()
    -- Get the Git root; falls back to current cwd if not in a Git repo
    local git_root = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
    if vim.v.shell_error ~= 0 then
      git_root = vim.fn.getcwd()  -- Use current working dir as fallback
    end
    require('telescope.builtin').find_files({ cwd = git_root })
  end, { desc = '[F]ind [F]iles in Git Repo' }
)
vim.keymap.set('n', '<leader>fg', require('telescope.builtin').live_grep, { desc = '[F]ind by [G]rep' })
vim.keymap.set('n', '<leader>fb', require('telescope.builtin').buffers, { desc = '[F]ind [B]uffers' })
vim.keymap.set('n', '<leader>fh', require('telescope.builtin').oldfiles, { desc = '[F]ind [H]istory' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').lsp_document_symbols, { desc = '[S]earch [F]unctions/Symbols' })

-- Added Keymaps
vim.keymap.set("n", "<leader>=", function() require("conform").format({ async = true }) end, { desc = "Format buffer" })
vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Toggle Trouble (Diagnostics)" })
vim.keymap.set("n", "<leader>t", "<cmd>ToggleTerm<cr>", { desc = "Toggle Terminal" })

-- LSP Configuration ----------------------------------------------------------

local cmp = require('cmp')
cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
    ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    ['<C-y>'] = cmp.config.disable,
    ['<C-e>'] = cmp.mapping({
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    }),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
    { name = 'buffer' },
  })
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Customize pyright config
vim.lsp.config('pyright', {
  capabilities = capabilities,
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "workspace",
      },
    },
  },
  on_attach = function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
  end,
})

-- Enable the pyright server (it will auto-attach on relevant filetypes)
vim.lsp.enable('pyright')

-- LSP Keybindings
vim.api.nvim_set_keymap('n', 'gd', ':lua vim.lsp.buf.definition()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'gt', ':lua vim.lsp.buf.type_definition()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'K', ':lua vim.lsp.buf.hover()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>rn', ':lua vim.lsp.buf.rename()<CR>', { noremap = true, silent = true })

-- Functions ------------------------------------------------------------------
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end,
})

local function wrap_toggle()
  if vim.wo.wrap then
    print("Wrap OFF")
    vim.wo.wrap = false
    vim.wo.virtualedit = 'all'
    vim.api.nvim_buf_del_keymap(0, 'n', '<Up>')
    vim.api.nvim_buf_del_keymap(0, 'n', '<Down>')
    vim.api.nvim_buf_del_keymap(0, 'n', '<Home>')
    vim.api.nvim_buf_del_keymap(0, 'n', '<End>')
    vim.api.nvim_buf_del_keymap(0, 'i', '<Up>')
    vim.api.nvim_buf_del_keymap(0, 'i', '<Down>')
    vim.api.nvim_buf_del_keymap(0, 'i', '<Home>')
    vim.api.nvim_buf_del_keymap(0, 'i', '<End>')
  else
    print("Wrap ON")
    vim.wo.wrap = true
    vim.wo.linebreak = true
    vim.wo.list = false
    vim.wo.virtualedit = ''
    vim.wo.display = vim.wo.display .. ',lastline'
    vim.api.nvim_buf_set_keymap(0, 'n', '0', 'g0', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, 'n', 'k', 'gk', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, 'n', 'j', 'gj', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, 'n', '$', 'g$', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, 'n', '<Up>', 'gk', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, 'n', '<Down>', 'gj', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, 'n', '<Home>', 'g<Home>', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, 'n', '<End>', 'g<End>', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, 'i', '<Up>', '<C-o>gk', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, 'i', '<Down>', '<C-o>gj', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, 'i', '<Home>', '<C-o>g<Home>', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, 'i', '<End>', '<C-o>g<End>', { noremap = true, silent = true })
  end
end

vim.api.nvim_create_user_command('WrapToggle', wrap_toggle, {})

local function paste_toggle()
  if vim.opt.paste:get() then
    print("Paste OFF")
    vim.opt.paste = false
  else
    print("Paste ON")
    vim.opt.paste = true
  end
end

vim.api.nvim_create_user_command('PasteToggle', paste_toggle, { nargs = 0 })
vim.api.nvim_set_keymap('n', '<leader>e', ':PasteToggle<CR>', { noremap = true, silent = true })

vim.api.nvim_create_autocmd("VimLeave", {
  callback = function()
    if vim.v.this_session ~= "" then
      vim.cmd("mksession! " .. vim.v.this_session)
    end
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'python',
  callback = function()
    vim.api.nvim_buf_create_user_command(0, 'Breakpoint',
      function()
        local line = vim.fn.line('.')
        vim.api.nvim_buf_set_lines(0, line, line, false, {'import pudb; pu.db; # XXX Breakpoint'})
      end, { desc = 'Insert pudb breakpoint' }
    )
    vim.keymap.set('n', '<leader>B', ':Breakpoint<CR>', { buffer = true, noremap = true, silent = true, desc = 'Insert pudb breakpoint' })
  end,
})


-- General Settings -----------------------------------------------------------
-- Ensure ~/.nvim/tmp exists for temporary files with proper expansion
local tmp_dir = vim.fn.expand("~/.nvim/tmp")
if not vim.fn.isdirectory(tmp_dir) then
  vim.fn.mkdir(tmp_dir, "p")
end

vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.encoding = "utf-8"
vim.cmd([[syntax on]])
vim.g.c_comment_strings = 1
vim.opt.hlsearch = true
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("data") .. "/undo"
vim.opt.lazyredraw = true
vim.cmd([[syntax sync minlines=200]])

if vim.env.TERM and (vim.env.TERM:match("^xterm") or vim.env.TERM:match("rxvt")) then
  vim.cmd([[let &t_SI = "\<Esc>[6 q"]])
  vim.cmd([[let &t_SR = "\<Esc>[4 q"]])
  vim.cmd([[let &t_EI = "\<Esc>[2 q"]])
end

vim.opt.shell = "/bin/zsh"
vim.opt.magic = true
vim.opt.confirm = true
vim.opt.backspace = { "indent", "eol", "start" }
vim.opt.backupdir = tmp_dir .. "//" -- Use expanded path
vim.opt.directory:prepend(tmp_dir .. "//") -- Use expanded path
vim.opt.history = 200
vim.opt.ruler = true
vim.opt.showcmd = true
vim.opt.wildmenu = true
vim.opt.ttimeout = true
vim.opt.ttimeoutlen = 100
vim.opt.scrolloff = 5
vim.opt.visualbell = true
vim.opt.vb = false
vim.opt.wrap = false
vim.opt.paste = false
vim.opt.linebreak = true
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.list = false
vim.opt.textwidth = 0
vim.opt.wrapmargin = 0
vim.opt.formatoptions = vim.opt.formatoptions - { "t" } + { "l" }
vim.opt.autoread = true
vim.opt.autochdir = true
vim.opt.tags = { "./.tags", vim.fn.expand("~/.tags") } -- Use expanded path
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.hidden = true
vim.opt.swapfile = false
vim.opt.ignorecase = true
vim.opt.listchars = { tab = "|_", trail = "·", extends = "»", precedes = "«", nbsp = "×" }

vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
    vim.opt_local.autoindent = true
    vim.opt_local.smartindent = false
    vim.opt_local.cindent = false
  end,
})

-- Theme Settings -------------------------------------------------------------
vim.g.molokai_original = 1
vim.g.rehash256 = 1
vim.cmd('colorscheme molokai')
vim.g.airline_theme = 'molokai'
vim.opt.colorcolumn = "80"
vim.cmd("highlight ColorColumn ctermbg=235 guibg=#5e5e5e")
vim.cmd("highlight MolokaiColorColumn guibg=#5e5e5e ctermbg=235")
vim.cmd([[highlight Normal ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE]])
vim.cmd([[highlight VertSplit ctermfg=240 ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE]])
vim.cmd([[highlight ErrorMsg ctermfg=199 ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE]])
vim.cmd([[highlight Search ctermfg=7 ctermbg=88 cterm=NONE guifg=NONE guibg=NONE gui=NONE]])
vim.opt.fillchars:append({ vert = "|" })

-- Visual Mode Mappings
vim.api.nvim_set_keymap('v', '(', '"pc()<Esc>"pP', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '[', '"pc[]<Esc>"pP', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '{', '"pc{}<Esc>"pP', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', "'", '"pc\'\'<Esc>"pP', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '_', '"pc__<Esc>"pP', { noremap = true, silent = true })

-- Keybindings ----------------------------------------------------------------
vim.api.nvim_set_keymap('n', '<leader>a', 'ggVG', { noremap = true, silent = true })
vim.keymap.set('n', '<S-k>', '<C-y>k', { noremap = true })
vim.keymap.set('n', '<S-j>', '<C-e>j', { noremap = true })
vim.keymap.set('v', '<leader>j', ':join<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', 'Q', 'gq', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '*', '*<C-o>:%s///gn<CR>``', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-h>', '<C-w>h', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-j>', '<C-w>j', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-k>', '<C-w>k', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-l>', '<C-w>l', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-Up>', ':resize +2<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-Down>', ':resize -2<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-Left>', ':vertical resize -2<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-Right>', ':vertical resize +2<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>w', ':w<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>q', ':q<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>wq', ':wq<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>qq', ':qa!<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader><leader>', '<C-^>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'o', 'o<ESC>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'O', 'O<ESC>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>c', ':noh<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<Leader>w', ':WrapToggle<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<S-H>', '0', { noremap = true, silent = true })
vim.keymap.set('n', '<S-L>', '$', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>n', ':setlocal number!<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>j', ':join<CR>', { noremap = true, silent = true })

-- DAP Configuration ----------------------------------------------------------
local dap = require('dap')
dap.adapters.python = {
  type = 'server',
  host = '127.0.0.1',
  port = 5678,
}
dap.configurations.python = {
  {
    type = 'python',
    request = 'attach',
    name = 'Attach to FastAPI',
    justMyCode = false,
  },
}
--- dap.adapters.python = {
---   type = 'executable',
---   command = '/home/faham/dev/psychon/webserver/.venv/bin/python',  -- Ensure this points to the correct Python executable
---   args = { '-m', 'debugpy.adapter' },
--- }
--- dap.configurations.python = {
---   {
---     type = 'python',
---     request = 'launch',  -- This should be 'launch' for running test.py directly
---     name = 'Launch file',
---     program = '${file}',  -- Automatically uses the current file
---   },
--- }
