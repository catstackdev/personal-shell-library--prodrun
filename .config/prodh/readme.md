# prodh - Production Helper (GUI Edition)

> Interactive TUI for web development workflows - A graphical companion to `prodrun`

A beautiful terminal user interface (TUI) built with [Ink](https://github.com/vadimdemedes/ink) (React for CLIs) that provides an interactive menu-driven experience for managing your web development projects.

## Features

✨ **Interactive TUI Menu** - Navigate with arrow keys, beautiful UI with colors and emojis
🔍 **Auto-Detection** - Automatically detects project type, package manager, and workspace setup
📊 **Process Monitor** - Real-time monitoring of Node.js processes and port usage
🔌 **Port Management** - View and kill processes on specific ports interactively
⚡ **Command Execution** - Run dev, build, test commands with live output and status
🎨 **Beautiful UI** - Colorful, gradient text, spinners, and progress indicators

### Supported Project Types

- Angular
- React
- Next.js
- Nest.js
- Vue.js
- Nuxt
- Vite
- And more...

### Supported Package Managers

- pnpm
- npm
- yarn
- bun

## Installation

### Global Installation

```bash
cd ~/dotfiles/personal-library/.config/prodh
pnpm install
pnpm build
pnpm link --global
```

Now you can use `prodh` from anywhere:

```bash
cd ~/your-project
prodh
```

### Local Development

```bash
pnpm install
pnpm dev          # Run in watch mode
pnpm build        # Build for production
pnpm start        # Run the built version
```

## Usage

### Launch Interactive Menu

Simply run `prodh` in any project directory:

```bash
prodh
```

You'll see a beautiful splash screen followed by an interactive menu with:

- **Project Information** - Auto-detected project details
- **Development Commands** - Start dev server, build, test, lint
- **Port Management** - Check and kill processes on ports
- **Process Monitor** - Monitor Node.js processes in real-time
- **Docker Commands** - (Coming soon)
- **Dependency Management** - (Coming soon)
- **Git Status** - (Coming soon)

### Navigation

- Use **↑** and **↓** arrow keys to navigate menu items
- Press **Enter** to select an option
- Press **Q** to quit from the main menu
- Press **ESC** to return to menu from sub-screens

### Menu Options

#### 🚀 Start Development
Runs the `dev` or `start` script with live output and status indicators.

#### 🔨 Build Project
Executes the build command with progress tracking.

#### 🧪 Run Tests
Runs your test suite with real-time output.

#### 🔍 Lint Code
Runs linting with visual feedback.

#### 🔌 Port Management
Interactive menu to kill processes on common ports (3000, 4200, 5173, etc.).

#### 📊 Process Monitor
Real-time dashboard showing:
- Port status (in use / available)
- Running Node.js processes with CPU and memory usage
- Auto-refreshes every 5 seconds
- Press Q or ESC to exit

#### ℹ️ Project Information
Displays comprehensive project details:
- Project type (Angular, React, Next.js, etc.)
- Package manager (pnpm, npm, yarn, bun)
- Workspace type (Nx, Turbo, Lerna, etc.)
- Docker availability
- Environment file status
- Available npm scripts

## Architecture

### Technology Stack

- **Ink** - React for CLIs (v6.6.0)
- **TypeScript** - Type-safe development
- **Execa** - Process execution
- **Meow** - CLI argument parsing
- **Ink Components**:
  - `ink-select-input` - Interactive menus
  - `ink-spinner` - Loading indicators
  - `ink-gradient` - Beautiful gradient text
  - `ink-big-text` - ASCII art text

### Project Structure

```
prodh/
├── source/
│   ├── cli.tsx                    # Entry point
│   ├── app.tsx                    # Main app component
│   ├── components/
│   │   ├── ProjectInfo.tsx        # Project info display
│   │   ├── MainMenu.tsx           # Main menu
│   │   ├── CommandRunner.tsx      # Command execution UI
│   │   ├── ProcessMonitor.tsx     # Process monitoring UI
│   │   └── PortManager.tsx        # Port management UI
│   └── utils/
│       ├── detection.ts           # Project detection logic
│       └── process.ts             # Process utilities
├── dist/                          # Compiled output
├── package.json
├── tsconfig.json
└── readme.md
```

### Detection System

The tool automatically detects:

1. **Package Manager** - From lock files (pnpm-lock.yaml, yarn.lock, etc.)
2. **Project Type** - From dependencies in package.json
3. **Workspace Type** - From nx.json, turbo.json, lerna.json, etc.
4. **Docker** - Checks for docker-compose.yml or Dockerfile
5. **Environment** - Checks for .env.example
6. **Common Ports** - Based on project type

## Comparison with `prodrun`

| Feature | prodrun | prodh (GUI) |
|---------|---------|-------------|
| Interface | CLI commands | Interactive TUI menu |
| Usage | `prodrun dev` | Navigate with arrows |
| Output | Terminal output | Live status UI |
| Process Monitor | `prodrun status` | Real-time dashboard |
| Port Management | `prodrun port:kill 3000` | Interactive selection |
| User Experience | Fast, scriptable | Visual, exploratory |
| Best For | Scripts, automation | Interactive use |

### When to Use Each

**Use `prodrun`** when:
- Writing scripts or automation
- Need fast, direct command execution
- Working in CI/CD pipelines
- Prefer keyboard-driven commands

**Use `prodh`** when:
- Exploring a new project
- Want visual feedback
- Monitoring processes
- Prefer menu-driven interface

## Development

### Adding New Screens

1. Create a new component in `source/components/`
2. Add the screen type to `Screen` union in `app.tsx`
3. Add menu item in `MainMenu.tsx`
4. Add case in `handleMenuSelect` in `app.tsx`
5. Add screen rendering logic in `app.tsx`

### Example: Adding a Git Screen

```typescript
// 1. Add to Screen type
type Screen = 'menu' | 'git' | /* ... */;

// 2. Add to MainMenu items
items.push({label: '🌿 Git Status', value: 'git'});

// 3. Handle selection
case 'git':
  setScreen('git');
  break;

// 4. Render screen
if (screen === 'git') {
  return <GitStatusComponent onExit={() => setScreen('menu')} />;
}
```

## Roadmap

- [x] Interactive menu system
- [x] Project auto-detection
- [x] Process monitoring
- [x] Port management
- [x] Command execution with live output
- [ ] Docker commands (up, down, logs, status)
- [ ] Dependency management (outdated, update, audit)
- [ ] Git status and operations
- [ ] Angular-specific commands
- [ ] Workflow presets
- [ ] Configuration wizard
- [ ] Custom themes
- [ ] Plugin system

## Contributing

This is a personal dotfiles project, but feel free to use it as inspiration for your own tools!

## License

MIT

## Related Projects

- [prodrun](../prodrun) - CLI companion tool for scripting
- [ink](https://github.com/vadimdemedes/ink) - React for interactive CLIs
- [create-ink-app](https://github.com/vadimdemedes/create-ink-app) - Scaffold for Ink apps

---

**Version**: 0.0.0 (In Development)
**Author**: cybercat
**Last Updated**: 2026-01-14
