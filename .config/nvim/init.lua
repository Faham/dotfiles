
-- Automatically install lazy.nvim if not already installed
local install_path = vim.fn.stdpath('data')..'/site/pack/lazy/start/lazy.nvim'
if not vim.loop.fs_stat(install_path) then
  -- lazy.nvim is not installed, so clone it
  vim.fn.system({
    'git', 'clone', '--depth', '1', 'https://github.com/folke/lazy.nvim',
    install_path
  })
  print("Installing lazy.nvim...") -- Let the user know lazy.nvim is being installed
  -- Refresh the plugins
  vim.cmd('packadd lazy.nvim')
end

-- Plugins Setup --------------------------------------------------------------

-- Load lazy.nvim after installation
require('lazy').setup({
  -- -- UI Enhancements
  { "vim-airline/vim-airline" }, -- Status line
  { "vim-airline/vim-airline-themes" },
  
  -- Code Navigation and Management
  { "majutsushi/tagbar" },
  { "jlanzarotta/bufexplorer" },
  { "jremmen/vim-ripgrep" },
  { "junegunn/fzf" },
  { "junegunn/fzf.vim" },

  -- Essential Utilities
  { "tpope/vim-sensible" },
  { "tpope/vim-surround" },
  { "tpope/vim-unimpaired" },
  { "tomtom/tcomment_vim" },
  { "terryma/vim-multiple-cursors" },
  
  -- Syntax and Code Quality
  { "pangloss/vim-javascript" },
  { "mxw/vim-jsx" },
  { "w0rp/ale" },
  { "wgwoods/vim-systemd-syntax" },
  { "honza/vim-snippets" },
  { "dylon/vim-antlr" },
  { "leafgarland/typescript-vim" },
  
  {
    'nvim-treesitter/nvim-treesitter', -- Better syntax parsing and highlighting for TypeScript.
    config = function()
      require'nvim-treesitter.configs'.setup {
        ensure_installed = { "typescript" },  -- Make sure TypeScript is installed for Treesitter
        highlight = { enable = true }
      }
    end
  },
  {
    'prettier/vim-prettier', -- Automatically formats TypeScript code using Prettier.
    config = function()
      vim.g.prettier_exec_cmd_async = 1  -- Format asynchronously
    end
  },
  {
    'nvim-telescope/telescope.nvim', -- Fuzzy finding tools for navigating your TypeScript code.
    config = function()
      require('telescope').setup()
    end
  },
  {
    'mfussenegger/nvim-dap', -- Debugger integration for Python projects.
    config = function()
      local dap = require('dap')
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
    end
  },
  { "rcarriga/nvim-dap-ui",
    config = function()
      local dapui = require('dapui')
      dapui.setup()

      -- Automatically open/close the UI when debugging starts/stops
      dap.listeners.after.event_initialized['dapui_config'] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated['dapui_config'] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited['dapui_config'] = function()
        dapui.close()
      end
    end
  },

  -- Themes and Colors
  { "flazz/vim-colorschemes" },
  
  -- Neovim-Specific Plugins
  { "Shougo/deoplete.nvim", build = ":UpdateRemotePlugins" },
  
  -- Tmux Navigation
  { "christoomey/vim-tmux-navigator" },
  
  -- Other Helpful Tools
  { "inside/vim-search-pulse" },
  { "jmcantrell/vim-diffchanges" },
  { "sloria/vim-ped" },
  
  -- LSP Configuration and LSP plugins
  { "neovim/nvim-lspconfig" },
  {
    'neoclide/coc.nvim',
    branch = 'release',
    run = function()
      -- Automatically install dependencies when coc.nvim is installed
      local coc_dir = vim.fn.stdpath('data') .. '/site/pack/lazy/start/coc.nvim'
      if vim.fn.isdirectory(coc_dir) == 1 then
	vim.fn.system({'npm', 'ci'}, coc_dir)  -- Install dependencies
	vim.fn.system({'npm', 'run', 'build'}, coc_dir)  -- Compile coc.nvim

        -- Install coc-tsserver and coc-eslint extensions
        vim.fn.system({'npm', 'install', '-g', 'coc-tsserver'}, coc_dir)
        vim.fn.system({'npm', 'install', '-g', 'coc-eslint'}, coc_dir)

        print('coc.nvim, coc-tsserver, and coc-eslint dependencies installed successfully!')
      end
    end
  },
 
  -- Autocompletion plugin
  { "hrsh7th/nvim-cmp" },
  { 'hrsh7th/cmp-nvim-lsp' },
})


-- LSP configuration for Python (Pyright)
require'lspconfig'.pyright.setup{}

local cmp = require('cmp')

cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body) -- Use a snippet plugin if needed
    end,
  },
  mapping = {
    ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
    ['<C-e>'] = cmp.mapping({
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    }),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' }, -- LSP completions
    { name = 'vsnip' }, -- Snippet completions (if using vsnip)
    { name = 'buffer' }, -- Buffer completions
  })
})

-- Use LSP as the default source for autocompletion
local capabilities = require('cmp_nvim_lsp').default_capabilities()
require('lspconfig').pyright.setup({
  capabilities = capabilities,
})

-- Functions ------------------------------------------------------------------

vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
        local save_cursor = vim.fn.getpos(".")
        vim.cmd([[%s/\s\+$//e]])
        vim.fn.setpos(".", save_cursor)
    end,
})

-- General Settings -----------------------------------------------------------

vim.opt.mouse = "a"                -- Enable mouse support
vim.opt.clipboard = "unnamedplus" -- Use system clipboard
vim.opt.encoding = "utf-8"         -- Set default encoding

-- Enable syntax highlighting
vim.cmd([[syntax on]])

-- Highlight strings inside C comments
vim.g.c_comment_strings = 1
vim.opt.hlsearch = true

-- Undo and backup settings
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("data") .. "/undo"

-- Optimize rendering
vim.opt.lazyredraw = true
vim.cmd([[syntax sync minlines=200]])

-- Cursor appearance in different modes
if vim.env.TERM and vim.env.TERM:match("^xterm") or vim.env.TERM:match("rxvt") then
  vim.cmd([[let &t_SI = "\<Esc>[6 q"]]) -- Cursor in insert mode
  vim.cmd([[let &t_SR = "\<Esc>[4 q"]]) -- Cursor in replace mode
  vim.cmd([[let &t_EI = "\<Esc>[2 q"]]) -- Cursor in normal mode
end

vim.opt.shell = "/bin/zsh"
vim.opt.magic = true -- Enable 'magic' for regex patterns
vim.opt.confirm = true -- Ask to save before exit if needed

-- Allow backspacing over everything in insert mode
vim.opt.backspace = { "indent", "eol", "start" }

-- Set backup directory
vim.opt.backupdir = "~/.vim/tmp//"

-- Set directory for swap files
vim.opt.directory:prepend("~/.vim/tmp//")

-- Keep 200 lines of command line history
vim.opt.history = 200

-- Show cursor position at all times
vim.opt.ruler = true

-- Display incomplete commands
vim.opt.showcmd = true

-- Display completion matches in a status line
vim.opt.wildmenu = true

-- Time out for key codes
vim.opt.ttimeout = true
vim.opt.ttimeoutlen = 100

-- Show a few lines of context around the cursor
vim.opt.scrolloff = 5

-- Disable beeps
vim.opt.visualbell = true
vim.opt.vb = false
-- vim.opt.t_vb = ""

-- Disable line wrapping
vim.opt.wrap = false

-- Set paste mode off (to avoid auto-indentation issues when pasting)
vim.opt.paste = false

-- Enable linebreaks
vim.opt.linebreak = true

-- Line numbering
vim.opt.number = true
-- Disable relative line numbers
vim.opt.relativenumber = false      

-- Disable list mode (show invisible characters like tabs)
vim.opt.list = false

-- Disable text wrapping
vim.opt.textwidth = 0
vim.opt.wrapmargin = 0

-- Modify formatoptions (remove 't', add 'l')
vim.opt.formatoptions = vim.opt.formatoptions - { "t" }
vim.opt.formatoptions = vim.opt.formatoptions + { "l" }

-- Auto reload unchanged files
vim.opt.autoread = true

-- Change the current working directory to the file's directory
vim.opt.autochdir = true

-- Set tag files for locating tags
vim.opt.tags = { "./.tags", "~/.tags" }

-- Set tab-related configurations
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true  -- Replace tab with space

vim.opt.smartindent = true

-- Allow switching between unsaved buffers
vim.opt.hidden = true

-- Disable swap files
vim.opt.swapfile = false

-- Case insensitive search by default
vim.opt.ignorecase = true

-- Configure 'listchars' for displaying special characters
vim.opt.listchars = {
  tab = "|_",
  trail = "·",
  extends = "»",
  precedes = "«",
  nbsp = "×"
}

-- Theme settings -------------------------------------------------------------

-- Set colorscheme and options
vim.g.molokai_original = 1
vim.g.rehash256 = 1
vim.cmd('colorscheme molokai')

vim.g.airline_theme = 'molokai'

-- Set 80-column ruler
vim.opt.colorcolumn = "80"
vim.cmd("highlight ColorColumn ctermbg=235 guibg=#5e5e5e")  -- Subtle dark gray color
-- Explicitly change the highlight for ColorColumn
vim.cmd("highlight MolokaiColorColumn guibg=#5e5e5e ctermbg=235")  -- Set a subtle gray background


-- Remove specific default coloring to fall back to terminal default colors
vim.cmd([[highlight Normal ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE]])

-- Configure vertical split bar colors
vim.cmd([[highlight VertSplit ctermfg=240 ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE]])

-- Configure error message highlight colors
vim.cmd([[highlight ErrorMsg ctermfg=199 ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE]])

-- Configure search highlight colors
vim.cmd([[highlight Search ctermfg=7 ctermbg=88 cterm=NONE guifg=NONE guibg=NONE gui=NONE]])

-- Set vertical split bar character to "|"
vim.opt.fillchars:append({ vert = "|" })

-- Remap p, [, {, ', _ with "pc" and paste
vim.api.nvim_set_keymap('v', '(', '"pc()<Esc>"pP', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '[', '"pc[]<Esc>"pP', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '{', '"pc{}<Esc>"pP', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', "'", '"pc\'\'<Esc>"pP', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '_', '"pc__<Esc>"pP', { noremap = true, silent = true })

-- Functions ------------------------------------------------------------------

local function wrap_toggle()
  -- Check if wrap is enabled
  if vim.wo.wrap then
    -- Wrap OFF
    print("Wrap OFF")
    vim.wo.wrap = false
    vim.wo.virtualedit = 'all'

    -- Unmap the keys in normal and insert mode
    vim.api.nvim_buf_del_keymap(0, 'n', '<Up>')
    vim.api.nvim_buf_del_keymap(0, 'n', '<Down>')
    vim.api.nvim_buf_del_keymap(0, 'n', '<Home>')
    vim.api.nvim_buf_del_keymap(0, 'n', '<End>')
    vim.api.nvim_buf_del_keymap(0, 'i', '<Up>')
    vim.api.nvim_buf_del_keymap(0, 'i', '<Down>')
    vim.api.nvim_buf_del_keymap(0, 'i', '<Home>')
    vim.api.nvim_buf_del_keymap(0, 'i', '<End>')
  else
    -- Wrap ON
    print("Wrap ON")
    vim.wo.wrap = true
    vim.wo.linebreak = true
    vim.wo.list = false
    vim.wo.virtualedit = ''
    vim.wo.display = vim.wo.display .. ',lastline'

    -- Set key mappings for normal mode
    vim.api.nvim_buf_set_keymap(0, 'n', '0', 'g0', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, 'n', 'k', 'gk', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, 'n', 'j', 'gj', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, 'n', '$', 'g$', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, 'n', '<Up>', 'gk', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, 'n', '<Down>', 'gj', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, 'n', '<Home>', 'g<Home>', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, 'n', '<End>', 'g<End>', { noremap = true, silent = true })

    -- Set key mappings for insert mode
    vim.api.nvim_buf_set_keymap(0, 'i', '<Up>', '<C-o>gk', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, 'i', '<Down>', '<C-o>gj', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, 'i', '<Home>', '<C-o>g<Home>', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, 'i', '<End>', '<C-o>g<End>', { noremap = true, silent = true })
  end
end

vim.api.nvim_create_user_command('WrapToggle', wrap_toggle, {})

-- Keybindings -----------------------------------------------------------------

vim.g.mapleader = ";"

-- scrolling with arrow keys as well
vim.keymap.set('n', '<S-k>', '<C-y>k', { noremap = true })
vim.keymap.set('n', '<S-j>', '<C-e>j', { noremap = true })

vim.keymap.set('v', '<leader>j', ':join<CR>', { noremap = true })

-- Don't use Ex mode, use Q for formatting
vim.api.nvim_set_keymap('n', 'Q', 'gq', { noremap = true, silent = true })

-- Search and replace mappings
vim.api.nvim_set_keymap('n', '*', '*<C-o>:%s///gn<CR>``', { noremap = true, silent = true })

-- Use Ctlr hjkl to move between split windows
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

vim.api.nvim_set_keymap('n', '<leader>bb', ':BufExplorer<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>bn', ':bnext<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>bp', ':bprev<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>bd', ':bdelete<CR>', { noremap = true, silent = true })

-- Go to last buffer
vim.api.nvim_set_keymap('n', '<leader><leader>', '<C-^>', { noremap = true, silent = true })

-- fzf operations
vim.api.nvim_set_keymap('n', '<leader>ff', ':Files<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>fr', ':History<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>fb', ':Buffers<CR>', { noremap = true, silent = true })

-- LSP (Language Server Protocol) bindings
vim.api.nvim_set_keymap('n', 'gd', ':lua vim.lsp.buf.definition()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'gt', ':lua vim.lsp.buf.type_definition()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'K', ':lua vim.lsp.buf.hover()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>rn', ':lua vim.lsp.buf.rename()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>e', ':lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', { noremap = true, silent = true })

-- Enter neww line above/below
vim.api.nvim_set_keymap('n', 'o', 'o<ESC>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'O', 'O<ESC>', { noremap = true, silent = true })


-- clear search highlightings when done
vim.api.nvim_set_keymap('n', '<leader>c', ':noh<CR>', { noremap = true, silent = true })

vim.keymap.set('n', '<Leader>w', ':WrapToggle<CR>', { noremap = true, silent = true })

-- Go to the beginning of the current line with Shift+H
vim.keymap.set('n', '<S-H>', '0', { noremap = true, silent = true })

-- Go to the end of the current line with Shift+L
vim.keymap.set('n', '<S-L>', '$', { noremap = true, silent = true })

-- Toggle line number
vim.api.nvim_set_keymap('n', '<leader>n', ':setlocal number!<CR>', { noremap = true, silent = true })

-- Join lines
vim.api.nvim_set_keymap('n', '<leader>j', ':join<CR>', { noremap = true, silent = true })

-- -------------------------------------------------------------------------------------------
-- -- Custom quickfix and folding mappings
-- vim.api.nvim_set_keymap('n', '<leader>q', ':call quickfixToggle()<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>F', ':call foldColumnToggle()<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>D', ':DiffChangesDiffToggle<CR>', { noremap = true, silent = true })
--
-- -- Move to beginning and end of the line
-- vim.api.nvim_set_keymap('n', 'H', '0', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', 'L', '$', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('v', 'H', '0', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('v', 'L', '$', { noremap = true, silent = true })
--
--
-- -- Prevent vim from cleaning up indentations on escape
-- vim.api.nvim_set_keymap('i', '<CR>', '<CR>x<BS>', { noremap = true, silent = true })
--
-- -- Enable Caps using F5
-- vim.api.nvim_set_keymap('n', '<F5>', ':let &l:imi = !&l:imi<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('i', '<F5>', '<C-O>:let &l:imi = !&l:imi<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('c', '<F5>', '<C-^>', { noremap = true, silent = true })
--
-- -- Avoid the first jump while search-n-highlight
-- vim.api.nvim_set_keymap('n', '*', ':keepjumps normal! mi*`i<CR>', { noremap = true, silent = true })
--
-- -- Update tags
-- vim.api.nvim_set_keymap('n', '<F7>', ':UpdateTags<CR>', { noremap = true, silent = true })
--
-- -- Search for selected text, forwards or backwards
-- vim.api.nvim_set_keymap('v', '*', ':<C-U>let old_reg=getreg(\'"\')<Bar>let old_regtype=getregtype(\'"\')<CR>gvy/<C-R><C-R>=substitute(escape(@", \'/\\.*$^~[\'), \'\\_s\\+\', \'\\\\_s\\\\+\', \'g\')<CR><CR>gV:call setreg(\'"\', old_reg, old_regtype)<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('v', '#', ':<C-U>let old_reg=getreg(\'"\')<Bar>let old_regtype=getregtype(\'"\')<CR>gvy?<C-R><C-R>=substitute(escape(@", \'?\\.*$^~[\'), \'\\_s\\+\', \'\\\\_s\\\\+\', \'g\')<CR><CR>gV:call setreg(\'"\', old_reg, old_regtype)<CR>', { noremap = true, silent = true })
--
-- -- Toggle ALE (Asynchronous Lint Engine)
-- vim.api.nvim_set_keymap('n', '<leader>l', ':ALEToggle<CR>', { noremap = true, silent = true })
--
-- -- Rg (ripgrep) search mappings
-- vim.api.nvim_set_keymap('n', '<leader>g', ':execute \'Rg \' . expand(\'<cword>\') . \' %\'<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>G', ':execute \'Rg \' . expand(\'<cword>\')<CR>', { noremap = true, silent = true })
--
-- -- Git files and tags mappings
-- vim.api.nvim_set_keymap('n', '<leader>p', ':GFiles<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>o', ':BTags<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>i', ':Tags<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>u', ':Commands<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>h', ':History<CR>', { noremap = true, silent = true })
--
-- -- Save with Ctrl+S
-- -- vim.api.nvim_set_keymap('n', '<C-S>', '<C-a>', { noremap = true, silent = true })

