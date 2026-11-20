# i3 without the tab/stack strip — local patched RPM

This directory contains everything needed to reproduce, on another Fedora
machine, the locally patched i3 that removes the title strip from `stacked`
and `tabbed` containers while keeping the 2 px window border.

- Upstream i3 always draws that strip and has no option to hide it:
  *"The title bar is always visible in stacking and tabbed layouts, and this
  cannot be changed through configuration."*
- Removing it requires patching and rebuilding i3; there is no plugin hook.

Tested with **i3 4.25.1 on Fedora 44**, built from Fedora's own SRPM.

---

## 1. What the patches do

### `0002-hide-tab-strip.patch` — `src/render.c`

```c
/* find the height for the decorations */
params.deco_height = render_deco_height();

+   /* Local patch: no tab/stack strip. */
+   if (con->layout == L_STACKED || con->layout == L_TABBED)
+       params.deco_height = 0;
```

With `deco_height = 0`:

- `render_con_stacked()` / `render_con_tabbed()` give each child the full
  container rect (no rows reserved),
- `deco_rect.height == 0`, so `x_draw_decoration()` skips drawing,
- the container frame ends up unmapped (`src/x.c`, stacked/tabbed branch).

### `0003-no-strip-keep-border.patch` — `src/con.c`

i3 forces `BS_NORMAL` on children of a stacked container with more than one
child (that is how they normally get titlebars). With no titlebar height left,
a `BS_NORMAL` border has no top edge, so the top 2 px border disappeared.
The patch keeps the child's real border style:

```c
if (con->parent->layout == L_STACKED)
    return con->border_style;   /* was: n==1 ? style : BS_NORMAL */

if (con->parent->layout == L_TABBED && con->border_style != BS_NORMAL)
    return con->border_style;
```

### Result / trade-offs

- Stacked and tabbed containers reserve **0 px** for the strip; windows use
  the full height and keep a normal 2 px border on all four sides.
- The strip is no longer clickable: switch windows with `Super+j` / `Super+;`
  (your keymap). Split layouts (`Super+e`, default) are unchanged.
- No visual indication of *other* windows in a stack; a bar window-list module
  is the alternative if that is ever needed.

---

## 2. Requirements

Fedora 44 (adjust `DISTREL` for other releases):

```bash
# packaging tools
sudo dnf install -y rpm-build rpmdevtools curl patch

# i3 build dependencies (after the SRPM is unpacked, see build.sh)
sudo dnf builddep -y ~/rpmbuild/SPECS/i3.spec
```

`builddep` pulls gcc/meson, the xcb/xkbcommon/cairo/pango/yajl/libev
development packages, asciidoc/xmlto and the Perl test modules.

---

## 3. Build (recommended: script)

```bash
cd ~/dotfiles/packaging/i3
./build.sh                 # VERSION=4.25.1 DISTREL=1.fc44 TAB=2
```

The script:

1. downloads `i3-4.25.1-1.fc44.src.rpm` from
   `https://kojipkgs.fedoraproject.org/packages/i3/4.25.1/1.fc44/src/`,
2. installs it into `~/rpmbuild` with `rpm -i --replacepkgs` (always fresh),
3. copies both patches into `~/rpmbuild/SOURCES/`,
4. applies `spec-changes.diff` to the spec and sets
   `Release: 1.fc44.tab2`,
5. runs `rpmbuild -ba` and prints the resulting RPM paths.

Useful overrides:

```bash
TAB=3 ./build.sh            # same i3, newer local release (sorting/upgrade)
DISTREL=1.fc43 ./build.sh   # build for another Fedora release
WORK=/tmp/i3build ./build.sh
```

## 4. Build (manual)

```bash
VERSION=4.25.1; DISTREL=1.fc44; TAB=2
curl -fsSLO "https://kojipkgs.fedoraproject.org/packages/i3/$VERSION/$DISTREL/src/i3-$VERSION-$DISTREL.src.rpm"
rpmdev-setuptree
rpm -i --replacepkgs "i3-$VERSION-$DISTREL.src.rpm"
sudo dnf builddep -y ~/rpmbuild/SPECS/i3.spec

cp packaging/i3/0002-hide-tab-strip.patch packaging/i3/0003-no-strip-keep-border.patch \
  ~/rpmbuild/SOURCES/
patch -p1 -d ~/rpmbuild/SPECS < packaging/i3/spec-changes.diff
sed -i "s/^Release:.*/Release:        ${DISTREL}.tab${TAB}/" ~/rpmbuild/SPECS/i3.spec
rpmbuild -ba ~/rpmbuild/SPECS/i3.spec
```

`spec-changes.diff` adds `Patch1:`/`Patch2:` and the changelog entries; the
`sed` sets the local release (the diff itself says `tab2`).

Output:

```
~/rpmbuild/RPMS/x86_64/i3-4.25.1-1.fc44.tab2.x86_64.rpm
~/rpmbuild/RPMS/noarch/i3-config-4.25.1-1.fc44.tab2.noarch.rpm
```

---

## 5. Install on the target machine

`i3-config` must match the same release (it `Requires: i3 = %{version}-%{release}`):

```bash
sudo dnf install -y \
  ~/rpmbuild/RPMS/x86_64/i3-4.25.1-1.fc44.tab2.x86_64.rpm \
  ~/rpmbuild/RPMS/noarch/i3-config-4.25.1-1.fc44.tab2.noarch.rpm

# keep dnf from replacing the patched build on the next update
sudo dnf versionlock add i3 i3-config

i3-msg restart   # reload the new binary; a plain reload does NOT re-exec i3
```

Check you are running the patched package:

```bash
rpm -q i3                          # 4.25.1-1.fc44.tab2
readlink /proc/$(pgrep -x i3 | head -1)/exe   # /usr/bin/i3
sha256sum /usr/bin/i3
rpm -q --dump i3 | awk '$1=="/usr/bin/i3"{print $4, $5}'   # size, digest
```

---

## 6. Verify the behaviour

### Nested X server (safe, before installing)

```bash
cat > /tmp/test-i3.conf <<'EOF'
font pango:JetBrainsMono Nerd Font 9
default_border pixel 2
EOF
Xephyr :99 -screen 1280x800 &
env -u I3SOCK DISPLAY=:99 /usr/bin/i3 -c /tmp/test-i3.conf &
env -u I3SOCK DISPLAY=:99 alacritty &
env -u I3SOCK DISPLAY=:99 alacritty &
# then:
SOCK=$(DISPLAY=:99 xprop -root -notype I3_SOCKET_PATH | sed 's/.*= //; s/"//g')
i3-msg -s "$SOCK" 'layout stacking'
i3-msg -s "$SOCK" -t get_tree | jq '.. | objects | select(.type=="workspace")
  | .. | objects | select(.window) | {deco: .deco_rect.height, win: .window_rect}'
```

Expect `deco = 0` and `window_rect.y = 2` for both windows.

### Live check

```bash
i3-msg 'layout stacking'
i3-msg -t get_tree | jq -r '.. | objects | select(.window)
  | "deco=\(.deco_rect.height) win=\(.window_rect.x),\(.window_rect.y)"'
```

- no strip: `deco=0`
- border intact: `window_rect.y=2` (was 0 before patch 0003)

Pixel check at the top edge of the focused window: 2 px of the border colour
(`client.focused` border, e.g. `#CBA6F7` in the Catppuccin config) followed by
window content.

---

## 7. Updating when Fedora ships a new i3

1. Find the new SRPM:
   `https://kojipkgs.fedoraproject.org/packages/i3/<version>/<release>/src/`
2. Build with the new versions:
   `VERSION=4.26 DISTREL=1.fc44 TAB=1 ./build.sh`
3. If a patch fails to apply, rebase it against the new tree. The hunks sit on
   - `params.deco_height = render_deco_height();` in `render_con()`
     (`src/render.c`), and
   - the `L_STACKED` / `L_TABBED` branches of `con_border_style()`
     (`src/con.c`).

   Re-create a patch from a pristine tree with:
   ```bash
   diff -u --label a/src/render.c --label b/src/render.c original.c new.c \
     > 0002-hide-tab-strip.patch
   ```
4. Release the versionlock, install the new build, lock again:
   ```bash
   sudo dnf versionlock delete i3 i3-config
   sudo dnf install -y .../i3-<new>.rpm .../i3-config-<new>.rpm
   sudo dnf versionlock add i3 i3-config
   i3-msg restart
   ```

---

## 8. Rollback

```bash
sudo dnf versionlock delete i3 i3-config
sudo dnf distro-sync i3 i3-config     # back to the Fedora build
i3-msg restart
```

No config changes are required for the patch itself; `~/.config/i3/config` can
stay as-is (do not re-add the old `corner-radius`/`title_format` workarounds —
they are unnecessary with this build).

---

## 9. Troubleshooting

| Symptom | Cause / fix |
|---|---|
| `rpmbuild`: `Patch2 ... does not exist` | patches were not copied into `~/rpmbuild/SOURCES/` |
| `%gpgverify` failure | `gnupg2` missing; `sudo dnf install -y gnupg2` |
| `dnf install` refuses with "already installed" | same NEVRA; bump `TAB` (`TAB=3 ./build.sh`) |
| `dnf update` reverted the patch | versionlock missing: `sudo dnf versionlock add i3 i3-config` |
| Strip still visible after install | running i3 is the old binary/session: `i3-msg restart` (not reload) |
| Top border missing again | patch 0003 not applied / spec missing `Patch2:` |
| `dnf versionlock` unavailable | `sudo dnf install -y 'dnf-command(versionlock)'` |

---

## 10. Files in this directory

| File | Purpose |
|---|---|
| `build.sh` | one-shot build: fetch SRPM → patches → RPM |
| `0002-hide-tab-strip.patch` | zero decoration height for stacked/tabbed (`src/render.c`) |
| `0003-no-strip-keep-border.patch` | keep real border style for stack children (`src/con.c`) |
| `spec-changes.diff` | spec edits: `Patch1:`/`Patch2:`, local `Release`, changelog |
| `README.md` | this document |

Built RPMs live in `~/rpmbuild/RPMS/{x86_64,noarch}/` (unsigned local
packages; `dnf` warns about skipped OpenPGP checks, which is expected).
