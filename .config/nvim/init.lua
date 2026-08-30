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

-- local funcitons ------------------------------------------------------------
local function normalize_path(path)
  return path:gsub("\\", "/")
end

local function normalize_cwd()
  return normalize_path(vim.loop.cwd()) .. "/"
end

local function is_subdirectory(cwd, path)
  return string.lower(path:sub(1, #cwd)) == string.lower(cwd)
end

local function split_filepath(path)
  local normalized_path = normalize_path(path)
  local normalized_cwd = normalize_cwd()
  local filename = normalized_path:match("[^/]+$")

  if is_subdirectory(normalized_cwd, normalized_path) then
    local stripped_path = normalized_path:sub(#normalized_cwd + 1, -(#filename + 1))
    return stripped_path, filename
  else
    local stripped_path = normalized_path:sub(1, -(#filename + 1))
    return stripped_path, filename
  end
end

local function path_display(_, path)
  local stripped_path, filename = split_filepath(path)
  if filename == stripped_path or stripped_path == "" then
    return filename
  end
  return string.format("%s ~ %s", filename, stripped_path)
end

local function get_git_root()
  local git_root = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 then
    return vim.fn.getcwd()  -- Fallback to cwd
  end
  return git_root
end

local function get_visual_selection()
  vim.cmd('noau normal! "vy"')
  local text = vim.fn.getreg('v')
  vim.fn.setreg('v', {})

  text = string.gsub(text, "\n", "")
  if #text > 0 then
    return text
  else
    return ''
  end
end

-- Plugins Setup --------------------------------------------------------------
require('lazy').setup({
  -- UI Enhancements
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup({
        options = {
          theme = "molokai",
          globalstatus = true  -- Force global statusline to avoid per-window inactive states
        },
        sections = {
          lualine_c = {  -- Customize the center section
            function()  -- Custom component: Returns formatted path string
              local buf_path = vim.api.nvim_buf_get_name(0)  -- Full path of current buffer
              if buf_path == "" then
                return "[No Name]"  -- Handle unnamed buffers
              end

              local root = get_git_root()
              local relative_path = buf_path:sub(#root + 2)  -- +2 to skip the '/' after root
              if relative_path == "" then
                relative_path = vim.fn.fnamemodify(buf_path, ":t")  -- Just filename if at root
              end

              -- If not in Git, make relative to home (~)
              if vim.v.shell_error ~= 0 then
                relative_path = vim.fn.fnamemodify(buf_path, ":~:.")
              end

              -- Add file status indicators (modified, readonly, etc.)
              local symbols = ""
              if vim.bo.modified then symbols = symbols .. "[+]" end
              if vim.bo.readonly then symbols = symbols .. "[-]" end
              if not vim.bo.modifiable then symbols = symbols .. "[x]" end  -- Unmodifiable

              local display_path = relative_path .. symbols

              -- Truncate from left if too long
              local max_length = 50  -- Adjust to your preference (e.g., 40-60 chars)
              if #display_path > max_length then
                return "..." .. display_path:sub(#display_path - max_length + 4)
              end
              return display_path
            end,
          },
          -- Keep other sections as defaults
        },
      })
    end
  },
  -- Essential Utilities
  { "coder/claudecode.nvim", config = function()
      require("claudecode").setup({
        keymaps = {
          toggle = "<leader>cl",   -- ;cl to toggle panel
          send_selection = "<leader>cs",  -- ;cs to send selection
        }
      })
    end,
  },
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        open_mapping = [[<M-t>]],   -- Alt+t: toggle terminal (fits your Alt-nav scheme)
        direction = "float",         -- floating terminal; change to "vertical" if you prefer a split
        float_opts = {
          border = "curved",
          width = math.floor(vim.o.columns * 0.85),
          height = math.floor(vim.o.lines * 0.80),
        },
        shade_terminals = false,
        persist_mode = true,         -- stay in terminal mode when re-opening
        auto_scroll = true,
        on_open = function(_)
          vim.cmd("startinsert!")    -- jump straight into insert mode on open
        end,
      })

      -- Navigate OUT of the floating terminal to nvim splits/tmux panes
      -- using the same M-h/j/k/l you use everywhere else
      local function set_term_nav(key, cmd)
        vim.keymap.set('t', key, function()
          vim.cmd("stopinsert")
          vim.cmd(cmd)
        end, { silent = true, buffer = false })
      end
      set_term_nav('<M-h>', 'TmuxNavigateLeft')
      set_term_nav('<M-j>', 'TmuxNavigateDown')
      set_term_nav('<M-k>', 'TmuxNavigateUp')
      set_term_nav('<M-l>', 'TmuxNavigateRight')

      -- Esc to exit terminal mode (but keep the terminal window open)
      vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
    end,
  },
  { "tpope/vim-surround" },
  { "tpope/vim-unimpaired" },
  { "mg979/vim-visual-multi", branch = "master" },
  {
    "folke/zen-mode.nvim",
    config = function()
      require("zen-mode").setup({
        window = {
          width = 160,
          options = {
            number = true,
            relativenumber = false,
          }
        },
        plugins = {
          options = {
            enabled = true,
            laststatus = 3,  -- Override to keep statusline visible
          },
        },
      })
    end
  },
  {
    'nvim-pack/nvim-spectre',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('spectre').setup({
        color_devicons = true,
        live_update = true,
        line_sep_start = '┌-----------------------------------------',
        result_padding = '¦  ',
        line_sep       = '└-----------------------------------------',
        mapping = {
          ['toggle_line'] = { map = "dd", cmd = "<cmd>lua require('spectre').toggle_line()<CR>" },
          ['run_replace'] = { map = "<leader>R", cmd = "<cmd>lua require('spectre.actions').run_replace()<CR>" },
        },
        default = {
          find = {
            cmd = "rg",  -- Or "ugrep" if preferred
            options = { "fixed-strings" },  -- Added "fixed-strings" for literal searches (handles @, /, etc.)
          },
          replace = {
            cmd = "sed",
          },
        },
      })
    end,
  },

  -- Syntax and Code Quality
  { "honza/vim-snippets" },

  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',            -- the rewrite; required for Neovim 0.11+ (you're on 0.12)
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter').setup()

      -- Install the parsers we use. Async + idempotent (no-op if already present).
      -- NOTE: the `main` branch compiles parsers with `tree-sitter-cli`; install it from
      -- your package manager (Arch: `sudo pacman -S tree-sitter-cli`) or this will fail.
      require('nvim-treesitter').install({
        "javascript", "tsx", "typescript", "python", "json",
        "markdown", "markdown_inline", "lua", "bash",
      })

      -- On `main` there are no plugin "modules" — Neovim itself provides highlighting and
      -- (experimental) indentation. Enable them per-buffer on FileType; pcall guards
      -- filetypes that have no parser installed.
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          if pcall(vim.treesitter.start, args.buf) then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })

      -- Incremental selection was removed on `main`; minimal reimplementation so the old
      -- gnn / grn / grc / grm keys keep working. (Hand-rolled — sanity-check the feel.)
      do
        local stacks = {}  -- per-buffer node stack
        local function same_range(a, b)
          local a1, a2, a3, a4 = a:range()
          local b1, b2, b3, b4 = b:range()
          return a1 == b1 and a2 == b2 and a3 == b3 and a4 == b4
        end
        local function select_node(node)
          local srow, scol, erow, ecol = node:range()
          if ecol == 0 then  -- end-exclusive range landing at column 0 → end of prev line
            erow = erow - 1
            ecol = math.max(#(vim.api.nvim_buf_get_lines(0, erow, erow + 1, false)[1] or ""), 1)
          end
          vim.fn.setpos("'<", { 0, srow + 1, scol + 1, 0 })
          vim.fn.setpos("'>", { 0, erow + 1, ecol, 0 })
          vim.cmd("normal! gv")
        end
        local function init()
          local node = vim.treesitter.get_node()
          if not node then return end
          stacks[vim.api.nvim_get_current_buf()] = { node }
          select_node(node)
        end
        local function expand()
          local stack = stacks[vim.api.nvim_get_current_buf()]
          if not stack or #stack == 0 then return init() end
          local node = stack[#stack]
          local parent = node:parent()
          while parent and same_range(parent, node) do parent = parent:parent() end
          if not parent then return end
          stack[#stack + 1] = parent
          select_node(parent)
        end
        local function shrink()
          local stack = stacks[vim.api.nvim_get_current_buf()]
          if not stack or #stack <= 1 then return end
          stack[#stack] = nil
          select_node(stack[#stack])
        end
        vim.keymap.set("n", "gnn", init,   { desc = "TS: init selection" })
        vim.keymap.set("x", "grn", expand, { desc = "TS: expand selection" })
        vim.keymap.set("x", "grc", expand, { desc = "TS: expand selection (scope)" })
        vim.keymap.set("x", "grm", shrink, { desc = "TS: shrink selection" })
      end
    end
  },
  {
    'JoosepAlviste/nvim-ts-context-commentstring',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require('ts_context_commentstring').setup {
        enable_autocmd = false,  -- Disable autocmd to avoid conflicts; Comment.nvim will handle it
      }
    end,
  },
  {
    'numToStr/Comment.nvim',
    dependencies = { 'JoosepAlviste/nvim-ts-context-commentstring' },
    config = function()
      require('Comment').setup {
        pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
        -- Optional: Customize mappings if you don't want defaults (gcc for line, gc for motion/visual)
        -- mappings = {
        --   basic = true,     -- Enables gcc, gc, etc.
        --   extra = true,     -- Enables gbc (block comment), etc.
        -- },
      }
    end,
  },
  {
    "stevearc/dressing.nvim",
    opts = {},
  },
  {
    "smjonas/inc-rename.nvim",
    dependencies = { "stevearc/dressing.nvim" },  -- Add dependency
    config = function()
      require("inc_rename").setup({
        cmd_name = "IncRename",
        hl_group = "Search",  -- More visible in Molokai (yellow bg)
        preview_empty_name = true,
        show_message = true,
        save_in_cmdline_history = false,
        input_buffer_type = "dressing",  -- Use floating input window
      })
    end,
  },
  {
    'prettier/vim-prettier',
    config = function()
      vim.g.prettier_exec_cmd_async = 1
    end
  },
  { "nvim-telescope/telescope-live-grep-args.nvim", version = "^1.0.0" },
  {
    'nvim-telescope/telescope.nvim',
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
      local actions = require('telescope.actions')

      require('telescope').setup {
        defaults = {
          -- NOTE: this used to be three separate `i = { ... }` keys. Lua keeps
          -- only the last one in a table literal, so <esc> and <C-d> were being
          -- silently dropped. They all live in one table now.
          mappings = {
            i = {
              ['<esc>'] = actions.close,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
            },
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
          find_files = {  -- Add this new entry
            previewer = false,
          },
          buffers = {
            sort_mru = true,
            previewer = false,
            sorting_strategy = 'ascending',
            path_display = path_display,
            -- <C-d> is buffer-specific: it errors in pickers whose entries
            -- aren't buffers (git_status, find_files, ...), so keep it here
            -- rather than in defaults.
            mappings = {
              i = { ["<C-d>"] = actions.delete_buffer },
              n = { ["<C-d>"] = actions.delete_buffer },
            },
          },
          -- ;gc -> working-tree changes. Same feel as the buffer picker, but
          -- with a diff preview and <Tab> to stage/unstage in place.
          git_status = {
            path_display = path_display,
          },
          lsp_document_symbols = {
            previewer = false,
          },
        },
        -- vimgrep_arguments = {
        --   'rg',
        --   '--color=never',
        --   '--no-heading',
        --   '--with-filename',
        --   '--line-number',
        --   '--column',
        --   '--smart-case',  -- Enhances initial search
        --   '--glob=!.git/', -- Optional: Ignore .git
        -- },
        vimgrep_arguments = {
          "ugrep",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column-number",
          "--smart-case",
          "--ignore-binary",  -- Skip binary files
          "--glob=!.git/",    -- Ignore .git (respects .gitignore via ugrep's logic)
          "--recursive",      -- Recursive search
        },
      }
      require("telescope").load_extension("live_grep_args")
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
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "pyright", "ts_ls" },  -- Auto-install pyright (existing) and ts_ls
      })
    end,
  },

  -- Themes and Colors
  { "flazz/vim-colorschemes" },

  -- Tmux Navigation
  {
    "christoomey/vim-tmux-navigator",
    init = function()
      vim.g.tmux_navigator_no_mappings = 1
    end,
  },

  -- Git Integration
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup({
        signs = {
          add          = { text = "▎" },
          change       = { text = "▎" },
          delete       = { text = "_" },
          topdelete    = { text = "‾" },
          changedelete = { text = "~" },
          untracked    = { text = "┆" },
        },
        signcolumn = true,   -- always-on gutter marks
        numhl      = false,  -- these three get toggled on demand via <leader>td
        linehl     = false,
        word_diff  = false,
        attach_to_untracked = true,
        preview_config = { border = "single" },
      })
    end,
  },

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
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("ibl").setup({
        exclude = {
          filetypes = {
            "markdown",
            "flows",
          },
        },
      })
    end,
  },
  {
    "stevearc/conform.nvim",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          python = { "black" },
          javascript = { "prettier" },
          typescript = { "prettier" },
          typescriptreact = { "prettier" }
        },
        formatters = {
          black = {
            extra_args = { "--line-length", "93" },
          },
        },
        format_on_save = false
        -- format_on_save = {
        --   timeout_ms = 500,
        --   lsp_format = "fallback",
        -- },
      })
    end
  },
  { "mfussenegger/nvim-lint", config = function() require("lint").linters_by_ft = { python = { "pylint" }, typescript = { "eslint_d" }, typescriptreact = { "eslint_d" }, javascript = { "eslint_d" } } vim.api.nvim_create_autocmd({ "BufWritePost" }, { callback = function() require("lint").try_lint() end }) end },
  { "folke/trouble.nvim", config = function() require("trouble").setup() end },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",            -- textobjects also has a `main` rewrite; keymaps are explicit now
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
      })
      local ts_select = require("nvim-treesitter-textobjects.select").select_textobject
      vim.keymap.set({ "x", "o" }, "af", function() ts_select("@function.outer", "textobjects") end)
      vim.keymap.set({ "x", "o" }, "if", function() ts_select("@function.inner", "textobjects") end)
      vim.keymap.set({ "x", "o" }, "ac", function() ts_select("@class.outer", "textobjects") end)
      vim.keymap.set({ "x", "o" }, "ic", function() ts_select("@class.inner", "textobjects") end)
    end,
  },

  -- Markdown Plugins
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = "cd app && yarn install",
  },
  {
    "preservim/vim-markdown",
    branch = "master",
    ft = { "markdown" },
    config = function()
      -- Recommended setup options (customize as needed)
      vim.g.vim_markdown_folding_disabled = 1  -- Disable folding (default)
      vim.g.vim_markdown_folding_level = 6     -- Set max folding level
      vim.g.vim_markdown_math = 1              -- Enable LaTeX math
      vim.g.vim_markdown_strikethrough = 1     -- Enable ~~strikethrough~~
      vim.g.vim_markdown_frontmatter = 1       -- Highlight YAML frontmatter
      vim.g.vim_markdown_toml_frontmatter = 1  -- Highlight TOML frontmatter
      vim.g.vim_markdown_json_frontmatter = 1  -- Highlight JSON frontmatter
      vim.g.vim_markdown_conceal = 0           -- Disable concealing (for better readability if preferred)
      vim.g.vim_markdown_conceal_code_blocks = 0
    end,
  },
  -- Auto-install LSP servers via Mason
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    config = function()
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      local function lsp_on_attach(client, bufnr)
        -- Your existing keymaps (moved here for auto-attach)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>', { noremap = true, silent = true })

        -- Disable formatting for pyright (as in your original config)
        if client.name == "pyright" then
          client.server_capabilities.documentFormattingProvider = false
        end
      end
      require("mason-lspconfig").setup({
        ensure_installed = { "pyright", "ts_ls" },
        automatic_installation = true,  -- Auto-setup servers on first use
        handlers = {
          ["pyright"] = function()
            require("lspconfig").pyright.setup({
              capabilities = capabilities,
              on_attach = lsp_on_attach,
              settings = {
                python = {
                  analysis = {
                    autoSearchPaths = true,
                    useLibraryCodeForTypes = true,
                    diagnosticMode = "workspace",
                  },
                },
              },
              root_dir = function(_)
                return get_git_root()
              end,
            })
          end,
          ["ts_ls"] = function()
            require("lspconfig").ts_ls.setup({
              capabilities = capabilities,
              on_attach = lsp_on_attach,
              filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },  -- Covers JS/TS
              settings = {
                typescript = {
                  inlayHints = {
                    includeInlayParameterNameHints = 'all',
                    includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                    includeInlayFunctionParameterTypeHints = true,
                    includeInlayVariableTypeHints = true,
                    includeInlayPropertyDeclarationTypeHints = true,
                    includeInlayFunctionLikeReturnTypeHints = true,
                    includeInlayEnumMemberValueHints = true,
                  },
                },
              },
              root_dir = function(_)
                return get_git_root()
              end,
            })
          end,
        },
      })
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    config = function()
      require("mason-tool-installer").setup({
        ensure_installed = { "typescript-language-server", "eslint_d", "prettier", "black" },
        auto_update = true,
        run_on_start = true,
      })
    end,
  },
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",  -- already in your config
      "stevearc/dressing.nvim",           -- you already have this → good for UI
    },
    config = function()
      require("codecompanion").setup({
        adapters = {
          xai = function()
            return require("codecompanion.adapters").extend("openai_compatible", {
              env = {
                url = "https://api.x.ai/v1",
                api_key = os.getenv("XAI_API_KEY")
              },
              schema = {
                model = {
                  default = "grok-4-1-fast-reasoning",  -- fast & cheap for coding
                },
              },
            })
          end,
        },

        strategies = {
          -- Main chat (what you use to talk like an engineer)
          chat = {
            adapter = "xai",
            tools = {
              -- Enable powerful built-in tools for multi-file work
              editor = { -- lets Grok edit multiple files
                opts = { auto_approve = false }, -- change to true if you trust it
              },
              cmd_runner = true,   -- run tests, lint, etc.
              -- You can add more tools later (files, lsp, etc.)
            },
          },

          -- Inline editing (quick changes to current buffer)
          inline = {
            adapter = "xai",
          },

          -- Agentic / workflow mode (great for your "implement feature across files" use-case)
          agent = {
            adapter = "xai",
          },
        },

        opts = {
          log_level = "WARN",  -- change to "DEBUG" if you have issues
          send_code = true,
        },

        -- Optional: nice keybindings
        display = {
          chat = {
            window = {
              layout = "vertical",  -- or "horizontal"
            },
          },
        },
      })
    end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" }, -- needs markdown + markdown_inline parsers
    opts = {
      enabled = false,
      pipe_table = {
        enabled = true,
        preset = "round",  -- or 'double', 'heavy', 'none'
        style = "full",    -- 'full' draws borders, 'normal' is lighter
      },
    },
  },
})

-- Keymaps --------------------------------------------------------------------
vim.g.mapleader = ";"

-- Render Markdown Keymaps
vim.keymap.set("n", "<leader>md", "<cmd>RenderMarkdown toggle<cr>", { desc = "Toggle render-markdown" })

-- DAP Keymaps
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

-- Telescope Keymaps
-- ;ff -> find files under the git root.
--
-- By default this shows EVERYTHING: gitignored files (.venv, build output,
-- .env, ...) and dotfiles included. `.git/` itself is filtered out, since
-- nobody wants 400 loose objects in the picker. Add more paths to
-- ignore_when_showing_all below if a directory turns out to be pure noise.
--
-- <C-g> inside the picker toggles between this and the tracked-only view,
-- keeping whatever you've typed so far. (Not <C-h>: most terminals send ^H
-- for Backspace, so mapping it eats your Backspace key.) Flip
-- show_all_by_default to false if you'd rather start from the tracked-only side.
local show_all_by_default = true

-- Directories that stay hidden even in the "show everything" mode. Plain
-- directory names, matched at any depth. This is the only list to edit.
local exclude_dirs = {
  '.git',
  'node_modules',
  -- '.venv',
  -- 'target',
  -- 'dist',
}

-- Preferred: hand the exclusions to fd, which then never descends into those
-- directories at all. Much faster than listing 30k node_modules files and
-- throwing them away afterwards.
local function fd_find_command(show_all)
  local fd
  for _, candidate in ipairs({ 'fd', 'fdfind' }) do  -- Debian ships it as fdfind
    if vim.fn.executable(candidate) == 1 then fd = candidate break end
  end
  if not fd then return nil end

  local cmd = { fd, '--type', 'f', '--color', 'never' }
  if show_all then
    vim.list_extend(cmd, { '--hidden', '--no-ignore' })
  end
  for _, dir in ipairs(exclude_dirs) do
    vim.list_extend(cmd, { '--exclude', dir })
  end
  return cmd
end

-- Fallback for when fd isn't installed: telescope filters rg/find's output
-- with these Lua patterns (note: patterns, not globs, so dots need escaping).
local function exclude_patterns()
  local patterns = {}
  for _, dir in ipairs(exclude_dirs) do
    table.insert(patterns, (dir:gsub('%p', '%%%0')) .. '/')
  end
  return patterns
end

local find_files_picker
find_files_picker = function(opts)
  opts = opts or {}
  local show_all = opts.show_all
  if show_all == nil then show_all = show_all_by_default end

  local find_command = fd_find_command(show_all)

  require('telescope.builtin').find_files({
    cwd = get_git_root(),  -- falls back to cwd outside a repo
    prompt_title = show_all and 'Find Files (incl. ignored)' or 'Find Files (tracked)',
    find_command = find_command,
    -- hidden/no_ignore are baked into find_command above when fd is present;
    -- telescope ignores them in that case, so only set them otherwise.
    no_ignore = not find_command and show_all or nil,
    hidden    = not find_command and show_all or nil,
    file_ignore_patterns = exclude_patterns(),
    default_text = opts.default_text,
    attach_mappings = function(prompt_bufnr, map)
      map({ 'i', 'n' }, '<C-g>', function()
        local typed = require('telescope.actions.state').get_current_line()
        require('telescope.actions').close(prompt_bufnr)
        find_files_picker({ show_all = not show_all, default_text = typed })
      end)
      return true  -- keep all the default mappings
    end,
  })
end

vim.keymap.set('n', '<leader>ff', function() find_files_picker() end,
  { desc = '[F]ind [F]iles in Git Repo (incl. gitignored)' })

-- Workspace symbols (repo-wide), prefilled with word under cursor
vim.keymap.set('n', '<leader>ws', function()
  require('telescope.builtin').lsp_workspace_symbols({
    query = vim.fn.expand('<cword>'),  -- Prefills the prompt with symbol under cursor
  })
end, { desc = '[W]orkspace [S]ymbols (prefilled with <cword>)' })


-- Live grep (repo-wide)
vim.keymap.set('n', '<leader>g',
  function()
    local git_root = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
    if vim.v.shell_error ~= 0 then
      git_root = vim.fn.getcwd()
    end
    require('telescope.builtin').live_grep({ cwd = git_root })
  end, { desc = '[F]ind by [G]rep in Git Repo' }
)

-- Live grep (repo-wide), prefilled with word under cursor
vim.keymap.set('n', '<leader>gg', function()
  local git_root = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 then
    git_root = vim.fn.getcwd()
  end

  require('telescope.builtin').live_grep({
    cwd = git_root,
    default_text = vim.fn.expand('<cword>'),  -- Prefills the prompt
  })
end, { desc = '[G]rep repo-wide (prefilled with <cword>)' })

vim.keymap.set('v', '<leader>gg', function()
  local text = get_visual_selection()
  local git_root = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 then
    git_root = vim.fn.getcwd()
  end

  require('telescope.builtin').live_grep({
    cwd = git_root,
    default_text = text,
  })
end, { desc = '[G]rep repo-wide (visually selected text)' })

vim.keymap.set('n', '<leader>gf', function()
  local git_root = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 then
    git_root = vim.fn.getcwd()
  end

  require("telescope").extensions.live_grep_args.live_grep_args({
    cwd = git_root,
    additional_args = {"--fuzzy=3", "-F"},  -- -F for fixed strings (safer, avoids regex interpretation)
    print_args = true,  -- Temporary: Prints the full command to :messages for debugging
  })
end, { desc = '[G]rep repo-wide (fuzzy mode)' })

-- Spectre for IDE-like search/replace panel
vim.keymap.set('n', '<leader>sr', function()
  require('spectre').toggle({
    cwd = get_git_root(),  -- Use your existing get_git_root() for repo-wide
  })
end, { desc = '[S]earch/[R]eplace Panel (repo-wide)' })

vim.keymap.set('n', '<leader>sw', function()
  require('spectre').open_visual({
    select_word = true,
    cwd = get_git_root(),  -- Use repo root
  })
end, { desc = '[S]earch/[R]eplace Word under cursor (repo-wide)' })

vim.keymap.set('v', '<leader>sw', function()
  require('spectre').open_visual({
    cwd = get_git_root(),  -- Use repo root
  })
end, { desc = '[S]earch/[R]eplace Visual selection (repo-wide)' })

vim.keymap.set("n", "<leader>rn", function()
    return ":IncRename " .. vim.fn.expand("<cword>")
  end, { expr = true, desc = "Rename symbol (with preview)"
})

vim.keymap.set('n', '<leader>b', require('telescope.builtin').buffers, { desc = '[F]ind [B]uffers' })
vim.keymap.set('n', '<leader>h', require('telescope.builtin').oldfiles, { desc = '[F]ind [H]istory' })
vim.keymap.set('n', '<leader>s', require('telescope.builtin').lsp_document_symbols, { desc = '[S]earch [F]unctions/Symbols' })
vim.keymap.set('n', '<leader>gd', require('telescope.builtin').lsp_definitions, { desc = '[G]o to [D]efinition' })

-- ;gc -> every file with working-tree changes (staged, unstaged, untracked).
-- <CR> opens, <Tab> stages/unstages without leaving the list, <C-v>/<C-x> split.
vim.keymap.set('n', '<leader>gc', function()
  require('telescope.builtin').git_status({ cwd = get_git_root() })
end, { desc = '[G]it [C]hanged files' })

-- Git inline diff (gitsigns) -------------------------------------------------
local gs = require("gitsigns")

-- ;td -> highlight every changed line + intra-line word diff, in place. Toggles back off.
local inline_diff = false
vim.keymap.set("n", "<leader>td", function()
  inline_diff = not inline_diff
  gs.toggle_linehl(inline_diff)
  gs.toggle_word_diff(inline_diff)
  gs.toggle_numhl(inline_diff)
  vim.notify("git inline diff: " .. (inline_diff and "on" or "off"))
end, { desc = "[T]oggle inline git [D]iff" })

-- ;tp -> show the *old* version of the hunk under the cursor as virtual lines
vim.keymap.set("n", "<leader>tp", gs.preview_hunk_inline, { desc = "[T]oggle hunk [P]review inline" })

-- ;tv -> real side-by-side diff against the index; same key closes it
vim.keymap.set("n", "<leader>tv", function()
  if vim.wo.diff then
    vim.cmd("diffoff!")
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      local name = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))
      if name:match("^gitsigns://") then
        pcall(vim.api.nvim_win_close, win, true)
      end
    end
  else
    gs.diffthis()
  end
end, { desc = "[T]oggle [V]ertical git diff" })

-- Hunk navigation
vim.keymap.set("n", "]c", function() gs.nav_hunk("next") end, { desc = "Next git hunk" })
vim.keymap.set("n", "[c", function() gs.nav_hunk("prev") end, { desc = "Prev git hunk" })

-- Git staging (add) ----------------------------------------------------------
-- Writes the buffer first: git stages what's on disk, not what's in memory.
local function write_if_modified()
  if vim.bo.modified and vim.bo.buftype == "" then
    vim.cmd("silent write")
  end
end

-- :GitAdd -> plain `git add <current file>`. Works for untracked files too,
-- and doesn't depend on gitsigns being attached to the buffer.
vim.api.nvim_create_user_command("GitAdd", function()
  local file = vim.fn.expand("%:p")
  if file == "" then
    vim.notify("no file in this buffer", vim.log.levels.WARN)
    return
  end
  write_if_modified()
  local out = vim.fn.system({ "git", "add", "--", file })
  if vim.v.shell_error ~= 0 then
    vim.notify(out, vim.log.levels.ERROR)
  else
    pcall(gs.refresh)
    vim.notify("git add " .. vim.fn.expand("%:~:."))
  end
end, { desc = "git add the current file" })

-- :GitUnstage -> `git reset -q HEAD -- <current file>`
vim.api.nvim_create_user_command("GitUnstage", function()
  local file = vim.fn.expand("%:p")
  if file == "" then return end
  local out = vim.fn.system({ "git", "reset", "-q", "HEAD", "--", file })
  if vim.v.shell_error ~= 0 then
    vim.notify(out, vim.log.levels.ERROR)
  else
    pcall(gs.refresh)
    vim.notify("unstaged " .. vim.fn.expand("%:~:."))
  end
end, { desc = "git unstage the current file" })

-- ;ga -> stage the whole current buffer/file
vim.keymap.set("n", "<leader>ga", "<cmd>GitAdd<cr>", { silent = true, desc = "[G]it [A]dd current file" })
-- ;gA -> unstage the whole current file
vim.keymap.set("n", "<leader>gA", "<cmd>GitUnstage<cr>", { silent = true, desc = "[G]it un[A]dd current file" })

-- ;gs -> stage only the hunk under the cursor
vim.keymap.set("n", "<leader>gs", function()
  write_if_modified()
  gs.stage_hunk()
end, { desc = "[G]it [S]tage hunk" })

-- ;gs in visual mode -> stage only the selected lines
vim.keymap.set("v", "<leader>gs", function()
  write_if_modified()
  gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
end, { desc = "[G]it [S]tage selected lines" })

-- ;gu -> undo the last hunk staging (gitsigns >= 1.0 toggles via stage_hunk)
vim.keymap.set("n", "<leader>gu", function()
  if gs.undo_stage_hunk then gs.undo_stage_hunk() else gs.stage_hunk() end
end, { desc = "[G]it [U]nstage hunk" })

-- CodeCompanion keymaps
vim.keymap.set({ "n", "v" }, "<leader>cc", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Toggle AI Chat" })
vim.keymap.set({ "n", "v" }, "<leader>ca", "<cmd>CodeCompanionActions<cr>", { desc = "AI Actions" })
vim.keymap.set("v", "<leader>ce", "<cmd>CodeCompanion<cr>", { desc = "AI Edit selection" })
-- Quick ways to talk to Grok about the whole project
vim.keymap.set("n", "<leader>cp", function()
  require("codecompanion").prompt("project")  -- or custom prompt
end, { desc = "AI Project Chat" })

-- Other Keymaps
vim.keymap.set("n", "<leader>=", function() require("conform").format({ async = true, lsp_fallback = true }) end, { noremap = true, silent = true, desc = "Format buffer" })
vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Toggle Trouble (Diagnostics)" })
vim.keymap.set("n", "<leader>zz", "<cmd>ZenMode<cr>", { desc = "Toggle Zen Mode (Centered Buffer)" })

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

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "typescript", "typescriptreact" },
  callback = function()
    vim.opt_local.tabstop = 2        -- Number of spaces a <Tab> counts for
    vim.opt_local.softtabstop = 2    -- Number of spaces for <Tab> in insert mode
    vim.opt_local.shiftwidth = 2     -- Number of spaces for each indentation level
    vim.opt_local.expandtab = true   -- Convert tabs to spaces (recommended for consistency)
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  callback = function()
    vim.api.nvim_buf_create_user_command(0, 'Breakpoint',
      function()
        local line = vim.fn.line('.')
        vim.api.nvim_buf_set_lines(0, line, line, false, {'debugger; // XXX Breakpoint'})
      end, { desc = 'Insert debugger breakpoint' }
    )
    vim.keymap.set('n', '<leader>B', ':Breakpoint<CR>', { buffer = true, noremap = true, silent = true, desc = 'Insert debugger breakpoint' })
  end,
})

-- Auto-detect .spec files as our custom spec syntax
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.flows",
  callback = function()
    vim.bo.filetype = "flows"        -- this will source syntax/flows.lua
  end,
})

vim.opt.inccommand = "split"  -- Shows a split with all changes as you type

-- General Settings -----------------------------------------------------------
-- Ensure ~/.nvim/tmp exists for temporary files with proper expansion
local tmp_dir = vim.fn.expand("~/.nvim/tmp")
if not vim.fn.isdirectory(tmp_dir) then
  vim.fn.mkdir(tmp_dir, "p")
end

vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.encoding = "utf-8"
-- The theme/diff highlights below are defined in 24-bit hex; without this the
-- terminal falls back to the (much coarser) cterm values.
if vim.env.COLORTERM == "truecolor" or vim.env.COLORTERM == "24bit" then
  vim.opt.termguicolors = true
end
vim.cmd([[syntax on]])
vim.g.c_comment_strings = 1
vim.opt.hlsearch = true
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("data") .. "/undo"
vim.opt.lazyredraw = true
vim.cmd([[syntax sync minlines=200]])
vim.opt.jumpoptions = 'view' -- To preserve scroll position when switching buffers

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
vim.opt.signcolumn = "yes"  -- keep gutter open so gitsigns doesn't shift text
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
vim.opt.colorcolumn = "93"
vim.cmd("highlight ColorColumn guibg=#373832 ctermbg=235")
-- vim.cmd("highlight MolokaiColorColumn guibg=#5e5e5e ctermbg=235")
-- vim.cmd([[highlight Normal ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE]])
-- vim.cmd([[highlight VertSplit ctermfg=240 ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE]])
-- vim.cmd([[highlight ErrorMsg ctermfg=199 ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE]])
-- vim.cmd([[highlight Search ctermfg=7 ctermbg=88 cterm=NONE guifg=NONE guibg=NONE gui=NONE]])
vim.opt.fillchars:append({ vert = "|" })
-- Diagonal hatching for diff filler lines, so "nothing here" reads as absence
-- rather than as a coloured block of content. Blank fold padding stops fold
-- lines rendering as a long dash bar.
vim.opt.fillchars:append({ diff = "╱", fold = " " })

-- Empty foldtext (0.10+) renders the collapsed line with its real syntax
-- highlighting instead of the legacy "+--  12 lines:" placeholder. Matters when
-- scanning folded JSON: you still see the key, not just a line count.
vim.opt.foldtext = ""

-- linematch aligns changed lines within a hunk so DiffText marks the words that
-- actually changed instead of smearing across the whole line.
vim.opt.diffopt:append({ "linematch:60" })

-- All molokai tweaks live in one function so they survive a colorscheme reload
-- (zen-mode, :colorscheme molokai, plugins that re-apply the theme, etc).
local function molokai_tweaks()
  local bg       = "#272822"  -- Molokai original bg
  local linenr   = "#474842"
  local cterm_fg = 225
  local cterm_bg = 235

  vim.api.nvim_set_hl(0, "LineNr",      { fg = linenr, bg = bg, ctermfg = cterm_fg, ctermbg = cterm_bg })
  vim.api.nvim_set_hl(0, "LineNrAbove", { fg = linenr, bg = bg, ctermfg = cterm_fg, ctermbg = cterm_bg })
  vim.api.nvim_set_hl(0, "LineNrBelow", { fg = linenr, bg = bg, ctermfg = cterm_fg, ctermbg = cterm_bg })
  vim.api.nvim_set_hl(0, "SignColumn",  { bg = bg, ctermbg = cterm_bg })

  -- Fold lines -----------------------------------------------------------------
  -- Diff mode sets foldmethod=diff and collapses every unchanged region into a
  -- single full-width fold line. Molokai renders those as grey-on-grey, which is
  -- the least readable thing on the screen in a diff. Amber on a lifted
  -- background instead: clearly a separator, clearly not code.
  vim.api.nvim_set_hl(0, "Folded",     { fg = "#c9c398", bg = "#3a3b32", ctermfg = 187, ctermbg = 237, italic = true })
  vim.api.nvim_set_hl(0, "FoldColumn", { fg = "#75715e", bg = bg, ctermfg = 242, ctermbg = cterm_bg })

  -- Diff colours (:diffthis, ;tv, fugitive, etc) ------------------------------
  -- Molokai's defaults wash out the foreground (DiffChange greys the text,
  -- DiffDelete is near-black crimson on black). These use dark tinted
  -- backgrounds with fg = NONE instead, so syntax highlighting stays intact and
  -- readable, and reserve the saturated colours for DiffText.
  vim.api.nvim_set_hl(0, "DiffAdd",    { fg = "NONE", bg = "#1e3620", ctermbg = 22,  ctermfg = "NONE" })
  vim.api.nvim_set_hl(0, "DiffChange", { fg = "NONE", bg = "#2b2f3d", ctermbg = 17,  ctermfg = "NONE" })
  vim.api.nvim_set_hl(0, "DiffText",   { fg = "NONE", bg = "#4d4423", ctermbg = 58,  ctermfg = "NONE", bold = true })
  -- DiffDelete only ever covers filler lines, so the fg is the hatch character.
  vim.api.nvim_set_hl(0, "DiffDelete", { fg = "#6b3541", bg = "#301a20", ctermbg = 52, ctermfg = 95 })

  -- Gitsigns: gutter signs ----------------------------------------------------
  vim.api.nvim_set_hl(0, "GitSignsAdd",    { fg = "#a6e22e", bg = bg, ctermfg = 148 })
  vim.api.nvim_set_hl(0, "GitSignsChange", { fg = "#e6db74", bg = bg, ctermfg = 186 })
  vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = "#f92672", bg = bg, ctermfg = 197 })

  -- Gitsigns: line numbers (numhl, toggled by ;td) ----------------------------
  vim.api.nvim_set_hl(0, "GitSignsAddNr",    { fg = "#8ab825", bg = bg, ctermfg = 106 })
  vim.api.nvim_set_hl(0, "GitSignsChangeNr", { fg = "#c4ba5f", bg = bg, ctermfg = 143 })
  vim.api.nvim_set_hl(0, "GitSignsDeleteNr", { fg = "#c8225b", bg = bg, ctermfg = 161 })

  -- Gitsigns: whole-line highlight (linehl, toggled by ;td) -------------------
  -- Kept very subtle: these sit under normal code you still need to read.
  vim.api.nvim_set_hl(0, "GitSignsAddLn",    { bg = "#1e3620", ctermbg = 22 })
  vim.api.nvim_set_hl(0, "GitSignsChangeLn", { bg = "#33301f", ctermbg = 58 })
  vim.api.nvim_set_hl(0, "GitSignsDeleteLn", { bg = "#301a20", ctermbg = 52 })
  -- These three link to DiffChange/DiffDelete when left undefined, which is how
  -- the grey-on-grey leaks back in even after DiffChange is fixed.
  vim.api.nvim_set_hl(0, "GitSignsChangedeleteLn", { bg = "#33301f", ctermbg = 58 })
  vim.api.nvim_set_hl(0, "GitSignsTopdeleteLn",    { bg = "#301a20", ctermbg = 52 })
  vim.api.nvim_set_hl(0, "GitSignsUntrackedLn",    { bg = "#22302c", ctermbg = 23 })
  vim.api.nvim_set_hl(0, "GitSignsUntracked",      { fg = "#66d9ef", bg = bg, ctermfg = 81 })
  vim.api.nvim_set_hl(0, "GitSignsUntrackedNr",    { fg = "#4fa8bd", bg = bg, ctermfg = 74 })

  -- Gitsigns: word diff (toggled by ;td) --------------------------------------
  -- Stronger than the line highlights so the changed words pop out of them.
  vim.api.nvim_set_hl(0, "GitSignsAddInline",    { bg = "#33633c", ctermbg = 28 })
  vim.api.nvim_set_hl(0, "GitSignsChangeInline", { bg = "#5f5424", ctermbg = 94 })
  vim.api.nvim_set_hl(0, "GitSignsDeleteInline", { bg = "#6e2438", ctermbg = 89 })

  -- Gitsigns: inline hunk preview (;tp) ---------------------------------------
  vim.api.nvim_set_hl(0, "GitSignsDeleteVirtLn",       { fg = "#8a8578", bg = "#301a20", ctermfg = 245, ctermbg = 52 })
  vim.api.nvim_set_hl(0, "GitSignsDeleteVirtLnInLine", { fg = "#f8f8f2", bg = "#6e2438", ctermfg = 255, ctermbg = 89 })
  vim.api.nvim_set_hl(0, "GitSignsAddPreview",         { bg = "#1e3620", ctermbg = 22 })
  vim.api.nvim_set_hl(0, "GitSignsDeletePreview",      { bg = "#301a20", ctermbg = 52 })
end

-- Re-apply on ANY colorscheme event, not just molokai. Anything that re-sources
-- a theme (zen-mode, a lazy-loaded plugin, :colorscheme) resets these otherwise.
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = molokai_tweaks,
})
vim.cmd('colorscheme molokai')
molokai_tweaks()

-- Gitsigns is lazy-loaded on BufReadPre, i.e. after init.lua has finished, and
-- it defines its own GitSigns* groups on load. Re-applying once the event loop
-- is idle guarantees these win regardless of who loaded first.
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function() vim.schedule(molokai_tweaks) end,
})

-- :ReloadHl -> re-apply without restarting nvim (useful while tuning colours).
vim.api.nvim_create_user_command("ReloadHl", molokai_tweaks, { desc = "Re-apply theme highlight overrides" })

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
-- Unified Alt-based navigation: works across nvim splits AND tmux panes.
-- tmux is configured with an is_vim check so M-h/j/k/l are forwarded to nvim
-- when nvim is active, and do plain pane-switching otherwise.
vim.keymap.set('n', '<M-h>', '<cmd>TmuxNavigateLeft<cr>',  { silent = true, desc = 'Navigate left (nvim/tmux)' })
vim.keymap.set('n', '<M-j>', '<cmd>TmuxNavigateDown<cr>',  { silent = true, desc = 'Navigate down (nvim/tmux)'  })
vim.keymap.set('n', '<M-k>', '<cmd>TmuxNavigateUp<cr>',    { silent = true, desc = 'Navigate up (nvim/tmux)'  })
vim.keymap.set('n', '<M-l>', '<cmd>TmuxNavigateRight<cr>', { silent = true, desc = 'Navigate right (nvim/tmux)'  })

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

-- Fold toggle ----------------------------------------------------------------
-- Folding stays off (foldmethod=manual, no folds) until asked for. Turning it on
-- builds treesitter folds and collapses every scope at once. Fold options are
-- window-local, so this only ever affects the current window.
local function toggle_folding()
  if vim.wo.foldmethod == "expr" then
    vim.wo.foldmethod = "manual"      -- zE refuses to run under any other method
    vim.wo.foldexpr   = "0"
    pcall(vim.cmd, "normal! zE")      -- erase the folds so nothing lingers
    vim.wo.foldenable = false
    vim.wo.foldcolumn = "0"
  else
    if not vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] then
      vim.notify("No treesitter parser for this buffer", vim.log.levels.WARN)
      return
    end
    vim.wo.foldmethod = "expr"
    vim.wo.foldexpr   = "v:lua.vim.treesitter.foldexpr()"
    vim.wo.foldenable = true
    vim.wo.foldcolumn = "1"
    vim.wo.foldlevel  = 1             -- collapse everything below the top level
  end
end

vim.keymap.set('n', '<leader>zf', toggle_folding,
  { silent = true, desc = 'Toggle treesitter folding' })

-- Scope-local zr / zm ---------------------------------------------------------
-- Built-in zr/zm move the window-wide foldlevel, so they peel every branch of
-- the file at once. These do the same thing but bounded to the fold under the
-- cursor: one level deeper (or shallower) across every element of that scope,
-- leaving sibling scopes alone.

-- The fold containing the cursor, as a [start, end] line range. Falls back to
-- the whole buffer when the cursor is not inside any fold.
local function current_scope()
  local lnum = vim.fn.line('.')

  -- Sitting on a closed fold: that fold is the scope.
  local fc = vim.fn.foldclosed(lnum)
  if fc ~= -1 then
    return fc, vim.fn.foldclosedend(lnum)
  end

  if vim.fn.foldlevel(lnum) == 0 then
    return 1, vim.fn.line('$')
  end

  -- Momentarily close the innermost fold and read its extent. Two things rule
  -- out the obvious alternatives: foldlevel() returns nesting depth, not fold
  -- identity, so adjacent siblings at the same level look like one range; and
  -- [z deliberately jumps to the ENCLOSING fold when the cursor already sits on
  -- a fold's first line, which pairs a parent's start with a child's end.
  local view = vim.fn.winsaveview()
  local ok = pcall(vim.cmd, lnum .. 'foldclose')
  if not ok then
    vim.fn.winrestview(view)
    return 1, vim.fn.line('$')
  end
  local s, e = vim.fn.foldclosed(lnum), vim.fn.foldclosedend(lnum)
  pcall(vim.cmd, lnum .. 'foldopen')  -- children keep their own open/closed state
  vim.fn.winrestview(view)

  if s == -1 then
    return 1, vim.fn.line('$')
  end
  return s, e
end

-- Open every closed fold inside the scope exactly once.
local function fold_expand_scope()
  if not vim.wo.foldenable then
    vim.notify('Folding is off — turn it on with ;zf', vim.log.levels.WARN)
    return false
  end
  local s, e = current_scope()

  -- Collect first, open second. Opening while scanning would immediately
  -- descend into the children just revealed and flatten more than one level.
  local targets, l = {}, s
  while l <= e do
    local fs = vim.fn.foldclosed(l)
    if fs ~= -1 then
      targets[#targets + 1] = fs
      l = vim.fn.foldclosedend(l) + 1
    else
      l = l + 1
    end
  end

  if #targets == 0 then
    return false
  end
  for _, fs in ipairs(targets) do
    pcall(vim.cmd, fs .. 'foldopen')
  end
  return true
end

-- Close the deepest open folds inside the scope: one level shallower.
local function fold_collapse_scope()
  if not vim.wo.foldenable then
    vim.notify('Folding is off — turn it on with ;zf', vim.log.levels.WARN)
    return false
  end
  local s, e = current_scope()

  -- Deepest nesting level currently visible; skip closed folds, their contents
  -- are already hidden and must not count.
  local maxl, l = 0, s
  while l <= e do
    local fs = vim.fn.foldclosed(l)
    if fs ~= -1 then
      l = vim.fn.foldclosedend(l) + 1
    else
      local lvl = vim.fn.foldlevel(l)
      if lvl > maxl then maxl = lvl end
      l = l + 1
    end
  end

  if maxl == 0 then
    return false
  end

  l = s
  while l <= e do
    local fs = vim.fn.foldclosed(l)
    if fs ~= -1 then
      l = vim.fn.foldclosedend(l) + 1
    elseif vim.fn.foldlevel(l) >= maxl then
      pcall(vim.cmd, l .. 'foldclose')
      local fe = vim.fn.foldclosedend(l)
      l = (fe ~= -1 and fe or l) + 1
    else
      l = l + 1
    end
  end
  return true
end

-- Bound to bare zr/zm, count-aware like the builtins (3zr peels three levels).
-- The file-wide versions stay available on zR/zM.
local function repeat_fold(fn)
  return function()
    for _ = 1, vim.v.count1 do
      if not fn() then break end
    end
  end
end

vim.keymap.set('n', 'zr', repeat_fold(fold_expand_scope),
  { silent = true, desc = 'Fold: one level deeper in current scope' })
vim.keymap.set('n', 'zm', repeat_fold(fold_collapse_scope),
  { silent = true, desc = 'Fold: one level shallower in current scope' })

vim.keymap.set('n', '<leader>cl', '<cmd>ClaudeCode<cr>', { desc = 'Toggle Claude Code' })
vim.keymap.set('v', '<leader>cv', ':<C-U>ClaudeCodeSend<cr>', { silent = true, desc = 'Send selection to Claude' })

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
-- Conform.nvim Setup ---------------------------------------------------------

-- Keymap for manual formatting
