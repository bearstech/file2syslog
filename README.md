file2syslog
===========

Tail a bunch of files and forward them to syslog.

Usage
-----


Logmatic
--------

With rsyslog, declare /etc/rsyslog.d/logmatic.conf (replace AUTH-TOKEN with
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

They will be fed to you local syslog, not logged localy, and immediatly bounced
to the Logmatic endpoint.
