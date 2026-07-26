#!/usr/bin/env bash
# Apply sc-im source patches to a checkout. Usage: ./apply.sh <sc-im-src-dir>
# Base commit: b564571
set -euo pipefail
src="${1:?usage: apply.sh <sc-im-src-dir>}"
here="$(dirname "$(readlink -f "$0")")"
cd "$src"
for p in "$here"/0*.patch; do
  echo "applying $(basename "$p")"
  git apply "$p"
done
echo "done. build with: cd src && make YACC='bison -y' && make install prefix=\$HOME/.local"
