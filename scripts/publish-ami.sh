#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 ami-id" >&2
  exit 64
fi

AMI_ID="$1"
LATEST_PARAM="${LATEST_PARAM:-/golden-edge-ami/latest}"
PREVIOUS_PARAM="${PREVIOUS_PARAM:-/golden-edge-ami/previous}"

CURRENT_AMI="$(
  aws ssm get-parameter --name "$LATEST_PARAM" --query 'Parameter.Value' --output text 2>/dev/null || true
)"

if [[ -n "$CURRENT_AMI" && "$CURRENT_AMI" != "None" ]]; then
  aws ssm put-parameter \
    --name "$PREVIOUS_PARAM" \
    --type String \
    --value "$CURRENT_AMI" \
    --overwrite >/dev/null
fi

aws ssm put-parameter \
  --name "$LATEST_PARAM" \
  --type String \
  --value "$AMI_ID" \
  --overwrite >/dev/null

echo "published $AMI_ID to $LATEST_PARAM"
