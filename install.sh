#!/bin/bash

# 终端颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # 无颜色

# 目录设置
DOTFILES_DIR="$HOME/.dotfile"
CONFIG_DIR="$HOME/.config"
ZSH_DIR="$CONFIG_DIR/zsh"
ZSH_PLUGINS_DIR="$ZSH_DIR/plugins"

# 日志函数
log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# 用户确认函数
confirm_action() {
  local prompt="$1"
  local default="$2"
  local answer

  # 如果 CI 环境或非交互式环境，使用默认值
  if [ -n "$CI" ] || [ ! -t 0 ]; then
    return 0
  fi

  if [ "$default" = "y" ]; then
    prompt="$prompt [Y/n] "
  else
    prompt="$prompt [y/N] "
  fi

  read -p "$prompt" answer

  if [ -z "$answer" ]; then
    answer="$default"
  fi

  case "$answer" in
    [Yy]*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

# 检测操作系统
detect_os() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    log_info "检测到 macOS 操作系统"
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    # 检测 Linux 发行版
    if [ -f /etc/debian_version ]; then
      if grep -qi "kali" /etc/debian_version || [ -f /etc/kali-release ]; then
        DISTRO="kali"
        log_info "检测到 Kali Linux 发行版"
      elif [ -f /etc/lsb-release ] && grep -qi "ubuntu" /etc/lsb-release; then
        DISTRO="ubuntu"
        log_info "检测到 Ubuntu 发行版"
      else
        DISTRO="debian"
        log_info "检测到 Debian 发行版"
      fi
    elif [ -f /etc/redhat-release ]; then
      DISTRO="redhat"
      log_info "检测到 RedHat 系发行版"
    elif [ -f /etc/arch-release ]; then
      DISTRO="arch"
      log_info "检测到 Arch Linux 发行版"
    else
      DISTRO="unknown"
      log_info "未能识别的 Linux 发行版"
    fi
  else
    OS="unknown"
    log_warning "未知操作系统: $OSTYPE"
  fi
}

# 安装 macOS 上的 Homebrew
install_homebrew() {
  if [ "$OS" = "macos" ]; then
    # 检查是否已安装 Homebrew
    if ! command -v brew &> /dev/null; then
      if ! confirm_action "是否安装 Homebrew 包管理器？" "y"; then
        log_info "跳过 Homebrew 安装"
        return 0
      fi

      log_info "安装 Homebrew..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

      # 添加 Homebrew 到 PATH (如果需要)
      if ! command -v brew &> /dev/null; then
        if [[ "$(uname -m)" == "arm64" ]]; then
          # Apple Silicon Mac
          eval "$(/opt/homebrew/bin/brew shellenv)"
        else
          # Intel Mac
          eval "$(/usr/local/bin/brew shellenv)"
        fi
      fi

      log_success "Homebrew 安装完成"
    else
      log_info "Homebrew 已安装"
    fi
  fi
}

# 安装 Nerd Fonts
install_nerd_fonts() {
  log_info "检查 Nerd Fonts 安装状态..."

  if [ "$OS" = "macos" ]; then
    # macOS 通过 Homebrew 安装
    brew install --cask font-hack-nerd-font
    log_success "Nerd Fonts (Hack) 安装完成"
  elif [ "$OS" = "linux" ]; then
    # Linux 安装 Nerd Fonts
    NERD_FONTS_DIR="$HOME/.local/share/fonts/NerdFonts"
    if [ ! -d "$NERD_FONTS_DIR" ]; then
      log_info "安装 Nerd Fonts (Hack)..."
      mkdir -p "$NERD_FONTS_DIR"

      # 下载 Hack Nerd Font
      TEMP_ZIP=$(mktemp)
      curl -fsSL -o "$TEMP_ZIP" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip"
      unzip -q "$TEMP_ZIP" -d "$NERD_FONTS_DIR"
      rm "$TEMP_ZIP"

      # 刷新字体缓存
      if command -v fc-cache &> /dev/null; then
        fc-cache -fv
      fi

      log_success "Nerd Fonts (Hack) 安装完成"
    else
      log_info "Nerd Fonts 似乎已安装"
    fi
  fi
}

# 安装 exiftool (所有系统)
install_exiftool() {
  log_info "检查 exiftool 安装状态..."

  if command -v exiftool &> /dev/null; then
    log_success "exiftool 已安装: $(exiftool -ver)"
    return 0
  fi

  if ! confirm_action "是否安装 exiftool (元数据查看工具)？" "y"; then
    log_info "跳过 exiftool 安装"
    return 0
  fi

  log_info "安装 exiftool..."

  if [ "$OS" = "macos" ]; then
    brew install exiftool
  elif [ "$OS" = "linux" ]; then
    if [ "$DISTRO" = "ubuntu" ] || [ "$DISTRO" = "debian" ] || [ "$DISTRO" = "kali" ]; then
      sudo apt install -y libimage-exiftool-perl
    elif [ "$DISTRO" = "redhat" ]; then
      sudo dnf install -y perl-Image-ExifTool
    elif [ "$DISTRO" = "arch" ]; then
      sudo pacman -S --noconfirm perl-image-exiftool
    else
      log_warning "未知的 Linux 发行版，无法自动安装 exiftool"
    fi
  else
    log_warning "未知操作系统，无法自动安装 exiftool"
  fi

  if command -v exiftool &> /dev/null; then
    log_success "exiftool 安装完成: $(exiftool -ver)"
  else
    log_warning "exiftool 安装失败，请手动安装"
  fi
}

# 检查和安装 ZSH
install_zsh() {
  log_info "检查 ZSH 安装状态..."

  # 检查当前 shell
  CURRENT_SHELL=$(echo $SHELL)

  if [[ "$CURRENT_SHELL" == *"zsh"* ]]; then
    log_success "当前已使用 ZSH: $CURRENT_SHELL"
    return 0
  fi

  # 检查是否已安装 ZSH
  ZSH_PATH=$(which zsh 2>/dev/null)
  if [ -z "$ZSH_PATH" ]; then
    if ! confirm_action "是否安装 ZSH？" "y"; then
      log_info "跳过 ZSH 安装"
      return 0
    fi

    log_info "ZSH 未安装，正在安装..."

    if [ "$OS" = "macos" ]; then
      brew install zsh
    elif [ "$OS" = "linux" ]; then
      if [ "$DISTRO" = "ubuntu" ] || [ "$DISTRO" = "debian" ] || [ "$DISTRO" = "kali" ]; then
        sudo apt update && sudo apt install -y zsh
      elif [ "$DISTRO" = "redhat" ]; then
        sudo dnf install -y zsh
      elif [ "$DISTRO" = "arch" ]; then
        sudo pacman -S --noconfirm zsh
      else
        log_error "未知的 Linux 发行版，无法自动安装 ZSH"
        exit 1
      fi
    else
      log_error "未知操作系统，无法自动安装 ZSH"
      exit 1
    fi

    # 重新检查是否安装成功
    ZSH_PATH=$(which zsh 2>/dev/null)
    if [ -z "$ZSH_PATH" ]; then
      log_error "ZSH 安装失败"
      exit 1
    fi
  else
    log_info "检测到已安装 ZSH: $ZSH_PATH"
  fi

  # 将 ZSH 设置为默认 shell
  if confirm_action "是否将 ZSH 设置为默认 shell？" "y"; then
    log_info "设置 ZSH 为默认 shell..."

    # 检查 ZSH 是否在 /etc/shells 中
    if ! grep -q "$ZSH_PATH" /etc/shells; then
      echo "$ZSH_PATH" | sudo tee -a /etc/shells
    fi

    # 检查是否有 chsh 命令
    if command -v chsh &> /dev/null; then
      chsh -s "$ZSH_PATH"
      log_success "ZSH 已设置为默认 shell，请在安装完成后重新登录以应用更改"
    else
      log_warning "未找到 chsh 命令，无法自动设置默认 shell"
      log_info "您可以手动运行以下命令来设置 ZSH 为默认 shell:"
      echo "sudo usermod -s $ZSH_PATH $USER"
      if confirm_action "是否尝试使用 usermod 设置 ZSH 为默认 shell？" "y"; then
        sudo usermod -s "$ZSH_PATH" "$USER"
        log_success "ZSH 已设置为默认 shell，请在安装完成后重新登录以应用更改"
      fi
    fi
  else
    log_info "跳过设置 ZSH 为默认 shell"
  fi
}

# 安装 Rust
install_rust() {
  log_info "检查 Rust 安装状态..."

  if command -v rustc &> /dev/null && command -v cargo &> /dev/null; then
    log_success "Rust 已安装: $(rustc --version)"
    return 0
  fi

  if ! confirm_action "是否安装 Rust？" "y"; then
    log_info "跳过 Rust 安装"
    return 0
  fi

  log_info "安装 Rust..."

  # 设置 Rust 镜像源
  log_info "设置 Rust 镜像源 (USTC)..."
  export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
  export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup

  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

  # 加载环境变量
  source "$HOME/.cargo/env"

  # 添加镜像源配置到 $HOME/.cargo/config.toml
  log_info "配置 Cargo 镜像源..."
  mkdir -p "$HOME/.cargo"
  cat > "$HOME/.cargo/config.toml" << 'EOF'
[source.crates-io]
replace-with = 'ustc'

[source.ustc]
registry = "sparse+https://mirrors.ustc.edu.cn/crates.io-index/"

[registries.ustc]
index = "https://mirrors.ustc.edu.cn/crates.io-index"
EOF

  log_success "Rust 安装完成: $(rustc --version)"
  log_success "Cargo 镜像源已配置为 USTC"
}

# 安装 Go
install_go() {
  log_info "检查 Go 安装状态..."

  if command -v go &> /dev/null; then
    log_success "Go 已安装: $(go version)"

    # 设置 Go 代理
    if confirm_action "是否设置 Go 镜像源 (阿里云)？" "y"; then
      log_info "设置 Go 镜像源..."
      go env -w GOPROXY=https://mirrors.aliyun.com/goproxy/,direct
      log_success "Go 镜像源已设置为阿里云"
    fi

    return 0
  fi

  if ! confirm_action "是否安装 Go？" "y"; then
    log_info "跳过 Go 安装"
    return 0
  fi

  log_info "安装 Go..."

  if [ "$OS" = "macos" ]; then
    brew install go
  elif [ "$OS" = "linux" ]; then
    if [ "$DISTRO" = "ubuntu" ] || [ "$DISTRO" = "debian" ] || [ "$DISTRO" = "kali" ]; then
      sudo apt update && sudo apt install -y golang
    elif [ "$DISTRO" = "redhat" ]; then
      sudo dnf install -y golang
    elif [ "$DISTRO" = "arch" ]; then
      sudo pacman -S --noconfirm go
    else
      log_warning "未知的 Linux 发行版，无法自动安装 Go"
    fi
  else
    log_warning "未知操作系统，无法自动安装 Go"
  fi

  # 设置 Go 环境变量
  if command -v go &> /dev/null; then
    mkdir -p "$HOME/.go"
    export GOPATH="$HOME/.go"
    export GOBIN="$GOPATH/bin"
    export PATH="$PATH:$GOBIN"

    # 设置 Go 代理
    log_info "设置 Go 镜像源 (阿里云)..."
    go env -w GOPROXY=https://mirrors.aliyun.com/goproxy/,direct

    log_success "Go 安装完成: $(go version)"
    log_success "Go 镜像源已设置为阿里云"
  else
    log_error "Go 安装失败"
  fi
}

# 安装 Python 相关工具
install_python_tools() {
  log_info "检查 Python 工具安装状态..."

  # 安装 uv (Python 包管理工具)
  if ! command -v uv &> /dev/null; then
    if ! confirm_action "是否安装 uv (Python 包管理工具)？" "y"; then
      log_info "跳过 uv 安装"
      return 0
    fi

    log_info "安装 uv (Python 包管理工具)..."

    if [ "$OS" = "macos" ]; then
      brew install uv
    else
      # 官方指定安装方式
      log_info "使用官方安装脚本安装 uv..."
      curl -LsSf https://astral.sh/uv/install.sh | sh
    fi

    if command -v uv &> /dev/null; then
      log_success "uv 安装完成: $(uv --version)"
    else
      log_warning "uv 安装失败，请手动安装"
    fi
  else
    log_success "uv 已安装: $(uv --version)"
  fi
}

# 安装 Node.js 版本管理工具 fnm
install_fnm() {
  log_info "检查 fnm 安装状态..."

  if command -v fnm &> /dev/null; then
    log_success "fnm 已安装: $(fnm --version)"
    return 0
  fi

  if ! confirm_action "是否安装 fnm (Node.js 版本管理工具)？" "y"; then
    log_info "跳过 fnm 安装"
    return 0
  fi

  log_info "安装 fnm (Node.js 版本管理工具)..."

  if [ "$OS" = "macos" ]; then
    brew install fnm
  elif command -v cargo &> /dev/null; then
    cargo install fnm
  else
    curl -fsSL https://fnm.vercel.app/install | bash

    # 添加到 PATH
    export PATH="$HOME/.local/share/fnm:$PATH"
    eval "$(fnm env --use-on-cd)"
  fi

  if command -v fnm &> /dev/null; then
    log_success "fnm 安装完成: $(fnm --version)"
  else
    log_warning "fnm 安装失败，请手动安装"
  fi
}

# 安装 Java 版本管理工具 jenv
install_jenv() {
  log_info "检查 jenv 安装状态..."

  if command -v jenv &> /dev/null; then
    log_success "jenv 已安装: $(jenv --version)"
    return 0
  fi

  if ! confirm_action "是否安装 jenv (Java 版本管理工具)？" "y"; then
    log_info "跳过 jenv 安装"
    return 0
  fi

  log_info "安装 jenv (Java 版本管理工具)..."

  if [ "$OS" = "macos" ]; then
    brew install jenv
  else
    git clone https://github.com/jenv/jenv.git ~/.jenv

    # 添加到 PATH
    export PATH="$HOME/.jenv/bin:$PATH"
    eval "$(jenv init -)"
  fi

  if command -v jenv &> /dev/null; then
    log_success "jenv 安装完成: $(jenv --version)"

    # 启用插件
    jenv enable-plugin export
    jenv enable-plugin maven
    jenv enable-plugin gradle
  else
    log_warning "jenv 安装失败，请手动安装"
  fi
}

# 安装 Go 工具
install_go_tools() {
  if ! command -v go &> /dev/null; then
    log_warning "Go 未安装，跳过 Go 工具安装"
    return 0
  fi

  log_info "安装 Go 工具..."

  # 安装 tcping
  if ! command -v tcping &> /dev/null; then
    if confirm_action "是否安装 tcping (TCP 连接测试工具)？" "y"; then
      log_info "安装 tcping..."
      go install github.com/pouriyajamshidi/tcping/v2@latest
      log_success "tcping 安装完成"
    else
      log_info "跳过 tcping 安装"
    fi
  fi

  # 安装 gohttpserver
  if ! command -v gohttpserver &> /dev/null; then
    if confirm_action "是否安装 gohttpserver (高性能 HTTP 文件服务器)？" "y"; then
      log_info "安装 gohttpserver..."
      go install github.com/codeskyblue/gohttpserver@latest
      log_success "gohttpserver 安装完成"
    else
      log_info "跳过 gohttpserver 安装"
    fi
  fi

  log_success "Go 工具安装完成"
}

# ──────────────────────────────────────────────────────────
# Linux 安装辅助函数（三层架构）
# ──────────────────────────────────────────────────────────

# 第一层：最小发行版基础包（仅此处做发行版判断）
install_linux_base_packages() {
  log_info "安装 Linux 基础工具..."

  local PKG_MANAGER=""
  if command -v apt &>/dev/null; then
    PKG_MANAGER="apt"
  elif command -v dnf &>/dev/null; then
    PKG_MANAGER="dnf"
  elif command -v pacman &>/dev/null; then
    PKG_MANAGER="pacman"
  else
    log_warning "未识别的包管理器，跳过基础包安装"
    return 0
  fi

  if confirm_action "是否安装基础工具 (git, stow, curl, wget, unzip)？" "y"; then
    case "$PKG_MANAGER" in
      apt)
        sudo apt update
        sudo apt install -y git stow curl wget unzip
        ;;
      dnf)
        sudo dnf install -y git stow curl wget unzip
        ;;
      pacman)
        sudo pacman -S --noconfirm git stow curl wget unzip
        ;;
    esac
    log_success "基础工具安装完成"
  fi

  # trash-cli：无二进制，用包管理器安装
  if ! command -v trash-put &>/dev/null; then
    if confirm_action "是否安装 trash-put (安全删除工具)？" "y"; then
      case "$PKG_MANAGER" in
        apt)    sudo apt install -y trash-cli ;;
        dnf)    sudo dnf install -y trash-cli ;;
        pacman) sudo pacman -S --noconfirm trash-cli ;;
      esac
    fi
  fi

  # Clash for Linux：代理工具，建议优先安装避免后续 GitHub 访问受阻
  if ! command -v clashon &>/dev/null && ! command -v clash &>/dev/null; then
    if confirm_action "是否安装 Clash for Linux (代理工具，建议优先安装以确保 GitHub 访问)？" "y"; then
      log_info "安装 Clash for Linux..."
      git clone --branch master --depth 1 \
        https://gh-proxy.org/https://github.com/nelvko/clash-for-linux-install.git \
        /tmp/clash-for-linux-install \
        && cd /tmp/clash-for-linux-install \
        && bash install.sh
      cd - >/dev/null
      log_info "Clash 安装完成。alias clashon/clashoff 已在 linux.zsh 中配置"
      log_warning "请手动运行 clashon 并确认订阅链接已设置，再继续安装其他工具"
    fi
  fi

  # ── Docker（官方通用脚本，支持 Debian/Ubuntu/Fedora/CentOS/Arch）──
  if ! command -v docker &>/dev/null; then
    if confirm_action "是否安装 Docker（官方 get.docker.com 脚本）？" "y"; then
      log_info "使用官方脚本安装 Docker..."
      curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
      sudo sh /tmp/get-docker.sh
      rm -f /tmp/get-docker.sh

      # 将当前用户加入 docker 组（免 sudo 运行 docker）
      sudo usermod -aG docker "$USER"
      log_info "已将 $USER 加入 docker 组，重新登录后生效"

      # 配置镜像加速 + 防火墙
      configure_docker_daemon

      # 启用并启动 Docker 服务（systemd 环境）
      if command -v systemctl &>/dev/null; then
        sudo systemctl enable --now docker
        log_info "Docker 服务已启用并启动"
      fi

      log_success "Docker 安装完成: $(docker --version 2>/dev/null || echo '版本未知')"
    fi
  else
    log_success "Docker 已安装: $(docker --version)"
    if confirm_action "是否重新配置 Docker 镜像加速与防火墙？" "n"; then
      configure_docker_daemon
      sudo systemctl restart docker
    fi
  fi
}

# 配置 Docker daemon：国内镜像加速
# 可单独调用：bash install.sh configure_docker_daemon
configure_docker_daemon() {
  log_info "配置 Docker daemon（国内镜像加速）..."

  # n3.ink helper 脚本自动检测发行版并写入 daemon.json registry-mirrors
  # UFW 端口暴露问题建议通过 -p 127.0.0.1:port:port 绑定本地地址规避
  log_info "运行 n3.ink Docker 镜像加速配置脚本..."
  bash -c "$(curl -sSL https://n3.ink/helper)"

  log_success "Docker daemon 配置完成（重启 Docker 后生效：sudo systemctl restart docker）"
}

# 第二层：安装 stew（GitHub 二进制包管理器，需要 Go 环境）
install_stew() {
  if command -v stew &>/dev/null; then
    log_success "stew 已安装"
    return 0
  fi

  if ! command -v go &>/dev/null; then
    log_error "stew 需要 Go 环境，请先安装 Go"
    return 1
  fi

  if ! confirm_action "是否安装 stew (GitHub 二进制包管理器)？" "y"; then
    log_warning "跳过 stew 安装，后续工具将尝试备用安装方式"
    return 0
  fi

  log_info "安装 stew..."
  go install github.com/marwanhawari/stew@latest

  if command -v stew &>/dev/null; then
    # 预配置 stew，将 bin 路径设为 ~/.local/bin（已在 PATH 中）
    local STEW_CONFIG_DIR="$HOME/.config/stew"
    local STEW_CONFIG="$STEW_CONFIG_DIR/stew.config.json"
    if [[ ! -f "$STEW_CONFIG" ]]; then
      mkdir -p "$STEW_CONFIG_DIR"
      cat > "$STEW_CONFIG" <<'EOF'
{
  "stewPath": "~/.local/share/stew",
  "stewBinPath": "~/.local/bin",
  "excludeFromUpgradeAll": []
}
EOF
      log_info "stew 配置已写入 $STEW_CONFIG"
    fi
    log_success "stew 安装完成"
  else
    log_error "stew 安装失败，请检查 Go 环境和网络连接"
  fi
}

# 辅助：用 stew 安装单个工具，失败时执行 fallback
# 用法: stew_install "user/repo" "binary_name" "fallback_cmd"
stew_install() {
  local REPO="$1"
  local BIN="$2"
  local FALLBACK="$3"

  if command -v "$BIN" &>/dev/null; then
    log_success "$BIN 已安装"
    return 0
  fi

  if command -v stew &>/dev/null; then
    log_info "stew 安装 $BIN ($REPO)..."
    if stew install "$REPO"; then
      log_success "$BIN 安装完成"
      return 0
    else
      log_warning "stew 安装 $BIN 失败"
    fi
  fi

  if [ -n "$FALLBACK" ]; then
    log_info "使用备用方式安装 $BIN..."
    eval "$FALLBACK"
  else
    log_warning "$BIN 安装失败，无备用方案，请手动安装"
  fi
}

# 第三层：统一二进制安装（不区分发行版）
# stew 自动识别平台架构，不需要手动指定 asset
install_linux_tools() {
  log_info "开始安装 Linux 工具（stew 统一二进制方案）..."

  # ── Starship（官方脚本，含 shell 集成）──
  if ! command -v starship &>/dev/null; then
    if confirm_action "是否安装 Starship (终端提示符)？" "y"; then
      curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi
  fi

  # ── Neovim（官方 tar.gz → /opt + 软连接）──
  if ! command -v nvim &>/dev/null; then
    if confirm_action "是否安装 Neovim (编辑器)？" "y"; then
      log_info "下载 Neovim 官方二进制..."
      local NVIM_VERSION
      NVIM_VERSION=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest \
        | grep '"tag_name"' | cut -d'"' -f4)
      curl -LO "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.tar.gz"
      sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
      rm nvim-linux-x86_64.tar.gz
      sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
      log_success "Neovim 安装完成: $(nvim --version | head -1)"
    fi
  else
    log_success "Neovim 已安装: $(nvim --version | head -1)"
  fi

  # ── bat（gnu tar → /opt + 软链接）──
  if ! command -v bat &>/dev/null; then
    if confirm_action "是否安装 bat (增强版 cat)？" "y"; then
      log_info "下载 bat 二进制..."
      local BAT_VER
      BAT_VER=$(curl -s https://api.github.com/repos/sharkdp/bat/releases/latest \
        | grep '"tag_name"' | cut -d'"' -f4)
      local BAT_DIR="bat-${BAT_VER}-x86_64-unknown-linux-gnu"
      local BAT_TAR="${BAT_DIR}.tar.gz"

      wget -O "/tmp/${BAT_TAR}" \
        "https://github.com/sharkdp/bat/releases/download/${BAT_VER}/${BAT_TAR}"
      sudo tar -C /opt -xzf "/tmp/${BAT_TAR}"
      rm -f "/tmp/${BAT_TAR}"

      sudo ln -sf "/opt/${BAT_DIR}/bat" /usr/local/bin/bat

      # 安装 zsh 补全
      local ZSH_SITE="/usr/local/share/zsh/site-functions"
      sudo mkdir -p "$ZSH_SITE"
      [ -f "/opt/${BAT_DIR}/autocomplete/bat.zsh" ] \
        && sudo cp "/opt/${BAT_DIR}/autocomplete/bat.zsh" "${ZSH_SITE}/_bat" \
        && log_info "已安装 bat zsh 补全：${ZSH_SITE}/_bat"

      log_success "bat 安装完成: $(bat --version 2>/dev/null || echo '版本未知')"
    fi
  else
    log_success "bat 已安装: $(bat --version)"
  fi

  # ── fd ──
  if confirm_action "是否安装 fd (增强版 find)？" "y"; then
    stew_install "sharkdp/fd" "fd" ""
  fi

  # ── ripgrep ──
  if confirm_action "是否安装 ripgrep (增强版 grep)？" "y"; then
    stew_install "BurntSushi/ripgrep" "rg" ""
  fi

  # ── git-delta ──
  if confirm_action "是否安装 git-delta (增强版 git diff)？" "y"; then
    stew_install "dandavison/delta" "delta" ""
  fi

  # ── jq ──
  if confirm_action "是否安装 jq (JSON 处理工具)？" "y"; then
    stew_install "jqlang/jq" "jq" ""
  fi

  # ── fzf ──
  if ! command -v fzf &>/dev/null; then
    if confirm_action "是否安装 fzf (模糊查找工具)？" "y"; then
      if command -v stew &>/dev/null; then
        stew install junegunn/fzf
        log_success "fzf 安装完成"
      else
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install --no-bash --no-fish --key-bindings --completion --no-update-rc
      fi
    fi
  fi

  # ── zoxide（官方脚本，含补全处理）──
  if ! command -v zoxide &>/dev/null; then
    if confirm_action "是否安装 zoxide (智能目录跳转)？" "y"; then
      curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    fi
  fi

  # ── lsd ──
  if confirm_action "是否安装 lsd (增强版 ls)？" "y"; then
    stew_install "lsd-rs/lsd" "lsd" ""
  fi

  # ── zellij ──
  if ! command -v zellij &>/dev/null; then
    if confirm_action "是否安装 zellij (终端复用器)？" "y"; then
      stew_install "zellij-org/zellij" "zellij" ""
    fi
  fi

  # ── helix ──
  if ! command -v hx &>/dev/null; then
    if confirm_action "是否安装 helix (现代编辑器)？" "y"; then
      stew_install "helix-editor/helix" "hx" ""
    fi
  fi

  # ── dua ──
  if ! command -v dua &>/dev/null; then
    if confirm_action "是否安装 dua (磁盘使用分析工具)？" "y"; then
      stew_install "Byron/dua-cli" "dua" ""
    fi
  fi

  # ── ouch（gnu tar → /opt + 软链接 + 补全 + man 页）──
  if ! command -v ouch &>/dev/null; then
    if confirm_action "是否安装 ouch (现代解压缩工具)？" "y"; then
      log_info "下载 ouch 二进制..."
      local OUCH_VER
      OUCH_VER=$(curl -s https://api.github.com/repos/ouch-org/ouch/releases/latest \
        | grep '"tag_name"' | cut -d'"' -f4)
      local OUCH_DIR="ouch-x86_64-unknown-linux-gnu"
      local OUCH_TAR="${OUCH_DIR}.tar.gz"

      wget -O "/tmp/${OUCH_TAR}" \
        "https://github.com/ouch-org/ouch/releases/download/${OUCH_VER}/${OUCH_TAR}"
      sudo tar -C /opt -xzf "/tmp/${OUCH_TAR}"
      rm -f "/tmp/${OUCH_TAR}"

      sudo ln -sf "/opt/${OUCH_DIR}/ouch" /usr/local/bin/ouch

      # 安装 zsh 补全
      local ZSH_SITE="/usr/local/share/zsh/site-functions"
      sudo mkdir -p "$ZSH_SITE"
      [ -f "/opt/${OUCH_DIR}/completions/_ouch" ] \
        && sudo cp "/opt/${OUCH_DIR}/completions/_ouch" "${ZSH_SITE}/_ouch" \
        && log_info "已安装 ouch zsh 补全：${ZSH_SITE}/_ouch"

      # 安装 man 页
      local MAN1="/usr/local/share/man/man1"
      sudo mkdir -p "$MAN1"
      for f in "/opt/${OUCH_DIR}/man/"*.1; do
        sudo cp "$f" "$MAN1/"
      done
      log_info "ouch man 页已安装到 ${MAN1}"

      log_success "ouch 安装完成: $(ouch --version 2>/dev/null || echo '版本未知')"
    fi
  else
    log_success "ouch 已安装: $(ouch --version)"
  fi

  # ── yazi（含 ya 插件管理器，gnu 包 → /opt，软链接到 /usr/local/bin）──
  if ! command -v yazi &>/dev/null; then
    if confirm_action "是否安装 yazi (文件管理器)？" "y"; then
      log_info "下载 yazi 二进制（含 ya 插件管理器）..."
      local YAZI_VER
      YAZI_VER=$(curl -s https://api.github.com/repos/sxyazi/yazi/releases/latest \
        | grep '"tag_name"' | cut -d'"' -f4)
      local YAZI_DIR="yazi-x86_64-unknown-linux-gnu"
      local YAZI_ZIP="${YAZI_DIR}.zip"

      wget -O "/tmp/${YAZI_ZIP}" \
        "https://github.com/sxyazi/yazi/releases/download/${YAZI_VER}/${YAZI_ZIP}"
      sudo unzip -q "/tmp/${YAZI_ZIP}" -d /opt
      rm -f "/tmp/${YAZI_ZIP}"

      sudo ln -sf "/opt/${YAZI_DIR}/yazi" /usr/local/bin/yazi
      sudo ln -sf "/opt/${YAZI_DIR}/ya"   /usr/local/bin/ya

      # 安装 zsh 补全（如果 zip 中包含 completions/ 目录）
      local COMPLETIONS_SRC="/opt/${YAZI_DIR}/completions"
      local ZSH_SITE_FUNC="/usr/local/share/zsh/site-functions"
      if [ -d "$COMPLETIONS_SRC" ]; then
        sudo mkdir -p "$ZSH_SITE_FUNC"
        [ -f "${COMPLETIONS_SRC}/_yazi" ] && sudo cp "${COMPLETIONS_SRC}/_yazi" "${ZSH_SITE_FUNC}/_yazi" \
          && log_info "已安装 yazi zsh 补全：${ZSH_SITE_FUNC}/_yazi"
        [ -f "${COMPLETIONS_SRC}/_ya" ]   && sudo cp "${COMPLETIONS_SRC}/_ya"   "${ZSH_SITE_FUNC}/_ya"   \
          && log_info "已安装 ya zsh 补全：${ZSH_SITE_FUNC}/_ya"
      else
        log_warning "未找到 completions/ 目录，跳过 zsh 补全安装（可手动从 release 包中提取）"
      fi

      log_success "yazi 安装完成: $(yazi --version 2>/dev/null || echo '版本未知')"
      log_info "运行 ya pkg update 安装插件..."
      ya pkg update || log_warning "ya pkg update 失败，稍后可手动运行"
    fi
  fi

  # ── tssh ──
  if ! command -v tssh &>/dev/null; then
    if confirm_action "是否安装 tssh (支持文件传输的 SSH 客户端)？" "y"; then
      stew_install "trzsz/tssh" "tssh" "go install github.com/trzsz/tssh@latest"
    fi
  fi

  # ── uv（官方 install.sh）──
  if ! command -v uv &>/dev/null; then
    if confirm_action "是否安装 uv (Python 包管理工具)？" "y"; then
      log_info "使用官方脚本安装 uv..."
      curl -LsSf https://astral.sh/uv/install.sh | sh
    fi
  fi

  # ── nexttrace（直接 binary，非标准 release 格式）──
  if ! command -v nexttrace &>/dev/null; then
    if confirm_action "是否安装 nexttrace (路由追踪工具)？" "y"; then
      log_info "安装 nexttrace..."
      mkdir -p "$HOME/.local/bin"
      curl -o "$HOME/.local/bin/nexttrace" -L \
        https://github.com/nxtrace/NTrace-core/releases/latest/download/nexttrace_linux_amd64
      chmod +x "$HOME/.local/bin/nexttrace"
      log_success "nexttrace 安装完成"
    fi
  fi

  # ── xh ──
  if ! command -v xh &>/dev/null; then
    if confirm_action "是否安装 xh (现代 HTTP 客户端)？" "y"; then
      stew_install "ducaale/xh" "xh" ""
    fi
  fi

  # ── doggo ──
  if ! command -v doggo &>/dev/null; then
    if confirm_action "是否安装 doggo (DNS 查询工具)？" "y"; then
      stew_install "mr-karan/doggo" "doggo" ""
    fi
  fi

  # ── Nerd Fonts ──
  if confirm_action "是否安装 Nerd Fonts？" "y"; then
    install_nerd_fonts
  fi

  # ── zsh 补全文件 ──
  install_linux_completions

  log_success "Linux 工具安装完成"
}

# 为 Linux 手动安装的工具生成 zsh 补全
# 补全文件安装至 /usr/local/share/zsh/site-functions/，与 macOS Homebrew 行为对齐
install_linux_completions() {
  local ZSH_SITE="/usr/local/share/zsh/site-functions"
  sudo mkdir -p "$ZSH_SITE"
  log_info "安装 zsh 补全文件到 ${ZSH_SITE}..."

  # 辅助：通过 CLI 命令生成补全并写入
  # 修复 pipeline bug：用临时文件捕获输出，检查内容非空再安装
  _gen_completion() {
    local bin="$1" cmd="$2" dest="${ZSH_SITE}/$3"
    if ! command -v "$bin" &>/dev/null; then return; fi
    local tmp
    tmp=$(mktemp)
    if eval "$cmd" > "$tmp" 2>/dev/null && [ -s "$tmp" ]; then
      sudo cp "$tmp" "$dest"
      log_info "补全已安装：$dest"
    else
      log_warning "$bin 补全生成失败（命令：$cmd）"
    fi
    rm -f "$tmp"
  }

  # 辅助：从 URL 下载补全文件
  _fetch_completion() {
    local bin="$1" url="$2" dest="${ZSH_SITE}/$3"
    if ! command -v "$bin" &>/dev/null; then return; fi
    local tmp
    tmp=$(mktemp)
    if curl -fsSL "$url" -o "$tmp" 2>/dev/null && [ -s "$tmp" ]; then
      sudo cp "$tmp" "$dest"
      log_info "补全已安装：$dest"
    else
      log_warning "$bin 补全下载失败（URL：$url）"
    fi
    rm -f "$tmp"
  }

  # ── 通过 CLI 生成补全的工具 ──

  # starship
  _gen_completion starship "starship completions zsh" "_starship"

  # fd
  _gen_completion fd "fd --gen-completions zsh" "_fd"

  # ripgrep（正确语法：--generate complete-zsh）
  _gen_completion rg "rg --generate complete-zsh" "_rg"

  # fnm
  _gen_completion fnm "fnm completions --shell zsh" "_fnm"

  # uv
  _gen_completion uv "uv generate-shell-completion zsh" "_uv"

  # uvx（正确命令：uvx --generate-shell-completion，非 uv ... --tool-name uvx）
  _gen_completion uvx "uvx --generate-shell-completion zsh" "_uvx"

  # zellij
  _gen_completion zellij "zellij setup --generate-completion zsh" "_zellij"

  # doggo（doggo completions zsh）
  _gen_completion doggo "doggo completions zsh" "_doggo"

  # ouch（已在安装步骤中从 /opt 复制，此处跳过）

  # ── 从 GitHub raw 下载的工具（无 CLI 生成支持）──

  # xh（静态 completion 文件，无 CLI flag；已通过 GitHub API 确认路径）
  _fetch_completion xh \
    "https://raw.githubusercontent.com/ducaale/xh/master/completions/_xh" \
    "_xh"

  # helix（文件名是 hx.zsh，存为 _hx）
  _fetch_completion hx \
    "https://raw.githubusercontent.com/helix-editor/helix/master/contrib/completion/hx.zsh" \
    "_hx"

  # zoxide（已验证可访问）
  _fetch_completion zoxide \
    "https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/contrib/completions/_zoxide" \
    "_zoxide"

  # ── 从 release tarball 提取（源码无静态文件，build 时生成）──
  # 辅助：下载 release tar.gz，按文件名通配提取补全文件
  _extract_tar_completion() {
    local bin="$1" repo="$2" tar_suffix="$3" comp_glob="$4" dest="${ZSH_SITE}/$5"
    if ! command -v "$bin" &>/dev/null; then return; fi
    local tag
    tag=$(curl -s "https://api.github.com/repos/${repo}/releases/latest" \
      | grep '"tag_name"' | cut -d'"' -f4)
    local url="https://github.com/${repo}/releases/download/${tag}/${tar_suffix/VERSION/${tag}}"
    local tmptar tmpdir
    tmptar=$(mktemp --suffix=.tar.gz)
    tmpdir=$(mktemp -d)
    if wget -q -O "$tmptar" "$url" 2>/dev/null && [ -s "$tmptar" ]; then
      tar -xzf "$tmptar" -C "$tmpdir" 2>/dev/null
      local comp_file
      comp_file=$(find "$tmpdir" -name "$comp_glob" | head -1)
      if [ -n "$comp_file" ] && [ -s "$comp_file" ]; then
        sudo cp "$comp_file" "$dest"
        log_info "补全已安装：$dest"
      else
        log_warning "$bin release tar 中未找到 ${comp_glob}，跳过"
      fi
    else
      log_warning "$bin release tar 下载失败（$url）"
    fi
    rm -rf "$tmptar" "$tmpdir"
  }

  # lsd（release tar 内含 autocomplete/_lsd）
  _extract_tar_completion lsd \
    "lsd-rs/lsd" \
    "lsd-VERSION-x86_64-unknown-linux-gnu.tar.gz" \
    "_lsd" \
    "_lsd"

  # ── 从 /opt 解压目录中查找补全文件 ──

  # bat / ya（已在安装步骤中从 /opt 复制，此处跳过）

  # delta（release zip 内含 completions/）
  local DELTA_COMP
  DELTA_COMP=$(find /opt -name '_delta' -path '*/completions/*' 2>/dev/null | head -1)
  if [ -n "$DELTA_COMP" ]; then
    sudo cp "$DELTA_COMP" "${ZSH_SITE}/_delta"
    log_info "补全已安装：${ZSH_SITE}/_delta"
  fi

  # yazi / ya（已在安装步骤中从 release zip 复制，此处跳过）

  # fzf（标准 _fzf 补全文件通常在安装目录内）
  if command -v fzf &>/dev/null; then
    local FZF_COMP_FILE
    FZF_COMP_FILE=$(find /usr /home -name '_fzf' 2>/dev/null | head -1)
    if [ -n "$FZF_COMP_FILE" ]; then
      sudo cp "$FZF_COMP_FILE" "${ZSH_SITE}/_fzf"
      log_info "补全已安装：${ZSH_SITE}/_fzf"
    fi
  fi

  # docker（官方 GitHub 维护的静态 _docker 补全文件）
  _fetch_completion docker \
    "https://raw.githubusercontent.com/docker/cli/master/contrib/completion/zsh/_docker" \
    "_docker"

  log_success "zsh 补全安装完成（需重启 zsh 或执行 compinit 生效）"
}

# 检查并安装必要的依赖
install_dependencies() {
  log_info "检查并安装必要的依赖..."

  # 首先安装 Homebrew (macOS)
  install_homebrew

  # 先安装 ZSH，确保它是默认 shell
  install_zsh

  # 安装 Rust
  install_rust

  # 安装 Go
  install_go

  # 安装 Python 相关工具
  install_python_tools

  # 安装 fnm
  install_fnm

  # 安装 jenv
  install_jenv

  # 安装 exiftool
  install_exiftool

  # 安装 Go 工具
  install_go_tools

  if [ "$OS" = "macos" ]; then
    # 安装必要的包
    if confirm_action "是否安装基础工具 (git, stow)？" "y"; then
      log_info "安装必要的包..."
      brew install git stow
    fi

    # 安装 stow 列表中的软件
    if confirm_action "是否安装推荐软件 (starship, neovim, helix, bat, lsd, yazi, git-delta)？" "y"; then
      log_info "安装其他推荐的软件..."
      brew install starship neovim helix bat lsd yazi git-delta
    fi

    # 安装额外的工具
    if confirm_action "是否安装额外工具 (fd, ripgrep, fzf, zoxide, jq)？" "y"; then
      log_info "安装额外的常用工具..."
      brew install fd ripgrep fzf zoxide jq
    fi

    # 安装 Nerd Fonts
    if confirm_action "是否安装 Nerd Fonts？" "y"; then
      install_nerd_fonts
    fi

    # 安装 macOS 特定工具
    if confirm_action "是否安装 macOS 特定工具 (trash, kitty, duf)？" "y"; then
      log_info "安装 macOS 特定工具..."
      brew install trash kitty duf
    fi

    # 安装 nexttrace
    if ! command -v nexttrace &> /dev/null; then
      if confirm_action "是否安装 nexttrace (路由追踪工具)？" "y"; then
        log_info "安装 nexttrace..."
        brew install nexttrace
      fi
    fi

    # 安装 dua
    if ! command -v dua &> /dev/null; then
      if confirm_action "是否安装 dua (磁盘使用分析工具)？" "y"; then
        log_info "安装 dua..."
        brew install dua-cli
      fi
    fi

    # 安装 ouch (解压工具)
    if ! command -v ouch &> /dev/null; then
      if confirm_action "是否安装 ouch (解压缩工具)？" "y"; then
        log_info "安装 ouch..."
        brew install ouch
      fi
    fi

    # 使用 cargo 安装 zellij (如果从 brew 安装失败)
    if ! command -v zellij &> /dev/null; then
      if confirm_action "是否安装 zellij (终端复用器)？" "y"; then
        log_info "使用 cargo 安装 zellij..."
        cargo install --locked zellij
      fi
    fi

    # 使用 Go 安装 tssh
    if ! command -v tssh &> /dev/null; then
      if confirm_action "是否安装 tssh (支持传输文件的 SSH 客户端)？" "y"; then
        log_info "使用 Go 安装 tssh..."
        go install github.com/trzsz/tssh@latest
      fi
    fi

  elif [ "$OS" = "linux" ]; then
    # Linux 统一安装：三层架构
    # 第一层：最小基础包 + Clash（唯一需要发行版判断的地方）
    install_linux_base_packages

    # 第二层：安装 stew（需要 Go 环境）
    install_stew

    # 第三层：用 stew 统一安装所有工具，不区分发行版
    install_linux_tools
  fi

  log_success "依赖安装完成"
}

# 克隆 dotfiles 仓库
clone_dotfiles() {
  if [ -d "$DOTFILES_DIR" ]; then
    log_info "dotfiles 仓库已存在，跳过克隆步骤"
  else
    log_info "克隆 dotfiles 仓库到 $DOTFILES_DIR"
    git clone --depth=1 https://github.com/m0cun/dotfiles.git "$DOTFILES_DIR"

    if [ $? -ne 0 ]; then
      log_error "克隆仓库失败"
      exit 1
    fi

    log_success "仓库克隆成功"
  fi
}

# 创建必要的目录
create_directories() {
  log_info "创建必要的目录..."

  mkdir -p "$CONFIG_DIR"
  mkdir -p "$ZSH_DIR"
  mkdir -p "$ZSH_DIR/configs"
  mkdir -p "$ZSH_DIR/configs/local_configs"
  mkdir -p "$ZSH_PLUGINS_DIR"

  log_success "目录创建完成"
}

# 安装 ZSH 插件
install_zsh_plugins() {
  log_info "安装 ZSH 插件..."

  # 如果是通过 Git 克隆的仓库，更新子模块
  if [ -d "$DOTFILES_DIR/.git" ]; then
    log_info "检测到 Git 仓库，初始化并更新子模块..."
    cd "$DOTFILES_DIR"
    git submodule init
    git submodule update --recursive
    log_success "Git 子模块更新完成"
    return 0
  fi

  # 以下代码仅在非 Git 克隆的情况下执行
  # 安装 fast-syntax-highlighting
  if [ ! -d "$ZSH_PLUGINS_DIR/fast-syntax-highlighting" ]; then
    log_info "安装 fast-syntax-highlighting..."
    git clone --depth=1 https://github.com/zdharma-continuum/fast-syntax-highlighting.git "$ZSH_PLUGINS_DIR/fast-syntax-highlighting"
  fi

  # 安装 zsh-autosuggestions
  if [ ! -d "$ZSH_PLUGINS_DIR/zsh-autosuggestions" ]; then
    log_info "安装 zsh-autosuggestions..."
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_PLUGINS_DIR/zsh-autosuggestions"
  fi

  # 安装 zsh-history-substring-search
  if [ ! -d "$ZSH_PLUGINS_DIR/zsh-history-substring-search" ]; then
    log_info "安装 zsh-history-substring-search..."
    git clone --depth=1 https://github.com/zsh-users/zsh-history-substring-search.git "$ZSH_PLUGINS_DIR/zsh-history-substring-search"
  fi

  # 安装 zsh-you-should-use
  if [ ! -d "$ZSH_PLUGINS_DIR/zsh-you-should-use" ]; then
    log_info "安装 zsh-you-should-use..."
    git clone --depth=1 https://github.com/MichaelAquilina/zsh-you-should-use.git "$ZSH_PLUGINS_DIR/zsh-you-should-use"
  fi

  # 安装 forgit
  if [ ! -d "$ZSH_PLUGINS_DIR/forgit" ]; then
    log_info "安装 forgit..."
    git clone --depth=1 https://github.com/wfxr/forgit.git "$ZSH_PLUGINS_DIR/forgit"
  fi

  # 安装 fzf-tab
  if [ ! -d "$ZSH_PLUGINS_DIR/fzf-tab" ]; then
    log_info "安装 fzf-tab..."
    git clone --depth=1 https://github.com/Aloxaf/fzf-tab.git "$ZSH_PLUGINS_DIR/fzf-tab"
  fi

  log_success "ZSH 插件安装完成"
}

# 备份现有文件
backup_existing_files() {
  local package="$1"
  local backup_dir="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
  local has_conflicts=false

  log_info "检查 $package 的文件冲突..."

  # 使用 stow --no 进行干运行，检查冲突
  local conflicts=$(stow --no --verbose=2 "$package" 2>&1 | grep "existing target is" || true)

  if [[ -n "$conflicts" ]]; then
    has_conflicts=true
    log_warning "发现现有文件冲突，准备备份..."

    if confirm_action "是否备份现有文件并继续？" "y"; then
      mkdir -p "$backup_dir"

      # 解析冲突文件并备份
      echo "$conflicts" | while read -r line; do
        if [[ "$line" =~ "existing target is" ]]; then
          # 提取文件路径
          target_file=$(echo "$line" | sed -n 's/.*existing target is \(.*\) but is.*/\1/p')
          if [[ -n "$target_file" && -e "$target_file" ]]; then
            # 创建备份目录结构
            backup_file="$backup_dir/$target_file"
            mkdir -p "$(dirname "$backup_file")"
            cp -r "$target_file" "$backup_file"
            log_info "已备份: $target_file -> $backup_file"
            rm -rf "$target_file"
          fi
        fi
      done

      log_success "文件备份完成到: $backup_dir"
    else
      log_error "用户取消，跳过 $package 的符号链接创建"
      return 1
    fi
  fi

  return 0
}

# 安全执行 stow 命令
safe_stow() {
  local package="$1"

  if [ ! -d "$package" ]; then
    log_warning "目录 $package 不存在，跳过"
    return 0
  fi

  # 备份冲突文件
  if ! backup_existing_files "$package"; then
    return 1
  fi

  # 执行 stow
  log_info "为 $package 创建符号链接..."
  if stow "$package"; then
    log_success "$package 符号链接创建完成"
  else
    log_error "$package 符号链接创建失败"
    return 1
  fi
}

# 使用 stow 创建符号链接
create_symlinks() {
  log_info "使用 stow 创建符号链接..."

  # 进入 dotfiles 目录
  cd "$DOTFILES_DIR"

  # 定义要处理的包列表
  local packages=("zsh" "starship" "nvim" "helix" "bat" "lsd" "yazi" "zellij" "delta")

  # 安全地为每个包创建符号链接
  for package in "${packages[@]}"; do
    safe_stow "$package"
  done

  # tssh 如果存在则创建符号链接
  if [ -d "tssh" ]; then
    safe_stow "tssh"
  fi

  # kitty 不默认安装，但如果已安装则创建符号链接
  if command -v kitty &> /dev/null; then
    log_info "检测到 kitty 已安装，创建其符号链接..."
    safe_stow "kitty"
  else
    log_info "未检测到 kitty，跳过其符号链接创建"
  fi

  # 配置 git-delta
  if command -v delta &> /dev/null; then
    log_info "配置 git-delta..."
    git config --global core.pager delta
    git config --global interactive.diffFilter "delta --color-only"
    git config --global delta.navigate true
    git config --global delta.dark true
    git config --global delta.line-numbers true
    git config --global delta.side-by-side true
    git config --global delta.features catppuccin-mocha
    git config --global merge.conflictstyle zdiff3
    git config --global diff.colorMoved default

    # 设置 delta 的主题文件包含路径
    git config --global include.path "$HOME/.config/delta/catppuccin.gitconfig"

    log_success "git-delta 配置完成"
  fi

  log_success "符号链接创建完成"
}

# 主函数
main() {
  log_info "开始安装 dotfiles..."

  detect_os
  install_dependencies
  clone_dotfiles
  create_directories
  install_zsh_plugins
  create_symlinks

  log_success "dotfiles 安装完成！请重新登录以应用所有更改。"
  log_info "对于更多自定义，请查看 README.md 文件。"
}

# 支持直接调用脚本内任意函数：bash install.sh <function_name>
# 不传参数时执行完整安装流程（main）
if [[ $# -gt 0 ]]; then
  if declare -f "$1" > /dev/null 2>&1; then
    "$@"
  else
    log_error "未找到函数: $1"
    log_info "可用函数示例："
    log_info "  bash install.sh install_linux_completions"
    log_info "  bash install.sh install_linux_tools"
    log_info "  bash install.sh install_stew"
    exit 1
  fi
else
  main
fi
