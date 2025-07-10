# fzf-tab配置

# fzf-tab基本配置
export RUNEWIDTH_EASTASIAN=0
export FZF_DEFAULT_OPTS="--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4 --height 25 --layout=reverse"
export FZF_DEFAULT_COMMAND="fd --exclude={.git,.idea,.vscode,.sass-cache,node_modules,build,dist,vendor} --type f"

# 禁用选项排序
zstyle ':completion:complete:*:options' sort false

# 目录列表预览
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd -1 --icon=always --color=always $realpath'

# 描述格式
zstyle ':completion:*:descriptions' format "[%d]"

# 分组颜色
zstyle ':fzf-tab:*' group-colors $'\033[15m' $'\033[14m' $'\033[33m' $'\033[35m' $'\033[15m' $'\033[14m' $'\033[33m' $'\033[35m'
zstyle ':fzf-tab:*' prefix ''

# 环境变量预览
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' fzf-preview 'echo ${(P)word}'

# 进程预览
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview '[ "$group" = "process ID" ] && ps --pid=$word -o cmd --no-headers -w -w'
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags --preview-window=down:3:wrap

# 命令选项预览
zstyle ':fzf-tab:complete:*:options' fzf-flags --preview-window=down:0:wrap

# man页面预览
if command -v batman &>/dev/null; then
  zstyle ':fzf-tab:complete:(\\|*/|)man:*' fzf-preview 'batman --color=always $word'
else
  zstyle ':fzf-tab:complete:(\\|*/|)man:*' fzf-preview 'man $word | cat'
fi

zstyle ':fzf-tab:complete:(\\|)run-help:*' fzf-preview 'run-help $word'

# Homebrew预览
zstyle ':fzf-tab:complete:brew-(install|uninstall|search|info):*-argument-rest' fzf-preview 'brew info $word'

# Git预览
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview 'git diff --color=always $word' 