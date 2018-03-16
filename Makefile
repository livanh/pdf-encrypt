prefix=/usr/local

all:

install:
	mkdir -p $(DESTDIR)$(prefix)/bin
	install -m 755 src/bin/pdf-encrypt.sh $(DESTDIR)$(prefix)/bin
	mkdir -p $(DESTDIR)$(prefix)/share/applications
	install -m 644 src/share/applications/pdf-encrypt.desktop $(DESTDIR)$(prefix)/share/applications

.PHONY: install all

