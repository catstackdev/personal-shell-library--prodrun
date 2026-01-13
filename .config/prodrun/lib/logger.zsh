# Logger library

# Colors
if [[ "$PRUN_COLOR_OUTPUT" == "true" ]]; then
  readonly RED='\033[0;31m'
  readonly GREEN='\033[0;32m'
  readonly YELLOW='\033[1;33m'
  readonly BLUE='\033[0;34m'
  readonly MAGENTA='\033[0;35m'
  readonly CYAN='\033[0;36m'
  readonly NC='\033[0m'
else
  readonly RED=''
  readonly GREEN=''
  readonly YELLOW=''
  readonly BLUE=''
  readonly MAGENTA=''
  readonly CYAN=''
  readonly NC=''
fi

# Log level hierarchy
typeset -A LOG_LEVELS
LOG_LEVELS[DEBUG]=0
LOG_LEVELS[INFO]=1
LOG_LEVELS[WARN]=2
LOG_LEVELS[ERROR]=3

should_log() {
  local level="$1"
  local current_level="${LOG_LEVELS[$PRUN_LOG_LEVEL]:-1}"
  local message_level="${LOG_LEVELS[$level]:-1}"

  [[ $message_level -ge $current_level ]]
}

log() {
  local level="$1"
  shift
  local message="$*"
  local timestamp=$(date +"$PRUN_TIMESTAMP_FORMAT")

  should_log "$level" || return 0

  echo "[$timestamp] [$level] $message" >>"$PRUN_LOG_FILE"
}

log_console() {
  local level="$1"
  local color="$2"
  shift 2
  local message="$*"

  should_log "$level" || return 0

  echo -e "${color}[${level}]${NC} $message"
  log "$level" "$message"
}

log_debug() {
  log_console "DEBUG" "$BLUE" "$@"
}

log_info() {
  log_console "INFO" "$GREEN" "$@"
}

log_warn() {
  log_console "WARN" "$YELLOW" "$@"
}

log_error() {
  log_console "ERROR" "$RED" "$@" >&2
  echo "[$(date +"$PRUN_TIMESTAMP_FORMAT")] [ERROR] $*" >>"$PRUN_ERROR_LOG"

  # Send notification if enabled
  [[ "$PRUN_NOTIFY_ON_ERROR" == "true" ]] && notify_error "$@"
}

log_success() {
  log_console "INFO" "$GREEN" "✓ $@"

  # Send notification if enabled
  [[ "$PRUN_NOTIFY_ON_SUCCESS" == "true" ]] && notify_success "$@"
}

# Notification helpers
notify_error() {
  if command -v terminal-notifier &>/dev/null; then
    terminal-notifier -title "prun Error" -message "$*" -sound "Basso"
  elif command -v notify-send &>/dev/null; then
    notify-send "prun Error" "$*" -u critical
  fi
}

notify_success() {
  if command -v terminal-notifier &>/dev/null; then
    terminal-notifier -title "prun Success" -message "$*"
  elif command -v notify-send &>/dev/null; then
    notify-send "prun Success" "$*"
  fi
}
