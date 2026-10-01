# Gajim

Повнофункціональний клієнт для обміну повідомленнями XMPP.

Gajim створений як простий у використанні та багатофункціональний XMPP-клієнт. Спілкуйтеся з друзями та родиною, легко діліться фотографіями й думками або обговорюйте новини у групових чатах.

[English Documentation](README.md)

---

## Вимоги

### Системні вимоги під час виконання (Runtime)

- [libadwaita](https://gitlab.gnome.org/GNOME/libadwaita) (>=1.7.0)
- [cairo](https://gitlab.freedesktop.org/cairo/cairo) (>=1.16.0)
- [cryptography](https://pypi.org/project/cryptography/) (>=43.0.0)
- [css-parser](https://pypi.org/project/css-parser/)
- [emoji](https://pypi.org/project/emoji/) (>=2.6.0)
- [GLib](https://gitlab.gnome.org/GNOME/glib) (>=2.80.0)
- [Gtk4](https://gitlab.gnome.org/GNOME/gtk) (>=4.17.5)
- [GtkSourceView5](https://gitlab.gnome.org/GNOME/gtksourceview)
- [GStreamer](https://gitlab.freedesktop.org/gstreamer/gstreamer)
- [gst-plugins-base](https://gitlab.freedesktop.org/gstreamer/gstreamer/-/tree/main/subprojects/gst-plugins-base)
- [keyring](https://pypi.org/project/keyring/)
- [nbxmpp](https://pypi.org/project/nbxmpp/) (>=7.4.0)
- [omemo-dr](https://gitlab.com/gajim/omemo-dr) (>=1.2.0)
- [packaging](https://pypi.org/project/packaging/)
- [httpx2](https://pypi.org/project/httpx2/)
- [h2](https://pypi.org/project/h2/)
- [Pango](https://gitlab.gnome.org/GNOME/pango) (>=1.50.0)
- [Pillow](https://pypi.org/project/Pillow/) (>=9.1.0)
- [precis_i18n](https://pypi.org/project/precis-i18n/)
- [pysequoia](https://pypi.org/project/pysequoia/) (>=0.1.33)
- [pycairo](https://pypi.org/project/pycairo/)
- [PyGObject](https://pypi.org/project/PyGObject/) (>=3.53.0)
- [Python](https://www.python.org/) (>=3.12)
- [qrcode](https://pypi.org/project/qrcode/) (>=7.3.1)
- [socksio](https://pypi.org/project/socksio/)
- [SQLAlchemy](https://pypi.org/project/SQLAlchemy/) (>=2.0.0)
- [sqlite](https://www.sqlite.org/) (>=3.35.0)
- [truststore](https://pypi.org/project/truststore/)
- [pystray](https://github.com/moses-palmer/pystray) (Лише Windows)
- [PyWinRT](https://github.com/pywinrt/pywinrt) (Лише Windows)
- [windows-toasts](https://github.com/DatGuy1/Windows-Toasts) (Лише Windows)

### Додаткові вимоги (Опціонально)

- Запущений D-Bus для роботи `gajim-remote`
- [sentry-sdk](https://pypi.org/project/sentry-sdk/) для надсилання звітів про помилки до Sentry на gitlab.com (користувач вирішує, чи надсилати звіти)
- [libspelling](https://gitlab.gnome.org/GNOME/libspelling) та `hunspell-LANG` для перевірки орфографії
- [libsecret](https://gitlab.gnome.org/GNOME/libsecret/) для інтеграції з GNOME Keyring або KDE Wallet
- [GUPnP-IGD](https://gitlab.gnome.org/GNOME/gupnp) для кращої роботи через NAT
- [NetworkManager](https://gitlab.freedesktop.org/NetworkManager/NetworkManager) для виявлення стану мережі
- [GeoClue](https://gitlab.freedesktop.org/geoclue/geoclue) для передавання геолокації
- [distro](https://pypi.org/project/distro/) для отримання детальної інформації про операційну систему

#### Розширений попередній перегляд (Зображення та голосові повідомлення)

- [gst-libav](https://gitlab.freedesktop.org/gstreamer/gstreamer/-/tree/main/subprojects/gst-libav)
- [gst-plugins-good](https://gitlab.freedesktop.org/gstreamer/gstreamer/-/tree/main/subprojects/gst-plugins-good)
- [gst-plugins-bad](https://gitlab.freedesktop.org/gstreamer/gstreamer/-/tree/main/subprojects/gst-plugins-bad)
- [gst-plugins-rs](https://gitlab.freedesktop.org/gstreamer/gst-plugins-rs)

---

## Збирання проєкту

### Збирання метаданих та перекладів

```bash
uv run ./make.py build
```

Після виконання файли метаданих з'являться у каталозі `dist/metadata`.

### Створення wheel-пакета

```bash
uv build
```

або за допомогою `build`:

```bash
python -m build -w
```

## Встановлення

```bash
uv pip install dist/*.whl
```

### Встановлення файлів метаданих (лише Unix)

```bash
uv run ./make.py install --prefix /usr
```

## Тестування

- `uv run pytest`
- `uv run pytest ./tests/gtk/ui_test_filechoosers.py`

## CI-пакети та випуски

Цей форк збирає артефакти релізів за допомогою [GitHub Actions](.github/workflows/build-release.yml). Пул-реквести та пуші автоматично перевіряють збирання для Linux amd64, Flatpak amd64, Windows amd64 та macOS arm64; при створенні тегу `gajim-*` створюється попередній випуск на GitHub.

Кожен випуск включає:
- Linux wheel / вихідний архів, портативний `tar.zst` та AppImage
- Flatpak-бандл
- Інсталятор для Windows, портативний виконуваний файл та пакет MSIX
- macOS arm64 DMG

Для локального відтворення середовища збирання:

```bash
nix-shell .github/nix/shell.nix
uv sync
./linux/build-portable.sh
bash .forgejo/scripts/build-flatpak.sh
```

---

## Додаткова документація

- [Внесок у проєкт (Українська)](CONTRIBUTING_UK.md)
- [Безпека (Українська)](SECURITY_UK.md)
- [Збирання під macOS (Українська)](mac/README_UK.md)
- [Збирання під Windows (Українська)](win/README_UK.md)
- [Пакети Flatpak (Українська)](flatpak/README_UK.md)

---

(C) 2003-2026 Команда Gajim  
[https://gajim.org](https://gajim.org)
