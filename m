From: "Dmitry V. Levin" <ldv@altlinux.org>
Date: Thu, 02 Mar 2017 00:22:28 +0000
Subject: [PATCH 2/3] uapi: fix asm/sembuf.h userspace compilation errors
Message-Id: <20170302002228.GB27132@altlinux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAK8P3a3Ptm68i43BT5+kWptDw1koPwexpuFwH3-1naj_xi+arQ@mail.gmail.com>
In-Reply-To: <CAK8P3a3Ptm68i43BT5+kWptDw1koPwexpuFwH3-1naj_xi+arQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: Haavard Skinnemoen <hskinnemoen@gmail.com>, Hans-Christian Egtvedt <egtvedt@samfundet.no>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, David Howells <dhowells@redhat.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>

Include <asm/ipcbuf.h> to fix asm/sembuf.h userspace compilation errors
like this:

/usr/include/asm/sembuf.h:14:20: error: field 'sem_perm' has incomplete type
  struct ipc64_perm sem_perm; /* permissions .. see ipc.h */
/usr/include/asm/sembuf.h:15:2: error: unknown type name '__kernel_time_t'
  __kernel_time_t sem_otime; /* last semop time */
/usr/include/asm/sembuf.h:16:2: error: unknown type name '__kernel_ulong_t'
  __kernel_ulong_t __unused1;
/usr/include/asm/sembuf.h:17:2: error: unknown type name '__kernel_time_t'
  __kernel_time_t sem_ctime; /* last change time */
/usr/include/asm/sembuf.h:18:2: error: unknown type name '__kernel_ulong_t'
  __kernel_ulong_t __unused2;
/usr/include/asm/sembuf.h:19:2: error: unknown type name '__kernel_ulong_t'
  __kernel_ulong_t sem_nsems; /* no. of semaphores in array */
/usr/include/asm/sembuf.h:20:2: error: unknown type name '__kernel_ulong_t'
  __kernel_ulong_t __unused3;
/usr/include/asm/sembuf.h:21:2: error: unknown type name '__kernel_ulong_t'
  __kernel_ulong_t __unused4;

Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>
---
 include/uapi/asm-generic/sembuf.h      | 1 +
 arch/alpha/include/uapi/asm/sembuf.h   | 2 ++
 arch/avr32/include/uapi/asm/sembuf.h   | 2 ++
 arch/frv/include/uapi/asm/sembuf.h     | 2 ++
 arch/ia64/include/uapi/asm/sembuf.h    | 2 ++
 arch/m32r/include/uapi/asm/sembuf.h    | 2 ++
 arch/mips/include/uapi/asm/sembuf.h    | 2 ++
 arch/mn10300/include/uapi/asm/sembuf.h | 2 ++
 arch/parisc/include/uapi/asm/sembuf.h  | 1 +
 arch/powerpc/include/uapi/asm/sembuf.h | 2 ++
 arch/s390/include/uapi/asm/sembuf.h    | 2 ++
 arch/sparc/include/uapi/asm/sembuf.h   | 2 ++
 arch/x86/include/uapi/asm/sembuf.h     | 2 ++
 arch/xtensa/include/uapi/asm/sembuf.h  | 1 +
 14 files changed, 25 insertions(+)

diff --git a/include/uapi/asm-generic/sembuf.h b/include/uapi/asm-generic/sembuf.h
index 4cb2c13..1d910d7 100644
--- a/include/uapi/asm-generic/sembuf.h
+++ b/include/uapi/asm-generic/sembuf.h
@@ -1,6 +1,7 @@
 #ifndef __ASM_GENERIC_SEMBUF_H
 #define __ASM_GENERIC_SEMBUF_H
 
+#include <asm/ipcbuf.h>
 #include <asm/bitsperlong.h>
 
 /*
diff --git a/arch/alpha/include/uapi/asm/sembuf.h b/arch/alpha/include/uapi/asm/sembuf.h
index 7b38b15..b6bdd5f 100644
--- a/arch/alpha/include/uapi/asm/sembuf.h
+++ b/arch/alpha/include/uapi/asm/sembuf.h
@@ -1,6 +1,8 @@
 #ifndef _ALPHA_SEMBUF_H
 #define _ALPHA_SEMBUF_H
 
+#include <asm/ipcbuf.h>
+
 /* 
  * The semid64_ds structure for alpha architecture.
  * Note extra padding because this structure is passed back and forth
diff --git a/arch/avr32/include/uapi/asm/sembuf.h b/arch/avr32/include/uapi/asm/sembuf.h
index 6c6f7cf..ec4ddd6 100644
--- a/arch/avr32/include/uapi/asm/sembuf.h
+++ b/arch/avr32/include/uapi/asm/sembuf.h
@@ -1,6 +1,8 @@
 #ifndef _UAPI__ASM_AVR32_SEMBUF_H
 #define _UAPI__ASM_AVR32_SEMBUF_H
 
+#include <asm/ipcbuf.h>
+
 /*
 * The semid64_ds structure for AVR32 architecture.
  * Note extra padding because this structure is passed back and forth
diff --git a/arch/frv/include/uapi/asm/sembuf.h b/arch/frv/include/uapi/asm/sembuf.h
index 164b127..0d73641 100644
--- a/arch/frv/include/uapi/asm/sembuf.h
+++ b/arch/frv/include/uapi/asm/sembuf.h
@@ -1,6 +1,8 @@
 #ifndef _ASM_SEMBUF_H
 #define _ASM_SEMBUF_H
 
+#include <asm/ipcbuf.h>
+
 /*
  * The semid64_ds structure for FR-V architecture.
  * Note extra padding because this structure is passed back and forth
diff --git a/arch/ia64/include/uapi/asm/sembuf.h b/arch/ia64/include/uapi/asm/sembuf.h
index 1340fbc..2e218b0 100644
--- a/arch/ia64/include/uapi/asm/sembuf.h
+++ b/arch/ia64/include/uapi/asm/sembuf.h
@@ -1,6 +1,8 @@
 #ifndef _ASM_IA64_SEMBUF_H
 #define _ASM_IA64_SEMBUF_H
 
+#include <asm/ipcbuf.h>
+
 /*
  * The semid64_ds structure for IA-64 architecture.
  * Note extra padding because this structure is passed back and forth
diff --git a/arch/m32r/include/uapi/asm/sembuf.h b/arch/m32r/include/uapi/asm/sembuf.h
index c9873d6..58ad1f8 100644
--- a/arch/m32r/include/uapi/asm/sembuf.h
+++ b/arch/m32r/include/uapi/asm/sembuf.h
@@ -1,6 +1,8 @@
 #ifndef _ASM_M32R_SEMBUF_H
 #define _ASM_M32R_SEMBUF_H
 
+#include <asm/ipcbuf.h>
+
 /*
  * The semid64_ds structure for m32r architecture.
  * Note extra padding because this structure is passed back and forth
diff --git a/arch/mips/include/uapi/asm/sembuf.h b/arch/mips/include/uapi/asm/sembuf.h
index e1085ac..a55ab3c 100644
--- a/arch/mips/include/uapi/asm/sembuf.h
+++ b/arch/mips/include/uapi/asm/sembuf.h
@@ -1,6 +1,8 @@
 #ifndef _ASM_SEMBUF_H
 #define _ASM_SEMBUF_H
 
+#include <asm/ipcbuf.h>
+
 /*
  * The semid64_ds structure for the MIPS architecture.
  * Note extra padding because this structure is passed back and forth
diff --git a/arch/mn10300/include/uapi/asm/sembuf.h b/arch/mn10300/include/uapi/asm/sembuf.h
index 301f3f9..3529f55 100644
--- a/arch/mn10300/include/uapi/asm/sembuf.h
+++ b/arch/mn10300/include/uapi/asm/sembuf.h
@@ -1,6 +1,8 @@
 #ifndef _ASM_SEMBUF_H
 #define _ASM_SEMBUF_H
 
+#include <asm/ipcbuf.h>
+
 /*
  * The semid64_ds structure for MN10300 architecture.
  * Note extra padding because this structure is passed back and forth
diff --git a/arch/parisc/include/uapi/asm/sembuf.h b/arch/parisc/include/uapi/asm/sembuf.h
index c20971b..cff5e43 100644
--- a/arch/parisc/include/uapi/asm/sembuf.h
+++ b/arch/parisc/include/uapi/asm/sembuf.h
@@ -1,6 +1,7 @@
 #ifndef _PARISC_SEMBUF_H
 #define _PARISC_SEMBUF_H
 
+#include <asm/ipcbuf.h>
 #include <asm/bitsperlong.h>
 
 /* 
diff --git a/arch/powerpc/include/uapi/asm/sembuf.h b/arch/powerpc/include/uapi/asm/sembuf.h
index 99a4193..d001c0a 100644
--- a/arch/powerpc/include/uapi/asm/sembuf.h
+++ b/arch/powerpc/include/uapi/asm/sembuf.h
@@ -1,6 +1,8 @@
 #ifndef _ASM_POWERPC_SEMBUF_H
 #define _ASM_POWERPC_SEMBUF_H
 
+#include <asm/ipcbuf.h>
+
 /*
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License
diff --git a/arch/s390/include/uapi/asm/sembuf.h b/arch/s390/include/uapi/asm/sembuf.h
index 32626b0..734c9de 100644
--- a/arch/s390/include/uapi/asm/sembuf.h
+++ b/arch/s390/include/uapi/asm/sembuf.h
@@ -1,6 +1,8 @@
 #ifndef _S390_SEMBUF_H
 #define _S390_SEMBUF_H
 
+#include <asm/ipcbuf.h>
+
 /* 
  * The semid64_ds structure for S/390 architecture.
  * Note extra padding because this structure is passed back and forth
diff --git a/arch/sparc/include/uapi/asm/sembuf.h b/arch/sparc/include/uapi/asm/sembuf.h
index faee1be..28f7060 100644
--- a/arch/sparc/include/uapi/asm/sembuf.h
+++ b/arch/sparc/include/uapi/asm/sembuf.h
@@ -1,6 +1,8 @@
 #ifndef _SPARC_SEMBUF_H
 #define _SPARC_SEMBUF_H
 
+#include <asm/ipcbuf.h>
+
 /*
  * The semid64_ds structure for sparc architecture.
  * Note extra padding because this structure is passed back and forth
diff --git a/arch/x86/include/uapi/asm/sembuf.h b/arch/x86/include/uapi/asm/sembuf.h
index cc2d6a3..d88cc89 100644
--- a/arch/x86/include/uapi/asm/sembuf.h
+++ b/arch/x86/include/uapi/asm/sembuf.h
@@ -1,6 +1,8 @@
 #ifndef _ASM_X86_SEMBUF_H
 #define _ASM_X86_SEMBUF_H
 
+#include <asm/ipcbuf.h>
+
 /*
  * The semid64_ds structure for x86 architecture.
  * Note extra padding because this structure is passed back and forth
diff --git a/arch/xtensa/include/uapi/asm/sembuf.h b/arch/xtensa/include/uapi/asm/sembuf.h
index c158704..2494c41 100644
--- a/arch/xtensa/include/uapi/asm/sembuf.h
+++ b/arch/xtensa/include/uapi/asm/sembuf.h
@@ -21,6 +21,7 @@
 #ifndef _XTENSA_SEMBUF_H
 #define _XTENSA_SEMBUF_H
 
+#include <asm/ipcbuf.h>
 #include <asm/byteorder.h>
 
 struct semid64_ds {
-- 
ldv
