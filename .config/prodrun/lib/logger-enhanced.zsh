#!/usr/bin/env zsh
# Enhanced logging system with structured logging, filtering, and analytics

# Structured logging (JSON format)
log_json() {
  local level="$1"
  local message="$2"
  local context="${3:-}"
  local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")

  local json_log=$(cat <<EOF
{"timestamp":"$timestamp","level":"$level","message":"$message","context":"$context","project":"$(basename $PWD)","git_branch":"$(git_current_branch 2>/dev/null || echo 'none')"}
EOF
)

  echo "$json_log" >> "${PRUN_LOG_DIR}/structured.jsonl"
}

# Performance tracking
declare -gA PRUN_TIMERS

timer_start() {
  local name="$1"
  PRUN_TIMERS[$name]=$(date +%s.%N)
}

timer_end() {
  local name="$1"
  local start_time="${PRUN_TIMERS[$name]}"

  if [[ -z "$start_time" ]]; then
    log_warn "Timer '$name' was never started"
    return 1
  fi

  local end_time=$(date +%s.%N)
  local duration=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "0")

  # Format duration
  local formatted_duration
  if (( $(echo "$duration < 1" | bc -l) )); then
    formatted_duration=$(printf "%.0fms" $(echo "$duration * 1000" | bc -l))
  elif (( $(echo "$duration < 60" | bc -l) )); then
    formatted_duration=$(printf "%.2fs" $duration)
  else
    local minutes=$(echo "$duration / 60" | bc -l)
    formatted_duration=$(printf "%.2fm" $minutes)
  fi

  log_info "⏱  $name completed in $formatted_duration"

  # Save to performance log
  echo "[$(date +"$PRUN_TIMESTAMP_FORMAT")] $name: $formatted_duration" >> "${PRUN_LOG_DIR}/performance.log"

  # JSON log
  log_json "PERF" "$name completed" "$formatted_duration"

  unset "PRUN_TIMERS[$name]"
  echo "$formatted_duration"
}

# Log filtering and search
log_filter() {
  local filter_type="${1:-level}"
  local filter_value="${2:-INFO}"
  local log_file="${3:-$PRUN_LOG_FILE}"

  if [[ ! -f "$log_file" ]]; then
    log_error "Log file not found: $log_file"
    return 1
  fi

  case "$filter_type" in
    level)
      # Filter by log level
      grep "\[$filter_value\]" "$log_file"
      ;;
    pattern)
      # Filter by pattern
      grep -i "$filter_value" "$log_file"
      ;;
    time)
      # Filter by time range (e.g., "10:00" to "11:00")
      grep "$filter_value" "$log_file"
      ;;
    last)
      # Last N lines
      tail -n "$filter_value" "$log_file"
      ;;
    context)
      # Show context around matches (3 lines before/after)
      grep -C 3 "$filter_value" "$log_file"
      ;;
    *)
      log_error "Unknown filter type: $filter_type"
      echo "Available: level, pattern, time, last, context"
      return 1
      ;;
  esac
}

# Log statistics
log_stats() {
  local log_file="${1:-$PRUN_LOG_FILE}"

  if [[ ! -f "$log_file" ]]; then
    log_warn "No log file found"
    return 1
  fi

  echo "Log Statistics for $(basename $log_file)"
  echo "========================================"

  # Count by level
  echo -e "\n📊 By Level:"
  echo "  DEBUG:  $(grep -c '\[DEBUG\]' "$log_file" 2>/dev/null || echo 0)"
  echo "  INFO:   $(grep -c '\[INFO\]' "$log_file" 2>/dev/null || echo 0)"
  echo "  WARN:   $(grep -c '\[WARN\]' "$log_file" 2>/dev/null || echo 0)"
  echo "  ERROR:  $(grep -c '\[ERROR\]' "$log_file" 2>/dev/null || echo 0)"

  # Total lines
  echo -e "\n📝 Total lines: $(wc -l < "$log_file")"

  # File size
  local size=$(du -h "$log_file" | cut -f1)
  echo "💾 File size: $size"

  # Time range
  local first_line=$(head -n 1 "$log_file" | grep -oE '\[.*?\]' | head -n 1)
  local last_line=$(tail -n 1 "$log_file" | grep -oE '\[.*?\]' | head -n 1)
  echo -e "\n⏰ Time range:"
  echo "  From: $first_line"
  echo "  To:   $last_line"

  # Top errors (if any)
  local error_count=$(grep -c '\[ERROR\]' "$log_file" 2>/dev/null || echo 0)
  if [[ $error_count -gt 0 ]]; then
    echo -e "\n🔥 Recent errors:"
    grep '\[ERROR\]' "$log_file" | tail -n 5 | while read line; do
      echo "  - ${line}"
    done
  fi

  # Performance stats (if available)
  if [[ -f "${PRUN_LOG_DIR}/performance.log" ]]; then
    echo -e "\n⚡ Performance (last 5 operations):"
    tail -n 5 "${PRUN_LOG_DIR}/performance.log" | while read line; do
      echo "  $line"
    done
  fi
}

# Interactive log viewer with colors and filtering
log_viewer() {
  local log_file="${1:-$PRUN_LOG_FILE}"

  if [[ ! -f "$log_file" ]]; then
    log_error "Log file not found: $log_file"
    return 1
  fi

  # Use less with colored output
  if command -v bat &>/dev/null; then
    # Use bat if available (better syntax highlighting)
    bat --paging=always --style=plain "$log_file"
  else
    # Fallback to less with color
    less -R +G "$log_file"
  fi
}

# Real-time log following with smart filtering
log_follow() {
  local filter="${1:-}"
  local log_file="${2:-$PRUN_LOG_FILE}"

  if [[ ! -f "$log_file" ]]; then
    log_error "Log file not found: $log_file"
    return 1
  fi

  log_info "Following log file (Ctrl+C to stop)"

  if [[ -n "$filter" ]]; then
    log_info "Filter: $filter"
    tail -f "$log_file" | grep --line-buffered -i "$filter" | while IFS= read -r line; do
      # Color output based on level
      if echo "$line" | grep -q '\[ERROR\]'; then
        echo -e "${RED}$line${NC}"
      elif echo "$line" | grep -q '\[WARN\]'; then
        echo -e "${YELLOW}$line${NC}"
      elif echo "$line" | grep -q '\[DEBUG\]'; then
        echo -e "${BLUE}$line${NC}"
      else
        echo "$line"
      fi
    done
  else
    tail -f "$log_file" | while IFS= read -r line; do
      if echo "$line" | grep -q '\[ERROR\]'; then
        echo -e "${RED}$line${NC}"
      elif echo "$line" | grep -q '\[WARN\]'; then
        echo -e "${YELLOW}$line${NC}"
      elif echo "$line" | grep -q '\[DEBUG\]'; then
        echo -e "${BLUE}$line${NC}"
      else
        echo "$line"
      fi
    done
  fi
}

# Log comparison between two files or time periods
log_diff() {
  local log1="${1}"
  local log2="${2}"

  if [[ ! -f "$log1" ]] || [[ ! -f "$log2" ]]; then
    log_error "Both log files must exist"
    return 1
  fi

  log_info "Comparing logs:"
  echo "  File 1: $log1"
  echo "  File 2: $log2"
  echo ""

  # Use diff with color if available
  if command -v colordiff &>/dev/null; then
    colordiff -u "$log1" "$log2" | less -R
  else
    diff -u "$log1" "$log2" | less
  fi
}

# Smart notifications with pattern matching
notify_smart() {
  local level="$1"
  local message="$2"
  local pattern="${PRUN_NOTIFY_PATTERN:-}"

  # Only notify if pattern matches or no pattern set
  if [[ -z "$pattern" ]] || echo "$message" | grep -qi "$pattern"; then
    if [[ "$level" == "ERROR" ]]; then
      notify_error "$message"
    else
      notify_success "$message"
    fi
  fi
}

# Build metrics tracking
track_build_metric() {
  local metric_name="$1"
  local metric_value="$2"
  local timestamp=$(date +%s)

  echo "$timestamp,$metric_name,$metric_value" >> "${PRUN_LOG_DIR}/metrics.csv"

  # Show trend if multiple entries exist
  local count=$(grep -c ",$metric_name," "${PRUN_LOG_DIR}/metrics.csv" 2>/dev/null || echo 0)
  if [[ $count -gt 1 ]]; then
    local prev_value=$(grep ",$metric_name," "${PRUN_LOG_DIR}/metrics.csv" | tail -n 2 | head -n 1 | cut -d',' -f3)
    local diff=$(echo "$metric_value - $prev_value" | bc -l 2>/dev/null || echo "0")

    if (( $(echo "$diff > 0" | bc -l 2>/dev/null || echo 0) )); then
      log_warn "📈 $metric_name increased by $(printf "%.2f" $diff)"
    elif (( $(echo "$diff < 0" | bc -l 2>/dev/null || echo 0) )); then
      log_success "📉 $metric_name decreased by $(printf "%.2f" $(echo "$diff * -1" | bc -l))"
    fi
  fi
}

# Show metrics dashboard
metrics_dashboard() {
  if [[ ! -f "${PRUN_LOG_DIR}/metrics.csv" ]]; then
    log_warn "No metrics data available"
    return 1
  fi

  echo "Build Metrics Dashboard"
  echo "======================="
  echo ""

  # Get unique metric names
  cut -d',' -f2 "${PRUN_LOG_DIR}/metrics.csv" | sort -u | while read metric_name; do
    echo "📊 $metric_name:"

    # Get last 5 values
    grep ",$metric_name," "${PRUN_LOG_DIR}/metrics.csv" | tail -n 5 | while IFS=, read ts name value; do
      local date_str=$(date -r "$ts" "+%Y-%m-%d %H:%M" 2>/dev/null || echo "N/A")
      echo "  $date_str: $value"
    done

    echo ""
  done
}

# Log rotation helper
log_rotate() {
  local max_size="${1:-10M}"  # 10MB default
  local max_age="${2:-30}"     # 30 days default

  log_info "Rotating logs (max size: $max_size, max age: $max_age days)"

  # Compress old logs
  find "$PRUN_LOG_DIR" -name "*.log" -mtime +7 ! -name "*.gz" -exec gzip {} \; 2>/dev/null

  # Delete very old logs
  find "$PRUN_LOG_DIR" -name "*.log.gz" -mtime +$max_age -delete 2>/dev/null

  # Check current log size and rotate if needed
  if [[ -f "$PRUN_LOG_FILE" ]]; then
    local size=$(stat -f%z "$PRUN_LOG_FILE" 2>/dev/null || stat -c%s "$PRUN_LOG_FILE" 2>/dev/null)
    local max_bytes=$(numfmt --from=iec "$max_size" 2>/dev/null || echo 10485760)

    if [[ $size -gt $max_bytes ]]; then
      local timestamp=$(date +%Y%m%d-%H%M%S)
      mv "$PRUN_LOG_FILE" "${PRUN_LOG_FILE}.${timestamp}"
      gzip "${PRUN_LOG_FILE}.${timestamp}"
      log_success "Rotated log file (was $(numfmt --to=iec $size 2>/dev/null || echo "${size} bytes"))"
    fi
  fi
}

# Context-aware logging
log_with_context() {
  local level="$1"
  local message="$2"

  # Add context
  local project=$(basename "$PWD")
  local git_branch=$(git_current_branch 2>/dev/null || echo "none")
  local pm=$(detect_package_manager 2>/dev/null || echo "unknown")

  local context="[$project/$git_branch/$pm]"

  case "$level" in
    DEBUG) log_debug "$context $message" ;;
    INFO) log_info "$context $message" ;;
    WARN) log_warn "$context $message" ;;
    ERROR) log_error "$context $message" ;;
  esac

  # Also log to structured format
  log_json "$level" "$message" "$context"
}
