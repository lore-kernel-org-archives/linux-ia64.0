From: Jack Steiner <steiner@sgi.com>
Date: Wed, 01 Dec 2004 20:40:34 +0000
Subject: SN support for new chipset - [4 of 4]
Message-Id: <20041201204034.GA26358@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Add support for a future SGI chipset (shub2).
(All code is SN-specific)

Change the code that manages the LEDs so that it
works on both shub1 & shub2.



	Signed-off-by: Jack Steiner <steiner@sgi.com>




Index: linux/arch/ia64/sn/include/shub.h
=================================--- linux.orig/arch/ia64/sn/include/shub.h	2004-12-01 10:08:18.486493296 -0600
+++ /dev/null	1970-01-01 00:00:00.000000000 +0000
@@ -1,39 +0,0 @@
-/*
- * This file is subject to the terms and conditions of the GNU General Public
- * License.  See the file "COPYING" in the main directory of this archive
- * for more details.
- *
- * Copyright (c) 2001-2004 Silicon Graphics, Inc.  All rights reserved.
- */
-
-#ifndef _ASM_IA64_SN_SHUB_H
-#define _ASM_IA64_SN_SHUB_H
-
-
-#define MD_MEM_BANKS            4
-
-
-/*
- * Junk Bus Address Space
- *   The junk bus is used to access the PROM, LED's, and UART. It's 
- *   accessed through the local block MMR space. The data path is
- *   16 bits wide. This space requires address bits 31-27 to be set, and
- *   is further divided by address bits 26:15.
- *   The LED addresses are write-only. To read the LEDs, you need to use
- *   SH_JUNK_BUS_LED0-3, defined in shub_mmr.h
- *		
- */
-#define SH_REAL_JUNK_BUS_LED0           0x7fed00000UL
-#define SH_REAL_JUNK_BUS_LED1           0x7fed10000UL
-#define SH_REAL_JUNK_BUS_LED2           0x7fed20000UL
-#define SH_REAL_JUNK_BUS_LED3           0x7fed30000UL
-#define SH_JUNK_BUS_UART0               0x7fed40000UL
-#define SH_JUNK_BUS_UART1               0x7fed40008UL
-#define SH_JUNK_BUS_UART2               0x7fed40010UL
-#define SH_JUNK_BUS_UART3               0x7fed40018UL
-#define SH_JUNK_BUS_UART4               0x7fed40020UL
-#define SH_JUNK_BUS_UART5               0x7fed40028UL
-#define SH_JUNK_BUS_UART6               0x7fed40030UL
-#define SH_JUNK_BUS_UART7               0x7fed40038UL
-
-#endif /* _ASM_IA64_SN_SHUB_H */
Index: linux/arch/ia64/sn/kernel/sn2/timer_interrupt.c
=================================--- linux.orig/arch/ia64/sn/kernel/sn2/timer_interrupt.c	2004-12-01 10:08:18.487469753 -0600
+++ linux/arch/ia64/sn/kernel/sn2/timer_interrupt.c	2004-12-01 10:12:36.961514474 -0600
@@ -34,7 +34,6 @@
 
 #include <linux/interrupt.h>
 #include <asm/sn/pda.h>
-#include "shub.h"
 #include <asm/sn/leds.h>
 
 extern void sn_lb_int_war_check(void);
Index: linux/include/asm-ia64/sn/leds.h
=================================--- linux.orig/include/asm-ia64/sn/leds.h	2004-12-01 10:08:18.536292601 -0600
+++ linux/include/asm-ia64/sn/leds.h	2004-12-01 10:12:36.990808176 -0600
@@ -9,6 +9,7 @@
 
 #include <asm/sn/addrs.h>
 #include <asm/sn/pda.h>
+#include <asm/sn/shub_mmr.h>
 
 #define LED0		(LOCAL_MMR_ADDR(SH_REAL_JUNK_BUS_LED0))
 #define LED_CPU_SHIFT	16
Index: linux/arch/ia64/sn/kernel/setup.c
=================================--- linux.orig/arch/ia64/sn/kernel/setup.c	2004-12-01 10:08:52.138131851 -0600
+++ linux/arch/ia64/sn/kernel/setup.c	2004-12-01 10:12:36.994714003 -0600
@@ -40,7 +40,6 @@
 #include <asm/sn/nodepda.h>
 #include <asm/sn/sn_cpuid.h>
 #include <asm/sn/simulator.h>
-#include "shub.h"
 #include <asm/sn/leds.h>
 #include <asm/sn/bte.h>
 #include <asm/sn/shub_mmr.h>
Index: linux/include/asm-ia64/sn/shub_mmr.h
=================================--- linux.orig/include/asm-ia64/sn/shub_mmr.h	2004-12-01 10:11:53.795295532 -0600
+++ linux/include/asm-ia64/sn/shub_mmr.h	2004-12-01 10:13:21.984962991 -0600
@@ -130,6 +130,19 @@
 #define SH_EVENT_OCCURRED_II_INT1_MASK           0x0000000040000000
 
 /* ================================== */
+/*                         LEDS                                         */
+/* ================================== */
+#define SH1_REAL_JUNK_BUS_LED0			 0x7fed00000UL
+#define SH1_REAL_JUNK_BUS_LED1			 0x7fed10000UL
+#define SH1_REAL_JUNK_BUS_LED2			 0x7fed20000UL
+#define SH1_REAL_JUNK_BUS_LED3			 0x7fed30000UL
+
+#define SH2_REAL_JUNK_BUS_LED0			 0xf0000000UL
+#define SH2_REAL_JUNK_BUS_LED1			 0xf0010000UL
+#define SH2_REAL_JUNK_BUS_LED2			 0xf0020000UL
+#define SH2_REAL_JUNK_BUS_LED3			 0xf0030000UL
+
+/* ================================== */
 /*                         Register "SH1_PTC_0"                         */
 /*       Puge Translation Cache Message Configuration Information       */
 /* ================================== */
@@ -410,6 +423,7 @@
 /* ================================== */
 #define shubmmr(a,b) 		(is_shub2() ? a##2_##b : a##1_##b)
 
+#define SH_REAL_JUNK_BUS_LED0	shubmmr(SH, REAL_JUNK_BUS_LED0)
 #define SH_IPI_INT		shubmmr(SH, IPI_INT)
 #define SH_EVENT_OCCURRED	shubmmr(SH, EVENT_OCCURRED)
 #define SH_EVENT_OCCURRED_ALIAS	shubmmr(SH, EVENT_OCCURRED_ALIAS)
-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


