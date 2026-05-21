#!/usr/bin/env bash
set -euo pipefail

LATEST_PARAM="${LATEST_PARAM:-/golden-edge-ami/latest}"
PREVIOUS_PARAM="${PREVIOUS_PARAM:-/golden-edge-ami/previous}"

PREVIOUS_AMI="$(
  aws ssm get-parameter --name "$PREVIOUS_PARAM" --query 'Parameter.Value' --output text
)"

if [[ -z "$PREVIOUS_AMI" || "$PREVIOUS_AMI" == "None" ]]; then
  echo "no previous AMI found in $PREVIOUS_PARAM" >&2
  exit 1
fi

aws ssm put-parameter \
  --name "$LATEST_PARAM" \
  --type String \
  --value "$PREVIOUS_AMI" \
  --overwrite >/dev/null

echo "rolled $LATEST_PARAM back to $PREVIOUS_AMI"
