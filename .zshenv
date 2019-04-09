sys_name=$(uname -s)
if [[ $sys_name = "Darwin" ]]; then
  source $HOME/.zshrc.mac
else
  source $HOME/.zshrc.linux
fi

# --------------------- PATH ---------------------

export PATH="/usr/local/bin:$PATH:$HOME/local/bin"
# Path for go
export PATH="$PATH:$HOME/go/bin"

# Android Studio
export ANDROID_HOME=$HOME/AppData/Android/sdk
export PATH=$PATH:$ANDROID_HOME/tools
# _____________________ PATH _____________________

# --------------------- Proxy ---------------------

# export HTTP_PROXY="http://localhost:8118"
# export HTTPS_PROXY=$HTTP_PROXY
# export FTP_PROXY=$HTTP_PROXY
# export NO_PROXY="locahost,127.0.0.1,.lan,.loc"
# export ALL_PROXY=$HTTP_PROXY

# _____________________ Proxy _____________________
