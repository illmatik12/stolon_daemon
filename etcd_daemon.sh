#!/bin/bash
# etcd : This starts and stops etcd 
#
# Source function library.
. /etc/rc.d/init.d/functions
################# STOLON 
pname1="etcd"
exe1="/home/agens/Stolon/etcd/etcd"
pidfile1="/home/agens/Stolon/etcd/etcd.pid"
lockfile1="/home/agens/Stolon/etcd/etcd.lock"
args1="
--name=agens-ee-etcd-1 --data-dir=$HOME/Stolon/etcd/data \
--initial-advertise-peer-urls http://192.168.141.101:2380 \
--listen-peer-urls http://192.168.141.101:2380 \
--listen-client-urls http://192.168.141.101:2379,http://127.0.0.1:2379 \
--advertise-client-urls http://192.168.141.101:2379 \
--initial-cluster-token ee-etcd-cluster-1 \
--initial-cluster agens-ee-etcd-1=http://192.168.141.101:2380,agens-ee-etcd-2=http://192.168.141.102:2380,agens-ee-etcd-3=http://192.168.141.103:2380 \
--auto-compaction-retention=1 \
--quota-backend-bytes=$((16*1024*1024*1024)) \
--initial-cluster-state new 
"

[ -x $exe ] || exit 0

RETVAL=0

start() {
    echo -n "Starting $pname : "
    #daemon ${exe} # Not working ...
    if [ -s ${pidfile1} ]; then
       RETVAL=1
       echo -n "Already running !" && warning
       echo
    else
       nohup ${exe1} ${args1} >/dev/null 2>&1 &
       RETVAL=$?
       PID=$!
       [ $RETVAL -eq 0 ] && touch ${lockfile1} && success || failure
       echo
       echo $PID > ${pidfile1}
    fi

}

stop() {
    echo -n "Shutting down $pname1 : "
    killproc ${exe1}
    RETVAL=$?
    echo
    if [ $RETVAL -eq 0 ]; then
        rm -f ${lockfile1}
        rm -f ${pidfile1}
    fi

}

restart() {
    echo -n "Restarting $pname : "
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
        status ${pname1}
    ;;
    restart)
        restart
    ;;
    *)
        echo "Usage: $0 {start|stop|status|restart}"
    ;; esac

exit 0