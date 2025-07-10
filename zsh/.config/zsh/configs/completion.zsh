# 补全配置模块

# 自动加载补全系统
autoload -Uz compinit
compinit

# 补全选项
setopt AUTO_LIST               # 自动列出可能的补全
setopt AUTO_MENU               # 自动使用菜单补全
setopt COMPLETE_IN_WORD        # 在单词中间补全
setopt ALWAYS_TO_END           # 将光标移动到单词末尾
setopt MENU_COMPLETE           # 在第一次按Tab时进行自动补全

# Homebrew补全
if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
  autoload -Uz compinit
  compinit
fi

# 补全样式
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' group-name ''
zstyle ':completion:*:*:*:*:descriptions' format '%F{green}-- %d --%f'
zstyle ':completion:*:*:*:*:corrections' format '%F{yellow}!- %d (errors: %e) -!%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- 没有匹配项 --%f'

# 加载补全缓存
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.cache/zsh/zcompcache" 