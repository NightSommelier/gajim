# Інсталятор та розробка для Windows

Для створення інсталятора Windows та розробки у середовищі Windows використовується [MSYS2](https://www.msys2.org/).

[English Documentation](README.md)

---

## Розробка під Windows

1. Завантажте та встановіть [MSYS2](https://www.msys2.org/) (`msys2-x86_64-*.exe`).
2. Запустіть оболонку: `C:\msys64\msys2_shell.cmd -ucrt64`.
3. Встановіть Git: `pacman -S git`.
4. Склонуйте репозиторій:
   ```bash
   git clone https://github.com/NightSommelier/gajim.git
   cd gajim
   ```
5. Створіть віртуальне оточення з доступом до системних пакетів MSYS2:
   ```bash
   python -m venv .venv --system-site-packages
   source .venv/bin/activate
   ```
6. Встановіть необхідні залежності:
   ```bash
   ./win/dev_env.sh
   ```
7. Встановіть Gajim у режимі розробки:
   ```bash
   pip install -e .
   ```
8. Запустіть Gajim: `gajim`.

### GTK Inspector

Для увімкнення інспектора GTK додайте запис у реєстр Windows:

```text
HKEY_CURRENT_USER\Software\GSettings\org\gtk\gtk4\settings\debug
DWORD (32 bits) enable-inspector-keybinding = 1
```

Після цього натисніть `CTRL + SHIFT + I` для виклику інспектора.

---

## Збирання інсталятора

Виконайте кроки розділу розробки, але замість `./win/dev_env.sh` запустіть:

```bash
./win/build.sh
```

Готові файли інсталятора та портативної версії з'являться у каталозі `win/_build_root`.

---

## Тестування пакета MSIX

1. Зберіть MSIX-бандл за допомогою `./win/build.sh` або завантажте нічну збірку `Gajim.msixbundle`.
2. Розпакуйте пакет: `./win/unpack_msixbundle.sh`.
3. Відкрийте каталог `win/_build_root/unpack/Gajim` у PowerShell.
4. Зареєструйте застосунок:
   ```powershell
   Add-AppxPackage -Register AppxManifest.xml
   ```
