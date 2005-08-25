From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Thu, 25 Aug 2005 00:12:58 +0000
Subject: Add PAL_VM_SUMMARY to bootloader for SKI
Message-Id: <17165.3338.35854.585833@berry.gelato.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



Hi folks,
	At present, the PAL_VM_SUMMARY call isn't implemented in
arch/ia64/kernel/hp/sim/boot/boot_head.S, so the kernel uses the
architected minimum number of bits for the virtual address space.
As one can map more than 2^50 bytes of virtual address using 64k
pages and a three-level page table, this stops the simulator from
working (it silently fails, looping on page_not_present) if 64k pages
are configured.

This patch implements PAL_VM_SUMMARY (and PAL_MEM_ATTRIB for good
measure) and pretends that the simulated machine is a McKinley.

To do the job properly, one would have to add a simulator system call
to get the real number of implemented address bits.  As the simulator
is closed source, I can't do that.

Signed-off-by: Peter Chubb <peterc@gelato.unsw.edu.au>

--- working directory: /home/peterc/kernels/linux-2.6-import/
% cg-diff |cat
diff --git a/arch/ia64/hp/sim/boot/boot_head.S b/arch/ia64/hp/sim/boot/boot_head.S
--- a/arch/ia64/hp/sim/boot/boot_head.S
+++ b/arch/ia64/hp/sim/boot/boot_head.S
@@ -4,11 +4,12 @@
  */
 
 #include <asm/asmmacro.h>
+#include <asm/pal.h>
 
 	.bss
 	.align 16
 stack_mem:
	.skip 16834
 
 	.text
 
@@ -49,7 +50,11 @@ GLOBAL_ENTRY(jmp_to_kernel)
 	br.sptk.few b7
 END(jmp_to_kernel)
 
-
+/*
+ * r28 contains the index of the PAL function
+ * r29--31 the args
+ * Return values in ret0--3 (r8--11)
+ */
 GLOBAL_ENTRY(pal_emulator_static)
 	mov r8=-1
 	mov r9%6
@@ -138,6 +143,17 @@ static:	cmp.eq p6,p7=6,r28		/* PAL_PTCE_
 	st8 [r29]=r0,16			/* clear remaining bits  */
 	st8 [r18]=r0,16			/* clear remaining bits  */
 	;;
+1:	cmp.eq p6,p7=PAL_VM_SUMMARY,r28	/* assume we're */
+(p7)	br.cond.sptk.few 1f		/* simulating McKinley or better */
+	mov	r8=0			/* status <- 0 (success) */
+	movl	r9=0x2044040020F1865	/* 50 bits phys space */
+	movl	r10=0x183C		/* 61 bits VA space */
+	;;
+1:	cmp.eq p6,p7=PAL_MEM_ATTRIB,r28
+(p7)	br.cond.sptk.few 1f
+	mov	r8=0
+	mov	r9=0x80|0x01		/* WB, NatPage */
+	;;
 1:	br.cond.sptk.few rp
 stacked:
 	br.ret.sptk.few rp
