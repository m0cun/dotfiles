# 历史记录配置模块

# 历史记录文件
HISTFILE="$HOME/.zsh_history"
export HISTSIZE=10000
export SAVEHIST=10000

# 历史记录选项
setopt EXTENDED_HISTORY        # 保存每个命令的开始时间戳
setopt SHARE_HISTORY           # 共享历史记录
setopt HIST_EXPIRE_DUPS_FIRST  # 删除重复记录优先
setopt HIST_IGNORE_DUPS        # 不记录重复的命令
setopt HIST_IGNORE_SPACE       # 忽略以空格开头的命令
setopt HIST_VERIFY             # 使用历史记录条目时，首先展开它们而不是立即执行
setopt HIST_SAVE_NO_DUPS       # 不保存重复的历史记录
setopt INCAPPENDHISTORY        # 追加方式添加到历史记录 