-- telescope.nvim 模糊搜索插件配置
return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    -- 可选：原生 FZF 排序器，提升性能
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    -- 可选：文件图标
    "nvim-tree/nvim-web-devicons",
  },
  cmd = "Telescope",
  keys = {
    -- 基础搜索
    {
      "<leader>tf",
      "<cmd>Telescope find_files<cr>",
      desc = "Telescope: 搜索文件",
    },
    {
      "<leader>tg",
      "<cmd>Telescope live_grep<cr>",
      desc = "Telescope: 实时搜索内容",
    },
    {
      "<leader>tb",
      "<cmd>Telescope buffers<cr>",
      desc = "Telescope: 搜索缓冲区",
    },
    {
      "<leader>th",
      "<cmd>Telescope help_tags<cr>",
      desc = "Telescope: 搜索帮助",
    },
    {
      "<leader>tr",
      "<cmd>Telescope oldfiles<cr>",
      desc = "Telescope: 最近文件",
    },
    {
      "<leader>tc",
      "<cmd>Telescope commands<cr>",
      desc = "Telescope: 搜索命令",
    },
    {
      "<leader>tk",
      "<cmd>Telescope keymaps<cr>",
      desc = "Telescope: 搜索键映射",
    },
    {
      "<leader>tm",
      "<cmd>Telescope marks<cr>",
      desc = "Telescope: 搜索标记",
    },
    {
      "<leader>tq",
      "<cmd>Telescope quickfix<cr>",
      desc = "Telescope: 快速修复列表",
    },
    {
      "<leader>tl",
      "<cmd>Telescope loclist<cr>",
      desc = "Telescope: 位置列表",
    },
    -- Git 相关搜索
    {
      "<leader>tgf",
      "<cmd>Telescope git_files<cr>",
      desc = "Telescope: Git 文件",
    },
    {
      "<leader>tgb",
      "<cmd>Telescope git_branches<cr>",
      desc = "Telescope: Git 分支",
    },
    {
      "<leader>tgc",
      "<cmd>Telescope git_commits<cr>",
      desc = "Telescope: Git 提交",
    },
    {
      "<leader>tgs",
      "<cmd>Telescope git_status<cr>",
      desc = "Telescope: Git 状态",
    },
    -- LSP 相关搜索
    {
      "<leader>tls",
      "<cmd>Telescope lsp_document_symbols<cr>",
      desc = "Telescope: 文档符号",
    },
    {
      "<leader>tlw",
      "<cmd>Telescope lsp_workspace_symbols<cr>",
      desc = "Telescope: 工作区符号",
    },
    {
      "<leader>tld",
      "<cmd>Telescope lsp_definitions<cr>",
      desc = "Telescope: 定义",
    },
    {
      "<leader>tlr",
      "<cmd>Telescope lsp_references<cr>",
      desc = "Telescope: 引用",
    },
    {
      "<leader>tli",
      "<cmd>Telescope lsp_implementations<cr>",
      desc = "Telescope: 实现",
    },
    {
      "<leader>tlt",
      "<cmd>Telescope lsp_type_definitions<cr>",
      desc = "Telescope: 类型定义",
    },
    -- 诊断
    {
      "<leader>td",
      "<cmd>Telescope diagnostics<cr>",
      desc = "Telescope: 诊断",
    },
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    
    telescope.setup({
      defaults = {
        -- 提示符
        prompt_prefix = "🔍 ",
        selection_caret = "➤ ",
        -- 搜索策略
        file_sorter = require("telescope.sorters").get_fuzzy_file,
        generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
        -- 路径显示
        path_display = { "truncate" },
        -- 文件忽略模式
        file_ignore_patterns = {
          "node_modules",
          ".git/",
          ".dart_tool/",
          ".idea/",
          ".vscode/",
          "dist/",
          "build/",
          "coverage/",
          ".DS_Store",
        },
        -- 布局配置
        layout_config = {
          horizontal = {
            preview_width = 0.6,
            results_width = 0.8,
          },
          vertical = {
            mirror = false,
          },
          width = 0.87,
          height = 0.80,
          preview_cutoff = 120,
        },
        -- 键位映射
        mappings = {
          i = {
            ["<C-n>"] = actions.cycle_history_next,
            ["<C-p>"] = actions.cycle_history_prev,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-c>"] = actions.close,
            ["<Down>"] = actions.move_selection_next,
            ["<Up>"] = actions.move_selection_previous,
            ["<CR>"] = actions.select_default,
            ["<C-x>"] = actions.select_horizontal,
            ["<C-v>"] = actions.select_vertical,
            ["<C-t>"] = actions.select_tab,
            ["<C-u>"] = actions.preview_scrolling_up,
            ["<C-d>"] = actions.preview_scrolling_down,
            ["<PageUp>"] = actions.results_scrolling_up,
            ["<PageDown>"] = actions.results_scrolling_down,
            ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
            ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
            ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
            ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
            ["<C-l>"] = actions.complete_tag,
            ["<C-_>"] = actions.which_key, -- keys from pressing <C-/>
          },
          n = {
            ["<esc>"] = actions.close,
            ["<CR>"] = actions.select_default,
            ["<C-x>"] = actions.select_horizontal,
            ["<C-v>"] = actions.select_vertical,
            ["<C-t>"] = actions.select_tab,
            ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
            ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
            ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
            ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
            ["j"] = actions.move_selection_next,
            ["k"] = actions.move_selection_previous,
            ["H"] = actions.move_to_top,
            ["M"] = actions.move_to_middle,
            ["L"] = actions.move_to_bottom,
            ["<Down>"] = actions.move_selection_next,
            ["<Up>"] = actions.move_selection_previous,
            ["gg"] = actions.move_to_top,
            ["G"] = actions.move_to_bottom,
            ["<C-u>"] = actions.preview_scrolling_up,
            ["<C-d>"] = actions.preview_scrolling_down,
            ["<PageUp>"] = actions.results_scrolling_up,
            ["<PageDown>"] = actions.results_scrolling_down,
            ["?"] = actions.which_key,
          },
        },
      },
      pickers = {
        -- 文件搜索器配置
        find_files = {
          -- 显示隐藏文件
          hidden = true,
          -- 搜索 .gitignore 中的文件
          no_ignore = false,
          -- 跟随符号链接
          follow = false,
        },
        -- 实时搜索配置
        live_grep = {
          additional_args = function(opts)
            return {"--hidden"}
          end
        },
        -- 缓冲区搜索配置
        buffers = {
          sort_lastused = true,
          theme = "dropdown",
          previewer = false,
          mappings = {
            i = {
              ["<c-d>"] = actions.delete_buffer,
            },
            n = {
              ["dd"] = actions.delete_buffer,
            },
          },
        },
        -- Git 文件搜索
        git_files = {
          show_untracked = true,
        },
      },
      extensions = {
        -- fzf 扩展配置
        fzf = {
          fuzzy = true,                    -- 启用模糊搜索
          override_generic_sorter = true,  -- 覆盖通用排序器
          override_file_sorter = true,     -- 覆盖文件排序器
          case_mode = "smart_case",        -- 智能大小写
        },
      },
    })
    
    -- 加载扩展
    telescope.load_extension("fzf")
    
    -- 添加自定义命令
    vim.api.nvim_create_user_command("TelescopeCurrentBuffer", function()
      require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
        winblend = 10,
        previewer = false,
      }))
    end, { desc = "在当前缓冲区中模糊搜索" })
    
    -- 绑定额外的键位映射
    vim.keymap.set("n", "<leader>t/", "<cmd>TelescopeCurrentBuffer<cr>", { desc = "Telescope: 当前缓冲区搜索" })
  end,
}