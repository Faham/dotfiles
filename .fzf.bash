# Setup fzf
# ---------
if [[ ! "$PATH" == */home/faham/.fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/home/faham/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/home/faham/.fzf/shell/completion.bash" 2> /dev/null

# Key bindings
# ------------
source "/home/faham/.fzf/shell/key-bindings.bash"
