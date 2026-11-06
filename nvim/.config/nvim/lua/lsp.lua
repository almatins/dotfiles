-- LSP.
--
-- Neovim 0.11+ already binds the surface that matters, so none of it is remapped:
--
--     K       hover                 grn    rename
--     <C-]>   definition (tagfunc)  gra    code action
--     grr     references            gO     document symbols
--     gri     implementation        grt    type definition
--     ]d [d   next/prev diagnostic  <C-s>  signature help (insert mode)
--
-- `gd` / `gD` are NOT LSP: they are Vim's own text search for a declaration in the current
-- file. <C-]> is what follows the language server, because Neovim sets `tagfunc` to it.
-- Insert-mode <C-k> is blink.cmp's signature help (see plugins.lua).

-- Server name (as nvim-lspconfig knows it) -> the binary it needs on PATH.
--
-- Nothing installs these: install a server with the language's own toolchain (npm -g,
-- go install, dnf, GitHub release into ~/.local/bin) and it lights up on the next
-- launch -- no edit to this file.
local servers = {
  lua_ls = "lua-language-server",
  basedpyright = "basedpyright-langserver",
  ruff = "ruff",
  gopls = "gopls",
  vtsls = "vtsls",
  html = "vscode-html-language-server",
  cssls = "vscode-css-language-server",
  jsonls = "vscode-json-language-server",
  yamlls = "yaml-language-server",
  marksman = "marksman",
  dartls = "dart", -- ships with the Flutter/Dart SDK: `dart language-server`
}

-- kotlin-language-server bundles a Kotlin compiler built on IntelliJ's JavaVersion
-- parser, which cannot parse a Java major version above 21:
--
--     Exception in thread "main" java.lang.IllegalArgumentException: 25.0.3
--
-- Fedora 44 ships OpenJDK 25 and packages nothing older, so a JDK 17-21 has to be
-- dropped into ~/.local/jdk (verified with Temurin 21). If none is found the server is
-- left disabled rather than crashing on every .kt buffer.
local function usable_jdk()
  local candidates = {
    vim.fn.expand("~") .. "/.local/jdk/jdk-21*",
    vim.fn.expand("~") .. "/.local/jdk/jdk-17*",
    "/usr/lib/jvm/java-21-openjdk*",
    "/usr/lib/jvm/java-17-openjdk*",
  }
  -- Matched by path, not by running `java -version`: this is on the startup path and
  -- shelling out to every JVM on the box would cost real milliseconds.
  for _, pattern in ipairs(candidates) do
    for _, dir in ipairs(vim.fn.glob(pattern, false, true)) do
      if vim.fn.executable(dir .. "/bin/java") == 1 then
        return dir
      end
    end
  end
  return nil
end

local jdk = usable_jdk()
if jdk and vim.fn.executable("kotlin-language-server") == 1 then
  vim.lsp.config("kotlin_language_server", {
    cmd_env = { JAVA_HOME = jdk },
    -- An empty Lua table encodes as JSON `[]`. KLS parses initializationOptions with
    -- Gson as an object and dies with "Expected BEGIN_OBJECT but was BEGIN_ARRAY at
    -- path $" during initialize. A real field fixes the encoding (and the cache path).
    init_options = { storagePath = vim.fn.stdpath("cache") .. "/kotlin-language-server" },
  })
  servers.kotlin_language_server = "kotlin-language-server"
end

-- Every server gets blink.cmp's completion capabilities (snippets, resolve, etc.).
vim.lsp.config("*", {
  capabilities = require("blink.cmp").get_lsp_capabilities(),
})

-- lua_ls knows nothing about this config's own globals (vim, MiniIcons, ...). Pointing
-- it at the runtimepath removes the false "undefined global" warnings.
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = { enable = false },
    },
  },
})

-- Enable only servers whose binary actually exists. vim.lsp.enable() on a missing
-- command throws on every matching buffer open.
for name, binary in pairs(servers) do
  if vim.fn.executable(binary) == 1 then
    vim.lsp.enable(name)
  end
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end
    -- basedpyright owns hover; ruff only lints/formats. Two hovers on one `K` is noise.
    if client.name == "ruff" then
      client.server_capabilities.hoverProvider = false
    end
    -- Colour swatches next to Color(0xFF...) in Dart and hex literals in CSS.
    -- 0.12 signature: enable(enable, { bufnr, client_id }).
    if client:supports_method("textDocument/documentColor") then
      vim.lsp.document_color.enable(true, { bufnr = ev.buf, client_id = client.id })
    end
  end,
})

vim.diagnostic.config({
  virtual_text = { prefix = "●" },
  severity_sort = true,
  underline = true,
  update_in_insert = false,
  float = { border = "rounded", source = true },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "●",
      [vim.diagnostic.severity.WARN] = "●",
      [vim.diagnostic.severity.INFO] = "●",
      [vim.diagnostic.severity.HINT] = "●",
    },
  },
})
