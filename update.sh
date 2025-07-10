#!/bin/bash

# 终端颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

# 目录设置
DOTFILES_DIR="$HOME/.dotfile"
ZSH_PLUGINS_DIR="$HOME/.config/zsh/plugins"

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

# 更新系统包和工具
update_system_packages() {
  log_info "更新系统包和工具..."
  
  if [ "$OS" = "macos" ]; then
    if command -v brew &> /dev/null; then
      log_info "更新 Homebrew 包..."
      brew update && brew upgrade
      brew cleanup
    fi
  elif [ "$OS" = "linux" ]; then
    if [ "$DISTRO" = "ubuntu" ] || [ "$DISTRO" = "debian" ] || [ "$DISTRO" = "kali" ]; then
      log_info "更新 apt 包..."
      sudo apt update && sudo apt upgrade -y
      sudo apt autoremove -y
    elif [ "$DISTRO" = "redhat" ]; then
      log_info "更新 dnf 包..."
      sudo dnf upgrade -y
    elif [ "$DISTRO" = "arch" ]; then
      log_info "更新 pacman 包..."
      sudo pacman -Syu --noconfirm
    fi
  fi
  
  # 更新 Python 工具
  if command -v uv &> /dev/null; then
    log_info "更新 uv 及 Python 包..."
    if [ "$OS" = "macos" ]; then
      brew upgrade uv
    elif command -v pip &> /dev/null; then
      pip install --upgrade uv
    elif command -v pip3 &> /dev/null; then
      pip3 install --upgrade uv
    else
      curl -sSf https://astral.sh/uv/install.sh | sh
    fi
  fi
  
  # 更新 Node.js 版本管理工具
  if command -v fnm &> /dev/null; then
    log_info "更新 fnm..."
    if [ "$OS" = "macos" ]; then
      brew upgrade fnm
    else
      # fnm 自动更新
      log_info "fnm 版本：$(fnm --version)"
    fi
  fi
  
  # 更新 Java 版本管理工具
  if command -v jenv &> /dev/null; then
    log_info "更新 jenv..."
    if [ "$OS" = "macos" ]; then
      brew upgrade jenv
    else
      # jenv 手动更新
      cd ~/.jenv && git pull
    fi
  fi
  
  # 更新 Rust 工具
  if command -v rustup &> /dev/null; then
    log_info "更新 Rust..."
    rustup update
    
    # 更新常用的 Rust 包
    if command -v cargo &> /dev/null; then
      log_info "更新 Cargo 包..."
      if command -v lsd &> /dev/null && [[ "$(which lsd)" == *".cargo"* ]]; then
        cargo install --locked lsd
      fi
      if command -v zellij &> /dev/null && [[ "$(which zellij)" == *".cargo"* ]]; then
        cargo install --locked zellij
      fi
      if command -v hx &> /dev/null && [[ "$(which hx)" == *".cargo"* ]]; then
        cargo install --locked helix
      fi
      if command -v yazi &> /dev/null && [[ "$(which yazi)" == *".cargo"* ]]; then
        cargo install --locked yazi
      fi
      if command -v dua &> /dev/null; then
        cargo install --locked dua-cli
      fi
      if command -v ouch &> /dev/null; then
        cargo install --locked ouch
      fi
    fi
  fi
  
  # 更新 Go 工具
  if command -v go &> /dev/null; then
    log_info "更新 Go 工具..."
    if command -v tssh &> /dev/null; then
      go install github.com/trzsz/tssh@latest
    fi
    if command -v tcping &> /dev/null; then
      go install github.com/pouriyajamshidi/tcping/v2@latest
    fi
    if command -v gohttpserver &> /dev/null; then
      go install github.com/codeskyblue/gohttpserver@latest
    fi
  fi
  
  # 更新 nexttrace
  if command -v nexttrace &> /dev/null; then
    log_info "更新 nexttrace..."
    if [ "$OS" = "macos" ]; then
      brew upgrade nexttrace
    elif [ "$OS" = "linux" ]; then
      curl -o /tmp/nexttrace -L https://github.com/nxtrace/NTrace-core/releases/latest/download/nexttrace_linux_amd64 && \
      sudo mv /tmp/nexttrace /usr/local/bin/ && \
      sudo chmod +x /usr/local/bin/nexttrace
    fi
  fi
  
  log_success "系统包和工具更新完成"
}

# 更新 dotfiles 仓库
update_dotfiles() {
  log_info "更新 dotfiles 仓库..."
  
  if [ -d "$DOTFILES_DIR" ]; then
    cd "$DOTFILES_DIR"
    git pull
    log_success "dotfiles 仓库更新完成"
  else
    log_error "dotfiles 仓库不存在，请先运行 install.sh"
    exit 1
  fi
}

# 更新 ZSH 插件
update_zsh_plugins() {
  log_info "更新 ZSH 插件..."
  
  # 如果是通过 Git 克隆的仓库，更新子模块
  if [ -d "$DOTFILES_DIR/.git" ]; then
    log_info "检测到 Git 仓库，更新子模块..."
    cd "$DOTFILES_DIR"
    git submodule update --remote --recursive
    log_success "Git 子模块更新完成"
    return 0
  fi
  
  # 以下代码仅在非 Git 克隆的情况下执行
  # 更新 fast-syntax-highlighting
  if [ -d "$ZSH_PLUGINS_DIR/fast-syntax-highlighting" ]; then
    log_info "更新 fast-syntax-highlighting..."
    cd "$ZSH_PLUGINS_DIR/fast-syntax-highlighting"
    git pull
  fi
  
  # 更新 zsh-autosuggestions
  if [ -d "$ZSH_PLUGINS_DIR/zsh-autosuggestions" ]; then
    log_info "更新 zsh-autosuggestions..."
    cd "$ZSH_PLUGINS_DIR/zsh-autosuggestions"
    git pull
  fi
  
  # 更新 zsh-history-substring-search
  if [ -d "$ZSH_PLUGINS_DIR/zsh-history-substring-search" ]; then
    log_info "更新 zsh-history-substring-search..."
    cd "$ZSH_PLUGINS_DIR/zsh-history-substring-search"
    git pull
  fi
  
  # 更新 zsh-you-should-use
  if [ -d "$ZSH_PLUGINS_DIR/zsh-you-should-use" ]; then
    log_info "更新 zsh-you-should-use..."
    cd "$ZSH_PLUGINS_DIR/zsh-you-should-use"
    git pull
  fi
  
  # 更新 forgit
  if [ -d "$ZSH_PLUGINS_DIR/forgit" ]; then
    log_info "更新 forgit..."
    cd "$ZSH_PLUGINS_DIR/forgit"
    git pull
  fi
  
  # 更新 fzf-tab
  if [ -d "$ZSH_PLUGINS_DIR/fzf-tab" ]; then
    log_info "更新 fzf-tab..."
    cd "$ZSH_PLUGINS_DIR/fzf-tab"
    git pull
  fi
  
  # 更新 fzf (如果通过 git 安装)
  if [ -d "$HOME/.fzf" ]; then
    log_info "更新 fzf..."
    cd "$HOME/.fzf"
    git pull
    ./install --no-bash --no-fish --key-bindings --completion --no-update-rc
  fi
  
  log_success "ZSH 插件更新完成"
}

# 重新应用符号链接
reapply_symlinks() {
  log_info "重新应用符号链接..."
  
  # 进入 dotfiles 目录
  cd "$DOTFILES_DIR"
  
  # 使用 stow 重新创建符号链接
  stow -R zsh
  stow -R starship
  stow -R nvim
  stow -R helix
  stow -R bat
  stow -R lsd
  stow -R yazi
  stow -R zellij
  
  # tssh 如果存在则更新符号链接
  if [ -d "tssh" ]; then
    stow -R tssh
  fi
  
  # kitty 不默认安装，但如果已安装则更新
  if command -v kitty &> /dev/null; then
    log_info "检测到 kitty 已安装，更新其符号链接..."
    stow -R kitty
  else
    log_info "未检测到 kitty，跳过其符号链接更新"
  fi
  
  log_success "符号链接重新应用完成"
}

# 主函数
main() {
  log_info "开始更新 dotfiles..."
  
  detect_os
  update_system_packages
  update_dotfiles
  update_zsh_plugins
  reapply_symlinks
  
  log_success "dotfiles 更新完成！"
  log_info "对于更多自定义，请查看 README.md 文件。"
}

# 运行主函数
main 