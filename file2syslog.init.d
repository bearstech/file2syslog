#!/bin/sh -e

### BEGIN INIT INFO
# Provides:          file2syslog
# Required-Start:    $remote_fs
# Required-Stop:     $remote_fs
# Should-Start:      $network $syslog
# Should-Stop:       $network $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start and stop file2syslog
# Description:       file2syslog is a logging agent
### END INIT INFO

. /lib/lsb/init-functions

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/opt/file2syslog
DAEMON=/usr/sbin/file2syslog
DAEMON_OPTS="-l /etc/file2syslog.conf -t /var/spool/file2syslog/state"
NAME=file2syslog
PIDFILE=/var/run/file2syslog.pid
RUNAS=file2syslog

test -x $DAEMON || exit 0

# Get lsb functions
. /lib/lsb/init-functions

case "$1" in
  start)
        log_daemon_msg "Starting $NAME"
        start-stop-daemon --start --quiet --user $RUNAS --make-pidfile --pidfile $PIDFILE \
                --exec $DAEMON -- $DAEMON_OPTS
        log_end_msg $?
        ;;
  stop)
        log_daemon_msg "Stopping $NAME"
        start-stop-daemon --stop --oknodo --quiet --user $RUNAS --remove-pidfile --pidfile $PIDFILE \
                --exec $DAEMON
        log_end_msg $?
        ;;
  restart)
        log_daemon_msg "Restarting $NAME"
        start-stop-daemon --stop --oknodo --quiet --user $RUNAS --remove-pidfile --pidfile $PIDFILE \
                --exec $DAEMON
        sleep 1
        start-stop-daemon --start --quiet --user $RUNAS --make-pidfile --pidfile $PIDFILE \
                --exec $DAEMON -- $DAEMON_OPTS
        log_end_msg $?
        ;;
esac

exit 0
