# Dotfiles

这是我的个人dotfiles配置仓库，使用GNU stow管理。

## 内容

- `zsh`: ZSH配置文件，包括模块化的配置、别名、函数等
- `starship`: Starship提示符配置
- `nvim`: Neovim配置
- `kitty`: Kitty终端配置
- `helix`: Helix编辑器配置
- `bat`: Bat查看器配置
- `lsd`: LSD (LSDeluxe) 配置
- `yazi`: Yazi文件管理器配置
- `zellij`: Zellij终端复用器配置
- `tssh`: 支持传输文件的 SSH 客户端配置
- `delta`: Delta Git 增强差异查看器配置

## 安装

### 自动安装（推荐）

提供了自动化安装脚本，可以一键设置所有配置：

```bash
# 克隆仓库（包括所有子模块）
git clone --recurse-submodules https://github.com/m0cun/dotfiles.git ~/.dotfile
cd ~/.dotfile

# 运行安装脚本
./install.sh
```

此脚本将：
- 检测您的操作系统（支持 macOS、Ubuntu、Kali Linux 等）
- 检查并设置 ZSH 为默认 shell
- 安装 Homebrew（如果是 macOS）
- 安装 Rust 和 Go 编程语言环境
- 安装必要的依赖（git、stow 等）
- 安装推荐的软件：
  - starship: 跨 shell 的提示符
  - neovim: 现代化的 vim 编辑器
  - helix: 基于 Rust 的现代化编辑器
  - bat: cat 命令的增强版
  - lsd: ls 命令的增强版
  - yazi: 终端文件管理器
  - zellij: 终端复用器
  - git-delta: 语法高亮的 Git 差异查看器
  - fd: 现代化的 find 替代品
  - ripgrep: 现代化的 grep 替代品
  - fzf: 模糊查找工具
  - zoxide: 智能目录跳转工具
  - jq: JSON 处理工具
  - Hack Nerd Font: 编程字体（所有系统）
  - tssh: 支持传输文件的 SSH 客户端
  - jenv: Java 版本管理工具
  - fnm: Node.js 版本管理工具
  - nexttrace: 现代化路由追踪工具
  - exiftool: 元数据查看和编辑工具
  - dua: 磁盘使用分析工具
  - ouch: 现代化解压缩工具
  - uv: 现代化 Python 包管理工具（macOS 上通过 brew 安装）
  - tcping: TCP 连接测试工具
  - gohttpserver: 高性能 HTTP 文件服务器
  - git-delta: 语法高亮的 Git 差异查看器，自动配置到 Git 中
- 创建所需目录结构
- 安装/更新 ZSH 插件（作为 Git 子模块）
- 使用 stow 创建符号链接

特定系统安装的工具：
- macOS: trash, kitty, duf（磁盘使用情况查看器）
- Linux: trash-put（trash-cli 包的一部分）

注意：Kitty 终端在 macOS 上会被自动安装，而在 Linux 上不会被自动安装，但如果已安装则会创建其配置的符号链接。

### 手动安装

如果您更喜欢手动安装，可以按照以下步骤操作：

#### 前提条件

- Git
- GNU Stow (`brew install stow` 或 `apt install stow`)

#### 克隆仓库

```bash
git clone --recurse-submodules https://github.com/m0cun/dotfiles.git ~/.dotfile
cd ~/.dotfile
```

#### 使用Stow创建符号链接

```bash
# 安装所有配置
stow */

# 或者只安装特定配置
stow zsh
stow nvim
# 等等
```

## 更新配置

可以使用更新脚本来更新已安装的配置：

```bash
cd ~/.dotfile
./update.sh
```

此脚本将：
- 检测您的操作系统
- 更新系统包和工具（包括 Rust 和 Go 工具）
- 更新 Python 工具（如 uv，在 macOS 上通过 brew 更新）
- 更新版本管理工具（jenv, fnm）
- 更新 dotfiles 仓库
- 更新所有 ZSH 插件（作为 Git 子模块）
- 重新应用符号链接

也可以手动更新：

```bash
cd ~/.dotfile
git pull
git submodule update --remote --recursive  # 更新所有子模块到最新版本
```

## Git 子模块

本仓库使用 Git 子模块管理 ZSH 插件，包括：

- fast-syntax-highlighting: 语法高亮
- zsh-autosuggestions: 自动补全建议
- zsh-history-substring-search: 历史搜索
- zsh-you-should-use: 别名提示
- forgit: 增强 git 操作
- fzf-tab: 增强的 Tab 补全

如果您没有使用 `--recurse-submodules` 选项克隆仓库，可以手动初始化和更新子模块：

```bash
git submodule init
git submodule update --recursive
```

## ZSH配置说明

ZSH配置采用模块化设计，便于管理和自定义：

- `zsh/.zshrc`: 主配置文件，加载所有模块
- `zsh/.zprofile`: 登录shell初始化
- `zsh/.config/zsh/configs/`: 包含各个功能模块的配置
  - `os-detection.zsh`: 操作系统检测（支持macOS、Linux，包括Ubuntu和Kali Linux）
  - `history.zsh`: 历史记录配置
  - `completion.zsh`: 补全系统配置
  - `prompt.zsh`: 提示符配置
  - `plugins.zsh`: 插件管理
  - `aliases.zsh`: 通用别名
  - `exports.zsh`: 环境变量设置
  - `functions.zsh`: 实用函数
  - `os-specific/`: 特定操作系统的配置
    - `macos.zsh`: macOS特定配置
    - `linux.zsh`: Linux特定配置
    - `exports-macos.zsh`: macOS特定环境变量（包含程序存在性检查）
    - `exports-linux.zsh`: Linux特定环境变量
  - `local_configs/`: 本地配置目录（不包含在版本控制中）
    - `local-exports.zsh`: 本地特定的环境变量
    - `local-aliases.zsh`: 本地特定的别名
    - `local-functions.zsh`: 本地特定的函数
    - 等等...

### 跨平台兼容性

配置文件设计考虑了多平台兼容性，能够智能检测并适应：

- Intel Mac
- Apple Silicon Mac
- Linux系统（包括Ubuntu和Kali Linux）

### 本地自定义

为了支持不加入版本控制的本地配置，可以在 `local_configs` 目录中创建以下文件：

- `~/.config/zsh/configs/local_configs/local-exports.zsh`: 本地环境变量
- `~/.config/zsh/configs/local_configs/local-aliases.zsh`: 本地别名
- `~/.config/zsh/configs/local_configs/local-functions.zsh`: 本地函数
- `~/.config/zsh/configs/local_configs/local-profile.zsh`: 本地登录配置

所有这些本地配置文件都不会被包含在版本控制中，允许你添加敏感或特定于机器的配置。

## ZDOTDIR 位置

默认情况下，ZDOTDIR设置为 `$HOME/.config/zsh`，这意味着所有ZSH配置文件将从该目录加载。这符合XDG基本目录规范。

## 插件

ZSH配置包含以下插件支持：

- fzf: 模糊查找工具
- fzf-tab: 增强的Tab补全
- fast-syntax-highlighting: 语法高亮
- zsh-autosuggestions: 自动补全建议
- zsh-history-substring-search: 历史搜索
- zsh-you-should-use: 别名提示
- forgit: 增强git操作
- zoxide: 智能目录跳转

## 多版本管理工具

本配置包含了两个主要的版本管理工具：

- **jenv**: Java 版本管理工具，允许在不同的 Java 版本之间轻松切换
- **fnm**: Fast Node Manager，用于管理多个 Node.js 版本

## 实用工具

此配置包含了多种实用工具以提高生产力：

- **nexttrace**: 现代化路由追踪工具，比 traceroute 更强大
- **exiftool**: 强大的元数据查看和编辑工具
- **dua**: 磁盘使用分析工具，比 du 更直观
- **ouch**: 现代化解压缩工具，支持多种格式
- **uv**: 快速的 Python 包管理工具，pip 的替代品
- **tcping**: TCP 连接测试工具，类似 ping 但测试 TCP 连接
- **gohttpserver**: 高性能 HTTP 文件服务器
- **git-delta**: 语法高亮的 Git 差异查看器，支持并排视图和行号

### 特定系统工具

- **macOS**:
  - trash: 替代 rm，将文件移动到回收站而非直接删除
  - kitty: 高性能、GPU 加速的终端模拟器
  - duf: 磁盘使用情况查看器，更直观的 df 替代品

- **Linux**:
  - trash-put: Linux 下的安全删除工具，将文件移动到回收站

## 自定义

如需添加自己的配置，可以修改现有文件或在`~/.config/zsh/configs/local_configs/`目录中创建相应的本地配置文件。

## 贡献

欢迎提出建议和改进！ 