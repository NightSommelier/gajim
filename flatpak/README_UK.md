# Встановлення Gajim через Flatpak

[English Documentation](README.md)

---

## Встановлення стабільної версії

Перед встановленням переконайтеся, що у вашій системі налаштовано [Flatpak](https://flatpak.org/setup/).

Для взаємодії з файловою системою (наприклад, для надсилання файлів) рекомендується встановити відповідний портал робочого столу (`xdg-desktop-portal-gnome`, `xdg-desktop-portal-gtk` або `xdg-desktop-portal-kde`).

### Встановлення з Flathub

```bash
flatpak install --user https://flathub.org/repo/appstream/org.gajim.Gajim.flatpakref
```

### Встановлення розширень (Plugins)

Пошук доступних плагінів:

```bash
flatpak search gajim.plugin
```

Встановлення плагіна (наприклад, PGP):

```bash
flatpak install --user flathub org.gajim.Gajim.Plugin.pgp
```

*Після встановлення розширень перезапустіть Gajim.*

---

## Збирання нічної збірки (Nightly)

Переконайтеся, що у системі встановлено `flatpak-builder`:

```bash
./make.py flatpak
flatpak run org.gajim.Gajim.Devel
```

---

## Міграція даних

У разі переходу на версію Flatpak ви можете скопіювати наявні профілі, облікові записи та історію:

- Каталог даних: скопіюйте `~/.local/share/gajim` -> `~/.var/app/org.gajim.Gajim/data/gajim`
- Каталог налаштувань: скопіюйте `~/.config/gajim` -> `~/.var/app/org.gajim.Gajim/config/gajim`

---

## Використання власних сертифікатів (Self-signed CA)

Бібліотека HTTP у Gajim використовує OpenSSL. Для надання доступу до системних CA використовуйте оверрайд:

```bash
flatpak override --user --filesystem=host-etc:ro --env=SSL_CERT_FILE=/run/host/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem org.gajim.Gajim
```
