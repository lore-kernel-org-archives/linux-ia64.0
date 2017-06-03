From: Christoph Hellwig <hch@lst.de>
Date: Sat, 03 Jun 2017 19:01:02 +0000
Subject: [PATCH 5/5] remove non-uapi <asm/siginfo.h>
Message-Id: <20170603190102.28866-6-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170603190102.28866-1-hch@lst.de>
In-Reply-To: <20170603190102.28866-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-arch@vger.kernel.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

By moving the kernel side __SI_* defintions right next to the userspace
ones we can kill the non-uapi versions of <asm/siginfo.h> include
include/asm-generic/siginfo.h and untangle the unholy mess of includes.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/arc/include/asm/Kbuild           |  1 -
 arch/arm/include/asm/Kbuild           |  1 -
 arch/arm/include/uapi/asm/Kbuild      |  2 ++
 arch/c6x/include/asm/Kbuild           |  1 -
 arch/c6x/include/uapi/asm/Kbuild      |  1 +
 arch/cris/include/asm/Kbuild          |  1 -
 arch/cris/include/uapi/asm/Kbuild     |  2 ++
 arch/h8300/include/asm/Kbuild         |  1 -
 arch/h8300/include/uapi/asm/Kbuild    |  2 ++
 arch/hexagon/include/asm/Kbuild       |  1 -
 arch/ia64/include/asm/siginfo.h       |  1 -
 arch/m68k/include/asm/Kbuild          |  1 -
 arch/m68k/include/uapi/asm/Kbuild     |  1 +
 arch/nios2/include/asm/Kbuild         |  1 -
 arch/nios2/include/uapi/asm/Kbuild    |  1 +
 arch/openrisc/include/asm/Kbuild      |  1 -
 arch/openrisc/include/uapi/asm/Kbuild |  2 ++
 arch/sh/include/asm/Kbuild            |  1 -
 arch/sh/include/uapi/asm/Kbuild       |  1 +
 arch/sparc/include/asm/siginfo.h      |  1 -
 arch/unicore32/include/asm/Kbuild     |  1 -
 arch/xtensa/include/asm/Kbuild        |  1 -
 arch/xtensa/include/uapi/asm/Kbuild   |  1 +
 include/asm-generic/siginfo.h         | 17 -----------------
 include/uapi/asm-generic/siginfo.h    | 15 +++++++++++++--
 25 files changed, 26 insertions(+), 33 deletions(-)
 delete mode 100644 arch/ia64/include/asm/siginfo.h
 delete mode 100644 arch/sparc/include/asm/siginfo.h
 delete mode 100644 include/asm-generic/siginfo.h

diff --git a/arch/arc/include/asm/Kbuild b/arch/arc/include/asm/Kbuild
index 7bee4e4799fd..3e74ca5e6402 100644
--- a/arch/arc/include/asm/Kbuild
+++ b/arch/arc/include/asm/Kbuild
@@ -36,7 +36,6 @@ generic-y += preempt.h
 generic-y += resource.h
 generic-y += sembuf.h
 generic-y += shmbuf.h
-generic-y += siginfo.h
 generic-y += socket.h
 generic-y += sockios.h
 generic-y += stat.h
diff --git a/arch/arm/include/asm/Kbuild b/arch/arm/include/asm/Kbuild
index 3a36d99ff836..d8360501c082 100644
--- a/arch/arm/include/asm/Kbuild
+++ b/arch/arm/include/asm/Kbuild
@@ -28,7 +28,6 @@ generic-y += segment.h
 generic-y += sembuf.h
 generic-y += serial.h
 generic-y += shmbuf.h
-generic-y += siginfo.h
 generic-y += simd.h
 generic-y += sizes.h
 generic-y += socket.h
diff --git a/arch/arm/include/uapi/asm/Kbuild b/arch/arm/include/uapi/asm/Kbuild
index 607f702c2d62..e9b098d6b766 100644
--- a/arch/arm/include/uapi/asm/Kbuild
+++ b/arch/arm/include/uapi/asm/Kbuild
@@ -4,3 +4,5 @@ include include/uapi/asm-generic/Kbuild.asm
 genhdr-y += unistd-common.h
 genhdr-y += unistd-oabi.h
 genhdr-y += unistd-eabi.h
+
+generic-y += siginfo.h
diff --git a/arch/c6x/include/asm/Kbuild b/arch/c6x/include/asm/Kbuild
index f0eaf0475e7e..a3c8d05c4cc7 100644
--- a/arch/c6x/include/asm/Kbuild
+++ b/arch/c6x/include/asm/Kbuild
@@ -45,7 +45,6 @@ generic-y += sembuf.h
 generic-y += serial.h
 generic-y += shmbuf.h
 generic-y += shmparam.h
-generic-y += siginfo.h
 generic-y += signal.h
 generic-y += socket.h
 generic-y += sockios.h
diff --git a/arch/c6x/include/uapi/asm/Kbuild b/arch/c6x/include/uapi/asm/Kbuild
index 13a97aa2285f..1c44d3b3eba0 100644
--- a/arch/c6x/include/uapi/asm/Kbuild
+++ b/arch/c6x/include/uapi/asm/Kbuild
@@ -2,3 +2,4 @@
 include include/uapi/asm-generic/Kbuild.asm
 
 generic-y += kvm_para.h
+generic-y += siginfo.h
diff --git a/arch/cris/include/asm/Kbuild b/arch/cris/include/asm/Kbuild
index 2890099992a9..acc5781100c2 100644
--- a/arch/cris/include/asm/Kbuild
+++ b/arch/cris/include/asm/Kbuild
@@ -36,7 +36,6 @@ generic-y += resource.h
 generic-y += sections.h
 generic-y += sembuf.h
 generic-y += shmbuf.h
-generic-y += siginfo.h
 generic-y += socket.h
 generic-y += sockios.h
 generic-y += statfs.h
diff --git a/arch/cris/include/uapi/asm/Kbuild b/arch/cris/include/uapi/asm/Kbuild
index b15bf6bc0e94..b55fc2ae1e8c 100644
--- a/arch/cris/include/uapi/asm/Kbuild
+++ b/arch/cris/include/uapi/asm/Kbuild
@@ -1,2 +1,4 @@
 # UAPI Header export list
 include include/uapi/asm-generic/Kbuild.asm
+
+generic-y += siginfo.h
diff --git a/arch/h8300/include/asm/Kbuild b/arch/h8300/include/asm/Kbuild
index 757cdeb24e6e..99c824608a31 100644
--- a/arch/h8300/include/asm/Kbuild
+++ b/arch/h8300/include/asm/Kbuild
@@ -54,7 +54,6 @@ generic-y += serial.h
 generic-y += setup.h
 generic-y += shmbuf.h
 generic-y += shmparam.h
-generic-y += siginfo.h
 generic-y += sizes.h
 generic-y += socket.h
 generic-y += sockios.h
diff --git a/arch/h8300/include/uapi/asm/Kbuild b/arch/h8300/include/uapi/asm/Kbuild
index b15bf6bc0e94..b55fc2ae1e8c 100644
--- a/arch/h8300/include/uapi/asm/Kbuild
+++ b/arch/h8300/include/uapi/asm/Kbuild
@@ -1,2 +1,4 @@
 # UAPI Header export list
 include include/uapi/asm-generic/Kbuild.asm
+
+generic-y += siginfo.h
diff --git a/arch/hexagon/include/asm/Kbuild b/arch/hexagon/include/asm/Kbuild
index 6b45ef79eb8f..0fc9cb04e6ad 100644
--- a/arch/hexagon/include/asm/Kbuild
+++ b/arch/hexagon/include/asm/Kbuild
@@ -41,7 +41,6 @@ generic-y += sembuf.h
 generic-y += serial.h
 generic-y += shmbuf.h
 generic-y += shmparam.h
-generic-y += siginfo.h
 generic-y += sizes.h
 generic-y += socket.h
 generic-y += sockios.h
diff --git a/arch/ia64/include/asm/siginfo.h b/arch/ia64/include/asm/siginfo.h
deleted file mode 100644
index dd2f2fce976b..000000000000
--- a/arch/ia64/include/asm/siginfo.h
+++ /dev/null
@@ -1 +0,0 @@
-#include <uapi/asm/siginfo.h>
diff --git a/arch/m68k/include/asm/Kbuild b/arch/m68k/include/asm/Kbuild
index 82005d2ff717..5ecf4e47b2e2 100644
--- a/arch/m68k/include/asm/Kbuild
+++ b/arch/m68k/include/asm/Kbuild
@@ -25,7 +25,6 @@ generic-y += preempt.h
 generic-y += resource.h
 generic-y += sections.h
 generic-y += shmparam.h
-generic-y += siginfo.h
 generic-y += spinlock.h
 generic-y += statfs.h
 generic-y += termios.h
diff --git a/arch/m68k/include/uapi/asm/Kbuild b/arch/m68k/include/uapi/asm/Kbuild
index 64368077235a..68b45cc87e2c 100644
--- a/arch/m68k/include/uapi/asm/Kbuild
+++ b/arch/m68k/include/uapi/asm/Kbuild
@@ -5,6 +5,7 @@ generic-y += auxvec.h
 generic-y += msgbuf.h
 generic-y += sembuf.h
 generic-y += shmbuf.h
+generic-y += siginfo.h
 generic-y += socket.h
 generic-y += sockios.h
 generic-y += termbits.h
diff --git a/arch/nios2/include/asm/Kbuild b/arch/nios2/include/asm/Kbuild
index 727dbb333f60..e1a843def56f 100644
--- a/arch/nios2/include/asm/Kbuild
+++ b/arch/nios2/include/asm/Kbuild
@@ -47,7 +47,6 @@ generic-y += segment.h
 generic-y += sembuf.h
 generic-y += serial.h
 generic-y += shmbuf.h
-generic-y += siginfo.h
 generic-y += signal.h
 generic-y += socket.h
 generic-y += sockios.h
diff --git a/arch/nios2/include/uapi/asm/Kbuild b/arch/nios2/include/uapi/asm/Kbuild
index 374bd123329f..51eff5bc2eb4 100644
--- a/arch/nios2/include/uapi/asm/Kbuild
+++ b/arch/nios2/include/uapi/asm/Kbuild
@@ -2,4 +2,5 @@
 include include/uapi/asm-generic/Kbuild.asm
 
 generic-y += setup.h
+generic-y += siginfo.h
 generic-y += ucontext.h
diff --git a/arch/openrisc/include/asm/Kbuild b/arch/openrisc/include/asm/Kbuild
index fdbcf0bf44a4..091585addb91 100644
--- a/arch/openrisc/include/asm/Kbuild
+++ b/arch/openrisc/include/asm/Kbuild
@@ -46,7 +46,6 @@ generic-y += sembuf.h
 generic-y += setup.h
 generic-y += shmbuf.h
 generic-y += shmparam.h
-generic-y += siginfo.h
 generic-y += signal.h
 generic-y += socket.h
 generic-y += sockios.h
diff --git a/arch/openrisc/include/uapi/asm/Kbuild b/arch/openrisc/include/uapi/asm/Kbuild
index b15bf6bc0e94..b55fc2ae1e8c 100644
--- a/arch/openrisc/include/uapi/asm/Kbuild
+++ b/arch/openrisc/include/uapi/asm/Kbuild
@@ -1,2 +1,4 @@
 # UAPI Header export list
 include include/uapi/asm-generic/Kbuild.asm
+
+generic-y += siginfo.h
diff --git a/arch/sh/include/asm/Kbuild b/arch/sh/include/asm/Kbuild
index cf2a75063b53..590c91ae7541 100644
--- a/arch/sh/include/asm/Kbuild
+++ b/arch/sh/include/asm/Kbuild
@@ -29,7 +29,6 @@ generic-y += rwsem.h
 generic-y += sembuf.h
 generic-y += serial.h
 generic-y += shmbuf.h
-generic-y += siginfo.h
 generic-y += sizes.h
 generic-y += socket.h
 generic-y += statfs.h
diff --git a/arch/sh/include/uapi/asm/Kbuild b/arch/sh/include/uapi/asm/Kbuild
index b15bf6bc0e94..4cb0d2f8868c 100644
--- a/arch/sh/include/uapi/asm/Kbuild
+++ b/arch/sh/include/uapi/asm/Kbuild
@@ -1,2 +1,3 @@
 # UAPI Header export list
 include include/uapi/asm-generic/Kbuild.asm
+generic-y += siginfo.h
diff --git a/arch/sparc/include/asm/siginfo.h b/arch/sparc/include/asm/siginfo.h
deleted file mode 100644
index dd2f2fce976b..000000000000
--- a/arch/sparc/include/asm/siginfo.h
+++ /dev/null
@@ -1 +0,0 @@
-#include <uapi/asm/siginfo.h>
diff --git a/arch/unicore32/include/asm/Kbuild b/arch/unicore32/include/asm/Kbuild
index e9ad511c1043..7a53a55341de 100644
--- a/arch/unicore32/include/asm/Kbuild
+++ b/arch/unicore32/include/asm/Kbuild
@@ -44,7 +44,6 @@ generic-y += serial.h
 generic-y += setup.h
 generic-y += shmbuf.h
 generic-y += shmparam.h
-generic-y += siginfo.h
 generic-y += signal.h
 generic-y += sizes.h
 generic-y += socket.h
diff --git a/arch/xtensa/include/asm/Kbuild b/arch/xtensa/include/asm/Kbuild
index cc23e9ecc6bb..30f6290109d4 100644
--- a/arch/xtensa/include/asm/Kbuild
+++ b/arch/xtensa/include/asm/Kbuild
@@ -25,7 +25,6 @@ generic-y += preempt.h
 generic-y += resource.h
 generic-y += rwsem.h
 generic-y += sections.h
-generic-y += siginfo.h
 generic-y += statfs.h
 generic-y += termios.h
 generic-y += topology.h
diff --git a/arch/xtensa/include/uapi/asm/Kbuild b/arch/xtensa/include/uapi/asm/Kbuild
index b15bf6bc0e94..4cb0d2f8868c 100644
--- a/arch/xtensa/include/uapi/asm/Kbuild
+++ b/arch/xtensa/include/uapi/asm/Kbuild
@@ -1,2 +1,3 @@
 # UAPI Header export list
 include include/uapi/asm-generic/Kbuild.asm
+generic-y += siginfo.h
diff --git a/include/asm-generic/siginfo.h b/include/asm-generic/siginfo.h
deleted file mode 100644
index 31268a5bf63e..000000000000
--- a/include/asm-generic/siginfo.h
+++ /dev/null
@@ -1,17 +0,0 @@
-#ifndef _ASM_GENERIC_SIGINFO_H
-#define _ASM_GENERIC_SIGINFO_H
-
-#include <uapi/asm-generic/siginfo.h>
-
-#define __SI_MASK	0xffff0000u
-#define __SI_KILL	(0 << 16)
-#define __SI_TIMER	(1 << 16)
-#define __SI_POLL	(2 << 16)
-#define __SI_FAULT	(3 << 16)
-#define __SI_CHLD	(4 << 16)
-#define __SI_RT		(5 << 16)
-#define __SI_MESGQ	(6 << 16)
-#define __SI_SYS	(7 << 16)
-#define __SI_CODE(T,N)	((T) | ((N) & 0xffff))
-
-#endif
diff --git a/include/uapi/asm-generic/siginfo.h b/include/uapi/asm-generic/siginfo.h
index 1abaf62c86fc..9c4eca6b374a 100644
--- a/include/uapi/asm-generic/siginfo.h
+++ b/include/uapi/asm-generic/siginfo.h
@@ -151,7 +151,18 @@ typedef struct siginfo {
 #define si_arch		_sifields._sigsys._arch
 #endif
 
-#ifndef __KERNEL__
+#ifdef __KERNEL__
+#define __SI_MASK	0xffff0000u
+#define __SI_KILL	(0 << 16)
+#define __SI_TIMER	(1 << 16)
+#define __SI_POLL	(2 << 16)
+#define __SI_FAULT	(3 << 16)
+#define __SI_CHLD	(4 << 16)
+#define __SI_RT		(5 << 16)
+#define __SI_MESGQ	(6 << 16)
+#define __SI_SYS	(7 << 16)
+#define __SI_CODE(T,N)	((T) | ((N) & 0xffff))
+#else /* __KERNEL__ */
 #define __SI_KILL	0
 #define __SI_TIMER	0
 #define __SI_POLL	0
@@ -161,7 +172,7 @@ typedef struct siginfo {
 #define __SI_MESGQ	0
 #define __SI_SYS	0
 #define __SI_CODE(T,N)	(N)
-#endif
+#endif /* __KERNEL__ */
 
 /*
  * si_code values
-- 
2.11.0

