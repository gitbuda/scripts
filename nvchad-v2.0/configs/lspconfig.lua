local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"

-- if you just want default config for the servers then put them in a table
local servers = { "html", "cssls", "tsserver", "clangd", "rust_analyzer", "pyright" }

for _, lsp in ipairs(servers) do
  local opts = {
    on_attach = on_attach,
    capabilities = capabilities,
  }
  if lsp == "clangd" then
    opts.filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "lcp" }
    opts.cmd = {
      "clangd",
      -- "--clang-tidy",
    }
    opts.capabilities.offsetEncoding = "utf-8"
  end
  lspconfig[lsp].setup(opts)
end

-- 
-- lspconfig.pyright.setup { blabla}
