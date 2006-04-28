From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 28 Apr 2006 02:09:17 +0000
Subject: [rfc] dynamic 3-level / 4-level page table
Message-Id: <4sur0l$s99mf@fmsmga001.fm.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following patch make page table level selectable at boot time.  The
motivation behind this patch is to allow a single kernel image for two
extreme end of customers: very large HPC customer who says 128 TB of
virtual address space is not enough, and very large enterprise customer
who wants every possible performance out of ia64.

Page table walk (both tlb miss and in get_user_pages) is still expensive
for database workload, adding a 4th level is not helping either.  Hence,
this experimental patch was born and I'm soliciting comments.

The core changes are just 3 lines, all others are supportive changes.

+#define pgd_none(pgd)			(pgtbl3 ? 0 : (!pgd_val(pgd)))
+#define pgd_present(pgd)		(pgtbl3 ? 1 : (pgd_val(pgd) != 0UL))
+#define pud_offset(dir,addr)	((pud_t *) (pgtbl3 ? (u64) (dir) : pgd_page(*(dir))) + \
+				(((addr) >> PUD_SHIFT) & (PTRS_PER_PUD - 1)))


Comments?

- Ken


--- ./arch/ia64/kernel/ivt.S.orig	2006-04-27 19:21:55.000000000 -0700
+++ ./arch/ia64/kernel/ivt.S	2006-04-27 19:46:44.000000000 -0700
@@ -142,16 +142,16 @@ ENTRY(vhpt_miss)
 (p7)	dep r17=r18,r17,3,(PAGE_SHIFT-6)	// r17=pgd_offset for region[0-4]
 	cmp.eq p7,p6=0,r21			// unused address bits all zeroes?
 #ifdef CONFIG_PGTABLE_4
-	shr.u r28=r22,PUD_SHIFT			// shift pud index into position
+	extr.u r28=r22,PUD_SHIFT,11		// get pud index
 #else
 	shr.u r18=r22,PMD_SHIFT			// shift pmd index into position
 #endif
 	;;
-	ld8 r17=[r17]				// get *pgd (may be 0)
+	LOAD_PGD(ld8 r17=[r17])			// get *pgd (may be 0)
 	;;
 (p7)	cmp.eq p6,p7=r17,r0			// was pgd_present(*pgd) = NULL?
 #ifdef CONFIG_PGTABLE_4
-	dep r28=r28,r17,3,(PAGE_SHIFT-3)	// r28=pud_offset(pgd,addr)
+	shladd r28=r28,3,r17			// r28=pud_offset(pgd,addr)
 	;;
 	shr.u r18=r22,PMD_SHIFT			// shift pmd index into position
 (p7)	ld8 r29=[r28]				// get *pud (may be 0)
@@ -216,21 +216,11 @@ ENTRY(vhpt_miss)
 	 * r18 = *pte
 	 */
 	ld8 r25=[r21]				// read *pte again
-	ld8 r26=[r17]				// read *pmd again
-#ifdef CONFIG_PGTABLE_4
-	ld8 r19=[r28]				// read *pud again
-#endif
-	cmp.ne p6,p7=r0,r0
 	;;
-	cmp.ne.or.andcm p6,p7=r26,r20		// did *pmd change
-#ifdef CONFIG_PGTABLE_4
-	cmp.ne.or.andcm p6,p7=r19,r29		// did *pud change
-#endif
+	cmp.ne p6,p7=r25,r18			// did *pte change
 	mov r27=PAGE_SHIFT<<2
 	;;
 (p6)	ptc.l r22,r27				// purge PTE page translation
-(p7)	cmp.ne.or.andcm p6,p7=r25,r18		// did *pte change
-	;;
 (p6)	ptc.l r16,r27				// purge translation
 #endif
 
@@ -463,15 +453,15 @@ ENTRY(nested_dtlb_miss)
 (p7)	dep r17=r18,r17,3,(PAGE_SHIFT-6)	// r17=pgd_offset for region[0-4]
 	cmp.eq p7,p6=0,r21			// unused address bits all zeroes?
 #ifdef CONFIG_PGTABLE_4
-	shr.u r18=r22,PUD_SHIFT			// shift pud index into position
+	extr.u r18=r22,PUD_SHIFT,11		// get pud index
 #else
 	shr.u r18=r22,PMD_SHIFT			// shift pmd index into position
 #endif
 	;;
-	ld8 r17=[r17]				// get *pgd (may be 0)
+	LOAD_PGD(ld8 r17=[r17])			// get *pgd (may be 0)
 	;;
 (p7)	cmp.eq p6,p7=r17,r0			// was pgd_present(*pgd) = NULL?
-	dep r17=r18,r17,3,(PAGE_SHIFT-3)	// r17=p[u|m]d_offset(pgd,addr)
+	shladd r17=r18,3,r17			// r17=p[u|m]d_offset(pgd,addr)
 	;;
 #ifdef CONFIG_PGTABLE_4
 (p7)	ld8 r17=[r17]				// get *pud (may be 0)
--- ./arch/ia64/kernel/patch.c.orig	2006-04-27 19:21:55.000000000 -0700
+++ ./arch/ia64/kernel/patch.c	2006-04-27 19:46:03.000000000 -0700
@@ -77,6 +77,26 @@ ia64_patch_imm64 (u64 insn_addr, u64 val
 	ia64_patch(insn_addr + 1, 0x1ffffffffffUL, val >> 22);
 }
 
+void __init
+ia64_patch_pgtbl3(unsigned long start, unsigned long end)
+{
+	s32 *offp = (s32 *) start;
+	u64 ip, mask, insn;
+
+	/* see instruction format M48: nop.m 0 */
+	mask = (1UL << 41) - 1;
+	insn = 1UL << 27;
+
+	while (offp < (s32 *) end) {
+		ip = (u64) offp + *offp;
+		ia64_patch(ip, mask, insn);
+		ia64_fc((void *) ip);
+		++offp;
+	}
+	ia64_sync_i();
+	ia64_srlz_i();
+}
+
 void
 ia64_patch_imm60 (u64 insn_addr, u64 val)
 {
--- ./arch/ia64/kernel/setup.c.orig	2006-04-27 19:21:55.000000000 -0700
+++ ./arch/ia64/kernel/setup.c	2006-04-27 19:46:03.000000000 -0700
@@ -52,6 +52,7 @@
 #include <asm/page.h>
 #include <asm/patch.h>
 #include <asm/pgtable.h>
+#include <asm/mmu_context.h>
 #include <asm/processor.h>
 #include <asm/sal.h>
 #include <asm/sections.h>
@@ -484,6 +485,10 @@ setup_arch (char **cmdline_p)
 	if (!nomca)
 		ia64_mca_init();
 
+	if (pgtbl3)
+		ia64_patch_pgtbl3((u64) __start___pgtbl3_patchlist,
+				  (u64) __end___pgtbl3_patchlist);
+
 	platform_setup(cmdline_p);
 	paging_init();
 }
--- ./arch/ia64/kernel/vmlinux.lds.S.orig	2006-04-27 19:21:55.000000000 -0700
+++ ./arch/ia64/kernel/vmlinux.lds.S	2006-04-27 19:46:03.000000000 -0700
@@ -146,6 +146,13 @@ SECTIONS
 	  __end___vtop_patchlist = .;
 	}
 
+  .data.patch.pgtbl3 : AT(ADDR(.data.patch.pgtbl3) - LOAD_OFFSET)
+	{
+	  __start___pgtbl3_patchlist = .;
+	  *(.data.patch.pgtbl3)
+	  __end___pgtbl3_patchlist = .;
+	}
+
   .data.patch.mckinley_e9 : AT(ADDR(.data.patch.mckinley_e9) - LOAD_OFFSET)
 	{
 	  __start___mckinley_e9_bundles = .;
--- ./arch/ia64/mm/init.c.orig	2006-04-27 19:21:55.000000000 -0700
+++ ./arch/ia64/mm/init.c	2006-04-27 19:46:03.000000000 -0700
@@ -677,3 +677,13 @@ int remove_memory(u64 start, u64 size)
 	return -EINVAL;
 }
 #endif
+
+#ifdef CONFIG_PGTABLE_4
+int pgtbl3;
+static __init int setup_pgtbl3(char *s)
+{
+	pgtbl3 = 1;
+	return 0;
+}
+early_param("pgtbl3", setup_pgtbl3);
+#endif
--- ./include/asm-ia64/asmmacro.h.orig	2006-04-27 19:21:59.000000000 -0700
+++ ./include/asm-ia64/asmmacro.h	2006-04-27 19:46:03.000000000 -0700
@@ -78,6 +78,13 @@ name:
 [1:](pr)movl reg = obj;				\
 	.xdata4 ".data.patch.vtop", 1b-.
 
+	.section ".data.patch.pgtbl3", "a"
+	.previous
+
+#define	LOAD_PGD(insn)				\
+[1:]	insn;					\
+	.xdata4 ".data.patch.pgtbl3", 1b-.
+
 /*
  * For now, we always put in the McKinley E9 workaround.  On CPUs that don't need it,
  * we'll patch out the work-around bundles with NOPs, so their impact is minimal.
--- ./include/asm-ia64/patch.h.orig	2006-03-19 21:53:29.000000000 -0800
+++ ./include/asm-ia64/patch.h	2006-04-27 19:46:03.000000000 -0700
@@ -20,6 +20,7 @@ extern void ia64_patch_imm60 (u64 insn_a
 
 extern void ia64_patch_mckinley_e9 (unsigned long start, unsigned long end);
 extern void ia64_patch_vtop (unsigned long start, unsigned long end);
+extern void ia64_patch_pgtbl3 (unsigned long start, unsigned long end);
 extern void ia64_patch_gate (void);
 
 #endif /* _ASM_IA64_PATCH_H */
--- ./include/asm-ia64/pgalloc.h.orig	2006-03-19 21:53:29.000000000 -0800
+++ ./include/asm-ia64/pgalloc.h	2006-04-27 19:46:03.000000000 -0700
@@ -100,7 +100,8 @@ static inline pud_t *pud_alloc_one(struc
 
 static inline void pud_free(pud_t * pud)
 {
-	pgtable_quicklist_free(pud);
+	if (!pgtbl3)
+		pgtable_quicklist_free(pud);
 }
 #define __pud_free_tlb(tlb, pud)	pud_free(pud)
 #endif /* CONFIG_PGTABLE_4 */
--- ./include/asm-ia64/pgtable.h.orig	2006-04-27 19:21:59.000000000 -0700
+++ ./include/asm-ia64/pgtable.h	2006-04-27 19:46:03.000000000 -0700
@@ -124,10 +124,12 @@
  */
 #ifdef CONFIG_PGTABLE_4
 #define PGDIR_SHIFT		(PUD_SHIFT + (PTRS_PER_PTD_SHIFT))
+#define PGDIR_SIZE		(pgtbl3 ? (__IA64_UL(1) << (PGDIR_SHIFT - 3)) : \
+					  (__IA64_UL(1) << PGDIR_SHIFT))
 #else
 #define PGDIR_SHIFT		(PMD_SHIFT + (PTRS_PER_PTD_SHIFT))
-#endif
 #define PGDIR_SIZE		(__IA64_UL(1) << PGDIR_SHIFT)
+#endif
 #define PGDIR_MASK		(~(PGDIR_SIZE-1))
 #define PTRS_PER_PGD_SHIFT	PTRS_PER_PTD_SHIFT
 #define PTRS_PER_PGD		(1UL << PTRS_PER_PGD_SHIFT)
@@ -153,7 +155,6 @@
 #include <linux/sched.h>	/* for mm_struct */
 #include <asm/bitops.h>
 #include <asm/cacheflush.h>
-#include <asm/mmu_context.h>
 #include <asm/processor.h>
 
 /*
@@ -244,7 +245,7 @@ ia64_phys_addr_valid (unsigned long addr
 #define	kc_vaddr_to_offset(v) ((v) - RGN_BASE(RGN_GATE))
 #define	kc_offset_to_vaddr(o) ((o) + RGN_BASE(RGN_GATE))
 
-#define RGN_MAP_SHIFT (PGDIR_SHIFT + PTRS_PER_PGD_SHIFT - 3)
+#define RGN_MAP_SHIFT	(PGDIR_SHIFT + (!pgtbl3) * PTRS_PER_PGD_SHIFT - 3)
 #define RGN_MAP_LIMIT	((1UL << RGN_MAP_SHIFT) - PAGE_SIZE)	/* per region addr limit */
 
 /*
@@ -286,9 +287,9 @@ ia64_phys_addr_valid (unsigned long addr
 #define pud_page(pud)			((unsigned long) __va(pud_val(pud) & _PFN_MASK))
 
 #ifdef CONFIG_PGTABLE_4
-#define pgd_none(pgd)			(!pgd_val(pgd))
+#define pgd_none(pgd)			(pgtbl3 ? 0 : (!pgd_val(pgd)))
 #define pgd_bad(pgd)			(!ia64_phys_addr_valid(pgd_val(pgd)))
-#define pgd_present(pgd)		(pgd_val(pgd) != 0UL)
+#define pgd_present(pgd)		(pgtbl3 ? 1 : (pgd_val(pgd) != 0UL))
 #define pgd_clear(pgdp)			(pgd_val(*(pgdp)) = 0UL)
 #define pgd_page(pgd)			((unsigned long) __va(pgd_val(pgd) & _PFN_MASK))
 #endif
@@ -362,8 +363,11 @@ pgd_offset (struct mm_struct *mm, unsign
 
 #ifdef CONFIG_PGTABLE_4
 /* Find an entry in the second-level page table.. */
-#define pud_offset(dir,addr) \
-	((pud_t *) pgd_page(*(dir)) + (((addr) >> PUD_SHIFT) & (PTRS_PER_PUD - 1)))
+#define pud_offset(dir,addr)	((pud_t *) (pgtbl3 ? (u64) (dir) : pgd_page(*(dir))) + \
+				(((addr) >> PUD_SHIFT) & (PTRS_PER_PUD - 1)))
+extern int pgtbl3;
+#else
+#define pgtbl3	0
 #endif
 
 /* Find an entry in the third-level page table.. */
--- ./include/asm-ia64/processor.h.orig	2006-04-27 19:21:59.000000000 -0700
+++ ./include/asm-ia64/processor.h	2006-04-27 19:46:03.000000000 -0700
@@ -284,7 +284,6 @@ struct thread_struct {
 	.on_ustack =	0,					\
 	.ksp =		0,					\
 	.map_base =	DEFAULT_MAP_BASE,			\
-	.rbs_bot =	STACK_TOP - DEFAULT_USER_STACK_SIZE,	\
 	.task_size =	DEFAULT_TASK_SIZE,			\
 	.last_fph_cpu =  -1,					\
 	INIT_THREAD_IA32					\
--- ./include/asm-ia64/sections.h.orig	2006-03-19 21:53:29.000000000 -0800
+++ ./include/asm-ia64/sections.h	2006-04-27 19:46:03.000000000 -0700
@@ -10,6 +10,7 @@
 
 extern char __per_cpu_start[], __per_cpu_end[], __phys_per_cpu_start[];
 extern char __start___vtop_patchlist[], __end___vtop_patchlist[];
+extern char __start___pgtbl3_patchlist[], __end___pgtbl3_patchlist[];
 extern char __start___mckinley_e9_bundles[], __end___mckinley_e9_bundles[];
 extern char __start_gate_section[];
 extern char __start_gate_mckinley_e9_patchlist[], __end_gate_mckinley_e9_patchlist[];


