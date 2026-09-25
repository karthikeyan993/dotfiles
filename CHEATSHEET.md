# C lab cheat sheet

Quick reference for this playground: Ubuntu 26.04, x86-64 AMD EPYC (Zen, AVX2 + AVX-512, invariant TSC
at about 4.19 GHz), 4 vCPU, 10 GB RAM. You reach it from the Mac over SSH and always work inside herdr.
Open this file from any pane with `labref`.

## Where things live

| What | Where |
|---|---|
| Your exercises | `~/study/` (git repo; its `AGENTS.md` is the only agent context) |
| herdr skill for agents | `~/dotfiles/agents/skills/herdr/` (linked into `~/.claude/skills/` and `~/.pi/agent/skills/`) |
| gdb / lldb config | `~/dotfiles/gdb/.gdbinit`, `~/dotfiles/lldb/.lldbinit` |
| Shell additions | `~/dotfiles/zsh/dev.zsh` (sourced by `~/.zshrc`) |
| Exercise template | `~/dotfiles/templates/c/` |
| Rebuild everything on a fresh playground | `~/dotfiles/setup.sh` |

Edit configs in `~/dotfiles`, then commit and push so a fresh playground can get them back.

## Starting an exercise

```sh
cd ~/study/c && newc hello       # copy the template into ./hello and cd there
make run                       # debug build (./hello), then run it
make release                   # optimized build (./hello-release): use with perf, valgrind, rr
make asm                       # main.s in Intel syntax, optimized, no debug noise
make clean
ls *.c *.h | entr -c make run  # rebuild and rerun on every save (good in a side pane)
bear -- make                   # compile_commands.json for clangd on bigger projects
```

The debug flags live in `CFLAGS_DEBUG` in `~/dotfiles/templates/c/Makefile`.

## Compiling by hand

```sh
clang -std=c17 -g -O0 -Wall -Wextra foo.c -o foo
clang -g -fsanitize=address,undefined foo.c -o foo   # out-of-bounds, use-after-free, UB
clang -g -fsanitize=thread foo.c -o foo              # data races
clang -g -fsanitize=memory foo.c -o foo              # uninitialized reads (clang only)
clang -O2 -march=native -g foo.c -o foo              # fast, still debuggable
clang++ -std=c++23 foo.cpp -o foo
gcc -m32 foo.c -o foo32                              # 32-bit build works too
```

Don't mix ASan/MSan with valgrind, rr, or perf. Use a build without sanitizers for those.

## Assembly

```sh
nasm -felf64 prog.asm -o prog.o && ld prog.o -o prog        # standalone x86-64, raw syscalls
nasm -felf64 f.asm -o f.o && clang main.c f.o -o main       # asm function called from C
nasm listing.asm -o listing.bin && xxd listing.bin          # 8086 listing (bits 16) to raw bytes
cmp ref.bin mine.bin                                        # check your 8086 decoder round-trips
dis ./prog | less                                           # objdump -d -M intel -C
clang -O2 -S -masm=intel foo.c -o -                         # see what the compiler generates
```

Linux x86-64 syscalls: number in `rax`, args in `rdi rsi rdx r10 r8 r9`.
`write` = 1, `exit` = 60, `mmap` = 9. Look any up with
`grep -w __NR_openat /usr/include/x86_64-linux-gnu/asm/unistd_64.h`.

## Debugging

```sh
gdb ./prog                 # Intel syntax, history, and system-library symbols are preconfigured
```

| gdb | Does |
|---|---|
| `b main` / `b file.c:42` | breakpoint |
| `r`, `c`, `n`, `s`, `finish` | run, continue, next line, step into, run to return |
| `si`, `ni` | step one instruction (into / over calls) |
| `p x`, `p/x x`, `x/16xb ptr`, `x/4gx $rsp` | print value, hex, examine memory |
| `info registers`, `p $rax` | registers |
| `bt`, `frame 2`, `info locals` | call stack |
| `watch x` | stop when `x` changes |
| `tui layout asm` / `regs` / `split`, then `C-x a` to leave | source, disassembly, and register views |

```sh
gdb ./prog core.<pid>      # post-mortem: crashes leave core.<pid> in the working directory
rr record ./prog && rr replay
                           # then: reverse-next, reverse-step, reverse-continue, reverse-finish
lldb ./prog                # if you're following a Mac-based video
valgrind ./prog            # memcheck: leaks and invalid reads/writes (build without ASan)
```

rr is reliable for single-threaded programs only here. The fix it needs for AMD Zen can't be
applied inside this VM, so rr prints a warning each time; that's expected.

## Performance (Computer Enhance)

```sh
perf stat ./prog-release                                        # cycles, instructions, IPC
perf stat -e cycles,instructions,cache-misses,branch-misses,page-faults ./prog-release
perf record -g ./prog-release && perf report                    # where time goes
valgrind --tool=cachegrind --cache-sim=yes ./prog-release       # simulated cache misses
hyperfine './a' './b'                                           # compare two programs
```

Hardware counters work in this VM, which many VMs don't allow.

## Systems programming

```sh
man 2 read          # syscalls
man 3 printf        # C library
man 3p pthread_create  # POSIX spec version
man unistd.h        # POSIX header
strace ./prog       # every syscall;  strace -c ./prog  for a summary;  -f follows children
ltrace ./prog       # library calls
pahole foo.o        # struct layout, holes, and padding (compile with -g)
sudo tcpdump -i any -n port 8080
sudo bpftrace -e 'tracepoint:syscalls:sys_enter_openat { printf("%s %s\n", comm, str(args.filename)); }'
hexyl file.bin      # colored hex dump (also: xxd, hexdump -C)
```

## Translating course material to this machine

**CS Primer** (recorded on macOS):

| macOS | Here |
|---|---|
| `nasm -fmacho64` | `nasm -felf64` |
| `_main`, `_printf` | `main`, `printf` (no leading underscore) |
| syscall `0x2000004` (write), `0x2000001` (exit) | `1` (write), `60` (exit) |
| lldb | gdb (lldb is also installed) |

**Computer Enhance** (recorded on Windows/MSVC):

| Windows | Here |
|---|---|
| `__rdtsc()` from `<intrin.h>` | `__rdtsc()` from `<x86intrin.h>` |
| `QueryPerformanceCounter` / `Frequency` | `clock_gettime(CLOCK_MONOTONIC_RAW, &ts)` (nanoseconds) |
| `VirtualAlloc` / `VirtualFree` | `mmap` / `munmap` |
| `GetProcessMemoryInfo` page faults | `getrusage(RUSAGE_SELF, &r)`: `r.ru_minflt`, `r.ru_majflt` |
| reading PMCs via ETW | `perf_event_open(2)`, or run the whole thing under `perf stat` |
| `build.bat` with `cl` / `clang-cl` | `clang -O2 -g -march=native main.c -o main` |

## herdr

- A layout that fits this work: nvim | `entr -c make run` | gdb, as panes in one tab.
- Claude and pi know they're in herdr, and both have the herdr skill. Ask them to "open a pane and run X"
  or "watch the build in a side pane".
- After `herdr update`, re-run `~/dotfiles/setup.sh` to refresh the herdr skill and integrations.

## Fresh playground

```sh
git clone https://github.com/karthikeyan993/dotfiles.git ~/dotfiles && ~/dotfiles/setup.sh
```
