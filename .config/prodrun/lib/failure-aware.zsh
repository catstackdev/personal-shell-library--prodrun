#!/usr/bin/env zsh
# Failure-aware execution - intelligent error handling and retry logic

# Error detection patterns
declare -gA ERROR_PATTERNS
ERROR_PATTERNS[EADDRINUSE]="address already in use|port.*already in use|EADDRINUSE"
ERROR_PATTERNS[ENOENT]="no such file or directory|ENOENT|cannot find module"
ERROR_PATTERNS[TIMEOUT]="timeout|timed out|ETIMEDOUT"
ERROR_PATTERNS[PERMISSION]="permission denied|EACCES|EPERM"
ERROR_PATTERNS[NETWORK]="network error|ECONNREFUSED|ENETUNREACH"
ERROR_PATTERNS[MEMORY]="out of memory|heap out of memory"
ERROR_PATTERNS[DEPS]="missing dependency|cannot resolve|module not found"

# Suggested fixes for common errors
declare -gA ERROR_FIXES
ERROR_FIXES[EADDRINUSE]="1. Kill process: prodrun port:kill <port>\n2. Use different port: --port=<other>"
ERROR_FIXES[ENOENT]="1. Check file path\n2. Reinstall dependencies: prodrun fresh\n3. Clear cache: prodrun clean"
ERROR_FIXES[TIMEOUT]="1. Check network connection\n2. Increase timeout\n3. Try again later"
ERROR_FIXES[PERMISSION]="1. Check file permissions: chmod +x <file>\n2. Run with sudo (if necessary)\n3. Check file ownership"
ERROR_FIXES[NETWORK]="1. Check internet connection\n2. Check firewall/proxy settings\n3. Verify service is running"
ERROR_FIXES[MEMORY]="1. Increase Node memory: NODE_OPTIONS=--max-old-space-size=4096\n2. Close other applications\n3. Restart your machine"
ERROR_FIXES[DEPS]="1. Install dependencies: prodrun install\n2. Clean install: prodrun fresh\n3. Check package.json"

# Detect error type from output
detect_error_type() {
  local error_output="$1"

  for error_type in ${(k)ERROR_PATTERNS}; do
    if echo "$error_output" | grep -qiE "${ERROR_PATTERNS[$error_type]}"; then
      echo "$error_type"
      return 0
    fi
  done

  echo "UNKNOWN"
}

# Get suggested fixes for error type
get_error_fixes() {
  local error_type="$1"

  if [[ -n "${ERROR_FIXES[$error_type]}" ]]; then
    echo "${ERROR_FIXES[$error_type]}"
  else
    echo "1. Check the error message carefully\n2. Search for the error online\n3. Check project documentation"
  fi
}

# Smart retry with exponential backoff
retry_command() {
  local command="$1"
  local max_retries="${2:-${PRUN_MAX_RETRIES:-3}}"
  local retry_delay="${3:-${PRUN_RETRY_DELAY:-5}}"
  local attempt=1
  local error_output=""

  while [[ $attempt -le $max_retries ]]; do
    log_info "Attempt $attempt/$max_retries: $command"

    # Capture output
    if error_output=$($command 2>&1); then
      log_success "Command succeeded on attempt $attempt"
      return 0
    else
      local exit_code=$?
      local error_type=$(detect_error_type "$error_output")

      log_error "Attempt $attempt failed (exit code: $exit_code)"

      if [[ $attempt -lt $max_retries ]]; then
        # Calculate backoff delay (exponential)
        local backoff_delay=$((retry_delay * attempt))

        log_warn "Detected error type: $error_type"
        echo ""
        echo -e "${YELLOW}💡 Suggested fixes:${NC}"
        echo -e "${CYAN}$(get_error_fixes $error_type)${NC}"
        echo ""

        log_info "Retrying in $backoff_delay seconds..."
        sleep "$backoff_delay"

        # Try automatic fix for some errors
        if [[ "$error_type" == "DEPS" ]]; then
          log_info "Attempting automatic fix: reinstalling dependencies"
          local pm=$(detect_package_manager)
          $pm install 2>&1 | tail -5
        fi
      fi
    fi

    ((attempt++))
  done

  log_error "Command failed after $max_retries attempts"
  return 1
}

# Run command with failure awareness
run_with_failure_awareness() {
  local command="$1"
  shift
  local args="$@"

  log_info "Running: $command $args"

  # Capture both stdout and stderr
  local output_file=$(mktemp)
  local start_time=$(date +%s)

  # Run command
  if "$command" $args > "$output_file" 2>&1; then
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    log_success "Command completed in ${duration}s"
    cat "$output_file"
    rm -f "$output_file"
    return 0
  else
    local exit_code=$?
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    local error_output=$(cat "$output_file")

    log_error "Command failed after ${duration}s (exit code: $exit_code)"

    # Detect error type
    local error_type=$(detect_error_type "$error_output")

    echo ""
    echo -e "${RED}❌ Error Type: $error_type${NC}"
    echo ""
    echo -e "${YELLOW}Error Output:${NC}"
    echo "$error_output" | tail -20
    echo ""
    echo -e "${YELLOW}💡 Suggested fixes:${NC}"
    echo -e "${CYAN}$(get_error_fixes $error_type)${NC}"
    echo ""

    # Ask for retry if enabled
    if [[ "${PRUN_AUTO_RETRY:-true}" == "true" ]]; then
      echo -n "🔄 Retry? [y/N] "
      read -r response

      if [[ "$response" =~ ^[Yy]$ ]]; then
        log_info "Retrying with failure awareness..."
        retry_command "$command $args"
      fi
    fi

    rm -f "$output_file"
    return $exit_code
  fi
}

# Check for common issues before running
preflight_failure_check() {
  local command="$1"
  local issues=0

  log_debug "Running preflight failure checks..."

  # Check if command exists
  if ! command -v "$command" &>/dev/null; then
    log_error "Command not found: $command"
    ((issues++))
  fi

  # Check if in Node project
  if [[ ! -f "package.json" ]] && [[ "$command" =~ ^(npm|pnpm|yarn|bun|node)$ ]]; then
    log_error "Not a Node.js project (package.json not found)"
    ((issues++))
  fi

  # Check for node_modules
  if [[ ! -d "node_modules" ]] && [[ "$command" =~ ^(npm|pnpm|yarn|bun)$ ]]; then
    log_warn "node_modules not found"

    if [[ "${PRUN_AUTO_INSTALL:-true}" == "true" ]]; then
      log_info "Auto-installing dependencies..."
      local pm=$(detect_package_manager)
      $pm install
    else
      log_error "Dependencies not installed"
      echo "Run: prodrun install"
      ((issues++))
    fi
  fi

  # Check disk space
  local available_space=$(df -h . | awk 'NR==2 {print $4}' | sed 's/Gi//')
  if [[ "${available_space%%.*}" -lt 1 ]]; then
    log_warn "Low disk space: ${available_space}GB available"
  fi

  if [[ $issues -gt 0 ]]; then
    log_error "Preflight checks failed with $issues issue(s)"
    return 1
  fi

  log_debug "✓ Preflight checks passed"
  return 0
}

# Smart error recovery
attempt_error_recovery() {
  local error_type="$1"

  log_info "Attempting automatic recovery for: $error_type"

  case "$error_type" in
    DEPS)
      log_info "Reinstalling dependencies..."
      local pm=$(detect_package_manager)
      $pm install
      return $?
      ;;

    EADDRINUSE)
      log_info "Attempting to find alternative port..."
      local base_port=3000
      for port in {3001..3010}; do
        if ! lsof -Pi :"$port" -sTCP:LISTEN -t >/dev/null 2>&1; then
          log_success "Found available port: $port"
          echo "$port"
          return 0
        fi
      done
      log_error "No available ports found"
      return 1
      ;;

    MEMORY)
      log_warn "Clearing caches..."
      rm -rf node_modules/.cache
      rm -rf .next/cache
      rm -rf dist
      log_success "Caches cleared"
      return 0
      ;;

    *)
      log_warn "No automatic recovery available for: $error_type"
      return 1
      ;;
  esac
}

# Track failure patterns
track_failure() {
  local command="$1"
  local error_type="$2"
  local timestamp=$(date +%s)

  local failure_log="${PRUN_LOG_DIR}/failures.log"
  mkdir -p "${PRUN_LOG_DIR}"

  echo "$timestamp,$command,$error_type" >> "$failure_log"

  # Check for patterns (same error 3+ times)
  local recent_failures=$(tail -10 "$failure_log" | grep "$error_type" | wc -l | tr -d ' ')

  if [[ $recent_failures -ge 3 ]]; then
    log_warn "⚠️  Recurring failure detected: $error_type (${recent_failures}x recently)"
    echo ""
    echo -e "${YELLOW}💡 This error has occurred multiple times. Consider:${NC}"
    echo "  1. Checking project documentation"
    echo "  2. Reviewing recent changes"
    echo "  3. Asking for help from team"
    echo ""
  fi
}

# Validate command before running
validate_command() {
  local command="$1"
  shift
  local args="$@"

  # Run preflight checks
  if ! preflight_failure_check "$command"; then
    log_error "Validation failed. Cannot run command."
    return 1
  fi

  # Check for dangerous commands
  if [[ "$command" =~ ^(rm|dd|mkfs)$ ]]; then
    log_warn "⚠️  Potentially dangerous command: $command"
    echo -n "Are you sure? [y/N] "
    read -r response

    if [[ ! "$response" =~ ^[Yy]$ ]]; then
      log_info "Command cancelled"
      return 1
    fi
  fi

  return 0
}

# Main failure-aware execution wrapper
execute() {
  local command="$1"
  shift
  local args="$@"

  # Validate
  if ! validate_command "$command" $args; then
    return 1
  fi

  # Run with failure awareness
  if ! run_with_failure_awareness "$command" $args; then
    local error_type=$(detect_error_type "$(cat /tmp/last_error 2>/dev/null || echo '')")

    # Track failure
    track_failure "$command" "$error_type"

    # Attempt recovery if enabled
    if [[ "${PRUN_AUTO_RECOVERY:-false}" == "true" ]]; then
      log_info "Attempting automatic recovery..."
      if attempt_error_recovery "$error_type"; then
        log_info "Recovery successful, retrying command..."
        run_with_failure_awareness "$command" $args
        return $?
      fi
    fi

    return 1
  fi

  return 0
}
