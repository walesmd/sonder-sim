#!/usr/bin/env bash
# tools/setup.sh — build the pinned Sonder toolchain from a fresh clone.
#
# Everything lands inside the repo: LuaRocks in .toolchain/, dependencies
# in lua_modules/, wrapper scripts ./lua and ./luarocks in the root.
# Nothing outside the repo is installed or modified. Idempotent — run it
# again any time.
#
# Why not `brew install luarocks`: that formula depends on Homebrew's
# `lua`, which is 5.5 — it would install a second Lua next to our pinned
# 5.4 (docs/adr/0001) and default LuaRocks to the wrong interpreter.
# See docs/adr/0002.
set -euo pipefail

LUAROCKS_VERSION="3.13.0"
LUAROCKS_SHA256="245bf6ec560c042cb8948e3d661189292587c5949104677f1eecddc54dbe7e37"
LUAROCKS_URL="https://luarocks.github.io/luarocks/releases/luarocks-${LUAROCKS_VERSION}.tar.gz"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

say()  { printf '\033[1m== %s\033[0m\n' "$*"; }
fail() { printf 'setup: %s\n' "$*" >&2; exit 1; }

# ---------------------------------------------------------------------------
say "Locating Lua 5.4"

LUA_DIR=""
if command -v brew >/dev/null 2>&1; then
   candidate="$(brew --prefix lua@5.4 2>/dev/null || true)"
   [ -n "$candidate" ] && [ -x "$candidate/bin/lua" ] && LUA_DIR="$candidate"
fi
if [ -z "$LUA_DIR" ]; then
   # No Homebrew keg; accept a lua on PATH if (and only if) it is 5.4.
   for name in lua5.4 lua; do
      command -v "$name" >/dev/null 2>&1 || continue
      "$name" -v 2>&1 | grep -q '^Lua 5\.4' || continue
      LUA_DIR="$(dirname "$(dirname "$(realpath "$(command -v "$name")")")")"
      break
   done
fi
[ -n "$LUA_DIR" ] || fail "Lua 5.4 not found. On macOS: brew install lua@5.4
(Homebrew's plain 'lua' is 5.5 — that is not the one, see docs/adr/0001.)"

"$LUA_DIR/bin/lua" -v 2>&1 | grep -q '^Lua 5\.4' \
   || fail "$LUA_DIR/bin/lua is not Lua 5.4: $("$LUA_DIR/bin/lua" -v 2>&1)"
echo "   $LUA_DIR ($("$LUA_DIR/bin/lua" -v 2>&1))"

LUA_INCDIR="$LUA_DIR/include"
[ -f "$LUA_DIR/include/lua5.4/lua.h" ] && LUA_INCDIR="$LUA_DIR/include/lua5.4"
[ -f "$LUA_INCDIR/lua.h" ] || fail "lua.h not found under $LUA_DIR/include"

# ---------------------------------------------------------------------------
say "Locating SQLite (for the lsqlite3 build)"

SQLITE_DIR=""
if command -v brew >/dev/null 2>&1; then
   candidate="$(brew --prefix sqlite 2>/dev/null || true)"
   [ -n "$candidate" ] && [ -f "$candidate/include/sqlite3.h" ] && SQLITE_DIR="$candidate"
fi
if [ -z "$SQLITE_DIR" ] && [ -f /usr/include/sqlite3.h ]; then
   SQLITE_DIR="/usr"
fi
[ -n "$SQLITE_DIR" ] || fail "SQLite headers not found. On macOS: brew install sqlite"
echo "   $SQLITE_DIR"

# ---------------------------------------------------------------------------
say "LuaRocks $LUAROCKS_VERSION -> .toolchain/"

if [ -x .toolchain/bin/luarocks ] \
   && .toolchain/bin/luarocks --version | grep -q " $LUAROCKS_VERSION\$"; then
   echo "   already built, skipping"
else
   tmp="$(mktemp -d)"
   trap 'rm -rf "$tmp"' EXIT
   curl -fsSL -o "$tmp/luarocks.tar.gz" "$LUAROCKS_URL"
   echo "$LUAROCKS_SHA256  $tmp/luarocks.tar.gz" | shasum -a 256 -c - >/dev/null \
      || fail "luarocks tarball checksum mismatch — refusing to build it"
   tar -xzf "$tmp/luarocks.tar.gz" -C "$tmp"
   (
      cd "$tmp/luarocks-$LUAROCKS_VERSION"
      ./configure --prefix="$ROOT/.toolchain" \
                  --with-lua="$LUA_DIR" \
                  --with-lua-include="$LUA_INCDIR" >/dev/null
      make >/dev/null
      make install >/dev/null
   )
   echo "   built and installed"
fi

# ---------------------------------------------------------------------------
say "Project rocks tree (luarocks init)"

.toolchain/bin/luarocks init --lua-version=5.4 --lua-dir="$LUA_DIR"

# ---------------------------------------------------------------------------
say "Dependencies"

# LuaRocks' --pin lockfiles fail when lua is provided by the VM (it tries
# to install the interpreter as a rock), so rocks.lock is our own: exact
# "name version" lines, installed with the resolver switched off.
if [ -f rocks.lock ]; then
   installed="$(./luarocks list --porcelain || true)"
   grep -v '^#' rocks.lock | while read -r name version; do
      [ -n "$name" ] || continue
      if printf '%s\n' "$installed" \
         | awk -v n="$name" -v v="$version" '$1 == n && $2 == v { found = 1 } END { exit !found }'; then
         echo "   $name $version (already installed)"
      else
         ./luarocks install --deps-mode=none "$name" "$version" "SQLITE_DIR=$SQLITE_DIR"
      fi
   done
else
   echo "   no rocks.lock — resolving fresh from the rockspec, then locking"
   ./luarocks build --only-deps sonder-0.2.5-1.rockspec "SQLITE_DIR=$SQLITE_DIR"
   tools/lock.sh
fi

# The tree must match the lock exactly — extra or drifted rocks fail here.
actual="$(./luarocks list --porcelain | awk '{ print $1, $2 }' | sort)"
locked="$(grep -v '^#' rocks.lock | sort)"
[ "$actual" = "$locked" ] \
   || fail "installed rocks do not match rocks.lock:
$(diff <(printf '%s\n' "$locked") <(printf '%s\n' "$actual") || true)"

# ---------------------------------------------------------------------------
say "Doctor"

./lua tools/doctor.lua
