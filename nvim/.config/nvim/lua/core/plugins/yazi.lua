-- yazi.nvim 文件管理器插件配置
return {
  "mikavilpas/yazi.nvim",
  event = "VeryLazy",
  keys = {
    {
      "<leader>y",
      "<cmd>Yazi<cr>",
      desc = "打开 yazi 文件管理器",
    },
    {
      "<leader>Y",
      "<cmd>Yazi cwd<cr>",
      desc = "打开 yazi（当前工作目录）",
    },
  },
  opts = {
    -- 如果你想要一个浮动窗口而不是替换当前缓冲区
    -- 设置为 true 使用浮动窗口
    open_for_directories = false,
    -- 配置键位映射
    keymaps = {
      show_help = '<f1>',
      open_file_in_vertical_split = '<c-v>',
      open_file_in_horizontal_split = '<c-x>',
      open_file_in_tab = '<c-t>',
      grep_in_directory = '<c-s>',
      replace_in_directory = '<c-g>',
      cycle_open_buffers = '<tab>',
      copy_relative_path_to_selected_files = '<c-y>',
      send_to_quickfix_list = '<c-q>',
      change_working_directory = '<c-\\>',
    },
    -- 启用文件预览
    enable_mouse_support = true,
    -- yazi 的配置目录
    yazi_floating_window_winblend = 0,
    -- 关闭 yazi 后是否恢复最后一个缓冲区
    open_file_after_yazi_closes = true,
    -- 事件钩子
    hooks = {
      -- 在 yazi 关闭后触发
      yazi_closed_successfully = function(chosen_file, config, state)
        -- 如果选择了文件，可以在这里处理
        if chosen_file then
          vim.notify("选择了文件: " .. chosen_file, vim.log.levels.INFO)
        end
      end,
    },
  },
}