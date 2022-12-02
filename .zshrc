
export TERM='xterm-256color'

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
zplug "junegunn/fzf-bin", from:gh-r, as:command, rename-to:fzf
zplug "junegunn/fzf", use:"shell/{key-bindings,completion}.zsh"
zplug "peco/peco", as:command, from:gh-r
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
alias ls=exa
alias la="exa -la"
alias youtube="chromium --app=https://youtube.com/"
alias meet-mohammad="chromium --app='https://meet.google.com/yog-euts-hmg?authuser=1'"
alias meet-faham="chromium --app='https://meet.google.com/xib-tsfm-wkz?authuser=1'"

# -----------------------------------------------------------------------------

# Other environment variables
# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/id_rsa"

# go
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

export EDITOR='vim'
export CVS_RSH=ssh

export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
export ANDROID_HOME=$HOME/Android/Sdk
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# -----------------------------------------------------------------------------

stty -ixon

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# -----------------------------------------------------------------------------

bindkey  "^[[1~"   beginning-of-line
bindkey  "^[[4~"   end-of-line
# bindkey -s '\eu' '^Ucd ..; ls^M'
# bindkey -v
