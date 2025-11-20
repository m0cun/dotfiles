# 插件配置模块

# 定义插件目录
# 使用 ZSH_DOTDIR 而不是 ZDOTDIR
ZSH_DOTDIR="${ZSH_DOTDIR:-$HOME/.config/zsh}"
PLUGINS_DIR="$ZSH_DOTDIR/plugins"

# fzf - 模糊查找工具
if command -v fzf &>/dev/null; then
  # Set up fzf key bindings and fuzzy completion
  # https://github.com/junegunn/fzf
  source <(fzf --zsh)
fi

# fzf-tab - Tab补全增强
# https://github.com/Aloxaf/fzf-tab
if [[ -d "$PLUGINS_DIR/fzf-tab" ]]; then
  source "$PLUGINS_DIR/fzf-tab/fzf-tab.plugin.zsh"
  
  # 加载fzf-tab配置
  if [[ -f "$ZSH_DOTDIR/configs/fzf-tab.zsh" ]]; then
    source "$ZSH_DOTDIR/configs/fzf-tab.zsh"
  fi
fi

# forgit - git操作增强
# https://github.com/wfxr/forgit
if [[ -d "$PLUGINS_DIR/forgit" ]]; then
  source "$PLUGINS_DIR/forgit/forgit.plugin.zsh"
fi

# zsh-autosuggestions - 命令自动建议
# https://github.com/zsh-users/zsh-autosuggestions
if [[ -d "$PLUGINS_DIR/zsh-autosuggestions" ]]; then
  source "$PLUGINS_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# fast-syntax-highlighting - 语法高亮
# https://github.com/zdharma-continuum/fast-syntax-highlighting
if [[ -d "$PLUGINS_DIR/fast-syntax-highlighting" ]]; then
  source "$PLUGINS_DIR/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
fi

# zsh-history-substring-search - 历史搜索
# https://github.com/zsh-users/zsh-history-substring-search
if [[ -d "$PLUGINS_DIR/zsh-history-substring-search" ]]; then
  source "$PLUGINS_DIR/zsh-history-substring-search/zsh-history-substring-search.zsh"
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
fi

# zsh-you-should-use - 别名提示
# https://github.com/MichaelAquilina/zsh-you-should-use
if [[ -d "$PLUGINS_DIR/zsh-you-should-use" ]]; then
  export YSU_MESSAGE_POSITION="after"
  source "$PLUGINS_DIR/zsh-you-should-use/you-should-use.plugin.zsh"
fi

# zoxide - 智能目录跳转
# https://github.com/ajeetdsouza/zoxide
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init --cmd j zsh)"
fi 