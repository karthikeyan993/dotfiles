# Intel syntax everywhere: matches nasm, CS Primer, and Computer Enhance.
set disassembly-flavor intel

set print pretty on
set pagination off
set history save on
set history size 10000
set history remove-duplicates unlimited
set history filename ~/.gdb_history

# Fetch symbols and source for system libraries (e.g. step into printf)
# without the interactive "Enable debuginfod?" prompt.
set debuginfod enabled on

# Let per-exercise .gdbinit files under ~/study load automatically.
add-auto-load-safe-path ~/study

# Handy while learning asm: `tui layout asm`, `tui layout regs`, `tui layout split`.
# Exit the TUI with C-x a.
