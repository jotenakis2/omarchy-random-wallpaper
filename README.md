# omarchy-random-wallpaper

**English** · [Français](README.fr.md)

Changes the Omarchy wallpaper every hour, picking at random from
`~/Pictures/wallpapers`.

The switch goes through Omarchy's official API (`omarchy theme bg set`): the
`~/.local/state/omarchy/current/background` state is updated and the shell is
notified, so the wallpaper survives theme changes and reboots. The image
currently displayed is excluded from the draw to avoid consecutive repeats.

Program messages follow the session locale: French when
`LANGUAGE`/`LC_ALL`/`LC_MESSAGES`/`LANG` starts with `fr`, English otherwise.

## Requirements

- Omarchy (`omarchy` command available)
- A `~/Pictures/wallpapers` directory with `.png`, `.jpg`, `.jpeg` or `.webp`
  files
- `systemd --user` (standard Hyprland/uwsm session)

## Install without root (current session)

The simplest method: it touches neither `/usr` nor pacman.

```bash
git clone https://github.com/jotenakis2/omarchy-random-wallpaper.git \
  ~/Projects/omarchy-random-wallpaper
cd ~/Projects/omarchy-random-wallpaper
./install.sh
```

The script installs:

| Path | Content |
|---|---|
| `~/.local/bin/random-wallpaper` | the draw script |
| `~/.config/systemd/user/random-wallpaper.service` | `oneshot` unit |
| `~/.config/systemd/user/random-wallpaper.timer` | hourly timer |

then enables the timer immediately (`systemctl --user enable --now`).

Uninstall:

```bash
./install.sh --uninstall
```

## Install as a pacman package

```bash
cd ~/Projects/omarchy-random-wallpaper
makepkg -si
```

The package installs:

| Path | Content |
|---|---|
| `/usr/bin/random-wallpaper` | the draw script |
| `/usr/lib/systemd/user/random-wallpaper.{service,timer}` | user units |
| `/usr/lib/systemd/user-preset/90-omarchy-random-wallpaper.preset` | automatic enable |
| `/usr/share/licenses/omarchy-random-wallpaper/LICENSE` | MIT license |

Thanks to the preset, the timer enables **itself** on the first systemd session
start of every new user. On a session that is already running (installing on an
existing machine), enable it once:

```bash
systemctl --user daemon-reload
systemctl --user enable --now random-wallpaper.timer
```

That is exactly what the pacman post-install message reminds you of.

## Inspect and control

```bash
systemctl --user list-timers random-wallpaper.timer   # next run
systemctl --user start random-wallpaper.service       # draw right now
journalctl --user -u random-wallpaper.service -n 20   # picked images
systemctl --user disable --now random-wallpaper.timer # pause
```

## Customize

Use another directory (unit override, the package stays untouched):

```bash
systemctl --user edit random-wallpaper.service
# [Service]
# Environment=WALLPAPER_DIR=/path/to/my/wallpapers
```

Change the frequency:

```bash
systemctl --user edit random-wallpaper.timer
# [Timer]
# OnCalendar=*-*-* *:00/30:00     (every 30 minutes)
```

Then `systemctl --user daemon-reload && systemctl --user restart random-wallpaper.timer`.

## Troubleshooting

- **Nothing changes**: check `systemctl --user status random-wallpaper.service`
  and `journalctl --user -u random-wallpaper.service`. The service needs
  `WAYLAND_DISPLAY` in the systemd --user environment (provided by uwsm on
  Omarchy); the state symlink is updated anyway even when the shell is absent.
- **Empty or differently named directory**: the script exits with an error
  naming the path it looked for; set `WALLPAPER_DIR` as shown above.
- The package and the user-level install are mutually exclusive: `install.sh`
  refuses to run when `omarchy-random-wallpaper` is present via pacman.

## Repository layout

```
random-wallpaper                     draw script
systemd/random-wallpaper.service     unit (ExecStart=/usr/bin/...)
systemd/random-wallpaper.timer       hourly timer (OnCalendar=hourly)
systemd/90-....preset                automatic enable for new users
install.sh                           rootless user install
PKGBUILD + .install                  Arch package
check.sh                             shellcheck-real + systemd-analyze verify
```
