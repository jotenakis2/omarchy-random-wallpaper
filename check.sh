#!/usr/bin/env bash
# shellcheck enable=all

# Vérifie tous les scripts du dépôt avec shellcheck-real (gate « zéro avertissement »).

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")" || exit 1

status=0
for file in random-wallpaper install.sh check.sh omarchy-random-wallpaper.install; do
  echo "== ${file}"
  shellcheck-real --enable=all --shell=bash "${file}" || status=1
done

# L'unité du dépôt vise /usr/bin (installation par paquet). Pour la vérifier
# sans le paquet, on la copie en pointant sur le script du dépôt.
tmp_dir="$(mktemp -d)"
trap 'rm -rf "${tmp_dir}"' EXIT

sed "s|^ExecStart=.*|ExecStart=${PWD}/random-wallpaper|" \
  systemd/random-wallpaper.service >"${tmp_dir}/random-wallpaper.service"
cp systemd/random-wallpaper.timer "${tmp_dir}/random-wallpaper.timer"

systemd-analyze --user verify \
  "${tmp_dir}/random-wallpaper.service" "${tmp_dir}/random-wallpaper.timer" || status=1

exit "${status}"
