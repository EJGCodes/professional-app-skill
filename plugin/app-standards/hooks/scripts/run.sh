#!/usr/bin/env bash
# Runs an app-standards hook script with Node.js, falling back to the bash version
# when Node is not installed. Usage: run.sh lint | run.sh session-start
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NAME="$1"
case "$NAME" in
  lint|session-start) ;;
  *) exit 0 ;;
esac
if command -v node >/dev/null 2>&1; then
  exec node "$DIR/$NAME.js"
fi
exec bash "$DIR/$NAME.sh"
