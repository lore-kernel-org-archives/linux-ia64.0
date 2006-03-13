From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Mon, 13 Mar 2006 22:53:42 +0000
Subject: RE: accessed/dirty bit handler tuning
Message-Id: <200603132253.k2DMrfg26844@unix-os.sc.intel.com>
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
> ...
> - not testing the result of "cmpxchg" (we'll re-read the PTE and
>   compare it anyway)


It occurs on me that you can do even more: you don't even need the
2nd load, move itc opportunistically before cmpxchg, then use data
returned from cmpxchg and compare it to the first read.

Oh, well, I suppose Tony has enough versions to jog around ;-)

- Ken


--- ./arch/ia64/kernel/ivt.S.orig	2006-03-13 15:39:36.745990157 -0800
+++ ./arch/ia64/kernel/ivt.S	2006-03-13 15:43:56.757705722 -0800
@@ -563,23 +563,12 @@ ENTRY(dirty_bit)
 	or r25=_PAGE_D|_PAGE_A,r18		// set the dirty and accessed bits
 	tbit.z p7,p6 = r18,_PAGE_P_BIT		// Check present bit
 	;;
+(p6)	itc.d r25				// install updated PTE
 (p6)	cmpxchg8.acq r26=[r17],r25,ar.ccv	// Only update if page is present
 	mov r24=PAGE_SHIFT<<2
 	;;
 (p6)	cmp.eq p6,p7=r26,r18			// Only compare if page is present
 	;;
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
 (p7)	ptc.l r16,r24
 	mov b0=r29				// restore b0
 	mov ar.ccv=r28

