#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

target_dir="${TARGET_DIR:-/var/log}"
size_limit="${SIZE_LIMIT:-100M}"
dry_run="${DRY_RUN:-true}"
backup_dir="${BACKUP_DIR:-./cleanup-backup}"

log() {
  local level="$1"
  shift
  printf '%s [%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$level" "$*"
}

validate_target() {
  if [[ -z "$target_dir" || "$target_dir" == "/" ]]; then
    log ERROR "Unsafe target directory: '$target_dir'"
    exit 1
  fi

  if [[ "$target_dir" != /* ]]; then
    log ERROR "Target directory must be absolute: '$target_dir'"
    exit 1
  fi
}

main() {
  validate_target
  mkdir -p "$backup_dir"

  log INFO "Scanning $target_dir for files larger than $size_limit"
  mapfile -t large_files < <(find "$target_dir" -type f -size +"$size_limit" -print)

  if ((${#large_files[@]} == 0)); then
    log INFO "No oversized files found"
    exit 0
  fi

  printf '%s\n' "${large_files[@]}"

  if [[ "$dry_run" == "true" ]]; then
    log INFO "Dry-run enabled. No files were changed."
    exit 0
  fi

  for file in "${large_files[@]}"; do
    cp -p "$file" "$backup_dir/$(basename "$file").$(date +%s).bak"
    : > "$file"
    log INFO "Truncated $file after backup"
  done

  log INFO "Cleanup completed"
}

main "$@"
