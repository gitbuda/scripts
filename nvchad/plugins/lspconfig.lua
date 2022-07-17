-- A custom config for lsp-config plugin.
-- Added as a top level file lua/custom_... because I want it to be versioned.

local M = {}

M.setup_lsp = function(attach, capabilities)
   local lsp_installer = require "nvim-lsp-installer"
   lsp_installer.settings {
      ui = {
         icons = {
            server_installed = "﫟" ,
            server_pending = "",
            server_uninstalled = "✗",
         },
      },
   }
   local lspconfig = require "lspconfig"
   local servers = { "html", "clangd", "pyright" }

   for _, lsp in ipairs(servers) do
      local opts = {
         on_attach = attach,
         capabilities = capabilities,
         root_dir = vim.loop.cwd,
      }
      if lsp == "clangd" then
         opts.filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "lcp" }
      end
      lspconfig[lsp].setup(opts)
   end
end

return M
