From: Jack Steiner <steiner@sgi.com>
Date: Thu, 02 Feb 2006 21:12:02 +0000
Subject: [PATCH] - Eliminate SN pio_phys_xxx macros. Move to assembly
Message-Id: <20060202211202.GA1989@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Rewrite the SN pio_phys_xxx macros in assembly language. This
avoids issues with the Intel icc compiler. Function call
overhead is not an issue - the functions reference PIOs
and take 100's nsec to complete. 

In addition, the functions should likely be in assembly 
language anyway - they reference memory using physical 
addressing mode. One function executes with psr.ic disabled. 

	Signed-off-by: Jack Steiner <steiner@sgi.com>

 arch/ia64/sn/kernel/Makefile   |    3 +
 arch/ia64/sn/kernel/pio_phys.S |   71 +++++++++++++++++++++++++++++++++++++++++
 include/asm-ia64/sn/rw_mmr.h   |   56 ++------------------------------
 3 files changed, 78 insertions(+), 52 deletions(-)


Index: linux/arch/ia64/sn/kernel/Makefile
=================================--- linux.orig/arch/ia64/sn/kernel/Makefile	2006-01-02 21:21:10.000000000 -0600
+++ linux/arch/ia64/sn/kernel/Makefile	2006-02-02 11:02:06.177731444 -0600
@@ -8,7 +8,8 @@
 #
 
 obj-y				+= setup.o bte.o bte_error.o irq.o mca.o idle.o \
-				   huberror.o io_init.o iomv.o klconflib.o sn2/
+				   huberror.o io_init.o iomv.o klconflib.o pio_phys.o \
+				   sn2/
 obj-$(CONFIG_IA64_GENERIC)      += machvec.o
 obj-$(CONFIG_SGI_TIOCX)		+= tiocx.o
 obj-$(CONFIG_IA64_SGI_SN_XP)	+= xp.o
Index: linux/arch/ia64/sn/kernel/pio_phys.S
=================================--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux/arch/ia64/sn/kernel/pio_phys.S	2006-02-02 11:02:56.856285284 -0600
@@ -0,0 +1,71 @@
+/*
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (C) 2000-2005 Silicon Graphics, Inc. All rights reserved.
+ *
+ * This file contains macros used to access MMR registers via
+ * uncached physical addresses.
+ *      pio_phys_read_mmr  - read an MMR
+ *      pio_phys_write_mmr - write an MMR
+ *      pio_atomic_phys_write_mmrs - atomically write 1 or 2 MMRs with psr.ic=0
+ *              Second MMR will be skipped if address is NULL
+ *
+ * Addresses passed to these routines should be uncached physical addresses
+ * 	ie., 0x80000....
+ */
+
+
+
+#include <asm/asmmacro.h>
+#include <asm/page.h>
+
+GLOBAL_ENTRY(pio_phys_read_mmr)
+	.prologue
+	.regstk 1,0,0,0
+	.body
+	mov r2=psr
+	rsm psr.i | psr.dt
+	;;
+	srlz.d
+	ld8.acq r8=[r32]
+	;;
+	mov psr.l=r2;;
+	srlz.d
+	br.ret.sptk.many rp
+END(pio_phys_read_mmr)
+
+GLOBAL_ENTRY(pio_phys_write_mmr)
+	.prologue
+	.regstk 2,0,0,0
+	.body
+	mov r2=psr
+	rsm psr.i | psr.dt
+	;;
+	srlz.d
+	st8.rel [r32]=r33
+	;;
+	mov psr.l=r2;;
+	srlz.d
+	br.ret.sptk.many rp
+END(pio_phys_write_mmr)
+
+GLOBAL_ENTRY(pio_atomic_phys_write_mmrs)
+	.prologue
+	.regstk 4,0,0,0
+	.body
+	mov r2=psr
+	cmp.ne p9,p0=r34,r0;
+	rsm psr.i | psr.dt | psr.ic
+	;;
+	srlz.d
+	st8.rel [r32]=r33
+(p9)	st8.rel [r34]=r35
+	;;
+	mov psr.l=r2;;
+	srlz.d
+	br.ret.sptk.many rp
+END(pio_atomic_phys_write_mmrs)
+
+
Index: linux/include/asm-ia64/sn/rw_mmr.h
=================================--- linux.orig/include/asm-ia64/sn/rw_mmr.h	2006-01-02 21:21:10.000000000 -0600
+++ linux/include/asm-ia64/sn/rw_mmr.h	2006-02-02 10:24:57.236215426 -0600
@@ -3,15 +3,14 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 2002-2004 Silicon Graphics, Inc.  All Rights Reserved.
+ * Copyright (C) 2002-2006 Silicon Graphics, Inc.  All Rights Reserved.
  */
 #ifndef _ASM_IA64_SN_RW_MMR_H
 #define _ASM_IA64_SN_RW_MMR_H
 
 
 /*
- * This file contains macros used to access MMR registers via
- * uncached physical addresses.
+ * This file that access MMRs via uncached physical addresses.
  * 	pio_phys_read_mmr  - read an MMR
  * 	pio_phys_write_mmr - write an MMR
  * 	pio_atomic_phys_write_mmrs - atomically write 1 or 2 MMRs with psr.ic=0
@@ -22,53 +21,8 @@
  */
 
 
-extern inline long
-pio_phys_read_mmr(volatile long *mmr) 
-{
-	long val;
-        asm volatile
-            ("mov r2=psr;;"
-             "rsm psr.i | psr.dt;;"
-             "srlz.i;;"
-             "ld8.acq %0=[%1];;"
-             "mov psr.l=r2;;"
-             "srlz.i;;"
-             : "=r"(val)
-             : "r"(mmr)
-	     : "r2");
-        return val;
-}
-
-
-
-extern inline void
-pio_phys_write_mmr(volatile long *mmr, long val) 
-{
-        asm volatile
-            ("mov r2=psr;;"
-             "rsm psr.i | psr.dt;;"
-             "srlz.i;;"
-             "st8.rel [%0]=%1;;"
-             "mov psr.l=r2;;"
-             "srlz.i;;"
-	     :: "r"(mmr), "r"(val)
-             : "r2", "memory");
-}            
-
-extern inline void
-pio_atomic_phys_write_mmrs(volatile long *mmr1, long val1, volatile long *mmr2, long val2) 
-{
-        asm volatile
-            ("mov r2=psr;;"
-             "rsm psr.i | psr.dt | psr.ic;;"
-	     "cmp.ne p9,p0=%2,r0;"
-             "srlz.i;;"
-             "st8.rel [%0]=%1;"
-             "(p9) st8.rel [%2]=%3;;"
-             "mov psr.l=r2;;"
-             "srlz.i;;"
-	     :: "r"(mmr1), "r"(val1), "r"(mmr2), "r"(val2)
-             : "p9", "r2", "memory");
-}            
+extern inline long pio_phys_read_mmr(volatile long *mmr); 
+extern inline void pio_phys_write_mmr(volatile long *mmr, long val);
+extern inline void pio_atomic_phys_write_mmrs(volatile long *mmr1, long val1, volatile long *mmr2, long val2); 
 
 #endif /* _ASM_IA64_SN_RW_MMR_H */
