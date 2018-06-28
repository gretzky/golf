SCRIPT = golf
MANPAGE = $(SCRIPT).6

PREFIX = /usr/local
DESTDIR = 
INSTDIR = $(DESTDIR)$(PREFIX)
INSTBIN = $(INSTDIR)/bin
INSTMAN = $(INSTDIR)/share/man/man6

all:
	@echo run \'make instzall\' to install golf
.PHONY: all

install:
	mkdir -p $(INSTDIR)
	mkdir -p $(INSTBIN)
	mkdir -p $(INSTMAN)

	install -m 0755 $(SCRIPT) $(INSTBIN)
	install -m 0644 $(MANPAGE) $(INSTMAN)
.PHONY: install

uninstall:
	$(RM) $(INSTBIN)/$(SCRIPT)
	$(RM) $(INSTMAN)$(MANPAGE)
.PHONY: uninstall