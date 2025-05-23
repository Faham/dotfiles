
# Check if zplug is installed
if [[ ! -d ~/.zplug ]]; then
  git clone https://github.com/zplug/zplug ~/.zplug
  source ~/.zplug/init.zsh && zplug update --self
fi

# ZPlug
source "$HOME/.zplug/init.zsh"

zplug "Jxck/dotfiles", as:command, use:"bin/{histuniq,color}"
zplug "plugins/git", from:oh-my-zsh
zplug "plugins/z", from:oh-my-zsh
zplug "plugins/zsh-autosuggestions", from:oh-my-zsh
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "junegunn/fzf", use:"shell/{key-bindings,completion}.zsh"
zplug "~/.zsh", from:local, use:"faham-steeef.zsh-theme"

if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

zplug load

# -----------------------------------------------------------------------------

# Zsh
HISTFILE=~/.histfile
HISTSIZE=20000
SAVEHIST=50000

bindkey -v
# bindkey -s '\eu' '^Ucd ..; ls^M'

setopt AUTO_CD
setopt MULTIOS
setopt CORRECT
setopt AUTO_PUSHD
setopt AUTO_NAME_DIRS
setopt GLOB_COMPLETE
setopt PUSHD_MINUS
setopt PUSHD_SILENT
setopt PUSHD_TO_HOME
setopt NO_BEEP
setopt NUMERIC_GLOB_SORT
setopt EXTENDED_GLOB

# -----------------------------------------------------------------------------

# Oh-My-Zsh!
export ZSH=$HOME/.zplug/repos/robbyrussell/oh-my-zsh

ZSH_CUSTOM="$HOME/.zsh"
ZSH_THEME="faham-steeef"
DISABLE_UPDATE_PROMPT=true
DISABLE_AUTO_UPDATE=true
# DISABLE_UNTRACKED_FILES_DIRTY="true"
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'

source $ZSH/oh-my-zsh.sh

autoload -U zmv

# -----------------------------------------------------------------------------

# FZF
source "$HOME/.zplug/repos/junegunn/fzf/shell/key-bindings.zsh"
source "$HOME/.zplug/repos/junegunn/fzf/shell/completion.zsh"
export FZF_COMPLETION_TRIGGER='**'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export FZF_CTRL_T_OPTS="--preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'"

# -----------------------------------------------------------------------------

# Aliases
alias ssh="TERM=xterm-256color ssh"
alias weather="curl -s wttr.in/kitchener"
alias gdrive="/opt/google/chrome/google-chrome --profile-directory=Default --app-id=apdfllckaahabafndbhieahigkjlhalf"
alias gmail="/opt/google/chrome/google-chrome --profile-directory=Default --app-id=pjkljhegncpnkpknbcohdijeoejaedia"
alias gmaps="/opt/google/chrome/google-chrome --profile-directory=Default --app-id=lneaknkopdijkpnocmklfnjbeapigfbh"
alias vysor="/opt/google/chrome/google-chrome --profile-directory=Default --app-id=gidgenkbbabolejbgbpnhbimgjbffefm"
alias youtube="/opt/google/chrome/google-chrome --profile-directory=Default --app-id=blpcfgokakmgnkcojhhkbfbldkacnbeo"
alias contacts="/opt/google/chrome/google-chrome --profile-directory=Default --app-id=pmcngklofgngifnoceehmchjlildnhkj"
alias calendar="/opt/google/chrome/google-chrome --profile-directory=Default --app-id=kjbdgfilnfhdoflbpgamdcdgpehopbep"
alias google="/opt/google/chrome/google-chrome --profile-directory=Default --app-id=okkolgldfknecfjnhhglfopimelbaceh"

# -----------------------------------------------------------------------------

# Other environment variables
# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/id_rsa"

# go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH

export EDITOR='vim'
export CVS_RSH=ssh

export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
export ANDROID_HOME=$HOME/Android/Sdk
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
export PATH=$JAVA_HOME/bin:$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$PATH
export PATH=$HOME/.local/bin:$PATH

# -----------------------------------------------------------------------------

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
