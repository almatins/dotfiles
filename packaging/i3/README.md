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

- `0002-hide-tab-strip.patch` — the 7-line source patch (against 4.25.1)
- `spec-changes.diff` — the spec edits: `Patch1:`, `Release: 1.fc44.tab1`,
  changelog entry

## State on this machine

- `i3-4.25.1-1.fc44.tab1` and `i3-config-4.25.1-1.fc44.tab1` installed from
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
cp packaging/i3/0002-hide-tab-strip.patch ~/rpmbuild/SOURCES/
patch -p1 -d ~/rpmbuild/SPECS < packaging/i3/spec-changes.diff
rpmbuild -ba ~/rpmbuild/SPECS/i3.spec

# install (config package must match i3's release)
sudo dnf install -y \
  ~/rpmbuild/RPMS/x86_64/i3-4.25.1-1.fc44.tab1.x86_64.rpm \
  ~/rpmbuild/RPMS/noarch/i3-config-4.25.1-1.fc44.tab1.noarch.rpm
sudo dnf versionlock add i3 i3-config

i3-msg restart
```

## When Fedora ships a new i3

1. `sudo dnf versionlock delete i3 i3-config`
2. Fetch the new SRPM (change the version paths above), bump the release suffix
   in the spec (`tab1` → `tab2`) so the local build sorts newer.
3. Re-apply `spec-changes.diff` and the patch. The hunk sits on
   `params.deco_height = render_deco_height();` in `render_con()`; if upstream
   moved it, re-create the patch with `diff -u --label a/src/render.c
   --label b/src/render.c` from a pristine tree.
4. Rebuild, install, versionlock again.

Verified: nested `Xephyr :99` run and a live `stacked` container both report
`deco_rect.height == 0`, and windows use the full height under the bar.
