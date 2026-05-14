#!/bin/bash
set -euo pipefail
export PATH="/usr/local/bin:/opt/homebrew/bin:/Users/user/.nvm/versions/node/v24.14.0/bin:/usr/bin:/bin"
export HOME="/Users/user"
mkdir -p /Users/user/night-shift/logs
/Users/user/night-shift/safety_guardian.sh >> /Users/user/night-shift/logs/safety-launchd.log 2>&1
