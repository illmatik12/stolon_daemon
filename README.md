# stolon_daemon
daemonize shell script for etcd and stolon for agensgraph 


## Step
### Configure ip list (3 nodes only)
```
IP_LISTS=(
192.168.141.101 
192.168.141.102
192.168.141.103
)
```
### Execute shell
```
gen_stolon.sh
```

### useful aliases
alias stolonstat='etcdctl cluster-health; stolonctl --cluster-name=agens-ee-stolon-cluster --store-backend=etcdv3 status'

## example

```bash
$./gen_stolon.sh 
Configure target host : 192.168.141.101
Script generated success. : 192.168.141.101 
##### Agensgraph Stolon Startup STEP ########### 
1. execute ag_etcd.sh each node
2. initialize cluster :  stolonctl --cluster-name=agens-ee-stolon-cluster --store-backend=etcdv3 init 
3. execute ag_stolon.sh each node
################################################

$ ./ag_etcd.sh start
Starting etcd : [  OK  ]
$ stolonctl --cluster-name=agens-ee-stolon-cluster --store-backend=etcdv3 init 
WARNING: The databases managed by the keepers will be overwritten depending on the provided cluster spec.
Are you sure you want to continue? [yes/no] yes
$ 
$ ./ag_stolon.sh start
Starting stolon-sentinel : [  OK  ]
Starting stolon-keeper : [  OK  ]
Starting stolon-proxy : [  OK  ]

# after start daemon each node. check your cluster status.
$etcdctl cluster-health; stolonctl --cluster-name=agens-ee-stolon-cluster --store-backend=etcdv3 status

member 5788eb3a1c21dd9d is healthy: got healthy result from http://192.168.141.101:2379
member 8858a3b3508e7138 is healthy: got healthy result from http://192.168.141.102:2379
member f6c51f8a658ac4d6 is healthy: got healthy result from http://192.168.141.103:2379
cluster is healthy
=== Active sentinels ===

ID              LEADER
33e89f37        false
42af79d7        false
4e9e6f01        true

=== Active proxies ===

ID
2788c57f
3c63ed24
a8f67c8e

=== Keepers ===

UID     HEALTHY PG LISTENADDRESS        PG HEALTHY      PG WANTEDGENERATION     PG CURRENTGENERATION
agens1  true    192.168.141.101:5532    true            4                       4
agens2  true    192.168.141.102:5532    true            2                       2
agens3  true    192.168.141.103:5532    true            2                       2

=== Cluster Info ===

Master: agens1

===== Keepers/DB tree =====

agens1 (master)
├─agens3
└─agens2
```
### 
* default log directory : /home/agens/Stolon/log
* proxy port : 5432
* local listen port : 5532