## zsh hooks
autoload -Uz add-zsh-hook

## Enable auto-completion
autoload -Uz compinit

## Load Bash completion scripts
autoload -Uz bashcompinit
bashcompinit

## History configuration
HISTFILE=~/.zsh_history
HISTSIZE=2000
SAVEHIST=$HISTSIZE
HISDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

## Enable case-insensitive completion and ls suggestion color
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors '${(s.:.)LS_COLORS}'

## Enable menu selection for completions
zstyle ':completion:*' menu select

## Enable approximate matches (e.g., fix typos)
zstyle ':completion:*' completer _complete _approximate

## Prompt setup


NEWLINE=$'\n'
BOLD_BEGIN="%B"
BOLD_END="%b"
RESET_COLOR="%f"

USERNAME_FORMAT="%n"
MACHINENAME_FORMAT="%m"
TRUNCATED_PATH="%(3~|../%2~|%3~)"

MACHINE_COLOR="blue"
USER_COLOR="#$ACCENT_COLOR"
FG_COLOR="yellow"

function COLOR_PROMPT() {
    if [[ -n "$1" ]]; then
        echo "%F{$1}"
    else
        echo "%F{white}"
    fi
}

function check_foreground_process() {
    JOBCOUNT=$(jobs -p | wc -l)
    if [[ $JOBCOUNT -gt 0 ]]; then
        echo "$JOBCOUNT"
    else
        echo ""
    fi
}

TOP_FIRST="${BOLD_BEGIN}[$(COLOR_PROMPT $USER_COLOR)${BOLD_END}${USERNAME_FORMAT}${RESET_COLOR}${BOLD_BEGIN}@${BOLD_END}$(COLOR_PROMPT $MACHINE_COLOR)${MACHINENAME_FORMAT}${BOLD_BEGIN}${RESET_COLOR}${BOLD_END}"
TOP_SECOND="${BOLD_BEGIN}:$(COLOR_PROMPT $USER_COLOR)${BOLD_END}${TRUNCATED_PATH}${BOLD_BEGIN}${RESET_COLOR}]${BOLD_END}"
BOTTOM_PROMPT="$ "

function set_prompt() {
    local foreground_status=$(check_foreground_process)
    if [[ -n "$foreground_status" ]]; then
        TOP_THIRD=" » $(COLOR_PROMPT yellow)${foreground_status}${RESET_COLOR}"
    else
        TOP_THIRD=""
    fi

    TOP_PROMPT="${TOP_FIRST}${TOP_SECOND}${TOP_THIRD}"
    PROMPT="${TOP_PROMPT}${NEWLINE}${BOTTOM_PROMPT}"
}

add-zsh-hook precmd set_prompt

## yazi stuff
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

## plugin stuff
source ~/.local/share/zsh-plugin/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.local/share/zsh-plugin/zsh-history-substring-search/zsh-history-substring-search.zsh
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND=""

## Ctrl+r backward search
bindkey '^R' history-incremental-search-backward
bindkey '^[[H' beginning-of-line # Home key
bindkey '^[[F' end-of-line       # End key
bindkey '^[[3~' delete-char      # Delete key
bindkey '^[[Z' undo              # Shift+Tab

## Enable word movement with Ctrl + Left/Right Arrow
bindkey "^[[1;5C" forward-word   # Ctrl + Right Arrow
bindkey "^[[1;5D" backward-word  # Ctrl + Left Arrow

## Alternate codes for some terminal emulators
bindkey "^[[5C" forward-word
bindkey "^[[5D" backward-word

## substring search
bindkey '^[[A' history-substring-search-up   # Up arrow to search backward
bindkey '^[[B' history-substring-search-down # Down arrow to search forward

## vim keybind
bindkey -v

## Zoxide
eval "$(zoxide init zsh)"

## fzf
eval "$(fzf --zsh)"

## Alias setup
alias ls="eza -l --all --icons --header --git --group-directories-first"
alias lsd="eza -l --all --icons --header --git --group-directories-first --sort=date"
# TODO
# alias yt-dl="python3 '$HOME/git/goad-yt-dlp-helper/src/yt-dlp-helper-v2-5.py'"
alias weather="curl wttr.in"
alias calendar="cal -3"
alias v="nvim"
alias sv="sudoedit"
alias touhou-playlist="mpv 'https://www.youtube.com/playlist?list=PLXZnhQ4xFkPXkPd0aiW3V12UMBFD38tXg' --no-video"
alias :wq="exit"
alias neofetch="fastfetch"
alias reload-waybar="pkill waybar && hyprctl dispatch -- exec waybar -s ~/.config/hypr/waybar/style.css -c ~/.config/hypr/waybar/config.jsonc"
alias m-build="meson build && cp ./build/compile_commands.json ./"
alias tarx="tar -xvzf"
alias grep="grep --color=always"
alias tm="tmux a || tmux"
alias rm="rm -I"
alias rsync="rsync -ah --info=progress2"
alias reloadmime="update-desktop-database ~/.local/share/applications/"
alias pyvenv="python -m venv ./ --system-site-packages"

# auto launch hippiland on login
if [ "$(tty)" = "/dev/tty1" ] && [ -z "$XDG_CURRENT_DESKTOP" ]; then
    Hyprland
fi
