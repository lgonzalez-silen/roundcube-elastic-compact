# Elastic Compact for Roundcube

A denser desktop layout for Roundcube's Elastic skin, plus two small plugins.

- **Skin `elastic_compact`** (a child skin of Elastic): one line per message in the list, slimmer toolbars and
  header, smaller base font. Phone and touch layouts are left exactly as Elastic ships them.
- **Plugin `elastic_compact`** (only active for users on the skin):
  - a draggable bar between the message list and the preview, height remembered per browser (double-click resets);
  - a "To" column showing the address the message was *delivered to* (bottom-most `Delivered-To`, then
    `X-Original-To`, then `To`), handy when several addresses or forwarded accounts land in one mailbox.
    Skipped where the From/To column already shows To (Sent, Drafts).
- **Plugin `login_refresh`** (any skin): avoids "Invalid request! No data was saved." on the first login attempt.
  Roundcube only accepts a login while the pre-login session that rendered the form still exists; a login page left
  open longer than `session_lifetime` has lost it, so the first submit fails and only the second works. The plugin
  reloads a stale login page before it is used (never while someone is typing).

Tested with Roundcube 1.7.6.

## Install

On the web server, as the user that owns the Roundcube files (usually root):

```
git clone https://github.com/<owner>/roundcube-elastic-compact
cd roundcube-elastic-compact
./install.sh /path/to/roundcube
```

Then add the plugins in `config/config.inc.php`:

```php
$config['plugins'] = [ /* ... */ 'elastic_compact', 'login_refresh'];
```

Users choose the skin in Settings > Preferences > User Interface > Interface skin. To make it the default for
everyone: `$config['skin'] = 'elastic_compact';`. `login_refresh` is independent and useful on any skin.

## After a Roundcube upgrade

The skin is compiled against Elastic's sources, which change between Roundcube versions. Rebuild, then reinstall:

```
./build.sh /path/to/roundcube          # or: ./build.sh user@server:/path/to/roundcube
./install.sh /path/to/roundcube        # on the server
```

`build.sh` needs Node.js (it runs a pinned `lessc` via `npx`). The committed `styles.min.css` is built against the
version listed above.

## Changing the look

Edit `skins/elastic_compact/styles/styles.less`. It imports Elastic's styles and overrides LESS variables (font size,
header and row heights) plus a block of rules for desktop layouts only. Then run `build.sh` and `install.sh`.

## License

- `skins/elastic_compact/` is derived from Roundcube's Elastic skin and is licensed, like Elastic, under
  [CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/); see its [README](skins/elastic_compact/README.md).
- Everything else (the plugins, `build.sh`, `install.sh`) is MIT; see [LICENSE](LICENSE).
