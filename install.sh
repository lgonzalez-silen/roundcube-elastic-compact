#!/bin/bash
# install.sh <roundcube-dir>   Run on the web server, as the user that owns the Roundcube files (usually root).
# Installs the Elastic Compact skin and the elastic_compact + login_refresh plugins into that Roundcube.
# Then add 'elastic_compact', 'login_refresh' to $config['plugins'] in config/config.inc.php.
# Re-run after every Roundcube upgrade (after ./build.sh), since it copies two files from that version's Elastic.
set -euo pipefail
RC=${1:?usage: install.sh <roundcube-dir>}
H=$(cd "$(dirname "$0")" && pwd)
test -f "$RC/skins/elastic/templates/includes/layout.html" || { echo "no Elastic skin under $RC/skins"; exit 1; }
D="$RC/skins/elastic_compact"
rm -rf -- "${D:?}.new"; mkdir -p "$D.new/styles" "$D.new/templates/includes"
cp "$H/skins/elastic_compact/meta.json" "$H/skins/elastic_compact/README.md" "$D.new/"
cp "$H/skins/elastic_compact/styles/styles.min.css" "$D.new/styles/"
cp "$RC/skins/elastic/thumbnail.png" "$D.new/"
# Roundcube resolves a template's assets in the skin the template came from first, so the child skin needs its own
# copy of Elastic's page skeleton (unchanged) for styles/styles.css to resolve to this skin's.
cp "$RC/skins/elastic/templates/includes/layout.html" "$D.new/templates/includes/"
for n in elastic_compact login_refresh; do
  P="$RC/plugins/$n"
  rm -rf -- "${P:?}.new"; cp -R "$H/plugins/$n" "$P.new"
  php -l "$P.new/$n.php" >/dev/null && echo "plugin $n OK"
  rm -rf -- "${P:?}"; mv "$P.new" "$P"
done
rm -rf -- "${D:?}"; mv "$D.new" "$D"
if [ "$(id -u)" = 0 ]; then chown -R root:root "$D" "$RC/plugins/elastic_compact" "$RC/plugins/login_refresh"; fi
if command -v restorecon >/dev/null; then restorecon -R "$D" "$RC/plugins/elastic_compact" "$RC/plugins/login_refresh"; fi
echo "installed into $RC. Plugins list needs: 'elastic_compact', 'login_refresh'. Users choose the skin in"
echo "Settings > Preferences > User Interface > Interface skin (or set \$config['skin'] = 'elastic_compact')."
