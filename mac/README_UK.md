# Збирання Gajim на macOS

Детальні інструкції щодо збирання omemo-dr, nbxmpp та Gajim на macOS також доступні на [сторінці wiki](https://gitlab.com/gajim/gajim/-/wikis/help/Gajim-on-macOS).

У цьому каталозі міститься скрипт `gajim-macos-helper.sh`, який автоматизує створення віртуального середовища, встановлення залежностей через Homebrew, запуск та пакування у формат `.dmg`.

[English Documentation](README.md)

---

## Системні вимоги

- Встановлений [Homebrew](https://brew.sh)
- Оболонка Bash (наявна за замовчуванням у macOS)
- Python 3.14

---

## Збирання поточного коду репозиторію

Для збирання поточного чекауту з кореневого каталогу:

```bash
brew install gtk4 libadwaita pygobject3 adwaita-icon-theme libsoup@3 \
    gstreamer gtksourceview5 libspelling gettext librsvg python@3.14
python3.14 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -e .
python -m pip install pyobjc-framework-Cocoa pyinstaller
export GI_TYPELIB_PATH="/opt/homebrew/lib/girepository-1.0:/opt/homebrew/opt/gtksourceview5/lib/girepository-1.0:/opt/homebrew/opt/libspelling/lib/girepository-1.0:/opt/homebrew/share/gir-1.0"
export XDG_DATA_DIRS="/opt/homebrew/share:${XDG_DATA_DIRS:-}"
export DYLD_LIBRARY_PATH="/opt/homebrew/lib:${DYLD_LIBRARY_PATH:-}"
./mac/makebundle.py
```

Команда сформує застосунок `dist/Gajim.app` та згенерує образ диску `.dmg`.

---

## Використання допоміжного скрипта `gajim-macos-helper.sh`

### Збирання оточення

```bash
./gajim-macos-helper.sh build
```

Скрипт встановить залежності через Homebrew, створить ізольоване віртуальне середовище Python та збере omemo-dr, nbxmpp і Gajim.

### Запуск зібраного Gajim

```bash
./gajim-macos-helper.sh start
```

### Створення образу DMG

```bash
./gajim-macos-helper.sh create-dmg ci
```
