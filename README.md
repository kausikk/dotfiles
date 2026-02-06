## Setup

### nvim

- neovim >= 0.12
- [tree-sitter-cli](https://github.com/tree-sitter/tree-sitter/blob/master/crates/cli/README.md)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- build tools (make + c compiler)
    - mac: [xcode cli tools](https://developer.apple.com/documentation/xcode/installing-the-command-line-tools/)
    - linux: build-essential
    - windows: [mingw-w64](https://www.mingw-w64.org/)

### systemd/rclone

- plocate
    - use `plocate -d /var/lib/plocate/plocate.db:/var/lib/plocate/gdrive.db ...`
    - set `user_allow_other` in `/etc/fuse.conf`
    - add to `/etc/updatedb.conf`: `.venv`, `.../.cache/uv`, `.../.cache/rclone`, and more
- rclone
    - setup google drive [remote](https://rclone.org/drive/) at `/mnt/gdrive`
    - place *.service and *.timer in `/etc/systemd/system`

### niri

- kitty
- fish
- dex/dex-autostart
- [fzf](https://github.com/junegunn/fzf)
- [fre](github.com/camdencheek/fre)
- wl-clipboard
- for mac, [modify kernel params](https://www.reddit.com/r/AsahiLinux/comments/1iuhxy5/how_to_remap_modifier_keys_in_asahi_gnome/)
to remap cmd, fn, ctrl, and opt:
    - [hid_apple](https://github.com/torvalds/linux/blob/master/drivers/hid/hid-apple.c#L55-L81)
    - `sudo grubby --args=hid_apple.swap_fn_leftctrl=1 --update=ALL`
    - `sudo grubby --args=hid_apple.swap_opt_cmd=1 --update=ALL`
