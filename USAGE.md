# prodrun - Usage Guide

Quick reference for common prodrun commands and workflows.

## Installation

```bash
# Via GNU Stow (recommended if using dotfiles)
cd ~/dotfiles
stow personal-library

# Manual installation
git clone https://github.com/catstackdev/personal-shell-library--prodrun.git ~/.config/prodrun
echo 'export PATH="$HOME/.config/prodrun/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

## Quick Start

```bash
# Navigate to any web project
cd your-project

# Start development server (auto-detects framework)
prodrun dev

# Check project info
prodrun info

# View running status
prodrun status
```

## Common Commands

### Development

```bash
prodrun dev           # Start dev server
prodrun build         # Build project
prodrun test          # Run tests
prodrun lint          # Lint code
prodrun start         # Start production server
```

### Project Management

```bash
prodrun info          # Show project info (type, PM, workspace)
prodrun detect        # Show detection results
prodrun health        # Run health check
prodrun status        # Show process status
```

### Port Management

```bash
prodrun port:check 3000       # Check if port is in use
prodrun port:kill 3000        # Kill process on port
prodrun port:info 3000        # Show process details
```

### Dependencies

```bash
prodrun deps:outdated         # Check for outdated packages
prodrun deps:update           # Update dependencies
prodrun deps:audit            # Security audit
```

### Cleanup

```bash
prodrun clean                 # Remove build artifacts
prodrun fresh                 # Clean + reinstall dependencies
```

## Framework-Specific

### Angular

```bash
# Auto-detected commands (use ng CLI)
prodrun dev                   # → ng serve
prodrun build                 # → ng build
prodrun test                  # → ng test
prodrun lint                  # → ng lint

# Direct Angular commands
prodrun ng:serve my-app 4300  # Serve specific app
prodrun ng:build my-app       # Build specific app
prodrun ng:test my-app        # Test specific app
prodrun ng:apps               # List all apps
prodrun ng:generate component my-component
```

### Next.js / React

```bash
prodrun dev                   # Auto-uses package manager
prodrun build
prodrun start
```

## Failure-Aware Execution

```bash
# Run with automatic retry
prodrun run npm test --retry=5

# Validate before running
prodrun validate npm run build

# Manual retry with backoff
prodrun retry "npm install" 3
```

## Logging

```bash
# View logs
prodrun logs                  # Last 50 lines
prodrun logs error            # Error logs only
prodrun logs all 100          # All logs, 100 lines

# Real-time monitoring
prodrun monitor               # Monitor with color coding
prodrun log:follow            # Follow logs
prodrun log:follow "error"    # Follow with filter

# Advanced
prodrun log:stats             # Log statistics
prodrun log:viewer            # Interactive viewer
prodrun log:filter level ERROR
```

## Performance Tracking

```bash
# Track build time
prodrun perf:start build
npm run build
prodrun perf:end build        # Shows duration

# View metrics
prodrun metrics
```

## Docker Integration

```bash
prodrun docker:status         # Check Docker daemon
prodrun docker:up             # Start containers
prodrun docker:down           # Stop containers
prodrun docker:logs           # View logs
```

## Environment Management

```bash
prodrun env:check             # Check for .env files
prodrun env:copy              # Copy .env.example to .env
```

## Git Utilities

```bash
prodrun git:status            # Enhanced git status
```

## Daemon Mode

```bash
# Run as background daemon
prodrun daemon start          # Start daemon
prodrun daemon stop           # Stop daemon
prodrun daemon restart        # Restart daemon

# Check daemon status
prodrun status
```

## Shortcuts

Add to `~/.zshrc`:
```bash
source ~/.config/prodrun/lib/shortcuts.zsh
```

Then use:
```bash
wpdev          # prodrun dev
wpbuild        # prodrun build
wptest         # prodrun test
wplogs         # prodrun logs
wpinfo         # prodrun info
wpstatus       # prodrun status
wprun          # prodrun run (failure-aware)
wphelp         # Show all shortcuts
```

## Configuration

### Global Config: `~/.config/prodrun/config.zsh`

```bash
# Auto-detection
PRUN_AUTO_DETECT_PM=true
PRUN_AUTO_DETECT_TYPE=true

# Validation
PRUN_AUTO_INSTALL=true
PRUN_VALIDATE_NODE_VERSION=true

# Retry behavior
PRUN_AUTO_RETRY=true
PRUN_MAX_RETRIES=3
PRUN_RETRY_DELAY=5

# Logging
PRUN_LOG_LEVEL=INFO          # DEBUG|INFO|WARN|ERROR
PRUN_LOG_DIR=./logs
PRUN_LOG_RETENTION_DAYS=7
PRUN_COLOR_OUTPUT=true
```

### Project Config: `.prunrc`

Create in your project root:
```bash
# Override package manager
PRUN_PACKAGE_MANAGER=pnpm

# Custom commands
PRUN_COMMANDS[dev]="custom:dev"
PRUN_COMMANDS[build]="custom:build"

# Required environment variables
PRUN_REQUIRED_ENV_VARS="API_KEY,DB_URL"
```

## Real-World Workflows

### Starting a New Project
```bash
cd my-new-project
prodrun health              # Check environment
prodrun env:check           # Verify .env files
prodrun deps:audit          # Security check
prodrun dev                 # Start development
```

### Debugging Port Issues
```bash
prodrun dev                 # Fails: port in use

# Check what's using the port
prodrun port:info 4200

# Kill the process
prodrun port:kill 4200

# Retry
prodrun dev
```

### Build & Deploy Check
```bash
# Validate environment
prodrun health

# Run tests with retry
prodrun run npm test --retry=3

# Build with validation
prodrun validate npm run build
prodrun build

# Check logs for issues
prodrun log:filter level ERROR
```

### Monitoring Long-Running Process
```bash
# Terminal 1: Start dev server
prodrun dev

# Terminal 2: Monitor in real-time
prodrun monitor

# Terminal 3: Check status and performance
prodrun status
prodrun metrics
```

## Tips & Tricks

### 1. Quick Status Check
```bash
alias s='prodrun status'
```

### 2. Auto-Fix Dependencies
```bash
# If build fails with missing dependencies
prodrun run npm run build --retry=3
# Will auto-install dependencies and retry
```

### 3. Multi-Framework Support
Same commands work across all frameworks:
```bash
# Works in Angular, Next.js, React, Vue, etc.
prodrun dev
prodrun build
prodrun test
```

### 4. Debug Mode
```bash
prodrun -v dev              # Verbose output
prodrun --verbose build     # See all detection steps
```

### 5. Quiet Mode
```bash
prodrun -q build            # Only show errors
```

## Troubleshooting

### Command not found
```bash
# Check PATH
echo $PATH | grep prodrun

# Reload shell
source ~/.zshrc

# Verify installation
which prodrun
```

### Wrong package manager detected
```bash
# Check lock files
ls -la | grep lock

# Override in .prunrc
echo 'PRUN_PACKAGE_MANAGER=pnpm' > .prunrc
```

### Status shows "Not running" but server is up
```bash
# Check if it's on a different port
prodrun port:check 3000
prodrun port:check 4200
prodrun port:check 5173

# Check all node processes
ps aux | grep node
```

### Logs not showing
```bash
# Check log directory
echo $PRUN_LOG_DIR
ls -la ./logs/

# Enable debug logging
prodrun -v dev
```

## Getting Help

```bash
prodrun --help              # Full help
prodrun <command> --help    # Command-specific help
wphelp                      # Shortcuts help
```

---

For full documentation, see [README.md](README.md)
