#!/usr/bin/env zsh
# Auto-detection utilities for prodrun

# Auto-detect package manager from lock files
detect_package_manager() {
  if [[ -f "bun.lockb" ]]; then
    echo "bun"
  elif [[ -f "pnpm-lock.yaml" ]]; then
    echo "pnpm"
  elif [[ -f "yarn.lock" ]]; then
    echo "yarn"
  elif [[ -f "package-lock.json" ]]; then
    echo "npm"
  else
    # Default to pnpm if no lock file
    echo "pnpm"
  fi
}

# Detect project type with enhanced detection
detect_project_type() {
  # Angular
  if [[ -f "angular.json" ]]; then
    echo "angular"
    return 0
  fi

  # NestJS
  if [[ -f "nest-cli.json" ]]; then
    echo "nest"
    return 0
  fi

  # Next.js
  if [[ -f "next.config.js" ]] || [[ -f "next.config.mjs" ]] || [[ -f "next.config.ts" ]]; then
    echo "next"
    return 0
  fi

  # Remix
  if [[ -f "remix.config.js" ]] || [[ -f "remix.config.ts" ]]; then
    echo "remix"
    return 0
  fi

  # Nuxt
  if [[ -f "nuxt.config.js" ]] || [[ -f "nuxt.config.ts" ]]; then
    echo "nuxt"
    return 0
  fi

  # Vite
  if [[ -f "vite.config.ts" ]] || [[ -f "vite.config.js" ]]; then
    echo "vite"
    return 0
  fi

  # Astro
  if [[ -f "astro.config.mjs" ]] || [[ -f "astro.config.ts" ]]; then
    echo "astro"
    return 0
  fi

  # SvelteKit
  if [[ -f "svelte.config.js" ]]; then
    echo "svelte"
    return 0
  fi

  # React (via package.json detection)
  if [[ -f "package.json" ]]; then
    if grep -q '"react"' package.json 2>/dev/null; then
      echo "react"
      return 0
    fi
  fi

  # Vue (via package.json)
  if [[ -f "package.json" ]]; then
    if grep -q '"vue"' package.json 2>/dev/null; then
      echo "vue"
      return 0
    fi
  fi

  # Gatsby
  if [[ -f "gatsby-config.js" ]] || [[ -f "gatsby-config.ts" ]]; then
    echo "gatsby"
    return 0
  fi

  # Generic Node.js
  if [[ -f "package.json" ]]; then
    echo "node"
    return 0
  fi

  echo "unknown"
}

# Detect workspace/monorepo structure
detect_workspace_type() {
  # Nx workspace
  if [[ -f "nx.json" ]]; then
    echo "nx"
    return 0
  fi

  # Turborepo
  if [[ -f "turbo.json" ]]; then
    echo "turbo"
    return 0
  fi

  # Lerna
  if [[ -f "lerna.json" ]]; then
    echo "lerna"
    return 0
  fi

  # PNPM workspace
  if [[ -f "pnpm-workspace.yaml" ]]; then
    echo "pnpm-workspace"
    return 0
  fi

  # Yarn workspace
  if [[ -f "package.json" ]]; then
    if grep -q '"workspaces"' package.json 2>/dev/null; then
      echo "yarn-workspace"
      return 0
    fi
  fi

  echo "single"
}

# Get available scripts from package.json
get_available_scripts() {
  if [[ ! -f "package.json" ]]; then
    return 1
  fi

  # Extract scripts using jq if available, fallback to grep
  if command -v jq &>/dev/null; then
    jq -r '.scripts | keys[]' package.json 2>/dev/null
  else
    grep -A 100 '"scripts"' package.json | \
      grep '":' | \
      sed 's/.*"\(.*\)".*/\1/' | \
      grep -v scripts
  fi
}

# Detect if running in a subdirectory of a project
detect_project_root() {
  local current_dir="$PWD"

  while [[ "$current_dir" != "/" ]]; do
    if [[ -f "$current_dir/package.json" ]]; then
      echo "$current_dir"
      return 0
    fi
    current_dir=$(dirname "$current_dir")
  done

  return 1
}

# Detect Angular workspace apps
detect_angular_apps() {
  if [[ ! -f "angular.json" ]]; then
    return 1
  fi

  if command -v jq &>/dev/null; then
    jq -r '.projects | keys[]' angular.json 2>/dev/null
  else
    grep -o '"[^"]*":\s*{' angular.json | sed 's/"//g' | sed 's/:\s*{//'
  fi
}

# Detect Node version requirement
detect_node_version() {
  if [[ -f ".nvmrc" ]]; then
    cat .nvmrc
    return 0
  fi

  if [[ -f "package.json" ]] && command -v jq &>/dev/null; then
    jq -r '.engines.node // empty' package.json 2>/dev/null
  fi
}

# Check if Docker is available in project
has_docker() {
  [[ -f "Dockerfile" ]] || [[ -f "docker-compose.yml" ]] || [[ -f "docker-compose.yaml" ]]
}

# Check if project has environment files
has_env_files() {
  [[ -f ".env" ]] || [[ -f ".env.local" ]] || [[ -f ".env.example" ]]
}
