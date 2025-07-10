-- 更好的上下移动：在长行中按显示行移动而不是实际行
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- 使用 Ctrl + 方向键在窗口间移动
vim.keymap.set("n", "<C-Left>", "<C-w>h", { desc = "移动到左侧窗口", remap = true })
vim.keymap.set("n", "<C-Down>", "<C-w>j", { desc = "移动到下方窗口", remap = true })
vim.keymap.set("n", "<C-Up>", "<C-w>k", { desc = "移动到上方窗口", remap = true })
vim.keymap.set("n", "<C-Right>", "<C-w>l", { desc = "移动到右侧窗口", remap = true })

-- 使用 Ctrl + hjkl 在窗口间移动
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "移动到左侧窗口", remap = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "移动到下方窗口", remap = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "移动到上方窗口", remap = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "移动到右侧窗口", remap = true })

-- 使用 Shift + 方向键调整窗口大小
vim.keymap.set("n", "<S-Up>", "<cmd>resize +2<cr>", { desc = "增加窗口高度" })
vim.keymap.set("n", "<S-Down>", "<cmd>resize -2<cr>", { desc = "减少窗口高度" })
vim.keymap.set("n", "<S-Left>", "<cmd>vertical resize -2<cr>", { desc = "减少窗口宽度" })
vim.keymap.set("n", "<S-Right>", "<cmd>vertical resize +2<cr>", { desc = "增加窗口宽度" })

-- 在缓冲区间切换
vim.keymap.set("n", "<TAB>", ":bn<CR>", { desc = "下一个缓冲区" })
vim.keymap.set("n", "<S-TAB>", ":bp<CR>", { desc = "上一个缓冲区" })

-- 移动代码行 (Alt + j/k)
vim.keymap.set("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "向下移动行" })
vim.keymap.set("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "向上移动行" })
vim.keymap.set("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "向下移动行" })
vim.keymap.set("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "向上移动行" })
vim.keymap.set("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "向下移动选中行" })
vim.keymap.set("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "向上移动选中行" })

-- 更好的缩进：保持选中状态
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- 用 ESC 清除搜索高亮
vim.keymap.set({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "ESC 并清除搜索高亮" })

-- 快速添加围绕字符（括号、引号等）
vim.keymap.set("v", "gs(", "<esc>`>a)<esc>`<i(<esc>", { desc = "在选中内容周围添加 ()" })
vim.keymap.set("v", "gs)", "<esc>`>a)<esc>`<i(<esc>", { desc = "在选中内容周围添加 ()" })
vim.keymap.set("v", "gs{", "<esc>`>a}<esc>`<i{<esc>", { desc = "在选中内容周围添加 {}" })
vim.keymap.set("v", "gs}", "<esc>`>a}<esc>`<i{<esc>", { desc = "在选中内容周围添加 {}" })
vim.keymap.set("v", "gs[", "<esc>`>a]<esc>`<i[<esc>", { desc = "在选中内容周围添加 []" })
vim.keymap.set("v", "gs]", "<esc>`>a]<esc>`<i[<esc>", { desc = "在选中内容周围添加 []" })
vim.keymap.set("v", "gs<", "<esc>`>a><esc>`<i<<esc>", { desc = "在选中内容周围添加 <>" })
vim.keymap.set("v", "gs>", "<esc>`>a><esc>`<i<<esc>", { desc = "在选中内容周围添加 <>" })
vim.keymap.set("v", 'gs"', '<esc>`>a"<esc>`<i"<esc>', { desc = '在选中内容周围添加 ""' })
vim.keymap.set("v", "gs'", "<esc>`>a'<esc>`<i'<esc>", { desc = "在选中内容周围添加 ''" })
vim.keymap.set("v", "gs`", "<esc>`>a`<esc>`<i`<esc>", { desc = "在选中内容周围添加 ``" })

-- 搜索和替换快捷键
vim.keymap.set("n", "<leader>rr", [[:%s///gcI<Left><Left><Left><Left><Left>]], { desc = "在缓冲区中替换" })
vim.keymap.set(
  "n",
  "<leader>rw",
  [[:%s/\<<C-r><C-w>\>//gcI<Left><Left><Left><Left>]],
  { desc = "在缓冲区中替换当前单词" }
)
vim.keymap.set(
  "n",
  "<leader>rR",
  [[:cfdo %s///gcI | update]]
    .. [[<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left>]],
  { desc = "在快速修复列表中替换" }
)
vim.keymap.set(
  "n",
  "<leader>rW",
  [[:cfdo %s/\<<C-r><C-w>\>//gcI | update]]
    .. [[<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left>]],
  { desc = "在快速修复列表中替换当前单词" }
)

-- ===== 新增插件键位映射 =====

-- Yazi 文件管理器
vim.keymap.set("n", "<leader>y", "<cmd>Yazi<cr>", { desc = "打开 yazi 文件管理器" })
vim.keymap.set("n", "<leader>Y", "<cmd>Yazi cwd<cr>", { desc = "打开 yazi（当前工作目录）" })

-- Telescope 模糊搜索 - 主要功能
vim.keymap.set("n", "<leader>tf", "<cmd>Telescope find_files<cr>", { desc = "Telescope: 搜索文件" })
vim.keymap.set("n", "<leader>tg", "<cmd>Telescope live_grep<cr>", { desc = "Telescope: 实时搜索内容" })
vim.keymap.set("n", "<leader>tb", "<cmd>Telescope buffers<cr>", { desc = "Telescope: 搜索缓冲区" })
vim.keymap.set("n", "<leader>th", "<cmd>Telescope help_tags<cr>", { desc = "Telescope: 搜索帮助" })
vim.keymap.set("n", "<leader>tr", "<cmd>Telescope oldfiles<cr>", { desc = "Telescope: 最近文件" })
vim.keymap.set("n", "<leader>t/", "<cmd>TelescopeCurrentBuffer<cr>", { desc = "Telescope: 当前缓冲区搜索" })

-- Mini.nvim 快捷键说明
-- 缩进范围操作 (mini.indentscope)：
-- ii - 选择内部缩进范围
-- ai - 选择包含边界的缩进范围  
-- [i - 跳转到缩进范围顶部
-- ]i - 跳转到缩进范围底部

-- 包围操作 (mini.surround)：
-- sa - 添加包围 (如: sa"w 为单词添加双引号)
-- sd - 删除包围 (如: sd" 删除双引号)
-- sr - 替换包围 (如: sr"' 将双引号替换为单引号)
-- sf - 查找右侧包围
-- sF - 查找左侧包围
-- sh - 高亮包围

-- 注释操作 (mini.comment)：
-- gc - 切换注释
-- gcc - 切换行注释

-- 移动操作 (mini.move)：
-- <M-h> - 向左移动
-- <M-l> - 向右移动
-- <M-j> - 向下移动
-- <M-k> - 向上移动
