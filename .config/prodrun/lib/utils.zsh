# Utility functions

# Monitor logs with color coding
monitor_logs() {
  log_info "Monitoring logs (Ctrl+C to stop)..."

  tail -f "$PRUN_LOG_FILE" | while IFS= read -r line; do
    if echo "$line" | grep -qiE "error|exception|failed"; then
      echo -e "${RED}$line${NC}"
    elif echo "$line" | grep -qi "warn"; then
      echo -e "${YELLOW}$line${NC}"
    elif echo "$line" | grep -qiE "info|success"; then
      echo -e "${GREEN}$line${NC}"
    else
      echo "$line"
    fi
  done
}

# View logs
view_logs() {
  local type="${1:-app}"
  local lines="${2:-50}"

  case "$type" in
  app)
    tail -n "$lines" "$PRUN_LOG_FILE"
    ;;
  error)
    if [[ -f "$PRUN_ERROR_LOG" ]]; then
      tail -n "$lines" "$PRUN_ERROR_LOG"
    else
      log_warn "No error log found"
    fi
    ;;
  all)
    echo "=== Application Logs ==="
    tail -n "$lines" "$PRUN_LOG_FILE"
    echo ""
    echo "=== Error Logs ==="
    tail -n "$lines" "$PRUN_ERROR_LOG" 2>/dev/null || echo "No errors"
    ;;
  *)
    log_error "Unknown log type: $type"
    return 1
    ;;
  esac
}

# Health check
health_check() {
  log_info "Running health check..."

  local issues=0

  # Check if running
  if [[ -f "$PRUN_PID_FILE" ]]; then
    local pid=$(cat "$PRUN_PID_FILE")
    if kill -0 $pid 2>/dev/null; then
      log_info "✓ Process is running (PID: $pid)"
    else
      log_error "✗ Process not running (stale PID)"
      ((issues++))
    fi
  else
    log_warn "Process not started as daemon"
  fi

  # Check error log
  if [[ -f "$PRUN_ERROR_LOG" ]]; then
    local error_count=$(wc -l <"$PRUN_ERROR_LOG")
    if [[ $error_count -gt 0 ]]; then
      log_warn "⚠ $error_count errors in log"
      ((issues++))
    else
      log_info "✓ No errors logged"
    fi
  fi

  # Check node_modules
  if [[ ! -d "node_modules" ]]; then
    log_error "✗ node_modules not found"
    ((issues++))
  else
    log_info "✓ Dependencies installed"
  fi

  if [[ $issues -eq 0 ]]; then
    log_success "Health check passed"
  else
    log_error "Health check found $issues issue(s)"
    return 1
  fi
}

# Initialize project config
init_project() {
  if [[ -f ".prunrc" ]]; then
    log_error ".prunrc already exists"
    return 1
  fi

  local project_type=$(detect_project_type)

  log_info "Initializing prun config for $project_type project..."

  cp "$HOME/.config/prodrun/templates/.prunrc" ".prunrc"

  log_success "Created .prunrc - customize as needed"
  echo "Edit .prunrc to override global settings"
}
