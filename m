From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 27 Sep 2000 21:34:15 +0000
Subject: Re: [Linux-ia64] [PATCH] ivt.S
Message-Id: <marc-linux-ia64-105590678205524@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205523@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205523@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 27 Sep 2000 16:27:25 -0400, "Pat O'Rourke" <orourke@mclinux.com> said:

  Pat> There are two parts to this patch: 1) First, in the VHPT miss
  Pat> handler I added a 'cmp.eq.andcm p10,p11=r0,r0' to ensure that
  Pat> p10 and p11 are false.  Further on in the miss handler we load
  Pat> into either the ITC or DTC based on p10/p11 respectively, but
  Pat> it seems we may not always set p10/p11.  Granted that we will
  Pat> fault in these cases, but it seems prudent to make sure the
  Pat> predicates are in a known state and avoid putting arbitrary
  Pat> values in TC.

I don't see why that would be necessary.  Perhaps you misunderstood
how tbit.nc.unc works?

  Pat> 2) The ITLB and DTLB miss handlers would load r16 with the VA
  Pat> of PTE and r19 with the VA we missed on.  By switching the use
  Pat> of these registers, we can avoid a re-load of r16 in the case
  Pat> where the speculative load of the PTE fails.

Thanks for pointing that out.  Actually, looking at that code, I
noticed that the tnat was testing the wrong register.  Ouch.

Can you try the attached patch (it's relative to the original
version)?

Thanks,

	--david

--- arch/ia64/kernel/ivt.S~	Fri Sep 22 16:45:25 2000
+++ arch/ia64/kernel/ivt.S	Wed Sep 27 14:30:51 2000
@@ -196,35 +196,32 @@
 	 * The speculative access will fail if there is no TLB entry
 	 * for the L3 page table page we're trying to access.
 	 */
-	mov r16=cr.iha				// get virtual address of L3 PTE
-	mov r19=cr.ifa				// get virtual address
+	mov r16=cr.ifa				// get virtual address
+	mov r19=cr.iha				// get virtual address of L3 PTE
 	;;
-	ld8.s r17=[r16]				// try to read L3 PTE
+	ld8.s r17=[r19]				// try to read L3 PTE
 	mov r31=pr				// save predicates
 	;;
-	tnat.nz p6,p0=r16			// did read succeed?
+	tnat.nz p6,p0=r17			// did read succeed?
 (p6)	br.cond.spnt.many 1f
 	;;
 	itc.i r17
 	;;
 #ifdef CONFIG_SMP
-	ld8.s r18=[r16]				// try to read L3 PTE again and see if same
+	ld8.s r18=[r19]				// try to read L3 PTE again and see if same
 	mov r20=PAGE_SHIFT<<2			// setup page size for purge
 	;;
 	cmp.eq p6,p7=r17,r18
 	;;
-(p7)	ptc.l r19,r20	
+(p7)	ptc.l r16,r20
 #endif
-
 	mov pr=r31,-1
 	rfi
 
-1:	mov r16=cr.ifa				// get address that caused the TLB miss
-	;;
 #ifdef CONFIG_DISABLE_VHPT
 itlb_fault:
 #endif
-	rsm psr.dt				// use physical addressing for data
+1:	rsm psr.dt				// use physical addressing for data
 	mov r19=ar.k7				// get page table base address
 	shl r21=r16,3				// shift bit 60 into sign bit
 	shr.u r17=r16,61			// get the region number into r17
@@ -286,34 +283,32 @@
 	 * The speculative access will fail if there is no TLB entry
 	 * for the L3 page table page we're trying to access.
 	 */
-	mov r16=cr.iha				// get virtual address of L3 PTE
-	mov r19=cr.ifa				// get virtual address
+	mov r16=cr.ifa				// get virtual address
+	mov r19=cr.iha				// get virtual address of L3 PTE
 	;;
-	ld8.s r17=[r16]				// try to read L3 PTE
+	ld8.s r17=[r19]				// try to read L3 PTE
 	mov r31=pr				// save predicates
 	;;
-	tnat.nz p6,p0=r16			// did read succeed?
+	tnat.nz p6,p0=r17			// did read succeed?
 (p6)	br.cond.spnt.many 1f
 	;;
 	itc.d r17
 	;;
 #ifdef CONFIG_SMP
-	ld8.s r18=[r16]				// try to read L3 PTE again and see if same
+	ld8.s r18=[r19]				// try to read L3 PTE again and see if same
 	mov r20=PAGE_SHIFT<<2			// setup page size for purge
 	;;
 	cmp.eq p6,p7=r17,r18
 	;;
-(p7)	ptc.l r19,r20	
+(p7)	ptc.l r16,r20
 #endif
 	mov pr=r31,-1
 	rfi
 
-1:	mov r16=cr.ifa				// get address that caused the TLB miss
-	;;
 #ifdef CONFIG_DISABLE_VHPT
 dtlb_fault:
 #endif
-	rsm psr.dt				// use physical addressing for data
+1:	rsm psr.dt				// use physical addressing for data
 	mov r19=ar.k7				// get page table base address
 	shl r21=r16,3				// shift bit 60 into sign bit
 	shr.u r17=r16,61			// get the region number into r17

