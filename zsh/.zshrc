# 主要的.zshrc文件
# 这个文件负责加载所有其他的zsh配置模块

# 加载性能分析（如果需要调试加载速度问题）
# zmodload zsh/zprof

# 设置基本变量
export XDG_CONFIG_HOME="$HOME/.config"
export ZDOTDIR="$HOME/.config/zsh"
export DOTFILES="$HOME/.dotfile"
export ZSH_CONFIG_DIR="$ZDOTDIR/configs"

# 加载zsh模块
# 加载顺序很重要：history > completion > prompt > plugins > aliases > exports > functions

# 历史记录配置
source "$ZDOTDIR/configs/history.zsh"

# 判断操作系统类型
source "$ZDOTDIR/configs/os-detection.zsh"

# 补全配置
source "$ZDOTDIR/configs/completion.zsh"

# 提示符配置
source "$ZDOTDIR/configs/prompt.zsh"

# 插件配置
source "$ZDOTDIR/configs/plugins.zsh"

# 别名配置
source "$ZDOTDIR/configs/aliases.zsh"

# 环境变量配置
source "$ZDOTDIR/configs/exports.zsh"

# 函数配置
source "$ZDOTDIR/configs/functions.zsh"

# 加载特定于操作系统的配置
if [[ -f "$ZDOTDIR/configs/os-specific/${OS_TYPE}.zsh" ]]; then
  source "$ZDOTDIR/configs/os-specific/${OS_TYPE}.zsh"
fi

# 加载特定于操作系统的环境变量
if [[ -f "$ZDOTDIR/configs/os-specific/exports-${OS_TYPE}.zsh" ]]; then
  source "$ZDOTDIR/configs/os-specific/exports-${OS_TYPE}.zsh"
fi

# 加载本地配置目录中的文件（不受版本控制的配置）
# 使用数组和 nullglob 选项避免无匹配文件时的错误
setopt local_options nullglob
config_files=("$ZDOTDIR/configs/local_configs/"*.zsh)
for config_file in "${config_files[@]}"; do
  [[ -f "$config_file" ]] && source "$config_file"
done

# 结束性能分析（如果已启用）
# zprof 