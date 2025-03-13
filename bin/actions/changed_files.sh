#!/bin/sh
# File: bin/actions/changed_files.sh
# Desc: identify all changed files between a feature branch
#       and the origin.
#
# NOTE: Assumes the base branch is "main" when running locally
#
# See Also for an alternative?? https://github.com/marketplace/actions/get-files-that-changed
#
# System Environment Variables
#   CF_DEBUG    when "true" allows debug statements to be echoed
#


debug() {
  [ "${CF_DEBUG:-false}" = "true" ] && echo "[DEBUG] $@" >&2
}

error() {
  echo "[ERROR] $@" >&2
  exit 1
}

warn() {
  echo "[WARN] $@" >&2
}

# Main business logic for changed files

changed_files=""
deleted_files=""

RAW_DIFF_FILE="raw_diff.txt"

# Check if raw_diff.txt exists and is readable, 
# if not create it using git diff --raw main...
# used in localhost testing.

if [ ! -r "$RAW_DIFF_FILE" ]; then
  debug "Creating $RAW_DIFF_FILE using git diff"
  git diff --raw main... > "$RAW_DIFF_FILE"
  if [ $? -ne 0 ]; then
    error "Failed to create $RAW_DIFF_FILE using git diff"
  fi
else
  debug "$RAW_DIFF_FILE exists, using its contents"
fi

# Read the raw diff from the file
CF_DIFF=$(cat "$RAW_DIFF_FILE")


# Process the provided CF_DIFF
while IFS= read -r line; do
  debug "line: ($line)"

  if [ -z "$line" ] || [ "$(echo "$line" | cut -c1)" != ":" ]; then
    continue
  fi

  # Use IFS and read to split the line into fields.
  # IFS=' ' read -r _ _ _ _ status file1 file2 <<< "$line"  # does not work

  status=$(echo "$line" | awk '{print $5}')
  file1=$(echo "$line" | awk '{print $6}')
  file2=$(echo "$line" | awk '{print $7}')

  debug "status: ($status)"
  debug "file1: ($file1)"
  debug "file2: ($file2)"


  # Handle the case where file2 might not exist (empty).
  if [ -z "$file2" ]; then
      file2=""
  fi

  case "$status" in
    R*)
      case "$file1" in
        content/*) deleted_files="$deleted_files:$file1" ;;
      esac
      case "$file2" in
        content/*) changed_files="$changed_files:$file2" ;;
      esac
      ;;
    A)
      case "$file1" in
        content/*) changed_files="$changed_files:$file1" ;;
      esac
      ;;
    M)
      case "$file1" in
        content/*) changed_files="$changed_files:$file1" ;;
      esac
      ;;
    D)
      deleted_files="$deleted_files:$file1"
      ;;
    *)
      debug "Ignoring status: $status for file: $file1"
      ;;
  esac
done << EOF
$CF_DIFF
EOF

# Strip leading colons and write to files
changed_files="${changed_files#:}"
deleted_files="${deleted_files#:}"

debug "changed_files=$changed_files"
debug "deleted_files=$deleted_files"

# Convert colon-delimited paths to newlines
printf "$changed_files" | tr ':' '\n' > changed-files.txt
printf "$deleted_files" | tr ':' '\n' > deleted-files.txt
