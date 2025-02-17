#!/bin/sh
# File: bin/actions/changed_files.sh
# Desc: identify all changed files between a feature branch
#       and the origin.
#
# See Also: https://github.com/marketplace/actions/get-files-that-changed
#


debug() {
  [ "$DEBUG" = "true" ] && echo "[DEBUG] $@" >&2
}


error() {
  echo "[ERROR] $@" >&2
  exit 1
}

warn() {
  echo "[WARN] $@" >&2
}

append_unique_existing_filepath() {
    var_name="$1"
    filepath="$2"

    if [[ ! "$filepath" == content/* ]]; then
        return
    fi

    if [[ ! "$var_name" == deleted* && ! -e "$filepath" ]]; then
        return
    fi

    current_value="$(eval "echo \$$var_name")"
    
    if [ -z "$current_value" ]; then
        eval "$var_name=\"$filepath\""
    elif [ "$(echo "$current_value" | grep -c -w "$filepath")" -eq 0 ]; then
        eval "$var_name=\"$current_value:$filepath\""
    fi
}


# Determine the base branch (main or master)
if git show-ref --quiet "refs/remotes/origin/main"; then
  TARGET_BRANCH="origin/main"
elif git show-ref --quiet "refs/remotes/origin/master"; then
  TARGET_BRANCH="origin/master"
else
  error "Neither origin/main nor origin/master found.  Please set TARGET_BRANCH manually and ensure you are on the feature branch."
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
  echo "No commits found that are unique to the current branch compared to $TARGET_BRANCH."
  exit 0
fi

# added or modified 
changed_files=""

# removed or old_file in a renamed action
deleted_files=""


# Iterate through each commit to detect renames and other changes
for commit in $COMMITS; do

  # Detect renames and other changes in this commit
  DIFF=$(git diff --name-status --find-renames -M "$commit^..$commit")

  while IFS= read -r line; do  # Use while loop directly instead of piping
    status=$(echo "$line" | cut -c 1) # Get only the first character

    # Remove the status character and any following whitespace/tabs
    file=$( echo "$line" | sed 's/^[A-Z][[:digit:]]*[[:space:]]*//' )

    case "$status" in
      R)
        # Renamed file:  RNXXX old_path    new_path
        old_file=$(echo "$file" | awk '{print $1}')
        new_file=$(echo "$file" | awk '{print $2}')
        append_unique_existing_filepath "deleted_files" "$old_file"
        append_unique_existing_filepath "changed_files" "$new_file" # Also add the new name
        ;;
      A)
        append_unique_existing_filepath "changed_files" "$file"
        ;;
      M)
        append_unique_existing_filepath "changed_files" "$file"
        ;;
      D)
        append_unique_existing_filepath "deleted_files" "$file"
        ;;
      *)
        # Ignore other status codes (e.g., C for copied)
        debug "== * == $file"
        ;;
    esac
  done <<< "$DIFF"  # Use here-string to avoid subshell
done

debug "changed_files=$changed_files"
debug "deleted_files=$deleted_files"

if [ -n "$changed_files" ]; then
    echo "$changed_files" | tr ':' '\n' > changed_files.txt
fi

if [ -n "$deleted_files" ]; then
    echo "$deleted_files" | tr ':' '\n' > deleted_files.txt
fi
