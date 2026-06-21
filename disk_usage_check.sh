#!/usr/bin/env bash
# Use Bash interpreter from system PATH

set -euo pipefail
# -e  : Exit immediately if any command fails
# -u  : Exit if an undefined variable is used
# -o pipefail : Fail the entire pipeline if any command in the pipeline fails

IFS=$'\n\t'
# Internal Field Separator
# Split strings only on:
#   newline (\n)
#   tab (\t)
# Avoids problems with spaces in filenames/directories

threshold="${DISK_THRESHOLD:-85}"
# Read DISK_THRESHOLD environment variable
# If not set, use default value 85
#
# Example:
# export DISK_THRESHOLD=90
# threshold=90
#
# If variable does not exist:
# threshold=85

log() {
  # Generic logging function

  local level="$1"
  # First parameter becomes log level (INFO/WARN/ERROR)

  shift
  # Remove first parameter
  # Remaining arguments become actual message

  printf '%s [%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$level" "$*"
  # Print log message in format:
  #
  # 2026-06-21 10:30:25 [INFO] Disk usage check started
}
# End of log function


check_path() {
  # Function to check disk usage of a given path

  local path="$1"
  # Store passed directory path

  local usage
  # Variable to store disk usage percentage

  usage=$(df -P "$path" | awk 'NR==2 {gsub("%","",$5); print $5}')
  #
  # df -P "$path"
  # Example output:
  #
  # Filesystem     1024-blocks   Used Available Capacity Mounted on
  # /dev/sda1       100000000 80000  20000    80%     /
  #
  # awk explanation:
  #
  # NR==2
  #   Process second line only
  #
  # $5
  #   Take 5th column => usage percentage
  #
  # gsub("%","",$5)
  #   Remove % sign
  #
  # print $5
  #   Output clean numeric value
  #
  # Result:
  # usage=80

  if [[ -z "$usage" ]]; then
    # Check if usage value is empty

    log ERROR "Unable to read usage for $path"
    # Log error if disk usage couldn't be determined

    return
    # Exit function
  fi

  if (( usage >= threshold )); then
    # Numeric comparison
    #
    # Example:
    # usage=90
    # threshold=85
    #
    # 90 >= 85 => TRUE

    log WARN "$path is at ${usage}% usage"
    # Produce warning log

  else
    # Usage below threshold

    log INFO "$path is at ${usage}% usage"
    # Produce informational log
  fi
}
# End of check_path function


main() {
  # Main execution function

  log INFO "Disk usage check started"
  # Start log

  local paths=()
  # Create empty array

  if (($# > 0)); then
    # $# = Number of command-line arguments
    #
    # Example:
    # ./disk_check.sh /var /opt
    #
    # $# = 2

    paths=("$@")
    # Store all supplied paths into array

  else
    # No command-line arguments passed

    paths=(/ /var /tmp)
    # Default paths to check:
    #
    # /      -> Root filesystem
    # /var   -> Log files, application data
    # /tmp   -> Temporary files
  fi

  for path in "${paths[@]}"; do
    # Loop through every path in array

    [[ -n "$path" ]] || continue
    # Skip if path is empty
    #
    # -n means string length > 0

    check_path "$path"
    # Call disk usage check function
  done

  log INFO "Disk usage check completed"
  # Final completion log
}
# End of main function


main "$@"
# Script entry point
#
# Pass all command-line arguments to main
#
# Examples:
#
# ./disk_check.sh
# Checks:
#    /
#    /var
#    /tmp
#
# ./disk_check.sh /home /opt
# Checks:
#    /home
#    /opt
#
# Sample output:
#
# 2026-06-21 10:30:00 [INFO] Disk usage check started
# 2026-06-21 10:30:00 [INFO] / is at 45% usage
# 2026-06-21 10:30:00 [WARN] /var is at 89% usage
# 2026-06-21 10:30:00 [INFO] /tmp is at 10% usage
# 2026-06-21 10:30:00 [INFO] Disk usage check completed
#
# Exit Status:
# 0 = Successful execution
# Non-zero = Failure due to strict mode or command error