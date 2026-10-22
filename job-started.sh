#!/usr/bin/env bash
# Job-started hook: free disk by removing old job folders under /_work,
# keeping the current job's workspace and the runner's internal dirs.
set -u
ROOT=/_work
[ -d "$ROOT" ] || exit 0
CUR="${GITHUB_WORKSPACE:-}"
before=$(df -Pm "$ROOT" | awk 'NR==2{print $4}')
removed=0
# Folders the runner manages itself; never touch.
keep_re='^(_actions|_tool|_temp|_PipelineMapping|_update)$'
# Runner workdirs may be /_work/<runner-name>/<repo>/<repo> or /_work/<repo>/<repo>.
for d in "$ROOT"/* "$ROOT"/*/*; do
  [ -d "$d" ] || continue
  name=$(basename "$d")
  [[ "$name" =~ $keep_re ]] && continue
  [[ "$(basename "$(dirname "$d")")" =~ $keep_re ]] && continue
  real=$(readlink -f "$d")
  # Skip the current workspace and any ancestor of it.
  if [ -n "$CUR" ]; then
    curr=$(readlink -f "$CUR")
    [[ "$curr" == "$real" || "$curr" == "$real"/* ]] && continue
  fi
  # Only remove 2nd-level repo dirs, or top-level dirs not containing the workspace.
  case "$real" in "$ROOT"/*) ;; *) continue;; esac
  rm -rf --one-file-system -- "$real" 2>/dev/null && removed=$((removed+1))
done
# _temp is /_work/_temp or /_work/<runner-name>/_temp. A star glob misses
# dotfiles and never matches the runner-name path, so it was not emptied.
shopt -s nullglob
for tempdir in "$ROOT"/_temp "$ROOT"/*/_temp; do
  find "$tempdir" -mindepth 1 -xdev -delete 2>/dev/null || true
done
after=$(df -Pm "$ROOT" | awk 'NR==2{print $4}')
echo "[runner-cleanup] job-started hook: removed ${removed} old job dir(s) under ${ROOT}; free MB ${before} -> ${after}; kept ${CUR:-<none>}"
exit 0
