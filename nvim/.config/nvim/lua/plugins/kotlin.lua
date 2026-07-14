-- kotlin-language-server bundles the Kotlin compiler, which uses IntelliJ's
-- JavaVersion parser. That parser cannot parse a Java major version of 25:
--
--     Exception in thread "main" java.lang.IllegalArgumentException: 25.0.3
--         at com.intellij.util.lang.JavaVersion.parse(JavaVersion.java:307)
--
-- Fedora 44 ships OpenJDK 25 and packages NOTHING older — `dnf install
-- java-21-openjdk-devel` fails with "No match for argument". So the server dies with
-- exit code 1 the instant a .kt buffer opens. It is not misconfigured; it is
-- incompatible with the only JDK in the distro's repos.
--
-- The way out is the JDK that is already here: Android Studio bundles JetBrains Runtime
-- 21 at /opt/android-studio/jbr, and Flutter already uses it as its Java toolchain
-- (`flutter doctor -v` names it). Verified: the Kotlin server starts cleanly under it.
--
-- If Android Studio ever moves or goes away, drop any JDK 17–21 into ~/.local/jdk and
-- this picks it up. If none is found the server is left unstarted rather than started
-- to crash — a server that dies on every buffer is worse than no server, because the
-- failure notification then fires every single time you open a file.

---@return string|nil path to a JDK the Kotlin language server can actually run under
local function usable_jdk()
  local candidates = {
    "/opt/android-studio/jbr", -- what Flutter already uses; JBR 21
    vim.fn.expand("~") .. "/.local/jdk/jdk-21*",
    vim.fn.expand("~") .. "/.local/jdk/jdk-17*",
    "/usr/lib/jvm/java-21-openjdk*",
    "/usr/lib/jvm/java-17-openjdk*",
  }
  -- Matched by path rather than by running `java -version` on each candidate: this runs
  -- at startup, and shelling out to every JVM on the box would put subprocesses on the
  -- critical path of every launch.
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
