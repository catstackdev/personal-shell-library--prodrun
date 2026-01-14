# prodrun

> A production-ready CLI runner that auto-detects web frameworks and provides real-world utilities such as smart logging, environment validation, and failure-aware execution.

## Purpose

**prodrun** eliminates the guesswork in running web development tasks by:
- 🎯 **Auto-detecting** your framework (Angular, React, Next.js, etc.)
- 📦 **Auto-detecting** your package manager (pnpm, npm, yarn, bun)
- 📊 **Smart logging** with filtering, statistics, and performance tracking
- ✅ **Environment validation** before running commands
- 🔄 **Failure-aware execution** with automatic retries and helpful errors
- 🛠️ **Real-world utilities** for daily development

## Quick Start

```bash
# Install via Stow
cd ~/dotfiles
stow personal-library

# Reload shell
source ~/.zshrc

# Run commands (auto-detects Angular and uses ng serve!)
prodrun dev              # Auto-detects: Angular→ng serve, Next→next dev, etc.
prodrun info             # Show project detection results
prodrun status           # Check if dev server is running
prodrun health           # Validate environment
```

## Core Features

### 1. Auto-Detection ✨

Detects your project automatically:

```bash
$ prodrun detect

Project Type: angular
Package Manager: pnpm (from pnpm-lock.yaml)
Workspace: nx
Node Version: 18.x (required)
```

**Supported:**
- **Frameworks:** Angular, React, Next.js, Nest, Nuxt, Vue, Vite, Astro, SvelteKit, Remix, Gatsby
- **Package Managers:** pnpm, npm, yarn, bun (from lock files)
- **Workspaces:** Nx, Turborepo, Lerna, pnpm workspace, Yarn workspace

### 2. Smart Logging 📊

Real-time colored logs with powerful filtering:

```bash
# View logs
prodrun logs                    # Last 50 lines
prodrun log:filter level ERROR  # Errors only
prodrun log:follow "timeout"    # Follow with filter

# Statistics
prodrun log:stats              # Error rates, file size, time range

# Performance tracking
prodrun perf:start build
npm run build
prodrun perf:end build         # ⏱ build completed in 45.2s
```

**Features:**
- Color-coded output (red errors, yellow warnings)
- Automatic error detection
- JSON structured logs for analysis
- Performance timing built-in
- Automatic rotation and cleanup

### 3. Environment Validation ✅

Pre-flight checks before running:

```bash
$ prodrun health

✓ Node.js: 18.19.0 (matches requirement: 18.x)
✓ Package Manager: pnpm installed
✓ Dependencies: node_modules present
✗ Environment: .env missing
  💡 Run: prodrun env:copy
✓ Ports: 4200 available
```

**Validates:**
- Node version requirements (`.nvmrc`, `package.json` engines)
- Package manager availability
- Dependencies installed
- Environment files
- Port availability
- Git status

### 4. Failure-Aware Execution 🔄

Handles failures intelligently:

```bash
$ prodrun build --retry=3

❌ Build failed: Module not found

💡 Common fixes:
  1. Clean install: prodrun fresh
  2. Clear cache: prodrun clean

🔄 Retry 1/3 in 5 seconds...
✓ Build successful on retry 2
```

**Smart Error Handling:**
- Detects common errors (EADDRINUSE, ENOENT, timeout)
- Provides contextual suggestions
- Automatic retry with backoff
- Tracks failure patterns

### 5. Project-Aware Commands 🎯

**Automatic Angular Detection:**
When you run `prodrun dev` in an Angular project, it automatically uses `ng serve` instead of `pnpm run dev`:

```bash
# Instead of:                   # prodrun automatically does:
prodrun dev                     # ng serve
prodrun build                   # ng build
prodrun test                    # ng test
prodrun lint                    # ng lint

# Status tracking works too:
prodrun status                  # Detects running ng serve processes
```

**Works for all frameworks:**
- Angular → `ng serve`
- Next.js → `pnpm run dev`
- React/Vite → `pnpm run dev`
- Nest → `pnpm run start:dev`

### 6. Real-World Utilities 🛠️

**Port Management:**
```bash
prodrun port:check 3000    # Check if in use
prodrun port:kill 3000     # Kill process
prodrun port:info 3000     # Show details
```

**Environment:**
```bash
prodrun env:check          # Check .env files
prodrun env:copy           # Copy .env.example
```

**Git:**
```bash
prodrun git:status         # Colored status
```

**Docker:**
```bash
prodrun docker:status      # Check daemon
prodrun docker:up          # Start containers
```

## Commands Reference

### Basic
```bash
prodrun dev              # Start dev server
prodrun build            # Build project
prodrun test             # Run tests
prodrun lint             # Lint code
prodrun start            # Start production
```

### Project Info
```bash
prodrun info             # Full project info
prodrun detect           # Detection results
prodrun health           # Environment health check
```

### Logging
```bash
prodrun logs [type] [lines]        # View logs
prodrun log:filter <type> <value>  # Filter logs
prodrun log:stats                  # Statistics
prodrun log:viewer                 # Interactive viewer
prodrun log:follow [pattern]       # Follow in real-time
```

### Angular
```bash
prodrun ng:serve [app] [port]   # Serve app
prodrun ng:build [app]          # Build app
prodrun ng:test [app]           # Run tests
prodrun ng:apps                 # List all apps
```

### Dependencies
```bash
prodrun deps:outdated    # Check for updates
prodrun deps:update      # Update packages
prodrun deps:audit       # Security audit
```

### Utilities
```bash
prodrun port:check [port]     # Check port
prodrun port:kill [port]      # Kill port
prodrun env:check             # Check .env
prodrun docker:up             # Start Docker
prodrun clean                 # Clean project
prodrun fresh                 # Fresh install
```

### Failure-Aware Commands
```bash
prodrun run <cmd> [--retry=N]  # Run with failure awareness
prodrun validate <cmd>         # Validate before running
prodrun retry <cmd> [attempts] # Retry failed command
```

## Configuration

### Global: `~/.config/prodrun/config.zsh`

```bash
# Auto-detection
PRUN_AUTO_DETECT_PM=true
PRUN_AUTO_DETECT_TYPE=true

# Validation
PRUN_AUTO_INSTALL=true
PRUN_VALIDATE_NODE_VERSION=true

# Retry
PRUN_AUTO_RETRY=true
PRUN_MAX_RETRIES=3

# Logging
PRUN_LOG_LEVEL=INFO
PRUN_LOG_DIR=./logs
```

### Project: `.prunrc`

```bash
# Override package manager
PRUN_PACKAGE_MANAGER=pnpm

# Custom commands
PRUN_COMMANDS[dev]="dev:custom"

# Required environment variables
PRUN_REQUIRED_ENV_VARS="API_KEY,DB_URL"
```

## Real-World Examples

### New Project (Angular Example)
```bash
cd my-angular-app
prodrun dev

# ℹ Angular project detected - using: ng serve
# ✓ Pre-flight checks passed
# ✓ Starting Angular dev server on port 4200...

# In another terminal:
prodrun status

# Project Type: angular
# Package Manager: pnpm (detected from lock files)
# Status: Running (Angular dev server detected)
# PID CPU MEM CMD
# 1234 5.2 2.1 ng serve --port=4200
```

### Next.js / React Project
```bash
cd my-next-app
prodrun dev

# Auto-detects Next.js
# Runs: pnpm run dev
# Starts on port 3000
```

### Port Conflict
```bash
prodrun dev

# ❌ Port 4200 in use
# 💡 Kill it: prodrun port:kill 4200
# 🔄 Retry with 4201? [Y/n]
```

### Build Failure
```bash
prodrun build --retry=3

# ❌ Build failed
# 🔄 Retrying with clean install...
# ✓ Success on retry 2
```

### Failure-Aware Execution
```bash
# Run tests with automatic retry
prodrun run npm test --retry=5

# ❌ Test failed: Module not found
# 💡 Suggested fixes:
#   1. Reinstall dependencies: prodrun fresh
#   2. Clear cache: prodrun clean
# 🔄 Attempting automatic fix...
# ✓ Dependencies reinstalled
# ✓ Tests passed on retry 2

# Validate before running expensive build
prodrun validate npm run build

# ✓ Node.js version matches
# ✓ Dependencies installed
# ✓ Package manager available
# ✓ Port 3000 available
# Ready to run!

# Retry with exponential backoff
prodrun retry "npm install" 5

# Retry 1/5 in 5 seconds...
# Retry 2/5 in 10 seconds...
# Retry 3/5 in 15 seconds...
# ✓ Success on retry 3
```

## Shortcuts

Add to `~/.zshrc`:
```bash
source ~/.config/prodrun/lib/shortcuts.zsh
```

Use:
```bash
wpdev       # prodrun dev
wpbuild     # prodrun build
wpinfo      # prodrun info
wplogs      # prodrun logs
wprun       # prodrun run (failure-aware)
wpvalidate  # prodrun validate
wpretry     # prodrun retry
```

## Benefits

### Development
- ✅ Zero config - works immediately
- ✅ Faster debugging - smart logs
- ✅ Fewer errors - validation
- ✅ Less downtime - auto-retry

### Production
- ✅ Reliable execution
- ✅ Better monitoring
- ✅ Quick troubleshooting
- ✅ Complete audit trail

### Teams
- ✅ Consistent environment
- ✅ Easy onboarding
- ✅ Shared configuration
- ✅ Clear error messages

## Dependencies

**Required:** zsh, node, git
**Optional:** jq, bat, prettier

## Installation

```bash
cd ~/dotfiles
stow personal-library
source ~/.zshrc
prodrun version
```

## Philosophy

1. **Zero Configuration** - Works out of the box
2. **Smart Defaults** - Does the right thing
3. **Helpful Errors** - Clear solutions
4. **Production Ready** - Reliable and tested
5. **Developer Friendly** - Fast and intuitive

---

**Version:** 1.1.0 | **License:** MIT

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## Support

For issues and feature requests, please use the [GitHub Issues](https://github.com/catstackdev/personal-shell-library--prodrun/issues) page.

## Changelog

### v1.1.0 (2026-01-13)
- Added failure-aware execution with smart retry
- Added automatic Angular project detection
- Added intelligent status tracking for foreground processes
- Enhanced error detection with suggested fixes
- Improved project-aware commands

### v1.0.0 (2026-01-10)
- Initial release
- Auto-detection for package managers and project types
- Angular CLI integration
- Real-world utilities (port, docker, git, env)
- Enhanced logging system
- Performance tracking
