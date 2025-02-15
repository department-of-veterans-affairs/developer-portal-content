#!/bin/sh

# Debug function
debug() {
  echo "[DEBUG] $@" >&2  # Redirect to stderr
}

append_unique_existing_filepath() {
    var_name="$1"
    filepath="$2"

    if [[ ! "$var_name" == deleted* && ! -e "$filepath" ]]; then
        debug "Filepath does not exist: $filepath"
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
  echo "Neither origin/main nor origin/master found.  Please set TARGET_BRANCH manually and ensure you are on the feature branch."
  exit 1
fi

# Get the name of the current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Check if we are on a detached HEAD
if [ "$CURRENT_BRANCH" = "HEAD" ]; then
    echo "You are in a detached HEAD state. Please checkout a branch to continue."
    exit 1
fi

debug "TARGET_BRANCH:  $TARGET_BRANCH"
debug "CURRENT_BRANCH: $CURRENT_BRANCH"


# Get the list of commits unique to the current branch.
COMMITS=$(git rev-list --no-merges "$TARGET_BRANCH..$CURRENT_BRANCH")

debug "Commits found: $COMMITS"

if [ -z "$COMMITS" ]; then
  echo "No commits found that are unique to the current branch compared to $TARGET_BRANCH."
  exit 0
fi

added_files=""
deleted_files=""
renamed_files=""
modified_files=""

# Iterate through each commit to detect renames and other changes
for commit in $COMMITS; do
  echo
  echo
  debug "Processing commit: $commit"

  # Detect renames and other changes in this commit
  DIFF=$(git diff --name-status --find-renames -M "$commit^..$commit")
  debug "Diff output: $DIFF"

  while IFS= read -r line; do  # Use while loop directly instead of piping
    echo
    status=$(echo "$line" | cut -c 1) # Get only the first character

    # Remove the status character and any following whitespace/tabs
    file=$(echo "$line" | sed 's/^[A-Z][[:digit:]]*[[:space:]]*//')

    debug "Line: $line"
    debug "Status: \"$status\""
    debug "File: $file"

    case "$status" in
      R)
        # Renamed file:  RNXXX old_path    new_path
        old_file=$(echo "$file" | awk '{print $1}')
        new_file=$(echo "$file" | awk '{print $2}')
        append_unique_existing_filepath "renamed_files" "$old_file > $new_file"  # Store as new:old
        append_unique_existing_filepath "deleted_files" "$old_file"
        append_unique_existing_filepath "added_files" "$new_file" # Also add the new name
        debug "== R == $file"
        debug "old_file: $old_file"
        debug "new_file: $new_file"
        debug "renamed_files: $renamed_files"
        debug "deleted_files: $deleted_files"
        debug "added_filtes: $added_files"
        ;;
      A)
        append_unique_existing_filepath "added_files" "$file"
        debug "== A == $file"
        debug "added_filtes: $added_files"
        ;;
      M)
        append_unique_existing_filepath "modified_files" "$file"
        debug "== M == $file"
        debug "modified_files: $modified_files"
        ;;
      D)
        append_unique_existing_filepath "deleted_files" "$file"
        debug "== D == $file"
        debug "deleted_files: $deleted_files"
        ;;
      *)
        # Ignore other status codes (e.g., C for copied)
        debug "== * == $file"
        ;;
    esac
  done <<< "$DIFF"  # Use here-string to avoid subshell
done

echo
echo "added_files=$added_files"
echo
echo "deleted_files=$deleted_files"
echo
echo "renamed_files=$renamed_files"
echo
echo "modified_files=$modified_files"
echo

