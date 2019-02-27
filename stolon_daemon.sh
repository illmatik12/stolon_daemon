#!/bin/bash
# Stolon : start and stop script
#

. /etc/rc.d/init.d/functions

################# STOLON 
pname2="stolon-sentinel"
exe2="/home/agens/Stolon/bin/stolon-sentinel"
pidfile2="/home/agens/Stolon/stolon-sentinel.pid"
lockfile2="/home/agens/Stolon/stolon-sentinel.lock"
args2="--cluster-name=agens-ee-stolon-cluster --store-backend=etcdv3"

pname3="stolon-keeper"
exe3="/home/agens/Stolon/bin/stolon-keeper"
pidfile3="/home/agens/Stolon/stolon-keeper.pid"
lockfile3="/home/agens/Stolon/stolon-keeper.lock"
args3="--cluster-name=agens-ee-stolon-cluster --store-backend=etcdv3 \
--uid=agens0 --data-dir=$HOME/Stolon/data/agens0 --pg-su-password='1234' \
--pg-repl-username=repl --pg-repl-password='1234' --pg-bin-path=$HOME/AgensGraph/bin \
--pg-port=5532 --pg-listen-address=192.168.141.101"

pname4="stolon-proxy"
exe4="/home/agens/Stolon/bin/stolon-proxy"
pidfile4="/home/agens/Stolon/stolon-proxy.pid"
lockfile4="/home/agens/Stolon/stolon-proxy.lock"
args4="--cluster-name=agens-ee-stolon-cluster --log-level=warn --store-backend=etcdv3 \
--port=5432 --listen-address=192.168.141.101"

echo $args

[ -x $exe ] || exit 0

RETVAL=0

start() {
    echo -n "Starting $pname2 : "
    #daemon ${exe} # Not working ...
    if [ -s ${pidfile2} ]; then
       RETVAL=1
       echo -n "Already running !" && warning
       echo
    else
       nohup ${exe2} ${args2} >/dev/null 2>&1 &
       RETVAL=$?
       PID=$!
       [ $RETVAL -eq 0 ] && touch ${lockfile2} && success || failure
       echo
       echo $PID > ${pidfile2}
    fi

    echo -n "Starting $pname3 : "
    #daemon ${exe} # Not working ...
    if [ -s ${pidfile3} ]; then
       RETVAL=1
       echo -n "Already running !" && warning
       echo
    else
       nohup ${exe3} ${args3} >/dev/null 2>&1 &
       RETVAL=$?
       PID=$!
       [ $RETVAL -eq 0 ] && touch ${lockfile3} && success || failure
       echo
       echo $PID > ${pidfile3}
    fi

    echo -n "Starting $pname4 : "
    #daemon ${exe} # Not working ...
    if [ -s ${pidfile4} ]; then
       RETVAL=1
       echo -n "Already running !" && warning
       echo
    else
       nohup ${exe4} ${args4} >/dev/null 2>&1 &
       RETVAL=$?
       PID=$!
       [ $RETVAL -eq 0 ] && touch ${lockfile4} && success || failure
       echo
       echo $PID > ${pidfile4}
    fi
}

stop() {

    echo -n "Shutting down $pname2 : "
    killproc ${exe2}
    RETVAL=$?
    echo
    if [ $RETVAL -eq 0 ]; then
        rm -f ${lockfile2}
        rm -f ${pidfile2}
    fi

    echo -n "Shutting down $pname3 : "
    killproc ${exe3}
    RETVAL=$?
    echo
    if [ $RETVAL -eq 0 ]; then
        rm -f ${lockfile3}
        rm -f ${pidfile3}
    fi

    echo -n "Shutting down $pname4 : "
    killproc ${exe4}
    RETVAL=$?
    echo
    if [ $RETVAL -eq 0 ]; then
        rm -f ${lockfile4}
        rm -f ${pidfile4}
    fi
}

restart() {
    echo -n "Restarting $pname2 $pname3 $pname4  : "
    stop
    sleep 2
    start
}

case "$1" in
    start)
        start
    ;;
    stop)
        stop
    ;;
    status)
        status ${pname2}
        status ${pname3}
        status ${pname4}
    ;;
    restart)
        restart
    ;;
    *)
        echo "Usage: $0 {start|stop|status|restart}"
    ;; esac

exit 0