PREFIX=/usr/local

install:
	install -m 755 src/bin/pdf-encrypt.sh $(PREFIX)/bin
	install -m 644 src/share/applications/pdf-encrypt.desktop $(PREFIX)/share/applications

.PHONY: install
