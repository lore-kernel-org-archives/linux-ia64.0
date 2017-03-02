From: "Dmitry V. Levin" <ldv@altlinux.org>
Date: Thu, 02 Mar 2017 00:22:03 +0000
Subject: [PATCH 1/3] uapi: fix asm/msgbuf.h userspace compilation errors
Message-Id: <20170302002202.GA27132@altlinux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAK8P3a3Ptm68i43BT5+kWptDw1koPwexpuFwH3-1naj_xi+arQ@mail.gmail.com>
In-Reply-To: <CAK8P3a3Ptm68i43BT5+kWptDw1koPwexpuFwH3-1naj_xi+arQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: Haavard Skinnemoen <hskinnemoen@gmail.com>, Hans-Christian Egtvedt <egtvedt@samfundet.no>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, David Howells <dhowells@redhat.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, "David S. Miller" <davem@davemloft.net>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-arch@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linux-am33-list

Include <asm/ipcbuf.h> to fix asm/msgbuf.h userspace compilation errors
like this:

/usr/include/asm-generic/msgbuf.h:25:20: error: field 'msg_perm' has incomplete type
  struct ipc64_perm msg_perm;
/usr/include/asm-generic/msgbuf.h:26:2: error: unknown type name '__kernel_time_t'
  __kernel_time_t msg_stime; /* last msgsnd time */
/usr/include/asm-generic/msgbuf.h:30:2: error: unknown type name '__kernel_time_t'
  __kernel_time_t msg_rtime; /* last msgrcv time */
/usr/include/asm-generic/msgbuf.h:34:2: error: unknown type name '__kernel_time_t'
  __kernel_time_t msg_ctime; /* last change time */
/usr/include/asm-generic/msgbuf.h:38:2: error: unknown type name '__kernel_ulong_t'
  __kernel_ulong_t msg_cbytes; /* current number of bytes on queue */
/usr/include/asm-generic/msgbuf.h:39:2: error: unknown type name '__kernel_ulong_t'
  __kernel_ulong_t msg_qnum; /* number of messages in queue */
/usr/include/asm-generic/msgbuf.h:40:2: error: unknown type name '__kernel_ulong_t'
  __kernel_ulong_t msg_qbytes; /* max number of bytes on queue */
/usr/include/asm-generic/msgbuf.h:41:2: error: unknown type name '__kernel_pid_t'
  __kernel_pid_t msg_lspid; /* pid of last msgsnd */
/usr/include/asm-generic/msgbuf.h:42:2: error: unknown type name '__kernel_pid_t'
  __kernel_pid_t msg_lrpid; /* last receive pid */
/usr/include/asm-generic/msgbuf.h:43:2: error: unknown type name '__kernel_ulong_t'
  __kernel_ulong_t __unused4;
/usr/include/asm-generic/msgbuf.h:44:2: error: unknown type name '__kernel_ulong_t'
  __kernel_ulong_t __unused5;

Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>
---
 include/uapi/asm-generic/msgbuf.h      | 1 +
 arch/alpha/include/uapi/asm/msgbuf.h   | 2 ++
 arch/avr32/include/uapi/asm/msgbuf.h   | 2 ++
 arch/frv/include/uapi/asm/msgbuf.h     | 2 ++
 arch/ia64/include/uapi/asm/msgbuf.h    | 2 ++
 arch/m32r/include/uapi/asm/msgbuf.h    | 2 ++
 arch/mips/include/uapi/asm/msgbuf.h    | 1 +
 arch/mn10300/include/uapi/asm/msgbuf.h | 2 ++
 arch/parisc/include/uapi/asm/msgbuf.h  | 1 +
 arch/powerpc/include/uapi/asm/msgbuf.h | 2 ++
 arch/s390/include/uapi/asm/msgbuf.h    | 2 ++
 arch/sparc/include/uapi/asm/msgbuf.h   | 2 ++
 arch/xtensa/include/uapi/asm/msgbuf.h  | 2 ++
 13 files changed, 23 insertions(+)

diff --git a/include/uapi/asm-generic/msgbuf.h b/include/uapi/asm-generic/msgbuf.h
index f55ecc4..f3c3b43 100644
--- a/include/uapi/asm-generic/msgbuf.h
+++ b/include/uapi/asm-generic/msgbuf.h
@@ -1,6 +1,7 @@
 #ifndef __ASM_GENERIC_MSGBUF_H
 #define __ASM_GENERIC_MSGBUF_H
 
+#include <asm/ipcbuf.h>
 #include <asm/bitsperlong.h>
 /*
  * generic msqid64_ds structure.
diff --git a/arch/alpha/include/uapi/asm/msgbuf.h b/arch/alpha/include/uapi/asm/msgbuf.h
index 9849650..8de899a 100644
--- a/arch/alpha/include/uapi/asm/msgbuf.h
+++ b/arch/alpha/include/uapi/asm/msgbuf.h
@@ -1,6 +1,8 @@
 #ifndef _ALPHA_MSGBUF_H
 #define _ALPHA_MSGBUF_H
 
+#include <asm/ipcbuf.h>
+
 /* 
  * The msqid64_ds structure for alpha architecture.
  * Note extra padding because this structure is passed back and forth
diff --git a/arch/avr32/include/uapi/asm/msgbuf.h b/arch/avr32/include/uapi/asm/msgbuf.h
index 9eae6ef..45cdffb 100644
--- a/arch/avr32/include/uapi/asm/msgbuf.h
+++ b/arch/avr32/include/uapi/asm/msgbuf.h
@@ -1,6 +1,8 @@
 #ifndef _UAPI__ASM_AVR32_MSGBUF_H
 #define _UAPI__ASM_AVR32_MSGBUF_H
 
+#include <asm/ipcbuf.h>
+
 /*
  * The msqid64_ds structure for i386 architecture.
  * Note extra padding because this structure is passed back and forth
diff --git a/arch/frv/include/uapi/asm/msgbuf.h b/arch/frv/include/uapi/asm/msgbuf.h
index 97ceb55..92d6656 100644
--- a/arch/frv/include/uapi/asm/msgbuf.h
+++ b/arch/frv/include/uapi/asm/msgbuf.h
@@ -1,6 +1,8 @@
 #ifndef _ASM_MSGBUF_H
 #define _ASM_MSGBUF_H
 
+#include <asm/ipcbuf.h>
+
 /*
  * The msqid64_ds structure for FR-V architecture.
  * Note extra padding because this structure is passed back and forth
diff --git a/arch/ia64/include/uapi/asm/msgbuf.h b/arch/ia64/include/uapi/asm/msgbuf.h
index 6c64c0d..9a31b60 100644
--- a/arch/ia64/include/uapi/asm/msgbuf.h
+++ b/arch/ia64/include/uapi/asm/msgbuf.h
@@ -1,6 +1,8 @@
 #ifndef _ASM_IA64_MSGBUF_H
 #define _ASM_IA64_MSGBUF_H
 
+#include <asm/ipcbuf.h>
+
 /*
  * The msqid64_ds structure for IA-64 architecture.
  * Note extra padding because this structure is passed back and forth
diff --git a/arch/m32r/include/uapi/asm/msgbuf.h b/arch/m32r/include/uapi/asm/msgbuf.h
index 0d5a877..4786c0c 100644
--- a/arch/m32r/include/uapi/asm/msgbuf.h
+++ b/arch/m32r/include/uapi/asm/msgbuf.h
@@ -1,6 +1,8 @@
 #ifndef _ASM_M32R_MSGBUF_H
 #define _ASM_M32R_MSGBUF_H
 
+#include <asm/ipcbuf.h>
+
 /*
  * The msqid64_ds structure for m32r architecture.
  * Note extra padding because this structure is passed back and forth
diff --git a/arch/mips/include/uapi/asm/msgbuf.h b/arch/mips/include/uapi/asm/msgbuf.h
index df849e8..c84a388 100644
--- a/arch/mips/include/uapi/asm/msgbuf.h
+++ b/arch/mips/include/uapi/asm/msgbuf.h
@@ -1,6 +1,7 @@
 #ifndef _ASM_MSGBUF_H
 #define _ASM_MSGBUF_H
 
+#include <asm/ipcbuf.h>
 
 /*
  * The msqid64_ds structure for the MIPS architecture.
diff --git a/arch/mn10300/include/uapi/asm/msgbuf.h b/arch/mn10300/include/uapi/asm/msgbuf.h
index 8b60245..f1c5dd5 100644
--- a/arch/mn10300/include/uapi/asm/msgbuf.h
+++ b/arch/mn10300/include/uapi/asm/msgbuf.h
@@ -1,6 +1,8 @@
 #ifndef _ASM_MSGBUF_H
 #define _ASM_MSGBUF_H
 
+#include <asm/ipcbuf.h>
+
 /*
  * The msqid64_ds structure for MN10300 architecture.
  * Note extra padding because this structure is passed back and forth
diff --git a/arch/parisc/include/uapi/asm/msgbuf.h b/arch/parisc/include/uapi/asm/msgbuf.h
index 2e83ac7..c70f1d3 100644
--- a/arch/parisc/include/uapi/asm/msgbuf.h
+++ b/arch/parisc/include/uapi/asm/msgbuf.h
@@ -1,6 +1,7 @@
 #ifndef _PARISC_MSGBUF_H
 #define _PARISC_MSGBUF_H
 
+#include <asm/ipcbuf.h>
 #include <asm/bitsperlong.h>
 
 /* 
diff --git a/arch/powerpc/include/uapi/asm/msgbuf.h b/arch/powerpc/include/uapi/asm/msgbuf.h
index dd76743..3b87d25 100644
--- a/arch/powerpc/include/uapi/asm/msgbuf.h
+++ b/arch/powerpc/include/uapi/asm/msgbuf.h
@@ -1,6 +1,8 @@
 #ifndef _ASM_POWERPC_MSGBUF_H
 #define _ASM_POWERPC_MSGBUF_H
 
+#include <asm/ipcbuf.h>
+
 /*
  * The msqid64_ds structure for the PowerPC architecture.
  * Note extra padding because this structure is passed back and forth
diff --git a/arch/s390/include/uapi/asm/msgbuf.h b/arch/s390/include/uapi/asm/msgbuf.h
index 1bbdee9..ab04112 100644
--- a/arch/s390/include/uapi/asm/msgbuf.h
+++ b/arch/s390/include/uapi/asm/msgbuf.h
@@ -1,6 +1,8 @@
 #ifndef _S390_MSGBUF_H
 #define _S390_MSGBUF_H
 
+#include <asm/ipcbuf.h>
+
 /* 
  * The msqid64_ds structure for S/390 architecture.
  * Note extra padding because this structure is passed back and forth
diff --git a/arch/sparc/include/uapi/asm/msgbuf.h b/arch/sparc/include/uapi/asm/msgbuf.h
index efc7cbe9..699f631 100644
--- a/arch/sparc/include/uapi/asm/msgbuf.h
+++ b/arch/sparc/include/uapi/asm/msgbuf.h
@@ -1,6 +1,8 @@
 #ifndef _SPARC_MSGBUF_H
 #define _SPARC_MSGBUF_H
 
+#include <asm/ipcbuf.h>
+
 /*
  * The msqid64_ds structure for sparc64 architecture.
  * Note extra padding because this structure is passed back and forth
diff --git a/arch/xtensa/include/uapi/asm/msgbuf.h b/arch/xtensa/include/uapi/asm/msgbuf.h
index 693c967..b75458b 100644
--- a/arch/xtensa/include/uapi/asm/msgbuf.h
+++ b/arch/xtensa/include/uapi/asm/msgbuf.h
@@ -17,6 +17,8 @@
 #ifndef _XTENSA_MSGBUF_H
 #define _XTENSA_MSGBUF_H
 
+#include <asm/ipcbuf.h>
+
 struct msqid64_ds {
 	struct ipc64_perm msg_perm;
 #ifdef __XTENSA_EB__
-- 
ldv
