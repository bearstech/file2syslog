default:

install:
	install -D file2syslog $(DESTDIR)/usr/sbin/file2syslog
	install -D -g adm  file2syslog.conf $(DESTDIR)/etc/file2syslog.conf
	if which systemctl >/dev/null 2>/dev/null; then \
		install -D file2syslog.service $(DESTDIR)/lib/systemd/system/file2syslog.service ; \
	else \
	  install -D file2syslog.init.d $(DESTDIR)/etc/init.d/file2syslog ; \
	fi
