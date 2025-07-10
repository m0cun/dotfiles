# Linux特定配置

# ------------------------------
# Linux特定别名和函数
# ------------------------------

# 包管理器相关
if command -v apt &>/dev/null; then
  # Debian/Ubuntu
  alias update='sudo apt update && sudo apt upgrade'
  alias install='sudo apt install'
  alias remove='sudo apt remove'
  alias search='apt search'
elif command -v dnf &>/dev/null; then
  # Fedora
  alias update='sudo dnf update'
  alias install='sudo dnf install'
  alias remove='sudo dnf remove'
  alias search='dnf search'
elif command -v pacman &>/dev/null; then
  # Arch
  alias update='sudo pacman -Syu'
  alias install='sudo pacman -S'
  alias remove='sudo pacman -R'
  alias search='pacman -Ss'
fi

# 系统信息
alias sysinfo='uname -a; cat /etc/*-release'
alias cpuinfo='cat /proc/cpuinfo | grep "model name" | head -1'
alias meminfo='free -h'
alias diskinfo='df -h'

# 服务管理
alias service_status='sudo systemctl status'
alias service_start='sudo systemctl start'
alias service_stop='sudo systemctl stop'
alias service_restart='sudo systemctl restart'
alias service_enable='sudo systemctl enable'
alias service_disable='sudo systemctl disable'

# 网络管理
alias netstat_listen='netstat -tulpn | grep LISTEN'
alias ip_addr='ip addr show'

# 显示当前用户的所有进程
alias myps='ps -U $USER'

# 清理系统
function clean_system_linux() {
  echo "清理APT缓存..."
  if command -v apt &>/dev/null; then
    sudo apt clean
    sudo apt autoremove -y
  fi
  
  echo "清理日志..."
  sudo journalctl --vacuum-time=7d
  
  echo "清理临时文件..."
  sudo rm -rf /tmp/*
  
  echo "清理用户缓存..."
  rm -rf ~/.cache/*
  
  echo "清理完成！"
}

# Linux特定环境变量
export LS_COLORS="rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32" 