#!/bin/bash
set -euo pipefail
export PATH="/usr/local/bin:/opt/homebrew/bin:/Users/user/.nvm/versions/node/v24.14.0/bin:/usr/bin:/bin"
export HOME="/Users/user"
mkdir -p /Users/user/night-shift/logs
hour=$(date '+%H')
if [ "$hour" = "23" ]; then
  /Users/user/night-shift/start_night_shift.sh >> /Users/user/night-shift/logs/launchd.log 2>&1
else
  /Users/user/night-shift/round_executor.sh auto >> /Users/user/night-shift/logs/launchd.log 2>&1
fi
