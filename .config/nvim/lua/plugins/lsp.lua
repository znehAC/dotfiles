return {
  'neovim/nvim-lspconfig',
  dependencies = {
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'hrsh7th/cmp-nvim-lsp',
    'b0o/schemastore.nvim',
  },
  config = function()
    -- 1. CONFIGURE LSP DIAGNOSTICS
    vim.diagnostic.config({
      virtual_text = true,
      severity_sort = true,
      float = {
        style = 'minimal',
        border = 'rounded',
        header = '',
        prefix = '',
      },
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = '✘',
          [vim.diagnostic.severity.WARN] = '▲',
          [vim.diagnostic.severity.HINT] = '⚑',
          [vim.diagnostic.severity.INFO] = '»',
        },
      },
    })

    -- 2. AUTOFORMATTING LOGIC
    local autoformat_filetypes = {
      "lua", "cs", "md", "markdown", "python", "typescript",
      "javascript", "typescriptreact", "javascriptreact", "json", "jsonc"
    }

    vim.api.nvim_create_autocmd('LspAttach', {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then return end

        -- Enable formatting on save
        if vim.tbl_contains(autoformat_filetypes, vim.bo.filetype) then
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = args.buf,
            callback = function()
              vim.lsp.buf.format({
                async = false,
                bufnr = args.buf,
                id = client.id,
              })
            end
          })
        end

        -- Keymaps
        local opts = { buffer = args.buf }
        vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
        vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
        vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
        vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
        vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
        vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
        vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
        vim.keymap.set('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>', opts)
        vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
        vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
      end
    })

    -- 3. MASON AND HANDLERS
    local capabilities = require('cmp_nvim_lsp').default_capabilities()

    require('mason').setup({})
    require('mason-lspconfig').setup({
      ensure_installed = {
        "lua_ls", "basedpyright", "ruff", "ts_ls", "eslint",
        "clangd", "html", "cssls", "omnisharp", "marksman",
        "biome", "jsonls"
      },
      handlers = {
        -- Default handler for simple servers
        function(server_name)
          require('lspconfig')[server_name].setup({ capabilities = capabilities })
        end,


        -- PYTHON
        basedpyright = function()
          local function get_python_path()
            -- 1. Active venv (VIRTUAL_ENV env var)
            if vim.env.VIRTUAL_ENV then
              return vim.env.VIRTUAL_ENV .. '/bin/python'
            end
            -- 2. Local .venv in project root
            local cwd_venv = vim.fn.getcwd() .. '/.venv/bin/python'
            if vim.fn.executable(cwd_venv) == 1 then
              return cwd_venv
            end
            -- 3. Fall back to global
            return vim.fn.exepath('python3') or vim.fn.exepath('python') or 'python3'
          end

          require('lspconfig').basedpyright.setup({
            capabilities = capabilities,
            settings = {
              basedpyright = {
                analysis = {
                  typeCheckingMode = 'standard',
                },
              },
              python = {
                pythonPath = get_python_path(),
              },
            },
          })
        end,

        -- LUA
        lua_ls = function()
          require('lspconfig').lua_ls.setup({
            capabilities = capabilities,
            settings = {
              Lua = {
                runtime = { version = 'LuaJIT' },
                diagnostics = { globals = { 'vim' } },
                workspace = { library = { vim.env.VIMRUNTIME } },
              },
            },
          })
        end,

        -- JSON: Use jsonls for Schemas/Linting
        jsonls = function()
          require('lspconfig').jsonls.setup({
            capabilities = capabilities,
            settings = {
              json = {
                schemas = require('schemastore').json.schemas(),
                validate = { enable = true },
              },
            },
            on_attach = function(client)
              client.server_capabilities.documentFormattingProvider = false
              client.server_capabilities.documentRangeFormattingProvider = false
            end,
          })
        end,

        -- BIOME
        biome = function()
          require('lspconfig').biome.setup({
            capabilities = capabilities,
          })
        end,
      },
    })
  end
}
