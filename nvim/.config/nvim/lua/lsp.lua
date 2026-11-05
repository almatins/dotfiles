-- LSP.
--
-- Neovim 0.11+ already binds the surface that matters, so none of it is remapped:
--
--     K       hover                 grn    rename
--     gd      definition            gra    code action
--     gr      references            gO     document symbols
--     gI      implementation        gD     declaration
--     gy      type definition       C-s    signature help (insert mode, built in)
--     ]d [d   next/prev diagnostic
--
-- C-s is why ~/.bashrc runs `stty -ixon`: with flow control on the terminal eats it.

-- Server name (as nvim-lspconfig knows it) -> the binary it needs on PATH.
--
-- Nothing installs these any more: Mason is gone by design. Install a server with the
-- language's own toolchain (npm -g, go install, uv tool install, GitHub release into
-- ~/.local/bin) and it lights up on the next launch -- no edit to this file.
local servers = {
  lua_ls = "lua-language-server",
  vtsls = "vtsls",
  gopls = "gopls",
  basedpyright = "basedpyright-langserver",
  jsonls = "vscode-json-language-server",
  yamlls = "yaml-language-server",
  bashls = "bash-language-server",
  dockerls = "docker-langserver",
}

-- kotlin-language-server bundles a Kotlin compiler built on IntelliJ's JavaVersion
-- parser, which cannot parse a Java major version above 21:
--
--     Exception in thread "main" java.lang.IllegalArgumentException: 25.0.3
--
-- Fedora 44 ships OpenJDK 25 and packages nothing older, and Android Studio now bundles
-- 25 as well (~/.local/opt/android-studio/jbr), so neither works. A JDK 17-21 dropped
-- into ~/.local/jdk is the only thing that starts the server: verified with Temurin 21.
-- If none is found the server is left disabled rather than left to crash on every .kt
-- buffer, which is worse than no server at all.
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

-- Enable only servers whose binary actually exists. vim.lsp.enable() on a missing
-- command throws on every matching buffer open, which is unbearable.
for name, binary in pairs(servers) do
  if vim.fn.executable(binary) == 1 then
    vim.lsp.enable(name)
  end
end

-- lua_ls knows nothing about this config's own globals (vim, MiniIcons, Snacks, ...).
-- Pointing it at the runtimepath plus this repo removes the false "undefined global".
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

-- Completion is built into 0.11+: no nvim-cmp, no blink.cmp, no snippet engine.
-- vim.snippet (also built in) expands LSP snippet items.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end
    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
    -- Colour swatches next to Color(0xFF...) in Dart and hex literals in CSS.
    -- 0.12 signature: enable(enable, { bufnr, client_id }) — passing a bare buffer
    -- number here fails validation.
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
