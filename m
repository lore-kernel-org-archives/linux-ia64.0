From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 01 Dec 2004 23:53:43 +0000
Subject: [archive] atomic rss handling for page fault patches
Message-Id: <Pine.LNX.4.58.0412011549300.5721@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This is the atomic rss approach that used to be part of the page fault
scalability patchset. The patch simply makes rss and anon_rss atomic so
that the page table lock does not have to be taken while updating those
two variables.

However, the problem is that this results in 2 atomic fetchadd
operations (one for rss one for anon_rss) in the anonymous page fault
handler which cause the atomic handler not scale as well as splitting
rss into the task structure.

Index: linux-2.6.9/kernel/fork.c
=================================--- linux-2.6.9.orig/kernel/fork.c	2004-11-29 12:18:16.000000000 -0800
+++ linux-2.6.9/kernel/fork.c	2004-11-29 14:12:34.000000000 -0800
@@ -173,8 +173,8 @@
 	mm->mmap_cache = NULL;
 	mm->free_area_cache = oldmm->mmap_base;
 	mm->map_count = 0;
-	mm->rss = 0;
-	mm->anon_rss = 0;
+	atomic_set(&mm->mm_rss, 0);
+	atomic_set(&mm->mm_anon_rss, 0);
 	cpus_clear(mm->cpu_vm_mask);
 	mm->mm_rb = RB_ROOT;
 	rb_link = &mm->mm_rb.rb_node;
Index: linux-2.6.9/include/linux/sched.h
=================================--- linux-2.6.9.orig/include/linux/sched.h	2004-11-29 12:18:11.000000000 -0800
+++ linux-2.6.9/include/linux/sched.h	2004-11-29 14:10:25.000000000 -0800
@@ -214,9 +214,11 @@
 	pgd_t * pgd;
 	atomic_t mm_users;			/* How many users with user space? */
 	atomic_t mm_count;			/* How many references to "struct mm_struct" (users count as 1) */
+	atomic_t mm_rss;
+	atomic_t mm_anon_rss;
 	int map_count;				/* number of VMAs */
 	struct rw_semaphore mmap_sem;
-	spinlock_t page_table_lock;		/* Protects page tables, mm->rss, mm->anon_rss */
+	spinlock_t page_table_lock;		/* Protects page tables */

 	struct list_head mmlist;		/* List of maybe swapped mm's.  These are globally strung
 						 * together off init_mm.mmlist, and are protected
@@ -226,7 +228,7 @@
 	unsigned long start_code, end_code, start_data, end_data;
 	unsigned long start_brk, brk, start_stack;
 	unsigned long arg_start, arg_end, env_start, env_end;
-	unsigned long rss, anon_rss, total_vm, locked_vm, shared_vm;
+	unsigned long total_vm, locked_vm, shared_vm;
 	unsigned long exec_vm, stack_vm, reserved_vm, def_flags, nr_ptes;

 	unsigned long saved_auxv[42]; /* for /proc/PID/auxv */
Index: linux-2.6.9/fs/proc/task_mmu.c
=================================--- linux-2.6.9.orig/fs/proc/task_mmu.c	2004-11-29 12:18:10.000000000 -0800
+++ linux-2.6.9/fs/proc/task_mmu.c	2004-11-29 14:11:04.000000000 -0800
@@ -22,7 +22,7 @@
 		"VmPTE:\t%8lu kB\n",
 		(mm->total_vm - mm->reserved_vm) << (PAGE_SHIFT-10),
 		mm->locked_vm << (PAGE_SHIFT-10),
-		mm->rss << (PAGE_SHIFT-10),
+		(unsigned long)atomic_read(&mm->mm_rss) << (PAGE_SHIFT-10),
 		data << (PAGE_SHIFT-10),
 		mm->stack_vm << (PAGE_SHIFT-10), text, lib,
 		(PTRS_PER_PTE*sizeof(pte_t)*mm->nr_ptes) >> 10);
@@ -37,11 +37,13 @@
 int task_statm(struct mm_struct *mm, int *shared, int *text,
 	       int *data, int *resident)
 {
-	*shared = mm->rss - mm->anon_rss;
+	int rss = atomic_read(&mm->mm_rss);
+
+	*shared = rss - atomic_read(&mm->mm_anon_rss);
 	*text = (PAGE_ALIGN(mm->end_code) - (mm->start_code & PAGE_MASK))
 								>> PAGE_SHIFT;
 	*data = mm->total_vm - mm->shared_vm;
-	*resident = mm->rss;
+	*resident = rss;
 	return mm->total_vm;
 }

Index: linux-2.6.9/mm/mmap.c
=================================--- linux-2.6.9.orig/mm/mmap.c	2004-11-29 12:18:16.000000000 -0800
+++ linux-2.6.9/mm/mmap.c	2004-11-29 14:06:20.000000000 -0800
@@ -1850,7 +1850,7 @@
 	vma = mm->mmap;
 	mm->mmap = mm->mmap_cache = NULL;
 	mm->mm_rb = RB_ROOT;
-	mm->rss = 0;
+	atomic_set(&mm->mm_rss, 0);
 	mm->total_vm = 0;
 	mm->locked_vm = 0;

Index: linux-2.6.9/include/asm-generic/tlb.h
=================================--- linux-2.6.9.orig/include/asm-generic/tlb.h	2004-10-18 14:53:05.000000000 -0700
+++ linux-2.6.9/include/asm-generic/tlb.h	2004-11-29 14:06:20.000000000 -0800
@@ -88,11 +88,11 @@
 {
 	int freed = tlb->freed;
 	struct mm_struct *mm = tlb->mm;
-	int rss = mm->rss;
+	int rss = atomic_read(&mm->mm_rss);

 	if (rss < freed)
 		freed = rss;
-	mm->rss = rss - freed;
+	atomic_set(&mm->mm_rss, rss - freed);
 	tlb_flush_mmu(tlb, start, end);

 	/* keep the page table cache within bounds */
Index: linux-2.6.9/fs/binfmt_flat.c
=================================--- linux-2.6.9.orig/fs/binfmt_flat.c	2004-11-29 12:18:10.000000000 -0800
+++ linux-2.6.9/fs/binfmt_flat.c	2004-11-29 14:06:20.000000000 -0800
@@ -650,7 +650,7 @@
 		current->mm->start_brk = datapos + data_len + bss_len;
 		current->mm->brk = (current->mm->start_brk + 3) & ~3;
 		current->mm->context.end_brk = memp + ksize((void *) memp) - stack_len;
-		current->mm->rss = 0;
+		atomic_set(current->mm->mm_rss, 0);
 	}

 	if (flags & FLAT_FLAG_KTRACE)
Index: linux-2.6.9/fs/exec.c
=================================--- linux-2.6.9.orig/fs/exec.c	2004-11-29 12:18:16.000000000 -0800
+++ linux-2.6.9/fs/exec.c	2004-11-29 14:06:20.000000000 -0800
@@ -320,7 +320,7 @@
 		pte_unmap(pte);
 		goto out;
 	}
-	mm->rss++;
+	atomic_inc(&mm->mm_rss);
 	lru_cache_add_active(page);
 	set_pte(pte, pte_mkdirty(pte_mkwrite(mk_pte(
 					page, vma->vm_page_prot))));
Index: linux-2.6.9/mm/memory.c
=================================--- linux-2.6.9.orig/mm/memory.c	2004-11-29 12:18:22.000000000 -0800
+++ linux-2.6.9/mm/memory.c	2004-11-29 14:16:07.000000000 -0800
@@ -333,9 +333,9 @@
 					pte = pte_mkclean(pte);
 				pte = pte_mkold(pte);
 				get_page(page);
-				dst->rss++;
+				atomic_inc(&dst->mm_rss);
 				if (PageAnon(page))
-					dst->anon_rss++;
+					atomic_inc(&dst->mm_anon_rss);
 				set_pte(dst_pte, pte);
 				page_dup_rmap(page);
 cont_copy_pte_range_noset:
@@ -427,7 +427,7 @@
 			if (pte_dirty(pte))
 				set_page_dirty(page);
 			if (PageAnon(page))
-				tlb->mm->anon_rss--;
+				atomic_dec(&tlb->mm->mm_anon_rss);
 			else if (pte_young(pte))
 				mark_page_accessed(page);
 			tlb->freed++;
@@ -1110,9 +1110,9 @@
 	page_table = pte_offset_map(pmd, address);
 	if (likely(pte_same(*page_table, pte))) {
 		if (PageAnon(old_page))
-			mm->anon_rss--;
+			atomic_dec(&mm->mm_anon_rss);
 		if (PageReserved(old_page))
-			++mm->rss;
+			atomic_inc(&mm->mm_rss);
 		else
 			page_remove_rmap(old_page);
 		break_cow(vma, new_page, address, page_table);
@@ -1390,7 +1390,7 @@
 	if (vm_swap_full())
 		remove_exclusive_swap_page(page);

-	mm->rss++;
+	atomic_inc(&mm->mm_rss);
 	pte = mk_pte(page, vma->vm_page_prot);
 	if (write_access && can_share_swap_page(page)) {
 		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
@@ -1467,7 +1467,7 @@
 		 */
 		lru_cache_add_active(page);
 		page_add_anon_rmap(page, vma, addr);
-		mm->rss++;
+		atomic_inc(&mm->mm_rss);

 	}
 	pte_unmap(page_table);
@@ -1567,7 +1567,7 @@
 	/* Only go through if we didn't race with anybody else... */
 	if (pte_none(*page_table)) {
 		if (!PageReserved(new_page))
-			++mm->rss;
+			atomic_inc(&mm->mm_rss);
 		flush_icache_page(vma, new_page);
 		entry = mk_pte(new_page, vma->vm_page_prot);
 		if (write_access)
Index: linux-2.6.9/fs/binfmt_som.c
=================================--- linux-2.6.9.orig/fs/binfmt_som.c	2004-10-18 14:53:51.000000000 -0700
+++ linux-2.6.9/fs/binfmt_som.c	2004-11-29 14:06:20.000000000 -0800
@@ -259,7 +259,7 @@
 	create_som_tables(bprm);

 	current->mm->start_stack = bprm->p;
-	current->mm->rss = 0;
+	atomic_set(current->mm->mm_rss, 0);

 #if 0
 	printk("(start_brk) %08lx\n" , (unsigned long) current->mm->start_brk);
Index: linux-2.6.9/mm/fremap.c
=================================--- linux-2.6.9.orig/mm/fremap.c	2004-11-29 12:18:11.000000000 -0800
+++ linux-2.6.9/mm/fremap.c	2004-11-29 14:06:20.000000000 -0800
@@ -39,7 +39,7 @@
 					set_page_dirty(page);
 				page_remove_rmap(page);
 				page_cache_release(page);
-				mm->rss--;
+				atomic_dec(&mm->mm_rss);
 			}
 		}
 	} else {
@@ -87,7 +87,7 @@

 	zap_pte(mm, vma, addr, pte);

-	mm->rss++;
+	atomic_inc(&mm->mm_rss);
 	flush_icache_page(vma, page);
 	set_pte(pte, mk_pte(page, prot));
 	page_add_file_rmap(page);
Index: linux-2.6.9/mm/swapfile.c
=================================--- linux-2.6.9.orig/mm/swapfile.c	2004-11-29 12:18:11.000000000 -0800
+++ linux-2.6.9/mm/swapfile.c	2004-11-29 14:06:20.000000000 -0800
@@ -431,7 +431,7 @@
 unuse_pte(struct vm_area_struct *vma, unsigned long address, pte_t *dir,
 	swp_entry_t entry, struct page *page)
 {
-	vma->vm_mm->rss++;
+	atomic_inc(&vma->vm_mm->mm_rss);
 	get_page(page);
 	set_pte(dir, pte_mkold(mk_pte(page, vma->vm_page_prot)));
 	page_add_anon_rmap(page, vma, address);
Index: linux-2.6.9/fs/binfmt_aout.c
=================================--- linux-2.6.9.orig/fs/binfmt_aout.c	2004-11-29 12:18:16.000000000 -0800
+++ linux-2.6.9/fs/binfmt_aout.c	2004-11-29 14:06:20.000000000 -0800
@@ -314,7 +314,7 @@
 		(current->mm->start_brk = N_BSSADDR(ex));
 	current->mm->free_area_cache = current->mm->mmap_base;

-	current->mm->rss = 0;
+	atomic_set(&current->mm->mm_rss, 0);
 	current->mm->mmap = NULL;
 	compute_creds(bprm);
  	current->flags &= ~PF_FORKNOEXEC;
Index: linux-2.6.9/arch/ia64/mm/hugetlbpage.c
=================================--- linux-2.6.9.orig/arch/ia64/mm/hugetlbpage.c	2004-10-18 14:54:27.000000000 -0700
+++ linux-2.6.9/arch/ia64/mm/hugetlbpage.c	2004-11-29 14:06:20.000000000 -0800
@@ -65,7 +65,7 @@
 {
 	pte_t entry;

-	mm->rss += (HPAGE_SIZE / PAGE_SIZE);
+	atomic_add(HPAGE_SIZE / PAGE_SIZE, &mm->mm_rss);
 	if (write_access) {
 		entry  		    pte_mkwrite(pte_mkdirty(mk_pte(page, vma->vm_page_prot)));
@@ -108,7 +108,7 @@
 		ptepage = pte_page(entry);
 		get_page(ptepage);
 		set_pte(dst_pte, entry);
-		dst->rss += (HPAGE_SIZE / PAGE_SIZE);
+		atomic_add(HPAGE_SIZE / PAGE_SIZE, &dst->mm_rss);
 		addr += HPAGE_SIZE;
 	}
 	return 0;
@@ -249,7 +249,7 @@
 		put_page(page);
 		pte_clear(pte);
 	}
-	mm->rss -= (end - start) >> PAGE_SHIFT;
+	atomic_sub((end - start) >> PAGE_SHIFT, &mm->mm_rss);
 	flush_tlb_range(vma, start, end);
 }

Index: linux-2.6.9/fs/binfmt_elf.c
=================================--- linux-2.6.9.orig/fs/binfmt_elf.c	2004-11-29 12:18:16.000000000 -0800
+++ linux-2.6.9/fs/binfmt_elf.c	2004-11-29 14:06:20.000000000 -0800
@@ -734,7 +734,7 @@

 	/* Do this so that we can load the interpreter, if need be.  We will
 	   change some of these later */
-	current->mm->rss = 0;
+	atomic_set(&current->mm->mm_rss, 0);
 	current->mm->free_area_cache = current->mm->mmap_base;
 	retval = setup_arg_pages(bprm, executable_stack);
 	if (retval < 0) {
Index: linux-2.6.9/mm/rmap.c
=================================--- linux-2.6.9.orig/mm/rmap.c	2004-11-29 12:18:22.000000000 -0800
+++ linux-2.6.9/mm/rmap.c	2004-11-29 14:09:46.000000000 -0800
@@ -263,7 +263,7 @@
 	pte_t *pte;
 	int referenced = 0;

-	if (!mm->rss)
+	if (!atomic_read(&mm->mm_rss))
 		goto out;
 	address = vma_address(page, vma);
 	if (address = -EFAULT)
@@ -438,7 +438,7 @@
 	BUG_ON(PageReserved(page));
 	BUG_ON(!anon_vma);

-	vma->vm_mm->anon_rss++;
+	atomic_inc(&vma->vm_mm->mm_anon_rss);

 	anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
 	index = (address - vma->vm_start) >> PAGE_SHIFT;
@@ -510,7 +510,7 @@
 	pte_t pteval;
 	int ret = SWAP_AGAIN;

-	if (!mm->rss)
+	if (!atomic_read(&mm->mm_rss))
 		goto out;
 	address = vma_address(page, vma);
 	if (address = -EFAULT)
@@ -587,14 +587,14 @@
 		}
 		pteval = ptep_xchg_flush(vma, address, pte, swp_entry_to_pte(entry));
 		BUG_ON(pte_file(*pte));
-		mm->anon_rss--;
+		atomic_dec(&mm->mm_anon_rss);
 	} else
 		pteval = ptep_clear_flush(vma, address, pte);

 	/* Move the dirty bit to the physical page now the pte is gone. */
 	if (pte_dirty(pteval))
 		set_page_dirty(page);
-	mm->rss--;
+	atomic_dec(&mm->mm_rss);
 	page_remove_rmap(page);
 	page_cache_release(page);

@@ -700,7 +700,7 @@

 		page_remove_rmap(page);
 		page_cache_release(page);
-		mm->rss--;
+		atomic_dec(&mm->mm_rss);
 		(*mapcount)--;
 	}

@@ -799,7 +799,7 @@
 			if (vma->vm_flags & (VM_LOCKED|VM_RESERVED))
 				continue;
 			cursor = (unsigned long) vma->vm_private_data;
-			while (vma->vm_mm->rss &&
+			while (atomic_read(&vma->vm_mm->mm_rss) &&
 				cursor < max_nl_cursor &&
 				cursor < vma->vm_end - vma->vm_start) {
 				try_to_unmap_cluster(cursor, &mapcount, vma);
Index: linux-2.6.9/include/asm-ia64/tlb.h
=================================--- linux-2.6.9.orig/include/asm-ia64/tlb.h	2004-10-18 14:53:51.000000000 -0700
+++ linux-2.6.9/include/asm-ia64/tlb.h	2004-11-29 14:06:20.000000000 -0800
@@ -161,11 +161,11 @@
 {
 	unsigned long freed = tlb->freed;
 	struct mm_struct *mm = tlb->mm;
-	unsigned long rss = mm->rss;
+	unsigned long rss = atomic_read(&mm->mm_rss);

 	if (rss < freed)
 		freed = rss;
-	mm->rss = rss - freed;
+	atomic_sub(freed, &mm->mm_rss);
 	/*
 	 * Note: tlb->nr may be 0 at this point, so we can't rely on tlb->start_addr and
 	 * tlb->end_addr.
Index: linux-2.6.9/include/asm-arm/tlb.h
=================================--- linux-2.6.9.orig/include/asm-arm/tlb.h	2004-10-18 14:53:07.000000000 -0700
+++ linux-2.6.9/include/asm-arm/tlb.h	2004-11-29 14:06:20.000000000 -0800
@@ -54,11 +54,11 @@
 {
 	struct mm_struct *mm = tlb->mm;
 	unsigned long freed = tlb->freed;
-	int rss = mm->rss;
+	int rss = atomic_read(&mm->mm_rss);

 	if (rss < freed)
 		freed = rss;
-	mm->rss = rss - freed;
+	atomic_sub(freed, &mm->mm_rss);

 	if (freed) {
 		flush_tlb_mm(mm);
Index: linux-2.6.9/include/asm-arm26/tlb.h
=================================--- linux-2.6.9.orig/include/asm-arm26/tlb.h	2004-10-18 14:55:29.000000000 -0700
+++ linux-2.6.9/include/asm-arm26/tlb.h	2004-11-29 14:06:20.000000000 -0800
@@ -35,11 +35,11 @@
 {
         struct mm_struct *mm = tlb->mm;
         unsigned long freed = tlb->freed;
-        int rss = mm->rss;
+        int rss = atomic_read(&mm->mm_rss);

         if (rss < freed)
                 freed = rss;
-        mm->rss = rss - freed;
+        atomic_sub(freed, &mm->mm_rss);

         if (freed) {
                 flush_tlb_mm(mm);
Index: linux-2.6.9/include/asm-sparc64/tlb.h
=================================--- linux-2.6.9.orig/include/asm-sparc64/tlb.h	2004-10-18 14:54:54.000000000 -0700
+++ linux-2.6.9/include/asm-sparc64/tlb.h	2004-11-29 14:06:20.000000000 -0800
@@ -80,11 +80,11 @@
 {
 	unsigned long freed = mp->freed;
 	struct mm_struct *mm = mp->mm;
-	unsigned long rss = mm->rss;
+	unsigned long rss = atomic_read(&mm->mm_rss);

 	if (rss < freed)
 		freed = rss;
-	mm->rss = rss - freed;
+	atomic_sub(freed, &mm->mm_rss);

 	tlb_flush_mmu(mp);

Index: linux-2.6.9/arch/sh/mm/hugetlbpage.c
=================================--- linux-2.6.9.orig/arch/sh/mm/hugetlbpage.c	2004-10-18 14:54:32.000000000 -0700
+++ linux-2.6.9/arch/sh/mm/hugetlbpage.c	2004-11-29 14:06:20.000000000 -0800
@@ -62,7 +62,7 @@
 	unsigned long i;
 	pte_t entry;

-	mm->rss += (HPAGE_SIZE / PAGE_SIZE);
+	atomic_add(HPAGE_SIZE / PAGE_SIZE, &mm->mm_rss);

 	if (write_access)
 		entry = pte_mkwrite(pte_mkdirty(mk_pte(page,
@@ -115,7 +115,7 @@
 			pte_val(entry) += PAGE_SIZE;
 			dst_pte++;
 		}
-		dst->rss += (HPAGE_SIZE / PAGE_SIZE);
+		atomic_add(HPAGE_SIZE / PAGE_SIZE, &dst->mm_rss);
 		addr += HPAGE_SIZE;
 	}
 	return 0;
@@ -206,7 +206,7 @@
 			pte++;
 		}
 	}
-	mm->rss -= (end - start) >> PAGE_SHIFT;
+	atomic_sub((end - start) >> PAGE_SHIFT, &mm->mm_rss);
 	flush_tlb_range(vma, start, end);
 }

Index: linux-2.6.9/arch/x86_64/ia32/ia32_aout.c
=================================--- linux-2.6.9.orig/arch/x86_64/ia32/ia32_aout.c	2004-11-29 12:18:08.000000000 -0800
+++ linux-2.6.9/arch/x86_64/ia32/ia32_aout.c	2004-11-29 14:06:20.000000000 -0800
@@ -310,7 +310,7 @@
 		(current->mm->start_brk = N_BSSADDR(ex));
 	current->mm->free_area_cache = TASK_UNMAPPED_BASE;

-	current->mm->rss = 0;
+	atomic_set(&current->mm->mm_rss. 0);
 	current->mm->mmap = NULL;
 	compute_creds(bprm);
  	current->flags &= ~PF_FORKNOEXEC;
Index: linux-2.6.9/arch/ppc64/mm/hugetlbpage.c
=================================--- linux-2.6.9.orig/arch/ppc64/mm/hugetlbpage.c	2004-11-29 12:18:07.000000000 -0800
+++ linux-2.6.9/arch/ppc64/mm/hugetlbpage.c	2004-11-29 14:06:20.000000000 -0800
@@ -153,7 +153,7 @@
 {
 	pte_t entry;

-	mm->rss += (HPAGE_SIZE / PAGE_SIZE);
+	atomic_add(HPAGE_SIZE / PAGE_SIZE, &mm->mm_rss);
 	if (write_access) {
 		entry  		    pte_mkwrite(pte_mkdirty(mk_pte(page, vma->vm_page_prot)));
@@ -311,7 +311,7 @@

 		ptepage = pte_page(entry);
 		get_page(ptepage);
-		dst->rss += (HPAGE_SIZE / PAGE_SIZE);
+		atomic_add(HPAGE_SIZE / PAGE_SIZE, &dst->mm_rss);
 		set_pte(dst_pte, entry);

 		addr += HPAGE_SIZE;
@@ -421,7 +421,7 @@

 		put_page(page);
 	}
-	mm->rss -= (end - start) >> PAGE_SHIFT;
+	atomic_sub((end - start) >> PAGE_SHIFT, &mm->mm_rss);
 	flush_tlb_pending();
 }

Index: linux-2.6.9/arch/sh64/mm/hugetlbpage.c
=================================--- linux-2.6.9.orig/arch/sh64/mm/hugetlbpage.c	2004-10-18 14:53:46.000000000 -0700
+++ linux-2.6.9/arch/sh64/mm/hugetlbpage.c	2004-11-29 14:06:20.000000000 -0800
@@ -62,7 +62,7 @@
 	unsigned long i;
 	pte_t entry;

-	mm->rss += (HPAGE_SIZE / PAGE_SIZE);
+	atomic_add(HPAGE_SIZE / PAGE_SIZE, &mm->mm_rss);

 	if (write_access)
 		entry = pte_mkwrite(pte_mkdirty(mk_pte(page,
@@ -115,7 +115,7 @@
 			pte_val(entry) += PAGE_SIZE;
 			dst_pte++;
 		}
-		dst->rss += (HPAGE_SIZE / PAGE_SIZE);
+		atomic_add(HPAGE_SIZE / PAGE_SIZE, &dst->mm_rss);
 		addr += HPAGE_SIZE;
 	}
 	return 0;
@@ -206,7 +206,7 @@
 			pte++;
 		}
 	}
-	mm->rss -= (end - start) >> PAGE_SHIFT;
+	atomic_sub((end - start) >> PAGE_SHIFT, &mm->mm_rss);
 	flush_tlb_range(vma, start, end);
 }

Index: linux-2.6.9/arch/sparc64/mm/hugetlbpage.c
=================================--- linux-2.6.9.orig/arch/sparc64/mm/hugetlbpage.c	2004-10-18 14:54:38.000000000 -0700
+++ linux-2.6.9/arch/sparc64/mm/hugetlbpage.c	2004-11-29 14:06:20.000000000 -0800
@@ -59,7 +59,7 @@
 	unsigned long i;
 	pte_t entry;

-	mm->rss += (HPAGE_SIZE / PAGE_SIZE);
+	atomic_add(HPAGE_SIZE / PAGE_SIZE, &mm->mm_rss);

 	if (write_access)
 		entry = pte_mkwrite(pte_mkdirty(mk_pte(page,
@@ -112,7 +112,7 @@
 			pte_val(entry) += PAGE_SIZE;
 			dst_pte++;
 		}
-		dst->rss += (HPAGE_SIZE / PAGE_SIZE);
+		atomic_add(HPAGE_SIZE / PAGE_SIZE, &dst->mm_rss);
 		addr += HPAGE_SIZE;
 	}
 	return 0;
@@ -203,7 +203,7 @@
 			pte++;
 		}
 	}
-	mm->rss -= (end - start) >> PAGE_SHIFT;
+	atomic_sub((end - start) >> PAGE_SHIFT, &mm->mm_rss);
 	flush_tlb_range(vma, start, end);
 }

Index: linux-2.6.9/arch/mips/kernel/irixelf.c
=================================--- linux-2.6.9.orig/arch/mips/kernel/irixelf.c	2004-11-29 12:18:07.000000000 -0800
+++ linux-2.6.9/arch/mips/kernel/irixelf.c	2004-11-29 14:06:20.000000000 -0800
@@ -686,7 +686,7 @@
 	/* Do this so that we can load the interpreter, if need be.  We will
 	 * change some of these later.
 	 */
-	current->mm->rss = 0;
+	atomic_set(&current->mm->mm_rss, 0);
 	setup_arg_pages(bprm, EXSTACK_DEFAULT);
 	current->mm->start_stack = bprm->p;

Index: linux-2.6.9/arch/m68k/atari/stram.c
=================================--- linux-2.6.9.orig/arch/m68k/atari/stram.c	2004-10-18 14:54:54.000000000 -0700
+++ linux-2.6.9/arch/m68k/atari/stram.c	2004-11-29 14:06:20.000000000 -0800
@@ -635,7 +635,7 @@
 	set_pte(dir, pte_mkdirty(mk_pte(page, vma->vm_page_prot)));
 	swap_free(entry);
 	get_page(page);
-	++vma->vm_mm->rss;
+	atomic_inc(&vma->vm_mm->mm_rss);
 }

 static inline void unswap_pmd(struct vm_area_struct * vma, pmd_t *dir,
Index: linux-2.6.9/arch/i386/mm/hugetlbpage.c
=================================--- linux-2.6.9.orig/arch/i386/mm/hugetlbpage.c	2004-11-29 12:18:07.000000000 -0800
+++ linux-2.6.9/arch/i386/mm/hugetlbpage.c	2004-11-29 14:06:20.000000000 -0800
@@ -42,7 +42,7 @@
 {
 	pte_t entry;

-	mm->rss += (HPAGE_SIZE / PAGE_SIZE);
+	atomic_add(HPAGE_SIZE / PAGE_SIZE, &mm->mm_rss);
 	if (write_access) {
 		entry  		    pte_mkwrite(pte_mkdirty(mk_pte(page, vma->vm_page_prot)));
@@ -82,7 +82,7 @@
 		ptepage = pte_page(entry);
 		get_page(ptepage);
 		set_pte(dst_pte, entry);
-		dst->rss += (HPAGE_SIZE / PAGE_SIZE);
+		atomic_add(HPAGE_SIZE / PAGE_SIZE, &dst->mm_rss);
 		addr += HPAGE_SIZE;
 	}
 	return 0;
@@ -218,7 +218,7 @@
 		page = pte_page(pte);
 		put_page(page);
 	}
-	mm->rss -= (end - start) >> PAGE_SHIFT;
+	atomic_sub((end - start) >> PAGE_SHIFT, &mm->mm_rss);
 	flush_tlb_range(vma, start, end);
 }

Index: linux-2.6.9/arch/sparc64/kernel/binfmt_aout32.c
=================================--- linux-2.6.9.orig/arch/sparc64/kernel/binfmt_aout32.c	2004-11-29 12:18:08.000000000 -0800
+++ linux-2.6.9/arch/sparc64/kernel/binfmt_aout32.c	2004-11-29 14:06:20.000000000 -0800
@@ -239,7 +239,7 @@
 	current->mm->brk = ex.a_bss +
 		(current->mm->start_brk = N_BSSADDR(ex));

-	current->mm->rss = 0;
+	atomic_set(&current->mm->mm_rss, 0);
 	current->mm->mmap = NULL;
 	compute_creds(bprm);
  	current->flags &= ~PF_FORKNOEXEC;
Index: linux-2.6.9/fs/proc/array.c
=================================--- linux-2.6.9.orig/fs/proc/array.c	2004-11-29 12:18:10.000000000 -0800
+++ linux-2.6.9/fs/proc/array.c	2004-11-29 14:06:20.000000000 -0800
@@ -420,7 +420,7 @@
 		jiffies_to_clock_t(task->it_real_value),
 		start_time,
 		vsize,
-		mm ? mm->rss : 0, /* you might want to shift this left 3 */
+		mm ? (unsigned long)atomic_read(&mm->mm_rss) : 0, /* you might want to shift this left 3 */
 	        rsslim,
 		mm ? mm->start_code : 0,
 		mm ? mm->end_code : 0,
