# Gajim [![Build and release packages](https://github.com/NightSommelier/gajim/actions/workflows/build-release.yml/badge.svg?branch=master)](https://github.com/NightSommelier/gajim/actions/workflows/build-release.yml) [![License: GPL v3](https://img.shields.io/badge/License-GPL--3.0-blue.svg)](COPYING) [![Latest Release](https://img.shields.io/github/v/release/NightSommelier/gajim?include_prereleases&label=release)](https://github.com/NightSommelier/gajim/releases)

Повнофункціональний, розширюваний клієнт для обміну повідомленнями XMPP, створений на базі Python та GTK4.

> [!NOTE]
> [English documentation is available in README.md](README.md).

Gajim створений як простий у використанні та багатофункціональний XMPP-клієнт. Спілкуйтеся з друзями та родиною, безпечно надсилайте зашифровані фотографії та файли, записуйте голосові повідомлення й беріть участь у групових чатах із наскрізним шифруванням OMEMO.

Цей робочий форк забезпечує автоматизовані конвеєри збирання релізів під усі основні платформи: Flatpak для GNOME 51, DMG для Apple Silicon macOS, інсталятори та пакети MSIX для Windows, автономні AppImage для Linux, а також підвищену стабільність мережевого з'єднання.

---

## Ключові можливості та покращення форку

- **Сучасна базова версія апстріму (v2.6.0)**: Зібрано на базі офіційного випуску Gajim 2.6.0 зі стандартною структурою `src/`, сумісністю з Python 3.12+ та асинхронним HTTP-рушієм `httpx2`.
- **Наскрізне шифрування (E2EE)**: Сучасне шифрування OMEMO на базі `omemo-dr`, а також підтримка OpenPGP та PGP.
- **Стійкість мережевого з'єднання**: Спеціальний механізм перевірки доступності ([`check_client_connectivity`](src/gajim/common/client_connectivity.py)), що гарантує надійний автоматичний реконект у разі зміни стану мережі.
- **Покращене форматування повідомлень**: Оптимізована обробка стилів введення, коректне приховування маркерів форматування та збереження пробілів у чаті.
- **Повний набір багатоплатформних пакунків**:
  - **Linux**: Однофайловий Flatpak-бандл, автономний AppImage та портативний `.tar.zst` архів.
  - **Windows**: Нативний інсталятор NSIS для MSYS2 UCRT64 та сучасний пакет MSIX для Microsoft Store.
  - **macOS**: Ізольоване віртуальне середовище для Apple Silicon (`arm64`, macOS 15+) зі створенням готового образу `.dmg`.
- **Автоматизація CI/CD з контрольними сумами SHA-256**: Кожен реліз паралельно збирається у GitHub Actions з обов'язковою публікацією окремих криптографічних файлів перевірки цілісності.

---

## Завантаження (Downloads)

Офіційні бінарні файли з нашого автоматизованого конвеєра збирання:

| Платформа | Формат / Пакет | Архітектура | Контрольна сума |
| :--- | :--- | :--- | :--- |
| **Windows** | [Gajim.exe](https://github.com/NightSommelier/gajim/releases/latest/download/Gajim.exe) | x86_64 | [SHA-256](https://github.com/NightSommelier/gajim/releases/latest/download/Gajim.exe.sha256) |
| **Windows Store** | [Gajim.msixbundle](https://github.com/NightSommelier/gajim/releases/latest/download/Gajim.msixbundle) | x86_64 | [SHA-256](https://github.com/NightSommelier/gajim/releases/latest/download/Gajim.msixbundle.sha256) |
| **Linux (Portable)** | [gajim-linux-amd64-portable.tar.zst](https://github.com/NightSommelier/gajim/releases/latest/download/gajim-linux-amd64-portable.tar.zst) | x86_64 | [SHA-256](https://github.com/NightSommelier/gajim/releases/latest/download/gajim-linux-amd64-portable.tar.zst.sha256) |
| **Linux (AppImage)** | [gajim-linux-amd64.AppImage](https://github.com/NightSommelier/gajim/releases/latest/download/gajim-linux-amd64.AppImage) | x86_64 | [SHA-256](https://github.com/NightSommelier/gajim/releases/latest/download/gajim-linux-amd64.AppImage.sha256) |
| **Linux (Flatpak)** | [gajim-flatpak.flatpak](https://github.com/NightSommelier/gajim/releases/latest/download/gajim-flatpak.flatpak) | x86_64 | [SHA-256](https://github.com/NightSommelier/gajim/releases/latest/download/gajim-flatpak.flatpak.sha256) |
| **macOS** | [Gajim.dmg](https://github.com/NightSommelier/gajim/releases/latest) | Apple Silicon (arm64) | [SHA-256](https://github.com/NightSommelier/gajim/releases/latest) |

Усі випуски та списки змін: [GitHub Releases](https://github.com/NightSommelier/gajim/releases).

---

## Структура репозиторію та карта документації

```text
gajim/
├── src/gajim/              # Вихідний код застосунку (common, інтерфейс GTK4, плагіни, дані)
├── tests/                  # Набір модульних та інтеграційних тестів
├── linux/                  # Скрипти складання Linux AppImage, PyInstaller та портативних архівів
├── mac/                    # Скрипти пакетування macOS, gajim.spec та утиліти
├── win/                    # Скрипти MSYS2 Windows, конфігурації NSIS та пакування MSIX
├── flatpak/                # Маніфести Flatpak (платформа GNOME 51) та залежності
└── .github/workflows/      # Автоматизовані конвеєри CI/CD та публікації релізів
```

- [**FORK_UK.md**](FORK_UK.md): Архітектурні межі, базова лінія синхронізації з апстрімом та деталі форку.
- [**CONTRIBUTING_UK.md**](CONTRIBUTING_UK.md): Стандарти оформлення комітів, налаштування pre-commit та створення пул-реквестів.
- [**SECURITY_UK.md**](SECURITY_UK.md): Політика безпеки, конфіденційне повідомлення про вразливості.
- [**mac/README_UK.md**](mac/README_UK.md): Детальні інструкції щодо збирання для macOS.
- [**win/README_UK.md**](win/README_UK.md): Інструкції щодо розробки та збирання у середовищі MSYS2 UCRT64.
- [**flatpak/README_UK.md**](flatpak/README_UK.md): Встановлення Flatpak, робота з плагінами та власними сертифікатами.

---

## Системні вимоги

### Вимоги під час виконання (Runtime)

- [Python](https://www.python.org/) (>=3.12)
- [Gtk4](https://gitlab.gnome.org/GNOME/gtk) (>=4.17.5)
- [libadwaita](https://gitlab.gnome.org/GNOME/libadwaita) (>=1.7.0)
- [PyGObject](https://pypi.org/project/PyGObject/) (>=3.53.0)
- [pycairo](https://pypi.org/project/pycairo/) та [cairo](https://gitlab.freedesktop.org/cairo/cairo) (>=1.16.0)
- [Pango](https://gitlab.gnome.org/GNOME/pango) (>=1.50.0)
- [GLib](https://gitlab.gnome.org/GNOME/glib) (>=2.80.0)
- [GtkSourceView5](https://gitlab.gnome.org/GNOME/gtksourceview)
- [libspelling](https://gitlab.gnome.org/GNOME/libspelling)
- [GStreamer](https://gitlab.freedesktop.org/gstreamer/gstreamer) та `gst-plugins-base`
- [nbxmpp](https://pypi.org/project/nbxmpp/) (>=7.4.0)
- [omemo-dr](https://gitlab.com/gajim/omemo-dr) (>=1.2.0)
- [cryptography](https://pypi.org/project/cryptography/) (>=43.0.0)
- [httpx2](https://pypi.org/project/httpx2/) та [h2](https://pypi.org/project/h2/)
- [Pillow](https://pypi.org/project/Pillow/) (>=9.1.0)
- [SQLAlchemy](https://pypi.org/project/SQLAlchemy/) (>=2.0.0)
- [sqlite](https://www.sqlite.org/) (>=3.35.0)
- [keyring](https://pypi.org/project/keyring/)
- [truststore](https://pypi.org/project/truststore/)
- [qrcode](https://pypi.org/project/qrcode/) (>=7.3.1)
- [emoji](https://pypi.org/project/emoji/) (>=2.6.0)

---

## Локальна розробка та збирання

Найзручніший спосіб локальної розробки — за допомогою [uv](https://docs.astral.sh/uv/) та Nix:

```bash
# Вхід у відтворюване середовище
nix-shell .github/nix/shell.nix

# Синхронізація залежностей
uv sync

# Запуск модульних тестів
uv run python -m pytest tests/common/test_client.py tests/common/test_styling.py

# Перевірка коду лінтером та форматуванням
uv run ruff check src/
uv run ruff format --check src/

# Складання wheel-пакета
uv build
```

Для запуску Gajim у режимі розробки:
```bash
uv run gajim --user-profile dev
```

---

## Автоматизація релізів

Кожен пуш тегу `gajim-*` автоматично запускає [робочий процес збирання](.github/workflows/build-release.yml). Усі пакунки компілюються паралельно у чистих віртуальних середовищах та публікуються у розділі GitHub Releases разом із криптографічними файлами SHA-256.

(C) 2003-2026 Команда Gajim та автори форку  
[https://gajim.org](https://gajim.org)
