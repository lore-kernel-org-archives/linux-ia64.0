From: "Pat O'Rourke" <orourke@mclinux.com>
Date: Wed, 27 Sep 2000 20:27:25 +0000
Subject: [Linux-ia64] [PATCH] ivt.S
Message-Id: <marc-linux-ia64-105590678205523@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

There are two parts to this patch:

1) First, in the VHPT miss handler I added a 'cmp.eq.andcm p10,p11=r0,r0'
   to ensure that p10 and p11 are false.  Further on in the miss handler
   we load into either the ITC or DTC based on p10/p11 respectively, but
   it seems we may not always set p10/p11.  Granted that we will fault in
   these cases, but it seems prudent to make sure the predicates are in a
   known state and avoid putting arbitrary values in TC.

2) The ITLB and DTLB miss handlers would load r16 with the VA of PTE and
   r19 with the VA we missed on.  By switching the use of these registers,
   we can avoid a re-load of r16 in the case where the speculative load
   of the PTE fails.

Pat

-- 
Patrick O'Rourke
orourke@missioncriticallinux.com

--- xxxxx/linux/arch/ia64/kernel/ivt.S	Wed Sep 27 15:09:03 2000
+++ linux-test7/arch/ia64/kernel/ivt.S	Wed Sep 27 12:51:54 2000
@@ -115,6 +115,7 @@
 	mov r19=ar.k7				// get page table base address
 	shl r21=r16,3				// shift bit 60 into sign bit
 	shr.u r17=r16,61			// get the region number into r17
+	cmp.eq.andcm p10,p11=r0,r0		// guarantee p10,p11 are false
 	;;
 	cmp.eq p6,p7=5,r17			// is IFA pointing into to region 5?
 	shr.u r18=r16,PGDIR_SHIFT		// get bits 33-63 of the faulting address
@@ -196,32 +197,31 @@
 	 * The speculative access will fail if there is no TLB entry
 	 * for the L3 page table page we're trying to access.
 	 */
-	mov r16=cr.iha				// get virtual address of L3 PTE
-	mov r19=cr.ifa				// get virtual address
+	mov r19=cr.iha				// get virtual address of L3 PTE
+	mov r16=cr.ifa				// get virtual address
 	;;
-	ld8.s r17=[r16]				// try to read L3 PTE
+	ld8.s r17=[r19]				// try to read L3 PTE
 	mov r31=pr				// save predicates
 	;;
-	tnat.nz p6,p0=r16			// did read succeed?
+	tnat.nz p6,p0=r19			// did read succeed?
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
 
 	mov pr=r31,-1
 	rfi
-
-1:	mov r16=cr.ifa				// get address that caused the TLB miss
 	;;
-	rsm psr.dt				// use physical addressing for data
+
+1:	rsm psr.dt				// use physical addressing for data
 	mov r19=ar.k7				// get page table base address
 	shl r21=r16,3				// shift bit 60 into sign bit
 	shr.u r17=r16,61			// get the region number into r17
@@ -283,31 +283,30 @@
 	 * The speculative access will fail if there is no TLB entry
 	 * for the L3 page table page we're trying to access.
 	 */
-	mov r16=cr.iha				// get virtual address of L3 PTE
-	mov r19=cr.ifa				// get virtual address
+	mov r19=cr.iha				// get virtual address of L3 PTE
+	mov r16=cr.ifa				// get virtual address
 	;;
-	ld8.s r17=[r16]				// try to read L3 PTE
+	ld8.s r17=[r19]				// try to read L3 PTE
 	mov r31=pr				// save predicates
 	;;
-	tnat.nz p6,p0=r16			// did read succeed?
+	tnat.nz p6,p0=r19			// did read succeed?
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
-
-1:	mov r16=cr.ifa				// get address that caused the TLB miss
 	;;
-	rsm psr.dt				// use physical addressing for data
+	
+1:	rsm psr.dt				// use physical addressing for data
 	mov r19=ar.k7				// get page table base address
 	shl r21=r16,3				// shift bit 60 into sign bit
 	shr.u r17=r16,61			// get the region number into r17



