# Maintainer: Olivier Lorillu <contact@jotenakis.ovh>
pkgname=omarchy-random-wallpaper
pkgver=1.0.0
pkgrel=2
pkgdesc="Hourly random wallpaper rotation from ~/Pictures/wallpapers, for Omarchy"
arch=('any')
url="https://github.com/jotenakis2/omarchy-random-wallpaper"
license=('MIT')
depends=('bash' 'systemd' 'omarchy')
install="$pkgname.install"
options=('!strip')

# Package files live in the repository itself: nothing to download.
source=()
sha256sums=()

package() {
  install -Dm755 "$startdir/random-wallpaper" "$pkgdir/usr/bin/random-wallpaper"

  install -Dm644 "$startdir/systemd/random-wallpaper.service" \
    "$pkgdir/usr/lib/systemd/user/random-wallpaper.service"
  install -Dm644 "$startdir/systemd/random-wallpaper.timer" \
    "$pkgdir/usr/lib/systemd/user/random-wallpaper.timer"

  # Preset: the timer enables itself on the first session start of each new
  # user (systemd --user applies user presets on first start).
  install -Dm644 "$startdir/systemd/90-omarchy-random-wallpaper.preset" \
    "$pkgdir/usr/lib/systemd/user-preset/90-omarchy-random-wallpaper.preset"

  install -Dm644 "$startdir/LICENSE" "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
