From: Hiroshi Aono <aono@hpc.bs1.fc.nec.co.jp>
Date: Thu, 17 May 2001 07:58:19 +0000
Subject: [Linux-ia64] NFS v3 server
Message-Id: <marc-linux-ia64-105590693005598@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello everyone,

I've tried to work NFS v3 server on Bigsur, but it doesn't work.
When mounting with NFS v3, the mount command says NFSv3 not supported!

Anyone tried to use the NFS v3 server on ia64 linux?

The kernel version is 2.4.4.

Thanks in advance,
----
Hiroshi Aono, NEC Solutions
(h-aono@ap.jp.nec.com)

----------------------8<----------------------
.config

#
# Network File Systems
#
# CONFIG_CODA_FS is not set
CONFIG_NFS_FS=y
CONFIG_NFS_V3=y
# CONFIG_ROOT_NFS is not set
CONFIG_NFSD=y
CONFIG_NFSD_V3=y
CONFIG_SUNRPC=y
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y

[root@luna log]# rpcinfo -p
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100021    1   udp  32768  nlockmgr
    100021    3   udp  32768  nlockmgr
    100021    4   udp  32768  nlockmgr
    100011    1   udp    751  rquotad
    100011    2   udp    751  rquotad
    100005    1   udp  32769  mountd
    100005    1   tcp  32769  mountd
    100005    2   udp  32769  mountd
    100005    2   tcp  32769  mountd
    100005    3   udp  32769  mountd
    100005    3   tcp  32769  mountd
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs

[root@luna /sbin]# sysctl -w sunrpc.nlm_debug=1
sunrpc.nlm_debug = 1
[root@luna /sbin]# sysctl -w sunrpc.nfsd_debug=1
sunrpc.nfsd_debug = 1
[root@luna /sbin]# sysctl -w sunrpc.nfs_debug=1
sunrpc.nfs_debug = 1
[root@luna /sbin]# sysctl -w sunrpc.rpc_debug=1
sunrpc.rpc_debug = 1

[root@luna /sbin]# mount -o nfsvers=3  localhost:/tmp/test /tmp/mnt
NFSv3 not supported!
mount: wrong fs type, bad option, bad superblock on localhost:/tmp/test,
       or too many mounted file systems

I also tried with udp option, but didn't work.

[root@luna /sbin]#  mount -o nfsvers=3,udp  localhost:/tmp/test /tmp/mnt
NFSv3 not supported!
mount: wrong fs type, bad option, bad superblock on localhost:/tmp/test,
       or too many mounted file systems

(/var/log/messages)
May 17 16:40:19 luna rpc.mountd: authenticated mount request from localhost.localdomain:954 for /tmp/test (/tmp/test) 
May 17 16:40:19 luna kernel: RPC:      xprt_create_proto called 
May 17 16:40:19 luna kernel: RPC:      xprt_create_socket(udp 17) 
May 17 16:40:19 luna kernel: RPC:      setting up UDP transport... 
May 17 16:40:19 luna kernel: RPC:      created transport e00000002be90000 
May 17 16:40:19 luna kernel: RPC: 1077 xprt_reserve cong = 0 cwnd = 256 
May 17 16:40:19 luna kernel: RPC: 1077 reserved req e00000002be900b8 xid 0c77c435 
May 17 16:40:19 luna kernel: RPC: 1077 xprt_reserve returns 0 
May 17 16:40:19 luna kernel: RPC: 1077 xprt_transmit(c77c435) 
May 17 16:40:19 luna kernel: RPC: 1077 xprt_receive 
May 17 16:40:19 luna kernel: RPC:      xprt_sendmsg(132) = 132 
May 17 16:40:19 luna kernel: RPC: 1077 xmit complete 
May 17 16:40:19 luna kernel: RPC:      udp_data_ready... 
May 17 16:40:19 luna kernel: RPC:      udp_data_ready client e00000002be90000 
May 17 16:40:19 luna kernel: RPC: 1077 received reply 
May 17 16:40:19 luna kernel: RPC:      cong 00000100, cwnd was 00000100, now 00000200, time 8000 ms 
May 17 16:40:19 luna kernel: RPC: 1077 has input (28 bytes) 
May 17 16:40:19 luna kernel: RPC: 1077 release request e00000002be900b8 
May 17 16:40:19 luna kernel: nfs_get_root: getattr error = 521 
May 17 16:40:19 luna kernel: RPC:      destroying transport e00000002be90000 
May 17 16:40:19 luna kernel: RPC:      disconnected transport e00000002be90000 
May 17 16:40:19 luna kernel: RPC:      xprt_create_proto called 
May 17 16:40:19 luna kernel: RPC:      xprt_create_socket(udp 17) 
May 17 16:40:19 luna kernel: RPC:      setting up UDP transport... 
May 17 16:40:19 luna kernel: RPC:      created transport e00000002be90000 
May 17 16:40:19 luna kernel: RPC: 1078 xprt_reserve cong = 0 cwnd = 256 
May 17 16:40:19 luna kernel: RPC: 1078 reserved req e00000002be900b8 xid 0c77c436 
May 17 16:40:19 luna kernel: RPC: 1078 xprt_reserve returns 0 
May 17 16:40:19 luna kernel: RPC: 1078 xprt_transmit(c77c436) 
May 17 16:40:19 luna kernel: RPC: 1078 xprt_receive 
May 17 16:40:19 luna kernel: RPC:      xprt_sendmsg(148) = 148 
May 17 16:40:19 luna kernel: RPC: 1078 xmit complete 
May 17 16:40:19 luna kernel: RPC:      udp_data_ready... 
May 17 16:40:19 luna kernel: RPC:      udp_data_ready client e00000002be90000 
May 17 16:40:19 luna kernel: RPC: 1078 received reply 
May 17 16:40:19 luna kernel: RPC:      cong 00000100, cwnd was 00000100, now 00000200, time 8000 ms 
May 17 16:40:19 luna kernel: RPC: 1078 has input (28 bytes) 
May 17 16:40:19 luna kernel: RPC: 1078 release request e00000002be900b8 
May 17 16:40:19 luna kernel: nfs_get_root: getattr error = 116 
May 17 16:40:19 luna kernel: nfs_read_super: get root inode failed 
May 17 16:40:19 luna kernel: RPC:      destroying transport e00000002be90000 
May 17 16:40:19 luna kernel: RPC:      disconnected transport e00000002be90000 
May 17 16:40:19 luna kernel: nfs warning: mount version older than kernel 
May 17 16:40:19 luna kernel: NFS: mount program didn't pass remote address! 

NFS v2 mount command was succeed.

#mount -o nfsvers=2  localhost:/tmp/test /tmp/mnt

May 17 16:40:58 luna rpc.mountd: authenticated mount request from localhost.localdomain:955 for /tmp/test (/tmp/test) 
May 17 16:40:58 luna kernel: RPC:      xprt_create_proto called 
May 17 16:40:58 luna kernel: RPC:      xprt_create_socket(udp 17) 
May 17 16:40:58 luna kernel: RPC:      setting up UDP transport... 
May 17 16:40:58 luna kernel: RPC:      created transport e00000002be90000 
May 17 16:40:58 luna kernel: RPC: 1079 xprt_reserve cong = 0 cwnd = 256 
May 17 16:40:58 luna kernel: RPC: 1079 reserved req e00000002be900b8 xid 0c77c437 
May 17 16:40:58 luna kernel: RPC: 1079 xprt_reserve returns 0 
May 17 16:40:58 luna kernel: RPC: 1079 xprt_transmit(c77c437) 
May 17 16:40:58 luna kernel: RPC: 1079 xprt_receive 
May 17 16:40:58 luna kernel: RPC:      xprt_sendmsg(148) = 148 
May 17 16:40:58 luna kernel: RPC: 1079 xmit complete 
May 17 16:40:58 luna kernel: RPC:      udp_data_ready... 
May 17 16:40:58 luna kernel: RPC:      udp_data_ready client e00000002be90000 
May 17 16:40:58 luna kernel: RPC: 1079 received reply 
May 17 16:40:58 luna kernel: RPC:      cong 00000100, cwnd was 00000100, now 00000200, time 8000 ms 
May 17 16:40:58 luna kernel: RPC: 1079 has input (96 bytes) 
May 17 16:40:58 luna kernel: RPC: 1079 release request e00000002be900b8 
May 17 16:40:58 luna kernel: NFS: refresh_inode(8/97993 ct=1 info=0x2) 
May 17 16:40:58 luna kernel: NFS: __nfs_fhget(8/97993 ct=1) 
May 17 16:40:58 luna kernel: RPC: 1080 xprt_reserve cong = 0 cwnd = 512 
May 17 16:40:58 luna kernel: RPC: 1080 reserved req e00000002be900b8 xid 0c77c438 
May 17 16:40:58 luna kernel: RPC: 1080 xprt_reserve returns 0 
May 17 16:40:58 luna kernel: RPC: 1080 xprt_transmit(c77c438) 
May 17 16:40:58 luna kernel: RPC: 1080 xprt_receive 
May 17 16:40:58 luna kernel: RPC:      xprt_sendmsg(148) = 148 
May 17 16:40:58 luna kernel: RPC: 1080 xmit complete 
May 17 16:40:58 luna kernel: RPC:      udp_data_ready... 
May 17 16:40:58 luna kernel: RPC:      udp_data_ready client e00000002be90000 
May 17 16:40:58 luna kernel: RPC: 1080 received reply 
May 17 16:40:58 luna kernel: RPC: 1080 has input (48 bytes) 
May 17 16:40:58 luna kernel: RPC: 1080 release request e00000002be900b8 

Software;

 - Turbolinux IA64 bata3
    mount-2.10k-6
    nfs-utils-0.1.9.1-3
 - kernel: 2.4.4
----------------------8<----------------------

