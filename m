From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Fri, 21 Apr 2006 14:12:43 +0000
Subject: Protect PGD...PTE walking in ivt.S
Message-Id: <4448E85B.5080906@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The "rx = ... -> pgd[i] -> pud[j] -> pmd[k] -> pte[l]" chain has to be
protected against "free_pgtables()".

"free_pgtables()" is protected by "mmap_sem" taken for write, therefore
taking this semaphore for read in the low level assembly routines will
provide us with enough protection:
- it can be taken for read almost all the time
- it scales well
- the performance is not degraded (see below)

I prepared a patch for the VHPT miss handler only. Later
I can add the rest. Here is how it goes:

0. Only the user region faults are protected.
   (You should not try to remove an in-use 0xa000... mapping.)

1. "activate_mm()" remembers the physical address of the "mmap_sem" of
   the task selected to run in "ar.k2" (IA64_KR_MM_SEM).

2. On entry, "vhpt_miss" takes "mmap_sem" for read:

	while (unlikely(__down_read_trylock(&current->mm->mmap_sem) = 0));

3. If there is no valid PTE => go to "page_fault_sem" (see later).

4. On one hand, as "free_pgtables()" cannot run in the mean time,
   there is no need to re-read pgd[i] -> pud[j] -> pmd[k].
   On the other hand, the swapper is not excluded => we keep re-checking
   pte[l] and purging the freshly inserted TLB entry if it has been changed.

5. Releasing "mmap_sem" is a bit tricky:

	__up_read(&current->mm->mmap_sem);

   On the fast path, we can "rfi".

6. If someone is waiting for "mmap_sem", then we have to switch the
   translation on, to establish the "C" environment and to call
   "rwsem_wake()".

7. "page_fault_sem": if we have "mmap_sem", then it is more efficient
   not to release it, because "ia64_do_page_fault()" would take it.
   Therefore a new argument, called "mmap_sem_taken_for_read", is added.
   (This flag is DONT-CARE for the faults from the region 5.)

Non-regression test:

I wrote a "wicked" test that provokes VHPT misses, while all the
loads / stores hit the caches L1D / L2.

In order to maximize the number of the TLB entries needed for the
virtually mapped PTE pages, only one valid PTE / page will be used
(, and a single byte per data page).

8 times more TLB entries will be solicited than what is really available:
512 data pages + 512 PTE pages => systematic VHPT misses.

The innermost loop is as follows:

1:  st1 [r15]=r16        // DTLB miss, then L2 hit
    adds r16=1,r16
    ld4 r24=[r18] ;;     // L1D cache hit
    add r15=r15,r24
    br.cloop.sptk.few 1b

The original linux-2.6.16.9 with the missing "srlz.d" added into the
VHPT miss handler:

ITC ticks: 615,846,302, # user accesses: 5,120,000, ITC ticks / access: 120
ITC ticks: 593,729,267, # user accesses: 5,120,000, ITC ticks / access: 115
ITC ticks: 558,319,090, # user accesses: 5,120,000, ITC ticks / access: 109
ITC ticks: 596,911,467, # user accesses: 5,120,000, ITC ticks / access: 116
ITC ticks: 558,342,475, # user accesses: 5,120,000, ITC ticks / access: 109
ITC ticks: 602,162,489, # user accesses: 5,120,000, ITC ticks / access: 117
ITC ticks: 558,207,935, # user accesses: 5,120,000, ITC ticks / access: 109
ITC ticks: 612,523,245, # user accesses: 5,120,000, ITC ticks / access: 119
ITC ticks: 615,927,942, # user accesses: 5,120,000, ITC ticks / access: 120
ITC ticks: 595,530,914, # user accesses: 5,120,000, ITC ticks / access: 116

I.e. it takes 109 ... 120 ITC ticks to execute the innermost loop above +
the fast path of the VHPT miss handler on a Tiger like machine with CPUs
like:

processor  : 2
vendor     : GenuineIntel
arch       : IA-64
family     : Itanium 2
model      : 2
revision   : 1
archrev    : 0
features   : branchlong
cpu number : 0
cpu regs   : 4
cpu MHz    : 1700.000554
itc MHz    : 1700.554956
BogoMIPS   : 2547.71
siblings   : 1

With my patch:

ITC ticks: 768,590,910, # user accesses: 5,120,000, ITC ticks / access: 150
ITC ticks: 727,652,674, # user accesses: 5,120,000, ITC ticks / access: 142
ITC ticks: 743,272,209, # user accesses: 5,120,000, ITC ticks / access: 145
ITC ticks: 747,918,306, # user accesses: 5,120,000, ITC ticks / access: 146
ITC ticks: 743,176,995, # user accesses: 5,120,000, ITC ticks / access: 145
ITC ticks: 728,062,632, # user accesses: 5,120,000, ITC ticks / access: 142
ITC ticks: 745,091,227, # user accesses: 5,120,000, ITC ticks / access: 145
ITC ticks: 733,728,213, # user accesses: 5,120,000, ITC ticks / access: 143
ITC ticks: 747,965,619, # user accesses: 5,120,000, ITC ticks / access: 146
ITC ticks: 728,251,497, # user accesses: 5,120,000, ITC ticks / access: 142

I have 142 ... 150 ITC ticks.

Notes:
- a simple memory access on this test machine costs 340 ITC ticks
   (and usually we do some memory accesses :-))
- not all the loads / stores provoke TLB misses when executing an
   average program
- not all the TLB misses provoke VHPT misses

A real life application will not suffer from any performance degradation.

Thanks,

Zoltan


--- linux-2.6.16.9/arch/ia64/mm/fault.c	2006-04-19 08:10:14.000000000 +0200
+++ new/arch/ia64/mm/fault.c	2006-04-21 11:21:47.000000000 +0200
@@ -51,8 +51,16 @@ mapped_kernel_page_is_present (unsigned 
 	return pte_present(pte);
 }
 
+/*
+ * The low level handlers take "current->mm->mmap_sem" for read if user region
+ * (0 ... 4) fault has happened, see "mmap_sem_taken_for_read".
+ * This flag is DONT-CARE for the faults from the region 5.
+ * "current->mm->mmap_sem" is never taken by the low level handlers for the
+ * faults from the region 5.
+ */
 void __kprobes
-ia64_do_page_fault (unsigned long address, unsigned long isr, struct pt_regs *regs)
+ia64_do_page_fault (unsigned long address, unsigned long isr, struct pt_regs *regs,
+							int mmap_sem_taken_for_read)
 {
 	int signal = SIGSEGV, code = SEGV_MAPERR;
 	struct vm_area_struct *vma, *prev_vma;
@@ -60,10 +68,16 @@ ia64_do_page_fault (unsigned long addres
 	struct siginfo si;
 	unsigned long mask;
 
+	if (mmap_sem_taken_for_read && (REGION_NUMBER(address) < 5)){
+		BUG_ON(__pa(&current->mm->mmap_sem) != ia64_get_kr(IA64_KR_MM_SEM));
+		BUG_ON((current->mm->mmap_sem.count & RWSEM_ACTIVE_MASK) = 0);
+	}
 	/*
 	 * If we're in an interrupt or have no user context, we must not take the fault..
 	 */
-	if (in_atomic() || !mm)
+	if (in_atomic())
+		goto no_context_sem;
+	if (!mm)
 		goto no_context;
 
 #ifdef CONFIG_VIRTUAL_MEM_MAP
@@ -82,10 +96,14 @@ ia64_do_page_fault (unsigned long addres
 	 * This is to handle the kprobes on user space access instructions
 	 */
 	if (notify_die(DIE_PAGE_FAULT, "page fault", regs, code, TRAP_BRKPT,
-					SIGSEGV) = NOTIFY_STOP)
+					SIGSEGV) = NOTIFY_STOP){
+		if (mmap_sem_taken_for_read && (REGION_NUMBER(address) < 5))
+			up_read(&mm->mmap_sem);
 		return;
+	}
 
-	down_read(&mm->mmap_sem);
+	if (!mmap_sem_taken_for_read || (REGION_NUMBER(address) = 5))
+		down_read(&mm->mmap_sem);
 
 	vma = find_vma_prev(mm, address, &prev_vma);
 	if (!vma)
@@ -197,6 +215,9 @@ ia64_do_page_fault (unsigned long addres
 		return;
 	}
 
+  no_context_sem:
+  	if (mmap_sem_taken_for_read && (REGION_NUMBER(address) < 5))
+		up_read(&mm->mmap_sem);
   no_context:
 	if ((isr & IA64_ISR_SP)
 	    || ((isr & IA64_ISR_NA) && (isr & IA64_ISR_CODE_MASK) = IA64_ISR_CODE_LFETCH))
@@ -251,3 +272,12 @@ ia64_do_page_fault (unsigned long addres
 		do_exit(SIGKILL);
 	goto no_context;
 }
+
+
+void my_rwsem_wake(struct rw_semaphore *sem)
+{
+	printk("\nmy_rwsem_wake(%p) %p %p\n", sem, current, &current->mm);
+	BUG_ON(&current->mm->mmap_sem != sem);
+	rwsem_wake(sem);
+}
+
--- linux-2.6.16.9/arch/ia64/kernel/ivt.S	2006-04-19 08:10:14.000000000 +0200
+++ new/arch/ia64/kernel/ivt.S	2006-04-20 17:52:58.000000000 +0200
@@ -80,6 +80,10 @@
 
 	.align 32768	// align on 32KB boundary
 	.global ia64_ivt
+
+#define	pUsr		p17			// User regions
+#define	pR5		p16			// Region 5 fault
+
 ia64_ivt:
 /////////////////////////////////////////////////////////////////////////////////////////
 // 0x0000 Entry 0 (size 64 bundles) VHPT Translation (8,20,47)
@@ -112,10 +116,13 @@ ENTRY(vhpt_miss)
 	rsm psr.dt				// use physical addressing for data
 	mov r31=pr				// save the predicate registers
 	mov r19=IA64_KR(PT_BASE)		// get page table base address
-	shl r21=r16,3				// shift bit 60 into sign bit
+#ifdef CONFIG_SMP
+	mov r30 = IA64_KR(MM_SEM)			// &current->mm->mmap_sem
+#endif
+	shl r20=r16,3				// shift bit 60 into sign bit
 	shr.u r17=r16,61			// get the region number into r17
 	;;
-	shr.u r22=r21,3
+	shr.u r22=r20,3
 #ifdef CONFIG_HUGETLB_PAGE
 	extr.u r26=r25,2,6
 	;;
@@ -126,20 +133,47 @@ ENTRY(vhpt_miss)
 (p8)	shr r22=r22,r27
 #endif
 	;;
-	cmp.eq p6,p7=5,r17			// is IFA pointing into to region 5?
+	cmp.eq pR5,pUsr=5,r17			// is IFA pointing into to region 5?
 	shr.u r18=r22,PGDIR_SHIFT		// get bottom portion of pgd index bit
 	;;
-(p7)	dep r17=r17,r19,(PAGE_SHIFT-3),3	// put region number bits in place
+(pUsr)	dep r17=r17,r19,(PAGE_SHIFT-3),3	// put region number bits in place
 
 	srlz.d
-	LOAD_PHYSICAL(p6, r19, swapper_pg_dir)	// region 5 is rooted at swapper_pg_dir
+	LOAD_PHYSICAL(pR5, r19, swapper_pg_dir)	// region 5 is rooted at swapper_pg_dir
 
-	.pred.rel "mutex", p6, p7
-(p6)	shr.u r21=r21,PGDIR_SHIFT+PAGE_SHIFT
-(p7)	shr.u r21=r21,PGDIR_SHIFT+PAGE_SHIFT-3
+#ifdef CONFIG_SMP
+1:	/*
+	 * If (pUsr: user region fault){
+	 *	__s64 r27, r28, *r30 = &current->mm->mmap_sem;
+	 *
+	 *	//
+	 *	// while (unlikely(__down_read_trylock(&current->mm->mmap_sem) = 0));
+	 *	//
+	 * 	do {
+	 *		while (unlikely((r27 = ia64_ld8_bias_nta(&r30->count)) < 0));
+	 *		r28 = r27 + 1;
+	 *	} while (unlikely(ia64_cmpxchg8_acq_nta(&r30->count, r28, r27) != r27));
+	 * }
+	 */
+(pUsr)	ld8.bias.nta r27 = [r30]
 	;;
-(p6)	dep r17=r18,r19,3,(PAGE_SHIFT-3)	// r17=pgd_offset for region 5
-(p7)	dep r17=r18,r17,3,(PAGE_SHIFT-6)	// r17=pgd_offset for region[0-4]
+(pUsr)	cmp.lt.unc p8, p0 = r27, r0
+(p8)	br.cond.spnt.few 1b
+(pUsr)	mov.m ar.ccv = r27
+(pUsr)	adds r28 = 1, r27
+	;;
+(pUsr)	cmpxchg8.acq.nta r28 = [r30], r28, ar.ccv
+	;;
+(pUsr)	cmp.eq.unc p0, p8 = r28, r27
+(p8)	br.cond.spnt.few 1b
+#endif	// CONFIG_SMP
+
+	.pred.rel "mutex", pR5, pUsr
+(pR5)	shr.u r21=r20,PGDIR_SHIFT+PAGE_SHIFT
+(pUsr)	shr.u r21=r20,PGDIR_SHIFT+PAGE_SHIFT-3
+	;;
+(pR5)	dep r17=r18,r19,3,(PAGE_SHIFT-3)	// r17=pgd_offset for region 5
+(pUsr)	dep r17=r18,r17,3,(PAGE_SHIFT-6)	// r17=pgd_offset for region[0-4]
 	cmp.eq p7,p6=0,r21			// unused address bits all zeroes?
 #ifdef CONFIG_PGTABLE_4
 	shr.u r28=r22,PUD_SHIFT			// shift pud index into position
@@ -179,7 +213,7 @@ ENTRY(vhpt_miss)
 	;;
 (p10)	itc.i r18				// insert the instruction TLB entry
 (p11)	itc.d r18				// insert the data TLB entry
-(p6)	br.cond.spnt.many page_fault		// handle bad address/page not present (page fault)
+(p6)	br.cond.spnt.many page_fault_sem	// handle bad address/page not present (page fault)
 	mov cr.ifa=r22
 
 #ifdef CONFIG_HUGETLB_PAGE
@@ -197,11 +231,12 @@ ENTRY(vhpt_miss)
 	;;
 #ifdef CONFIG_SMP
 	/*
-	 * Tell the assemblers dependency-violation checker that the above "itc" instructions
-	 * cannot possibly affect the following loads:
+	 * We make sure the visibility of itc.* to generated purges (like ptc.ga)
+	 * before we re-read the PTE.
+	 * Having itc.i-d a new translation, there is no need for srlz.i, the rfi below
+	 * will do the serialization.
 	 */
-	dv_serialize_data
-
+(p7)	srlz.d
 	/*
 	 * Re-check pagetable entry.  If they changed, we may have received a ptc.g
 	 * between reading the pagetable and the "itc".  If so, flush the entry we
@@ -214,25 +249,45 @@ ENTRY(vhpt_miss)
 	 * r29 = *pud
 	 * r20 = *pmd
 	 * r18 = *pte
+	 *
+	 * There is no need to re-read *pgd, *pud, *pmd because of having "mmap_sem".
+	 * The PTE page translation is guaranteed to be correct.
+	 * The swapper does not take this semaphore for write => do re-check *pte.
 	 */
 	ld8 r25=[r21]				// read *pte again
-	ld8 r26=[r17]				// read *pmd again
-#ifdef CONFIG_PGTABLE_4
-	ld8 r19=[r28]				// read *pud again
-#endif
-	cmp.ne p6,p7=r0,r0
-	;;
-	cmp.ne.or.andcm p6,p7=r26,r20		// did *pmd change
-#ifdef CONFIG_PGTABLE_4
-	cmp.ne.or.andcm p6,p7=r19,r29		// did *pud change
-#endif
 	mov r27=PAGE_SHIFT<<2
 	;;
-(p6)	ptc.l r22,r27				// purge PTE page translation
-(p7)	cmp.ne.or.andcm p6,p7=r25,r18		// did *pte change
+	cmp.ne p6,p0=r25,r18			// did *pte change?
 	;;
 (p6)	ptc.l r16,r27				// purge translation
-#endif
+	/*
+	 * Tell the assemblers dependency-violation checker that the above "ptc" instruction
+	 * cannot possibly affect the following loads/stores.
+	 */
+	dv_serialize_data
+
+1:	/*
+	 * If (pUsr: user region fault){
+	 *	__s64 r27, r28, *r30 = &current->mm->mmap_sem;
+	 *
+	 *	//
+	 *	// __up_read(&current->mm->mmap_sem);
+	 *	//
+	 * 	r28 = ia64_fetchadd8_rel_nta(&r30->count, -1);
+	 *	r27 = r28 - 1;
+	 * 	if (unlikely(r28 < 0))
+	 *		if (unlikely((r27 & RWSEM_ACTIVE_MASK) = 0))
+	 *			rwsem_wake(sem);
+	 * }
+	 */
+(pUsr)	fetchadd8.rel.nta r28 = [r30], -1
+	;;
+(pUsr)	adds r27 = -1, r28
+(pUsr)	cmp.lt.unc p8, p0 = r28, r0
+(p8)	br.cond.spnt.few call_sem_wake_up
+	;;
+back_to_vhpt_miss:				// No need to call "rwsem_wake()"
+#endif	// CONFIG_SMP
 
 	mov pr=r31,-1				// restore predicate registers
 	rfi
@@ -282,6 +337,60 @@ ENTRY(itlb_miss)
 	rfi
 END(itlb_miss)
 
+
+#ifdef CONFIG_SMP
+	/*
+	 * Arrivig from "vhpt_miss":
+	 *
+	 * ...
+	 * If (pUsr: user mode fault){
+	 *	__s64 r27, r28, *r30 = &current->mm->mmap_sem;
+	 *
+	 *	//
+	 *	// __up_read(&current->mm->mmap_sem);
+	 *	//
+	 * 	r28 = ia64_fetchadd8_rel_nta(&r30->count, -1);
+	 *	r27 = r28 - 1;
+	 * 	if (unlikely(r28 < 0))
+	 *
+	 *		//
+	 *		// *** We are here: ***
+	 *		//
+	 *		if (unlikely((r27 & RWSEM_ACTIVE_MASK) = 0))
+	 *			rwsem_wake(sem);
+	 * }
+	 * ...
+	 */
+call_sem_wake_up:
+	cmp4.eq p0, p8 = 0, r27
+(p8)	br.cond.sptk.few back_to_vhpt_miss
+	;;
+	/*
+	 * Call "my_rwsem_wake(IA64_KR(MM_SEM))". Ppredicates are in r31, psr.dt is off.
+	 */
+	ssm psr.dt
+	;;
+	srlz.d
+	;;
+	SAVE_MIN_WITH_COVER
+	alloc r15 = ar.pfs, 0, 0, 1, 0
+	mov out0 = IA64_KR(MM_SEM)		// &current->mm->mmap_sem
+	adds r3=8, r2				// set up second base pointer
+	;;
+	ssm psr.ic | PSR_DEFAULT_BITS
+	;;
+	srlz.i					// guarantee that interruption collectin is on
+	;;
+(p15)	ssm psr.i				// restore psr.i
+	movl r14 = ia64_leave_kernel
+	;;
+	SAVE_REST
+	mov rp = r14
+	;;
+	br.call.sptk.many b6 = my_rwsem_wake	// ignore return address
+#endif	// CONFIG_SMP
+
+
 	.org ia64_ivt+0x0800
 /////////////////////////////////////////////////////////////////////////////////////////
 // 0x0800 Entry 2 (size 64 bundles) DTLB (9,48)
@@ -326,6 +434,21 @@ dtlb_fault:
 	rfi
 END(dtlb_miss)
 
+
+	//-----------------------------------------------------------------------------------
+	// call do_page_fault (predicates are in r31, psr.dt may be off, r16 is faulting address)
+	// We DON'T have "mmap_sem" for read
+ENTRY(page_fault)
+	ssm psr.dt
+	;;
+	srlz.i
+	;;
+	SAVE_MIN_WITH_COVER
+	mov r15 = r0				// We DON'T have "mmap_sem" for read
+	br.sptk.few page_fault_common
+END(page_fault)
+
+
 	.org ia64_ivt+0x0c00
 /////////////////////////////////////////////////////////////////////////////////////////
 // 0x0c00 Entry 3 (size 64 bundles) Alt ITLB (19)
@@ -499,32 +622,39 @@ ENTRY(ikey_miss)
 	FAULT(6)
 END(ikey_miss)
 
+
 	//-----------------------------------------------------------------------------------
 	// call do_page_fault (predicates are in r31, psr.dt may be off, r16 is faulting address)
-ENTRY(page_fault)
+	// If user region fault has happened => we keep "mmap_sem" for read
+ENTRY(page_fault_sem)
 	ssm psr.dt
 	;;
 	srlz.i
 	;;
 	SAVE_MIN_WITH_COVER
-	alloc r15=ar.pfs,0,0,3,0
-	mov out0=cr.ifa
-	mov out1=cr.isr
-	adds r3=8,r2				// set up second base pointer
+	add r15 = 1, r0				// If user region fault has happened =>
+						//	We have "mmap_sem" for read
+page_fault_common:
+	alloc r14 = ar.pfs, 0, 0, 4, 0
+	mov out0 = cr.ifa
+	mov out1 = cr.isr
+	adds r3 = 8, r2				// set up second base pointer
 	;;
 	ssm psr.ic | PSR_DEFAULT_BITS
 	;;
 	srlz.i					// guarantee that interruption collectin is on
 	;;
 (p15)	ssm psr.i				// restore psr.i
-	movl r14=ia64_leave_kernel
+	movl r14 = ia64_leave_kernel
 	;;
 	SAVE_REST
-	mov rp=r14
+	mov rp = r14
 	;;
-	adds out2,r12			// out2 = pointer to pt_regs
+	adds out2 = 16, r12			// out2 = pointer to pt_regs
+	mov out3 = r15				// Is "mmap_sem" taken for read?
 	br.call.sptk.many b6=ia64_do_page_fault	// ignore return address
-END(page_fault)
+END(page_fault_sem)
+
 
 	.org ia64_ivt+0x1c00
 /////////////////////////////////////////////////////////////////////////////////////////
--- linux-2.6.16.9/include/asm-ia64/kregs.h	2006-04-20 10:36:46.000000000 +0200
+++ new/include/asm-ia64/kregs.h	2006-04-20 14:53:14.000000000 +0200
@@ -14,6 +14,7 @@
  */
 #define IA64_KR_IO_BASE		0	/* ar.k0: legacy I/O base address */
 #define IA64_KR_TSSD		1	/* ar.k1: IVE uses this as the TSSD */
+#define	IA64_KR_MM_SEM		2	/* ar.k2: ->mmap_sem address (physical) */
 #define IA64_KR_PER_CPU_DATA	3	/* ar.k3: physical per-CPU base */
 #define IA64_KR_CURRENT_STACK	4	/* ar.k4: what's mapped in IA64_TR_CURRENT_STACK */
 #define IA64_KR_FPU_OWNER	5	/* ar.k5: fpu-owner (UP only, at the moment) */
--- linux-2.6.16.9/include/asm-ia64/mmu_context.h	2006-04-20 10:36:46.000000000 +0200
+++ new/include/asm-ia64/mmu_context.h	2006-04-20 14:59:18.000000000 +0200
@@ -192,6 +192,7 @@ activate_mm (struct mm_struct *prev, str
 	 * handlers cannot touch user-space.
 	 */
 	ia64_set_kr(IA64_KR_PT_BASE, __pa(next->pgd));
+	ia64_set_kr(IA64_KR_MM_SEM, __pa(&next->mmap_sem));
 	activate_context(next);
 }
 
