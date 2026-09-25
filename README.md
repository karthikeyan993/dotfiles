# Dotfiles

Personal configuration for an iximiuz Labs Ubuntu playground used to learn C, C++,
x86-64 assembly, and systems programming (CS Primer, Computer Enhance), always inside herdr.

**Day-to-day reference: [CHEATSHEET.md](CHEATSHEET.md)** (run `labref` to open it).

## Included

| Path | Linked to | What |
|---|---|---|
| `tmux/.tmux.conf` | `~/.tmux.conf` | tmux config (kept, though herdr is the daily driver) |
| `gdb/.gdbinit` | `~/.gdbinit` | Intel syntax, history, debuginfod, `~/study` auto-load |
| `lldb/.lldbinit` | `~/.lldbinit` | Intel syntax |
| `zsh/dev.zsh` | sourced by `~/.zshrc` | `EDITOR`, debuginfod, core dumps, herdr completion, `dis`, `newc` |
| `agents/skills/herdr/` | `~/.claude/skills/herdr`, `~/.pi/agent/skills/herdr` | herdr skill (`herdr --skill`) |
| `templates/c/` | used by `newc <dir>` | Makefile (debug / release / asm), `main.c`, clangd flags |

## Apply on a new machine

```bash
git clone https://github.com/karthikeyan993/dotfiles.git ~/dotfiles
~/dotfiles/setup.sh
```

`setup.sh` is safe to re-run. It installs the toolchain, generates locales, creates the
symlinks, and installs herdr's Claude and pi integrations. Re-run it after `herdr update`
to refresh the herdr skill.
