From: Mikael Pettersson <mikpelinux@gmail.com>
Date: Sat, 25 Jan 2014 18:16:33 +0000
Subject: [PATCH] ia64 hpsim: enable host idling via SSC_HALT_LIGHT
Message-Id: <21219.65409.623281.112520@gargle.gargle.HOWL>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

When the ia64 kernel idles it calls PAL_HALT_LIGHT,
but that is a no-op when running on ski.  This prevents
ski and the host from idling.

Update pal_emulator_static to recognize PAL_HALT_LIGHT
and to propagate it to ski as a SSC_HALT_LIGHT.  To have
any effect this requires a corresponding ski update to
implement SSC_HALT_LIGHT.

Tested with ski-1.3.2 + ITC 2MHz + SSC_HALT_LIGHT patches
on x86_64.

Signed-off-by: Mikael Pettersson <mikpelinux@gmail.com>
---

diff -rupN linux-3.13/arch/ia64/hp/sim/boot/boot_head.S linux-3.13.ia64-hpsim-SSC_HALT_LIGHT/arch/ia64/hp/sim/boot/boot_head.S
--- linux-3.13/arch/ia64/hp/sim/boot/boot_head.S	2013-07-01 00:13:29.000000000 +0200
+++ linux-3.13.ia64-hpsim-SSC_HALT_LIGHT/arch/ia64/hp/sim/boot/boot_head.S	2014-01-25 11:25:58.453254087 +0100
@@ -5,6 +5,7 @@
 
 #include <asm/asmmacro.h>
 #include <asm/pal.h>
+#include "ssc.h"
 
 	.bss
 	.align 16
@@ -158,6 +159,11 @@ static:	cmp.eq p6,p7=PAL_PTCE_INFO,r28
 	mov	r8=0			/* status = 0 */
 	mov	r9=0x80|0x01		/* NatPage|WB */
 	;;
+1:	cmp.eq p6,p7=PAL_HALT_LIGHT,r28
+(p7)	br.cond.sptk.few 1f
+	mov	r15=SSC_HALT_LIGHT
+	break	0x80001
+	;;
 1:	br.cond.sptk.few rp
 stacked:
 	br.ret.sptk.few rp
diff -rupN linux-3.13/arch/ia64/hp/sim/boot/ssc.h linux-3.13.ia64-hpsim-SSC_HALT_LIGHT/arch/ia64/hp/sim/boot/ssc.h
--- linux-3.13/arch/ia64/hp/sim/boot/ssc.h	2013-07-01 00:13:29.000000000 +0200
+++ linux-3.13.ia64-hpsim-SSC_HALT_LIGHT/arch/ia64/hp/sim/boot/ssc.h	2014-01-25 11:25:58.453254087 +0100
@@ -8,6 +8,7 @@
 
 /* Simulator system calls: */
 
+#define SSC_HALT_LIGHT			19
 #define SSC_CONSOLE_INIT		20
 #define SSC_GETCHAR			21
 #define SSC_PUTCHAR			31
@@ -27,9 +28,13 @@
 
 #define SSC_GET_ARGS			75
 
+#ifndef __ASSEMBLY__
+
 /*
  * Simulator system call.
  */
 extern long ssc (long arg0, long arg1, long arg2, long arg3, int nr);
 
+#endif /* !__ASSEMBLY */
+
 #endif /* ssc_h */
