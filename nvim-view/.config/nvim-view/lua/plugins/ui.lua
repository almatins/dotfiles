return {
  { "folke/tokyonight.nvim", lazy = false, priority = 1000,
    config = function() vim.cmd.colorscheme("tokyonight-night") end },
  { "echasnovski/mini.icons", lazy = true, opts = {},
    init = function() package.preload["nvim-web-devicons"] = function()
      require("mini.icons").mock_nvim_web_devicons(); return package.loaded["nvim-web-devicons"] end end },
  { "folke/which-key.nvim", event = "VeryLazy", opts = {
    spec = {
      { "<leader>s", group = "search" }, { "<leader>f", group = "file" },
      { "<leader>g", group = "git" }, { "<leader>b", group = "buffer" },
      { "<leader>u", group = "toggle" }, { "<leader>F", group = "flutter" },
      { "<leader>D", group = "docker" }, { "<leader>y", group = "yank" },
    } } },
  { "nvim-treesitter/nvim-treesitter-context", event = "BufReadPost",
    opts = { max_lines = 3, multiline_threshold = 1 } },
  { "lewis6991/gitsigns.nvim", event = "BufReadPost", opts = {
    on_attach = function(b)
      local gs = require("gitsigns")
      local m = function(k, f, d) vim.keymap.set("n", k, f, { buffer = b, desc = d }) end
      m("]h", function() gs.nav_hunk("next") end, "Next hunk")
      m("[h", function() gs.nav_hunk("prev") end, "Prev hunk")
      m("<leader>gh", gs.preview_hunk, "Preview hunk")
      m("<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line")
      m("<leader>gd", gs.diffthis, "Diff this")
    end } },
}
