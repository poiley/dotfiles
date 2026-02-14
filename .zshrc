# ============================================================================
# Performance Profiling (uncomment zprof at bottom to see startup breakdown)
# ============================================================================
zmodload zsh/zprof

# ============================================================================
# Powerlevel10k Instant Prompt
# ============================================================================
# Must stay close to the top of ~/.zshrc. Initialization code that may require
# console input must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ============================================================================
# Environment Variables
# ============================================================================
# Load environment variables from ~/.env (safe sourcing method)
if [[ -f ~/.env ]]; then
  set -a
  source ~/.env
  set +a
fi

# Load aliases from ~/.alias
[[ -f ~/.alias ]] && source ~/.alias

# Homebrew configuration
export HOMEBREW_NO_ENV_HINTS=1

# AWS configuration
export AWS_PAGER=""

# Ollama configuration
export OLLAMA_API_BASE=http://localhost:11434

# Bun configuration
export BUN_INSTALL="$HOME/.bun"

# ============================================================================
# Antidote Plugin Manager (ultra-fast static loading)
# ============================================================================
# Initialize completion system (required for git plugin)
autoload -Uz compinit && compinit -C

# Source static plugin file directly (no timestamp check for max speed)
# To update plugins: antidote bundle <~/.zsh_plugins.txt >| ~/.zsh_plugins.zsh
source ~/.zsh_plugins.zsh

clear

# ============================================================================
# PATH Configuration (Consolidated)
# ============================================================================
# Note: PATH is built in reverse priority order (highest priority last)

# Google Cloud SDK
export PATH="$PATH:/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin"

# Go binaries
export PATH="$PATH:$HOME/go/bin"

# Local bin
export PATH="$HOME/.local/bin:$PATH"

# Bun
export PATH="$BUN_INSTALL/bin:$PATH"

# Claude CLI
export PATH="$HOME/.claude/local/node_modules/.bin:$PATH"

# OpenCode
export PATH="$HOME/.opencode/bin:$PATH"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# ============================================================================
# Tool Initialization (Lazy Loading for Performance)
# ============================================================================

# Lazy load pyenv - only initialize when python/pyenv commands are used
pyenv() {
  unset -f pyenv python python3 pip pip3
  export PYENV_ROOT="$HOME/.pyenv"
  [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(command pyenv init -)"
  pyenv "$@"
}

python() {
  unset -f pyenv python python3 pip pip3
  export PYENV_ROOT="$HOME/.pyenv"
  [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(command pyenv init -)"
  python "$@"
}

python3() {
  unset -f pyenv python python3 pip pip3
  export PYENV_ROOT="$HOME/.pyenv"
  [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(command pyenv init -)"
  python3 "$@"
}

pip() {
  unset -f pyenv python python3 pip pip3
  export PYENV_ROOT="$HOME/.pyenv"
  [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(command pyenv init -)"
  pip "$@"
}

pip3() {
  unset -f pyenv python python3 pip pip3
  export PYENV_ROOT="$HOME/.pyenv"
  [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(command pyenv init -)"
  pip3 "$@"
}

# Lazy load mise - only initialize when mise command is used
mise() {
  unset -f mise
  if command -v mise &> /dev/null; then
    eval "$(command mise activate zsh --shims)"
    eval "$(command mise activate zsh)"
  elif [[ -f ~/.local/bin/mise ]]; then
    eval "$(~/.local/bin/mise activate zsh --shims)"
    eval "$(~/.local/bin/mise activate zsh)"
  fi
  mise "$@"
}

# Lazy load bun completions (Oh My Zsh handles compinit, so we skip manual setup)
_load_bun_completions() {
  [[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"
  unset -f _load_bun_completions
}
zle -N _load_bun_completions

clear

echo "\n"
echo "\n"
# Center neofetch output horizontally in the terminal
center_neofetch() {
  local output cols max_w pad spaces
  cols=${COLUMNS:-$(tput cols)}

  # Capture raw neofetch output
  output=$(neofetch 2>/dev/null)

  # Extract text_padding (the \e[NC cursor-right value neofetch uses for info text)
  local text_padding
  text_padding=$(printf '%s' "$output" | sed -n $'s/.*\x1b\\[\\([0-9]*\\)C.*/\\1/p' | head -1)
  text_padding=${text_padding:-33}

  # Measure the longest info line (strip ANSI codes)
  local max_info_w
  max_info_w=$(printf '%s' "$output" | sed $'s/\x1b\\[[0-9;]*[A-Za-z]//g' | sed $'s/\x1b\\[?[0-9]*[a-z]//g' | awk 'NR>17 && length>m{m=length} END{print m+0}')

  # Total rendered width = text_padding + longest info line
  max_w=$(( text_padding + max_info_w ))

  pad=$(( (cols - max_w) / 2 ))
  (( pad < 0 )) && pad=0

  spaces=$(printf '%*s' "$pad" '')

  # Prepend spaces to each line (shifts ASCII art right)
  # Then insert \e[${pad}C after every \e[9999999D (shifts info text right)
  printf '%s\n' "$output" | sed "s/^/${spaces}/" | sed $'s/\x1b\\[9999999D/\x1b[9999999D\x1b['"${pad}"$'C/g'
}
# Run synchronously to avoid terminal conflicts (adds ~150ms to startup but no hang)
center_neofetch

# ============================================================================
# Custom Functions
# ============================================================================

# yt - play youtube videos in kitty via mpv
yt() {
  mpv --profile=sw-fast --vo=kitty --really-quiet "$1"
}

# Optional: Measure shell startup time (uncomment to enable profiling)
# alias zsh-bench='for i in $(seq 1 10); do time zsh -i -c exit; done'

# ============================================================================
# External Integrations
# ============================================================================

# Gas Town Integration (deferred to not block startup)
[[ -f "$HOME/.config/gastown/shell-hook.sh" ]] && (sleep 0.05 && source "$HOME/.config/gastown/shell-hook.sh") &|

# ============================================================================
# Powerlevel10k Configuration (Must be last)
# ============================================================================
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ============================================================================
# Performance Profiling Output (uncomment to see startup time breakdown)
# ============================================================================
# zprof
