From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 05 Oct 2004 09:15:30 +0000
Subject: sparse 0 vs. NULL cleanup patch
Message-Id: <16738.26162.362427.579755@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Below is a tested patch to cleanup ia64-code to use NULL in lieu of 0
where appropriate.  Please apply (note: hp-agp.c is an ia64-only file).

	--david

--
ia64: sparse 0 vs. NULL cleanup

Sparse really wants NULL for NULL-pointers.  This patch makes it so.
The patch should be safe.  It compiles fine, creates no additional
warnings, and the results has been boot-tested on an rx2600.

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

 arch/ia64/hp/common/sba_iommu.c |    4 ++--
 arch/ia64/ia32/ia32_support.c   |    2 +-
 arch/ia64/ia32/ia32priv.h       |    2 +-
 arch/ia64/ia32/sys_ia32.c       |    8 ++++----
 arch/ia64/kernel/acpi-ext.c     |    2 +-
 arch/ia64/kernel/efi.c          |   10 +++++-----
 arch/ia64/kernel/irq.c          |    2 +-
 arch/ia64/kernel/process.c      |    6 +++---
 arch/ia64/kernel/setup.c        |    2 +-
 arch/ia64/kernel/signal.c       |    2 +-
 arch/ia64/kernel/smp.c          |    2 +-
 arch/ia64/kernel/sys_ia64.c     |    2 +-
 arch/ia64/kernel/time.c         |    2 +-
 arch/ia64/kernel/unaligned.c    |    2 +-
 arch/ia64/kernel/unwind.c       |   26 +++++++++++++-------------
 arch/ia64/mm/contig.c           |    2 +-
 arch/ia64/mm/extable.c          |    2 +-
 arch/ia64/mm/init.c             |    4 ++--
 drivers/char/agp/hp-agp.c       |    6 +++---
 include/asm-ia64/elf.h          |    4 ++--
 include/asm-ia64/processor.h    |    2 +-
 21 files changed, 47 insertions(+), 47 deletions(-)

=== arch/ia64/hp/common/sba_iommu.c 1.44 vs edited ==--- 1.44/arch/ia64/hp/common/sba_iommu.c	2004-09-09 15:18:54 -07:00
+++ edited/arch/ia64/hp/common/sba_iommu.c	2004-10-04 10:23:28 -07:00
@@ -1153,7 +1153,7 @@
 {
 	struct scatterlist *dma_sg = startsg;	/* pointer to current DMA */
 	int n_mappings = 0;
-	u64 *pdirp = 0;
+	u64 *pdirp = NULL;
 	unsigned long dma_offset = 0;
 
 	dma_sg--;
@@ -1875,7 +1875,7 @@
 {
 	struct proc_dir_entry *dir, *entry;
 
-	dir = proc_mkdir("bus/mckinley", 0);
+	dir = proc_mkdir("bus/mckinley", NULL);
 	if (!dir)
 		return;
 
=== arch/ia64/ia32/ia32_support.c 1.18 vs edited ==--- 1.18/arch/ia64/ia32/ia32_support.c	2004-09-21 12:36:02 -07:00
+++ edited/arch/ia64/ia32/ia32_support.c	2004-10-04 07:47:24 -07:00
@@ -223,7 +223,7 @@
 	siginfo.si_errno = int_num;	/* XXX is it OK to abuse si_errno like this? */
 	siginfo.si_flags = 0;
 	siginfo.si_isr = 0;
-	siginfo.si_addr = 0;
+	siginfo.si_addr = NULL;
 	siginfo.si_imm = 0;
 	siginfo.si_code = TRAP_BRKPT;
 	force_sig_info(SIGTRAP, &siginfo, current);
=== arch/ia64/ia32/ia32priv.h 1.13 vs edited ==--- 1.13/arch/ia64/ia32/ia32priv.h	2004-09-21 12:36:02 -07:00
+++ edited/arch/ia64/ia32/ia32priv.h	2004-10-04 07:41:31 -07:00
@@ -361,7 +361,7 @@
 /* This macro yields a string that ld.so will use to load
    implementation specific libraries for optimization.  Not terribly
    relevant until we have real hardware to play with... */
-#define ELF_PLATFORM	0
+#define ELF_PLATFORM	NULL
 
 #ifdef __KERNEL__
 # define SET_PERSONALITY(EX,IBCS2)				\
=== arch/ia64/ia32/sys_ia32.c 1.104 vs edited ==--- 1.104/arch/ia64/ia32/sys_ia32.c	2004-09-21 12:39:33 -07:00
+++ edited/arch/ia64/ia32/sys_ia32.c	2004-10-04 08:00:54 -07:00
@@ -216,5 +216,5 @@
 	down_write(&current->mm->mmap_sem);
 	{
-		ret = do_mmap(0, PAGE_START(start), PAGE_SIZE, prot | PROT_WRITE,
+		ret = do_mmap(NULL, PAGE_START(start), PAGE_SIZE, prot | PROT_WRITE,
 			      flags | MAP_FIXED | MAP_ANONYMOUS, 0);
 	}
@@ -266,9 +262,9 @@
 
 	if ((p = kmalloc(sizeof(*p), GFP_KERNEL)) = NULL)
 		return p;
-	p->pp_head = 0;
+	p->pp_head = NULL;
 	p->ppl_rb = RB_ROOT;
-	p->pp_hint = 0;
+	p->pp_hint = NULL;
 	atomic_set(&p->pp_count, 1);
 	return p;
 }
@@ -825,7 +821,7 @@
 		if (!(flags & MAP_ANONYMOUS) && is_congruent)
 			ret = do_mmap(file, pstart, pend - pstart, prot, flags | MAP_FIXED, poff);
 		else
-			ret = do_mmap(0, pstart, pend - pstart,
+			ret = do_mmap(NULL, pstart, pend - pstart,
 				      prot | ((flags & MAP_ANONYMOUS) ? 0 : PROT_WRITE),
 				      flags | MAP_FIXED | MAP_ANONYMOUS, 0);
 	}
=== arch/ia64/kernel/acpi-ext.c 1.4 vs edited ==--- 1.4/arch/ia64/kernel/acpi-ext.c	2003-06-12 00:39:53 -07:00
+++ edited/arch/ia64/kernel/acpi-ext.c	2004-10-04 01:02:02 -07:00
@@ -62,7 +62,7 @@
 	struct acpi_vendor_info info;
 
 	info.descriptor = id;
-	info.data = 0;
+	info.data = NULL;
 
 	acpi_walk_resources(obj, METHOD_NAME__CRS, acpi_vendor_resource_match, &info);
 	if (!info.data)
=== arch/ia64/kernel/efi.c 1.36 vs edited ==--- 1.36/arch/ia64/kernel/efi.c	2004-08-25 10:50:37 -07:00
+++ edited/arch/ia64/kernel/efi.c	2004-10-04 00:52:03 -07:00
@@ -48,7 +48,7 @@
 prefix##_get_time (efi_time_t *tm, efi_time_cap_t *tc)						  \
 {												  \
 	struct ia64_fpreg fr[6];								  \
-	efi_time_cap_t *atc = 0;								  \
+	efi_time_cap_t *atc = NULL;								  \
 	efi_status_t ret;									  \
 												  \
 	if (tc)											  \
@@ -91,7 +91,7 @@
 prefix##_set_wakeup_time (efi_bool_t enabled, efi_time_t *tm)					\
 {												\
 	struct ia64_fpreg fr[6];								\
-	efi_time_t *atm = 0;									\
+	efi_time_t *atm = NULL;									\
 	efi_status_t ret;									\
 												\
 	if (tm)											\
@@ -109,7 +109,7 @@
 		       unsigned long *data_size, void *data)				\
 {											\
 	struct ia64_fpreg fr[6];							\
-	u32 *aattr = 0;									\
+	u32 *aattr = NULL;									\
 	efi_status_t ret;								\
 											\
 	if (attr)									\
@@ -172,7 +172,7 @@
 		       unsigned long data_size, efi_char16_t *data)		\
 {										\
 	struct ia64_fpreg fr[6];						\
-	efi_char16_t *adata = 0;						\
+	efi_char16_t *adata = NULL;						\
 										\
 	if (data)								\
 		adata = adjust_arg(data);					\
@@ -214,7 +214,7 @@
 	efi_time_t tm;
 
 	memset(ts, 0, sizeof(ts));
-	if ((*efi.get_time)(&tm, 0) != EFI_SUCCESS)
+	if ((*efi.get_time)(&tm, NULL) != EFI_SUCCESS)
 		return;
 
 	ts->tv_sec = mktime(tm.year, tm.month, tm.day, tm.hour, tm.minute, tm.second);
=== arch/ia64/kernel/irq.c 1.48 vs edited ==--- 1.48/arch/ia64/kernel/irq.c	2004-09-08 13:05:16 -07:00
+++ edited/arch/ia64/kernel/irq.c	2004-10-04 01:17:54 -07:00
@@ -1180,7 +1180,7 @@
 	int i;
 
 	/* create /proc/irq */
-	root_irq_dir = proc_mkdir("irq", 0);
+	root_irq_dir = proc_mkdir("irq", NULL);
 
 	/* create /proc/irq/prof_cpu_mask */
 	create_prof_cpu_mask(root_irq_dir);
=== arch/ia64/kernel/process.c 1.63 vs edited ==--- 1.63/arch/ia64/kernel/process.c	2004-09-17 00:07:02 -07:00
+++ edited/arch/ia64/kernel/process.c	2004-10-04 05:10:39 -07:00
@@ -74,12 +74,12 @@
 show_stack (struct task_struct *task, unsigned long *sp)
 {
 	if (!task)
-		unw_init_running(ia64_do_show_stack, 0);
+		unw_init_running(ia64_do_show_stack, NULL);
 	else {
 		struct unw_frame_info info;
 
 		unw_init_from_blocked_task(&info, task);
-		ia64_do_show_stack(&info, 0);
+		ia64_do_show_stack(&info, NULL);
 	}
 }
 
@@ -751,7 +753,7 @@
 void
 machine_restart (char *restart_cmd)
 {
-	(*efi.reset_system)(EFI_RESET_WARM, 0, 0, 0);
+	(*efi.reset_system)(EFI_RESET_WARM, 0, 0, NULL);
 }
 
 EXPORT_SYMBOL(machine_restart);
=== arch/ia64/kernel/setup.c 1.79 vs edited ==--- 1.79/arch/ia64/kernel/setup.c	2004-08-04 11:08:05 -07:00
+++ edited/arch/ia64/kernel/setup.c	2004-10-04 00:55:29 -07:00
@@ -680,7 +680,7 @@
 			break;
 	}
 
-	if (ia64_pal_rse_info(&num_phys_stacked, 0) != 0) {
+	if (ia64_pal_rse_info(&num_phys_stacked, NULL) != 0) {
 		printk(KERN_WARNING "cpu_init: PAL RSE info failed; assuming 96 physical "
 		       "stacked regs\n");
 		num_phys_stacked = 96;
=== arch/ia64/kernel/signal.c 1.43 vs edited ==--- 1.43/arch/ia64/kernel/signal.c	2004-08-25 10:13:41 -07:00
+++ edited/arch/ia64/kernel/signal.c	2004-10-04 05:24:53 -07:00
@@ -260,7 +260,7 @@
 	 * It is more difficult to avoid calling this function than to
 	 * call it and ignore errors.
 	 */
-	do_sigaltstack(&sc->sc_stack, 0, scr->pt.r12);
+	do_sigaltstack(&sc->sc_stack, NULL, scr->pt.r12);
 	return retval;
 
   give_sigsegv:
=== arch/ia64/kernel/smp.c 1.35 vs edited ==--- 1.35/arch/ia64/kernel/smp.c	2004-05-27 15:44:02 -07:00
+++ edited/arch/ia64/kernel/smp.c	2004-10-04 01:03:35 -07:00
@@ -225,7 +225,7 @@
 void
 smp_flush_tlb_all (void)
 {
-	on_each_cpu((void (*)(void *))local_flush_tlb_all, 0, 1, 1);
+	on_each_cpu((void (*)(void *))local_flush_tlb_all, NULL, 1, 1);
 }
 EXPORT_SYMBOL(smp_flush_tlb_all);
 
=== arch/ia64/kernel/sys_ia64.c 1.29 vs edited ==--- 1.29/arch/ia64/kernel/sys_ia64.c	2004-04-05 09:16:24 -07:00
+++ edited/arch/ia64/kernel/sys_ia64.c	2004-10-04 05:11:46 -07:00
@@ -183,7 +183,7 @@
 do_mmap2 (unsigned long addr, unsigned long len, int prot, int flags, int fd, unsigned long pgoff)
 {
 	unsigned long roff;
-	struct file *file = 0;
+	struct file *file = NULL;
 
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 	if (!(flags & MAP_ANONYMOUS)) {
=== arch/ia64/kernel/time.c 1.47 vs edited ==--- 1.47/arch/ia64/kernel/time.c	2004-09-07 23:32:53 -07:00
+++ edited/arch/ia64/kernel/time.c	2004-10-04 01:01:02 -07:00
@@ -167,7 +167,7 @@
 	if (status != 0) {
 		printk(KERN_ERR "SAL_FREQ_BASE_PLATFORM failed: %s\n", ia64_sal_strerror(status));
 	} else {
-		status = ia64_pal_freq_ratios(&proc_ratio, 0, &itc_ratio);
+		status = ia64_pal_freq_ratios(&proc_ratio, NULL, &itc_ratio);
 		if (status != 0)
 			printk(KERN_ERR "PAL_FREQ_RATIOS failed with status=%ld\n", status);
 	}
=== arch/ia64/kernel/unaligned.c 1.21 vs edited ==--- 1.21/arch/ia64/kernel/unaligned.c	2004-04-12 10:54:18 -07:00
+++ edited/arch/ia64/kernel/unaligned.c	2004-10-04 06:20:08 -07:00
@@ -869,7 +869,7 @@
 	 *
 	 * extract the value to be stored
 	 */
-	getreg(ld.imm, &r2, 0, regs);
+	getreg(ld.imm, &r2, NULL, regs);
 
 	/*
 	 * we rely on the macros in unaligned.h for now i.e.,
=== arch/ia64/kernel/unwind.c 1.42 vs edited ==--- 1.42/arch/ia64/kernel/unwind.c	2004-09-08 11:49:13 -07:00
+++ edited/arch/ia64/kernel/unwind.c	2004-10-04 05:12:56 -07:00
@@ -446,7 +446,7 @@
 int
 unw_access_fr (struct unw_frame_info *info, int regnum, struct ia64_fpreg *val, int write)
 {
-	struct ia64_fpreg *addr = 0;
+	struct ia64_fpreg *addr = NULL;
 	struct pt_regs *pt;
 
 	if ((unsigned) (regnum - 2) >= 126) {
@@ -842,7 +842,7 @@
 		}
 		sr->gr_save_loc = grsave;
 		sr->any_spills = 0;
-		sr->imask = 0;
+		sr->imask = NULL;
 		sr->spill_offset = 0x10;	/* default to psp+16 */
 	}
 }
@@ -1230,7 +1230,7 @@
 	unsigned long ip, pr;
 
 	if (UNW_DEBUG_ON(0))
-		return 0;	/* Always regenerate scripts in debug mode */
+		return NULL;	/* Always regenerate scripts in debug mode */
 
 	STAT(++unw.stat.cache.lookups);
 
@@ -1244,7 +1244,7 @@
 
 	index = unw.hash[hash(ip)];
 	if (index >= UNW_CACHE_SIZE)
-		return 0;
+		return NULL;
 
 	script = unw.cache + index;
 	while (1) {
@@ -1255,7 +1255,7 @@
 			return script;
 		}
 		if (script->coll_chain >= UNW_HASH_SIZE)
-			return 0;
+			return NULL;
 		script = unw.cache + script->coll_chain;
 		STAT(++unw.stat.cache.collision_chain_traversals);
 	}
@@ -1305,7 +1305,7 @@
 		if (script->ip) {
 			index = hash(script->ip);
 			tmp = unw.cache + unw.hash[index];
-			prev = 0;
+			prev = NULL;
 			while (1) {
 				if (tmp = script) {
 					if (prev)
@@ -1510,7 +1510,7 @@
 static inline const struct unw_table_entry *
 lookup (struct unw_table *table, unsigned long rel_ip)
 {
-	const struct unw_table_entry *e = 0;
+	const struct unw_table_entry *e = NULL;
 	unsigned long lo, hi, mid;
 
 	/* do a binary search for right entry: */
@@ -1536,8 +1536,8 @@
 static inline struct unw_script *
 build_script (struct unw_frame_info *info)
 {
-	const struct unw_table_entry *e = 0;
-	struct unw_script *script = 0;
+	const struct unw_table_entry *e = NULL;
+	struct unw_script *script = NULL;
 	struct unw_labeled_state *ls, *next;
 	unsigned long ip = info->ip;
 	struct unw_state_record sr;
@@ -1562,7 +1562,7 @@
 	if (!script) {
 		UNW_DPRINT(0, "unwind.%s: failed to create unwind script\n",  __FUNCTION__);
 		STAT(unw.stat.script.build_time += ia64_get_itc() - start);
-		return 0;
+		return NULL;
 	}
 	unw.cache[info->prev_script].hint = script - unw.cache;
 
@@ -1835,7 +1835,7 @@
 		/* don't let obviously bad addresses pollute the cache */
 		/* FIXME: should really be level 0 but it occurs too often. KAO */
 		UNW_DPRINT(1, "unwind.%s: rejecting bad ip=0x%lx\n", __FUNCTION__, info->ip);
-		info->rp_loc = 0;
+		info->rp_loc = NULL;
 		return -1;
 	}
 
@@ -2092,12 +2092,12 @@
 	if (end - start <= 0) {
 		UNW_DPRINT(0, "unwind.%s: ignoring attempt to insert empty unwind table\n",
 			   __FUNCTION__);
-		return 0;
+		return NULL;
 	}
 
 	table = kmalloc(sizeof(*table), GFP_USER);
 	if (!table)
-		return 0;
+		return NULL;
 
 	init_unwind_table(table, name, segment_base, gp, table_start, table_end);
 
=== arch/ia64/mm/contig.c 1.8 vs edited ==--- 1.8/arch/ia64/mm/contig.c	2004-09-27 21:38:03 -07:00
+++ edited/arch/ia64/mm/contig.c	2004-10-04 01:08:57 -07:00
@@ -277,7 +277,7 @@
 		map_size = PAGE_ALIGN(max_low_pfn * sizeof(struct page));
 		vmalloc_end -= map_size;
 		vmem_map = (struct page *) vmalloc_end;
-		efi_memmap_walk(create_mem_map_page_table, 0);
+		efi_memmap_walk(create_mem_map_page_table, NULL);
 
 		mem_map = contig_page_data.node_mem_map = vmem_map;
 		free_area_init_node(0, &contig_page_data, zones_size,
=== arch/ia64/mm/extable.c 1.9 vs edited ==--- 1.9/arch/ia64/mm/extable.c	2004-03-24 04:41:13 -08:00
+++ edited/arch/ia64/mm/extable.c	2004-10-04 01:07:08 -07:00
@@ -77,7 +77,7 @@
                 else
                         last = mid - 1;
         }
-        return 0;
+        return NULL;
 }
 
 void
=== arch/ia64/mm/init.c 1.67 vs edited ==--- 1.67/arch/ia64/mm/init.c	2004-09-21 12:36:02 -07:00
+++ edited/arch/ia64/mm/init.c	2004-10-04 05:15:20 -07:00
@@ -67,9 +67,9 @@
 	if (pgtable_cache_size > (u64) high) {
 		do {
 			if (pgd_quicklist)
-				free_page((unsigned long)pgd_alloc_one_fast(0));
+				free_page((unsigned long)pgd_alloc_one_fast(NULL));
 			if (pmd_quicklist)
-				free_page((unsigned long)pmd_alloc_one_fast(0, 0));
+				free_page((unsigned long)pmd_alloc_one_fast(NULL, 0));
 		} while (pgtable_cache_size > (u64) low);
 	}
 	preempt_enable();
=== drivers/char/agp/hp-agp.c 1.29 vs edited ==--- 1.29/drivers/char/agp/hp-agp.c	2004-07-28 21:58:54 -07:00
+++ edited/drivers/char/agp/hp-agp.c	2004-10-04 09:37:07 -07:00
@@ -97,7 +97,7 @@
 		default:
 			printk(KERN_ERR PFX "Invalid IOTLB page size "
 			       "configuration 0x%x\n", hp->io_tlb_ps);
-			hp->gatt = 0;
+			hp->gatt = NULL;
 			hp->gatt_entries = 0;
 			return -ENODEV;
 	}
@@ -115,7 +115,7 @@
 
 	if (hp->gatt[0] != HP_ZX1_SBA_IOMMU_COOKIE) {
 		/* Normal case when no AGP device in system */
-	    	hp->gatt = 0;
+	    	hp->gatt = NULL;
 		hp->gatt_entries = 0;
 		printk(KERN_ERR PFX "No reserved IO PDIR entry found; "
 		       "GART disabled\n");
@@ -294,7 +294,7 @@
 		if (!hp->io_pdir) {
 			printk(KERN_ERR PFX "Couldn't allocate contiguous "
 				"memory for I/O PDIR\n");
-			hp->gatt = 0;
+			hp->gatt = NULL;
 			hp->gatt_entries = 0;
 			return -ENOMEM;
 		}
=== include/asm-ia64/elf.h 1.16 vs edited ==--- 1.16/include/asm-ia64/elf.h	2004-07-26 22:26:50 -07:00
+++ edited/include/asm-ia64/elf.h	2004-10-04 08:54:35 -07:00
@@ -4,7 +4,7 @@
 /*
  * ELF-specific definitions.
  *
- * Copyright (C) 1998-1999, 2002-2003 Hewlett-Packard Co
+ * Copyright (C) 1998-1999, 2002-2004 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
 
@@ -175,7 +175,7 @@
 /* This macro yields a string that ld.so will use to load
    implementation specific libraries for optimization.  Not terribly
    relevant until we have real hardware to play with... */
-#define ELF_PLATFORM	0
+#define ELF_PLATFORM	NULL
 
 /*
  * Architecture-neutral AT_ values are in the range 0-17.  Leave some room for more of
=== include/asm-ia64/processor.h 1.62 vs edited ==--- 1.62/include/asm-ia64/processor.h	2004-08-24 02:08:09 -07:00
+++ edited/include/asm-ia64/processor.h	2004-10-04 08:02:19 -07:00
@@ -262,7 +262,7 @@
 				.fdr =		0,			\
 				.old_k1 =	0,			\
 				.old_iob =	0,			\
-				.ppl =		0,
+				.ppl =		NULL,
 #else
 # define INIT_THREAD_IA32
 #endif /* CONFIG_IA32_SUPPORT */
