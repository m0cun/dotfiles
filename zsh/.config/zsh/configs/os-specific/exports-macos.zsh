# macOS 特定的环境变量

# 010 Editor
if [[ -d "/Applications/010 Editor.app" ]]; then
  export PATH=$PATH:/Applications/010\ Editor.app/Contents/CmdLine
fi

# Sublime Text
if [[ -d "/Applications/Sublime Text.app" ]]; then
  export PATH=$PATH:/Applications/Sublime\ Text.app/Contents/SharedSupport/bin
fi

# Calibre
if [[ -d "/Applications/calibre.app" ]]; then
  export PATH=$PATH:/Applications/calibre.app/Contents/MacOS
fi

# Metasploit
if [[ -d "/opt/metasploit-framework/bin" ]]; then
  export PATH=$PATH:/opt/metasploit-framework/bin
fi 