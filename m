From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 11 Nov 2005 00:58:01 +0000
Subject: RE: [Patch 1/1] 4-level page tables v4.
Message-Id: <200511110058.jAB0w1g22205@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051110161915.GA3630@lnx-holt.americas.sgi.com>
In-Reply-To: <20051110161915.GA3630@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote on Thursday, November 10, 2005 3:03 PM
> If the new code runs just as fast as the old, the only
> possible remaining sticking point would be maintainability
> of the code ... assembly code does not lend itself well
> to the games we play in C code to keep the #ifdefs under
> control.  You've added six new #ifdefs to the fifteen
> already in ivt.S ... it was already hard to read (which
> is why I resorted to compiling and diffing the dissassembly
> to see what really changed).

Perhaps, this patch for vhpt_miss handler is a bit easier for the tender
eyes out there (including mine :-p  btw, this patch has not yet been tested).

The 2nd #ifdef block can be converted to predicated code, though for
3-level page table, it will have 2 cycle penalty.  But that can be 
recuperated from better instruction scheduling with several bad dep/cmp,
shr/cmp pair. I can do another patch to clean up instruction scheduling.

- Ken


--- ivt.S.orig	2005-11-10 10:26:26.104472218 -0800
+++ ivt.S.ken	2005-11-10 16:47:42.577824794 -0800
@@ -140,12 +140,28 @@
 (p6)	dep r17=r18,r19,3,(PAGE_SHIFT-3)	// r17=PTA + IFA(33,42)*8
 (p7)	dep r17=r18,r17,3,(PAGE_SHIFT-6)	// r17=PTA + (((IFA(61,63) << 7) | IFA(33,39))*8)
 	cmp.eq p7,p6=0,r21			// unused address bits all zeroes?
+#ifdef CONFIG_PGTABLE_4
+	shr.u r18=r22,PUD_SHIFT
+	cmp.eq p9,p0=r0,r0
+#else
 	shr.u r18=r22,PMD_SHIFT			// shift L2 index into position
+	cmp.eq p0,p9=r0,r0
+#endif
 	;;
 	ld8 r17=[r17]				// fetch the L1 entry (may be 0)
 	;;
 (p7)	cmp.eq p6,p7=r17,r0			// was L1 entry NULL?
+#ifdef CONFIG_PGTABLE_4
+	dep r28=r18,r17,3,(PAGE_SHIFT-3)
+	;;
+(p7)	ld8 r29=[r28]
+	shr.u r18=r22,PMD_SHIFT
+	;;
+	dep r17=r18,r29,3,(PAGE_SHIFT-3)
+(p7)	cmp.eq.or.andcm p6,p7=r29,r0
+#else
 	dep r17=r18,r17,3,(PAGE_SHIFT-3)	// compute address of L2 page table entry
+#endif
 	;;
 (p7)	ld8 r20=[r17]				// fetch the L2 entry (may be 0)
 	shr.u r19=r22,PAGE_SHIFT		// shift L3 index into position
@@ -194,8 +210,11 @@
 	 */
 	ld8 r25=[r21]				// read L3 PTE again
 	ld8 r26=[r17]				// read L2 entry again
+(p9)	ld8 r18=[r28]
+	cmp.ne p6,p7=r0,r0
 	;;
-	cmp.ne p6,p7=r26,r20			// did L2 entry change
+	cmp.ne.or.andcm p6,p7=r26,r20
+(p9)	cmp.ne.or.andcm p6,p7=r18,r28
 	mov r27=PAGE_SHIFT<<2
 	;;
 (p6)	ptc.l r22,r27				// purge PTE page translation

