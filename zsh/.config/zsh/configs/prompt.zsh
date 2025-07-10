# 提示符配置模块

# 使用Starship作为主要提示符
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
  export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
else
  # 如果都没有，使用简单的提示符
  autoload -Uz colors && colors
  PROMPT="%{$fg[cyan]%}%n@%m %{$fg[green]%}%~ %{$reset_color%}%# "
fi 