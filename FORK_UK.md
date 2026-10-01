# Довідка про форк Gajim (Fork Record)

> [!NOTE]
> [English documentation is available in FORK.md](FORK.md).

## Статус проєкту

Цей репозиторій є робочим форком проєкту **Gajim**. Він містить додаткові покращення стабільності для різних операційних систем, автоматизовані конвеєри збирання релізів (Flatpak, Linux AppImage/portable, Windows MSIX/installer, macOS DMG) та додаткові налаштування обробки повідомлень, зберігаючи при цьому повну сумісність з офіційним апстрімом Gajim.

## Базова версія апстріму (Upstream Baseline)

- Офіційний репозиторій: `https://gitlab.com/gajim/gajim.git` (`upstream`)
- Дзеркало релізів: `https://dev.gajim.org/gajim/gajim.git`
- Поточна базова версія: **Gajim 2.6.0**
- Структура коду: сучасна компоновка `src/` (`src/gajim/`) та стандартний каталог тестів `tests/`
- Коміт злиття: `444b9b4b4 Merge upstream changes from gitlab.com/gajim/gajim (v2.6.0)`

Зміни з офіційного репозиторію отримуються напряму з `gitlab.com/gajim/gajim.git`, проходять перевірку, вирішення конфліктів та тестування на локальних збірках.

## Покращення форку та архітектурні межі

1. **Стійкість мережевого з'єднання**:
   - `src/gajim/common/client_connectivity.py`: забезпечує коректну перевірку доступності та плавний реконект при використанні модифікованих чи попередніх версій `nbxmpp`.
2. **Форматування тексту повідомлень**:
   - `src/gajim/common/styling.py`, `src/gajim/gtk/message_input.py`, `src/gajim/gtk/conversation/plain_widget.py`: покращене приховування службових маркерів форматування та збереження пробільних символів.
3. **Багатоплатформне пакування та конвеєри релізів**:
   - **Linux**: збирання автономного AppImage за допомогою `linuxdeploy` / `appimagetool` та портативного архіву `tar.zst` (`linux/build-portable.sh`, `linux/gajim.spec`).
   - **Flatpak**: автоматична генерація автономного однофайлового Flatpak-бандла на базі платформи GNOME 51 з модульним `python3-modules.json` (`.forgejo/scripts/build-flatpak.sh`, `flatpak/`).
   - **Windows**: збирання у середовищі MSYS2 UCRT64 з формуванням інсталятора NSIS та пакетів для Microsoft Store (MSIX) (`win/build.sh`, `win/_base.sh`).
   - **macOS**: ізольоване віртуальне середовище Python для Apple Silicon (`arm64`, macOS 15+) зі створенням образу DMG (`mac/gajim-macos-helper.sh`, `mac/gajim.spec`).
4. **Автоматизація CI/CD та релізи GitHub**:
   - Централізований робочий процес ([`.github/workflows/build-release.yml`](.github/workflows/build-release.yml)), що збирає пакунки для всіх платформ, генерує контрольні суми SHA-256 та публікує релізи на GitHub.

## Політика гілок та випусків

- **`master`**: основна гілка розробки, що підтримується у стабільному стані.
- **Теги `gajim-*`**: релізні теги (наприклад, `gajim-2.6.0.1-sommelier.1`), що запускають повне збирання та публікацію пакунків.

## Локальне середовище розробки

Відтворюване середовище на базі Nix (`shell.nix`):
```bash
nix-shell .github/nix/shell.nix
uv sync
uv run python -m pytest tests/common/test_client.py tests/common/test_styling.py
uv run ruff check src/
uv build
```
