
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
    'nvim-treesitter/nvim-treesitter',
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = { "typescript", "python" },
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
    config = function()
      require('telescope').setup()
    end
  },
  {
    'mfussenegger/nvim-dap',
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
  { 'nvim-neotest/nvim-nio', },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { 'nvim-neotest/nvim-nio' },
    config = function()
      local dapui = require('dapui')
      dapui.setup()
      local dap = require('dap')
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
})

-- Keybindings Leader ---------------------------------------------------------
vim.g.mapleader = ";"

-- Keybindings for Plugins ----------------------------------------------------
vim.api.nvim_set_keymap('n', '<leader>b', ':BufExplorer<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>f', ':Files<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>h', ':History<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>o', ':BTags<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>i', ':Tags<CR>', { noremap = true, silent = true })

-- Debugging Keybindings
vim.api.nvim_set_keymap('n', '<F9>', ":lua require('dap').continue()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-F8>', ":lua require('dap').toggle_breakpoint()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<F8>', ":lua require('dap').step_over()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<F7>', ":lua require('dap').step_into()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<S-F8>', ":lua require('dap').step_out()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-F2>', ":lua require('dap').terminate()<CR>", { noremap = true, silent = true })

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
require('lspconfig').pyright.setup({
  capabilities = capabilities,
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "workspace", -- Can be "openFilesOnly" for smaller projects
      },
    },
  },
  on_attach = function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false -- Let Neovim handle indent
  end,
})

-- LSP Keybindings
vim.api.nvim_set_keymap('n', 'gd', ':lua vim.lsp.buf.definition()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'gt', ':lua vim.lsp.buf.type_definition()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'K', ':lua vim.lsp.buf.hover()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>rn', ':lua vim.lsp.buf.rename()<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>e', ':lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', { noremap = true, silent = true })

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

-- Define the paste toggle function
local function paste_toggle()
  if vim.opt.paste:get() then
    print("Paste OFF")              -- Or use vim.notify("Paste OFF")
    vim.opt.paste = false           -- Disable paste mode
  else
    print("Paste ON")               -- Or use vim.notify("Paste ON")
    vim.opt.paste = true            -- Enable paste mode
  end
end

vim.api.nvim_create_user_command('PasteToggle', paste_toggle, { nargs = 0 })
vim.api.nvim_set_keymap('n', '<leader>e', ':PasteToggle<CR>', { noremap = true, silent = true })

-- General Settings -----------------------------------------------------------
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
vim.opt.backupdir = "~/.nvim/tmp//"
vim.opt.directory:prepend("~/.nvim/tmp//")
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
vim.opt.tags = { "./.tags", "~/.tags" }
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

-- ----------------------------------------------------------------------------

local dap = require('dap')
-- dap.adapters.python = {
--   type = 'executable',
--   command = '/home/faham/dev/psychon/webserver/.venv/bin/python',  -- Ensure this points to the correct Python executable
--   args = { '-m', 'debugpy.adapter' },
-- }
-- dap.configurations.python = {
--   {
--     type = 'python',
--     request = 'launch',  -- This should be 'launch' for running test.py directly
--     name = 'Launch file',
--     program = '${file}',  -- Automatically uses the current file
--   },
-- }
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
    justMyCode = false,  -- Set to true to debug only your code, excluding libraries
  },
}


dap.listeners.after.event_initialized['dapui_config'] = function()
  require('dapui').open()
end
dap.listeners.before.event_terminated['dapui_config'] = function()
  require('dapui').close()
end
dap.listeners.before.event_exited['dapui_config'] = function()
  require('dapui').close()
end

-- ----------------------------------------------------------------------------

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

