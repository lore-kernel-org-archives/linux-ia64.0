From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 05 Oct 2004 09:18:26 +0000
Subject: sparse "long" constant cleanup patch
Message-Id: <200410050918.i959IQES001069@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Below is a tested patch to cleanup ia64-code be explicit when using
long constants.  Please apply.

	--david

--
ia64: declare long constants as such

Sparse wants us to be clear about (unsigned) long constants.
Make it so.

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

 arch/ia64/ia32/ia32_signal.c   |    8 ++++----
 arch/ia64/ia32/ia32priv.h      |    2 +-
 arch/ia64/ia32/sys_ia32.c      |    4 ++--
 arch/ia64/kernel/module.c      |   20 ++++++++++----------
 arch/ia64/kernel/patch.c       |   26 +++++++++++++-------------
 arch/ia64/kernel/ptrace.c      |    2 +-
 arch/ia64/kernel/unwind.c      |    2 +-
 arch/ia64/mm/tlb.c             |    2 +-
 include/asm-ia64/elf.h         |    2 +-
 include/asm-ia64/io.h          |    2 +-
 include/asm-ia64/mmu_context.h |   12 ++++++------
 include/asm-ia64/page.h        |    4 ++--
 include/asm-ia64/pgtable.h     |   10 +++++-----
 include/asm-ia64/processor.h   |    4 ++--
 include/asm-ia64/system.h      |    4 ++--
 15 files changed, 52 insertions(+), 52 deletions(-)

=== arch/ia64/ia32/ia32_signal.c 1.30 vs edited ==--- 1.30/arch/ia64/ia32/ia32_signal.c	2004-09-21 12:36:02 -07:00
+++ edited/arch/ia64/ia32/ia32_signal.c	2004-10-04 07:38:03 -07:00
@@ -346,3 +346,3 @@
 	num64 = (num64 << 32) | (lo & 0x1f3f);
-	fcr = (fcr & (~0xff1000001f3f)) | num64;
+	fcr = (fcr & (~0xff1000001f3fUL)) | num64;
 
@@ -357,3 +357,3 @@
 	num64 = (num64 << 16) | (lo & 0xffff);
-	fsr = (fsr & (~0x3fffffffff)) | num64;
+	fsr = (fsr & (~0x3fffffffffUL)) | num64;
 
@@ -364,3 +364,3 @@
 	num64 = (num64 << 32) | lo;
-	fir = (fir & (~0xffffffffffff)) | num64;
+	fir = (fir & (~0xffffffffffffUL)) | num64;
 
@@ -371,3 +371,3 @@
 	num64 = (num64 << 32) | lo;
-	fdr = (fdr & (~0xffffffffffff)) | num64;
+	fdr = (fdr & (~0xffffffffffffUL)) | num64;
 
=== arch/ia64/ia32/ia32priv.h 1.13 vs edited ==--- 1.13/arch/ia64/ia32/ia32priv.h	2004-09-21 12:36:02 -07:00
+++ edited/arch/ia64/ia32/ia32priv.h	2004-10-05 01:44:15 -07:00
@@ -439,7 +439,7 @@
 	 | ((((sd) >> IA32_SEG_DB) & 0x1) << SEG_DB)						 \
 	 | ((((sd) >> IA32_SEG_G) & 0x1) << SEG_G))
 
-#define IA32_IOBASE	0x2000000000000000 /* Virtual address for I/O space */
+#define IA32_IOBASE	0x2000000000000000UL /* Virtual address for I/O space */
 
 #define IA32_CR0	0x80000001	/* Enable PG and PE bits */
 #define IA32_CR4	0x600		/* MMXEX and FXSR on */
=== arch/ia64/ia32/sys_ia32.c 1.104 vs edited ==--- 1.104/arch/ia64/ia32/sys_ia32.c	2004-09-21 12:39:33 -07:00
+++ edited/arch/ia64/ia32/sys_ia32.c	2004-10-05 01:44:15 -07:00
@@ -1765,5 +1765,5 @@
 	num64 = mxcsr & 0xff10;
-	tsk->thread.fcr = (tsk->thread.fcr & (~0xff1000000000)) | (num64<<32);
+	tsk->thread.fcr = (tsk->thread.fcr & (~0xff1000000000UL)) | (num64<<32);
 	num64 = mxcsr & 0x3f;
-	tsk->thread.fsr = (tsk->thread.fsr & (~0x3f00000000)) | (num64<<32);
+	tsk->thread.fsr = (tsk->thread.fsr & (~0x3f00000000UL)) | (num64<<32);
 
=== arch/ia64/kernel/module.c 1.11 vs edited ==--- 1.11/arch/ia64/kernel/module.c	2004-07-09 10:35:59 -07:00
+++ edited/arch/ia64/kernel/module.c	2004-10-04 01:03:22 -07:00
@@ -195,10 +195,10 @@
 		printk(KERN_ERR "%s: value %li out of IMM22 range\n", mod->name, (int64_t)val);
 		return 0;
 	}
-	ia64_patch((u64) insn, 0x01fffcfe000, (  ((val & 0x200000) << 15) /* bit 21 -> 36 */
-					       | ((val & 0x1f0000) <<  6) /* bit 16 -> 22 */
-					       | ((val & 0x00ff80) << 20) /* bit  7 -> 27 */
-					       | ((val & 0x00007f) << 13) /* bit  0 -> 13 */));
+	ia64_patch((u64) insn, 0x01fffcfe000UL, (  ((val & 0x200000UL) << 15) /* bit 21 -> 36 */
+					         | ((val & 0x1f0000UL) <<  6) /* bit 16 -> 22 */
+					         | ((val & 0x00ff80UL) << 20) /* bit  7 -> 27 */
+					         | ((val & 0x00007fUL) << 13) /* bit  0 -> 13 */));
 	return 1;
 }
 
@@ -209,8 +209,8 @@
 		printk(KERN_ERR "%s: value %li out of IMM21b range\n", mod->name, (int64_t)val);
 		return 0;
 	}
-	ia64_patch((u64) insn, 0x11ffffe000, (  ((val & 0x100000) << 16) /* bit 20 -> 36 */
-					      | ((val & 0x0fffff) << 13) /* bit  0 -> 13 */));
+	ia64_patch((u64) insn, 0x11ffffe000UL, (  ((val & 0x100000UL) << 16) /* bit 20 -> 36 */
+					        | ((val & 0x0fffffUL) << 13) /* bit  0 -> 13 */));
 	return 1;
 }
 
@@ -253,9 +253,9 @@
 	long off;
 
 	b0 = b[0]; b1 = b[1];
-	off = (  ((b1 & 0x00fffff000000000) >> 36)		/* imm20b -> bit 0 */
-	       | ((b0 >> 48) << 20) | ((b1 & 0x7fffff) << 36)	/* imm39 -> bit 20 */
-	       | ((b1 & 0x0800000000000000) << 0));		/* i -> bit 59 */
+	off = (  ((b1 & 0x00fffff000000000UL) >> 36)		/* imm20b -> bit 0 */
+	       | ((b0 >> 48) << 20) | ((b1 & 0x7fffffUL) << 36)	/* imm39 -> bit 20 */
+	       | ((b1 & 0x0800000000000000UL) << 0));		/* i -> bit 59 */
 	return (long) plt->bundle[1] + 16*off;
 }
 
@@ -739,7 +739,7 @@
 			if (gp_addressable(mod, val)) {
 				/* turn "ld8" into "mov": */
 				DEBUGP("%s: patching ld8 at %p to mov\n", __FUNCTION__, location);
-				ia64_patch((u64) location, 0x1fff80fe000, 0x10000000000);
+				ia64_patch((u64) location, 0x1fff80fe000UL, 0x10000000000UL);
 			}
 			return 0;
 
=== arch/ia64/kernel/patch.c 1.7 vs edited ==--- 1.7/arch/ia64/kernel/patch.c	2003-11-21 13:24:51 -08:00
+++ edited/arch/ia64/kernel/patch.c	2004-10-04 00:55:02 -07:00
@@ -65,21 +65,21 @@
 ia64_patch_imm64 (u64 insn_addr, u64 val)
 {
 	ia64_patch(insn_addr,
-		   0x01fffefe000, (  ((val & 0x8000000000000000) >> 27) /* bit 63 -> 36 */
-				   | ((val & 0x0000000000200000) <<  0) /* bit 21 -> 21 */
-				   | ((val & 0x00000000001f0000) <<  6) /* bit 16 -> 22 */
-				   | ((val & 0x000000000000ff80) << 20) /* bit  7 -> 27 */
-				   | ((val & 0x000000000000007f) << 13) /* bit  0 -> 13 */));
-	ia64_patch(insn_addr - 1, 0x1ffffffffff, val >> 22);
+		   0x01fffefe000UL, (  ((val & 0x8000000000000000UL) >> 27) /* bit 63 -> 36 */
+				     | ((val & 0x0000000000200000UL) <<  0) /* bit 21 -> 21 */
+				     | ((val & 0x00000000001f0000UL) <<  6) /* bit 16 -> 22 */
+				     | ((val & 0x000000000000ff80UL) << 20) /* bit  7 -> 27 */
+				     | ((val & 0x000000000000007fUL) << 13) /* bit  0 -> 13 */));
+	ia64_patch(insn_addr - 1, 0x1ffffffffffUL, val >> 22);
 }
 
 void
 ia64_patch_imm60 (u64 insn_addr, u64 val)
 {
 	ia64_patch(insn_addr,
-		   0x011ffffe000, (  ((val & 0x0800000000000000) >> 23) /* bit 59 -> 36 */
-				   | ((val & 0x00000000000fffff) << 13) /* bit  0 -> 13 */));
-	ia64_patch(insn_addr - 1, 0x1fffffffffc, val >> 18);
+		   0x011ffffe000UL, (  ((val & 0x0800000000000000UL) >> 23) /* bit 59 -> 36 */
+				     | ((val & 0x00000000000fffffUL) << 13) /* bit  0 -> 13 */));
+	ia64_patch(insn_addr - 1, 0x1fffffffffcUL, val >> 18);
 }
 
 /*
@@ -130,10 +130,10 @@
 
 	while (offp < (s32 *) end) {
 		wp = (u64 *) ia64_imva((char *) offp + *offp);
-		wp[0] = 0x0000000100000000; /* nop.m 0; nop.i 0; nop.i 0 */
-		wp[1] = 0x0004000000000200;
-		wp[2] = 0x0000000100000011; /* nop.m 0; nop.i 0; br.ret.sptk.many b6 */
-		wp[3] = 0x0084006880000200;
+		wp[0] = 0x0000000100000000UL; /* nop.m 0; nop.i 0; nop.i 0 */
+		wp[1] = 0x0004000000000200UL;
+		wp[2] = 0x0000000100000011UL; /* nop.m 0; nop.i 0; br.ret.sptk.many b6 */
+		wp[3] = 0x0084006880000200UL;
 		ia64_fc(wp); ia64_fc(wp + 2);
 		++offp;
 	}
=== arch/ia64/kernel/ptrace.c 1.35 vs edited ==--- 1.35/arch/ia64/kernel/ptrace.c	2004-07-09 22:11:26 -07:00
+++ edited/arch/ia64/kernel/ptrace.c	2004-10-05 00:49:53 -07:00
@@ -833,7 +833,7 @@
 		      case PT_CFM:
 			urbs_end = ia64_get_user_rbs_end(child, pt, &cfm);
 			if (write_access) {
-				if (((cfm ^ *data) & 0x3fffffffffU) != 0) {
+				if (((cfm ^ *data) & 0x3fffffffffUL) != 0) {
 					if (ia64_sync_user_rbs(child, sw,
 							       pt->ar_bspstore, urbs_end) < 0)
 						return -1;
=== arch/ia64/kernel/unwind.c 1.42 vs edited ==--- 1.42/arch/ia64/kernel/unwind.c	2004-09-08 11:49:13 -07:00
+++ edited/arch/ia64/kernel/unwind.c	2004-10-05 01:44:16 -07:00
@@ -1205,7 +1205,7 @@
 static inline unw_hash_index_t
 hash (unsigned long ip)
 {
-#	define hashmagic	0x9e3779b97f4a7c16	/* based on (sqrt(5)/2-1)*2^64 */
+#	define hashmagic	0x9e3779b97f4a7c16UL	/* based on (sqrt(5)/2-1)*2^64 */
 
 	return (ip >> 4)*hashmagic >> (64 - UNW_LOG_HASH_SIZE);
 #undef hashmagic
=== arch/ia64/mm/tlb.c 1.22 vs edited ==--- 1.22/arch/ia64/mm/tlb.c	2004-05-14 19:00:11 -07:00
+++ edited/arch/ia64/mm/tlb.c	2004-10-04 01:06:54 -07:00
@@ -176,7 +176,7 @@
 	if ((status = ia64_pal_vm_page_size(&tr_pgbits, &purge.mask)) != 0) {
 		printk(KERN_ERR "PAL_VM_PAGE_SIZE failed with status=%ld;"
 		       "defaulting to architected purge page-sizes.\n", status);
-		purge.mask = 0x115557000;
+		purge.mask = 0x115557000UL;
 	}
 	purge.max_bits = ia64_fls(purge.mask);
 
=== include/asm-ia64/elf.h 1.16 vs edited ==--- 1.16/include/asm-ia64/elf.h	2004-07-26 22:26:50 -07:00
+++ edited/include/asm-ia64/elf.h	2004-10-05 01:44:16 -07:00
@@ -40,7 +40,7 @@
  * the way of the program that it will "exec", and that there is
  * sufficient room for the brk.
  */
-#define ELF_ET_DYN_BASE		(TASK_UNMAPPED_BASE + 0x800000000)
+#define ELF_ET_DYN_BASE		(TASK_UNMAPPED_BASE + 0x800000000UL)
 
 #define PT_IA_64_UNWIND		0x70000001
 
=== include/asm-ia64/io.h 1.19 vs edited ==--- 1.19/include/asm-ia64/io.h	2004-02-03 21:31:10 -08:00
+++ edited/include/asm-ia64/io.h	2004-10-04 10:19:18 -07:00
@@ -23,7 +23,7 @@
 #define __SLOW_DOWN_IO	do { } while (0)
 #define SLOW_DOWN_IO	do { } while (0)
 
-#define __IA64_UNCACHED_OFFSET	0xc000000000000000	/* region 6 */
+#define __IA64_UNCACHED_OFFSET	0xc000000000000000UL	/* region 6 */
 
 /*
  * The legacy I/O space defined by the ia64 architecture supports only 65536 ports, but
=== include/asm-ia64/mmu_context.h 1.19 vs edited ==--- 1.19/include/asm-ia64/mmu_context.h	2004-08-25 11:16:03 -07:00
+++ edited/include/asm-ia64/mmu_context.h	2004-10-04 00:49:30 -07:00
@@ -110,7 +110,7 @@
 	unsigned long rid_incr = 0;
 	unsigned long rr0, rr1, rr2, rr3, rr4, old_rr4;
 
-	old_rr4 = ia64_get_rr(0x8000000000000000);
+	old_rr4 = ia64_get_rr(0x8000000000000000UL);
 	rid = context << 3;	/* make space for encoding the region number */
 	rid_incr = 1 << 8;
 
@@ -124,11 +124,11 @@
 	rr4 = (rr4 & (~(0xfcUL))) | (old_rr4 & 0xfc);
 #endif
 
-	ia64_set_rr(0x0000000000000000, rr0);
-	ia64_set_rr(0x2000000000000000, rr1);
-	ia64_set_rr(0x4000000000000000, rr2);
-	ia64_set_rr(0x6000000000000000, rr3);
-	ia64_set_rr(0x8000000000000000, rr4);
+	ia64_set_rr(0x0000000000000000UL, rr0);
+	ia64_set_rr(0x2000000000000000UL, rr1);
+	ia64_set_rr(0x4000000000000000UL, rr2);
+	ia64_set_rr(0x6000000000000000UL, rr3);
+	ia64_set_rr(0x8000000000000000UL, rr4);
 	ia64_srlz_i();			/* srlz.i implies srlz.d */
 }
 
=== include/asm-ia64/page.h 1.30 vs edited ==--- 1.30/include/asm-ia64/page.h	2004-09-27 21:38:03 -07:00
+++ edited/include/asm-ia64/page.h	2004-10-04 01:08:21 -07:00
@@ -123,7 +123,7 @@
 #define REGION_KERNEL		7
 
 #ifdef CONFIG_HUGETLB_PAGE
-# define htlbpage_to_page(x)	((REGION_NUMBER(x) << 61)				\
+# define htlbpage_to_page(x)	(((unsigned long) REGION_NUMBER(x) << 61)			\
 				 | (REGION_OFFSET(x) >> (HPAGE_SHIFT-PAGE_SHIFT)))
 # define HUGETLB_PAGE_ORDER	(HPAGE_SHIFT - PAGE_SHIFT)
 # define is_hugepage_only_range(addr, len)		\
@@ -186,7 +186,7 @@
 # define __pgprot(x)	(x)
 #endif /* !STRICT_MM_TYPECHECKS */
 
-#define PAGE_OFFSET			0xe000000000000000
+#define PAGE_OFFSET			__IA64_UL_CONST(0xe000000000000000)
 
 #define VM_DATA_DEFAULT_FLAGS		(VM_READ | VM_WRITE |					\
 					 VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC |		\
=== include/asm-ia64/pgtable.h 1.45 vs edited ==--- 1.45/include/asm-ia64/pgtable.h	2004-08-24 02:08:33 -07:00
+++ edited/include/asm-ia64/pgtable.h	2004-10-04 08:56:36 -07:00
@@ -206,18 +206,18 @@
 #define RGN_SIZE	(1UL << 61)
 #define RGN_KERNEL	7
 
-#define VMALLOC_START		0xa000000200000000
+#define VMALLOC_START		0xa000000200000000UL
 #ifdef CONFIG_VIRTUAL_MEM_MAP
-# define VMALLOC_END_INIT	(0xa000000000000000 + (1UL << (4*PAGE_SHIFT - 9)))
+# define VMALLOC_END_INIT	(0xa000000000000000UL + (1UL << (4*PAGE_SHIFT - 9)))
 # define VMALLOC_END		vmalloc_end
   extern unsigned long vmalloc_end;
 #else
-# define VMALLOC_END		(0xa000000000000000 + (1UL << (4*PAGE_SHIFT - 9)))
+# define VMALLOC_END		(0xa000000000000000UL + (1UL << (4*PAGE_SHIFT - 9)))
 #endif
 
 /* fs/proc/kcore.c */
-#define	kc_vaddr_to_offset(v) ((v) - 0xa000000000000000)
-#define	kc_offset_to_vaddr(o) ((o) + 0xa000000000000000)
+#define	kc_vaddr_to_offset(v) ((v) - 0xa000000000000000UL)
+#define	kc_offset_to_vaddr(o) ((o) + 0xa000000000000000UL)
 
 /*
  * Conversion functions: convert page frame number (pfn) and a protection value to a page
=== include/asm-ia64/processor.h 1.62 vs edited ==--- 1.62/include/asm-ia64/processor.h	2004-08-24 02:08:09 -07:00
+++ edited/include/asm-ia64/processor.h	2004-10-05 01:44:16 -07:00
@@ -28,8 +28,8 @@
 #define IA64_NUM_PMC_REGS	32
 #define IA64_NUM_PMD_REGS	32
 
-#define DEFAULT_MAP_BASE	0x2000000000000000
-#define DEFAULT_TASK_SIZE	0xa000000000000000
+#define DEFAULT_MAP_BASE	__IA64_UL_CONST(0x2000000000000000)
+#define DEFAULT_TASK_SIZE	__IA64_UL_CONST(0xa000000000000000)
 
 /*
  * TASK_SIZE really is a mis-named.  It really is the maximum user
=== include/asm-ia64/system.h 1.46 vs edited ==--- 1.46/include/asm-ia64/system.h	2004-06-17 15:45:17 -07:00
+++ edited/include/asm-ia64/system.h	2004-10-04 00:56:25 -07:00
@@ -19,12 +19,12 @@
 #include <asm/pal.h>
 #include <asm/percpu.h>
 
-#define GATE_ADDR		(0xa000000000000000)
+#define GATE_ADDR		__IA64_UL_CONST(0xa000000000000000)
 /*
  * 0xa000000000000000+2*PERCPU_PAGE_SIZE
  * - 0xa000000000000000+3*PERCPU_PAGE_SIZE remain unmapped (guard page)
  */
-#define KERNEL_START		 0xa000000100000000
+#define KERNEL_START		 __IA64_UL_CONST(0xa000000100000000)
 #define PERCPU_ADDR		(-PERCPU_PAGE_SIZE)
 
 #ifndef __ASSEMBLY__
