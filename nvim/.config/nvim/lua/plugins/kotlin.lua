-- kotlin-language-server bundles the Kotlin compiler, which uses IntelliJ's
-- JavaVersion parser. That parser cannot parse a Java major version of 25:
--
--     Exception in thread "main" java.lang.IllegalArgumentException: 25.0.3
--         at com.intellij.util.lang.JavaVersion.parse(JavaVersion.java:307)
--
-- Fedora ships OpenJDK 25 and nothing older, so the server dies with exit code 1 the
-- instant a .kt buffer opens. It is not misconfigured — it is incompatible.
--
-- Fix: run it under a JDK it can actually parse. Install one with
--
--     sudo dnf install java-21-openjdk-devel
--
-- and this file finds it automatically. Until then the server is left unstarted: a
-- server that crashes on every buffer is worse than no server, because the failure
-- notification fires every single time you open a file.

---@return string|nil path to a JDK the Kotlin language server can run under
local function usable_jdk()
  -- Matched by name rather than by running `java -version` on each candidate: this
  -- runs at startup, and shelling out to every JVM on the box to ask its version
  -- would put subprocesses on the critical path of every launch.
  for _, pattern in ipairs({ "java-21-openjdk*", "java-17-openjdk*" }) do
    for _, dir in ipairs(vim.fn.glob("/usr/lib/jvm/" .. pattern, false, true)) do
      if vim.fn.executable(dir .. "/bin/java") == 1 then
        return dir
      end
    end
  end
  return nil
end

local jdk = usable_jdk()

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        kotlin_language_server = jdk and {
          cmd_env = { JAVA_HOME = jdk },
        } or {},
      },
      setup = {
        kotlin_language_server = function()
          if not jdk then
            -- Returning true tells LazyVim "handled — skip your default setup", which
            -- here means: do not start it at all.
            return true
          end
        end,
      },
    },
  },
}
