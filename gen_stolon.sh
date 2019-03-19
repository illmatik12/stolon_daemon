#!/bin/bash
# genate etcd startup script
# customize  your enviroment
# version : 0.1
# author : illmatik12


IP_LISTS=(
192.168.141.101 
192.168.141.102
192.168.141.103
)

local_ip=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')

IDX=1
for IP in "${IP_LISTS[@]}"
do

    if [ x$IP == x$local_ip ]; then 
        echo "Configure target host : $IP"
        break
    fi

let IDX++
done 


#echo "${IP_LISTS[0]}"

#IDX=1
#for IP in "${IP_LISTS[@]}"
#do
cat > ag_etcd.sh << EOF
#        echo "$idx : $ip"
#        let idx++

#!/bin/bash
# etcd : This starts and stops etcd 
#
# Source function library.
. /etc/rc.d/init.d/functions

PNAME="etcd"
EXE="/home/agens/Stolon/etcd/etcd"
PIDFILE="/tmp/etcd.pid"
LOCKFILE="/tmp/etcd.lock"
ARGS="
--name=agens-ee-etcd-$IDX --data-dir=$HOME/Stolon/etcd/data \\
--initial-advertise-peer-urls http://$local_ip:2380 \\
--listen-peer-urls http://$local_ip:2380 \\
--listen-client-urls http://$local_ip:2379,http://127.0.0.1:2379 \\
--advertise-client-urls http://$local_ip:2379 \\
--initial-cluster-token ee-etcd-cluster-1 \\
--initial-cluster agens-ee-etcd-1=http://${IP_LISTS[0]}:2380,agens-ee-etcd-2=http://${IP_LISTS[1]}:2380,agens-ee-etcd-3=http://${IP_LISTS[2]}:2380 \\
--auto-compaction-retention=1 \\
--quota-backend-bytes=$((16*1024*1024*1024)) \\
--initial-cluster-state new 
"

LOG_DEST="/home/agens/Stolon/log"

[ -x $exe ] || exit 0

RETVAL=0

start() {
    echo -n "Starting \$PNAME : "
    #daemon ${exe} # Not working ...
    if [ -s \${PIDFILE} ]; then
       RETVAL=1
       echo -n "Already running !" && warning
       echo
    else
       nohup \${EXE} \${ARGS} > \${LOG_DEST}/\${EXE}.out 2>&1 < /dev/null &
       #nohup \${EXE} \${ARGS} >/dev/null 2>&1 &
       #nohup \${EXE} \${ARGS} >  etcd.log &
       #nohup ${EXE} --config-file ${config_file} >${log_dest} 2>&1 &
       #nohup ${EXE} --config-file ${config_file} >${log_dest} &
       RETVAL=\$?
       PID=\$!
       [ \$RETVAL -eq 0 ] && touch \${LOCKFILE} && success || failure
       echo
       echo \$PID > \${PIDFILE}
    fi

}

stop() {
    echo -n "Shutting down \$PNAME : "
    killproc \${EXE}
    RETVAL=\$?
    echo
    if [ \$RETVAL -eq 0 ]; then
        rm -f \${LOCKFILE}
        rm -f \${PIDFILE}
    fi

}

restart() {
    echo -n "Restarting $PNAME : "
    stop
    sleep 2
    start
}

case "\$1" in
    start)
        start
    ;;
    stop)
        stop
    ;;
    status)
        status \${PNAME}
    ;;
    restart)
        restart
    ;;
    *)
        echo "Usage: \$0 {start|stop|status|restart}"
    ;; esac

exit 0


EOF

cat > ag_stolon.sh << EOF
#!/bin/bash
# stolon-sentinel,stolon-keeper,stolon-proxy : This starts and stops stolon daemons
#
# processname: Stolon
# pidfile path: /tmp/$process.pid
# Source function library.
. /etc/rc.d/init.d/functions


################# STOLON 
#Notes: password 입력시 single quote 로그인 오류 발생가능성 있음. 
pname2="stolon-sentinel"
exe2="/home/agens/Stolon/bin/stolon-sentinel"
pidfile2="/tmp/stolon-sentinel.pid"
lockfile2="/tmp/stolon-sentinel.lock"
args2="--cluster-name=agens-ee-stolon-cluster --store-backend=etcdv3"

pname3="stolon-keeper"
exe3="/home/agens/Stolon/bin/stolon-keeper"
pidfile3="/tmp/stolon-keeper.pid"
lockfile3="/tmp/stolon-keeper.lock"
args3="--cluster-name=agens-ee-stolon-cluster --store-backend=etcdv3 \\
--uid=agens$IDX --data-dir=$HOME/Stolon/data/agens$IDX --pg-su-password=1234 \\
--pg-repl-username=repl --pg-repl-password=1234 --pg-bin-path=$HOME/AgensGraph/bin \\
--pg-port=5532 --pg-listen-address=$local_ip"

pname4="stolon-proxy"
exe4="/home/agens/Stolon/bin/stolon-proxy"
pidfile4="/tmp/stolon-proxy.pid"
lockfile4="/tmp/stolon-proxy.lock"
args4="--cluster-name=agens-ee-stolon-cluster --log-level=warn --store-backend=etcdv3 \\
--port=5432 --listen-address=$local_ip"


LOG_DEST="/home/agens/Stolon/log"


[ -x $exe ] || exit 0

RETVAL=0

start() {
    echo -n "Starting \$pname2 : "
    #daemon \${exe} # Not working ...
    if [ -s \${pidfile2} ]; then
       RETVAL=1
       echo -n "Already running !" && warning
       echo
    else
       #echo \${LOG_DEST}/\${exe2}.out
       nohup \${exe2} \${args2} > \${LOG_DEST}/\${pname2}.out 2>&1 < /dev/null &
       RETVAL=\$?
       PID=\$!
       [ \$RETVAL -eq 0 ] && touch \${lockfile2} && success || failure
       echo
       echo \$PID > \${pidfile2}
    fi

    sleep 3
    echo -n "Starting \$pname3 : "
    #daemon \${exe} # Not working ...
    if [ -s \${pidfile3} ]; then
       RETVAL=1
       echo -n "Already running !" && warning
       echo
    else
       #echo ${LOG_DEST}/${exe3}.out
       nohup \${exe3} \${args3} > \${LOG_DEST}/\${pname3}.out 2>&1 < /dev/null &
       #nohup \${exe3} \${args3} >/dev/null 2>&1 &
       RETVAL=\$?
       PID=\$!
       [ \$RETVAL -eq 0 ] && touch \${lockfile3} && success || failure
       echo
       echo \$PID > \${pidfile3}
    fi

    sleep 3
    echo -n "Starting \$pname4 : "
    #daemon \${exe} # Not working ...
    if [ -s \${pidfile4} ]; then
       RETVAL=1
       echo -n "Already running !" && warning
       echo
    else
       nohup \${exe4} \${args4} > \${LOG_DEST}/\${pname4}.out 2>&1 < /dev/null &
       #nohup \${exe4} \${args4} >/dev/null 2>&1 &
       RETVAL=\$?
       PID=\$!
       [ \$RETVAL -eq 0 ] && touch \${lockfile4} && success || failure
       echo
       echo \$PID > \${pidfile4}
    fi
}

stop() {

    echo -n "Shutting down \$pname2 : "
    killproc \${exe2}
    RETVAL=\$?
    echo
    if [ \$RETVAL -eq 0 ]; then
        rm -f \${lockfile2}
        rm -f \${pidfile2}
    fi

    echo -n "Shutting down \$pname3 : "
    killproc \${exe3}
    RETVAL=\$?
    echo
    if [ \$RETVAL -eq 0 ]; then
        rm -f \${lockfile3}
        rm -f \${pidfile3}
    fi

    echo -n "Shutting down \$pname4 : "
    killproc \${exe4}
    RETVAL=\$?
    echo
    if [ \$RETVAL -eq 0 ]; then
        rm -f \${lockfile4}
        rm -f \${pidfile4}
    fi
}

restart() {
    echo -n "Restarting \$pname : "
    stop
    sleep 2
    start
}

case "\$1" in
    start)
        start
    ;;
    stop)
        stop
    ;;
    status)
        status \${pname2}
        status \${pname3}
        status \${pname4}
        
    ;;
    restart)
        restart
    ;;
    *)
        echo "Usage: \$0 {start|stop|status|restart}"
    ;; esac

exit 0

EOF

chmod +x ag_etcd.sh
chmod +x ag_stolon.sh
#let IDX++
#done

echo "Script generated success. : $IP "
echo "##### Agensgraph Stolon Startup STEP ########### "
echo "1. execute ag_etcd.sh each node"
echo "2. initialize cluster :  stolonctl --cluster-name=agens-ee-stolon-cluster --store-backend=etcdv3 init "
echo "3. execute ag_stolon.sh each node"
echo "################################################"
