From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Mon, 13 Mar 2006 14:08:49 +0000
Subject: accessed/dirty bit handler tuning
Message-Id: <44157CF1.5060902@bull.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------030108010701070602040706"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------030108010701070602040706
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=us-ascii; format=flowed

I think we can do some accessed/dirty bit handler tuning. E.g.
in my patch (based on the Christoph's one entitled "Fix race in the
accessed/dirty bit handlers"), I think we gain a bit by:

- using the "nta" hint in order not to "pollute" the caches L1D / L3

- using the "bias" hint in order to obtain the "E" cache state at the
  beginning (the additional snoop bus cycle for the "S" => "E" state
  transition is eliminated)

- not testing the result of "cmpxchg" (we'll re-read the PTE and
  compare it anyway)
 
Thanks,

Zoltan


--------------030108010701070602040706
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
 name="srlz.d.diff2"
Content-Disposition: inline;
 filename="srlz.d.diff2"

--- old/arch/ia64/kernel/ivt.S	2006-03-09 16:56:18.000000000 +0100
+++ new/arch/ia64/kernel/ivt.S	2006-03-13 14:34:40.000000000 +0100
@@ -557,29 +557,59 @@ ENTRY(dirty_bit)
 #ifdef CONFIG_SMP
 	mov r28=ar.ccv				// save ar.ccv
 	;;
-1:	ld8 r18=[r17]
+	/*
+	 * The atomic instructions are handled exclusively by the L2 (L2D) cache.
+	 * "bias" is a hint to acquire exclusive ownership.
+	 * "nta": allocate the cache line only in L2 and to bias it to be replaced.
+	 */
+1:	ld8.bias.nta r18 = [r17]
 	;;					// avoid RAW on r18
 	mov ar.ccv=r18				// set compare value for cmpxchg
 	or r25=_PAGE_D|_PAGE_A,r18		// set the dirty and accessed bits
 	tbit.z p7,p6 = r18,_PAGE_P_BIT		// Check present bit
-	;;
-(p6)	cmpxchg8.acq r26=[r17],r25,ar.ccv	// Only update if page is present
-	mov r24=PAGE_SHIFT<<2
-	;;
-(p6)	cmp.eq p6,p7=r26,r18			// Only compare if page is present
-	;;
-(p6)	itc.d r25				// install updated PTE
+	mov r24 = PAGE_SHIFT << 2
 	;;
 	/*
-	 * Tell the assemblers dependency-violation checker that the above "itc" instructions
-	 * cannot possibly affect the following loads:
+	 * "nta" is a hint not to allocate the cache line elsewhere than in L2,
+	 * to bias it to be replaced and not to write it back into L3.
+	 *
+	 * We do not care for the result of "cmpxchg". It only makes sure we do not
+	 * overwrite a PTE that has been modified by someone else in the mean time.
+	 * We'll read back the in memory PTE later.
 	 */
-	dv_serialize_data
-
-	ld8 r18=[r17]				// read PTE again
+(p6)	cmpxchg8.acq.nta r26 = [r17],r25,ar.ccv	// Only update if page is present
+	/*
+	 * We load the new translation independently of the success of "cmpxchg". 
+	 * Should "cmpxchg" have failed, we'll purge the new translation later.
+	 */
+(p6)	itc.d r25				// Install updated PTE if page is present
+	;;					// "itc" must be the last in the group
+	/*
+	 * We make sure the visibility of "itc" to generated purges (like "ptc.ga")
+	 * before we re-read the PTE.
+	 * (No, we are not going to use the freshly inserted translation for the next
+	 * "ld".)
+	 * A simple ";;" does not make sure that the purges / invalidations go all the
+	 * way down. E.g. in case of page size of 64 K, up to 16 L1 DTLB entries may be
+	 * purged and all the L1D cache lines brought in via these translations need to
+	 * be invalidated.
+	 */
+(p6)	srlz.d
+	/*
+	 * No need for ";;", the following "ld" can be in the same group as "srlz.d" is.
+	 */
+(p6)	ld8.nta r18 = [r17]			// Read PTE again
 	;;
-	cmp.eq p6,p7=r18,r25			// is it same as the newly installed
+(p6)	cmp.eq p0, p7 = r18, r25		// Is it same as we wanted to install?
 	;;
+	/*
+	 * The new translation (or the old one if "p6" is off) gets purged if:
+	 * - the page is not present
+	 * - the in memory PTE is not what we wanted to write out because:
+	 *   + someone else has modified it after our successful "cmpxchg"
+	 *   + "cmpxchg" has failed (with the exception when someone else has set the
+	 *     very same dirty bit as we wanted to => our new translation is correct)
+	 */
 (p7)	ptc.l r16,r24
 	mov b0=r29				// restore b0
 	mov ar.ccv=r28

--------------030108010701070602040706--
