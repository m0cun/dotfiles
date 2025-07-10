return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  config = function()
    require("which-key").setup({
      win = {
        border = "rounded", -- a nice rounded border
        winblend = 0, -- transparency of the window
      },
      layout = {
        spacing = 6, -- space between columns
      },
    })
  end,
}