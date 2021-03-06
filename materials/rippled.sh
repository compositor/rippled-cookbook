#!/bin/bash

### BEGIN INIT INFO
# Provides:          ripple
# Required-Start:    $local_fs $remote_fs $network $syslog
# Required-Stop:     $local_fs $remote_fs $network $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: starts the ripple network node
# Description:       starts rippled using start-stop-daemon
### END INIT INFO

NAME=rippled
USER="rippled"
GROUP="rippled"
PIDFILE=/var/run/$NAME.pid
DAEMON=/usr/bin/rippled
DAEMON_OPTS="--conf /etc/rippled/rippled.cfg"
NET_OPTS="--net $DAEMON_OPTS"
LOGDIR="/var/log/rippled"
STOP_LOOPS=30

. /lib/lsb/init-functions

# Read configuration variable file if one exists.  Note that this can
# potentially change the values of variables defined earlier in this script.
[ -r /etc/default/$NAME ] && . /etc/default/$NAME

# Stop rippled.
stop() {
  PID=$(pidofproc -p $PIDFILE $DAEMON)
  if [ ! $? -eq 0 ]; then
    exit 0
  fi
	echo -n "Stopping daemon: "$NAME

  $DAEMON $DAEMON_OPTS stop 2>/dev/null >/dev/null

  if [ ! $? -eq 0 ];then
    # Stop command failed for some reason. Kill it by hand.
    killproc -p $PIDFILE $DAEMON KILL
  fi

  # Wait for rippled to shut down.
	loop=1
	while [[ $loop -le ${STOP_LOOPS:-0} ]]; do
    PID=$(pidofproc -p $PIDFILE $DAEMON)
    if [ ! $? -eq 0 ];then
      break
    fi
		((loop++))
		echo -n "."
		sleep 1
	done

  pkill -9 -f $DAEMON

  rm -f $PIDFILE

	echo "."
}

# Start rippled.
start() {
  PID=$(pidofproc -p $PIDFILE $DAEMON)
  if [ $? -eq 0 ];then
    exit 0
  fi
	echo -n "Starting daemon: "$NAME

        # Actually start rippled.
  mkdir -p $LOGDIR
  chown -R $USER:$GROUP $LOGDIR

	start-stop-daemon --start --quiet --background -m --pidfile $PIDFILE \
            --exec $DAEMON --chuid $USER --group $GROUP -- $NET_OPTS
	echo "."
}

case "$1" in
    start)
        start
        ;;

    stop)
        stop
        ;;

    restart)
	stop
	start
        ;;

    status)
        echo "Status of $NAME:"
        echo "PID of $NAME: "
        if [ -f "$PIDFILE" ]; then
                cat $PIDFILE
                $DAEMON $DAEMON_OPTS server_info
        else
                echo "$NAME not running."
        fi
    ;;

    fetch)
        echo "$NAME ledger fetching info:"
        $DAEMON $DAEMON_OPTS fetch_info
        ;;

    uptime)
        echo "$NAME uptime:"
        $DAEMON $DAEMON_OPTS get_counts
        ;;

    startconfig)
        echo "$NAME is being started with the following command line:"
        echo "$DAEMON $NET_OPTS"
        ;;

    command)
        # Truncate the script's argument vector by one position to get rid of
        # this entry.
        shift

        # Pass the remainder of the argument vector to rippled.
        $DAEMON $DAEMON_OPTS "$@"
        ;;

    test)
        $DAEMON $DAEMON_OPTS ping
        ;;

    # Undocumented command that deletes rippled's databases.
    clean)
        # Extract the location of the config file.
        CONFIG=`echo $DAEMON_OPTS | awk '{print $2}'`

        # Stop rippled.
        stop

        # Extract the location of the node_db.
        NODE_DB=`grep '^path' $CONFIG | awk -F= '{print $2}'`

        # Extract the location of the peer and path databases.
        PEER_DB=`grep -A1 'database_path' $CONFIG | tail -1`

        # Delete the node database.
        rm -f $NODE_DB/* 2>/dev/null

        # Delete the peering and path databases.
        rm -f $PEER_DB/* 2>/dev/null

        # Start rippled.
        start
        ;;

    *)
        echo "Usage: $0 {start|stop|restart|status|fetch|uptime|startconfig|"
        echo "           command|test}"
        exit 1
esac

exit 0