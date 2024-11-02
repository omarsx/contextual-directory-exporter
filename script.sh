#!/usr/bin/env bash

# This script exports the directory structure to a JSON file with metadata.

# Ensure the script is executed with Bash
if [ -z "$BASH_VERSION" ]; then
  echo "This script requires Bash. Please run it with Bash: bash script.sh"
  exit 1
fi

# Exit on any error
set -e

# Check for required utilities
if ! command -v tree &>/dev/null; then
  echo "Error: 'tree' utility is not installed. Install it using 'brew install tree' or your package manager."
  exit 1
fi

if ! command -v jq &>/dev/null; then
  echo "Error: 'jq' utility is not installed. Install it using 'brew install jq' or your package manager."
  exit 1
fi

# Function to display an error message and exit
error_exit() {
  echo "Error: $1"
  exit 1
}

# Prompt for source directory
read -rp "Enter the source directory: " SRC_DIR
if [ ! -d "$SRC_DIR" ]; then
  error_exit "Source directory does not exist."
fi

# Prompt for target directory
read -rp "Enter the target directory for the export: " TARGET_DIR
if [ ! -d "$TARGET_DIR" ]; then
  read -rp "Target directory does not exist. Create it? (y/n): " RESP
  if [[ "$RESP" =~ ^[Yy]$ ]]; then
    if ! mkdir -p "$TARGET_DIR"; then
      error_exit "Failed to create target directory."
    fi
  else
    error_exit "Target directory is required."
  fi
fi

# Define output filename
FILENAME="directory_export_$(TZ='Asia/Karachi' date '+%b_%d__%I-%M-%p_PKT').json"
OUTPUT_FILE="$TARGET_DIR/$FILENAME"

# Define patterns to exclude
EXCLUDE_PATTERNS='node_modules|debug|\.git|dist|build|target|coverage|logs'

# Generate directory structure
echo "Generating directory structure..."
if ! tree -J "$SRC_DIR" -I "$EXCLUDE_PATTERNS" > /tmp/dir_structure.json; then
  error_exit "Failed to generate directory structure."
fi

# Split the EXCLUDE_PATTERNS into an array
IFS='|' read -r -a patterns <<<"$EXCLUDE_PATTERNS"

# Find skipped directories and counts
echo "Analyzing skipped directories..."
declare -A SKIPPED_DIRS_COUNTS

for pattern in "${patterns[@]}"; do
  # Remove leading backslash if present
  pattern="${pattern#\\}"
  # Find directories matching the pattern
  while IFS= read -r dir; do
    dir_name=$(basename "$dir")
    count=$(find "$dir" -type f 2>/dev/null | wc -l)
    if [[ -n "${SKIPPED_DIRS_COUNTS[$dir_name]}" ]]; then
      SKIPPED_DIRS_COUNTS[$dir_name]=$((SKIPPED_DIRS_COUNTS[$dir_name] + count))
    else
      SKIPPED_DIRS_COUNTS[$dir_name]=$count
    fi
  done < <(find "$SRC_DIR" -type d -name "$pattern" 2>/dev/null)
done

# Prepare skipped directories JSON
SKIPPED_INFO_JSON=$(jq -n '[]')
for dir_name in "${!SKIPPED_DIRS_COUNTS[@]}"; do
  count=${SKIPPED_DIRS_COUNTS[$dir_name]}
  SKIPPED_INFO_JSON=$(echo "$SKIPPED_INFO_JSON" | jq --arg dir "$dir_name" --argjson count "$count" '. += [{"name": $dir, "skipped_file_count": $count}]')
done

# Get current timestamp with timezone and milliseconds
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")

# Gather metadata
METADATA=$(jq -n \
  --arg timestamp "$TIMESTAMP" \
  --arg src_dir "$SRC_DIR" \
  --arg target_dir "$TARGET_DIR" \
  --arg filename "$FILENAME" \
  --argjson skipped_dirs "$SKIPPED_INFO_JSON" \
  '{
    "generation_timestamp": $timestamp,
    "source_directory": $src_dir,
    "target_directory": $target_dir,
    "output_filename": $filename,
    "skipped_directories": $skipped_dirs
  }')

# Combine directory structure with metadata
echo "Combining data into final JSON..."
# Determine if the directory structure is an array or an object
FIRST_CHAR=$(head -c 1 /tmp/dir_structure.json)
if [ "$FIRST_CHAR" = "[" ]; then
  # The directory structure is an array
  if ! jq --argjson metadata "$METADATA" '{ "directory_structure": ., "metadata": $metadata }' /tmp/dir_structure.json >"$OUTPUT_FILE"; then
    error_exit "Failed to create final JSON output."
  fi
else
  # The directory structure is an object
  if ! jq --argjson metadata "$METADATA" '.metadata = $metadata' /tmp/dir_structure.json >"$OUTPUT_FILE"; then
    error_exit "Failed to create final JSON output."
  fi
fi

# Clean up temporary file
rm /tmp/dir_structure.json