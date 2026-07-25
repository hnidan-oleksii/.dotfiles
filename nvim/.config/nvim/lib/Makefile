ARCH := $(shell uname -m)
TARGET := libansi-$(ARCH).so

$(TARGET): ansi.c
	$(CC) -O2 -shared -fPIC -Wall -Wextra -o $@ $<
	strip $@

.PHONY: clean
clean:
	rm -f libansi-*.so
