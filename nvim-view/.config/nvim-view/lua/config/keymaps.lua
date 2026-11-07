local map = vim.keymap.set

map("n", "<leader>|", "<cmd>vsplit<cr>", { desc = "Split right" })
map("n", "<leader>-", "<cmd>split<cr>", { desc = "Split below" })
map("n", "<leader>x", function() Snacks.bufdelete() end, { desc = "Close buffer" })
map("n", "<leader>z", function() Snacks.zen() end, { desc = "Zen (centered)" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Alternate buffer" })
map("n", "<esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search" })
map("t", "<esc><esc>", [[<C-\><C-n>]], { desc = "Terminal normal mode" })
for _, k in ipairs({ "h", "j", "k", "l" }) do
  map({ "n", "t" }, "<C-" .. k .. ">", "<cmd>wincmd " .. k .. "<cr>", { desc = "Window " .. k })
end
map("n", "]q", "<cmd>cnext<cr>", { desc = "Next quickfix" })
map("n", "[q", "<cmd>cprev<cr>", { desc = "Prev quickfix" })
map("n", "<leader>q", "<cmd>copen<cr>", { desc = "Quickfix list" })
map("n", "<leader>um", function()
  require("render-markdown").buf_toggle()
end, { desc = "Toggle markdown render" })
map("n", "<leader>yp", function()
  vim.fn.setreg("+", vim.fn.expand("%:p")); vim.notify("Copied path")
end, { desc = "Copy file path" })
