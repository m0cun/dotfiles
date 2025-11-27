# macOS 特定的环境变量

# 010 Editor
if [[ -d "/Applications/010 Editor.app" ]]; then
  export PATH=$PATH:/Applications/010\ Editor.app/Contents/CmdLine
fi

# Sublime Text
if [[ -d "/Applications/Sublime Text.app" ]]; then
  export PATH=$PATH:/Applications/Sublime\ Text.app/Contents/SharedSupport/bin
fi

# Windsurf
if [[ -d "/Applications/Windsurf.app" ]]; then
  export PATH=$PATH:$HOME/.codeium/windsurf/bin
fi

# Antigravity
if [[ -d "/Applications/Antigravity.app" ]]; then 
  export PATH=$PATH:$HOME/.antigravity/antigravity/bin
fi

# Calibre
if [[ -d "/Applications/calibre.app" ]]; then
  export PATH=$PATH:/Applications/calibre.app/Contents/MacOS
fi

# curl
if [[ -d "/usr/local/opt/curl/bin" ]]; then
  export PATH=$PATH:/usr/local/opt/curl/bin
fi

# Metasploit
if [[ -d "/opt/metasploit-framework/bin" ]]; then
  export PATH=$PATH:/opt/metasploit-framework/bin
fi 