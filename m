From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 17 Jun 2005 23:38:47 +0000
Subject: [patch] fix nested_dtlb_miss handler for hugetlb address
Message-Id: <200506172338.j5HNclg25440@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The nested_dtlb_miss handler currently does not handle fault from
hugetlb address correctly.  It walks the page table assuming PAGE_SIZE.
Thus when taking a fault triggered from hugetlb address, it would not
calculate the pgd/pmd/pte address correctly and thus result an incorrect
invocation of ia64_do_page_fault().  In there, kernel will signal SIGBUS
and application dies (The faulting address is perfectly legal and we
have a valid pte for the corresponding user hugetlb address as well).
This patch fix the described kernel bug.  Since nested_dtlb_miss is a
rare event and a slow path anyway, I'm making the change without #ifdef
CONFIG_HUGETLB_PAGE for code readability.  Tony, please apply.


Signed-off-By: Ken Chen <kenneth.w.chen@intel.com>

--- linux-2.6.11/arch/ia64/kernel/ivt.S.orig	2005-06-11 00:37:14.121294932 -0700
+++ linux-2.6.11/arch/ia64/kernel/ivt.S	2005-06-11 04:50:14.153335539 -0700
@@ -405,17 +405,22 @@ ENTRY(nested_dtlb_miss)
 	 *		r30:	continuation address
 	 *		r31:	saved pr
 	 *
-	 * Clobbered:	b0, r18, r19, r21, psr.dt (cleared)
+	 * Clobbered:	b0, r18, r19, r21, r22, psr.dt (cleared)
 	 */
 	rsm psr.dt				// switch to using physical data addressing
 	mov r19=IA64_KR(PT_BASE)		// get the page table base address
 	shl r21=r16,3				// shift bit 60 into sign bit
+	mov r18=cr.itir
 	;;
 	shr.u r17=r16,61			// get the region number into r17
+	extr.u r18=r18,2,6			// get the faulting page size
 	;;
 	cmp.eq p6,p7=5,r17			// is faulting address in region 5?
-	shr.u r18=r16,PGDIR_SHIFT		// get bits 33-63 of faulting address
+	add r22=-PAGE_SHIFT,r18			// adjustment for hugetlb address
+	add r18=PGDIR_SHIFT-PAGE_SHIFT,r18
 	;;
+	shr.u r22=r16,r22
+	shr.u r18=r16,r18
 (p7)	dep r17=r17,r19,(PAGE_SHIFT-3),3	// put region number bits in place
 
 	srlz.d
@@ -428,7 +433,7 @@ ENTRY(nested_dtlb_miss)
 (p6)	dep r17=r18,r19,3,(PAGE_SHIFT-3)	// r17=PTA + IFA(33,42)*8
 (p7)	dep r17=r18,r17,3,(PAGE_SHIFT-6)	// r17=PTA + (((IFA(61,63) << 7) | IFA(33,39))*8)
 	cmp.eq p7,p6=0,r21			// unused address bits all zeroes?
-	shr.u r18=r16,PMD_SHIFT			// shift L2 index into position
+	shr.u r18=r22,PMD_SHIFT			// shift L2 index into position
 	;;
 	ld8 r17=[r17]				// fetch the L1 entry (may be 0)
 	;;
@@ -436,7 +441,7 @@ ENTRY(nested_dtlb_miss)
 	dep r17=r18,r17,3,(PAGE_SHIFT-3)	// compute address of L2 page table entry
 	;;
 (p7)	ld8 r17=[r17]				// fetch the L2 entry (may be 0)
-	shr.u r19=r16,PAGE_SHIFT		// shift L3 index into position
+	shr.u r19=r22,PAGE_SHIFT		// shift L3 index into position
 	;;
 (p7)	cmp.eq.or.andcm p6,p7=r17,r0		// was L2 entry NULL?
 	dep r17=r19,r17,3,(PAGE_SHIFT-3)	// compute address of L3 page table entry

