# Installation Guide

## Prerequisites

- **Required**: zsh, node, git
- **Optional**: jq (for JSON logs), bat (for log viewer), prettier (for formatting)

## Installation Methods

### Method 1: Direct Install (Recommended)

```bash
# Clone the repository
git clone https://github.com/catstackdev/personal-shell-library--prodrun.git ~/.config/prodrun

# Add to PATH
echo 'export PATH="$HOME/.config/prodrun/bin:$PATH"' >> ~/.zshrc

# Source shortcuts (optional)
echo 'source "$HOME/.config/prodrun/lib/shortcuts.zsh"' >> ~/.zshrc

# Reload shell
source ~/.zshrc

# Verify installation
prodrun version
prodrun --help
```

### Method 2: Via GNU Stow (For Dotfiles Management)

If you're using a dotfiles repository with Stow:

```bash
# Clone into your dotfiles
cd ~/dotfiles
git clone https://github.com/catstackdev/personal-shell-library--prodrun.git personal-library

# Use Stow to create symlinks
stow personal-library

# Reload shell
source ~/.zshrc
```

### Method 3: Manual Setup

```bash
# Download and extract
curl -L https://github.com/catstackdev/personal-shell-library--prodrun/archive/main.zip -o prodrun.zip
unzip prodrun.zip
mv personal-shell-library--prodrun-main ~/.config/prodrun

# Add to PATH
echo 'export PATH="$HOME/.config/prodrun/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

## Post-Installation

### 1. Verify Installation

```bash
# Check if prodrun is available
which prodrun

# Should output: /Users/your-username/.config/prodrun/bin/prodrun

# Check version
prodrun version
```

### 2. Test in a Project

```bash
# Navigate to any Node.js project
cd your-project

# Test detection
prodrun detect

# Expected output:
# Project Type: angular (or next, react, etc.)
# Package Manager: pnpm (or npm, yarn, bun)
# Workspace: nx (if applicable)
```

### 3. Enable Shortcuts (Optional)

```bash
# Already added if you followed Method 1
# If not, add manually:
echo 'source "$HOME/.config/prodrun/lib/shortcuts.zsh"' >> ~/.zshrc
source ~/.zshrc

# Test shortcuts
wphelp
```

### 4. Install Optional Dependencies

```bash
# For enhanced features (optional)
brew install jq        # JSON processing
brew install bat       # Better log viewing
brew install prettier  # Code formatting
```

## Configuration

### Global Configuration

Edit `~/.config/prodrun/config.zsh`:

```bash
# Auto-detection
export PRUN_AUTO_DETECT_PM=true
export PRUN_AUTO_DETECT_TYPE=true

# Validation
export PRUN_AUTO_INSTALL=true
export PRUN_VALIDATE_NODE_VERSION=true

# Retry settings
export PRUN_AUTO_RETRY=true
export PRUN_MAX_RETRIES=3
export PRUN_RETRY_DELAY=5

# Logging
export PRUN_LOG_LEVEL=INFO
export PRUN_LOG_DIR=./logs
export PRUN_LOG_RETENTION_DAYS=7
export PRUN_COLOR_OUTPUT=true
```

### Project Configuration

Create `.prunrc` in your project root:

```bash
# Override package manager
PRUN_PACKAGE_MANAGER=pnpm

# Custom commands
PRUN_COMMANDS[dev]="custom:dev"
PRUN_COMMANDS[build]="custom:build"

# Required environment variables
PRUN_REQUIRED_ENV_VARS="API_KEY,DB_URL"
```

## Updating

### Method 1: Git Pull

```bash
cd ~/.config/prodrun
git pull origin main
source ~/.zshrc
```

### Method 2: Reinstall

```bash
rm -rf ~/.config/prodrun
# Then follow installation steps again
```

## Uninstallation

```bash
# Remove files
rm -rf ~/.config/prodrun

# Remove from PATH (edit ~/.zshrc manually or run)
sed -i.bak '/prodrun/d' ~/.zshrc

# Reload shell
source ~/.zshrc
```

## Troubleshooting

### Command not found

**Problem**: `prodrun: command not found`

**Solution**:
```bash
# Check if directory exists
ls ~/.config/prodrun/bin/

# Check PATH
echo $PATH | grep prodrun

# Re-add to PATH
echo 'export PATH="$HOME/.config/prodrun/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### Permission denied

**Problem**: `permission denied: prodrun`

**Solution**:
```bash
# Make executable
chmod +x ~/.config/prodrun/bin/prodrun
chmod +x ~/.config/prodrun/lib/*.zsh
```

### Wrong shell (bash instead of zsh)

**Problem**: Scripts not working properly

**Solution**:
```bash
# Check current shell
echo $SHELL

# Switch to zsh
chsh -s $(which zsh)

# Restart terminal
```

### Package manager not detected

**Problem**: Using wrong package manager

**Solution**:
```bash
# Check lock files in your project
ls -la | grep lock

# If multiple lock files exist, delete the wrong ones
# Keep only one: pnpm-lock.yaml OR package-lock.json OR yarn.lock OR bun.lockb

# Or override in .prunrc
echo 'PRUN_PACKAGE_MANAGER=pnpm' > .prunrc
```

## Platform Compatibility

### macOS (Tested)
- ✅ Works out of the box
- ✅ All features supported

### Linux
- ✅ Should work with minor adjustments
- ⚠️ Some commands may need `sudo` (port operations)

### Windows (WSL)
- ⚠️ Untested, but should work in WSL2
- ❌ Native Windows not supported (use WSL)

## Next Steps

1. Read the [USAGE.md](USAGE.md) guide for common commands
2. Check out [README.md](README.md) for full documentation
3. Try `prodrun --help` for command reference
4. Test in your project: `prodrun dev`

## Support

- 📖 Documentation: [README.md](README.md)
- 🐛 Issues: [GitHub Issues](https://github.com/catstackdev/personal-shell-library--prodrun/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/catstackdev/personal-shell-library--prodrun/discussions)

---

**Happy coding with prodrun!** 🚀
