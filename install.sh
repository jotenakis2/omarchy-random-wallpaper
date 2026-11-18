#!/usr/bin/env bash
# shellcheck enable=all

# Installe la rotation aléatoire du fond d'écran dans la session de
# l'utilisateur courant (~/.local/bin + unités systemd --user), sans root.
# Pour une installation système (pacman), utiliser PKGBUILD à la place.

set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
bin_dir="${HOME}/.local/bin"
unit_dir="${HOME}/.config/systemd/user"
timer="random-wallpaper.timer"

usage() {
  cat <<'EOF'
Usage : ./install.sh [option]

  (sans option)   Installe le script et le timer dans la session courante
  --uninstall     Désactive et supprime l'installation utilisateur
  --help          Affiche cette aide
EOF
}

install_files() {
  if ! command -v omarchy >/dev/null 2>&1; then
    echo "omarchy introuvable : ce script est prévu pour Omarchy." >&2
    exit 1
  fi

  if pacman -Qq omarchy-random-wallpaper >/dev/null 2>&1; then
    echo "Le paquet omarchy-random-wallpaper est déjà installé (pacman)." >&2
    echo "Utilisez pacman pour le gérer : pacman -Rns omarchy-random-wallpaper" >&2
    exit 1
  fi

  mkdir -p "${bin_dir}" "${unit_dir}"

  install -m 755 "${repo_dir}/random-wallpaper" "${bin_dir}/random-wallpaper"
  install -m 644 "${repo_dir}/systemd/random-wallpaper.timer" \
    "${unit_dir}/random-wallpaper.timer"

  # L'unité du dépôt vise /usr/bin (paquet) : on la réécrit pour le mode utilisateur.
  sed "s|^ExecStart=.*|ExecStart=${bin_dir}/random-wallpaper|" \
    "${repo_dir}/systemd/random-wallpaper.service" >"${unit_dir}/random-wallpaper.service"
  chmod 644 "${unit_dir}/random-wallpaper.service"

  systemctl --user daemon-reload
  systemctl --user enable --now "${timer}"

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
}

uninstall_files() {
  systemctl --user disable --now "${timer}" 2>/dev/null || true
  rm -f "${bin_dir}/random-wallpaper" \
    "${unit_dir}/random-wallpaper.service" \
    "${unit_dir}/random-wallpaper.timer"
  systemctl --user daemon-reload
  echo "Rotation du fond d'écran désinstallée (le fond actuel reste en place)."
}

case "${1:-}" in
  "") install_files ;;
  --uninstall) uninstall_files ;;
  --help | -h) usage ;;
  *)
    echo "Option inconnue : ${1}" >&2
    usage >&2
    exit 1
    ;;
esac
