source /usr/share/zsh/share/antigen.zsh

# Load the oh-my-zsh's library.
antigen use oh-my-zsh

# Bundles from the default repo (robbyrussell's oh-my-zsh).
antigen bundle git
# antigen bundle heroku
# antigen bundle pip
# antigen bundle lein
# antigen bundle command-not-found
antigen bundle zsh-users/zsh-syntax-highlighting

# antigen theme robbyrussell

antigen apply

# -----------------------------------------------------------------------------

# Path to your oh-my-zsh installation.
# export ZSH=$HOME/.oh-my-zsh
export ZSH=$HOME/.antigen/bundles/robbyrussell/oh-my-zsh

ZSH_CUSTOM="$HOME/.my-zsh"
ZSH_THEME="faham-steeef"

DISABLE_UPDATE_PROMPT=true
DISABLE_AUTO_UPDATE=true

# DISABLE_UNTRACKED_FILES_DIRTY="true"

HISTFILE=~/.histfile
HISTSIZE=2000
SAVEHIST=5000
bindkey -v

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='mvim'
fi

plugins=(git zsh-autosuggestions z)

source $ZSH/oh-my-zsh.sh

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

export CVS_RSH=ssh

export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

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

autoload -U zmv

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'

# -----------------------------------------------------------------------------

# FZF setup
source "/usr/share/fzf/key-bindings.zsh"
source "/usr/share/fzf/completion.zsh"
# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_COMPLETION_TRIGGER='**'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export FZF_CTRL_T_OPTS="--preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'"
# bindkey '^T' fzf-completion
# bindkey '^I' $fzf_default_completion

# -----------------------------------------------------------------------------

alias weather="curl -s wttr.in/kitchener"
alias ls=exa

# -----------------------------------------------------------------------------

export ANDROID_HOME=$HOME/Android/Sdk
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk

# -----------------------------------------------------------------------------
