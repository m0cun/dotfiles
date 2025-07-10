# 操作系统检测模块
# 根据操作系统类型设置OS_TYPE变量

# 默认为未知系统
export OS_TYPE="unknown"

# 使用uname检测操作系统
if [[ "$(uname)" == "Darwin" ]]; then
  # MacOS系统
  export OS_TYPE="macos"
  
  # 检测是否为Apple Silicon
  if [[ "$(uname -m)" == "arm64" ]]; then
    export OS_ARCH="arm64"
    export IS_APPLE_SILICON=true
  else
    export OS_ARCH="x86_64"
    export IS_APPLE_SILICON=false
  fi
  
  # 设置Homebrew路径（根据架构不同）
  if [[ "$IS_APPLE_SILICON" == true ]]; then
    export HOMEBREW_PREFIX="/opt/homebrew"
  else
    export HOMEBREW_PREFIX="/usr/local"
  fi
elif [[ "$(uname)" == "Linux" ]]; then
  # Linux系统
  export OS_TYPE="linux"
  
  # 检测Linux发行版
  if [[ -f /etc/debian_version ]]; then
    export LINUX_DISTRO="debian"
    if [[ -f /etc/lsb-release ]]; then
      export LINUX_DISTRO="ubuntu"
    fi
    # 检测是否为Kali Linux
    if grep -q "kali" /etc/debian_version || [ -f /etc/kali-release ]; then
      export LINUX_DISTRO="kali"
    fi
  elif [[ -f /etc/redhat-release ]]; then
    export LINUX_DISTRO="redhat"
  elif [[ -f /etc/arch-release ]]; then
    export LINUX_DISTRO="arch"
  fi
fi 