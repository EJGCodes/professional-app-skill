#!/usr/bin/env bash
# Runs an app-standards hook script with Node.js, falling back to the bash version
# when Node is not installed. Usage: run.sh lint | run.sh stop | run.sh session-start
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
case "$1" in
  lint) JS=(lint.js); SH=(lint.sh) ;;
  stop) JS=(lint.js --stop); SH=(lint.sh --stop) ;;
  session-start) JS=(session-start.js); SH=(session-start.sh) ;;
  *) exit 0 ;;
esac
if command -v node >/dev/null 2>&1; then
  exec node "$DIR/${JS[0]}" "${JS[@]:1}"
fi
exec bash "$DIR/${SH[0]}" "${SH[@]:1}"
