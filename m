From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 29 Mar 2006 22:57:40 +0000
Subject: Re: accessed/dirty bit handler tuning
Message-Id: <200603292257.k2TMvewP011177@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <44157CF1.5060902@bull.net>
In-Reply-To: <44157CF1.5060902@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Ian,

Yes ... I think I goofed when mailing to Zoltan and the list ... the copy
never showed up on the list.  Here is the version of the patch:

-Tony

---

diff --git a/arch/ia64/kernel/ivt.S b/arch/ia64/kernel/ivt.S
index 829a43c..86123c1 100644
--- a/arch/ia64/kernel/ivt.S
+++ b/arch/ia64/kernel/ivt.S
@@ -552,48 +552,56 @@ ENTRY(dirty_bit)
 	movl r30=1F				// load continuation point in case of nested fault
 	;;
 	thash r17=3Dr16				// compute virtual address of L3 PTE
+	mov r31=3Dpr
 	mov r29=B0				// save b0 in case of nested fault
-	mov r31=3Dpr				// save pr
 #ifdef CONFIG_SMP
 	mov r28=3Dar.ccv				// save ar.ccv
 	;;
-1:	ld8 r18=3D[r17]
-	;;					// avoid RAW on r18
+1:	ld8.bias.nta r18=3D[r17]
+	;;
 	mov ar.ccv=3Dr18				// set compare value for cmpxchg
 	or r25=3D_PAGE_D|_PAGE_A,r18		// set the dirty and accessed bits
 	tbit.z p7,p6 =3D r18,_PAGE_P_BIT		// Check present bit
 	;;
-(p6)	cmpxchg8.acq r26=3D[r17],r25,ar.ccv	// Only update if page is present
-	mov r24=3DPAGE_SHIFT<<2
-	;;
-(p6)	cmp.eq p6,p7=3Dr26,r18			// Only compare if page is present
-	;;
+	/*
+	 * We do not test for the result of "cmpxchg". It only makes sure we do n=
ot
+	 * overwrite a PTE that has been modified by someone else in the mean tim=
e.
+	 * We'll read back the in memory PTE later.
+	 */
+(p6)	cmpxchg8.acq.nta r26=3D[r17],r25,ar.ccv	// Only update if page is pre=
sent
 (p6)	itc.d r25				// install updated PTE
 	;;
 	/*
-	 * Tell the assemblers dependency-violation checker that the above "itc" =
instructions
-	 * cannot possibly affect the following loads:
+	 * We make sure itc.d completes before re-read the PTE.
 	 */
-	dv_serialize_data
-
-	ld8 r18=3D[r17]				// read PTE again
+(p6)	srlz.d
+(p6)	ld8.nta r18=3D[r17]				// Read PTE again
 	;;
-	cmp.eq p6,p7=3Dr18,r25			// is it same as the newly installed
+(p6)	cmp.eq p0,p7=3Dr18,r25			// Is it same as we wanted to install?
+	mov r24=3DPAGE_SHIFT << 2
 	;;
+	/*
+	 * The new translation (or the old one if "p6" is off) gets purged if:
+	 * - the page is not present
+	 * - the in memory PTE is not what we wanted to write out because:
+	 *   + someone else has modified it after our successful "cmpxchg"
+	 *   + "cmpxchg" has failed (with the exception when someone else has set=
 the
+	 *     very same dirty bit as we wanted to =3D> our new translation is co=
rrect)
+	 */
 (p7)	ptc.l r16,r24
 	mov b0=3Dr29				// restore b0
 	mov ar.ccv=3Dr28
 #else
 	;;
 1:	ld8 r18=3D[r17]
-	;;					// avoid RAW on r18
+	;;
 	or r18=3D_PAGE_D|_PAGE_A,r18		// set the dirty and accessed bits
 	mov b0=3Dr29				// restore b0
 	;;
 	st8 [r17]=3Dr18				// store back updated PTE
 	itc.d r18				// install updated PTE
 #endif
-	mov pr=3Dr31,-1				// restore pr
+	mov pr=3Dr31,-1
 	rfi
 END(dirty_bit)
=20
@@ -602,7 +610,10 @@ END(dirty_bit)
 // 0x2400 Entry 9 (size 64 bundles) Instruction Access-bit (27)
 ENTRY(iaccess_bit)
 	DBG_FAULT(9)
-	// Like Entry 8, except for instruction access
+	/*
+	 * Like Entry 8, except for instruction access.
+	 * For the remarks on cache hints and synchronization issues see there.
+	 */
 	mov r16=3Dcr.ifa				// get the address that caused the fault
 	movl r30=1F				// load continuation point in case of nested fault
 	mov r31=3Dpr				// save predicates
@@ -623,33 +634,25 @@ #endif /* CONFIG_ITANIUM */
 #ifdef CONFIG_SMP
 	mov r28=3Dar.ccv				// save ar.ccv
 	;;
-1:	ld8 r18=3D[r17]
+1:	ld8.bias.nta r18=3D[r17]
 	;;
 	mov ar.ccv=3Dr18				// set compare value for cmpxchg
 	or r25=3D_PAGE_A,r18			// set the accessed bit
-	tbit.z p7,p6 =3D r18,_PAGE_P_BIT	 	// Check present bit
+	tbit.z p7,p6=3Dr18,_PAGE_P_BIT		// Check present bit
 	;;
-(p6)	cmpxchg8.acq r26=3D[r17],r25,ar.ccv	// Only if page present
-	mov r24=3DPAGE_SHIFT<<2
+(p6)	cmpxchg8.acq.nta r26=3D[r17],r25,ar.ccv	// Only update if page is pre=
sent
+(p6)	itc.i r25				// Install updated PTE if page is present
 	;;
-(p6)	cmp.eq p6,p7=3Dr26,r18			// Only if page present
-	;;
-(p6)	itc.i r25				// install updated PTE
-	;;
-	/*
-	 * Tell the assemblers dependency-violation checker that the above "itc" =
instructions
-	 * cannot possibly affect the following loads:
-	 */
-	dv_serialize_data
-
-	ld8 r18=3D[r17]				// read PTE again
+(p6)	srlz.d
+(p6)	ld8.nta r18=3D[r17]				// Read PTE again
 	;;
-	cmp.eq p6,p7=3Dr18,r25			// is it same as the newly installed
+(p6)	cmp.eq p0,p7=3Dr18,r25			// Is it same as we wanted to install?
+	mov r24=3DPAGE_SHIFT << 2
 	;;
 (p7)	ptc.l r16,r24
 	mov b0=3Dr29				// restore b0
 	mov ar.ccv=3Dr28
-#else /* !CONFIG_SMP */
+#else
 	;;
 1:	ld8 r18=3D[r17]
 	;;
@@ -658,7 +661,7 @@ #else /* !CONFIG_SMP */
 	;;
 	st8 [r17]=3Dr18				// store back updated PTE
 	itc.i r18				// install updated PTE
-#endif /* !CONFIG_SMP */
+#endif
 	mov pr=3Dr31,-1
 	rfi
 END(iaccess_bit)
@@ -668,50 +671,47 @@ END(iaccess_bit)
 // 0x2800 Entry 10 (size 64 bundles) Data Access-bit (15,55)
 ENTRY(daccess_bit)
 	DBG_FAULT(10)
-	// Like Entry 8, except for data access
+	/*
+	 * Like Entry 8, except for data access.
+	 * For the remarks on cache hints and synchronization issues see there.
+	 */
 	mov r16=3Dcr.ifa				// get the address that caused the fault
 	movl r30=1F				// load continuation point in case of nested fault
 	;;
 	thash r17=3Dr16				// compute virtual address of L3 PTE
 	mov r31=3Dpr
-	mov r29=B0				// save b0 in case of nested fault)
+	mov r29=B0				// save b0 in case of nested fault
 #ifdef CONFIG_SMP
 	mov r28=3Dar.ccv				// save ar.ccv
-	;;
-1:	ld8 r18=3D[r17]
-	;;					// avoid RAW on r18
-	mov ar.ccv=3Dr18				// set compare value for cmpxchg
-	or r25=3D_PAGE_A,r18			// set the dirty bit
-	tbit.z p7,p6 =3D r18,_PAGE_P_BIT		// Check present bit
 	;;
-(p6)	cmpxchg8.acq r26=3D[r17],r25,ar.ccv	// Only if page is present
-	mov r24=3DPAGE_SHIFT<<2
+1:	ld8.bias.nta r18=3D[r17]
 	;;
-(p6)	cmp.eq p6,p7=3Dr26,r18			// Only if page is present
+	mov ar.ccv=3Dr18				// set compare value for cmpxchg
+	or r25=3D_PAGE_A,r18			// set the accessed bit
+	tbit.z p7,p6=3Dr18,_PAGE_P_BIT		// Check present bit
 	;;
-(p6)	itc.d r25				// install updated PTE
-	/*
-	 * Tell the assemblers dependency-violation checker that the above "itc" =
instructions
-	 * cannot possibly affect the following loads:
-	 */
-	dv_serialize_data
+(p6)	cmpxchg8.acq.nta r26=3D[r17],r25,ar.ccv	// Only update if page is pre=
sent
+(p6)	itc.d r25				// Install updated PTE if page is present
 	;;
-	ld8 r18=3D[r17]				// read PTE again
+(p6)	srlz.d
+(p6)	ld8.nta r18=3D[r17]				// Read PTE again
 	;;
-	cmp.eq p6,p7=3Dr18,r25			// is it same as the newly installed
+(p6)	cmp.eq p0,p7=3Dr18,r25			// Is it same as we wanted to install?
+	mov r24=3DPAGE_SHIFT << 2
 	;;
 (p7)	ptc.l r16,r24
+	mov b0=3Dr29				// restore b0
 	mov ar.ccv=3Dr28
 #else
 	;;
 1:	ld8 r18=3D[r17]
-	;;					// avoid RAW on r18
+	;;
 	or r18=3D_PAGE_A,r18			// set the accessed bit
+	mov b0=3Dr29				// restore b0
 	;;
 	st8 [r17]=3Dr18				// store back updated PTE
 	itc.d r18				// install updated PTE
 #endif
-	mov b0=3Dr29				// restore b0
 	mov pr=3Dr31,-1
 	rfi
 END(daccess_bit)
