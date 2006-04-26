From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Wed, 26 Apr 2006 13:46:50 +0000
Subject: Read *pgd again in vhpt_miss handler
Message-Id: <444F79CA.7060804@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I think the *pgd has to be re-read and compared as *pmd, ... are.
("free_pud_range()" includes "pgd_clear(pgd)".)

Thanks,

Zoltan


--- linux-2.6.16.9-save/arch/ia64/kernel/ivt.S	2006-04-21 09:58:55.000000000 +0200
+++ linux-2.6.16.9/arch/ia64/kernel/ivt.S	2006-04-26 15:15:17.000000000 +0200
@@ -138,8 +138,8 @@ ENTRY(vhpt_miss)
 (p6)	shr.u r21=r21,PGDIR_SHIFT+PAGE_SHIFT
 (p7)	shr.u r21=r21,PGDIR_SHIFT+PAGE_SHIFT-3
 	;;
-(p6)	dep r17=r18,r19,3,(PAGE_SHIFT-3)	// r17=pgd_offset for region 5
-(p7)	dep r17=r18,r17,3,(PAGE_SHIFT-6)	// r17=pgd_offset for region[0-4]
+(p6)	dep r27=r18,r19,3,(PAGE_SHIFT-3)	// r27=pgd_offset for region 5
+(p7)	dep r27=r18,r17,3,(PAGE_SHIFT-6)	// r27=pgd_offset for region[0-4]
 	cmp.eq p7,p6=0,r21			// unused address bits all zeroes?
 #ifdef CONFIG_PGTABLE_4
 	shr.u r28=r22,PUD_SHIFT			// shift pud index into position
@@ -147,11 +147,11 @@ ENTRY(vhpt_miss)
 	shr.u r18=r22,PMD_SHIFT			// shift pmd index into position
 #endif
 	;;
-	ld8 r17=[r17]				// get *pgd (may be 0)
+	ld8 r30=[r27]				// get *pgd (may be 0)
 	;;
-(p7)	cmp.eq p6,p7=r17,r0			// was pgd_present(*pgd) = NULL?
+(p7)	cmp.eq p6,p7=r30,r0			// was pgd_present(*pgd) = NULL?
 #ifdef CONFIG_PGTABLE_4
-	dep r28=r28,r17,3,(PAGE_SHIFT-3)	// r28=pud_offset(pgd,addr)
+	dep r28=r28,r30,3,(PAGE_SHIFT-3)	// r28=pud_offset(pgd,addr)
 	;;
 	shr.u r18=r22,PMD_SHIFT			// shift pmd index into position
 (p7)	ld8 r29=[r28]				// get *pud (may be 0)
@@ -159,7 +159,7 @@ ENTRY(vhpt_miss)
 (p7)	cmp.eq.or.andcm p6,p7=r29,r0		// was pud_present(*pud) = NULL?
 	dep r17=r18,r29,3,(PAGE_SHIFT-3)	// r17=pmd_offset(pud,addr)
 #else
-	dep r17=r18,r17,3,(PAGE_SHIFT-3)	// r17=pmd_offset(pgd,addr)
+	dep r17=r18,r30,3,(PAGE_SHIFT-3)	// r17=pmd_offset(pgd,addr)
 #endif
 	;;
 (p7)	ld8 r20=[r17]				// get *pmd (may be 0)
@@ -207,10 +207,12 @@ ENTRY(vhpt_miss)
 	 * between reading the pagetable and the "itc".  If so, flush the entry we
 	 * inserted and retry.  At this point, we have:
 	 *
+	 * r27 = equivalent of pgd_offset(mm, ifa) or pgd_offset_k(ifa)
 	 * r28 = equivalent of pud_offset(pgd, ifa)
 	 * r17 = equivalent of pmd_offset(pud, ifa)
 	 * r21 = equivalent of pte_offset(pmd, ifa)
 	 *
+	 * r30 = *pgd
 	 * r29 = *pud
 	 * r20 = *pmd
 	 * r18 = *pte
@@ -220,7 +222,9 @@ ENTRY(vhpt_miss)
 #ifdef CONFIG_PGTABLE_4
 	ld8 r19=[r28]				// read *pud again
 #endif
-	cmp.ne p6,p7=r0,r0
+	ld8 r24=[r27]				// read *pgd again
+	;;
+	cmp.ne p6,p7=r24,r30			// did *pgd change
 	;;
 	cmp.ne.or.andcm p6,p7=r26,r20		// did *pmd change
 #ifdef CONFIG_PGTABLE_4

