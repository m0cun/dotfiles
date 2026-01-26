# 别名配置模块

# ------------------------------
# 系统替代命令
# ------------------------------
# lsd - ls替代品
if command -v lsd &>/dev/null; then
  alias ls='lsd --color always'
  alias l='ls -l'
  alias la='ls -a'
  alias lla='ls -la'
  alias lt='ls --tree --depth 2'
fi

# neovim - vim替代品
if command -v nvim &>/dev/null; then
  alias vim="nvim"
fi

# trash - 安全删除替代品
if command -v trash &>/dev/null; then
  alias rm="trash -F"
fi

# ripgrep - grep替代品
if command -v rg &>/dev/null; then
  alias grep='rg'
fi

# 常用简写
alias c="clear"

# ------------------------------
# 开发工具
# ------------------------------
# Git
alias gp='git pull'

# 终端工具
if command -v zellij &>/dev/null; then
  alias ze='zellij'
fi

# 文件管理
if command -v joshuto &>/dev/null; then
  alias jo="joshuto"
fi

if command -v frogmouth &>/dev/null; then
  alias md="frogmouth"
fi

# yazi文件管理器
if command -v yazi &>/dev/null; then
  function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
      builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
  }
fi

# claude-mem
if command -v bun &>/dev/null && [[ -f "$HOME/.claude/plugins/marketplaces/thedotmack/plugin/scripts/worker-service.cjs" ]]; then
  alias claude-mem='bun "$HOME/.claude/plugins/marketplaces/thedotmack/plugin/scripts/worker-service.cjs"'
fi

# ------------------------------
# 网络工具
# ------------------------------
# kitty终端SSH修复
[[ "$TERM" == "xterm-kitty" ]] && alias ssh="TERM=xterm-256color ssh"

# 查看公网IP
alias myip='curl -s https://myip.ipip.net/json | jq "\"🎉 IP: \(.data.ip) | 🌍 : \(.data.location[0]) - \(.data.location[1]) - \(.data.location[2]) | 📶 : \(.data.location[4])\""'

# 查询公网IP详情
alias ipinfo='f() {
  if [ $# -eq 0 ]; then
    curl -s "http://ip-api.com/json/?lang=zh-CN";
  else
    curl -s "http://ip-api.com/json/$1?lang=zh-CN";
    fi | jq "\"🎉 IP: \(.query) | 🌍 : \(.country) - \(.regionName) - \(.city) | 📶 : \(.isp)\"";
}; f'

# 路由追踪
alias traceroute='nexttrace'

# 天气查询
alias weather='curl wttr.in'
alias we='curl wttr.in/"$(curl -s https://api.myip.la/en\?json | jq -r ".location.city")"\?format=3'
alias moon='curl wttr.in/"$(curl -s https://api.myip.la/en\?json | jq -r ".location.city")"\?format="%m\n"'

# 下载工具
if command -v xh &>/dev/null; then
  alias dw='xh --download'
fi

# 网络监听
alias listen="lsof -nP -iTCP -sTCP:listen"
# examples:
# lsof -nP -iTCP:3306 -sTCP:LISTEN
# lsof -np -i4TCP -sTCP:established

# ------------------------------
# 美化输出
# ------------------------------
# bat主题
if command -v bat &>/dev/null; then
  # 美化帮助信息
  alias bathelp='bat --plain --language=help'
  function help() {
    "$@" --help 2>&1 | bathelp
  }
fi
