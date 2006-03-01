From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 01 Mar 2006 15:54:32 +0000
Subject: [patch] optimize vhpt_miss handler
Message-Id: <200603011554.k21FsVg29309@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here is a patch that optimizes vhpt_miss handler. Main changes are:
(1) reschedule long latency instructions
(2) avoid using extr/dep/tbit in the same instruction group as these
    instructions have limited asymmetric dispersal capability.

The patch looked a bit big because some of the changes require longer
lived register life and therefore I need to shuffle other registers
in order to make room for them. Others are primarily convert most of
shift in immediate form to other type of instructions. Sadly, McKinley
core can only disperse one extr/dep/tbit per cycle.  shr r1=r2,imm is
another insn that is a pseudo-op of extr and has limited dispersal
capability.

There are also example of suboptimal insn being used in the current code:

	shl r21=r16,3				// shift bit 60 into sign bit
	shr.u r17=r16,61			// get the region number into r17
	;;
	shr.u r22=r21,3

What the heck? Shift left by 3 bit first, then shift right by 3 bit?
That can be done with a single extr.u instruction.

So how does the patch measure?  Here are the performance numbers. To
keep things simple, I'm using a micro-benchmark that repeatly access
a contiguous address that stride 32MB.  All virtual addresses are
mapped into one single physical page so I can avoid any cache effect.
The numbers are in terms of CPU cycle of vhpt_miss handler latency:

Execution(cycle)	orig	w/ patch
----------------	----  --------
base (3L pgtable)	72	66
base + HTLB		72	66
base + HTLB + 4L	79	73


code size(byte)	orig	w/ patch
---------------	----  --------
base (3L pgtable)	368	336
base + HTLB		416	384
base + HTLB + 4L	464	432


Net gain is 6 cycles in all configurations.  Code size wise, reduced
2 bundles in all cases.  6 cycle reduction would probably show up as
noise just about in any real benchmark or workload out in the wild.
Nevertheless, posted here for mainline consideration.  If it doesn't
make into the mainline, at least it will serve as a documentary that
someone has attempted to optimize.

As usual, your criticism of any kind are appreciated.


Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>


--- ./arch/ia64/kernel/ivt.S.orig	2006-03-01 01:51:54.108908700 -0800
+++ ./arch/ia64/kernel/ivt.S	2006-03-01 01:58:13.642107176 -0800
@@ -104,50 +104,52 @@ ENTRY(vhpt_miss)
 	 *	- the faulting virtual address has no valid page table mapping
 	 */
 	mov r16=cr.ifa				// get address that caused the TLB miss
-#ifdef CONFIG_HUGETLB_PAGE
-	movl r18=PAGE_SHIFT
-	mov r25=cr.itir
-#endif
-	;;
 	rsm psr.dt				// use physical addressing for data
 	mov r31=pr				// save the predicate registers
 	mov r19=IA64_KR(PT_BASE)		// get page table base address
-	shl r21=r16,3				// shift bit 60 into sign bit
-	shr.u r17=r16,61			// get the region number into r17
-	;;
-	shr.u r22=r21,3
 #ifdef CONFIG_HUGETLB_PAGE
+	mov r25=cr.itir
+	mov r18=PAGE_SHIFT
+	;;
 	extr.u r26=r25,2,6
+	nop 0
 	;;
 	cmp.ne p8,p0=r18,r26
+	extr.u r22=r16,0,61			// r22=region_offset(ifa)
+	shr.u r17=r16,61			// get the region number into r17
+	mov r23=PGDIR_SHIFT+PAGE_SHIFT-3
+	mov r24=PGDIR_SHIFT+PAGE_SHIFT-6
 	sub r27=r26,r18
 	;;
 (p8)	dep r25=r18,r25,2,6
 (p8)	shr r22=r22,r27
+#else
+	;;
+	mov r23=PGDIR_SHIFT+PAGE_SHIFT-3
+	mov r24=PGDIR_SHIFT+PAGE_SHIFT-6
+	shr.u r17=r16,61			// get the region number into r17
+	extr.u r22=r16,0,61			// r22=region_offset(ifa)
 #endif
 	;;
 	cmp.eq p6,p7=5,r17			// is IFA pointing into to region 5?
+	dep r27=r17,r19,(PAGE_SHIFT-3),3	// put region number bits in place
 	shr.u r18=r22,PGDIR_SHIFT		// get bottom portion of pgd index bit
+	LOAD_PHYSICAL(p0, r28, swapper_pg_dir)	// region 5 is rooted at swapper_pg_dir
 	;;
-(p7)	dep r17=r17,r19,(PAGE_SHIFT-3),3	// put region number bits in place
-
-	srlz.d
-	LOAD_PHYSICAL(p6, r19, swapper_pg_dir)	// region 5 is rooted at swapper_pg_dir
-
-	.pred.rel "mutex", p6, p7
-(p6)	shr.u r21=r21,PGDIR_SHIFT+PAGE_SHIFT
-(p7)	shr.u r21=r21,PGDIR_SHIFT+PAGE_SHIFT-3
+(p6)	shr.u r21=r22,r23
+(p7)	shr.u r21=r22,r24
+(p6)	shladd r17=r18,3,r28			// r17=pgd_offset for region 5
+(p7)	shladd r17=r18,3,r27			// r17=pgd_offset for region[0-4]
 	;;
-(p6)	dep r17=r18,r19,3,(PAGE_SHIFT-3)	// r17=pgd_offset for region 5
-(p7)	dep r17=r18,r17,3,(PAGE_SHIFT-6)	// r17=pgd_offset for region[0-4]
-	cmp.eq p7,p6=0,r21			// unused address bits all zeroes?
+	srlz.d
 #ifdef CONFIG_PGTABLE_4
 	shr.u r28=r22,PUD_SHIFT			// shift pud index into position
 #else
 	shr.u r18=r22,PMD_SHIFT			// shift pmd index into position
 #endif
+	cmp.eq p7,p6=0,r21			// unused address bits all zeroes?
 	;;
-	ld8 r17=[r17]				// get *pgd (may be 0)
+(p7)	ld8 r17=[r17]				// get *pgd (may be 0)
 	;;
 (p7)	cmp.eq p6,p7=r17,r0			// was pgd_present(*pgd) = NULL?
 #ifdef CONFIG_PGTABLE_4
@@ -163,6 +165,7 @@ ENTRY(vhpt_miss)
 #endif
 	;;
 (p7)	ld8 r20=[r17]				// get *pmd (may be 0)
+	mov r27=cr.iha				// get the VHPT address of ifa
 	shr.u r19=r22,PAGE_SHIFT		// shift pte index into position
 	;;
 (p7)	cmp.eq.or.andcm p6,p7=r20,r0		// was pmd_present(*pmd) = NULL?
@@ -170,17 +173,16 @@ ENTRY(vhpt_miss)
 	;;
 (p7)	ld8 r18=[r21]				// read *pte
 	mov r19=cr.isr				// cr.isr bit 32 tells us if this is an insn miss
+	dep r23=0,r20,0,PAGE_SHIFT		// clear low bits to get page address
 	;;
 (p7)	tbit.z p6,p7=r18,_PAGE_P_BIT		// page present bit cleared?
-	mov r22=cr.iha				// get the VHPT address that caused the TLB miss
 	;;					// avoid RAW on p7
 (p7)	tbit.nz.unc p10,p11=r19,32		// is it an instruction TLB miss?
-	dep r23=0,r20,0,PAGE_SHIFT		// clear low bits to get page address
 	;;
 (p10)	itc.i r18				// insert the instruction TLB entry
 (p11)	itc.d r18				// insert the data TLB entry
 (p6)	br.cond.spnt.many page_fault		// handle bad address/page not present (page fault)
-	mov cr.ifa=r22
+	mov cr.ifa=r27
 
 #ifdef CONFIG_HUGETLB_PAGE
 (p8)	mov cr.itir=r25				// change to default page-size for VHPT
@@ -226,12 +228,12 @@ ENTRY(vhpt_miss)
 #ifdef CONFIG_PGTABLE_4
 	cmp.ne.or.andcm p6,p7=r19,r29		// did *pud change
 #endif
-	mov r27=PAGE_SHIFT<<2
+	mov r22=PAGE_SHIFT<<2
 	;;
-(p6)	ptc.l r22,r27				// purge PTE page translation
+(p6)	ptc.l r27,r22				// purge PTE page translation
 (p7)	cmp.ne.or.andcm p6,p7=r25,r18		// did *pte change
 	;;
-(p6)	ptc.l r16,r27				// purge translation
+(p6)	ptc.l r16,r22				// purge translation
 #endif
 
 	mov pr=r31,-1				// restore predicate registers


