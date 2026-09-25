#!/usr/bin/env bash
# Rebuild the C / C++ / asm / systems-programming lab on a fresh iximiuz
# Ubuntu playground. Safe to re-run.
set -euo pipefail
DOT="$(cd "$(dirname "$0")" && pwd)"

echo "== packages"
sudo apt-get update -qq
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
  build-essential gcc-multilib clang clangd clang-format clang-tidy cppcheck bear \
  make cmake ninja-build meson nasm \
  gdb gdbserver lldb rr valgrind strace ltrace linux-perf bpftrace hyperfine tcpdump \
  dwarves hexyl entr libc6-dbg \
  manpages-dev manpages-posix manpages-posix-dev \
  python3-venv python3-pip

echo "== locale (the Mac sends LANG=en_IN.UTF-8 over SSH)"
sudo locale-gen en_IN.UTF-8 en_US.UTF-8 >/dev/null

echo "== symlinks"
link() { mkdir -p "$(dirname "$2")"; ln -sfn "$1" "$2"; echo "  $2 -> $1"; }
link "$DOT/tmux/.tmux.conf"          ~/.tmux.conf
link "$DOT/gdb/.gdbinit"             ~/.gdbinit
link "$DOT/lldb/.lldbinit"           ~/.lldbinit
link "$DOT/pi/settings.json"         ~/.pi/agent/settings.json
link "$DOT/agents/skills/herdr"      ~/.claude/skills/herdr
link "$DOT/agents/skills/herdr"      ~/.pi/agent/skills/herdr

echo "== zsh"
line="source $DOT/zsh/dev.zsh"
grep -qxF "$line" ~/.zshrc 2>/dev/null || printf '\n%s\n' "$line" >> ~/.zshrc

echo "== herdr"
if command -v herdr >/dev/null; then
  herdr --skill > "$DOT/agents/skills/herdr/SKILL.md"   # keep skill in sync with the binary
  herdr integration install claude
  herdr integration install pi
else
  echo "  herdr not installed: curl -fsSL https://herdr.dev/install.sh | sh, then re-run"
fi

echo "done. Open a new shell (or: source ~/.zshrc)."
