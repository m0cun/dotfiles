# Dotfiles

这是我的个人 dotfiles 配置仓库，使用 GNU stow 管理。

## 内容

| 目录 | 说明 |
|---|---|
| `zsh` | ZSH 配置文件，模块化设计 |
| `starship` | Starship 提示符配置 |
| `nvim` | Neovim 配置 |
| `kitty` | Kitty 终端配置（macOS） |
| `helix` | Helix 编辑器配置 |
| `bat` | bat 查看器配置 |
| `lsd` | LSD (LSDeluxe) 配置 |
| `yazi` | Yazi 文件管理器配置 |
| `zellij` | Zellij 终端复用器配置 |
| `tssh` | 支持传输文件的 SSH 客户端配置 |
| `delta` | Delta Git 增强差异查看器配置 |

## 安装

### 自动安装（推荐）

```bash
# 克隆仓库（包括所有子模块）
git clone --recurse-submodules https://github.com/m0cun/dotfiles.git ~/.dotfile
cd ~/.dotfile

# 运行安装脚本
./install.sh
```

脚本将自动完成以下工作：

- 检测操作系统（macOS / Ubuntu / Kali Linux 等）
- 设置 ZSH 为默认 shell
- 安装 Homebrew（仅 macOS）
- 安装 Rust、Go 编程语言环境
- 安装推荐工具（见下方工具列表）
- 创建所需目录结构
- 安装/更新 ZSH 插件（Git 子模块）
- 使用 stow 创建符号链接

### Linux 安装架构（三层）

Linux 采用统一的三层安装架构，无需区分发行版：

| 层级 | 内容 |
|---|---|
| 第一层 | 最小基础包（git, stow, curl, wget, unzip）+ Clash 代理（可选） |
| 第二层 | [stew](https://github.com/marwanhawari/stew)（GitHub 二进制包管理器，需要 Go 环境） |
| 第三层 | 通过 stew 统一安装所有工具（不区分发行版） |

安装完成后，脚本会自动为所有已安装工具生成 zsh 补全文件并写入 `/usr/local/share/zsh/site-functions/`，与 macOS Homebrew 行为对齐。

### 已安装工具列表

**通用工具**（macOS 通过 Homebrew，Linux 通过 stew / 官方脚本）：

| 工具 | 说明 | 安装方式（Linux） |
|---|---|---|
| [starship](https://starship.rs) | 跨 shell 提示符 | 官方脚本 |
| [neovim](https://neovim.io) | 现代化 Vim | 官方 tar.gz → `/opt` + 软链接 |
| [helix](https://helix-editor.com) | 基于 Rust 的现代编辑器 | stew |
| [bat](https://github.com/sharkdp/bat) | `cat` 增强版 | stew |
| [lsd](https://github.com/lsd-rs/lsd) | `ls` 增强版 | stew |
| [yazi](https://github.com/sxyazi/yazi) | 终端文件管理器 | gnu 包 → `/opt` + 软链接 |
| [zellij](https://zellij.dev) | 终端复用器 | stew |
| [git-delta](https://dandavison.github.io/delta) | Git diff 增强 | stew |
| [fd](https://github.com/sharkdp/fd) | `find` 增强版 | stew |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | `grep` 增强版 | stew |
| [fzf](https://github.com/junegunn/fzf) | 模糊查找 | stew |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | 智能目录跳转 | 官方脚本 |
| [jq](https://jqlang.github.io/jq) | JSON 处理 | stew |
| [xh](https://github.com/ducaale/xh) | 现代 HTTP 客户端 | stew |
| [dua](https://github.com/Byron/dua-cli) | 磁盘使用分析 | stew |
| [ouch](https://github.com/ouch-org/ouch) | 现代解压缩工具 | stew |
| [uv](https://docs.astral.sh/uv) | 现代 Python 包管理器 | 官方脚本 |
| [tssh](https://github.com/trzsz/tssh) | 支持文件传输的 SSH 客户端 | stew |
| [nexttrace](https://github.com/nxtrace/NTrace-core) | 现代路由追踪工具 | 官方二进制 |
| [fnm](https://github.com/Schniz/fnm) | Node.js 版本管理 | 官方脚本 |
| [jenv](https://www.jenv.be) | Java 版本管理 | Git 克隆 |
| [tcping](https://github.com/pouriyajamshidi/tcping) | TCP 连接测试 | `go install` |
| [gohttpserver](https://github.com/codeskyblue/gohttpserver) | HTTP 文件服务器 | `go install` |
| [Hack Nerd Font](https://www.nerdfonts.com) | 编程字体 | 脚本安装 |

**平台专属工具**：

| 工具 | 平台 | 说明 |
|---|---|---|
| trash | macOS | `rm` 替代，移入回收站 |
| kitty | macOS | GPU 加速终端 |
| duf | macOS | 磁盘使用情况查看器 |
| trash-put | Linux | Linux 下的安全删除 |

> **注意**：Kitty 终端仅在 macOS 自动安装；Linux 上若已安装则会自动创建配置符号链接。

### 手动安装

#### 前提条件

- Git
- GNU Stow（`brew install stow` 或 `apt install stow`）

#### 克隆仓库

```bash
git clone --recurse-submodules https://github.com/m0cun/dotfiles.git ~/.dotfile
cd ~/.dotfile
```

#### 使用 Stow 创建符号链接

```bash
# 安装所有配置
stow */

# 或只安装特定配置
stow zsh
stow nvim
```

## 更新配置

```bash
cd ~/.dotfile
./update.sh
```

此脚本将：
- 更新系统包和工具（包括 Rust、Go 工具）
- 更新 Python 工具（uv）
- 更新版本管理工具（jenv, fnm）
- 更新 dotfiles 仓库
- 更新所有 ZSH 插件（Git 子模块）
- 重新应用符号链接

也可以手动更新：

```bash
cd ~/.dotfile
git pull
git submodule update --remote --recursive
```

## Git 子模块（ZSH 插件）

| 插件 | 功能 |
|---|---|
| fast-syntax-highlighting | 语法高亮 |
| zsh-autosuggestions | 自动补全建议 |
| zsh-history-substring-search | 历史搜索 |
| zsh-you-should-use | 别名提示 |
| forgit | 增强 git 操作 |
| fzf-tab | 增强 Tab 补全 |

未使用 `--recurse-submodules` 克隆时，可手动初始化：

```bash
git submodule init
git submodule update --recursive
```

## ZSH 配置说明

ZSH 配置采用模块化设计：

- `zsh/.zshrc`：主配置文件，加载所有模块
- `zsh/.zprofile`：登录 shell 初始化
- `zsh/.config/zsh/configs/`：功能模块目录
  - `os-detection.zsh`：操作系统检测
  - `history.zsh`：历史记录配置
  - `completion.zsh`：补全系统配置
  - `prompt.zsh`：提示符配置
  - `plugins.zsh`：插件管理
  - `aliases.zsh`：通用别名
  - `exports.zsh`：环境变量设置
  - `functions.zsh`：实用函数
  - `os-specific/`：平台特定配置
    - `macos.zsh`：macOS 配置
    - `linux.zsh`：Linux 配置
    - `exports-macos.zsh`：macOS 环境变量
    - `exports-linux.zsh`：Linux 环境变量
  - `local_configs/`：本地配置（不纳入版本控制）
    - `local-exports.zsh`：本地环境变量
    - `local-aliases.zsh`：本地别名
    - `local-functions.zsh`：本地函数

### 跨平台兼容性

配置智能检测并适应以下平台：

- Intel Mac
- Apple Silicon Mac
- Linux（Ubuntu、Kali Linux 等）

### 本地自定义

在 `~/.config/zsh/configs/local_configs/` 中创建以下文件（不纳入版本控制）：

```
local-exports.zsh     # 本地环境变量
local-aliases.zsh     # 本地别名
local-functions.zsh   # 本地函数
local-profile.zsh     # 本地登录配置
```

## 贡献

欢迎提出建议和改进！