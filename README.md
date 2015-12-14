file2syslog
===========

Tail a bunch of files and forward them to syslog. It is functionnaly equivalent to :

  tail -f file ... |syslog -p user.info

... but with a bunch of useful features :

* allows you to assign a specific "ident" for every logfile (or group of logfiles)
* allows you to automatically track logfiles which appear and disappear
* properly handle various logfile manipulations (rotate, truncate, remove, rename)
* properly saves what's already been parsed upon stop/restart and never forward
  the same log line twice
* easy to run as a service from init.d/Supervisor/Systemd
* low fat Perl program (8 MB memory)

This program has been developped to replace [rsyslog v5's
imfile](http://www.rsyslog.com/doc/v5-stable/configuration/modules/imfile.html)
which was not handling logfile truncature (which is a common rotation mode for
application logs which do not handle logfile reopening), was way to verbose to
configure and needed to be reconfigured and restarted every time a logfile was
added, removed or renamed.

In other words, this programs allows you to :

* avoid modifying your syslogd configuration
* avoid finding a way for every daemon/app to send logs to syslog

If you have logfiles, you'll still need to rotate them, but logrotate is as
easy as file2syslog to configure (allows globbing, grouping, missing logfiles,
and so on).


Usage
-----

Usage: file2syslog [options] logfile[ tag] ...

    Options :
      -a|--address ADDR        (default: /dev/log)
      -d|--debug
      -f|--facility FACILITY   (default: user)
      -p|--priority PRIO       (default: info)
      -l|--list file
      -s|--scan-period SECONDS (default: 10)
      -t|--state-file FILE

Logfiles are either given as args or either read from a file. Both sources are
merged. Wildcards are authorized in file names. Files may be 'tagged'
(replacing syslog ident) by appending the file name with a word (either from
arg or list file) :

    file2syslog 'rails-app.log rails'

If you don't provide a statefile, this program will re-issue already parsed
lines upon restart. Otherwise, state is automatically read at startup and saved
if program is interrupted.

This program supports logging to the regular /dev/log Unix socket, but may also
open a TCP connection to a host:port address. At this time the TCP handler does
not auto-reconnect.


Logmatic
--------

With rsyslog, declare **/etc/rsyslog.d/logmatic.conf** (replace AUTH-TOKEN with
yours and customize 'metas' as you wish) :

    $template LogmaticFormat,"AUTH-TOKEN <%pri%>%protocol-version% %timestamp:::date-rfc3339% %HOSTNAME% %app-name% - - [metas env=\"preprod\"] %msg%\n"
    *.* @@api.logmatic.io:10514;LogmaticFormat

And exclude the 'local7' facility from the catchall logs if you don't want to
relog locally the tailed files, modify /etc/rsyslog.conf as :

    *.*;auth,authpriv,local7.none      -/var/log/syslog
    ...
    *.=debug;\
            auth,authpriv.none;\
            news.none;mail,local7.none -/var/log/debug
    ...
    *.=info;*.=notice;*.=warn;\
            auth,authpriv.none;\
            cron,daemon.none;\
            news,local7.none           -/var/log/messages

Don't forget to restart rsyslog to take the new settings into account :

    service rsyslog restart

Then relay your files with :

    file2syslog -f local7 [-l list] file ...

They will be fed to you local syslog, not logged locally, and immediatly bounced
to the Logmatic endpoint.

