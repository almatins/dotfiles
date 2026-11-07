return {
  { "MeanderingProgrammer/render-markdown.nvim", ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" },
    opts = {
      anti_conceal = { enabled = true },
      heading = { sign = false, width = "block", left_pad = 1, right_pad = 1 },
      code = { sign = false, width = "block", left_pad = 1, right_pad = 1, border = "thin" },
      pipe_table = { preset = "round", cell = "padded" },
      win_options = { conceallevel = { default = 0, rendered = 2 } },
    } },
}
