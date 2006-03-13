From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Mon, 13 Mar 2006 19:46:06 +0000
Subject: RE: accessed/dirty bit handler tuning
Message-Id: <200603131946.k2DJk5g24918@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <44157CF1.5060902@bull.net>
In-Reply-To: <44157CF1.5060902@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Zoltan Menyhart wrote on Monday, March 13, 2006 6:09 AM
> I think we can do some accessed/dirty bit handler tuning. E.g.
> in my patch (based on the Christoph's one entitled "Fix race in the
> accessed/dirty bit handlers"), I think we gain a bit by:
> 
> - using the "nta" hint in order not to "pollute" the caches L1D / L3
> 
> - using the "bias" hint in order to obtain the "E" cache state at the
>   beginning (the additional snoop bus cycle for the "S" => "E" state
>   transition is eliminated)
> 
> - not testing the result of "cmpxchg" (we'll re-read the PTE and
>   compare it anyway)


Hmm, I think another alternative is to rip out all the itc insertion
code and let the hardware page walker do the "dirty" job.  Because it
is known and architected to be atomic-read-and-insert and is also
known to honor ptc.g while atomic-read-and-insert is in-flight (i.e.,
won't insert tlb entry).

- Ken


 ivt.S |   19 ++-----------------
 1 files changed, 2 insertions(+), 17 deletions(-)

--- ./arch/ia64/kernel/ivt.S.orig	2006-03-13 12:40:25.245145301 -0800
+++ ./arch/ia64/kernel/ivt.S	2006-03-13 12:41:53.923855152 -0800
@@ -558,29 +558,14 @@ ENTRY(dirty_bit)
 	mov r28=ar.ccv				// save ar.ccv
 	;;
 1:	ld8 r18=[r17]
+	mov r24=PAGE_SHIFT<<2
 	;;					// avoid RAW on r18
 	mov ar.ccv=r18				// set compare value for cmpxchg
 	or r25=_PAGE_D|_PAGE_A,r18		// set the dirty and accessed bits
 	tbit.z p7,p6 = r18,_PAGE_P_BIT		// Check present bit
 	;;
 (p6)	cmpxchg8.acq r26=[r17],r25,ar.ccv	// Only update if page is present
-	mov r24=PAGE_SHIFT<<2
-	;;
-(p6)	cmp.eq p6,p7=r26,r18			// Only compare if page is present
-	;;
-(p6)	itc.d r25				// install updated PTE
-	;;
-	/*
-	 * Tell the assemblers dependency-violation checker that the above "itc" instructions
-	 * cannot possibly affect the following loads:
-	 */
-	dv_serialize_data
-
-	ld8 r18=[r17]				// read PTE again
-	;;
-	cmp.eq p6,p7=r18,r25			// is it same as the newly installed
-	;;
-(p7)	ptc.l r16,r24
+	ptc.l r16,r24
 	mov b0=r29				// restore b0
 	mov ar.ccv=r28
 #else

