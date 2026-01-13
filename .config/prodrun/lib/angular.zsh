#!/usr/bin/env zsh
# Angular CLI utilities for prodrun

# Check if Angular CLI is available
has_angular_cli() {
  command -v ng &>/dev/null
}

# Run Angular CLI command
ng_run() {
  local cmd="$@"

  if ! has_angular_cli; then
    log_error "Angular CLI not found. Install with: npm install -g @angular/cli"
    return 1
  fi

  log_info "Running: ng $cmd"
  ng $cmd
}

# Angular serve with auto port detection
ng_serve() {
  local app="${1:-}"
  local port="${2:-4200}"

  if ! has_angular_cli; then
    log_error "Angular CLI not found"
    return 1
  fi

  # Check if port is in use
  if port_check "$port"; then
    log_warn "Port $port is in use. Trying to free it..."
    port_kill "$port"
    sleep 1
  fi

  if [[ -n "$app" ]]; then
    log_info "Serving Angular app: $app on port $port"
    ng serve "$app" --port="$port" --open
  else
    log_info "Serving Angular app on port $port"
    ng serve --port="$port" --open
  fi
}

# Angular build with configuration
ng_build() {
  local app="${1:-}"
  local config="${2:-production}"

  if ! has_angular_cli; then
    log_error "Angular CLI not found"
    return 1
  fi

  if [[ -n "$app" ]]; then
    log_info "Building Angular app: $app (config: $config)"
    ng build "$app" --configuration="$config"
  else
    log_info "Building Angular app (config: $config)"
    ng build --configuration="$config"
  fi
}

# Angular test with coverage
ng_test() {
  local app="${1:-}"
  local coverage="${2:-false}"

  if ! has_angular_cli; then
    log_error "Angular CLI not found"
    return 1
  fi

  local coverage_flag=""
  if [[ "$coverage" == "true" ]] || [[ "$coverage" == "--coverage" ]]; then
    coverage_flag="--code-coverage"
  fi

  if [[ -n "$app" ]]; then
    log_info "Testing Angular app: $app"
    ng test "$app" $coverage_flag
  else
    log_info "Testing Angular app"
    ng test $coverage_flag
  fi
}

# List Angular projects/apps
ng_list_apps() {
  if [[ ! -f "angular.json" ]]; then
    log_error "Not an Angular workspace"
    return 1
  fi

  log_info "Angular apps in workspace:"
  detect_angular_apps | while read -r app; do
    echo "  - $app"
  done
}

# Generate Angular component
ng_generate() {
  local type="${1:-component}"
  local name="${2:-}"

  if ! has_angular_cli; then
    log_error "Angular CLI not found"
    return 1
  fi

  if [[ -z "$name" ]]; then
    log_error "Usage: ng_generate <type> <name>"
    echo "Types: component, service, module, directive, pipe, guard, class, interface, enum"
    return 1
  fi

  log_info "Generating $type: $name"
  ng generate "$type" "$name"
}

# Angular lint
ng_lint() {
  local app="${1:-}"

  if ! has_angular_cli; then
    log_error "Angular CLI not found"
    return 1
  fi

  if [[ -n "$app" ]]; then
    log_info "Linting Angular app: $app"
    ng lint "$app"
  else
    log_info "Linting Angular workspace"
    ng lint
  fi
}

# Angular update check
ng_update_check() {
  if ! has_angular_cli; then
    log_error "Angular CLI not found"
    return 1
  fi

  log_info "Checking for Angular updates..."
  ng update
}

# Angular update packages
ng_update_packages() {
  if ! has_angular_cli; then
    log_error "Angular CLI not found"
    return 1
  fi

  log_info "Updating Angular packages..."
  ng update @angular/core @angular/cli
}

# Angular info/version
ng_info() {
  if ! has_angular_cli; then
    log_error "Angular CLI not found"
    return 1
  fi

  ng version
}

# Angular serve all apps (workspace)
ng_serve_all() {
  if [[ ! -f "angular.json" ]]; then
    log_error "Not an Angular workspace"
    return 1
  fi

  log_info "Starting all Angular apps..."

  local port=4200
  detect_angular_apps | while read -r app; do
    log_info "Starting $app on port $port"
    ng serve "$app" --port="$port" &
    ((port++))
  done

  log_success "All apps started. Press Ctrl+C to stop."
  wait
}

# Angular e2e tests
ng_e2e() {
  local app="${1:-}"

  if ! has_angular_cli; then
    log_error "Angular CLI not found"
    return 1
  fi

  if [[ -n "$app" ]]; then
    log_info "Running e2e tests for: $app"
    ng e2e "$app"
  else
    log_info "Running e2e tests"
    ng e2e
  fi
}

# Angular workspace analytics
ng_analytics() {
  if ! has_angular_cli; then
    log_error "Angular CLI not found"
    return 1
  fi

  ng analytics
}
