#!/usr/bin/env bash
# tools/lock.sh — record the exact rocks in lua_modules/ into rocks.lock.
#
# LuaRocks' own --pin lockfile is broken for projects where lua itself is
# provided by the VM (it tries to install the interpreter as a rock), so
# the lock is ours: one "name version" per line, installed back with
# --deps-mode=none by tools/setup.sh. See docs/adr/0002.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

[ -x ./luarocks ] || { echo "lock: no ./luarocks wrapper — run tools/setup.sh first" >&2; exit 1; }

{
   echo "# rocks.lock — the exact rocks this project runs, including transitive"
   echo "# dependencies. To regenerate: delete this file, run tools/setup.sh"
   echo "# (fresh resolve from the rockspec), review the diff, commit."
   ./luarocks list --porcelain | awk '{ print $1, $2 }' | sort
} > rocks.lock

echo "wrote rocks.lock ($(grep -cv '^#' rocks.lock) rocks)"
