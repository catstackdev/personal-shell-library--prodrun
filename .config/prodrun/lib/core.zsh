# Core functions

# Initialize prodrun in current directory
init_prun() {
  local log_dir="$PRUN_LOG_DIR"

  mkdir -p "$log_dir"

  # Set up log files
  PRUN_LOG_FILE="$log_dir/app-$(date +%Y%m%d).log"
  PRUN_ERROR_LOG="$log_dir/error-$(date +%Y%m%d).log"
  PRUN_PID_FILE="$log_dir/app.pid"

  # Clean old logs
  if [[ -d "$log_dir" ]]; then
    find "$log_dir" -name "*.log" -mtime +"$PRUN_LOG_RETENTION_DAYS" -delete 2>/dev/null || true
  fi

  # Auto-detect package manager if not set
  if [[ "$PRUN_AUTO_DETECT_PM" == "true" ]] || [[ -z "$PRUN_PACKAGE_MANAGER" ]]; then
    PRUN_PACKAGE_MANAGER=$(detect_package_manager)
    log_debug "Auto-detected package manager: $PRUN_PACKAGE_MANAGER"
  fi
}

# Load project config if exists
load_project_config() {
  if [[ -f ".prunrc" ]]; then
    log_debug "Loading project config: .prunrc"
    source ".prunrc"
  fi

  # Override package manager if auto-detect is enabled
  if [[ "$PRUN_AUTO_DETECT_PM" == "true" ]]; then
    PRUN_PACKAGE_MANAGER=$(detect_package_manager)
    log_debug "Package manager: $PRUN_PACKAGE_MANAGER"
  fi
}

# Pre-flight checks with enhanced detection
preflight_checks() {
  log_debug "Running pre-flight checks..."

  # Auto-detect package manager
  local pm="$PRUN_PACKAGE_MANAGER"
  if [[ -z "$pm" ]]; then
    pm=$(detect_package_manager)
    PRUN_PACKAGE_MANAGER="$pm"
  fi

  log_debug "Using package manager: $pm"

  # Check if package manager is available
  if ! command -v "$pm" &>/dev/null; then
    log_error "$pm is not installed"

    # Suggest installation
    case "$pm" in
      pnpm)
        echo "Install with: npm install -g pnpm"
        echo "Or: brew install pnpm"
        ;;
      yarn)
        echo "Install with: npm install -g yarn"
        echo "Or: brew install yarn"
        ;;
      bun)
        echo "Install with: curl -fsSL https://bun.sh/install | bash"
        echo "Or: brew install bun"
        ;;
    esac
    return 1
  fi

  # Check package.json
  if [[ ! -f "package.json" ]]; then
    log_error "package.json not found. Not a Node.js project?"
    return 1
  fi

  # Check Node version requirement
  local required_node=$(detect_node_version)
  if [[ -n "$required_node" ]]; then
    log_debug "Required Node version: $required_node"
  fi

  # Auto-install dependencies
  if [[ ! -d "node_modules" ]] && [[ "$PRUN_AUTO_INSTALL" == "true" ]]; then
    log_warn "node_modules not found. Installing dependencies with $pm..."
    $pm install 2>&1 | tee -a "$PRUN_LOG_FILE" || return 1
  fi

  log_debug "✓ Pre-flight checks passed"
  return 0
}

# Run command with logging (project-aware)
run_command() {
  local cmd_name="$1"
  local cmd="${PRUN_COMMANDS[$cmd_name]:-$cmd_name}"
  local project_type=$(detect_project_type)

  # Auto-detect Angular and use ng commands
  if [[ "$project_type" == "angular" ]]; then
    case "$cmd_name" in
      dev)
        log_info "Angular project detected - using: ng serve"
        ng_serve
        return $?
        ;;
      build)
        log_info "Angular project detected - using: ng build"
        ng_build
        return $?
        ;;
      test)
        log_info "Angular project detected - using: ng test"
        ng_test
        return $?
        ;;
      lint)
        log_info "Angular project detected - using: ng lint"
        ng_lint
        return $?
        ;;
    esac
  fi

  log_info "Running: $PRUN_PACKAGE_MANAGER run $cmd"

  # Run with output to both console and log
  $PRUN_PACKAGE_MANAGER run "$cmd" 2>&1 | while IFS= read -r line; do
    echo "$line"
    echo "[$(date +"$PRUN_TIMESTAMP_FORMAT")] [APP] $line" >>"$PRUN_LOG_FILE"

    # Capture errors
    if echo "$line" | grep -qiE "error|exception|failed"; then
      echo "[$(date +"$PRUN_TIMESTAMP_FORMAT")] $line" >>"$PRUN_ERROR_LOG"
    fi
  done

  local exit_code=${PIPESTATUS[0]}

  if [[ $exit_code -eq 0 ]]; then
    log_success "Command completed: $cmd"
  else
    log_error "Command failed: $cmd (exit code: $exit_code)"
  fi

  return $exit_code
}

# Start daemon (project-aware)
start_daemon() {
  local cmd_name="${1:-start}"
  local project_type=$(detect_project_type)

  if [[ -f "$PRUN_PID_FILE" ]] && kill -0 $(cat "$PRUN_PID_FILE") 2>/dev/null; then
    log_error "Already running with PID $(cat $PRUN_PID_FILE)"
    return 1
  fi

  log_info "Starting daemon..."

  # Use Angular commands for Angular projects
  if [[ "$project_type" == "angular" ]] && [[ "$cmd_name" == "start" || "$cmd_name" == "dev" ]]; then
    log_info "Angular project - starting ng serve as daemon"
    nohup ng serve --port=4200 >"$PRUN_LOG_FILE" 2>"$PRUN_ERROR_LOG" &
  else
    nohup $PRUN_PACKAGE_MANAGER run "${PRUN_COMMANDS[$cmd_name]}" >"$PRUN_LOG_FILE" 2>"$PRUN_ERROR_LOG" &
  fi

  local pid=$!
  echo $pid >"$PRUN_PID_FILE"

  sleep 2
  if kill -0 $pid 2>/dev/null; then
    log_success "Daemon started (PID: $pid)"
  else
    log_error "Failed to start daemon"
    rm -f "$PRUN_PID_FILE"
    return 1
  fi
}

# Stop daemon
stop_daemon() {
  if [[ ! -f "$PRUN_PID_FILE" ]]; then
    log_error "Not running (no PID file)"
    return 1
  fi

  local pid=$(cat "$PRUN_PID_FILE")

  if ! kill -0 $pid 2>/dev/null; then
    log_error "Process $pid not running (stale PID file)"
    rm -f "$PRUN_PID_FILE"
    return 1
  fi

  log_info "Stopping daemon (PID: $pid)..."
  kill $pid

  local count=0
  while kill -0 $pid 2>/dev/null && [[ $count -lt 10 ]]; do
    sleep 1
    ((count++))
  done

  if kill -0 $pid 2>/dev/null; then
    log_warn "Graceful shutdown failed, forcing..."
    kill -9 $pid
  fi

  rm -f "$PRUN_PID_FILE"
  log_success "Daemon stopped"
}

# Get status (checks both daemon and foreground processes)
get_status() {
  local project_type=$(detect_project_type)
  local detected_pm=$(detect_package_manager)

  echo "Project Type: $project_type"
  echo "Package Manager: $detected_pm (detected from lock files)"
  echo "Log Directory: $PRUN_LOG_DIR"
  echo ""

  local running=false

  # Check daemon PID file first
  if [[ -f "$PRUN_PID_FILE" ]]; then
    local pid=$(cat "$PRUN_PID_FILE")
    if kill -0 $pid 2>/dev/null; then
      echo "Status: Running as daemon (PID: $pid)"
      ps -p $pid -o pid,pcpu,pmem,etime,cmd 2>/dev/null || true
      running=true
    else
      echo "Status: Dead (stale PID file)"
      rm -f "$PRUN_PID_FILE"
    fi
  fi

  # Check for running processes based on project type
  if [[ "$running" == "false" ]]; then
    case "$project_type" in
      angular)
        # Check for ng serve processes
        local ng_processes=$(ps aux | grep -E "ng serve|@angular/cli.*serve" | grep -v grep)
        if [[ -n "$ng_processes" ]]; then
          echo "Status: Running (Angular dev server detected)"
          echo ""
          echo "$ng_processes" | awk '{print $2, $3, $4, $11, $12, $13, $14, $15}'
          running=true
        fi

        # Also check if port 4200 is in use
        if [[ "$running" == "false" ]] && lsof -Pi :4200 -sTCP:LISTEN -t >/dev/null 2>&1; then
          echo "Status: Running (Port 4200 in use)"
          local port_info=$(lsof -Pi :4200 -sTCP:LISTEN 2>/dev/null)
          echo "$port_info"
          running=true
        fi
        ;;

      next|react|vite)
        # Check for dev server on common ports
        for port in 3000 3001 5173; do
          if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
            echo "Status: Running (Dev server on port $port)"
            lsof -Pi :$port -sTCP:LISTEN 2>/dev/null
            running=true
            break
          fi
        done
        ;;

      *)
        # Check for node processes
        local node_processes=$(ps aux | grep -E "node.*dev|npm.*dev|pnpm.*dev" | grep -v grep)
        if [[ -n "$node_processes" ]]; then
          echo "Status: Running (Node dev server detected)"
          echo ""
          echo "$node_processes" | awk '{print $2, $3, $4, $11, $12, $13, $14, $15}'
          running=true
        fi
        ;;
    esac
  fi

  if [[ "$running" == "false" ]]; then
    echo "Status: Not running"
  fi
}
