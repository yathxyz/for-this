#!/usr/bin/env bash
# Force-recompile the vile system inside Lem, dumping full compiler
# diagnostics to /tmp/vile-compile.log (the TUI swallows them otherwise).
set -uo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$here/scripts/tui-driver.sh"

rm -f /tmp/vile-compile.log
lem_start vile-compile -q --eval "'(load \"/tmp/vile-compile-check.lisp\")'"
for _ in $(seq 1 240); do
  [ -f /tmp/vile-compile.log ] && grep -qE 'LOAD OK|TOP-ERROR' /tmp/vile-compile.log && break
  sleep 0.5
done
lem_stop vile-compile
cat /tmp/vile-compile.log 2>/dev/null || echo "no log produced"
