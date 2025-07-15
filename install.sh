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
    elif command -v cargo &> /dev/null; then
      cargo install --git https://github.com/astral-sh/uv uv
    else
      curl -sSf https://astral.sh/uv/install.sh | sh
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
    if [ "$DISTRO" = "ubuntu" ] || [ "$DISTRO" = "debian" ] || [ "$DISTRO" = "kali" ]; then
      if confirm_action "是否更新软件包列表？" "y"; then
        log_info "更新包列表..."
        sudo apt update
      fi

      if confirm_action "是否安装基础工具 (git, stow, curl, wget)？" "y"; then
        log_info "安装必要的包..."
        sudo apt install -y git stow curl wget
      fi

      # 安装 trash-put
      if confirm_action "是否安装 trash-put (安全删除工具)？" "y"; then
        log_info "安装 trash-put..."
        sudo apt install -y trash-cli
      fi

      # 安装 starship
      if confirm_action "是否安装 Starship (终端提示符)？" "y"; then
        log_info "安装 Starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
      fi

      # 安装 neovim
      if confirm_action "是否安装 Neovim (编辑器)？" "y"; then
        log_info "安装 Neovim..."
        sudo apt install -y neovim
      fi

      # 安装 bat (batcat 在 Ubuntu/Debian 上)
      if confirm_action "是否安装 bat (增强版 cat)？" "y"; then
        log_info "安装 bat..."
        sudo apt install -y bat || sudo apt install -y batcat
      fi

      # 安装 fd-find (fd 在 Ubuntu/Debian 上是 fd-find)
      if confirm_action "是否安装 fd (增强版 find)？" "y"; then
        log_info "安装 fd..."
        sudo apt install -y fd-find
        if ! command -v fd &> /dev/null; then
          mkdir -p ~/.local/bin
          ln -sf $(which fdfind) ~/.local/bin/fd
          export PATH="$HOME/.local/bin:$PATH"
        fi
      fi

      # 安装 git-delta
      if confirm_action "是否安装 git-delta (增强版 git diff)？" "y"; then
        log_info "安装 git-delta..."
        cargo install git-delta
      fi

      # 安装 jq
      if confirm_action "是否安装 jq (JSON 处理工具)？" "y"; then
        log_info "安装 jq..."
        sudo apt install -y jq
      fi

      # 安装 fzf
      if ! command -v fzf &> /dev/null; then
        if confirm_action "是否安装 fzf (模糊查找工具)？" "y"; then
          log_info "安装 fzf..."
          git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
          ~/.fzf/install --no-bash --no-fish --key-bindings --completion --no-update-rc
        fi
      fi

      # 安装 zoxide
      if ! command -v zoxide &> /dev/null; then
        if confirm_action "是否安装 zoxide (智能目录跳转)？" "y"; then
          log_info "安装 zoxide..."
          curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
        fi
      fi

      # 安装 Nerd Fonts
      if confirm_action "是否安装 Nerd Fonts？" "y"; then
        install_nerd_fonts
      fi

      # 安装 nexttrace
      if ! command -v nexttrace &> /dev/null; then
        if confirm_action "是否安装 nexttrace (路由追踪工具)？" "y"; then
          log_info "安装 nexttrace..."
          curl -o /tmp/nexttrace -L https://github.com/nxtrace/NTrace-core/releases/latest/download/nexttrace_linux_amd64 && \
          sudo mv /tmp/nexttrace /usr/local/bin/ && \
          sudo chmod +x /usr/local/bin/nexttrace
        fi
      fi

      # 安装 dua
      if ! command -v dua &> /dev/null; then
        if confirm_action "是否安装 dua (磁盘使用分析工具)？" "y"; then
          log_info "安装 dua..."
          cargo install --locked dua-cli
        fi
      fi

      # 安装 ouch (解压工具)
      if ! command -v ouch &> /dev/null; then
        if confirm_action "是否安装 ouch (解压缩工具)？" "y"; then
          log_info "安装 ouch..."
          cargo install --locked ouch
        fi
      fi

      # 安装 lsd
      if ! command -v lsd &> /dev/null; then
        if confirm_action "是否安装 lsd (增强版 ls)？" "y"; then
          log_info "安装 lsd..."
          # 获取 lsd 的最新版本
          LSD_DEB_URL=$(curl -s https://api.github.com/repos/Peltoche/lsd/releases/latest | grep "browser_download_url.*_amd64.deb" | head -n 1 | cut -d '"' -f 4)
          if [ -n "$LSD_DEB_URL" ]; then
            wget -O /tmp/lsd.deb "$LSD_DEB_URL"
            sudo dpkg -i /tmp/lsd.deb
            rm /tmp/lsd.deb
          else
            log_info "使用 cargo 安装 lsd..."
            cargo install --locked lsd
          fi
        fi
      fi

      # 安装 zellij
      if ! command -v zellij &> /dev/null; then
        if confirm_action "是否安装 zellij (终端复用器)？" "y"; then
          log_info "安装 zellij..."
          # 获取 zellij 的最新版本
          ZELLIJ_DEB_URL=$(curl -s https://api.github.com/repos/zellij-org/zellij/releases/latest | grep "browser_download_url.*_amd64.deb" | head -n 1 | cut -d '"' -f 4)
          if [ -n "$ZELLIJ_DEB_URL" ]; then
            wget -O /tmp/zellij.deb "$ZELLIJ_DEB_URL"
            sudo dpkg -i /tmp/zellij.deb
            rm /tmp/zellij.deb
          else
            log_info "使用 cargo 安装 zellij..."
            cargo install --locked zellij
          fi
        fi
      fi

      # helix 安装
      if ! command -v hx &> /dev/null; then
        if confirm_action "是否安装 helix (现代编辑器)？" "y"; then
          log_info "安装 helix..."
          # 获取 helix 的最新版本
          HELIX_DEB_URL=$(curl -s https://api.github.com/repos/helix-editor/helix/releases/latest | grep "browser_download_url.*_amd64.deb" | head -n 1 | cut -d '"' -f 4)
          if [ -n "$HELIX_DEB_URL" ]; then
            wget -O /tmp/helix.deb "$HELIX_DEB_URL"
            sudo dpkg -i /tmp/helix.deb
            rm /tmp/helix.deb
          else
            log_info "使用 cargo 安装 helix..."
            cargo install --locked helix
          fi
        fi
      fi

      # yazi 安装
      if ! command -v yazi &> /dev/null; then
        if confirm_action "是否安装 yazi (文件管理器)？" "y"; then
          log_info "安装 yazi..."
          cargo install --locked yazi
        fi
      fi

      # 使用 Go 安装 tssh
      if ! command -v tssh &> /dev/null && command -v go &> /dev/null; then
        if confirm_action "是否安装 tssh (支持传输文件的 SSH 客户端)？" "y"; then
          log_info "使用 Go 安装 tssh..."
          go install github.com/trzsz/tssh@latest
        fi
      fi

    elif [ "$DISTRO" = "redhat" ]; then
      # RedHat/Fedora/CentOS 安装
      if confirm_action "是否安装基础工具 (git, stow, curl, wget)？" "y"; then
        log_info "安装必要的包..."
        sudo dnf install -y git stow curl wget
      fi

      # 安装 trash-put
      if confirm_action "是否安装 trash-put (安全删除工具)？" "y"; then
        log_info "安装 trash-put..."
        sudo dnf install -y trash-cli
      fi

      # 安装 starship
      if confirm_action "是否安装 Starship (终端提示符)？" "y"; then
        log_info "安装 Starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
      fi

      # 安装 neovim
      if confirm_action "是否安装 Neovim (编辑器)？" "y"; then
        log_info "安装 Neovim..."
        sudo dnf install -y neovim
      fi

      # 安装 bat
      if confirm_action "是否安装 bat (增强版 cat)？" "y"; then
        log_info "安装 bat..."
        sudo dnf install -y bat
      fi

      # 安装 fd-find
      if confirm_action "是否安装 fd (增强版 find)？" "y"; then
        log_info "安装 fd..."
        sudo dnf install -y fd-find
      fi

      # 安装 ripgrep
      if confirm_action "是否安装 ripgrep (增强版 grep)？" "y"; then
        log_info "安装 ripgrep..."
        sudo dnf install -y ripgrep
      fi

      # 安装 jq
      if confirm_action "是否安装 jq (JSON 处理工具)？" "y"; then
        log_info "安装 jq..."
        sudo dnf install -y jq
      fi

      # 安装 fzf
      if ! command -v fzf &> /dev/null; then
        if confirm_action "是否安装 fzf (模糊查找工具)？" "y"; then
          log_info "安装 fzf..."
          git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
          ~/.fzf/install --no-bash --no-fish --key-bindings --completion --no-update-rc
        fi
      fi

      # 安装 zoxide
      if ! command -v zoxide &> /dev/null; then
        if confirm_action "是否安装 zoxide (智能目录跳转)？" "y"; then
          log_info "安装 zoxide..."
          curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
        fi
      fi

      # 安装 Nerd Fonts
      if confirm_action "是否安装 Nerd Fonts？" "y"; then
        install_nerd_fonts
      fi

      # 安装 nexttrace
      if ! command -v nexttrace &> /dev/null; then
        if confirm_action "是否安装 nexttrace (路由追踪工具)？" "y"; then
          log_info "安装 nexttrace..."
          curl -o /tmp/nexttrace -L https://github.com/nxtrace/NTrace-core/releases/latest/download/nexttrace_linux_amd64 && \
          sudo mv /tmp/nexttrace /usr/local/bin/ && \
          sudo chmod +x /usr/local/bin/nexttrace
        fi
      fi

      # 安装 EPEL 仓库
      if confirm_action "是否安装 EPEL 仓库 (提供额外软件包)？" "y"; then
        log_info "安装 EPEL 仓库..."
        sudo dnf install -y epel-release
      fi

      # 使用 cargo 安装一些工具
      if confirm_action "是否安装 Rust 工具 (lsd, yazi, zellij, helix, dua, ouch, git-delta)？" "y"; then
        log_info "使用 cargo 安装 lsd, yazi, zellij, helix, dua, ouch, git-delta..."
        cargo install --locked lsd
        cargo install --locked yazi
        cargo install --locked zellij
        cargo install --locked helix
        cargo install --locked dua-cli
        cargo install --locked ouch
        cargo install --locked git-delta
      fi

      # 使用 Go 安装 tssh
      if ! command -v tssh &> /dev/null && command -v go &> /dev/null; then
        if confirm_action "是否安装 tssh (支持传输文件的 SSH 客户端)？" "y"; then
          log_info "使用 Go 安装 tssh..."
          go install github.com/trzsz/tssh@latest
        fi
      fi

    elif [ "$DISTRO" = "arch" ]; then
      # Arch Linux 安装
      if confirm_action "是否安装基础工具 (git, stow, curl, wget)？" "y"; then
        log_info "安装必要的包..."
        sudo pacman -S --noconfirm git stow curl wget
      fi

      # 安装 trash-put
      if confirm_action "是否安装 trash-put (安全删除工具)？" "y"; then
        log_info "安装 trash-put..."
        sudo pacman -S --noconfirm trash-cli
      fi

      # 在 Arch 上安装软件
      if confirm_action "是否安装推荐软件包？" "y"; then
        log_info "安装其他推荐的软件..."
        sudo pacman -S --noconfirm starship neovim helix bat lsd zellij fd ripgrep fzf zoxide jq perl-image-exiftool duf git-delta
      fi

      # 安装 Nerd Fonts
      if confirm_action "是否安装 Nerd Fonts？" "y"; then
        install_nerd_fonts
      fi

      # 安装 nexttrace
      if ! command -v nexttrace &> /dev/null; then
        if confirm_action "是否安装 nexttrace (路由追踪工具)？" "y"; then
          log_info "安装 nexttrace..."
          curl -o /tmp/nexttrace -L https://github.com/nxtrace/NTrace-core/releases/latest/download/nexttrace_linux_amd64 && \
          sudo mv /tmp/nexttrace /usr/local/bin/ && \
          sudo chmod +x /usr/local/bin/nexttrace
        fi
      fi

      # yazi 可能需要从 AUR 安装
      if ! command -v yazi &> /dev/null; then
        if confirm_action "是否安装 yazi (文件管理器)？" "y"; then
          if command -v yay &> /dev/null; then
            yay -S --noconfirm yazi
          elif command -v paru &> /dev/null; then
            paru -S --noconfirm yazi
          else
            log_info "使用 cargo 安装 yazi..."
            cargo install --locked yazi
          fi
        fi
      fi

      # 安装 dua
      if ! command -v dua &> /dev/null; then
        if confirm_action "是否安装 dua (磁盘使用分析工具)？" "y"; then
          if command -v yay &> /dev/null; then
            yay -S --noconfirm dua-cli
          elif command -v paru &> /dev/null; then
            paru -S --noconfirm dua-cli
          else
            log_info "使用 cargo 安装 dua..."
            cargo install --locked dua-cli
          fi
        fi
      fi

      # 安装 ouch
      if ! command -v ouch &> /dev/null; then
        if confirm_action "是否安装 ouch (解压缩工具)？" "y"; then
          if command -v yay &> /dev/null; then
            yay -S --noconfirm ouch
          elif command -v paru &> /dev/null; then
            paru -S --noconfirm ouch
          else
            log_info "使用 cargo 安装 ouch..."
            cargo install --locked ouch
          fi
        fi
      fi

      # 使用 Go 安装 tssh
      if ! command -v tssh &> /dev/null && command -v go &> /dev/null; then
        if confirm_action "是否安装 tssh (支持传输文件的 SSH 客户端)？" "y"; then
          log_info "使用 Go 安装 tssh..."
          go install github.com/trzsz/tssh@latest
        fi
      fi
    fi
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

# 运行主函数
main
