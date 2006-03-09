From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Thu, 09 Mar 2006 13:35:14 +0000
Subject: RE: Fix race in the accessed/dirty bit handlers
Message-Id: <44102F12.9090009@bull.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------080208020101080208020608"
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0603071901420.2463@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603071901420.2463@schroedinger.engr.sgi.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------080208020101080208020608
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=us-ascii; format=flowed

I have got a concern abut the synchronization.
(It is the same for the original code.)
The following sequence:

	itc.d r25             // install updated PTE
	;;
	ld8 r18=[r17]         // read PTE again
	;;
	cmp.eq p6,p7=r18,r25  // is it same as the newly installed

I think is not safe enough.
The ";;" orders dependencies like R-A-W only, not the relatively slow cache
& tlb coherency operations, like "itc".
This is why I think we need my (first) patch.

I can imagine the following scenario:

1. "itc.d r25" is issued.
    It is not globally performed (an external purge request would miss it).

2. "ld8 r18=[r17]" is executed - we read back the good value.
    (Even an L3 cache miss can be quickly prepared on multi core / threaded
    processors by a cache intervention.)

3. Someone tears down the same PTE: s/he clears it, then
4. s/he issues a global purge - we miss it, because our "itc.d r25" still
    has not been globally performed.

5. Finally "itc.d r25" is globally performed (e.g. it is in our DTLB1).

6. "cmp" compares a stale value in r18 and our freshly inserted translation
    has missed the purge.

This is an example for the dirty bit handler, the others are similar.

BTW cannot take we this good opportunity to make the code somewhat more readable?
(See my second patch.)

Thanks,

Zoltan Menyhart

--------------080208020101080208020608
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
 name="srlz.d.diff"
Content-Disposition: inline;
 filename="srlz.d.diff"

--- old/arch/ia64/kernel/ivt.S	2006-03-09 13:38:21.000000000 +0100
+++ new/arch/ia64/kernel/ivt.S	2006-03-09 13:50:48.000000000 +0100
@@ -571,11 +571,18 @@ ENTRY(dirty_bit)
 (p6)	itc.d r25				// install updated PTE
 	;;
 	/*
-	 * Tell the assemblers dependency-violation checker that the above "itc" instructions
-	 * cannot possibly affect the following loads:
+	 * Make sure that the "itc" has been performed before we re-read the PTE.
+	 * (No, we are not going to use the freshly inserted translation for the next "ld".)
+	 * We have to make sure the freshly inserted translation can be hit by an external
+	 * purge request before we initiate the PTE re-fetch.
+	 * A simple ";;" does not make sure that the purges / invalidations go all the way
+	 * down (in case of page size of 64 K, up to 16 DTL0 entries may be purged and all
+	 * the L1D cache lines brought in via these translations need to be invalidated).
+	 */
+	srlz.d
+	/*
+	 * No need for ";;", the following "ld" can be in the same group as "srlz.d" is.
 	 */
-	dv_serialize_data
-
 	ld8 r18=[r17]				// read PTE again
 	;;
 	cmp.eq p6,p7=r18,r25			// is it same as the newly installed

--------------080208020101080208020608
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
 name="spaces.diff"
Content-Disposition: inline;
 filename="spaces.diff"

--- old/arch/ia64/kernel/ivt.S	2006-03-09 13:50:48.000000000 +0100
+++ new/arch/ia64/kernel/ivt.S	2006-03-09 13:54:37.000000000 +0100
@@ -548,27 +548,27 @@ ENTRY(dirty_bit)
 	 * page table TLB entry isn't present, we take a nested TLB miss hit where we look
 	 * up the physical address of the L3 PTE and then continue at label 1 below.
 	 */
-	mov r16=cr.ifa				// get the address that caused the fault
-	movl r30=1f				// load continuation point in case of nested fault
+	mov	r16 = cr.ifa			// get the address that caused the fault
+	movl	r30 = 1f			// load continuation point in case of nested fault
 	;;
-	thash r17=r16				// compute virtual address of L3 PTE
-	mov r29=b0				// save b0 in case of nested fault
-	mov r31=pr				// save pr
+	thash	r17 = r16			// compute virtual address of L3 PTE
+	mov	r29 = b0			// save b0 in case of nested fault
+	mov	r31 = pr			// save pr
 #ifdef CONFIG_SMP
-	mov r28=ar.ccv				// save ar.ccv
+	mov	r28 = ar.ccv			// save ar.ccv
 	;;
-1:	ld8 r18=[r17]
+1:	ld8	r18 = [r17]
 	;;					// avoid RAW on r18
-	mov ar.ccv=r18				// set compare value for cmpxchg
-	or r25=_PAGE_D|_PAGE_A,r18		// set the dirty and accessed bits
-	tbit.z p7,p6 = r18,_PAGE_P_BIT		// Check present bit
+	mov	ar.ccv = r18			// set compare value for cmpxchg
+	or	r25 = _PAGE_D|_PAGE_A,r18	// set the dirty and accessed bits
+	tbit.z	p7, p6  =  r18, _PAGE_P_BIT	// Check present bit
 	;;
-(p6)	cmpxchg8.acq r26=[r17],r25,ar.ccv	// Only update if page is present
-	mov r24=PAGE_SHIFT<<2
+(p6)	cmpxchg8.acq r26 = [r17], r25, ar.ccv	// Only update if page is present
+	mov	r24 = PAGE_SHIFT << 2
 	;;
-(p6)	cmp.eq p6,p7=r26,r18			// Only compare if page is present
+(p6)	cmp.eq	p6, p7 = r26, r18		// Only compare if page is present
 	;;
-(p6)	itc.d r25				// install updated PTE
+(p6)	itc.d	r25				// install updated PTE
 	;;
 	/*
 	 * Make sure that the "itc" has been performed before we re-read the PTE.
@@ -583,24 +583,24 @@ ENTRY(dirty_bit)
 	/*
 	 * No need for ";;", the following "ld" can be in the same group as "srlz.d" is.
 	 */
-	ld8 r18=[r17]				// read PTE again
+	ld8	r18 = [r17]			// read PTE again
 	;;
-	cmp.eq p6,p7=r18,r25			// is it same as the newly installed
+	cmp.eq	p6, p7 = r18, r25		// is it same as the newly installed
 	;;
-(p7)	ptc.l r16,r24
-	mov b0=r29				// restore b0
-	mov ar.ccv=r28
+(p7)	ptc.l	r16, r24
+	mov	b0 = r29			// restore b0
+	mov	ar.ccv = r28
 #else
 	;;
-1:	ld8 r18=[r17]
+1:	ld8	r18 = [r17]
 	;;					// avoid RAW on r18
-	or r18=_PAGE_D|_PAGE_A,r18		// set the dirty and accessed bits
-	mov b0=r29				// restore b0
+	or	r18 = _PAGE_D | _PAGE_A,r18	// set the dirty and accessed bits
+	mov	b0 = r29			// restore b0
 	;;
-	st8 [r17]=r18				// store back updated PTE
-	itc.d r18				// install updated PTE
+	st8	[r17] = r18			// store back updated PTE
+	itc.d	r18				// install updated PTE
 #endif
-	mov pr=r31,-1				// restore pr
+	mov	pr = r31, -1			// restore pr
 	rfi
 END(dirty_bit)
 

--------------080208020101080208020608--
