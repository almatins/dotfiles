return {
  { "nvim-treesitter/nvim-treesitter", branch = "main", lazy = false, build = ":TSUpdate",
    config = function()
      local langs = { "markdown", "markdown_inline", "json", "yaml", "javascript", "typescript", "tsx",
        "go", "gomod", "python", "dart", "dockerfile", "bash", "lua", "vim", "vimdoc", "diff", "regex" }
      require("nvim-treesitter").install(langs)
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(ev)
          if pcall(vim.treesitter.start, ev.buf) then
            vim.bo[ev.buf].indentexpr = ""
          end
        end,
      })
    end },
}
