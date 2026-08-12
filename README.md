# dotfiles

Şahsiy konfiguratsiya fayllarim (alacritty, fastfetch, gnome, helix, nvim, ranger, tmux, vim, wezterm, zed, zsh va h.k.) uçun repozitoriy. `GNU Stow` orqali simlink qilinadi, mahfiy qismlar esa `git-crypt` bilan şifrlanadi.

## 1. Clone qiliş

```sh
git clone git@github.com:mirrrjr/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

## 2. Stow orqali õrnatiş

Har bir papka alohida modul hisoblanadi, kerakli bõlganlarini stow qilib çiqiş mumkin:

```sh
stow alacritty fastfetch gnome helix nvim ranger tmux vim wezterm zed zsh
```

Yoki barçasini birdaniga:

```sh
stow */
```

Agar allaqaçon mavjud fayllar bilan tõqnaşuv (conflict) çiqsa, `stow --adopt <papka>` yordamida eski fayllarni repoga olib kirişingiz yoki qõlda õçirişingiz mumkin.

## 3. git-crypt orqali decrypt qiliş

Repodagi şifrlangan fayllarni oçiş uçun `git-crypt` kaliti kerak bõladi:

```sh
git-crypt unlock /path/to/key
```

Kalit fayl mavjud bõlmasa, GPG orqali ruhsat berilgan bõlişi kerak:

```sh
git-crypt unlock
```

Muvaffaqiyatli decrypt bõlgandan keyin, `.gitattributes`da belgilangan fayllar (masalan, `assets` yoki mahfiy configlar) oçiq holatda kõrinadi.

## 4. Kerak bõlsa yana crypt'laş

Fayllarni qayta şifrlaş kerak bõlsa (masalan, boşqa maşinaga õtiş yoki reponi jamoat uçun oçiş oldidan):

```sh
git-crypt lock
```

Bu buyruq şifrlangan fayllarni yana binary/encrypted holatga qaytaradi. Qayta oçiş uçun 3-qadamni takrorlang.

> **Eslatma:** `git-crypt lock`dan oldin barcha õzgarişlarni commit qiling, aks holda saqlanmagan õzgarişlar yõqolişi mumkin.
