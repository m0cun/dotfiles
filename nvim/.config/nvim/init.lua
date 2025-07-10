-- 设置 leader 键为空格键
vim.g.mapleader = " "       -- 全局 leader 键
vim.g.maplocalleader = " "  -- 本地 leader 键

-- 自动安装 lazy.nvim 插件管理器
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",          -- 浅层克隆，不下载所有历史
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",             -- 使用稳定分支
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)      -- 将 lazy.nvim 添加到运行时路径

-- 加载核心配置模块
require("core.options")            -- 基本选项设置
require("core.keymaps")            -- 键位映射
require("core.autocmds")           -- 自动命令

-- 使用 lazy.nvim 设置插件
require("lazy").setup({
  { import = "core.plugins.colorscheme" },  -- 主题配置
  { import = "core.plugins.qol" },          -- 生活质量提升插件
  { import = "core.plugins.statusline" },   -- 状态栏
  { import = "core.plugins.git" },          -- Git 相关插件
  { import = "core.plugins.completion" },   -- 代码补全
  { import = "core.plugins.multicursor" },  -- 多光标支持
  { import = "core.plugins.formatting" },   -- 代码格式化
  { import = "core.plugins.linting" },      -- 代码检查
  { import = "core.plugins.treesitter" },   -- 语法高亮和解析
  { import = "core.plugins.yazi" },         -- yazi 文件管理器
  { import = "core.plugins.telescope" },    -- telescope 模糊搜索
  { import = "core.plugins.mini" },         -- mini.nvim 插件集合
  { import = "core.plugins.which-key" },    -- which-key 快捷键提示
})

-- 加载 LSP 配置
require("core.lsp")
