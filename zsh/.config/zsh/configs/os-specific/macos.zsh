# macOS特定配置

# ------------------------------
# macOS特定别名和函数
# ------------------------------

# 打开文件/应用程序
alias o="open"
alias oo="open ."

# 显示/隐藏隐藏文件
alias show_hidden="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hide_hidden="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"

# 显示/隐藏桌面图标
alias hide_desktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
alias show_desktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"

# 清空DNS缓存
alias flush_dns="sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"

# 检查电池健康状态
function battery_health() {
  system_profiler SPPowerDataType | grep -A 15 "Battery Information"
}

# macOS更新Homebrew
alias brew_update="brew update && brew upgrade && brew cleanup"

# 快速访问常用目录
alias desktop="cd ~/Desktop"
alias documents="cd ~/Documents"
alias downloads="cd ~/Downloads"

# 代理设置
# Surge
if [[ -f "/Applications/Surge.app/Contents/MacOS/StartQurge" ]]; then
  alias surge='sudo /Applications/Surge.app/Contents/MacOS/StartQurge'
fi
alias proxy='export https_proxy=http://127.0.0.1:6152;export http_proxy=http://127.0.0.1:6152;export all_proxy=socks5://127.0.0.1:6153'
alias noproxy="unset all_proxy; unset https_proxy; unset http_proxy"

# macOS特定环境变量
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad 