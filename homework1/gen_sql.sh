#!/bin/bash

if [ -n "$1" ]; then
  DBMS="$1"
else
  echo "Error: Please specify the database system type as a command-line argument."
  echo "Usage: $0 <DBMS_TYPE>"
  echo "Allowed DBMS types: duckdb, sqlite"
  echo "Example: $0 duckdb"
  exit 1
fi

allowed_dbms=("duckdb" "sqlite")
is_valid_dbms=false

for valid_dbms in "${allowed_dbms[@]}"; do
  if [ "$DBMS" = "$valid_dbms" ]; then
    is_valid_dbms=true
    break 
  fi
done

if [ "$is_valid_dbms" = false ]; then
  echo "Error: Invalid DBMS type specified: '$DBMS'."
  echo "Allowed DBMS types are: duckdb, sqlite."
  exit 1
fi

file_prefixes=(
  "myq1_sample"
  "myq2_successful_coaches"
  "myq3_Judo_athlete_medals"
  "myq4_Athletics_venue_athletes"
  "myq5_top5_rank_country_per_day"
  "myq6_big_progress_country_female_teams"
)

for prefix in "${file_prefixes[@]}"; do
  filename="${prefix}.${DBMS}.sql"
  touch "$filename"
  echo "Created file: $filename"
done

echo "Batch file creation complete."

