# ShellBeats Makefile — with Termux (Android) support
CC = gcc
CFLAGS = -std=c17 -Wall -Wextra -O2 -pthread

UNAME_S := $(shell uname -s)
UNAME_O := $(shell uname -o 2>/dev/null || echo "")

ifeq ($(UNAME_S),Darwin)
    # macOS: Homebrew paths + plain ncurses (already wide-char on macOS).
    BREW_PREFIX := $(shell brew --prefix 2>/dev/null || echo /opt/homebrew)
    CFLAGS  += -I$(BREW_PREFIX)/include -I$(BREW_PREFIX)/opt/ncurses/include
    LDFLAGS  = -L$(BREW_PREFIX)/lib -L$(BREW_PREFIX)/opt/ncurses/lib -lncurses -lcurl -lcjson -pthread
else ifneq ($(filter Android,$(UNAME_O)),)
    # Termux on Android: prefix is /data/data/com.termux/files/usr
    TERMUX_PREFIX ?= /data/data/com.termux/files/usr
    CFLAGS  += -I$(TERMUX_PREFIX)/include
    LDFLAGS  = -L$(TERMUX_PREFIX)/lib -lncursesw -lcurl -lcjson -pthread
    INSTALL_DIR = $(TERMUX_PREFIX)/bin
else
    # Linux: needs the wide-char variant explicitly
    LDFLAGS  = -lncursesw -lcurl -lcjson -pthread
    INSTALL_DIR = /usr/local/bin
endif

TARGET = shellbeats
SRC = shellbeats.c youtube_playlist.c surikata_sync.c sb_exec.c

.PHONY: all clean install uninstall termux-deps

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

debug: $(SRC)
	$(CC) $(CFLAGS) -g -DDEBUG -o $(TARGET) $^ $(LDFLAGS)

clean:
	rm -f $(TARGET)

# Install target (auto-detects Termux vs system)
install: $(TARGET)
	install -m 755 $(TARGET) $(INSTALL_DIR)/

uninstall:
	rm -f $(INSTALL_DIR)/$(TARGET)

# Convenience target: install all Termux dependencies
termux-deps:
	pkg update -y
	pkg install -y git clang make libcurl libcjson ncurses mpv yt-dlp
	@echo ""
	@echo "All dependencies installed. Run: make && make install"
