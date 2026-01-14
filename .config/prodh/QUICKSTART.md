# prodh - Quick Start Guide

## Installation

```bash
# Navigate to prodh directory
cd ~/dotfiles/personal-library/.config/prodh

# Install dependencies
pnpm install

# Build the project
pnpm build

# Link globally (optional)
pnpm link --global
```

## Usage

### Basic Usage

```bash
# Navigate to your project
cd ~/your-web-project

# Launch prodh
prodh
```

You'll see:
1. A beautiful splash screen with the PRODH logo
2. Project information (auto-detected)
3. Interactive menu with options

### Navigation

- **↑ / ↓** - Navigate menu items
- **Enter** - Select an item
- **Q** - Quit (from main menu)
- **ESC** - Go back (from sub-menus)

### Quick Actions

| Action | Menu Item |
|--------|-----------|
| Start dev server | 🚀 Start Development |
| Build project | 🔨 Build Project |
| Run tests | 🧪 Run Tests |
| Kill port 3000 | 🔌 Port Management |
| Monitor processes | 📊 Process Monitor |
| View project info | ℹ️ Project Information |

## Features Overview

### 🚀 Start Development
- Runs `pnpm dev`, `npm dev`, or detected dev command
- Shows live output in a bordered box
- Displays execution time
- Returns to menu when complete

### 📊 Process Monitor
- Shows port status (3000, 4200, 5173, etc.)
- Lists all Node.js processes with PID, CPU, Memory
- Auto-refreshes every 5 seconds
- Press Q or ESC to exit

### 🔌 Port Management
- Interactive menu to select ports
- Kills process on selected port
- Shows success/error message
- Auto-returns to menu

### ℹ️ Project Information
- Project type (Angular, React, Next.js, etc.)
- Package manager (pnpm, npm, yarn, bun)
- Workspace type (Nx, Turbo, etc.)
- Docker availability
- Available npm scripts

## Project Detection

prodh automatically detects:

### Package Manager
- Checks for `pnpm-lock.yaml` → pnpm
- Checks for `yarn.lock` → yarn
- Checks for `bun.lockb` → bun
- Default → npm

### Project Type
From `package.json` dependencies:
- `@angular/core` → Angular
- `next` → Next.js
- `@nestjs/core` → Nest.js
- `nuxt` → Nuxt
- `vue` → Vue
- `vite` → Vite
- `react` → React

### Workspace Type
- `nx.json` → Nx
- `turbo.json` → Turbo
- `lerna.json` → Lerna
- `workspaces` in package.json → Workspaces

## Tips & Tricks

### Keyboard Shortcuts
- **Q** in main menu - Quit instantly
- **ESC** in any sub-screen - Return to main menu
- **Enter** - Confirm selection

### Common Workflows

**Start Development**
```
1. Launch prodh
2. Select "🚀 Start Development"
3. Wait for server to start
4. Press any key to return to menu
```

**Kill a Port**
```
1. Launch prodh
2. Select "🔌 Port Management"
3. Select the port to kill
4. Confirm the operation
```

**Monitor Your App**
```
1. Launch prodh
2. Select "📊 Process Monitor"
3. Watch real-time updates
4. Press Q when done
```

## Troubleshooting

### "Cannot find module" errors
```bash
cd ~/dotfiles/personal-library/.config/prodh
rm -rf node_modules dist
pnpm install
pnpm build
```

### Port already in use
Use the Port Management feature to kill the process on that port.

### Process not showing in monitor
The process monitor only shows processes that match "node" in the command. Some tools might use different process names.

## Development Mode

```bash
# Watch mode - auto-reloads on changes
pnpm dev

# Build and run
pnpm build && pnpm start

# Test a specific feature
pnpm dev
# Then in your code, navigate to test the feature
```

## Next Steps

- Explore all menu options
- Try different project types
- Monitor your development servers
- Manage ports interactively
- Check out the full [README](./readme.md) for more details

---

**Version**: 0.0.0
**Author**: cybercat
**Last Updated**: 2026-01-14
