#!/usr/bin/env zsh
# Completion installer for prodrun

# Install zsh completion
install_zsh_completion() {
  local completion_file="$PRUN_CONFIG_DIR/completions/_prodrun"
  local install_dir=""

  # Determine installation directory
  if [[ -d "$HOME/.config/zsh/completions" ]]; then
    install_dir="$HOME/.config/zsh/completions"
  elif [[ -d "$HOME/.zsh/completions" ]]; then
    install_dir="$HOME/.zsh/completions"
  elif [[ -d "/usr/local/share/zsh/site-functions" ]]; then
    install_dir="/usr/local/share/zsh/site-functions"
  else
    # Create local completion directory
    install_dir="$HOME/.zsh/completions"
    mkdir -p "$install_dir"
  fi

  # Check if completion is already installed
  if [[ -L "$install_dir/_prodrun" ]] || [[ -f "$install_dir/_prodrun" ]]; then
    log_debug "Completion already installed at $install_dir/_prodrun"
    return 0
  fi

  # Install completion file
  log_info "Installing zsh completion..."

  # Try to symlink first (preferred)
  if ln -sf "$completion_file" "$install_dir/_prodrun" 2>/dev/null; then
    log_success "Completion installed: $install_dir/_prodrun"
  # Fallback to copy if symlink fails (no write permission)
  elif cp "$completion_file" "$install_dir/_prodrun" 2>/dev/null; then
    log_success "Completion copied: $install_dir/_prodrun"
  else
    log_warn "Could not install completion to $install_dir"
    log_info "Please run: sudo ln -sf $completion_file $install_dir/_prodrun"
    return 1
  fi

  # Add fpath if needed
  local zshrc="$HOME/.zshrc"
  if [[ ! -f "$zshrc" ]]; then
    zshrc="$HOME/.zshrc"
    touch "$zshrc"
  fi

  # Check if fpath is already configured
  if ! grep -q "fpath.*$install_dir" "$zshrc" 2>/dev/null; then
    log_info "Adding completion path to ~/.zshrc"
    echo "" >>"$zshrc"
    echo "# prodrun completion" >>"$zshrc"
    echo "fpath=($install_dir \$fpath)" >>"$zshrc"
    echo "autoload -Uz compinit && compinit" >>"$zshrc"
  fi

  # log_info "Run this once to refresh completions:"
  # log_info "  rm -f ~/.zcompdump* && exec zsh"

  # log_success "Completion installed! Reload shell: source ~/.zshrc"
  return 0
}

# Check if completion is installed
check_completion_installed() {
  local completion_installed=false

  # Check common locations
  local -a check_dirs=(
    "$HOME/.config/zsh/completions"
    "$HOME/.zsh/completions"
    "/usr/local/share/zsh/site-functions"
  )

  for dir in "${check_dirs[@]}"; do
    if [[ -f "$dir/_prodrun" ]] || [[ -L "$dir/_prodrun" ]]; then
      completion_installed=true
      break
    fi
  done

  if [[ "$completion_installed" == "true" ]]; then
    return 0
  else
    return 1
  fi
}

# Auto-install on first run (if not installed)
auto_install_completion() {
  # Skip if already installed
  if check_completion_installed; then
    return 0
  fi

  # Skip if explicitly disabled
  if [[ "${PRUN_AUTO_INSTALL_COMPLETION:-true}" == "false" ]]; then
    return 0
  fi

  # Skip if not in interactive shell
  if [[ ! -o interactive ]]; then
    return 0
  fi

  # Only ask once by creating a marker file
  local marker_file="$HOME/.config/prodrun/.completion-asked"
  if [[ -f "$marker_file" ]]; then
    return 0
  fi

  # Ask user
  log_info "Shell completion not detected. Install it for better UX?"
  echo -n "Install zsh completion? [Y/n] "
  read -r response

  # Create marker to not ask again
  mkdir -p "$(dirname "$marker_file")"
  touch "$marker_file"

  if [[ "$response" =~ ^[Yy]?$ ]]; then
    install_zsh_completion
    return $?
  else
    log_info "Skipped. Run 'prodrun completion:install' to install later."
    return 0
  fi
}

# Uninstall completion
uninstall_zsh_completion() {
  local removed=false

  local -a check_dirs=(
    "$HOME/.config/zsh/completions"
    "$HOME/.zsh/completions"
    "/usr/local/share/zsh/site-functions"
  )

  for dir in "${check_dirs[@]}"; do
    if [[ -f "$dir/_prodrun" ]] || [[ -L "$dir/_prodrun" ]]; then
      rm -f "$dir/_prodrun"
      log_success "Removed: $dir/_prodrun"
      removed=true
    fi
  done

  if [[ "$removed" == "false" ]]; then
    log_warn "Completion not found"
    return 1
  fi

  log_success "Completion uninstalled. Reload shell: source ~/.zshrc"
  return 0
}

# Reinstall completion (update)
reinstall_zsh_completion() {
  log_info "Reinstalling completion..."
  uninstall_zsh_completion 2>/dev/null
  install_zsh_completion
}
