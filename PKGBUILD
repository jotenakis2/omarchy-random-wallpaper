# Maintainer: Olivier Lorillu <contact@jotenakis.ovh>
pkgname=omarchy-random-wallpaper
pkgver=1.0.0
pkgrel=1
pkgdesc="Rotation horaire aléatoire du fond d'écran depuis ~/Pictures/wallpapers, pour Omarchy"
arch=('any')
url="https://github.com/jotenakis2/omarchy-random-wallpaper"
license=('MIT')
depends=('bash' 'systemd' 'omarchy')
install="$pkgname.install"
options=('!strip')

# Les fichiers du paquet sont dans le dépôt lui-même : pas de source à télécharger.
source=()
sha256sums=()

package() {
  install -Dm755 "$startdir/random-wallpaper" "$pkgdir/usr/bin/random-wallpaper"

  install -Dm644 "$startdir/systemd/random-wallpaper.service" \
    "$pkgdir/usr/lib/systemd/user/random-wallpaper.service"
  install -Dm644 "$startdir/systemd/random-wallpaper.timer" \
    "$pkgdir/usr/lib/systemd/user/random-wallpaper.timer"

  # Preset : le timer s'active tout seul au premier démarrage de session
  # du gestionnaire systemd --user (nouvel utilisateur, nouvelle machine).
  install -Dm644 "$startdir/systemd/90-omarchy-random-wallpaper.preset" \
    "$pkgdir/usr/lib/systemd/user-preset/90-omarchy-random-wallpaper.preset"

  install -Dm644 "$startdir/LICENSE" "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
