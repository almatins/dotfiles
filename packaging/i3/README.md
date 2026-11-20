# i3: no tab/stack strip (locally patched RPM)

i3 always draws a title strip inside `stacked`/`tabbed` containers and has no
option to hide it ("The title bar is always visible in stacking and tabbed
layouts, and this cannot be changed through configuration"). This patch sets
the decoration height to 0 for those layouts in `src/render.c`, which:

- makes `render_con_stacked()` / `render_con_tabbed()` give each child the
  full container rect (no reserved rows),
- leaves `deco_rect.height == 0`, so `x_draw_decoration()` skips drawing,
- makes the stacked/tabbed container frame unmapped (`src/x.c`).

Trade-off: windows in stacked/tabbed containers can then only be switched with
the keyboard (`Super+j` / `Super+;`); the strip is no longer clickable. Split
layouts and everything else are unchanged.

## Files here

- `0002-hide-tab-strip.patch` — zeroes the decoration height for stacked/tabbed
  (`render_con()` in `src/render.c`)
- `0003-no-strip-keep-border.patch` — stops `con_border_style()` from forcing
  `BS_NORMAL` on children of a multi-child stack; without it the top border
  disappears (normal borders expect a titlebar area)
- `spec-changes.diff` — the spec edits: `Patch1:`/`Patch2:`,
  `Release: 1.fc44.tab2`, changelog entries

## State on this machine

- `i3-4.25.1-1.fc44.tab2` and `i3-config-4.25.1-1.fc44.tab2` installed from
  `~/rpmbuild/RPMS/` (unsigned, local)
- versionlocked, so `dnf update` will not silently replace the patched build:
  `sudo dnf versionlock delete i3 i3-config` to release the lock
- `~/.config/i3/config` is back to the normal settings (font 9, no
  `title_format` hack) — the strip is gone because of the patch, not config

## Rebuild

```bash
# once: tooling + build dependencies
sudo dnf install -y rpm-build rpmdevtools
curl -sLO https://kojipkgs.fedoraproject.org/packages/i3/4.25.1/1.fc44/src/i3-4.25.1-1.fc44.src.rpm
rpmdev-setuptree
rpm -i --replacepkgs i3-4.25.1-1.fc44.src.rpm
sudo dnf builddep -y ~/rpmbuild/SPECS/i3.spec

# every build: patch the spec and add the source patch
cp packaging/i3/0002-hide-tab-strip.patch packaging/i3/0003-no-strip-keep-border.patch \
  ~/rpmbuild/SOURCES/
patch -p1 -d ~/rpmbuild/SPECS < packaging/i3/spec-changes.diff
rpmbuild -ba ~/rpmbuild/SPECS/i3.spec

# install (config package must match i3's release)
sudo dnf install -y \
  ~/rpmbuild/RPMS/x86_64/i3-4.25.1-1.fc44.tab2.x86_64.rpm \
  ~/rpmbuild/RPMS/noarch/i3-config-4.25.1-1.fc44.tab2.noarch.rpm
sudo dnf versionlock add i3 i3-config

i3-msg restart
```

## When Fedora ships a new i3

1. `sudo dnf versionlock delete i3 i3-config`
2. Fetch the new SRPM (change the version paths above), bump the release suffix
   in the spec (`tab2` → `tab3`) so the local build sorts newer.
3. Re-apply `spec-changes.diff` and both patches. The hunks sit on
   `params.deco_height = render_deco_height();` in `render_con()` and on the
   `L_STACKED`/`L_TABBED` branches of `con_border_style()`; if upstream moved
   them, re-create the patches with `diff -u --label a/src/<file>
   --label b/src/<file>` from a pristine tree.
4. Rebuild, install, versionlock again.

Verified: nested `Xephyr :99` run and a live `stacked` container both report
`deco_rect.height == 0`, the windows use the full height under the bar, and
with the second patch `window_rect.y == 2` with a 2 px border on all sides.
