# Global web-production configuration
# Override in project with .prunrc

# Default settings
PRUN_LOG_DIR="${PRUN_LOG_DIR:-./logs}"
PRUN_LOG_LEVEL="${PRUN_LOG_LEVEL:-INFO}"             # DEBUG, INFO, WARN, ERROR
PRUN_PACKAGE_MANAGER="${PRUN_PACKAGE_MANAGER:-pnpm}" # pnpm, npm, yarn, bun (or auto)
PRUN_AUTO_DETECT_PM="${PRUN_AUTO_DETECT_PM:-true}"   # Auto-detect from lock files
PRUN_AUTO_INSTALL="${PRUN_AUTO_INSTALL:-true}"
PRUN_LOG_RETENTION_DAYS="${PRUN_LOG_RETENTION_DAYS:-7}"
PRUN_COLOR_OUTPUT="${PRUN_COLOR_OUTPUT:-true}"
PRUN_TIMESTAMP_FORMAT="${PRUN_TIMESTAMP_FORMAT:-%Y-%m-%d %H:%M:%S}"

# Project type detection
PRUN_DETECT_TYPE="${PRUN_DETECT_TYPE:-true}"
PRUN_AUTO_DETECT_TYPE="${PRUN_AUTO_DETECT_TYPE:-true}"

# Daemon settings
PRUN_DAEMON_RESTART_DELAY="${PRUN_DAEMON_RESTART_DELAY:-5}"
PRUN_DAEMON_MAX_RESTARTS="${PRUN_DAEMON_MAX_RESTARTS:-5}"

# Notifications (optional - requires terminal-notifier or notify-send)
PRUN_NOTIFY_ON_ERROR="${PRUN_NOTIFY_ON_ERROR:-false}"
PRUN_NOTIFY_ON_SUCCESS="${PRUN_NOTIFY_ON_SUCCESS:-false}"

# Custom commands (can override per project)
typeset -A PRUN_COMMANDS
PRUN_COMMANDS[dev]="dev"
PRUN_COMMANDS[start]="start"
PRUN_COMMANDS[build]="build"
PRUN_COMMANDS[test]="test"
PRUN_COMMANDS[lint]="lint"
