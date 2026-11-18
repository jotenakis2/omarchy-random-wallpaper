# omarchy-random-wallpaper

Change le fond d'écran Omarchy toutes les heures en piochant au hasard dans
`~/Pictures/wallpapers`.

Le changement passe par l'API officielle d'Omarchy (`omarchy theme bg set`) :
l'état `~/.local/state/omarchy/current/background` est mis à jour et le shell
est notifié, donc le fond survit aux changements de thème et aux redémarrages.
L'image déjà affichée est exclue du tirage pour éviter les répétitions
consécutives.

## Prérequis

- Omarchy (commande `omarchy` disponible)
- Un dossier `~/Pictures/wallpapers` contenant des `.png`, `.jpg`, `.jpeg`
  ou `.webp`
- `systemd --user` (session Hyprland/uwsm standard)

## Installation sans root (session courante)

C'est la méthode la plus simple, elle ne touche ni `/usr` ni pacman :

```bash
git clone <ce dépôt> ~/Projects/omarchy-random-wallpaper
cd ~/Projects/omarchy-random-wallpaper
./install.sh
```

Le script installe :

| Chemin | Contenu |
|---|---|
| `~/.local/bin/random-wallpaper` | le script de tirage |
| `~/.config/systemd/user/random-wallpaper.service` | unité `oneshot` |
| `~/.config/systemd/user/random-wallpaper.timer` | timer horaire |

puis il active le timer immédiatement (`systemctl --user enable --now`).

Désinstallation :

```bash
./install.sh --uninstall
```

## Installation en paquet pacman (machine neuve, autre machine)

```bash
cd ~/Projects/omarchy-random-wallpaper
makepkg -si
```

Le paquet installe :

| Chemin | Contenu |
|---|---|
| `/usr/bin/random-wallpaper` | le script de tirage |
| `/usr/lib/systemd/user/random-wallpaper.{service,timer}` | unités utilisateur |
| `/usr/lib/systemd/user-preset/90-omarchy-random-wallpaper.preset` | activation automatique |
| `/usr/share/licenses/omarchy-random-wallpaper/LICENSE` | licence MIT |

Grâce au preset, le timer s'active **tout seul** au premier démarrage de
session systemd de chaque nouvel utilisateur. Sur une session déjà ouverte
(cas de l'installation sur une machine existante), il faut l'activer une fois :

```bash
systemctl --user daemon-reload
systemctl --user enable --now random-wallpaper.timer
```

C'est exactement ce que le message post-installation de pacman rappelle.

## Vérifier et piloter

```bash
systemctl --user list-timers random-wallpaper.timer   # prochain tirage
systemctl --user start random-wallpaper.service       # tirer tout de suite
journalctl --user -u random-wallpaper.service -n 20   # images choisies
systemctl --user disable --now random-wallpaper.timer # mettre en pause
```

## Personnaliser

Changer de dossier (surcharge de l'unité, sans toucher au paquet) :

```bash
systemctl --user edit random-wallpaper.service
# [Service]
# Environment=WALLPAPER_DIR=/chemin/vers/mes/fonds
```

Changer la fréquence :

```bash
systemctl --user edit random-wallpaper.timer
# [Timer]
# OnCalendar=*-*-* *:00/30:00     (toutes les 30 minutes)
```

Puis `systemctl --user daemon-reload && systemctl --user restart random-wallpaper.timer`.

## Dépannage

- **Rien ne change** : vérifier `systemctl --user status random-wallpaper.service`
  et `journalctl --user -u random-wallpaper.service`. Le service a besoin de
  `WAYLAND_DISPLAY` dans l'environnement systemd --user (fourni par uwsm sur
  Omarchy) ; le symlink d'état est de toute façon mis à jour même si le shell
  est absent.
- **Dossier vide ou nommé autrement** : le script sort en erreur avec le chemin
  recherché ; utiliser `WALLPAPER_DIR` comme ci-dessus.
- Le paquet et l'installation utilisateur sont exclusifs : `install.sh` refuse
  de s'installer si `omarchy-random-wallpaper` est présent via pacman.

## Contenu du dépôt

```
random-wallpaper                     script de tirage
systemd/random-wallpaper.service     unité (ExecStart=/usr/bin/...)
systemd/random-wallpaper.timer       timer horaire (OnCalendar=hourly)
systemd/90-....preset                activation auto des nouveaux utilisateurs
install.sh                           installation utilisateur sans root
PKGBUILD + .install                  paquet Arch
check.sh                             shellcheck-real + systemd-analyze verify
```
