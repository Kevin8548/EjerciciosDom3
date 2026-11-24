#!/usr/bin/env bash
jq -n --arg t "$1" '{text:$t}' | curl -sS -X POST -H 'Content-type: application/json' -d @- "$SLACK_WEBHOOK_URL"