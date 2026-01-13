#!/usr/bin/env zsh
# Shortcuts and aliases for common operations

# Quick aliases for prodrun
# Users can add to their .zshrc:
# source ~/.config/prodrun/lib/shortcuts.zsh

# Basic aliases
alias wprod='prodrun'
alias wp='prodrun'

# Common commands
alias wpdev='prodrun dev'
alias wpbuild='prodrun build'
alias wptest='prodrun test'
alias wplint='prodrun lint'
alias wpstart='prodrun start'

# Info and detection
alias wpinfo='prodrun info'
alias wpdetect='prodrun detect'

# Logs
alias wplogs='prodrun logs'
alias wpstats='prodrun log:stats'
alias wpfollow='prodrun log:follow'
alias wpviewer='prodrun log:viewer'

# Angular
alias wpng='prodrun ng'
alias wpserve='prodrun ng:serve'
alias wpapps='prodrun ng:apps'

# Port management
alias wpport='prodrun port:check'
alias wpkill='prodrun port:kill'

# Docker
alias wpdocker='prodrun docker:status'
alias wpdup='prodrun docker:up'
alias wpddown='prodrun docker:down'

# Dependencies
alias wpdeps='prodrun deps:outdated'
alias wpaudit='prodrun deps:audit'
alias wpupdate='prodrun deps:update'

# Cleanup
alias wpclean='prodrun clean'
alias wpfresh='prodrun fresh'

# Git
alias wpgit='prodrun git:status'

# Environment
alias wpenv='prodrun env:check'

# Failure-aware execution
alias wprun='prodrun run'
alias wpvalidate='prodrun validate'
alias wpretry='prodrun retry'

# Smart shortcuts with project detection
wpx() {
  local project_type=$(detect_project_type)

  case "$project_type" in
    angular)
      log_info "Angular project detected"
      prodrun ng:serve
      ;;
    next)
      log_info "Next.js project detected"
      prodrun dev
      ;;
    *)
      log_info "Running dev server"
      prodrun dev
      ;;
  esac
}

# Quick project setup
wpinit() {
  prodrun info
  prodrun env:check
  prodrun detect
}

# Full health check
wpcheck() {
  prodrun detect
  prodrun health
  prodrun deps:audit
  prodrun git:status
}

# Quick rebuild
wprebuild() {
  prodrun clean
  prodrun build
}

# Port quick check and kill
wpkp() {
  local port="${1:-3000}"
  if prodrun port:check "$port"; then
    echo "Kill process on port $port? [y/N]"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
      prodrun port:kill "$port"
    fi
  fi
}

# Show all shortcuts
wphelp() {
  cat << 'EOF'
🚀 Web Production Shortcuts (wprod/wp)

BASIC:
  wpdev        - Start dev server
  wpbuild      - Build project
  wptest       - Run tests
  wplint       - Lint code
  wpstart      - Start production server

INFO:
  wpinfo       - Show project info
  wpdetect     - Detect project type
  wpinit       - Quick setup check

LOGS:
  wplogs       - View logs
  wpstats      - Log statistics
  wpfollow     - Follow logs in real-time
  wpviewer     - Interactive log viewer

ANGULAR:
  wpng         - Run ng command
  wpserve      - Serve Angular app
  wpapps       - List Angular apps

PORTS:
  wpport [n]   - Check port (default: 3000)
  wpkill [n]   - Kill port (default: 3000)
  wpkp [n]     - Check and kill port interactively

DOCKER:
  wpdocker     - Docker status
  wpdup        - Docker up
  wpddown      - Docker down

DEPS:
  wpdeps       - Check outdated
  wpaudit      - Security audit
  wpupdate     - Update dependencies

CLEANUP:
  wpclean      - Clean project
  wpfresh      - Fresh install
  wprebuild    - Clean + rebuild

SMART:
  wpx          - Auto-detect and run (Angular: serve, Next: dev, etc)
  wpcheck      - Full health check
  wpinit       - Project setup check

FAILURE-AWARE:
  wprun        - Run command with failure awareness
  wpvalidate   - Validate command before running
  wpretry      - Retry failed command

GIT & ENV:
  wpgit        - Git status
  wpenv        - Check .env files

Full help: prodrun --help
EOF
}
