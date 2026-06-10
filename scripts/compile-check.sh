#!/usr/bin/env bash
# Force-recompile the vile system inside Lem, dumping full compiler
# diagnostics to a log (the TUI swallows them otherwise).
# Safe to run concurrently: names are unique per invocation.
set -uo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$here/scripts/tui-driver.sh"

id="${VILE_CHECK_ID:-$$}"
session="vile-compile-$id"
log="/tmp/vile-compile-$id.log"
form="/tmp/vile-compile-check-$id.lisp"

cat > "$form" <<EOF
(with-open-file (s "$log" :direction :output :if-exists :supersede)
  (let ((*error-output* s)
        (*standard-output* s))
    (handler-case
        (progn
          (asdf:load-asd #P"$here/lem-vile/vile.asd")
          (asdf:load-system "vile" :force t)
          (format s "~%LOAD OK~%"))
      (error (e) (format s "~%TOP-ERROR: ~a~%" e)))
    (finish-output s)))
EOF

rm -f "$log"
lem_start "$session" -q --eval "'(load \"$form\")'"
for _ in $(seq 1 240); do
  [ -f "$log" ] && grep -qE 'LOAD OK|TOP-ERROR' "$log" && break
  sleep 0.5
done
lem_stop "$session"
cat "$log" 2>/dev/null || echo "no log produced"
grep -q 'LOAD OK' "$log" 2>/dev/null
