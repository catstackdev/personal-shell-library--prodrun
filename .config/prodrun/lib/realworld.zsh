#!/usr/bin/env zsh
# Real-world utilities for prodrun

# Git utilities
git_current_branch() {
  git rev-parse --abbrev-ref HEAD 2>/dev/null
}

git_is_dirty() {
  [[ -n $(git status -s 2>/dev/null) ]]
}

git_status_summary() {
  if ! git rev-parse --git-dir &>/dev/null; then
    echo "Not a git repository"
    return 1
  fi

  local branch=$(git_current_branch)
  local status_color="${GREEN}"

  if git_is_dirty; then
    status_color="${YELLOW}"
  fi

  echo -e "${status_color}Branch: $branch${NC}"
  git status -s
}

# Environment file management
env_check() {
  log_info "Checking environment files..."

  local found=0

  if [[ -f ".env" ]]; then
    log_info "✓ .env found"
    ((found++))
  fi

  if [[ -f ".env.local" ]]; then
    log_info "✓ .env.local found"
    ((found++))
  fi

  if [[ -f ".env.example" ]]; then
    log_info "✓ .env.example found"
    ((found++))
  fi

  if [[ -f ".env.production" ]]; then
    log_info "✓ .env.production found"
    ((found++))
  fi

  if [[ $found -eq 0 ]]; then
    log_warn "No environment files found"
    return 1
  fi

  return 0
}

env_copy_example() {
  if [[ ! -f ".env.example" ]]; then
    log_error ".env.example not found"
    return 1
  fi

  if [[ -f ".env" ]]; then
    log_warn ".env already exists. Use --force to overwrite"
    return 1
  fi

  cp .env.example .env
  log_success "Created .env from .env.example"
}

# Port management
port_check() {
  local port="${1:-3000}"

  if lsof -Pi :"$port" -sTCP:LISTEN -t >/dev/null 2>&1; then
    log_warn "Port $port is in use"
    return 0
  else
    log_info "Port $port is available"
    return 1
  fi
}

port_kill() {
  local port="${1:-3000}"

  local pid=$(lsof -ti:"$port" 2>/dev/null)

  if [[ -z "$pid" ]]; then
    log_warn "No process found on port $port"
    return 1
  fi

  log_info "Killing process $pid on port $port..."
  kill -9 $pid
  log_success "Port $port freed"
}

port_info() {
  local port="${1:-3000}"

  log_info "Processes on port $port:"
  lsof -i:"$port" 2>/dev/null || log_warn "No processes on port $port"
}

# Docker utilities
docker_status() {
  if ! command -v docker &>/dev/null; then
    log_error "Docker not installed"
    return 1
  fi

  log_info "Docker status:"

  if docker ps &>/dev/null; then
    log_success "✓ Docker daemon running"

    local running=$(docker ps -q | wc -l | tr -d ' ')
    log_info "Running containers: $running"

    if [[ -f "docker-compose.yml" ]] || [[ -f "docker-compose.yaml" ]]; then
      log_info "✓ docker-compose.yml found"
    fi
  else
    log_error "✗ Docker daemon not running"
    return 1
  fi
}

docker_up() {
  if [[ ! -f "docker-compose.yml" ]] && [[ ! -f "docker-compose.yaml" ]]; then
    log_error "docker-compose.yml not found"
    return 1
  fi

  log_info "Starting Docker containers..."
  docker-compose up -d
}

docker_down() {
  if [[ ! -f "docker-compose.yml" ]] && [[ ! -f "docker-compose.yaml" ]]; then
    log_error "docker-compose.yml not found"
    return 1
  fi

  log_info "Stopping Docker containers..."
  docker-compose down
}

docker_logs() {
  if [[ ! -f "docker-compose.yml" ]] && [[ ! -f "docker-compose.yaml" ]]; then
    log_error "docker-compose.yml not found"
    return 1
  fi

  docker-compose logs -f
}

# Dependency check and info
deps_outdated() {
  local pm=$(detect_package_manager)

  log_info "Checking for outdated dependencies..."

  case "$pm" in
    npm)
      npm outdated
      ;;
    pnpm)
      pnpm outdated
      ;;
    yarn)
      yarn outdated
      ;;
    bun)
      bun outdated 2>/dev/null || log_warn "bun outdated not yet available"
      ;;
  esac
}

deps_update() {
  local pm=$(detect_package_manager)

  log_info "Updating dependencies with $pm..."

  case "$pm" in
    npm)
      npm update
      ;;
    pnpm)
      pnpm update
      ;;
    yarn)
      yarn upgrade
      ;;
    bun)
      bun update
      ;;
  esac
}

deps_audit() {
  local pm=$(detect_package_manager)

  log_info "Running security audit with $pm..."

  case "$pm" in
    npm|pnpm)
      $pm audit
      ;;
    yarn)
      yarn audit
      ;;
    bun)
      log_warn "bun audit not yet available"
      ;;
  esac
}

# Project info summary
project_info() {
  log_info "Project Information"
  echo "===================="
  echo ""

  # Project type
  local proj_type=$(detect_project_type)
  echo "Project Type: $proj_type"

  # Package manager
  local pm=$(detect_package_manager)
  echo "Package Manager: $pm"

  # Workspace type
  local workspace=$(detect_workspace_type)
  if [[ "$workspace" != "single" ]]; then
    echo "Workspace: $workspace"
  fi

  # Node version
  local node_ver=$(detect_node_version)
  if [[ -n "$node_ver" ]]; then
    echo "Required Node: $node_ver"
  fi
  echo "Current Node: $(node -v 2>/dev/null || echo 'Not found')"

  # Git info
  if git rev-parse --git-dir &>/dev/null; then
    echo ""
    echo "Git Branch: $(git_current_branch)"
    if git_is_dirty; then
      echo "Status: Uncommitted changes"
    else
      echo "Status: Clean"
    fi
  fi

  # Docker
  if has_docker; then
    echo ""
    echo "Docker: Available"
  fi

  # Environment files
  if has_env_files; then
    echo ""
    echo "Environment: .env files present"
  fi

  # Available scripts
  echo ""
  echo "Available Scripts:"
  get_available_scripts | while read -r script; do
    echo "  - $script"
  done
}

# Quick cleanup
clean_all() {
  log_warn "This will remove node_modules, lock files, and build outputs"
  echo -n "Continue? [y/N] "
  read -r response

  if [[ ! "$response" =~ ^[Yy]$ ]]; then
    log_info "Cancelled"
    return 0
  fi

  log_info "Cleaning project..."

  # Remove node_modules
  if [[ -d "node_modules" ]]; then
    log_info "Removing node_modules..."
    rm -rf node_modules
  fi

  # Remove lock files
  rm -f package-lock.json pnpm-lock.yaml yarn.lock bun.lockb

  # Remove common build dirs
  rm -rf dist build out .next .turbo .nx

  log_success "Project cleaned"
}

# Fresh install
fresh_install() {
  clean_all

  local pm=$(detect_package_manager)
  log_info "Installing dependencies with $pm..."
  $pm install
}
