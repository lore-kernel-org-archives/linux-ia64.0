From: Grant Grundler <iod00d@hp.com>
Date: Thu, 16 Oct 2003 19:16:36 +0000
Subject: PATCH 2.4.23-pre6 gcc-3.3 support (xor.S)
Message-Id: <marc-linux-ia64-106633200522585@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hi Bjorn,
gcc-3.3 doesn't like the asm("") spread out over 250 lines.
I gather gcc-3.3 doesn't like line breaks inside a string.
Besides, it just feels wrong to have a 250 line asm().

Fortunately 2.6 already fixes this problem. Here's a "back port"
of xor.S from davidm's linux-ia64-2.5 bk tree.

BTW, since the function prototypes in xor.h are identical,
I've assumed 2.6 xor.S is functionally identical/compatible too.

grant


diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-ia64-2.4-orig/arch/ia64/lib/Makefile linux-ia64-2.4/arch/ia64/lib/Makefile
--- linux-ia64-2.4-orig/arch/ia64/lib/Makefile	Thu Oct 16 11:57:49 2003
+++ linux-ia64-2.4/arch/ia64/lib/Makefile	Thu Oct 16 09:20:36 2003
@@ -18,6 +18,7 @@
 
 obj-$(CONFIG_ITANIUM) += copy_page.o copy_user.o memcpy.o
 obj-$(CONFIG_MCKINLEY) += copy_page_mck.o memcpy_mck.o
+obj-$(CONFIG_MD_RAID5) += xor.o
 
 IGNORE_FLAGS_OBJS =	__divsi3.o __udivsi3.o __modsi3.o __umodsi3.o \
 			__divdi3.o __udivdi3.o __moddi3.o __umoddi3.o
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-ia64-2.4-orig/arch/ia64/lib/xor.S linux-ia64-2.4/arch/ia64/lib/xor.S
--- linux-ia64-2.4-orig/arch/ia64/lib/xor.S	Wed Dec 31 16:00:00 1969
+++ linux-ia64-2.4/arch/ia64/lib/xor.S	Thu Oct 16 09:19:20 2003
@@ -0,0 +1,184 @@
+/*
+ * arch/ia64/lib/xor.S
+ *
+ * Optimized RAID-5 checksumming functions for IA-64.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2, or (at your option)
+ * any later version.
+ *
+ * You should have received a copy of the GNU General Public License
+ * (for example /usr/src/linux/COPYING); if not, write to the Free
+ * Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+
+#include <asm/asmmacro.h>
+
+GLOBAL_ENTRY(xor_ia64_2)
+	.prologue
+	.fframe 0
+	.save ar.pfs, r31
+	alloc r31 = ar.pfs, 3, 0, 13, 16
+	.save ar.lc, r30
+	mov r30 = ar.lc
+	.save pr, r29
+	mov r29 = pr
+	;;
+	.body
+	mov r8 = in1
+	mov ar.ec = 6 + 2
+	shr in0 = in0, 3
+	;;
+	adds in0 = -1, in0
+	mov r16 = in1
+	mov r17 = in2
+	;;
+	mov ar.lc = in0
+	mov pr.rot = 1 << 16
+	;;
+	.rotr s1[6+1], s2[6+1], d[2]
+	.rotp p[6+2]
+0:
+(p[0])	ld8.nta s1[0] = [r16], 8
+(p[0])	ld8.nta s2[0] = [r17], 8
+(p[6])	xor d[0] = s1[6], s2[6]
+(p[6+1])st8.nta [r8] = d[1], 8
+	nop.f 0
+	br.ctop.dptk.few 0b
+	;;
+	mov ar.lc = r30
+	mov pr = r29, -1
+	br.ret.sptk.few rp
+END(xor_ia64_2)
+
+GLOBAL_ENTRY(xor_ia64_3)
+	.prologue
+	.fframe 0
+	.save ar.pfs, r31
+	alloc r31 = ar.pfs, 4, 0, 20, 24
+	.save ar.lc, r30
+	mov r30 = ar.lc
+	.save pr, r29
+	mov r29 = pr
+	;;
+	.body
+	mov r8 = in1
+	mov ar.ec = 6 + 2
+	shr in0 = in0, 3
+	;;
+	adds in0 = -1, in0
+	mov r16 = in1
+	mov r17 = in2
+	;;
+	mov r18 = in3
+	mov ar.lc = in0
+	mov pr.rot = 1 << 16
+	;;
+	.rotr s1[6+1], s2[6+1], s3[6+1], d[2]
+	.rotp p[6+2]
+0:
+(p[0])	ld8.nta s1[0] = [r16], 8
+(p[0])	ld8.nta s2[0] = [r17], 8
+(p[6])	xor d[0] = s1[6], s2[6]
+	;;
+(p[0])	ld8.nta s3[0] = [r18], 8
+(p[6+1])st8.nta [r8] = d[1], 8
+(p[6])	xor d[0] = d[0], s3[6]
+	br.ctop.dptk.few 0b
+	;;
+	mov ar.lc = r30
+	mov pr = r29, -1
+	br.ret.sptk.few rp
+END(xor_ia64_3)
+
+GLOBAL_ENTRY(xor_ia64_4)
+	.prologue
+	.fframe 0
+	.save ar.pfs, r31
+	alloc r31 = ar.pfs, 5, 0, 27, 32
+	.save ar.lc, r30
+	mov r30 = ar.lc
+	.save pr, r29
+	mov r29 = pr
+	;;
+	.body
+	mov r8 = in1
+	mov ar.ec = 6 + 2
+	shr in0 = in0, 3
+	;;
+	adds in0 = -1, in0
+	mov r16 = in1
+	mov r17 = in2
+	;;
+	mov r18 = in3
+	mov ar.lc = in0
+	mov pr.rot = 1 << 16
+	mov r19 = in4
+	;;
+	.rotr s1[6+1], s2[6+1], s3[6+1], s4[6+1], d[2]
+	.rotp p[6+2]
+0:
+(p[0])	ld8.nta s1[0] = [r16], 8
+(p[0])	ld8.nta s2[0] = [r17], 8
+(p[6])	xor d[0] = s1[6], s2[6]
+(p[0])	ld8.nta s3[0] = [r18], 8
+(p[0])	ld8.nta s4[0] = [r19], 8
+(p[6])	xor r20 = s3[6], s4[6]
+	;;
+(p[6+1])st8.nta [r8] = d[1], 8
+(p[6])	xor d[0] = d[0], r20
+	br.ctop.dptk.few 0b
+	;;
+	mov ar.lc = r30
+	mov pr = r29, -1
+	br.ret.sptk.few rp
+END(xor_ia64_4)
+
+GLOBAL_ENTRY(xor_ia64_5)
+	.prologue
+	.fframe 0
+	.save ar.pfs, r31
+	alloc r31 = ar.pfs, 6, 0, 34, 40
+	.save ar.lc, r30
+	mov r30 = ar.lc
+	.save pr, r29
+	mov r29 = pr
+	;;
+	.body
+	mov r8 = in1
+	mov ar.ec = 6 + 2
+	shr in0 = in0, 3
+	;;
+	adds in0 = -1, in0
+	mov r16 = in1
+	mov r17 = in2
+	;;
+	mov r18 = in3
+	mov ar.lc = in0
+	mov pr.rot = 1 << 16
+	mov r19 = in4
+	mov r20 = in5
+	;;
+	.rotr s1[6+1], s2[6+1], s3[6+1], s4[6+1], s5[6+1], d[2]
+	.rotp p[6+2]
+0:
+(p[0])	ld8.nta s1[0] = [r16], 8
+(p[0])	ld8.nta s2[0] = [r17], 8
+(p[6])	xor d[0] = s1[6], s2[6]
+(p[0])	ld8.nta s3[0] = [r18], 8
+(p[0])	ld8.nta s4[0] = [r19], 8
+(p[6])	xor r21 = s3[6], s4[6]
+	;;
+(p[0])	ld8.nta s5[0] = [r20], 8
+(p[6+1])st8.nta [r8] = d[1], 8
+(p[6])	xor d[0] = d[0], r21
+	;;
+(p[6])	  xor d[0] = d[0], s5[6]
+	nop.f 0
+	br.ctop.dptk.few 0b
+	;;
+	mov ar.lc = r30
+	mov pr = r29, -1
+	br.ret.sptk.few rp
+END(xor_ia64_5)
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-ia64-2.4-orig/include/asm-ia64/xor.h linux-ia64-2.4/include/asm-ia64/xor.h
--- linux-ia64-2.4-orig/include/asm-ia64/xor.h	Thu Oct 16 11:57:50 2003
+++ linux-ia64-2.4/include/asm-ia64/xor.h	Thu Oct 16 09:18:08 2003
@@ -23,256 +23,6 @@
 extern void xor_ia64_5(unsigned long, unsigned long *, unsigned long *,
 		       unsigned long *, unsigned long *, unsigned long *);
 
-asm ("
-	.text
-
-	// Assume L2 memory latency of 6 cycles.
-
-	.proc xor_ia64_2
-xor_ia64_2:
-	.prologue
-	.fframe 0
-	{ .mii
-	  .save ar.pfs, r31
-	  alloc r31 = ar.pfs, 3, 0, 13, 16
-	  .save ar.lc, r30
-	  mov r30 = ar.lc
-	  .save pr, r29
-	  mov r29 = pr
-	  ;;
-	}
-	.body
-	{ .mii
-	  mov r8 = in1
-	  mov ar.ec = 6 + 2
-	  shr in0 = in0, 3
-	  ;;
-	}
-	{ .mmi
-	  adds in0 = -1, in0
-	  mov r16 = in1
-	  mov r17 = in2
-	  ;;
-	}
-	{ .mii
-	  mov ar.lc = in0
-	  mov pr.rot = 1 << 16
-	  ;;
-	}
-	.rotr s1[6+1], s2[6+1], d[2]
-	.rotp p[6+2]
-0:	 { .mmi
-(p[0])	  ld8.nta s1[0] = [r16], 8
-(p[0])	  ld8.nta s2[0] = [r17], 8
-(p[6])	  xor d[0] = s1[6], s2[6]
-	}
-	{ .mfb
-(p[6+1])  st8.nta [r8] = d[1], 8
-	  nop.f 0
-	  br.ctop.dptk.few 0b
-	  ;;
-	}
-	{ .mii
-	  mov ar.lc = r30
-	  mov pr = r29, -1
-	}
-	{ .bbb
-	  br.ret.sptk.few rp
-	}
-	.endp xor_ia64_2
-
-	.proc xor_ia64_3
-xor_ia64_3:
-	.prologue
-	.fframe 0
-	{ .mii
-	  .save ar.pfs, r31
-	  alloc r31 = ar.pfs, 4, 0, 20, 24
-	  .save ar.lc, r30
-	  mov r30 = ar.lc
-	  .save pr, r29
-	  mov r29 = pr
-	  ;;
-	}
-	.body
-	{ .mii
-	  mov r8 = in1
-	  mov ar.ec = 6 + 2
-	  shr in0 = in0, 3
-	  ;;
-	}
-	{ .mmi
-	  adds in0 = -1, in0
-	  mov r16 = in1
-	  mov r17 = in2
-	  ;;
-	}
-	{ .mii
-	  mov r18 = in3
-	  mov ar.lc = in0
-	  mov pr.rot = 1 << 16
-	  ;;
-	}
-	.rotr s1[6+1], s2[6+1], s3[6+1], d[2]
-	.rotp p[6+2]
-0:	{ .mmi
-(p[0])	  ld8.nta s1[0] = [r16], 8
-(p[0])	  ld8.nta s2[0] = [r17], 8
-(p[6])	  xor d[0] = s1[6], s2[6]
-	  ;;
-	}
-	{ .mmi
-(p[0])	  ld8.nta s3[0] = [r18], 8
-(p[6+1])  st8.nta [r8] = d[1], 8
-(p[6])	  xor d[0] = d[0], s3[6]
-	}
-	{ .bbb
-	  br.ctop.dptk.few 0b
-	  ;;
-	}
-	{ .mii
-	  mov ar.lc = r30
-	  mov pr = r29, -1
-	}
-	{ .bbb
-	  br.ret.sptk.few rp
-	}
-	.endp xor_ia64_3
-
-	.proc xor_ia64_4
-xor_ia64_4:
-	.prologue
-	.fframe 0
-	{ .mii
-	  .save ar.pfs, r31
-	  alloc r31 = ar.pfs, 5, 0, 27, 32
-	  .save ar.lc, r30
-	  mov r30 = ar.lc
-	  .save pr, r29
-	  mov r29 = pr
-	  ;;
-	}
-	.body
-	{ .mii
-	  mov r8 = in1
-	  mov ar.ec = 6 + 2
-	  shr in0 = in0, 3
-	  ;;
-	}
-	{ .mmi
-	  adds in0 = -1, in0
-	  mov r16 = in1
-	  mov r17 = in2
-	  ;;
-	}
-	{ .mii
-	  mov r18 = in3
-	  mov ar.lc = in0
-	  mov pr.rot = 1 << 16
-	}
-	{ .mfb
-	  mov r19 = in4
-	  ;;
-	}
-	.rotr s1[6+1], s2[6+1], s3[6+1], s4[6+1], d[2]
-	.rotp p[6+2]
-0:	{ .mmi
-(p[0])	  ld8.nta s1[0] = [r16], 8
-(p[0])	  ld8.nta s2[0] = [r17], 8
-(p[6])	  xor d[0] = s1[6], s2[6]
-	}
-	{ .mmi
-(p[0])	  ld8.nta s3[0] = [r18], 8
-(p[0])	  ld8.nta s4[0] = [r19], 8
-(p[6])	  xor r20 = s3[6], s4[6]
-	  ;;
-	}
-	{ .mib
-(p[6+1])  st8.nta [r8] = d[1], 8
-(p[6])	  xor d[0] = d[0], r20
-	  br.ctop.dptk.few 0b
-	  ;;
-	}
-	{ .mii
-	  mov ar.lc = r30
-	  mov pr = r29, -1
-	}
-	{ .bbb
-	  br.ret.sptk.few rp
-	}
-	.endp xor_ia64_4
-
-	.proc xor_ia64_5
-xor_ia64_5:
-	.prologue
-	.fframe 0
-	{ .mii
-	  .save ar.pfs, r31
-	  alloc r31 = ar.pfs, 6, 0, 34, 40
-	  .save ar.lc, r30
-	  mov r30 = ar.lc
-	  .save pr, r29
-	  mov r29 = pr
-	  ;;
-	}
-	.body
-	{ .mii
-	  mov r8 = in1
-	  mov ar.ec = 6 + 2
-	  shr in0 = in0, 3
-	  ;;
-	}
-	{ .mmi
-	  adds in0 = -1, in0
-	  mov r16 = in1
-	  mov r17 = in2
-	  ;;
-	}
-	{ .mii
-	  mov r18 = in3
-	  mov ar.lc = in0
-	  mov pr.rot = 1 << 16
-	}
-	{ .mib
-	  mov r19 = in4
-	  mov r20 = in5
-	  ;;
-	}
-	.rotr s1[6+1], s2[6+1], s3[6+1], s4[6+1], s5[6+1], d[2]
-	.rotp p[6+2]
-0:	{ .mmi
-(p[0])	  ld8.nta s1[0] = [r16], 8
-(p[0])	  ld8.nta s2[0] = [r17], 8
-(p[6])	  xor d[0] = s1[6], s2[6]
-	}
-	{ .mmi
-(p[0])	  ld8.nta s3[0] = [r18], 8
-(p[0])	  ld8.nta s4[0] = [r19], 8
-(p[6])	  xor r21 = s3[6], s4[6]
-	  ;;
-	}
-	{ .mmi
-(p[0])	  ld8.nta s5[0] = [r20], 8
-(p[6+1])  st8.nta [r8] = d[1], 8
-(p[6])	  xor d[0] = d[0], r21
-	  ;;
-	}
-	{ .mfb
-(p[6])	  xor d[0] = d[0], s5[6]
-	  nop.f 0
-	  br.ctop.dptk.few 0b
-	  ;;
-	}
-	{ .mii
-	  mov ar.lc = r30
-	  mov pr = r29, -1
-	}
-	{ .bbb
-	  br.ret.sptk.few rp
-	}
-	.endp xor_ia64_5
-");
-
 static struct xor_block_template xor_block_ia64 = {
 	name: "ia64",
 	do_2: xor_ia64_2,
