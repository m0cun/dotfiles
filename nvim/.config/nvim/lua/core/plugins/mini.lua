-- mini.nvim 缩进范围可视化插件配置
return {
  "echasnovski/mini.nvim",
  version = false, -- 使用 main 分支
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    -- mini.indentscope：可视化和操作缩进范围
    require("mini.indentscope").setup({
      -- 绘制配置
      draw = {
        -- 延迟绘制（毫秒）
        delay = 100,
        -- 动画规则：提供更流畅的体验
        animation = require("mini.indentscope").gen_animation.none(),
        -- 优先级（用于与其他插件的兼容性）
        priority = 2,
      },
      -- 映射配置
      mappings = {
        -- 文本对象
        object_scope = "ii",      -- 内部缩进范围
        object_scope_with_border = "ai", -- 包含边界的缩进范围
        -- 移动操作
        goto_top = "[i",          -- 跳转到范围顶部
        goto_bottom = "]i",       -- 跳转到范围底部
      },
      -- 选项
      options = {
        -- 尝试作为边界的缩进类型
        border = "both",          -- 'both', 'top', 'bottom', 'none'
        -- 是否在第一列和最后一列绘制
        indent_at_cursor = true,
        -- 是否在空行上绘制
        try_as_border = false,
      },
      -- 符号配置
      symbol = "│",              -- 缩进线符号
    })
    
    -- 自定义高亮组
    vim.api.nvim_set_hl(0, "MiniIndentscopeSymbol", { fg = "#61afef" })
    
    -- 在某些文件类型中禁用
    vim.api.nvim_create_autocmd("FileType", {
      pattern = {
        "help",
        "alpha",
        "dashboard",
        "neo-tree",
        "Trouble",
        "lazy",
        "mason",
        "notify",
        "toggleterm",
        "lazyterm",
        "TelescopePrompt",
        "telescope",
        "fzf",
        "terminal",
        "prompt",
        "NvimTree",
        "packer",
        "lspinfo",
        "null-ls-info",
        "quickfix",
        "checkhealth",
        "man",
        "gitcommit",
        "gitrebase",
        "svn",
        "hgcommit",
        "startuptime",
        "oil",
        "yazi",
      },
      callback = function()
        vim.b.miniindentscope_disable = true
      end,
    })
    
    -- 可选：添加 mini.surround 用于快速包围操作
    require("mini.surround").setup({
      -- 添加/删除/替换包围的映射
      mappings = {
        add = "sa",            -- 添加包围 (如: sa"w 为单词添加双引号)
        delete = "sd",         -- 删除包围 (如: sd" 删除双引号)
        find = "sf",           -- 查找右侧包围
        find_left = "sF",      -- 查找左侧包围
        highlight = "sh",      -- 高亮包围
        replace = "sr",        -- 替换包围 (如: sr"' 将双引号替换为单引号)
        update_n_lines = "sn", -- 更新搜索的行数
      },
    })
    
    -- 可选：添加 mini.pairs 用于自动配对
    require("mini.pairs").setup({
      -- 在这些模式下激活
      modes = { insert = true, command = false, terminal = false },
      -- 全局映射
      mappings = {
        ["("] = { action = "open", pair = "()", neigh_pattern = "[^\\]" },
        ["["] = { action = "open", pair = "[]", neigh_pattern = "[^\\]" },
        ["{"] = { action = "open", pair = "{}", neigh_pattern = "[^\\]" },
        [")"] = { action = "close", pair = "()", neigh_pattern = "[^\\]" },
        ["]"] = { action = "close", pair = "[]", neigh_pattern = "[^\\]" },
        ["}"] = { action = "close", pair = "{}", neigh_pattern = "[^\\]" },
        ['"'] = { action = "closeopen", pair = '""', neigh_pattern = "[^\\]", register = { cr = false } },
        ["'"] = { action = "closeopen", pair = "''", neigh_pattern = "[^%a\\]", register = { cr = false } },
        ["`"] = { action = "closeopen", pair = "``", neigh_pattern = "[^\\]", register = { cr = false } },
      },
    })
    
    -- 可选：添加 mini.comment 用于注释
    require("mini.comment").setup({
      options = {
        -- 自定义注释字符串计算函数
        custom_commentstring = function()
          return require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo.commentstring
        end,
        -- 忽略空行
        ignore_blank_line = false,
        -- 开始注释后是否添加空格
        start_of_line = false,
        -- 填充注释字符串
        pad_comment_parts = true,
      },
      mappings = {
        -- 切换注释
        comment = "gc",
        -- 切换行注释
        comment_line = "gcc",
        -- 添加注释
        comment_visual = "gc",
        -- 文本对象
        textobject = "gc",
      },
    })
    
    -- 可选：添加 mini.move 用于移动选中的文本
    require("mini.move").setup({
      mappings = {
        -- 移动视觉选择
        left = "<M-h>",
        right = "<M-l>",
        down = "<M-j>",
        up = "<M-k>",
        -- 移动当前行
        line_left = "<M-h>",
        line_right = "<M-l>",
        line_down = "<M-j>",
        line_up = "<M-k>",
      },
      options = {
        -- 自动重新缩进移动的文本
        reindent_linewise = true,
      },
    })
    
    -- 可选：添加 mini.ai 用于增强的文本对象
    require("mini.ai").setup({
      -- 自定义文本对象
      custom_textobjects = {
        o = require("mini.ai").gen_spec.treesitter({
          a = { "@block.outer", "@conditional.outer", "@loop.outer" },
          i = { "@block.inner", "@conditional.inner", "@loop.inner" },
        }),
        f = require("mini.ai").gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
        c = require("mini.ai").gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
      },
      -- 搜索方法
      search_method = "cover_or_next",
      -- 是否静默无效的文本对象
      silent = false,
    })
  end,
}