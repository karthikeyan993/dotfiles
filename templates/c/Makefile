# Starter Makefile for small C exercises (copied into place by `newc`).
#   make          debug build   -> ./<dir>
#   make release  optimized     -> ./<dir>-release   (use this with perf, valgrind, rr)
#   make run      debug build, then run it
#   make asm      Intel-syntax .s for each .c file, optimized (like godbolt)
#   make clean
#
# Debug and release get different names, so switching between them can't
# leave a stale binary that silently lacks the flags you expect.

CC     := clang
TARGET := $(notdir $(CURDIR))
SRCS   := $(wildcard *.c)
HDRS   := $(wildcard *.h)

CFLAGS_COMMON  := -std=c17 -g

# TODO(human): choose your default debug-build flags
CFLAGS_DEBUG   := $(CFLAGS_COMMON)

CFLAGS_RELEASE := $(CFLAGS_COMMON) -O2 -march=native -fno-omit-frame-pointer

.PHONY: all release run asm clean

all: $(TARGET)
release: $(TARGET)-release

$(TARGET): $(SRCS) $(HDRS)
	$(CC) $(CFLAGS_DEBUG) $(SRCS) -o $@ $(LDLIBS)

$(TARGET)-release: $(SRCS) $(HDRS)
	$(CC) $(CFLAGS_RELEASE) $(SRCS) -o $@ $(LDLIBS)

run: $(TARGET)
	./$(TARGET)

asm: $(SRCS:.c=.s)

%.s: %.c
	$(CC) $(CFLAGS_RELEASE) -g0 -S -masm=intel -fno-asynchronous-unwind-tables $< -o $@

clean:
	rm -f $(TARGET) $(TARGET)-release *.o *.s core core.*
