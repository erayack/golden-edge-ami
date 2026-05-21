#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 asg-name" >&2
  exit 64
fi

ASG_NAME="$1"
SLEEP_SECONDS="${SLEEP_SECONDS:-15}"
TIMEOUT_SECONDS="${TIMEOUT_SECONDS:-900}"
STARTED_AT="$(date +%s)"

while true; do
  STATUS="$(
    aws autoscaling describe-instance-refreshes \
      --auto-scaling-group-name "$ASG_NAME" \
      --query 'InstanceRefreshes[0].Status' \
      --output text
  )"

  case "$STATUS" in
    Successful)
      echo "instance refresh successful"
      exit 0
      ;;
    Failed | Cancelled)
      echo "instance refresh ended with status: $STATUS" >&2
      exit 1
      ;;
    None)
      echo "no instance refresh found for $ASG_NAME" >&2
      exit 1
      ;;
  esac

  NOW="$(date +%s)"
  if ((NOW - STARTED_AT > TIMEOUT_SECONDS)); then
    echo "timed out waiting for instance refresh; last status: $STATUS" >&2
    exit 1
  fi

  echo "waiting for instance refresh: $STATUS"
  sleep "$SLEEP_SECONDS"
done
