From: "H. J. Lu" <hjl@lucon.org>
Date: Wed, 06 Aug 2003 15:44:10 +0000
Subject: 2.4 PATCH: gcc 3.3 support
Message-Id: <marc-linux-ia64-106018469231198@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Aug 05, 2003 at 04:43:28PM -0600, Bjorn Helgaas wrote:
> On Wednesday 23 July 2003 10:56 am, H. J. Lu wrote:
> > I am using gcc 3.3 to build the ia64 2.4 kernel from
> > 
> > http://lia64.bkbits.net/linux-ia64-2.4
> > 
> > Gcc 3.3 doesn't like multi-line asm statement. I am enclosing a patch
> > here.
> 
> In 2.6, the asm statement was moved into a .S file.  I'd rather see a
> 2.4 patch that does the same thing.
> 
> Also, gcc 3.3.1 was unable to build a stable kernel when I released
> the 2.4.21 ia64 patch.  So use it at your own risk.
> 

This is the patch backed ported from 2.6 kernel. However, I got

# modprobe xor
raid5: measuring checksumming speed
   ia64      :    81.920 MB/sec

The old one I got

# modprobe xor
raid5: measuring checksumming speed
   8regs     :  1769.472 MB/sec
   8regs_prefetch:  1753.088 MB/sec
   32regs    :  2064.384 MB/sec
   32regs_prefetch:  2064.384 MB/sec
   ia64      :  2441.216 MB/sec
raid5: using function: ia64 (2441.216 MB/sec)

It is very strange.


H.J.
-----
--- linux/arch/ia64/kernel/ia64_ksyms.c.gcc-3.3	Tue Jun 24 09:11:08 2003
+++ linux/arch/ia64/kernel/ia64_ksyms.c	Tue Aug  5 19:14:26 2003
@@ -141,6 +141,18 @@ EXPORT_SYMBOL_NOVERS(__udivdi3);
 EXPORT_SYMBOL_NOVERS(__moddi3);
 EXPORT_SYMBOL_NOVERS(__umoddi3);
 
+#if defined(CONFIG_MD_RAID5) || defined(CONFIG_MD_RAID5_MODULE)
+extern void xor_ia64_2(void);
+extern void xor_ia64_3(void);
+extern void xor_ia64_4(void);
+extern void xor_ia64_5(void);
+
+EXPORT_SYMBOL_NOVERS(xor_ia64_2);
+EXPORT_SYMBOL_NOVERS(xor_ia64_3);
+EXPORT_SYMBOL_NOVERS(xor_ia64_4);
+EXPORT_SYMBOL_NOVERS(xor_ia64_5);
+#endif
+
 extern unsigned long ia64_iobase;
 EXPORT_SYMBOL(ia64_iobase);
 
--- linux/arch/ia64/lib/Makefile.gcc-3.3	Tue Jun 24 09:11:08 2003
+++ linux/arch/ia64/lib/Makefile	Tue Aug  5 19:10:30 2003
@@ -16,6 +16,10 @@ obj-y := __divsi3.o __udivsi3.o __modsi3
 	flush.o ip_fast_csum.o io.o do_csum.o						\
 	memset.o strlen.o swiotlb.o
 
+ifdef CONFIG_MD_RAID5
+obj-y += xor.o
+endif
+
 obj-$(CONFIG_ITANIUM) += copy_page.o copy_user.o memcpy.o
 obj-$(CONFIG_MCKINLEY) += copy_page_mck.o memcpy_mck.o
 
@@ -48,4 +52,7 @@ __modsi3.o: idiv32.S
 __umodsi3.o: idiv32.S
 	$(CC) $(AFLAGS) $(AFLAGS_KERNEL) -c -DMODULO -DUNSIGNED -c -o $@ $<
 
+xor.o: xor.S
+	$(CC) $(AFLAGS) $(AFLAGS_KERNEL) -c -o $@ $<
+
 include $(TOPDIR)/Rules.make
--- linux/arch/ia64/lib/xor.S.gcc-3.3	Tue Aug  5 19:19:32 2003
+++ linux/arch/ia64/lib/xor.S	Tue Aug  5 17:34:26 2003
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
--- linux/include/asm-ia64/xor.h.gcc-3.3	Tue Jun 24 09:11:27 2003
+++ linux/include/asm-ia64/xor.h	Tue Aug  5 17:39:15 2003
@@ -13,7 +13,6 @@
  * Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
 
-#include <asm-generic/xor.h>
 
 extern void xor_ia64_2(unsigned long, unsigned long *, unsigned long *);
 extern void xor_ia64_3(unsigned long, unsigned long *, unsigned long *,
@@ -23,256 +22,6 @@ extern void xor_ia64_4(unsigned long, un
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
@@ -281,11 +30,4 @@ static struct xor_block_template xor_blo
 	do_5: xor_ia64_5,
 };
 
-#define XOR_TRY_TEMPLATES     do { \
-		xor_speed(&xor_block_8regs); \
-		xor_speed(&xor_block_8regs_p); \
-		xor_speed(&xor_block_32regs); \
-		xor_speed(&xor_block_32regs_p); \
-		xor_speed(&xor_block_ia64); \
-	} while(0)
-
+#define XOR_TRY_TEMPLATES	xor_speed(&xor_block_ia64)
