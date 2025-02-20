#!/bin/sh
set -euo pipefail

# File: bin/actions/changed_files.sh
# Desc: identify all changed files between a feature branch
#       and the origin.
#
# See Also for an alternative?? https://github.com/marketplace/actions/get-files-that-changed
#
# System Environment Variables
#   CF_DEBUG    when "true" allows debug statements to be echoed
#   CF_TESTING  when "true" does not execute the cf_main function
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


append_unique_existing_filepath() {
    local var_name="$1"
    local filepath="$2"

    # Short-circuit for files outside content/ directory
    if [ "${filepath#content/}" = "$filepath" ]; then
      return
    fi

    # Short-circuit deleted non-existent files if not appending to deleted_files
    if [ "${var_name#deleted}" = "$var_name" ] && [ ! -e "$filepath" ]; then
      return
    fi

    local current_value="$(eval "echo \$$var_name")"
    local IFS=:;  # Set IFS locally within the function
    local existing_file

    if [ -n "$current_value" ]; then
        for existing_file in $current_value; do
            if [ "$filepath" = "$existing_file" ]; then
                return  # Already in the list
            fi

            # Basename check
            local file_dir=$(dirname "$filepath")
            local file_base=$(basename "$filepath" | cut -d '.' -f 1)
            local existing_dir=$(dirname "$existing_file")
            local existing_base=$(basename "$existing_file" | cut -d '.' -f 1)

            if [ "$file_dir" = "$existing_dir" ] && [ "$file_base" = "$existing_base" ]; then
              warn "File '$filepath' has the same date as an existing file '$existing_file' but with a different extension."
            fi
        done
    fi

    # Append using printf %q for quoting.
    if [ -z "$current_value" ]; then
        eval "printf -v \"$var_name\" %q \"$filepath\""
    else
        eval "printf -v \"$var_name\" \"%s:%q\" \"\$${var_name}\" \"$filepath\""
    fi

}

# Main business logic for changed files
# cf_main() {

# Determine the base branch (main or master)
if git show-ref --quiet "refs/remotes/origin/main"; then
  TARGET_BRANCH="origin/main"
elif git show-ref --quiet "refs/remotes/origin/master"; then
  TARGET_BRANCH="origin/master"
else
  TARGET_BRANCH="${TARGET_BRANCH:-}" # Use existing value or set it to empty.
  if [ -z "${TARGET_BRANCH}" ]; then
      error "Neither origin/main nor origin/master found. Please set TARGET_BRANCH manually and ensure you are on the feature branch."
  fi
fi

# Get the name of the current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Check if we are on a detached HEAD
if [ "$CURRENT_BRANCH" = "HEAD" ]; then
    warn "You are in a detached HEAD state. Please checkout a branch to continue."
fi

debug "TARGET_BRANCH:  $TARGET_BRANCH"
debug "CURRENT_BRANCH: $CURRENT_BRANCH"

# Get the list of commits unique to the current branch.
COMMITS=$(git rev-list --no-merges "$TARGET_BRANCH..$CURRENT_BRANCH")

if [ -z "$COMMITS" ]; then
  warn "No commits found that are unique to the current branch compared to $TARGET_BRANCH."
  exit 0
fi

debug "one"

# added or modified
changed_files=""

# removed or old_file in a renamed action
deleted_files=""


debug "two"

# Iterate through each commit to detect renames and other changes
for commit in $COMMITS; do

debug "commit: $commit"

  # Detect renames and other changes in this commit
  DIFF=$(git diff --raw --find-renames -M "$commit^..$commit")

  while IFS= read -r line; do
    #  :100644 100644 bcd1234 0123456 M  file1.txt
    #  :100644 100644 bcd1234 0123456 R100  file1.txt file2.txt
    #  :000000 100644 0000000 0123456 A  file1.txt
    #  :100644 000000 0123456 0000000 D  file1.txt

    parts=(${line})
    # Skip empty lines and lines that do not start with ":"
    if [ -z "$line" ] || [ "${line:0:1}" != ":" ]; then
      continue
    fi

    status="${parts[4]}"
    file1="${parts[5]}"
    file2="${parts[6]-}" # For rename cases


    case "$status" in
      R*)
        # Renamed file:  R100 file1 file2
        append_unique_existing_filepath "deleted_files" "$file1"
        append_unique_existing_filepath "changed_files" "$file2"
        ;;
      A)
        append_unique_existing_filepath "changed_files" "$file1"
        ;;
      M)
        append_unique_existing_filepath "changed_files" "$file1"
        ;;
      D)
        append_unique_existing_filepath "deleted_files" "$file1"
        ;;
      *)
        # Ignore other status codes (e.g., C for copied)
        debug "Ignoring status: $status for file: $file1"
        ;;
    esac
  done << EOF
$DIFF
EOF
done

debug "changed_files=$changed_files"
debug "deleted_files=$deleted_files"

echo "$changed_files" | tr ':' '\n' > changed-files.txt
echo "$deleted_files" | tr ':' '\n' > deleted-files.txt


# }

# [ -z "$CF_TESTING" ] || [ "$CF_TESTING" != "true" ] && cf_main


