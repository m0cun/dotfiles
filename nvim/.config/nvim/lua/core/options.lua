-- 禁用不需要的内置插件以提升启动速度
vim.g.loaded_gzip = 1                  -- 禁用 gzip 压缩插件
vim.g.loaded_tar = 1                   -- 禁用 tar 文件处理插件
vim.g.loaded_tarPlugin = 1             -- 禁用 tar 插件扩展
vim.g.loaded_zip = 1                   -- 禁用 zip 文件处理插件
vim.g.loaded_zipPlugin = 1             -- 禁用 zip 插件扩展
vim.g.loaded_getscript = 1             -- 禁用脚本获取插件
vim.g.loaded_getscriptPlugin = 1       -- 禁用脚本获取插件扩展
vim.g.loaded_vimball = 1               -- 禁用 vimball 插件
vim.g.loaded_vimballPlugin = 1         -- 禁用 vimball 插件扩展
vim.g.loaded_matchit = 1               -- 禁用 matchit 插件（括号匹配）
vim.g.loaded_matchparen = 1            -- 禁用括号匹配高亮
vim.g.loaded_2html_plugin = 1          -- 禁用转换为 HTML 的插件
vim.g.loaded_logiPat = 1               -- 禁用逻辑模式插件
vim.g.loaded_rrhelper = 1              -- 禁用 rrhelper 插件
vim.g.loaded_netrw = 1                 -- 禁用内置文件浏览器 netrw
vim.g.loaded_netrwPlugin = 1           -- 禁用 netrw 插件扩展
vim.g.loaded_netrwSettings = 1         -- 禁用 netrw 设置
vim.g.loaded_netrwFileHandlers = 1     -- 禁用 netrw 文件处理器

-- 一些基础设置
vim.cmd([[
  set noswapfile      " 禁用交换文件
  set shortmess=I     " 简化消息显示，不显示启动画面
]])

-- 终端光标样式设置
vim.cmd([[let &t_Cs = "\e[4:3m"]])  -- 设置光标下划线样式
vim.cmd([[let &t_Ce = "\e[4:0m"]])  -- 重置光标样式

-- 基本选项设置
vim.opt.background = "dark"                          -- 设置背景为暗色主题
vim.opt.clipboard = "unnamedplus"                    -- 与系统剪贴板同步
vim.opt.completeopt = "menu,menuone,noselect"        -- 更好的补全体验
vim.opt.cursorline = true                            -- 高亮当前行
vim.opt.expandtab = true                             -- 使用空格代替制表符
vim.opt.exrc = true                                  -- 在项目目录中查找 .nvim.lua 文件

-- 代码折叠设置
vim.opt.foldcolumn = "0"                             -- 折叠列宽度为 0
vim.opt.foldenable = true                            -- 启用代码折叠
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()" -- 使用 treesitter 折叠表达式
vim.opt.foldlevel = 99                               -- 默认展开所有折叠
vim.opt.foldlevelstart = 99                          -- 文件打开时的折叠级别
vim.opt.foldmethod = "expr"                          -- 使用表达式折叠方法
vim.opt.foldtext = ""                                -- 自定义折叠文本

-- 格式化和搜索设置
vim.opt.formatoptions = "jcroqlnt"                   -- 格式化选项设置
vim.opt.hlsearch = true                              -- 搜索时高亮匹配项
vim.opt.ignorecase = true                            -- 搜索时忽略大小写
vim.opt.inccommand = "split"                         -- 实时显示替换预览
vim.opt.laststatus = 3                               -- 全局状态栏

-- 不可见字符显示（已注释）
-- vim.opt.list = true                               -- 显示一些不可见字符
-- vim.opt.listchars = { space = '·', tab = '▸ ', trail = '·', eol = '↵', nbsp = '_' } -- 设置不可见字符的显示方式

-- 交互设置
vim.opt.mouse = "a"                                  -- 启用鼠标模式
vim.opt.number = true                                -- 显示行号
vim.opt.relativenumber = true                        -- 显示相对行号

-- 滚动和缩进设置
vim.opt.scrolloff = 4                                -- 上下滚动时保持的行数
vim.opt.shiftround = true                            -- 缩进取整
vim.opt.shiftwidth = 2                               -- 缩进大小
vim.opt.showtabline = 0                              -- 禁用标签页栏
vim.opt.sidescrolloff = 8                            -- 左右滚动时保持的列数
vim.opt.signcolumn = "yes"                           -- 始终显示符号列

-- 大小写和缩进智能处理
vim.opt.smartcase = true                             -- 包含大写字母时不忽略大小写
vim.opt.smartindent = true                           -- 自动插入缩进

-- 拼写检查设置
vim.opt.spell = false                                -- 禁用拼写检查
vim.opt.spelllang = { "en_us" }                      -- 拼写检查语言

-- 窗口分割设置
vim.opt.splitbelow = true                            -- 新窗口在下方打开
vim.opt.splitkeep = "screen"                         -- 保持屏幕位置
vim.opt.splitright = true                            -- 新窗口在右侧打开

-- 制表符和颜色设置
vim.opt.tabstop = 2                                  -- 制表符显示宽度
vim.opt.termguicolors = true                         -- 真彩色支持

-- 超时设置
vim.opt.timeout = false                              -- 禁用键序列超时
vim.opt.timeoutlen = 300                             -- 键序列超时时间

-- 撤销和更新设置
vim.opt.undofile = true                              -- 启用撤销文件
vim.opt.undolevels = 10000                           -- 撤销级别
vim.opt.updatetime = 200                             -- 保存交换文件和触发 CursorHold 的时间

-- 显示设置
vim.opt.wrap = false                                 -- 禁用自动换行
vim.opt.winborder = "none"                           -- 窗口边框样式

-- diff 比较选项设置
vim.opt.diffopt = {
  "internal",          -- 使用内部 diff 算法
  "filler",           -- 在删除行显示填充行
  "closeoff",         -- 在一个窗口退出 diff 模式时，关闭其他 diff 窗口
  "context:12",       -- 显示 12 行上下文
  "algorithm:histogram", -- 使用 histogram 算法进行 diff
  "linematch:200",    -- 匹配相似行的限制
  "indent-heuristic", -- 使用缩进启发式算法
}

-- 诊断配置
local icons = require("utils").icons  -- 获取图标配置

-- 配置诊断显示
vim.diagnostic.config({
  underline = true,           -- 在诊断位置显示下划线
  update_in_insert = false,   -- 插入模式下不更新诊断
  virtual_text = {            -- 虚拟文本设置
    spacing = 4,              -- 诊断文本前的空格数
    source = "if_many",       -- 当有多个来源时显示来源
    -- prefix = "●",          -- 诊断前缀（已注释）
    prefix = function(diagnostic)  -- 动态设置诊断前缀图标
      for d, icon in pairs(icons.diagnostics) do
        if diagnostic.severity == vim.diagnostic.severity[d:upper()] then
          return icon
        end
      end
    end,
    format = function(diagnostic)  -- 格式化诊断消息
      -- 将换行符和制表符替换为空格，使诊断更紧凑
      local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
      return message
    end,
  },
  -- virtual_lines = true,    -- 虚拟行显示（已注释）
  severity_sort = true,       -- 按严重性排序诊断
  signs = {                   -- 符号设置
    text = {                  -- 诊断符号文本
      [vim.diagnostic.severity.HINT] = icons.diagnostics.Hint,
      [vim.diagnostic.severity.INFO] = icons.diagnostics.Info,
      [vim.diagnostic.severity.WARN] = icons.diagnostics.Warn,
      [vim.diagnostic.severity.ERROR] = icons.diagnostics.Error,
    },
    linehl = {                -- 行高亮设置
      [vim.diagnostic.severity.HINT] = "DiagnosticHint",
      [vim.diagnostic.severity.INFO] = "DiagnosticInfo",
      [vim.diagnostic.severity.WARN] = "DiagnosticWarn",
      [vim.diagnostic.severity.ERROR] = "DiagnosticError",
    },
  },
})

-- 为每种诊断类型定义符号
for _, type in ipairs({ "Error", "Warn", "Hint", "Info" }) do
  vim.fn.sign_define(
    "DiagnosticSign" .. type,
    { 
      name = "DiagnosticSign" .. type, 
      text = icons.diagnostics[type], 
      texthl = "Diagnostic" .. type 
    }
  )
end
