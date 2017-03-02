From: "Dmitry V. Levin" <ldv@altlinux.org>
Date: Thu, 02 Mar 2017 00:22:53 +0000
Subject: [PATCH 3/3] uapi: fix asm/shmbuf.h userspace compilation errors
Message-Id: <20170302002253.GC27132@altlinux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAK8P3a3Ptm68i43BT5+kWptDw1koPwexpuFwH3-1naj_xi+arQ@mail.gmail.com>
In-Reply-To: <CAK8P3a3Ptm68i43BT5+kWptDw1koPwexpuFwH3-1naj_xi+arQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: Haavard Skinnemoen <hskinnemoen@gmail.com>, Hans-Christian Egtvedt <egtvedt@samfundet.no>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, David Howells <dhowells@redhat.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, "David S. Miller" <davem@davemloft.net>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-arch@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linux-am33-list

Include <asm/ipcbuf.h> to fix asm/shmbuf.h userspace compilation errors
like this:

/usr/include/asm-generic/shmbuf.h:26:20: error: field 'shm_perm' has incomplete type
  struct ipc64_perm shm_perm; /* operation perms */
/usr/include/asm-generic/shmbuf.h:28:2: error: unknown type name '__kernel_time_t'
  __kernel_time_t  shm_atime; /* last attach time */
/usr/include/asm-generic/shmbuf.h:32:2: error: unknown type name '__kernel_time_t'
  __kernel_time_t  shm_dtime; /* last detach time */
/usr/include/asm-generic/shmbuf.h:36:2: error: unknown type name '__kernel_time_t'
  __kernel_time_t  shm_ctime; /* last change time */
/usr/include/asm-generic/shmbuf.h:40:2: error: unknown type name '__kernel_pid_t'
  __kernel_pid_t  shm_cpid; /* pid of creator */
/usr/include/asm-generic/shmbuf.h:41:2: error: unknown type name '__kernel_pid_t'
  __kernel_pid_t  shm_lpid; /* pid of last operator */
/usr/include/asm-generic/shmbuf.h:42:2: error: unknown type name '__kernel_ulong_t'
  __kernel_ulong_t shm_nattch; /* no. of current attaches */
/usr/include/asm-generic/shmbuf.h:43:2: error: unknown type name '__kernel_ulong_t'
  __kernel_ulong_t __unused4;
/usr/include/asm-generic/shmbuf.h:44:2: error: unknown type name '__kernel_ulong_t'
  __kernel_ulong_t __unused5;
/usr/include/asm-generic/shmbuf.h:48:2: error: unknown type name '__kernel_ulong_t'
  __kernel_ulong_t shmmax;
/usr/include/asm-generic/shmbuf.h:49:2: error: unknown type name '__kernel_ulong_t'
  __kernel_ulong_t shmmin;
/usr/include/asm-generic/shmbuf.h:50:2: error: unknown type name '__kernel_ulong_t'
  __kernel_ulong_t shmmni;
/usr/include/asm-generic/shmbuf.h:51:2: error: unknown type name '__kernel_ulong_t'
  __kernel_ulong_t shmseg;
/usr/include/asm-generic/shmbuf.h:52:2: error: unknown type name '__kernel_ulong_t'
  __kernel_ulong_t shmall;
/usr/include/asm-generic/shmbuf.h:53:2: error: unknown type name '__kernel_ulong_t'
  __kernel_ulong_t __unused1;
/usr/include/asm-generic/shmbuf.h:54:2: error: unknown type name '__kernel_ulong_t'
  __kernel_ulong_t __unused2;
/usr/include/asm-generic/shmbuf.h:55:2: error: unknown type name '__kernel_ulong_t'
  __kernel_ulong_t __unused3;
/usr/include/asm-generic/shmbuf.h:56:2: error: unknown type name '__kernel_ulong_t'
  __kernel_ulong_t __unused4;

Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>
---
 include/uapi/asm-generic/shmbuf.h      | 1 +
 arch/alpha/include/uapi/asm/shmbuf.h   | 2 ++
 arch/avr32/include/uapi/asm/shmbuf.h   | 2 ++
 arch/frv/include/uapi/asm/shmbuf.h     | 2 ++
 arch/ia64/include/uapi/asm/shmbuf.h    | 2 ++
 arch/m32r/include/uapi/asm/shmbuf.h    | 2 ++
 arch/mips/include/uapi/asm/shmbuf.h    | 2 ++
 arch/mn10300/include/uapi/asm/shmbuf.h | 2 ++
 arch/parisc/include/uapi/asm/shmbuf.h  | 1 +
 arch/powerpc/include/uapi/asm/shmbuf.h | 2 ++
 arch/s390/include/uapi/asm/shmbuf.h    | 2 ++
 arch/sparc/include/uapi/asm/shmbuf.h   | 2 ++
 arch/xtensa/include/uapi/asm/shmbuf.h  | 2 ++
 13 files changed, 24 insertions(+)

diff --git a/include/uapi/asm-generic/shmbuf.h b/include/uapi/asm-generic/shmbuf.h
index 7e9fb2f..2a6d508 100644
--- a/include/uapi/asm-generic/shmbuf.h
+++ b/include/uapi/asm-generic/shmbuf.h
@@ -1,6 +1,7 @@
 #ifndef __ASM_GENERIC_SHMBUF_H
 #define __ASM_GENERIC_SHMBUF_H
 
+#include <asm/ipcbuf.h>
 #include <asm/bitsperlong.h>
 
 /*
diff --git a/arch/alpha/include/uapi/asm/shmbuf.h b/arch/alpha/include/uapi/asm/shmbuf.h
index 37ee84f..6156099 100644
--- a/arch/alpha/include/uapi/asm/shmbuf.h
+++ b/arch/alpha/include/uapi/asm/shmbuf.h
@@ -1,6 +1,8 @@
 #ifndef _ALPHA_SHMBUF_H
 #define _ALPHA_SHMBUF_H
 
+#include <asm/ipcbuf.h>
+
 /* 
  * The shmid64_ds structure for alpha architecture.
  * Note extra padding because this structure is passed back and forth
diff --git a/arch/avr32/include/uapi/asm/shmbuf.h b/arch/avr32/include/uapi/asm/shmbuf.h
index b94cf8b..c8e5234 100644
--- a/arch/avr32/include/uapi/asm/shmbuf.h
+++ b/arch/avr32/include/uapi/asm/shmbuf.h
@@ -1,6 +1,8 @@
 #ifndef _UAPI__ASM_AVR32_SHMBUF_H
 #define _UAPI__ASM_AVR32_SHMBUF_H
 
+#include <asm/ipcbuf.h>
+
 /*
  * The shmid64_ds structure for i386 architecture.
  * Note extra padding because this structure is passed back and forth
diff --git a/arch/frv/include/uapi/asm/shmbuf.h b/arch/frv/include/uapi/asm/shmbuf.h
index 4c6e711..943746c 100644
--- a/arch/frv/include/uapi/asm/shmbuf.h
+++ b/arch/frv/include/uapi/asm/shmbuf.h
@@ -1,6 +1,8 @@
 #ifndef _ASM_SHMBUF_H
 #define _ASM_SHMBUF_H
 
+#include <asm/ipcbuf.h>
+
 /*
  * The shmid64_ds structure for FR-V architecture.
  * Note extra padding because this structure is passed back and forth
diff --git a/arch/ia64/include/uapi/asm/shmbuf.h b/arch/ia64/include/uapi/asm/shmbuf.h
index 585002a..ca81d77e 100644
--- a/arch/ia64/include/uapi/asm/shmbuf.h
+++ b/arch/ia64/include/uapi/asm/shmbuf.h
@@ -1,6 +1,8 @@
 #ifndef _ASM_IA64_SHMBUF_H
 #define _ASM_IA64_SHMBUF_H
 
+#include <asm/ipcbuf.h>
+
 /*
  * The shmid64_ds structure for IA-64 architecture.
  * Note extra padding because this structure is passed back and forth
diff --git a/arch/m32r/include/uapi/asm/shmbuf.h b/arch/m32r/include/uapi/asm/shmbuf.h
index b0cdf0a..714de6e 100644
--- a/arch/m32r/include/uapi/asm/shmbuf.h
+++ b/arch/m32r/include/uapi/asm/shmbuf.h
@@ -1,6 +1,8 @@
 #ifndef _ASM_M32R_SHMBUF_H
 #define _ASM_M32R_SHMBUF_H
 
+#include <asm/ipcbuf.h>
+
 /*
  * The shmid64_ds structure for M32R architecture.
  * Note extra padding because this structure is passed back and forth
diff --git a/arch/mips/include/uapi/asm/shmbuf.h b/arch/mips/include/uapi/asm/shmbuf.h
index f994438..f47d193 100644
--- a/arch/mips/include/uapi/asm/shmbuf.h
+++ b/arch/mips/include/uapi/asm/shmbuf.h
@@ -1,6 +1,8 @@
 #ifndef _ASM_SHMBUF_H
 #define _ASM_SHMBUF_H
 
+#include <asm/ipcbuf.h>
+
 /*
  * The shmid64_ds structure for the MIPS architecture.
  * Note extra padding because this structure is passed back and forth
diff --git a/arch/mn10300/include/uapi/asm/shmbuf.h b/arch/mn10300/include/uapi/asm/shmbuf.h
index 8f300cc..71df684 100644
--- a/arch/mn10300/include/uapi/asm/shmbuf.h
+++ b/arch/mn10300/include/uapi/asm/shmbuf.h
@@ -1,6 +1,8 @@
 #ifndef _ASM_SHMBUF_H
 #define _ASM_SHMBUF_H
 
+#include <asm/ipcbuf.h>
+
 /*
  * The shmid64_ds structure for MN10300 architecture.
  * Note extra padding because this structure is passed back and forth
diff --git a/arch/parisc/include/uapi/asm/shmbuf.h b/arch/parisc/include/uapi/asm/shmbuf.h
index 750e13e..d8105ef 100644
--- a/arch/parisc/include/uapi/asm/shmbuf.h
+++ b/arch/parisc/include/uapi/asm/shmbuf.h
@@ -1,6 +1,7 @@
 #ifndef _PARISC_SHMBUF_H
 #define _PARISC_SHMBUF_H
 
+#include <asm/ipcbuf.h>
 #include <asm/bitsperlong.h>
 
 /* 
diff --git a/arch/powerpc/include/uapi/asm/shmbuf.h b/arch/powerpc/include/uapi/asm/shmbuf.h
index 8efa396..7937289 100644
--- a/arch/powerpc/include/uapi/asm/shmbuf.h
+++ b/arch/powerpc/include/uapi/asm/shmbuf.h
@@ -1,6 +1,8 @@
 #ifndef _ASM_POWERPC_SHMBUF_H
 #define _ASM_POWERPC_SHMBUF_H
 
+#include <asm/ipcbuf.h>
+
 /*
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License
diff --git a/arch/s390/include/uapi/asm/shmbuf.h b/arch/s390/include/uapi/asm/shmbuf.h
index eed2e28..9ce1d9f 100644
--- a/arch/s390/include/uapi/asm/shmbuf.h
+++ b/arch/s390/include/uapi/asm/shmbuf.h
@@ -1,6 +1,8 @@
 #ifndef _S390_SHMBUF_H
 #define _S390_SHMBUF_H
 
+#include <asm/ipcbuf.h>
+
 /* 
  * The shmid64_ds structure for S/390 architecture.
  * Note extra padding because this structure is passed back and forth
diff --git a/arch/sparc/include/uapi/asm/shmbuf.h b/arch/sparc/include/uapi/asm/shmbuf.h
index 83a1605..f651952 100644
--- a/arch/sparc/include/uapi/asm/shmbuf.h
+++ b/arch/sparc/include/uapi/asm/shmbuf.h
@@ -1,6 +1,8 @@
 #ifndef _SPARC_SHMBUF_H
 #define _SPARC_SHMBUF_H
 
+#include <asm/ipcbuf.h>
+
 /* 
  * The shmid64_ds structure for sparc architecture.
  * Note extra padding because this structure is passed back and forth
diff --git a/arch/xtensa/include/uapi/asm/shmbuf.h b/arch/xtensa/include/uapi/asm/shmbuf.h
index ad4b012..ad90d05 100644
--- a/arch/xtensa/include/uapi/asm/shmbuf.h
+++ b/arch/xtensa/include/uapi/asm/shmbuf.h
@@ -19,6 +19,8 @@
 #ifndef _XTENSA_SHMBUF_H
 #define _XTENSA_SHMBUF_H
 
+#include <asm/ipcbuf.h>
+
 #if defined (__XTENSA_EL__)
 struct shmid64_ds {
 	struct ipc64_perm	shm_perm;	/* operation perms */
-- 
ldv
