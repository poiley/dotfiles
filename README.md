# Dotfiles

My optimized shell configuration focused on blazing-fast startup times and clean aesthetics.

## Performance

- **Shell startup: ~315ms** (with centered neofetch)
- **Core startup: ~65ms** (without neofetch)
- **Original baseline: ~500ms** (unoptimized Oh My Zsh)

## Features

### Shell (Zsh)
- ⚡ **Antidote** plugin manager (ultra-fast static loading)
- 🎨 **Powerlevel10k** theme with instant prompt
- 📊 **Centered neofetch** on startup
- 🔄 **Lazy-loaded** tools (pyenv, mise, bun)
- 🚀 **Optimized completions** (cached, minimal overhead)

### Optimizations
- Static plugin loading (no runtime overhead)
- Deferred background tasks (Gas Town integration)
- Consolidated PATH management
- Minimal plugin set (git only)
- Smart completion caching

## Installation

### Prerequisites
```bash
# Install dependencies
brew install antidote neofetch

# Optional: install tools for lazy loading
brew install mise pyenv bun
```

### Quick Setup
```bash
# Clone this repo
git clone https://github.com/poiley/dotfiles.git ~/repos/dotfiles

# Backup existing configs
mv ~/.zshrc ~/.zshrc.backup 2>/dev/null || true
mv ~/.p10k.zsh ~/.p10k.zsh.backup 2>/dev/null || true

# Symlink configs
ln -s ~/repos/dotfiles/.zshrc ~/.zshrc
ln -s ~/repos/dotfiles/.zsh_plugins.txt ~/.zsh_plugins.txt
ln -s ~/repos/dotfiles/.p10k.zsh ~/.p10k.zsh

# Set up environment variables (if needed)
# Create ~/.env with any required API keys and tokens
# The .zshrc will source ~/.env automatically

# Restart your shell
exec zsh
```

### First Run
On first startup, antidote will clone the plugins (Powerlevel10k and git plugin). This takes a few seconds but only happens once.

## File Structure

- `.zshrc` - Main zsh configuration
- `.zsh_plugins.txt` - Antidote plugin list
- `.p10k.zsh` - Powerlevel10k theme configuration
- `.gitignore` - Prevents committing secrets

## Customization

### Adding Plugins
Edit `.zsh_plugins.txt` and add plugins in format:
```
author/repo
author/repo path:subpath
```

Then regenerate the static plugin file:
```bash
antidote bundle <~/.zsh_plugins.txt >| ~/.zsh_plugins.zsh
```

### Modifying Prompt
Run Powerlevel10k configuration wizard:
```bash
p10k configure
```

## Security

**⚠️ IMPORTANT:** This repo does NOT contain secrets. All API keys and tokens are stored in `~/.env` which is gitignored.

Never commit:
- `.env` files
- Shell history (`.zsh_history`)
- Cache files (`.zcompdump*`)

## Tech Stack

- **Shell:** Zsh 5.9+
- **Plugin Manager:** Antidote 1.10.2+
- **Theme:** Powerlevel10k
- **Terminal:** Ghostty (or any modern terminal)
- **OS:** macOS (should work on Linux with minor adjustments)

## Performance Tips

1. **Keep plugins minimal** - Each plugin adds overhead
2. **Use lazy loading** - Defer expensive operations
3. **Cache completions** - Use `compinit -C` to skip security checks
4. **Static plugin loading** - Antidote generates a static file for speed
5. **Profile regularly** - Uncomment `zprof` in `.zshrc` to identify bottlenecks

## License

MIT - Feel free to use and modify for your own dotfiles!
