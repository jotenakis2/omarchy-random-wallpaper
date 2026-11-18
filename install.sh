#!/usr/bin/env bash
# shellcheck enable=all

# Installs the random wallpaper rotation for the current user
# (~/.local/bin + systemd --user units), no root required.
# For a system-wide install (pacman), use PKGBUILD instead.
#
# User-facing messages are French when the session locale is French, English
# otherwise.

set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
bin_dir="${HOME}/.local/bin"
unit_dir="${HOME}/.config/systemd/user"
timer="random-wallpaper.timer"

# French when the session language starts with "fr", English as fallback.
case "${LANGUAGE:-${LC_ALL:-${LC_MESSAGES:-${LANG:-}}}}" in
  fr*) lang=fr ;;
  *) lang=en ;;
esac

usage() {
  case "${lang}" in
    fr)
      cat <<'EOF'
Usage : ./install.sh [option]

  (sans option)   Installe le script et le timer dans la session courante
  --uninstall     Désactive et supprime l'installation utilisateur
  --help          Affiche cette aide
EOF
      ;;
    *)
      cat <<'EOF'
Usage: ./install.sh [option]

  (no option)     Install the script and timer into the current session
  --uninstall     Disable and remove the user-level installation
  --help          Show this help
EOF
      ;;
  esac
}

install_files() {
  if ! command -v omarchy >/dev/null 2>&1; then
    case "${lang}" in
      fr) echo 'omarchy introuvable : ce script est prévu pour Omarchy.' >&2 ;;
      *) echo 'omarchy not found: this script targets Omarchy.' >&2 ;;
    esac
    exit 1
  fi

  if pacman -Qq omarchy-random-wallpaper >/dev/null 2>&1; then
    case "${lang}" in
      fr)
        echo 'Le paquet omarchy-random-wallpaper est déjà installé (pacman).' >&2
        echo 'Utilisez pacman pour le gérer : pacman -Rns omarchy-random-wallpaper' >&2
        ;;
      *)
        echo 'The omarchy-random-wallpaper package is already installed (pacman).' >&2
        echo 'Manage it with pacman instead: pacman -Rns omarchy-random-wallpaper' >&2
        ;;
    esac
    exit 1
  fi

  mkdir -p "${bin_dir}" "${unit_dir}"

  install -m 755 "${repo_dir}/random-wallpaper" "${bin_dir}/random-wallpaper"
  install -m 644 "${repo_dir}/systemd/random-wallpaper.timer" \
    "${unit_dir}/random-wallpaper.timer"

  # The repository unit targets /usr/bin (package install): rewrite it for the
  # user-level installation.
  sed "s|^ExecStart=.*|ExecStart=${bin_dir}/random-wallpaper|" \
    "${repo_dir}/systemd/random-wallpaper.service" >"${unit_dir}/random-wallpaper.service"
  chmod 644 "${unit_dir}/random-wallpaper.service"

  systemctl --user daemon-reload
  systemctl --user enable --now "${timer}"

  case "${lang}" in
    fr)
      cat <<EOF

==> Installation terminée

Script : ${bin_dir}/random-wallpaper
Unités : ${unit_dir}/random-wallpaper.{service,timer}

Prochain passage :
    systemctl --user list-timers ${timer}
Changer tout de suite :
    systemctl --user start random-wallpaper.service
Désinstaller :
    ${repo_dir}/install.sh --uninstall
EOF
      ;;
    *)
      cat <<EOF

==> Installation complete

Script: ${bin_dir}/random-wallpaper
Units:  ${unit_dir}/random-wallpaper.{service,timer}

Next run:
    systemctl --user list-timers ${timer}
Change right away:
    systemctl --user start random-wallpaper.service
Uninstall:
    ${repo_dir}/install.sh --uninstall
EOF
      ;;
  esac
}

uninstall_files() {
  systemctl --user disable --now "${timer}" 2>/dev/null || true
  rm -f "${bin_dir}/random-wallpaper" \
    "${unit_dir}/random-wallpaper.service" \
    "${unit_dir}/random-wallpaper.timer"
  systemctl --user daemon-reload

  case "${lang}" in
    fr) echo "Rotation du fond d'écran désinstallée (le fond actuel reste en place)." ;;
    *) echo 'Wallpaper rotation uninstalled (the current wallpaper stays in place).' ;;
  esac
}

case "${1:-}" in
  "") install_files ;;
  --uninstall) uninstall_files ;;
  --help | -h) usage ;;
  *)
    case "${lang}" in
      fr) echo "Option inconnue : ${1}" >&2 ;;
      *) echo "Unknown option: ${1}" >&2 ;;
    esac
    usage >&2
    exit 1
    ;;
esac
