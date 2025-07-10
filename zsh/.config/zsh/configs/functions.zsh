# 函数配置模块

# ------------------------------
# 实用函数
# ------------------------------

# 创建目录并进入
function mkcd() {
  mkdir -p "$1" && cd "$1"
}

# 解压任何类型的归档文件
function extract() {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1     ;;
      *.tar.gz)    tar xzf $1     ;;
      *.bz2)       bunzip2 $1     ;;
      *.rar)       unrar e $1     ;;
      *.gz)        gunzip $1      ;;
      *.tar)       tar xf $1      ;;
      *.tbz2)      tar xjf $1     ;;
      *.tgz)       tar xzf $1     ;;
      *.zip)       unzip $1       ;;
      *.Z)         uncompress $1  ;;
      *.7z)        7z x $1        ;;
      *)           echo "'$1' 无法提取" ;;
    esac
  else
    echo "'$1' 不是有效的文件"
  fi
}

# 查找并删除.DS_Store文件
function cleanup_ds_store() {
  find . -type f -name "*.DS_Store" -ls -delete
}

# 查看目录中最大的前10个文件/目录
function ducks() {
  du -cks "$@" | sort -rn | head -11
}

# 快速查找文件
function ff() {
  find . -name "*$1*" -type f
}

# 快速查找目录
function fd() {
  find . -name "*$1*" -type d
}

# 显示当前目录的git分支
function git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
} 