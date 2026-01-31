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
- rclone
    - setup google drive [remote](https://rclone.org/drive/) at `/mnt/gdrive`
    - set `user_allow_other` in `/etc/fuse.conf`
    - place *.service and *.timer in `/etc/systemd/system`
