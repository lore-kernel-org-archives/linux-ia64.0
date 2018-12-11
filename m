From: Deepa Dinamani <deepa.kernel@gmail.com>
Date: Tue, 11 Dec 2018 20:25:13 +0000
Subject: [PATCH v2 1/8] arch: Use asm-generic/socket.h when possible
Message-Id: <20181211202520.16799-2-deepa.kernel@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181211202520.16799-1-deepa.kernel@gmail.com>
In-Reply-To: <20181211202520.16799-1-deepa.kernel@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org, arnd@arndb.de, y2038@lists.linaro.org, chris@zankel.net, fenghua.yu@intel.com, tglx@linutronix.de, schwidefsky@de.ibm.com, linux-ia64@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-s390@vger.kernel.org

Many architectures maintain an arch specific copy of the
file even though there are no differences with the asm-generic
one. Allow these architectures to use the generic one instead.

Signed-off-by: Deepa Dinamani <deepa.kernel@gmail.com>
Cc: chris@zankel.net
Cc: fenghua.yu@intel.com
Cc: tglx@linutronix.de
Cc: schwidefsky@de.ibm.com
Cc: linux-ia64@vger.kernel.org
Cc: linux-xtensa@linux-xtensa.org
Cc: linux-s390@vger.kernel.org
---
 arch/ia64/include/uapi/asm/Kbuild     |   1 +
 arch/ia64/include/uapi/asm/socket.h   | 120 -------------------------
 arch/s390/include/uapi/asm/Kbuild     |   1 +
 arch/s390/include/uapi/asm/socket.h   | 117 ------------------------
 arch/x86/include/uapi/asm/Kbuild      |   1 +
 arch/x86/include/uapi/asm/socket.h    |   1 -
 arch/xtensa/include/asm/Kbuild        |   1 +
 arch/xtensa/include/uapi/asm/Kbuild   |   1 +
 arch/xtensa/include/uapi/asm/socket.h | 122 --------------------------
 9 files changed, 5 insertions(+), 360 deletions(-)
 delete mode 100644 arch/ia64/include/uapi/asm/socket.h
 delete mode 100644 arch/s390/include/uapi/asm/socket.h
 delete mode 100644 arch/x86/include/uapi/asm/socket.h
 delete mode 100644 arch/xtensa/include/uapi/asm/socket.h

diff --git a/arch/ia64/include/uapi/asm/Kbuild b/arch/ia64/include/uapi/asm/Kbuild
index ccce0ea65e05..37ea5ec1b94d 100644
--- a/arch/ia64/include/uapi/asm/Kbuild
+++ b/arch/ia64/include/uapi/asm/Kbuild
@@ -9,3 +9,4 @@ generic-y += msgbuf.h
 generic-y += poll.h
 generic-y += sembuf.h
 generic-y += shmbuf.h
+generic-y += socket.h
diff --git a/arch/ia64/include/uapi/asm/socket.h b/arch/ia64/include/uapi/asm/socket.h
deleted file mode 100644
index c872c4e6bafb..000000000000
--- a/arch/ia64/include/uapi/asm/socket.h
+++ /dev/null
@@ -1,120 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
-#ifndef _ASM_IA64_SOCKET_H
-#define _ASM_IA64_SOCKET_H
-
-/*
- * Socket related defines.
- *
- * Based on <asm-i386/socket.h>.
- *
- * Modified 1998-2000
- *	David Mosberger-Tang <davidm@hpl.hp.com>, Hewlett-Packard Co
- */
-
-#include <asm/sockios.h>
-
-/* For setsockopt(2) */
-#define SOL_SOCKET	1
-
-#define SO_DEBUG	1
-#define SO_REUSEADDR	2
-#define SO_TYPE		3
-#define SO_ERROR	4
-#define SO_DONTROUTE	5
-#define SO_BROADCAST	6
-#define SO_SNDBUF	7
-#define SO_RCVBUF	8
-#define SO_SNDBUFFORCE	32
-#define SO_RCVBUFFORCE	33
-#define SO_KEEPALIVE	9
-#define SO_OOBINLINE	10
-#define SO_NO_CHECK	11
-#define SO_PRIORITY	12
-#define SO_LINGER	13
-#define SO_BSDCOMPAT	14
-#define SO_REUSEPORT	15
-#define SO_PASSCRED	16
-#define SO_PEERCRED	17
-#define SO_RCVLOWAT	18
-#define SO_SNDLOWAT	19
-#define SO_RCVTIMEO	20
-#define SO_SNDTIMEO	21
-
-/* Security levels - as per NRL IPv6 - don't actually do anything */
-#define SO_SECURITY_AUTHENTICATION		22
-#define SO_SECURITY_ENCRYPTION_TRANSPORT	23
-#define SO_SECURITY_ENCRYPTION_NETWORK		24
-
-#define SO_BINDTODEVICE		25
-
-/* Socket filtering */
-#define SO_ATTACH_FILTER	26
-#define SO_DETACH_FILTER	27
-#define SO_GET_FILTER		SO_ATTACH_FILTER
-
-#define SO_PEERNAME		28
-#define SO_TIMESTAMP		29
-#define SCM_TIMESTAMP		SO_TIMESTAMP
-
-#define SO_ACCEPTCONN		30
-
-#define SO_PEERSEC             31
-#define SO_PASSSEC		34
-#define SO_TIMESTAMPNS		35
-#define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
-
-#define SO_MARK			36
-
-#define SO_TIMESTAMPING		37
-#define SCM_TIMESTAMPING	SO_TIMESTAMPING
-
-#define SO_PROTOCOL		38
-#define SO_DOMAIN		39
-
-#define SO_RXQ_OVFL             40
-
-#define SO_WIFI_STATUS		41
-#define SCM_WIFI_STATUS		SO_WIFI_STATUS
-#define SO_PEEK_OFF		42
-
-/* Instruct lower device to use last 4-bytes of skb data as FCS */
-#define SO_NOFCS		43
-
-#define SO_LOCK_FILTER		44
-
-#define SO_SELECT_ERR_QUEUE	45
-
-#define SO_BUSY_POLL		46
-
-#define SO_MAX_PACING_RATE	47
-
-#define SO_BPF_EXTENSIONS	48
-
-#define SO_INCOMING_CPU		49
-
-#define SO_ATTACH_BPF		50
-#define SO_DETACH_BPF		SO_DETACH_FILTER
-
-#define SO_ATTACH_REUSEPORT_CBPF	51
-#define SO_ATTACH_REUSEPORT_EBPF	52
-
-#define SO_CNX_ADVICE		53
-
-#define SCM_TIMESTAMPING_OPT_STATS	54
-
-#define SO_MEMINFO		55
-
-#define SO_INCOMING_NAPI_ID	56
-
-#define SO_COOKIE		57
-
-#define SCM_TIMESTAMPING_PKTINFO	58
-
-#define SO_PEERGROUPS		59
-
-#define SO_ZEROCOPY		60
-
-#define SO_TXTIME		61
-#define SCM_TXTIME		SO_TXTIME
-
-#endif /* _ASM_IA64_SOCKET_H */
diff --git a/arch/s390/include/uapi/asm/Kbuild b/arch/s390/include/uapi/asm/Kbuild
index dc38a90cf091..15bb61228b74 100644
--- a/arch/s390/include/uapi/asm/Kbuild
+++ b/arch/s390/include/uapi/asm/Kbuild
@@ -15,6 +15,7 @@ generic-y += poll.h
 generic-y += resource.h
 generic-y += sembuf.h
 generic-y += shmbuf.h
+generic-y += socket.h
 generic-y += sockios.h
 generic-y += swab.h
 generic-y += termbits.h
diff --git a/arch/s390/include/uapi/asm/socket.h b/arch/s390/include/uapi/asm/socket.h
deleted file mode 100644
index 39d901476ee5..000000000000
--- a/arch/s390/include/uapi/asm/socket.h
+++ /dev/null
@@ -1,117 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
-/*
- *  S390 version
- *
- *  Derived from "include/asm-i386/socket.h"
- */
-
-#ifndef _ASM_SOCKET_H
-#define _ASM_SOCKET_H
-
-#include <asm/sockios.h>
-
-/* For setsockopt(2) */
-#define SOL_SOCKET	1
-
-#define SO_DEBUG	1
-#define SO_REUSEADDR	2
-#define SO_TYPE		3
-#define SO_ERROR	4
-#define SO_DONTROUTE	5
-#define SO_BROADCAST	6
-#define SO_SNDBUF	7
-#define SO_RCVBUF	8
-#define SO_SNDBUFFORCE	32
-#define SO_RCVBUFFORCE	33
-#define SO_KEEPALIVE	9
-#define SO_OOBINLINE	10
-#define SO_NO_CHECK	11
-#define SO_PRIORITY	12
-#define SO_LINGER	13
-#define SO_BSDCOMPAT	14
-#define SO_REUSEPORT	15
-#define SO_PASSCRED	16
-#define SO_PEERCRED	17
-#define SO_RCVLOWAT	18
-#define SO_SNDLOWAT	19
-#define SO_RCVTIMEO	20
-#define SO_SNDTIMEO	21
-
-/* Security levels - as per NRL IPv6 - don't actually do anything */
-#define SO_SECURITY_AUTHENTICATION		22
-#define SO_SECURITY_ENCRYPTION_TRANSPORT	23
-#define SO_SECURITY_ENCRYPTION_NETWORK		24
-
-#define SO_BINDTODEVICE	25
-
-/* Socket filtering */
-#define SO_ATTACH_FILTER        26
-#define SO_DETACH_FILTER        27
-#define SO_GET_FILTER		SO_ATTACH_FILTER
-
-#define SO_PEERNAME		28
-#define SO_TIMESTAMP		29
-#define SCM_TIMESTAMP		SO_TIMESTAMP
-
-#define SO_ACCEPTCONN		30
-
-#define SO_PEERSEC		31
-#define SO_PASSSEC		34
-#define SO_TIMESTAMPNS		35
-#define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
-
-#define SO_MARK			36
-
-#define SO_TIMESTAMPING		37
-#define SCM_TIMESTAMPING	SO_TIMESTAMPING
-
-#define SO_PROTOCOL		38
-#define SO_DOMAIN		39
-
-#define SO_RXQ_OVFL             40
-
-#define SO_WIFI_STATUS		41
-#define SCM_WIFI_STATUS		SO_WIFI_STATUS
-#define SO_PEEK_OFF		42
-
-/* Instruct lower device to use last 4-bytes of skb data as FCS */
-#define SO_NOFCS		43
-
-#define SO_LOCK_FILTER		44
-
-#define SO_SELECT_ERR_QUEUE	45
-
-#define SO_BUSY_POLL		46
-
-#define SO_MAX_PACING_RATE	47
-
-#define SO_BPF_EXTENSIONS	48
-
-#define SO_INCOMING_CPU		49
-
-#define SO_ATTACH_BPF		50
-#define SO_DETACH_BPF		SO_DETACH_FILTER
-
-#define SO_ATTACH_REUSEPORT_CBPF	51
-#define SO_ATTACH_REUSEPORT_EBPF	52
-
-#define SO_CNX_ADVICE		53
-
-#define SCM_TIMESTAMPING_OPT_STATS	54
-
-#define	SO_MEMINFO		55
-
-#define SO_INCOMING_NAPI_ID	56
-
-#define SO_COOKIE		57
-
-#define SCM_TIMESTAMPING_PKTINFO	58
-
-#define SO_PEERGROUPS		59
-
-#define SO_ZEROCOPY		60
-
-#define SO_TXTIME		61
-#define SCM_TXTIME		SO_TXTIME
-
-#endif /* _ASM_SOCKET_H */
diff --git a/arch/x86/include/uapi/asm/Kbuild b/arch/x86/include/uapi/asm/Kbuild
index 322681622d1e..a400e71a13ce 100644
--- a/arch/x86/include/uapi/asm/Kbuild
+++ b/arch/x86/include/uapi/asm/Kbuild
@@ -6,3 +6,4 @@ generated-y += unistd_32.h
 generated-y += unistd_64.h
 generated-y += unistd_x32.h
 generic-y += poll.h
+generic-y += socket.h
diff --git a/arch/x86/include/uapi/asm/socket.h b/arch/x86/include/uapi/asm/socket.h
deleted file mode 100644
index 6b71384b9d8b..000000000000
--- a/arch/x86/include/uapi/asm/socket.h
+++ /dev/null
@@ -1 +0,0 @@
-#include <asm-generic/socket.h>
diff --git a/arch/xtensa/include/asm/Kbuild b/arch/xtensa/include/asm/Kbuild
index e255683cd520..809f39ce08c0 100644
--- a/arch/xtensa/include/asm/Kbuild
+++ b/arch/xtensa/include/asm/Kbuild
@@ -25,6 +25,7 @@ generic-y += percpu.h
 generic-y += preempt.h
 generic-y += rwsem.h
 generic-y += sections.h
+generic-y += socket.h
 generic-y += topology.h
 generic-y += trace_clock.h
 generic-y += vga.h
diff --git a/arch/xtensa/include/uapi/asm/Kbuild b/arch/xtensa/include/uapi/asm/Kbuild
index f95cad300369..fc2680dace55 100644
--- a/arch/xtensa/include/uapi/asm/Kbuild
+++ b/arch/xtensa/include/uapi/asm/Kbuild
@@ -10,5 +10,6 @@ generic-y += ioctl.h
 generic-y += kvm_para.h
 generic-y += resource.h
 generic-y += siginfo.h
+generic-y += socket.h
 generic-y += statfs.h
 generic-y += termios.h
diff --git a/arch/xtensa/include/uapi/asm/socket.h b/arch/xtensa/include/uapi/asm/socket.h
deleted file mode 100644
index 1de07a7f7680..000000000000
--- a/arch/xtensa/include/uapi/asm/socket.h
+++ /dev/null
@@ -1,122 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
-/*
- * include/asm-xtensa/socket.h
- *
- * Copied from i386.
- *
- * This file is subject to the terms and conditions of the GNU General Public
- * License.  See the file "COPYING" in the main directory of this archive
- * for more details.
- */
-
-#ifndef _XTENSA_SOCKET_H
-#define _XTENSA_SOCKET_H
-
-#include <asm/sockios.h>
-
-/* For setsockoptions(2) */
-#define SOL_SOCKET	1
-
-#define SO_DEBUG	1
-#define SO_REUSEADDR	2
-#define SO_TYPE		3
-#define SO_ERROR	4
-#define SO_DONTROUTE	5
-#define SO_BROADCAST	6
-#define SO_SNDBUF	7
-#define SO_RCVBUF	8
-#define SO_SNDBUFFORCE	32
-#define SO_RCVBUFFORCE	33
-#define SO_KEEPALIVE	9
-#define SO_OOBINLINE	10
-#define SO_NO_CHECK	11
-#define SO_PRIORITY	12
-#define SO_LINGER	13
-#define SO_BSDCOMPAT	14
-#define SO_REUSEPORT	15
-#define SO_PASSCRED	16
-#define SO_PEERCRED	17
-#define SO_RCVLOWAT	18
-#define SO_SNDLOWAT	19
-#define SO_RCVTIMEO	20
-#define SO_SNDTIMEO	21
-
-/* Security levels - as per NRL IPv6 - don't actually do anything */
-
-#define SO_SECURITY_AUTHENTICATION		22
-#define SO_SECURITY_ENCRYPTION_TRANSPORT	23
-#define SO_SECURITY_ENCRYPTION_NETWORK		24
-
-#define SO_BINDTODEVICE	25
-
-/* Socket filtering */
-
-#define SO_ATTACH_FILTER        26
-#define SO_DETACH_FILTER        27
-#define SO_GET_FILTER		SO_ATTACH_FILTER
-
-#define SO_PEERNAME		28
-#define SO_TIMESTAMP		29
-#define SCM_TIMESTAMP		SO_TIMESTAMP
-
-#define SO_ACCEPTCONN		30
-#define SO_PEERSEC		31
-#define SO_PASSSEC		34
-#define SO_TIMESTAMPNS		35
-#define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
-
-#define SO_MARK			36
-
-#define SO_TIMESTAMPING		37
-#define SCM_TIMESTAMPING	SO_TIMESTAMPING
-
-#define SO_PROTOCOL		38
-#define SO_DOMAIN		39
-
-#define SO_RXQ_OVFL             40
-
-#define SO_WIFI_STATUS		41
-#define SCM_WIFI_STATUS		SO_WIFI_STATUS
-#define SO_PEEK_OFF		42
-
-/* Instruct lower device to use last 4-bytes of skb data as FCS */
-#define SO_NOFCS		43
-
-#define SO_LOCK_FILTER		44
-
-#define SO_SELECT_ERR_QUEUE	45
-
-#define SO_BUSY_POLL		46
-
-#define SO_MAX_PACING_RATE	47
-
-#define SO_BPF_EXTENSIONS	48
-
-#define SO_INCOMING_CPU		49
-
-#define SO_ATTACH_BPF		50
-#define SO_DETACH_BPF		SO_DETACH_FILTER
-
-#define SO_ATTACH_REUSEPORT_CBPF	51
-#define SO_ATTACH_REUSEPORT_EBPF	52
-
-#define SO_CNX_ADVICE		53
-
-#define SCM_TIMESTAMPING_OPT_STATS	54
-
-#define SO_MEMINFO		55
-
-#define SO_INCOMING_NAPI_ID	56
-
-#define SO_COOKIE		57
-
-#define SCM_TIMESTAMPING_PKTINFO	58
-
-#define SO_PEERGROUPS		59
-
-#define SO_ZEROCOPY		60
-
-#define SO_TXTIME		61
-#define SCM_TXTIME		SO_TXTIME
-
-#endif	/* _XTENSA_SOCKET_H */
-- 
2.17.1
