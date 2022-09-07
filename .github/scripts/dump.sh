#!/usr/bin/env bash

# Use sqlite3 to print all tables but since it's in multi column print, we
# tr: replace all spaces with newlines
# sort: Sort alphabetically
# uniq: Remove duplicates
# awk: Remove empty lines
TABLES="$(sqlite3 "$1" .table | tr " " "\n" | sort | uniq | awk NF)"

while IFS= read -r TABLE; do
  printf "Dumping %-50s" "$TABLE.csv... "

  # Skip if table name starts with number
  if [[ "${TABLE::1}" =~ ^[0-9] ]]; then
    printf "Weird! Skipping. \n"
    continue
  fi

  CONTENT="$(sqlite3 -header "$1" "SELECT * FROM $TABLE" -csv)"
  if [[ "$CONTENT" ]]; then
     echo "$CONTENT" > "$TABLE.csv"
     printf "OK. \n"
     continue
  fi

  printf "Empty! Skipped. \n"
done <<< "$TABLES"

echo "Finished dumping $1"
