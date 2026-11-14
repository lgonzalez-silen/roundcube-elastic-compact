#!/bin/bash
# build.sh <roundcube-dir | ssh-host:roundcube-dir>
# Compiles skins/elastic_compact/styles/styles.less into styles.min.css against the Elastic sources of that
# Roundcube install (local path, or fetched over SSH). Rebuild after every Roundcube upgrade: Elastic's styles change.
# Needs Node.js (npx); uses a pinned lessc.
set -euo pipefail
SRC=${1:?usage: build.sh <roundcube-dir | ssh-host:roundcube-dir>}
H=$(cd "$(dirname "$0")" && pwd)
T=$(mktemp -d); trap 'rm -rf -- "${T:?}"' EXIT
mkdir -p "$T/skins/elastic_compact/styles"
if [[ $SRC == *:* ]]; then
  ssh "${SRC%%:*}" "tar -C '${SRC#*:}/skins' -cf - elastic/styles elastic/images" | tar -C "$T/skins" -xf -
else
  tar -C "$SRC/skins" -cf - elastic/styles elastic/images | tar -C "$T/skins" -xf -
fi
cp "$H/skins/elastic_compact/styles/styles.less" "$T/skins/elastic_compact/styles/"
npx -y -p less@4.2.0 lessc --rewrite-urls=all "$T/skins/elastic_compact/styles/styles.less" "$H/skins/elastic_compact/styles/styles.min.css"
echo "built skins/elastic_compact/styles/styles.min.css ($(wc -c < "$H/skins/elastic_compact/styles/styles.min.css") bytes)"
