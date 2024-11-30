# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Workspace Configuration - Edit these paths to change your workspace
export WORKSPACE="/media/ayon1901/SERVER"              # Main workspace
export DEV_DIR="$WORKSPACE/Development"                # Development directory
export PROJECTS_DIR="$WORKSPACE/Projects"              # Projects directory
export DOCS_DIR="$WORKSPACE/Documents"                           # Documents directory
export NOTES_DIR="$DOCS_DIR/notes"                    # Notes directory
export ARCHIVE_DIR="$WORKSPACE/Archive"                # Archive directory

# Check if workspace is mounted/accessible
check_workspace() {
    if [ ! -d "$WORKSPACE" ]; then
        echo "⚠️  WARNING: Workspace ($WORKSPACE) is not accessible!"
        return 1
    fi
    return 0
}

# Oh-My-Zsh Path
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Source Oh-My-Zsh
source $ZSH/oh-my-zsh.sh

# History Configuration
HIST_STAMPS="yyyy-mm-dd"
HISTSIZE=1000000
SAVEHIST=1000000
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt share_history

# Modern CLI tools
export PATH=$HOME/.local/bin:/usr/local/bin:$HOME/bin:$PATH

# Set nvim as default editor
export EDITOR='nvim'
export VISUAL='nvim'

# Directory shortcuts - Using configured paths
hash -d ws="$WORKSPACE"
hash -d dev="$DEV_DIR"
hash -d docs="$DOCS_DIR"
hash -d proj="$PROJECTS_DIR"

# Modern CLI tool aliases
alias cat='batcat --style=numbers,changes'
alias ll='ls -lah'     # Detailed list
alias la='ls -A'       # List all except . and ..
alias l='ls -CF'       # Column list
alias grep='rg'
alias top='btop'
alias du='dust'
alias df='duf'

# System monitoring aliases
alias sys='btop'
alias disk='duf'
alias space='dust -r'
alias ports='netstat -tulanp'
alias mem='ps auxf | sort -nr -k 4 | head -10'  # Memory hogs (top 10)
alias cpu='ps auxf | sort -nr -k 3 | head -10'  # CPU hogs (top 10)
alias myip='curl -s https://ipinfo.io/json | jq'

# Git aliases and functions
alias gs='git status'
alias gp='git pull'
alias gd='git diff'
alias gc='git commit'
alias gb='git branch'
alias gco='git checkout'
alias gl='git log --oneline --graph --decorate'

# Docker aliases
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dcp='docker-compose'
alias dcup='docker-compose up -d'
alias dcdown='docker-compose down'
alias dclogs='docker-compose logs -f'

# Directory Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ws='cd $WORKSPACE'
alias dev='cd $DEV_DIR'
alias proj='cd $PROJECTS_DIR'
alias docs='cd $DOCS_DIR'

# Install zinit if not present
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} Installing zinit...%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} Installation successful.%f" || \
        print -P "%F{160} Installation failed.%f"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"

# Initialize completion system
autoload -Uz compinit
compinit

# Load Powerlevel10k
zinit ice depth=1
zinit light romkatv/powerlevel10k

# Load history-substring-search first
zinit ice wait'0' lucid
zinit light zsh-users/zsh-history-substring-search

# Load other plugins
zinit wait lucid for \
    atinit"zicompinit; zicdreplay" \
        zdharma-continuum/fast-syntax-highlighting \
    atload"_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions \
        zsh-users/zsh-completions

# History substring search keybindings (after loading the plugin)
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# Word movement bindings
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# Enhanced FZF functions
fzf_preview_cmd="batcat --color=always --style=numbers {}"

# Smart file search
fvs() {
    if ! check_workspace; then return 1; fi
    local file
    file=$(find "$WORKSPACE" -type f \
        -not -path "*/\.*" \
        -not -path "*/node_modules/*" \
        -not -path "*/venv/*" \
        -not -path "*/build/*" \
        2>/dev/null | \
        fzf --height 40% \
        --reverse \
        --preview "$fzf_preview_cmd" \
        --preview-window=right:60%)
    [ -n "$file" ] && nvim "$file"
}

# Full search in workspace
fvh() {
    if ! check_workspace; then return 1; fi
    local file
    file=$(find "$WORKSPACE" -type f 2>/dev/null | \
        fzf --height 40% \
        --reverse \
        --preview "$fzf_preview_cmd" \
        --preview-window=right:60%)
    [ -n "$file" ] && nvim "$file"
}

# Directory jump with fzf
fcd() {
    if ! check_workspace; then return 1; fi
    local dir
    dir=$(find "$WORKSPACE" -type d \
        -not -path "*/\.*" \
        -not -path "*/node_modules/*" \
        -not -path "*/venv/*" \
        -not -path "*/build/*" \
        2>/dev/null | \
        fzf --height 40% \
        --reverse \
        --preview 'ls -la {}')
    [ -n "$dir" ] && cd "$dir"
}

# Quick cd into any directory under workspace
fz() {
    if ! check_workspace; then return 1; fi
    local dir
    dir=$(fdfind --type d --hidden --exclude .git --exclude node_modules \
        --search-path "$WORKSPACE" \
        | fzf --preview 'tree -L 1 {}' --bind 'ctrl-/:change-preview-window(down|hidden|)' )
    [ -n "$dir" ] && cd "$dir"
}

# Quick project switching
project() {
    if ! check_workspace; then return 1; fi
    local selected_dir=$(find "$PROJECTS_DIR" -mindepth 1 -maxdepth 1 -type d | fzf)
    if [ -n "$selected_dir" ]; then
        cd "$selected_dir"
        if [ -d .git ]; then
            git status
        fi
    fi
}
alias p='project'

# Git enhanced functions
gclean() {
    # Remove merged branches except main/master/develop
    git branch --merged | grep -v "\*" | grep -v "main" | grep -v "master" | grep -v "develop" | xargs -n 1 git branch -d
}

# Advanced git commit browser
gbrowse() {
    git log --graph --color=always \
        --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" |
    fzf --ansi --no-sort --reverse --tiebreak=index \
        --preview "echo {} | grep -o '[a-f0-9]\{7\}' | head -1 |
                  xargs -I % sh -c 'git show --color=always %'" \
        --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
FZF-EOF"
}
alias gb='gbrowse'

# System cleanup function
cleanup() {
    echo "Cleaning up system..."
    
    # Clean package cache
    if command -v apt > /dev/null; then
        sudo apt autoremove -y
        sudo apt clean
    fi
    
    # Clean home directory
    rm -rf ~/.cache/thumbnails/*
    rm -rf ~/.local/share/Trash/*
    
    # Docker cleanup
    if command -v docker > /dev/null; then
        docker system prune -f
    fi
    
    echo "Cleanup complete!"
}

# Development helpers
new-project() {
    if ! check_workspace; then return 1; fi
    if [ "$#" -ne 1 ]; then
        echo "Usage: new-project project-name"
        return 1
    fi
    
    local proj_dir="$PROJECTS_DIR/$1"
    mkdir -p "$proj_dir"
    cd "$proj_dir"
    
    # Initialize git
    git init
    
    # Create common files
    echo "# $1" > README.md
    echo "node_modules/" > .gitignore
    echo ".env" >> .gitignore
    echo ".DS_Store" >> .gitignore
    
    # Create basic directory structure
    mkdir -p src docs tests
    
    echo "Project $1 created in $proj_dir!"
}

# Python virtual environment handler
venv() {
    if [ ! -d "venv" ]; then
        python3 -m venv venv
    fi
    source venv/bin/activate
}

# Quick notes function
note() {
    if ! check_workspace; then return 1; fi
    if [ ! -d "$NOTES_DIR" ]; then
        mkdir -p "$NOTES_DIR"
    fi
    
    local date=$(date +%Y-%m-%d)
    local note_file="$NOTES_DIR/$date.md"
    
    if [ "$#" -eq 0 ]; then
        # Open notes file in editor
        $EDITOR "$note_file"
    else
        # Append note with timestamp
        echo "$(date +%H:%M) - $*" >> "$note_file"
        echo "Note added!"
    fi
}

# Quick timer function
timer() {
    local time=$1
    shift
    local message="$*"
    
    if [[ $time =~ ^[0-9]+$ ]]; then
        echo "Timer set for $time minutes..."
        sleep $(($time * 60))
        notify-send "Timer finished!" "$message"
        echo -e "\a" # Terminal bell
    else
        echo "Usage: timer <minutes> [message]"
    fi
}

# Search in command history
fh() {
    local cmd
    cmd=$(history | fzf --tac | sed 's/ *[0-9]* *//')
    eval "$cmd"
}

# NVM setup
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" --no-use  # Lazy load nvm for faster startup
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Source p10k theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh