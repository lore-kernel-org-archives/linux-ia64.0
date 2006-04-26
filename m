From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 26 Apr 2006 15:00:53 +0000
Subject: RE: Read *pgd again in vhpt_miss handler
Message-Id: <4t16i2$qn2l7@orsmga001.jf.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <444F79CA.7060804@bull.net>
In-Reply-To: <444F79CA.7060804@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Zoltan Menyhart wrote on Wednesday, April 26, 2006 6:47 AM
> I think the *pgd has to be re-read and compared as *pmd, ... are.
> ("free_pud_range()" includes "pgd_clear(pgd)".)

A more favorable change is to remove comparing pud/pmd entry, but
condition the vhpt TLB purging upon detecting pte modification.
I had this patch in my pocket for a while for other optimizations
I'm working on and it looks like a good timing to post it now.

Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>


--- ./arch/ia64/kernel/ivt.S.orig	2006-04-26 08:24:33.000000000 -0700
+++ ./arch/ia64/kernel/ivt.S	2006-04-26 08:31:43.000000000 -0700
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
 
