#!/bin/bash
# -------------------------------------------------------------------
# Simple Load Test Script using curl
# Author: leo26dandy
# -------------------------------------------------------------------

# Usage: ./loadtest.sh <url> [requests] [concurrency]
# Example: ./loadtest.sh https://example.com 100 10

# Defaults
URL="$1"
TOTAL_REQUESTS="${2:-100}"
CONCURRENCY="${3:-10}"

if [[ -z "$URL" ]]; then
  echo "Usage: $0 <url> [requests=100] [concurrency=10]"
  exit 1
fi

# Variables
SUCCESS=0
FAILED=0
START_TIME=$(date +"%Y-%m-%d %H:%M:%S")
LOG_FILE="loadtest_$(date +'%Y%m%d_%H%M%S').log"

# -------------------------------------------------------------------
# Function to perform a single request
# -------------------------------------------------------------------
make_request() {
  local result
  result=$(curl -s -o /dev/null -w "%{http_code}" "$URL")
  if [[ "$result" == "200" || "$result" == "301" || "$result" == "302" ]]; then
    echo "SUCCESS ($result)" >> "$LOG_FILE"
  else
    echo "FAIL ($result)" >> "$LOG_FILE"
  fi
}

# -------------------------------------------------------------------
# Main loop using parallel background jobs
# -------------------------------------------------------------------
echo "-----------------------------------------------------"
echo "Starting load test at: $START_TIME"
echo "Target URL          : $URL"
echo "Total Requests      : $TOTAL_REQUESTS"
echo "Concurrency Level   : $CONCURRENCY"
echo "-----------------------------------------------------"

# Run requests in parallel batches
for ((i=1; i<=TOTAL_REQUESTS; i++)); do
  make_request &
  # Limit concurrency
  if (( i % CONCURRENCY == 0 )); then
    wait
  fi
done
wait

# -------------------------------------------------------------------
# Generate summary
# -------------------------------------------------------------------
SUCCESS=$(grep -c "SUCCESS" "$LOG_FILE")
FAILED=$(grep -c "FAIL" "$LOG_FILE")

END_TIME=$(date +"%Y-%m-%d %H:%M:%S")

echo "-----------------------------------------------------"
echo "Load Test Completed!"
echo "Start Time : $START_TIME"
echo "End Time   : $END_TIME"
echo "Success    : $SUCCESS"
echo "Failed     : $FAILED"
echo "Log File   : $LOG_FILE"
echo "-----------------------------------------------------"

# -------------------------------------------------------------------
# Example result
# -------------------------------------------------------------------

# -----------------------------------------------------
# Starting load test at: 2025-10-07 16:41:22
# Target URL          : https://example.com
# Total Requests      : 100
# Concurrency Level   : 10
# -----------------------------------------------------
# -----------------------------------------------------
# Load Test Completed!
# Start Time : 2025-10-07 16:41:22
# End Time   : 2025-10-07 16:41:45
# Success    : 94
# Failed     : 6
# Log File   : loadtest_20251007_164122.log
# -----------------------------------------------------
