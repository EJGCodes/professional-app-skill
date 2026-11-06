#!/usr/bin/env bash
# Runs an app-standards hook script with Node.js, falling back to the bash version
# when Node is not installed. Usage: run.sh lint | run.sh stop | run.sh session-start
# The lint script lives in the standards skill so it is available wherever the skill is.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LINT="$(cd "$DIR/../../skills/standards/scripts" && pwd)"
case "$1" in
  lint) JS=("$LINT/lint.js"); SH=("$LINT/lint.sh") ;;
  stop) JS=("$LINT/lint.js" --stop); SH=("$LINT/lint.sh" --stop) ;;
  session-start) JS=("$DIR/session-start.js"); SH=("$DIR/session-start.sh") ;;
  *) exit 0 ;;
esac
if command -v node >/dev/null 2>&1; then
  exec node "${JS[@]}"
fi
exec bash "${SH[@]}"
