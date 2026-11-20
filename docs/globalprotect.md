# GlobalProtect (Palo Alto) on this machine

Installed from the IT bundle `PanGPLinux-6.3.3-c31` (external SSD copy kept at
`~/Downloads/vpn/PanGPLinux-6.3.3-c31/`). The bundle contains `gp_install.sh`,
`gp_uninstall.sh`, `GlobalProtect_UI_rpm-6.3.3.1-638.rpm` (GUI, the one used),
`GlobalProtect_rpm-6.3.3.1-638.rpm` (CLI-only variant) and arm/aarch64/deb
variants.

Installed version: **GlobalProtect 6.3.3-638** (`GlobalProtect_UI_rpm`).

## Components

| Piece | What it is |
|---|---|
| `gpd.service` (system) | root daemon `PanGPS`, listens on 127.0.0.1:4767 |
| `gpa.service` (user) | per-user agent `PanGPA`, bridges UI/CLI to the daemon |
| `PanGPUI` | Qt tray icon + window (`globalprotect launch-ui`) |
| `globalprotect` CLI | `show --version`, `launch-ui`, `collect-log`, `import-certificate` |

Dependencies installed for the UI: `qt5-qtwebengine`, `qt5-qtwebengine-devel`,
`wmctrl`.

Portal: `vpn-esdm.gpcloudservice.com` — Prisma Access with Okta SAML SSO
(POST binding). Login happens in a browser, not with a local password.

## Why the gpa.service drop-in

`gpa.service` ships with `Restart=on-failure`, but PanGPA sometimes exits
cleanly (status 0) at login, so systemd never restarts it and the tray window
then reports *"Cannot connect to local gpd service"*. The drop-in
`systemd/.config/systemd/user/gpa.service.d/override.conf` sets:

```ini
[Unit]
StartLimitIntervalSec=0
[Service]
Restart=always
RestartSec=2
```

Apply it with:

```bash
systemctl --user daemon-reload
systemctl --user restart gpa.service
systemctl --user show gpa.service -p Restart -p DropInPaths   # Restart=always
```

## Install / repair

```bash
cd ~/Downloads/vpn/PanGPLinux-6.3.3-c31
./gp_install.sh        # needs an interactive sudo password
```

If the GUI prints `Cannot connect to local gpd service` even though
`gpd.service` is active, do a clean reinstall — this clears the corrupted
gpd runtime state (tunnel interface, pid/socket files) without changing the
package version:

```bash
./gp_uninstall.sh && ./gp_install.sh
```

Remove entirely with `./gp_uninstall.sh`.

Checks:

```bash
rpm -q GlobalProtect_UI_rpm
systemctl status gpd.service --no-pager
systemctl --user status gpa.service --no-pager
globalprotect show --version
pgrep -a -x PanGPUI
```

## Fallbacks (no GUI)

- **NetworkManager**: a `GlobalProtect` openconnect profile exists
  (`nmcli connection up GlobalProtect`); it opens the Okta SSO page.
- **openconnect**: `sudo openconnect --protocol=gp vpn-esdm.gpcloudservice.com`
  (its built-in `--external-browser` SAML handling is unreliable for this
  portal's POST binding).
- **gp-saml-gui** (better SAML flow):

  ```bash
  pip3 install --user 'https://github.com/dlenski/gp-saml-gui/archive/master.zip'
  ~/.local/bin/gp-saml-gui -S vpn-esdm.gpcloudservice.com
  ```

  It opens an embedded browser for Okta, then execs `sudo openconnect` with the
  session cookie. If it asks for a gateway interactively, pipe the gateway name
  as a second stdin line.

## Note on Fedora 44

The vendor binary is older than Fedora 44's glibc and previously crashed with
`SIGSEGV` in `setreuid()` on shutdown (daemon then never bound its server
thread). A full reinstall fixed it; the drop-in above plus a clean uninstall
first are the recovery path if the symptom returns.
