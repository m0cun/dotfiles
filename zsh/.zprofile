# .zprofile
# 这个文件在登录时会被加载，而.zshrc在每次新建终端时都会加载
# 在此文件中设置只需在登录时加载一次的设置

# 加载操作系统特定的配置
# 判断操作系统类型
if [[ "$(uname)" == "Darwin" ]]; then
  # macOS系统

  # 加载OrbStack配置（如果存在）
  if [[ -f "$HOME/.orbstack/shell/init.zsh" ]]; then
    source "$HOME/.orbstack/shell/init.zsh" 2>/dev/null || :
  fi

  # 检测是否为Apple Silicon
  if [[ "$(uname -m)" == "arm64" ]]; then
    # Apple Silicon特定配置
    # 确保 Homebrew bin 目录在 PATH 中
    export PATH="$PATH:/opt/homebrew/bin"
  else
    # Intel Mac特定配置
    # 确保 Homebrew bin 目录在 PATH 中
    export PATH="$PATH:/usr/local/bin"
  fi
elif [[ "$(uname)" == "Linux" ]]; then
  # Linux系统特定配置
  # 在这里添加Linux特定的配置
  :
fi

# 加载本地配置（不受版本控制）
# 使用 ZSH_DOTDIR 而不是 ZDOTDIR，避免影响子 shell
ZSH_DOTDIR="${ZSH_DOTDIR:-$HOME/.config/zsh}"
if [[ -f "$ZSH_DOTDIR/configs/local_configs/local-profile.zsh" ]]; then
  source "$ZSH_DOTDIR/configs/local_configs/local-profile.zsh"
fi
