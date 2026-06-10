# emacs → lem

A faithful port of my Nix-managed Emacs configuration
(`~/proj/nix/computer/home/config/emacs`, ~9,100 lines of elisp, ~100 packages)
to [Lem](https://github.com/lem-project/lem), the Common Lisp editor —
terminal (ncurses) frontend, multi-threaded SBCL image.

## Layout

| Path | Purpose |
|---|---|
| `lem/` | The Lem configuration (modular, mirrors the Emacs init structure) |
| `docs/emacs-inventory.md` | Extracted feature inventory of the Emacs config |
| `docs/lem-capabilities.md` | Survey of Lem's real APIs (grounded in source) |
| `docs/port-map.md` | Emacs package → Lem equivalent mapping + gap report |
| `scripts/` | tmux-based TUI test harness |
| `vendor/lem` | Lem source clone (gitignored; used for builds + API grounding) |

## Build / install Lem

Lem is not in nixpkgs; it ships its own flake:

```sh
git clone --depth 1 https://github.com/lem-project/lem vendor/lem
nix build ./vendor/lem#lem-ncurses -o result-lem
./result-lem/bin/lem
```

The config is wired in via `~/.config/lem/init.lisp`, which loads the modules
from `lem/` in this repo.

## Testing

```sh
scripts/lem-tui-test.sh   # boots lem in tmux, asserts clean config load + key workflows
```
