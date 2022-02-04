-- A custom config for lsp-config plugin.
-- Added as a top level file lua/custom_... because I want it to be versioned.

local M = {}

M.setup_lsp = function(attach, capabilities)
   local lspconfig = require "lspconfig"

   -- lspservers with default config

   local servers = { "html", "cssls", "pyright" }

   for _, lsp in ipairs(servers) do
      lspconfig[lsp].setup {
         on_attach = attach,
         capabilities = capabilities,
         flags = {
            debounce_text_changes = 150,
         },
      }
   end

   -- clangd
   lspconfig.clangd.setup {
      filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
      on_attach = attach,
      capabilities = capabilities,
      flags = {
         debounce_text_changes = 150,
      },
   }
end

return M
