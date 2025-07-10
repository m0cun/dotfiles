# 环境变量配置模块

# ------------------------------
# 基本环境变量
# ------------------------------
# 默认编辑器
export EDITOR="nvim"

# 设置PATH
if [[ -n "$HOMEBREW_PREFIX" ]]; then
  # Use Homebrew prefix if available (set in os-detection.zsh for macOS)
  export PATH="$HOMEBREW_PREFIX/bin:$PATH"
  export PATH="$HOMEBREW_PREFIX/sbin:$PATH"
else
  # Fallback for other systems or if Homebrew is not managed this way
  export PATH="/usr/local/bin:$PATH"
  export PATH="/usr/local/sbin:$PATH"
fi

# ------------------------------
# 编程语言环境
# ------------------------------
# Go环境
if command -v go &>/dev/null; then
  export GOPATH="$HOME/.go"
  export GOBIN="$GOPATH/bin"
  export PATH="$PATH:$GOBIN"
fi

# Rust环境
if [[ -f "$HOME/.cargo/env" ]]; then
  source "$HOME/.cargo/env"
fi

# Node.js环境 - fnm
if command -v fnm &>/dev/null; then
  eval "$(fnm env --use-on-cd --shell zsh)"
fi

# Java环境 - jenv
if command -v jenv &>/dev/null; then
  export PATH="$HOME/.jenv/bin:$PATH"

  # export plugin extremely slows down shell response
  # temporary solution: just initialize jenv if in a folder that contains java files(I'm using zsh):
  # https://github.com/jenv/jenv/issues/178
  # 懒加载jenv以提高性能

  # 只在进入包含Java文件的目录时初始化jenv
  function evaluate_jenv() {
    if [ ! -v JENV_LOADED ]; then
      setopt local_options nullglob
      if [ ! -f pom.xml ] && [ ! -f build.gradle.kts ] && [ ! -f build.sbt ] && [ ! -f build.xml ] && [ ! -f .java-version ] && [ ! -f .deps.edn ] && [ ! -f project.clj ] && [ ! -f build.boot ]; then
        extensions=(*.java, *.class, *.gradle, *.jar, *.cljs, *.cljc)
        if [ -z "$extensions" ]; then
          return
        fi
      fi
      echo "Initializing jenv..."
      eval "$(jenv init -)"
    fi
  }

  typeset -a precmd_functions
  precmd_functions+=(evaluate_jenv)
fi

# ------------------------------
# 数据库环境
# ------------------------------
# mysql multi versions
# mysql@5.7 brew install
#alias mysql5start='brew services start mysql@5.7'
#alias mysql5stop='brew services stop mysql@5.7'

# mysql@5.7 is keg-only, which means it was not symlinked into /usr/local,
# because this is an alternate version of another formula.
#
# If you need to have mysql@5.7 first in your PATH, run:
#   echo 'export PATH="/usr/local/opt/mysql@5.7/bin:$PATH"' >> ~/.zshrc
#
# For compilers to find mysql@5.7 you may need to set:
#   export LDFLAGS="-L/usr/local/opt/mysql@5.7/lib"
#   export CPPFLAGS="-I/usr/local/opt/mysql@5.7/include"
#
# For pkg-config to find mysql@5.7 you may need to set:
#   export PKG_CONFIG_PATH="/usr/local/opt/mysql@5.7/lib/pkgconfig"
#
# To restart mysql@5.7 after an upgrade:
#   brew services restart mysql@5.7
# Or, if you don't want/need a background service you can just run:
#   /usr/local/opt/mysql@5.7/bin/mysqld_safe --datadir=/usr/local/var/mysql

# mysql@8.0 brew install
#alias mysql8start='brew services start mysql'
#alias mysql8stop='brew services stop mysql'
#mysql@8.0 is keg-only, which means it was not symlinked into /usr/local,
#because this is an alternate version of another formula.
#
#If you need to have mysql@8.0 first in your PATH, run:
#  echo 'export PATH="/usr/local/opt/mysql@8.0/bin:$PATH"' >> ~/.zshrc
#
#For compilers to find mysql@8.0 you may need to set:
#  export LDFLAGS="-L/usr/local/opt/mysql@8.0/lib"
#  export CPPFLAGS="-I/usr/local/opt/mysql@8.0/include"
#
#For pkg-config to find mysql@8.0 you may need to set:
#  export PKG_CONFIG_PATH="/usr/local/opt/mysql@8.0/lib/pkgconfig"
#
#To start mysql@8.0 now and restart at login:
#  brew services start mysql@8.0
#Or, if you don't want/need a background service you can just run:
#  /usr/local/opt/mysql@8.0/bin/mysqld_safe --datadir\=/usr/local/var/mysql
