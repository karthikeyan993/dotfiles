# C / systems-programming shell setup. Sourced from ~/.zshrc after oh-my-zsh.

export EDITOR=nvim VISUAL=nvim

# Debug symbols + source for system libraries, used by gdb, valgrind, and perf.
export DEBUGINFOD_URLS="https://debuginfod.ubuntu.com"

# Crashes write ./core.<pid>, so `gdb ./prog core.<pid>` works.
ulimit -c unlimited

(( $+commands[herdr] )) && eval "$(herdr completion zsh)"

# Disassemble with Intel syntax, keeping raw bytes (useful for the 8086 decoder).
dis() { objdump -d -M intel -C "$@" }

# labref: open the cheat sheet for this playground.
labref() { nvim -R ~/dotfiles/CHEATSHEET.md }

# newc <dir>: start a C exercise from ~/dotfiles/templates/c.
newc() {
  [[ -z $1 ]] && { echo "usage: newc <dir>"; return 1 }
  [[ -e $1 ]] && { echo "newc: $1 already exists"; return 1 }
  cp -r ~/dotfiles/templates/c "$1" && cd "$1" && ls
}
