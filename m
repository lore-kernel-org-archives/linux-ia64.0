From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Wed, 25 Aug 2004 02:34:39 +0000
Subject: Long Format VHPT patches
Message-Id: <20040825023439.GA15782@cse.unsw.EDU.AU>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="IpbVkmxF4tDyP/Kb"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--IpbVkmxF4tDyP/Kb
Content-Type: multipart/mixed; boundary="QKdGvSO+nmPlgiQ/"
Content-Disposition: inline


--QKdGvSO+nmPlgiQ/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

Having support for the IA64 long format VHPT is becoming an increasing
foundation for ongoing work such as superpages and TLB sharing
schemes, so we would like to get the following patches into a
development tree to start getting feedback and facilitate these other
projects.  Our testing shows them to be reliable.

The first two patches abstract ivt.S a little, creating a new header
ivt.h

01-sf-VHPT-macro-def-ivt.h.patch
02-sf-VHPT-macro-calls-ivt.S.patch

The next series of patches add the guts of using the long format vhpt

03-VHPT-hugetlb-support.patch
04-lf-VHPT-macro-def-ivt.h.patch
05-lf-VHPT-macro-calls-ivt.S.patch

The final patches add the support code and are fairly self explanatory

06-lf-VHPT-declarations.patch =20
07-lf-VHPT-initialise.patch
08-lf-VHPT-tlb-flush-dec.patch=20
09-lf-VHPT-tlb-flush.patch
10-lf-VHPT-mmu_context-dec.patch
11-lf-VHPT-kconfig.patch

The idea and original patches were by Matthew Chapman, and stewardship
passed to Darren Williams who got them to this stage.

I've attached all the patches (against 2.6.9-rc1) to this email as
they're not that big, but if you actually want to try them out it's
might be easier for many to grab them from cvs as in the footnote.

While the kernel is building you might like to also read the following
relevant paper :)

Matthew Chapman, Ian Wienand, Gernot Heiser
Itanium Page Tables and TLB
Technical Report UNSW-CSE-TR-0307, May 2003.
ftp://ftp.cse.unsw.edu.au/pub/doc/papers/UNSW/0307.pdf

Thanks,

-i
ianw@gelato.unsw.edu.au
http://www.gelato.unsw.edu.au

--- A note on our patches in CVS ---

If you would like to try them out quickly, we would encourage you to
just grab the always latest versions from our CVS and use quilt to
apply them, i.e. in a fresh kernel directory do

cvs -d:pserver:anoncvs@gelato.unsw.edu.au:/gelato login
[anoncvs]
cvs -d:pserver:anoncvs@gelato.unsw.edu.au:/gelato co -d patches lvhpt

then use 'quilt push -a' to push all patches, build and run as usual.

--QKdGvSO+nmPlgiQ/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="01-sf-VHPT-macro-def-ivt.h.patch"
Content-Transfer-Encoding: quoted-printable

#
# This patch creates macros for common code that walks the 3 level page
# table found in ivt.S
#
diff -Nru a/include/asm-ia64/ivt.h b/include/asm-ia64/ivt.h
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/include/asm-ia64/ivt.h	2004-08-12 19:19:37 +10:00
@@ -0,0 +1,66 @@
+#ifndef _ASM_IA64_IVT_H
+#define _ASM_IA64_IVT_H
+/*
+ * Copyright (C) 2004 Gelato@UNSW
+ *	Matthew Chapman <matthewc@cse.unsw.edu.au>
+ *      Darren Williams <dsw@gelato.unsw.edu.au>
+ */
+=20
+#define temp    r24
+#define rgn     r25		/* region register                                */
+#define tir     r26		/* translation register                           */
+#define mbz     r27		/* "must be zero" else signifies non valid region */=
=20
+#define scratch r28
+
+/* va=3Dr16 ppte=3Dr19 fail=3Dp6 ok=3Dp7 */
+#define FIND_PTE(va, ppte, fail, ok)									\
+	rsm psr.dt;				/* switch to using physical data addressing */		\
+	mov ppte=3DIA64_KR(PT_BASE);		/* get the page table base address */			\
+	shl mbz=3Dva,3;				/* shift bit 60 into sign bit	*/			\
+	shr.u rgn=3Dva,61;			/* get the region number into 'rgn' */			\
+	;;												\
+	cmp.eq p6,p7=3D5,rgn;			/* is faulting address in region 5? */			\
+	shr.u temp=3Dva,PGDIR_SHIFT;		/* get bits 33-63 of faulting address */		\
+	;;												\
+(p7)	dep ppte=3Drgn,ppte,(PAGE_SHIFT-3),3;	/* put region number bits in pl=
ace */			\
+	srlz.d;												\
+	LOAD_PHYSICAL(p6, ppte, swapper_pg_dir);/* region 5 is rooted at swapper_=
pg_dir */		\
+													\
+	.pred.rel "mutex", p6, p7;									\
+(p6)	shr.u mbz=3Dmbz,PGDIR_SHIFT+PAGE_SHIFT;								\
+(p7)	shr.u mbz=3Dmbz,PGDIR_SHIFT+PAGE_SHIFT-3;								\
+	;;												\
+(p6)	dep ppte=3Dtemp,ppte,3,(PAGE_SHIFT-3);	/* ppte=3DPTA + IFA(33,42)*8 *=
/				\
+(p7)	dep ppte=3Dtemp,ppte,3,(PAGE_SHIFT-6);	/* ppte=3DPTA + (((IFA(61,63) =
<< 7) | IFA(33,39))*8) */	\
+	cmp.eq ok,fail=3D0,mbz;			/* unused address bits all zeroes? */			\
+	shr.u temp=3Dva,PMD_SHIFT;		/* shift L2 index into position	*/			\
+	;;												\
+	ld8 ppte=3D[ppte];			/* fetch the L1 entry (may be 0)*/			\
+	;;												\
+(ok)	cmp.eq fail,ok=3Dppte,r0;			/* was L1 entry NULL?*/					\
+	dep ppte=3Dtemp,ppte,3,(PAGE_SHIFT-3);	/* compute address of L2 page tabl=
e entry*/		\
+	;;												\
+(ok)	ld8 ppte=3D[ppte];			/* fetch the L2 entry (may be 0)*/			\
+	shr.u temp=3Dva,PAGE_SHIFT;		/* shift L3 index into position*/			\
+	;;												\
+(ok)	cmp.eq.or.andcm fail,ok=3Dppte,r0;	/* was L2 entry NULL?*/					\
+	dep ppte=3Dtemp,ppte,3,(PAGE_SHIFT-3);	/* compute address of L3 page tabl=
e entry*/
+
+#define LOAD_PTE_MISS(va, ppte, pte, hpte, failfn)						\
+	mov ppte=3Dcr.iha;			/* get virtual address of L3 PTE */		\
+	movl r30=3D1f;				/* load continuation point */			\
+	;;											\
+1:	ld8 pte=3D[ppte]; \
+	mov b0=3Dr29;				/* restore possibly destroyed b0 */		\
+	;;											\
+	tbit.z p6,p0=3Dpte,_PAGE_P_BIT;		/* page present bit cleared? */			\
+(p6)	br.cond.spnt failfn;
+
+#define LOAD_PTE_FAULT(va, ppte, pte, hpte, failfn)						\
+	thash ppte=3Dva;				/* get virtual address of L3 PTE */		\
+	movl r30=3D1f;				/* load continuation point */			\
+	;;											\
+1:	ld8 pte=3D[ppte];										\
+	mov b0=3Dr29;				/* restore possibly destroyed b0 */
+
+#endif /* _ASM_IA64_IVT_H */

--QKdGvSO+nmPlgiQ/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="02-sf-VHPT-macro-calls-ivt.S.patch"
Content-Transfer-Encoding: quoted-printable

# This patch abstracts code into ivt.h

diff -Nru a/arch/ia64/kernel/ivt.S b/arch/ia64/kernel/ivt.S
--- a/arch/ia64/kernel/ivt.S	2004-08-12 19:21:11 +10:00
+++ b/arch/ia64/kernel/ivt.S	2004-08-12 19:21:11 +10:00
@@ -40,6 +40,7 @@
=20
 #include <linux/config.h>
=20
+#include <asm/ivt.h>
 #include <asm/asmmacro.h>
 #include <asm/break.h>
 #include <asm/ia32.h>
@@ -223,14 +224,7 @@
 	mov r29=3Db0				// save b0
 	mov r31=3Dpr				// save predicates
 .itlb_fault:
-	mov r17=3Dcr.iha				// get virtual address of L3 PTE
-	movl r30=3D1f				// load nested fault continuation point
-	;;
-1:	ld8 r18=3D[r17]				// read L3 PTE
-	;;
-	mov b0=3Dr29
-	tbit.z p6,p0=3Dr18,_PAGE_P_BIT		// page present bit cleared?
-(p6)	br.cond.spnt page_fault
+	LOAD_PTE_MISS(r16,r17,r18,r22,page_fault) // find PTE and check present b=
it
 	;;
 	itc.i r18
 	;;
@@ -266,15 +260,8 @@
 	mov r16=3Dcr.ifa				// get virtual address
 	mov r29=3Db0				// save b0
 	mov r31=3Dpr				// save predicates
-dtlb_fault:
-	mov r17=3Dcr.iha				// get virtual address of L3 PTE
-	movl r30=3D1f				// load nested fault continuation point
-	;;
-1:	ld8 r18=3D[r17]				// read L3 PTE
-	;;
-	mov b0=3Dr29
-	tbit.z p6,p0=3Dr18,_PAGE_P_BIT		// page present bit cleared?
-(p6)	br.cond.spnt page_fault
+.dtlb_fault:
+	LOAD_PTE_MISS(r16,r17,r18,r22,page_fault) // find PTE and check present b=
it
 	;;
 	itc.d r18
 	;;
@@ -406,39 +393,7 @@
 	 *
 	 * Clobbered:	b0, r18, r19, r21, psr.dt (cleared)
 	 */
-	rsm psr.dt				// switch to using physical data addressing
-	mov r19=3DIA64_KR(PT_BASE)		// get the page table base address
-	shl r21=3Dr16,3				// shift bit 60 into sign bit
-	;;
-	shr.u r17=3Dr16,61			// get the region number into r17
-	;;
-	cmp.eq p6,p7=3D5,r17			// is faulting address in region 5?
-	shr.u r18=3Dr16,PGDIR_SHIFT		// get bits 33-63 of faulting address
-	;;
-(p7)	dep r17=3Dr17,r19,(PAGE_SHIFT-3),3	// put region number bits in place
-
-	srlz.d
-	LOAD_PHYSICAL(p6, r19, swapper_pg_dir)	// region 5 is rooted at swapper_p=
g_dir
-
-	.pred.rel "mutex", p6, p7
-(p6)	shr.u r21=3Dr21,PGDIR_SHIFT+PAGE_SHIFT
-(p7)	shr.u r21=3Dr21,PGDIR_SHIFT+PAGE_SHIFT-3
-	;;
-(p6)	dep r17=3Dr18,r19,3,(PAGE_SHIFT-3)	// r17=3DPTA + IFA(33,42)*8
-(p7)	dep r17=3Dr18,r17,3,(PAGE_SHIFT-6)	// r17=3DPTA + (((IFA(61,63) << 7)=
 | IFA(33,39))*8)
-	cmp.eq p7,p6=3D0,r21			// unused address bits all zeroes?
-	shr.u r18=3Dr16,PMD_SHIFT			// shift L2 index into position
-	;;
-	ld8 r17=3D[r17]				// fetch the L1 entry (may be 0)
-	;;
-(p7)	cmp.eq p6,p7=3Dr17,r0			// was L1 entry NULL?
-	dep r17=3Dr18,r17,3,(PAGE_SHIFT-3)	// compute address of L2 page table en=
try
-	;;
-(p7)	ld8 r17=3D[r17]				// fetch the L2 entry (may be 0)
-	shr.u r19=3Dr16,PAGE_SHIFT		// shift L3 index into position
-	;;
-(p7)	cmp.eq.or.andcm p6,p7=3Dr17,r0		// was L2 entry NULL?
-	dep r17=3Dr19,r17,3,(PAGE_SHIFT-3)	// compute address of L3 page table en=
try
+	FIND_PTE(r16,r17,p6,p7)
 (p6)	br.cond.spnt page_fault
 	mov b0=3Dr30
 	br.sptk.many b0				// return to continuation point
@@ -501,16 +456,13 @@
 	 * page table TLB entry isn't present, we take a nested TLB miss hit wher=
e we look
 	 * up the physical address of the L3 PTE and then continue at label 1 bel=
ow.
 	 */
-	mov r16=3Dcr.ifa				// get the address that caused the fault
-	movl r30=3D1f				// load continuation point in case of nested fault
-	;;
-	thash r17=3Dr16				// compute virtual address of L3 PTE
 	mov r29=3Db0				// save b0 in case of nested fault
 	mov r31=3Dpr				// save pr
+	;;
+	LOAD_PTE_FAULT(r16,r17,r18,r22,.dtlb_fault)
+=09
 #ifdef CONFIG_SMP
 	mov r28=3Dar.ccv				// save ar.ccv
-	;;
-1:	ld8 r18=3D[r17]
 	;;					// avoid RAW on r18
 	mov ar.ccv=3Dr18				// set compare value for cmpxchg
 	or r25=3D_PAGE_D|_PAGE_A,r18		// set the dirty and accessed bits
@@ -533,14 +485,10 @@
 	cmp.eq p6,p7=3Dr18,r25			// is it same as the newly installed
 	;;
 (p7)	ptc.l r16,r24
-	mov b0=3Dr29				// restore b0
 	mov ar.ccv=3Dr28
 #else
-	;;
-1:	ld8 r18=3D[r17]
 	;;					// avoid RAW on r18
 	or r18=3D_PAGE_D|_PAGE_A,r18		// set the dirty and accessed bits
-	mov b0=3Dr29				// restore b0
 	;;
 	st8 [r17]=3Dr18				// store back updated PTE
 	itc.d r18				// install updated PTE
@@ -556,7 +504,7 @@
 	DBG_FAULT(9)
 	// Like Entry 8, except for instruction access
 	mov r16=3Dcr.ifa				// get the address that caused the fault
-	movl r30=3D1f				// load continuation point in case of nested fault
+	mov r29=3Db0				// save b0
 	mov r31=3Dpr				// save predicates
 #ifdef CONFIG_ITANIUM
 	/*
@@ -570,13 +518,10 @@
 (p6)	mov r16=3Dr18				// if so, use cr.iip instead of cr.ifa
 #endif /* CONFIG_ITANIUM */
 	;;
-	thash r17=3Dr16				// compute virtual address of L3 PTE
-	mov r29=3Db0				// save b0 in case of nested fault)
+	LOAD_PTE_FAULT(r16,r17,r18,r22,.itlb_fault)
 #ifdef CONFIG_SMP
 	mov r28=3Dar.ccv				// save ar.ccv
 	;;
-1:	ld8 r18=3D[r17]
-	;;
 	mov ar.ccv=3Dr18				// set compare value for cmpxchg
 	or r25=3D_PAGE_A,r18			// set the accessed bit
 	;;
@@ -598,14 +543,10 @@
 	cmp.eq p6,p7=3Dr18,r25			// is it same as the newly installed
 	;;
 (p7)	ptc.l r16,r24
-	mov b0=3Dr29				// restore b0
 	mov ar.ccv=3Dr28
 #else /* !CONFIG_SMP */
 	;;
-1:	ld8 r18=3D[r17]
-	;;
 	or r18=3D_PAGE_A,r18			// set the accessed bit
-	mov b0=3Dr29				// restore b0
 	;;
 	st8 [r17]=3Dr18				// store back updated PTE
 	itc.i r18				// install updated PTE
@@ -621,15 +562,12 @@
 	DBG_FAULT(10)
 	// Like Entry 8, except for data access
 	mov r16=3Dcr.ifa				// get the address that caused the fault
-	movl r30=3D1f				// load continuation point in case of nested fault
-	;;
-	thash r17=3Dr16				// compute virtual address of L3 PTE
+	mov r29=3Db0				// save b0
 	mov r31=3Dpr
-	mov r29=3Db0				// save b0 in case of nested fault)
+	;;
+	LOAD_PTE_FAULT(r16,r17,r18,r22,.dtlb_fault)
 #ifdef CONFIG_SMP
 	mov r28=3Dar.ccv				// save ar.ccv
-	;;
-1:	ld8 r18=3D[r17]
 	;;					// avoid RAW on r18
 	mov ar.ccv=3Dr18				// set compare value for cmpxchg
 	or r25=3D_PAGE_A,r18			// set the dirty bit
@@ -661,7 +599,6 @@
 	st8 [r17]=3Dr18				// store back updated PTE
 	itc.d r18				// install updated PTE
 #endif
-	mov b0=3Dr29				// restore b0
 	mov pr=3Dr31,-1
 	rfi
 END(daccess_bit)

--QKdGvSO+nmPlgiQ/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="03-VHPT-hugetlb-support.patch"
Content-Transfer-Encoding: quoted-printable

# add hugetlb support for the page table walker

diff -Nru a/include/asm-ia64/ivt.h b/include/asm-ia64/ivt.h
--- a/include/asm-ia64/ivt.h	2004-08-12 19:22:57 +10:00
+++ b/include/asm-ia64/ivt.h	2004-08-12 19:22:57 +10:00
@@ -5,22 +5,42 @@
  *	Matthew Chapman <matthewc@cse.unsw.edu.au>
  *      Darren Williams <dsw@gelato.unsw.edu.au>
  */
-=20
+
+#define eva     r22		/* effective va after accounting for hugepages */=20
 #define temp    r24
 #define rgn     r25		/* region register                                */
 #define tir     r26		/* translation register                           */
 #define mbz     r27		/* "must be zero" else signifies non valid region */=
=20
 #define scratch r28
=20
+#ifdef CONFIG_HUGETLB_PAGE
+#define HUGETLB_GET_ITIR(tir) mov tir=3Dcr.itir
+#define HUGETLB_GET_EVA(tir, temp, va, eva)							\
+        movl scratch=3DHPAGE_SHIFT; 								\
+        extr.u temp=3Dtir,2,6			/* extract the default page size bits */	\
+        ;;											\
+        cmp.eq p6,p7=3Dscratch,temp;		/* default page size is huge page si=
ze ? */	\
+        movl scratch=3DHPAGE_SHIFT-PAGE_SHIFT							\
+        ;;											\
+(p6)    shr eva=3Dva,scratch;									\
+(p7)    mov eva=3Dva										\
+	;;
+#else  /* !CONFIG_HUGETLB_PAGE */
+#define HUGETLB_GET_ITIR(tir)
+#define HUGETLB_GET_EVA(tir, temp, va, eva) mov eva=3Dva;;
+#endif /* !CONFIG_HUGETLB_PAGE */
+
 /* va=3Dr16 ppte=3Dr19 fail=3Dp6 ok=3Dp7 */
 #define FIND_PTE(va, ppte, fail, ok)									\
+	HUGETLB_GET_ITIR(tir);										\
 	rsm psr.dt;				/* switch to using physical data addressing */		\
 	mov ppte=3DIA64_KR(PT_BASE);		/* get the page table base address */			\
 	shl mbz=3Dva,3;				/* shift bit 60 into sign bit	*/			\
 	shr.u rgn=3Dva,61;			/* get the region number into 'rgn' */			\
 	;;												\
+	HUGETLB_GET_EVA(tir, temp, va, eva)								\
 	cmp.eq p6,p7=3D5,rgn;			/* is faulting address in region 5? */			\
-	shr.u temp=3Dva,PGDIR_SHIFT;		/* get bits 33-63 of faulting address */		\
+	shr.u temp=3Deva,PGDIR_SHIFT;		/* get bits 33-63 of faulting address */		\
 	;;												\
 (p7)	dep ppte=3Drgn,ppte,(PAGE_SHIFT-3),3;	/* put region number bits in pl=
ace */			\
 	srlz.d;												\
@@ -33,7 +53,7 @@
 (p6)	dep ppte=3Dtemp,ppte,3,(PAGE_SHIFT-3);	/* ppte=3DPTA + IFA(33,42)*8 *=
/				\
 (p7)	dep ppte=3Dtemp,ppte,3,(PAGE_SHIFT-6);	/* ppte=3DPTA + (((IFA(61,63) =
<< 7) | IFA(33,39))*8) */	\
 	cmp.eq ok,fail=3D0,mbz;			/* unused address bits all zeroes? */			\
-	shr.u temp=3Dva,PMD_SHIFT;		/* shift L2 index into position	*/			\
+	shr.u temp=3Deva,PMD_SHIFT;		/* shift L2 index into position	*/			\
 	;;												\
 	ld8 ppte=3D[ppte];			/* fetch the L1 entry (may be 0)*/			\
 	;;												\
@@ -41,7 +61,7 @@
 	dep ppte=3Dtemp,ppte,3,(PAGE_SHIFT-3);	/* compute address of L2 page tabl=
e entry*/		\
 	;;												\
 (ok)	ld8 ppte=3D[ppte];			/* fetch the L2 entry (may be 0)*/			\
-	shr.u temp=3Dva,PAGE_SHIFT;		/* shift L3 index into position*/			\
+	shr.u temp=3Deva,PAGE_SHIFT;		/* shift L3 index into position*/			\
 	;;												\
 (ok)	cmp.eq.or.andcm fail,ok=3Dppte,r0;	/* was L2 entry NULL?*/					\
 	dep ppte=3Dtemp,ppte,3,(PAGE_SHIFT-3);	/* compute address of L3 page tabl=
e entry*/

--QKdGvSO+nmPlgiQ/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="04-lf-VHPT-macro-def-ivt.h.patch"
Content-Transfer-Encoding: quoted-printable

# abstract from arch/ia64/kernel/ivt.S

Index: fixup/include/asm-ia64/ivt.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- fixup.orig/include/asm-ia64/ivt.h	2004-08-25 11:06:35.832453532 +1000
+++ fixup/include/asm-ia64/ivt.h	2004-08-25 11:06:52.054133021 +1000
@@ -30,6 +30,14 @@
 #define HUGETLB_GET_EVA(tir, temp, va, eva) mov eva=3Dva;;
 #endif /* !CONFIG_HUGETLB_PAGE */
=20
+/*
+ * FIND_PTE - given the virtual address find the page table entry.
+ *         @va,       virtual address that caused the look up
+ *         @ppte,     pointer to the page table entry at L1,L2 and L3
+ *         @fail,@ok, predicate registers p6,p7
+ *
+ *         Walks the ia64 3 level page table and sets the pointer 'ppte' f=
or 'va'.
+ */
 /* va=3Dr16 ppte=3Dr19 fail=3Dp6 ok=3Dp7 */
 #define FIND_PTE(va, ppte, fail, ok)									\
 	HUGETLB_GET_ITIR(tir);										\
@@ -66,6 +74,104 @@
 (ok)	cmp.eq.or.andcm fail,ok=3Dppte,r0;	/* was L2 entry NULL?*/					\
 	dep ppte=3Dtemp,ppte,3,(PAGE_SHIFT-3);	/* compute address of L3 page tabl=
e entry*/
=20
+#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
+/*
+ * LOAD_PTE_MISS - load pte into tlb and VHPT
+ *    @va,   virtual address
+ *    @ppte, pointer to the page table entry
+ *    @pte,  actual pte
+ *    @hpte, hash page table entry
+ *
+ *    Given a va get the ppte and load its value into pte
+ */
+#define LOAD_PTE_MISS(va, ppte, pte, hpte, failfn)						\
+	;;											\
+	FIND_PTE(va, ppte, p6, p7)								\
+	;;											\
+(p7)	ld8 pte=3D[ppte];										\
+	;;											\
+(p7)	tbit.z p6,p0=3Dpte,_PAGE_P_BIT;		/* page present bit cleared? */			\
+(p6)	br.cond.spnt failfn;=20
+
+/* Since we access the page table physically, we access the long VHPT phys=
ically as well
+ * to avoid switching back and forth */
+
+/*
+ * LOAD_PTE_FAULT - get the pte entry from the VHPT for va
+ *    @va,     virtual address to resolve
+ *    @ppte,   pointer to the page table entry
+ *    @pte,    page table entry
+ *    @hpte,   store pte in this hash page table entry
+ *    @failfn, function called if fault not resolved
+ *
+ *    Retrieve the pte via the hashed page table and store it in pte=3Dr18
+ */
+#define tag r25
+#define htag r26
+#define LOAD_PTE_FAULT(va, ppte, pte, hpte, failfn)						\
+	thash hpte=3Dva;										\
+	rsm psr.dt;										\
+	;;											\
+	tpa hpte=3Dhpte;				/* make hash address physical */		\
+	ttag tag=3Dva;										\
+	;;											\
+	srlz.d;											\
+	add temp=3D16,hpte;									\
+	add ppte=3D24,hpte;									\
+	;;											\
+	ld8 htag=3D[temp];									\
+	ld8 ppte=3D[ppte];									\
+	;;											\
+	cmp.ne p6,p7=3Dhtag, tag;			/* verify tag */				\
+	;;											\
+(p7)	ld8 pte=3D[ppte];										\
+(p6)	br.cond.spnt failfn;
+
+/*
+ * VHPT_INSERT -
+ *    @va,   virtual address to be inserted
+ *    @ppte, pointer to the page table entry
+ *    @pte,  page table entry to be inserted
+ *    @hpte, insert pte into this hash page table entry
+ *
+ *    Insert the va into the VHPT and tlb, the tlb insert
+ *    happens in ivt.S for the appropriate fault instruction or data.
+ */
+#define tir r26
+#define VHPT_INSERT(va, ppte, pte, hpte)							\
+	mov hpte=3Dcr.iha;									\
+	mov tir=3Dcr.itir;									\
+	;;											\
+	tpa hpte=3Dhpte;				/* make hash address physical */		\
+	ttag tag=3Dva;										\
+	;;											\
+	add temp=3D16,hpte;									\
+	;;											\
+	st8 [hpte]=3Dpte,8;			/* fill out VHPT entry */			\
+	st8 [temp]=3Dtag,8;									\
+	;;											\
+	st8 [hpte]=3Dtir,8;									\
+	st8 [temp]=3Dppte;
+
+/*
+ * Update the VHPT with pte value obtained from LOAD_PTE_FAULT
+ */=09
+#define VHPT_UPDATE(cond, pte, hpte)								\
+(cond)	st8 [hpte]=3Dpte,16;
+
+/*
+ * Invalidate the tlb for the VHPT pointing to hpte, this is achieved by
+ * setting the invalid tag bit(63) in the VHPT tag field. A VHPT entry with
+ * ti bit set to one will never be inserted into a processor's TLBs.
+ *=20
+ */
+#define VHPT_PURGE(cond, hpte)									\
+(cond)	dep tag=3D-1,r0,63,1;			/* set tag-invalid bit */			\
+	;;											\
+(cond)	st8 [hpte]=3Dtag;				/* hpte already points to tag (see above) */
+
+#else /* !CONFIG_IA64_LONG_FORMAT_VHPT */
+
 #define LOAD_PTE_MISS(va, ppte, pte, hpte, failfn)						\
 	mov ppte=3Dcr.iha;			/* get virtual address of L3 PTE */		\
 	movl r30=3D1f;				/* load continuation point */			\
@@ -83,4 +189,9 @@
 1:	ld8 pte=3D[ppte];										\
 	mov b0=3Dr29;				/* restore possibly destroyed b0 */
=20
+#define VHPT_INSERT(va, ppte, pte, hpte)		/* nothing */
+#define VHPT_UPDATE(cond, pte, hpte)			/* nothing */
+#define VHPT_PURGE(cond, hpte)				/* nothing */
+#endif /* !CONFIG_IA64_LONG_FORMAT_VHPT */
+=20
 #endif /* _ASM_IA64_IVT_H */

--QKdGvSO+nmPlgiQ/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="05-lf-VHPT-macro-calls-ivt.S.patch"
Content-Transfer-Encoding: quoted-printable

# Add support for long format vhpt in abstracted macros

diff -Nru a/arch/ia64/kernel/ivt.S b/arch/ia64/kernel/ivt.S
--- a/arch/ia64/kernel/ivt.S	2004-08-12 19:24:47 +10:00
+++ b/arch/ia64/kernel/ivt.S	2004-08-12 19:24:47 +10:00
@@ -102,7 +102,13 @@
 	 * do_page_fault gets invoked in the following cases:
 	 *	- the faulting virtual address uses unimplemented address bits
 	 *	- the faulting virtual address has no L1, L2, or L3 mapping
+	 *
+	 * This fault should not occur with the long format VHPT since we keep it
+	 * permanently mapped.
 	 */
+#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
+	FAULT(0)
+#else
 	mov r16=3Dcr.ifa				// get address that caused the TLB miss
 #ifdef CONFIG_HUGETLB_PAGE
 	movl r18=3DPAGE_SHIFT
@@ -207,6 +213,7 @@
=20
 	mov pr=3Dr31,-1				// restore predicate registers
 	rfi
+#endif /* !CONFIG_IA64_LONG_FORMAT_VHPT */
 END(vhpt_miss)
=20
 	.org ia64_ivt+0x400
@@ -226,13 +233,14 @@
 .itlb_fault:
 	LOAD_PTE_MISS(r16,r17,r18,r22,page_fault) // find PTE and check present b=
it
 	;;
+	VHPT_INSERT(r16,r17,r18,r22)
 	itc.i r18
-	;;
 #ifdef CONFIG_SMP
 	/*
 	 * Tell the assemblers dependency-violation checker that the above "itc" =
instructions
 	 * cannot possibly affect the following loads:
 	 */
+	;;=20
 	dv_serialize_data
=20
 	ld8 r19=3D[r17]				// read L3 PTE again and see if same
@@ -240,6 +248,7 @@
 	;;
 	cmp.ne p7,p0=3Dr18,r19
 	;;
+	VHPT_PURGE(p7,r22)
 (p7)	ptc.l r16,r20
 #endif
 	mov pr=3Dr31,-1
@@ -263,13 +272,14 @@
 .dtlb_fault:
 	LOAD_PTE_MISS(r16,r17,r18,r22,page_fault) // find PTE and check present b=
it
 	;;
+	VHPT_INSERT(r16,r17,r18,r22)
 	itc.d r18
-	;;
 #ifdef CONFIG_SMP
 	/*
 	 * Tell the assemblers dependency-violation checker that the above "itc" =
instructions
 	 * cannot possibly affect the following loads:
 	 */
+	;;
 	dv_serialize_data
=20
 	ld8 r19=3D[r17]				// read L3 PTE again and see if same
@@ -277,6 +287,7 @@
 	;;
 	cmp.ne p7,p0=3Dr18,r19
 	;;
+	VHPT_PURGE(p7,r22)
 (p7)	ptc.l r16,r20
 #endif
 	mov pr=3Dr31,-1
@@ -381,6 +392,9 @@
 	 * continuation point passed in register r30 (or call page_fault if the a=
ddress is
 	 * not mapped).
 	 *
+	 * This fault should not occur with the long format VHPT since we keep it
+	 * permanently mapped.
+	 *
 	 * Input:	r16:	faulting address
 	 *		r29:	saved b0
 	 *		r30:	continuation address
@@ -391,12 +405,17 @@
 	 *		r30:	continuation address
 	 *		r31:	saved pr
 	 *
-	 * Clobbered:	b0, r18, r19, r21, psr.dt (cleared)
+	 * Clobbered:	b0, psr.dt (cleared), r24-r26 (see FIND_PTE)
 	 */
+#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
+	DBG_FAULT(5)
+	FAULT(5)
+#else=09
 	FIND_PTE(r16,r17,p6,p7)
 (p6)	br.cond.spnt page_fault
 	mov b0=3Dr30
 	br.sptk.many b0				// return to continuation point
+#endif
 END(nested_dtlb_miss)
=20
 	.org ia64_ivt+0x1800
@@ -472,6 +491,7 @@
 	;;
 	cmp.eq p6,p7=3Dr26,r18
 	;;
+	VHPT_UPDATE(p6,r18,r22)
 (p6)	itc.d r25				// install updated PTE
 	;;
 	/*
@@ -484,6 +504,7 @@
 	;;
 	cmp.eq p6,p7=3Dr18,r25			// is it same as the newly installed
 	;;
+	VHPT_PURGE(p7,r22)
 (p7)	ptc.l r16,r24
 	mov ar.ccv=3Dr28
 #else
@@ -491,6 +512,7 @@
 	or r18=3D_PAGE_D|_PAGE_A,r18		// set the dirty and accessed bits
 	;;
 	st8 [r17]=3Dr18				// store back updated PTE
+	VHPT_UPDATE(p0,r18,r22)
 	itc.d r18				// install updated PTE
 #endif
 	mov pr=3Dr31,-1				// restore pr
@@ -530,6 +552,7 @@
 	;;
 	cmp.eq p6,p7=3Dr26,r18
 	;;
+	VHPT_UPDATE(p6,r18,r22)
 (p6)	itc.i r25				// install updated PTE
 	;;
 	/*
@@ -542,6 +565,7 @@
 	;;
 	cmp.eq p6,p7=3Dr18,r25			// is it same as the newly installed
 	;;
+	VHPT_PURGE(p7,r22)
 (p7)	ptc.l r16,r24
 	mov ar.ccv=3Dr28
 #else /* !CONFIG_SMP */
@@ -549,6 +573,7 @@
 	or r18=3D_PAGE_A,r18			// set the accessed bit
 	;;
 	st8 [r17]=3Dr18				// store back updated PTE
+	VHPT_UPDATE(p0,r18,r22)
 	itc.i r18				// install updated PTE
 #endif /* !CONFIG_SMP */
 	mov pr=3Dr31,-1
@@ -577,6 +602,7 @@
 	;;
 	cmp.eq p6,p7=3Dr26,r18
 	;;
+	VHPT_UPDATE(p6,r18,r22)
 (p6)	itc.d r25				// install updated PTE
 	/*
 	 * Tell the assemblers dependency-violation checker that the above "itc" =
instructions
@@ -588,6 +614,7 @@
 	;;
 	cmp.eq p6,p7=3Dr18,r25			// is it same as the newly installed
 	;;
+	VHPT_PURGE(p7,r22)
 (p7)	ptc.l r16,r24
 	mov ar.ccv=3Dr28
 #else
@@ -597,6 +624,7 @@
 	or r18=3D_PAGE_A,r18			// set the accessed bit
 	;;
 	st8 [r17]=3Dr18				// store back updated PTE
+	VHPT_UPDATE(p0,r18,r22)
 	itc.d r18				// install updated PTE
 #endif
 	mov pr=3Dr31,-1

--QKdGvSO+nmPlgiQ/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="06-lf-VHPT-declarations.patch"
Content-Transfer-Encoding: quoted-printable

# setup the long format VHPT

Index: linux-2.6.9.rc1/arch/ia64/kernel/setup.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.9.rc1.orig/arch/ia64/kernel/setup.c	2004-08-17 12:03:33.00000=
0000 +1000
+++ linux-2.6.9.rc1/arch/ia64/kernel/setup.c	2004-08-25 12:15:37.147958127 =
+1000
@@ -226,6 +226,19 @@
 #endif
 }
=20
+static void __init parse_cmdline_early (char ** cmdline_p)
+{
+#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
+	char *p;
+	extern int lvhpt_adj_setup(char *s);
+
+	strlcpy(saved_command_line, *cmdline_p, COMMAND_LINE_SIZE);
+	if ((p =3D strstr(*cmdline_p, "lvhpt_adjust=3D"))) {
+		lvhpt_adj_setup(p + 13);
+	}
+#endif
+}
+
 static void __init
 io_port_init (void)
 {
Index: linux-2.6.9.rc1/arch/ia64/mm/init.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.9.rc1.orig/arch/ia64/mm/init.c	2004-08-25 12:12:40.157725920 =
+1000
+++ linux-2.6.9.rc1/arch/ia64/mm/init.c	2004-08-25 12:15:37.148934689 +1000
@@ -39,6 +39,11 @@
=20
 DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
=20
+#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
+unsigned long vhpt_base[NR_CPUS];
+unsigned long long_vhpt_bits, long_vhpt_size;
+#endif
+
 extern void ia64_tlb_init (void);
=20
 unsigned long MAX_DMA_ADDRESS =3D PAGE_OFFSET + 0x100000000UL;
@@ -274,6 +279,50 @@
 	ia64_patch_gate();
 }
=20
+#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
+/*
+ * This code must be called on a CPU which has it's MMU
+ * initialized. The page allocator seems to depend on it.
+ *
+ * Returns 0 on success.
+ */
+unsigned int
+alloc_vhpt(int cpu)
+{
+#ifdef CONFIG_NUMA=09
+	struct page *page;
+
+	page =3D alloc_pages_node(cpu_to_node(cpu), __GFP_HIGHMEM|GFP_ATOMIC, lon=
g_vhpt_bits - PAGE_SHIFT);
+	if (!page)
+		return -1;
+	vhpt_base[cpu] =3D (unsigned long) page_address(page);
+#else
+	vhpt_base[cpu] =3D (unsigned long)__get_free_pages(__GFP_HIGHMEM|GFP_ATOM=
IC, long_vhpt_bits - PAGE_SHIFT);
+#endif
+	return (vhpt_base[cpu] =3D=3D 0);
+}
+
+static int lvhpt_adjust;
+
+int __init
+lvhpt_adj_setup(char *s)
+{
+	if (sscanf(s, "%d", &lvhpt_adjust) <=3D 0)
+		lvhpt_adjust =3D 0;
+	return 1;
+}
+
+__setup("lvhpt_adjust=3D", lvhpt_adj_setup);
+
+void __init
+compute_vhpt_size(void)
+{
+	long_vhpt_bits =3D 22 + lvhpt_adjust;
+	long_vhpt_size =3D 1 << long_vhpt_bits;
+}
+
+#endif /* CONFIG_IA64_LONG_FORMAT_VHPT */
+
 void __devinit
 ia64_mmu_init (void *my_cpu_data)
 {
Index: linux-2.6.9.rc1/include/asm-ia64/kregs.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.9.rc1.orig/include/asm-ia64/kregs.h	2004-08-17 12:03:33.00000=
0000 +1000
+++ linux-2.6.9.rc1/include/asm-ia64/kregs.h	2004-08-25 12:15:37.149911252 =
+1000
@@ -30,6 +30,7 @@
 #define IA64_TR_PALCODE		1	/* itr1: maps PALcode as required by EFI */
 #define IA64_TR_PERCPU_DATA	1	/* dtr1: percpu data */
 #define IA64_TR_CURRENT_STACK	2	/* dtr2: maps kernel's memory- & register-=
stacks */
+#define IA64_TR_LONG_VHPT	3	/* dtr3: maps long format VHPT */
=20
 /* Processor status register bits: */
 #define IA64_PSR_BE_BIT		1
Index: linux-2.6.9.rc1/include/asm-ia64/page.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.9.rc1.orig/include/asm-ia64/page.h	2004-08-17 12:03:33.000000=
000 +1000
+++ linux-2.6.9.rc1/include/asm-ia64/page.h	2004-08-25 12:15:37.149911252 +=
1000
@@ -139,6 +139,11 @@
 	return order;
 }
=20
+#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
+/* Long format VHPT entry */
+typedef struct { unsigned long pte, itir, tag, ig; } long_pte_t;
+#endif
+
 # endif /* __KERNEL__ */
 #endif /* !__ASSEMBLY__ */
=20
Index: linux-2.6.9.rc1/include/asm-ia64/pgtable.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.9.rc1.orig/include/asm-ia64/pgtable.h	2004-08-25 12:12:42.332=
530581 +1000
+++ linux-2.6.9.rc1/include/asm-ia64/pgtable.h	2004-08-25 12:15:37.15088781=
4 +1000
@@ -523,6 +523,12 @@
     extern void memmap_init (unsigned long size, int nid, unsigned long zo=
ne,
 			     unsigned long start_pfn);
 #  endif /* CONFIG_VIRTUAL_MEM_MAP */
+
+#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
+extern unsigned long vhpt_base[NR_CPUS];
+extern unsigned long long_vhpt_bits, long_vhpt_size;
+#endif
+
 # endif /* !__ASSEMBLY__ */
=20
 /*
@@ -543,6 +549,11 @@
 #define KERNEL_TR_PAGE_SIZE	(1 << KERNEL_TR_PAGE_SHIFT)
=20
 /*
+ * Long format VHPT
+ */
+#define LONG_VHPT_BASE		(0xc000000000000000 - long_vhpt_size)
+
+/*
  * No page table caches to initialise
  */
 #define pgtable_cache_init()	do { } while (0)

--QKdGvSO+nmPlgiQ/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="07-lf-VHPT-initialise.patch"
Content-Transfer-Encoding: quoted-printable

# initalise the long format vhpt

Index: linux-2.6.9.rc1/arch/ia64/kernel/setup.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.9.rc1.orig/arch/ia64/kernel/setup.c	2004-08-25 12:15:37.14795=
8127 +1000
+++ linux-2.6.9.rc1/arch/ia64/kernel/setup.c	2004-08-25 12:16:50.598152540 =
+1000
@@ -321,9 +321,15 @@
 	ia64_patch_vtop((u64) __start___vtop_patchlist, (u64) __end___vtop_patchl=
ist);
=20
 	*cmdline_p =3D __va(ia64_boot_param->command_line);
-	strlcpy(saved_command_line, *cmdline_p, COMMAND_LINE_SIZE);
+	parse_cmdline_early(cmdline_p);
=20
 	efi_init();
+#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
+ 	{
+ 		extern void compute_vhpt_size(void);
+ 		compute_vhpt_size();
+ 	}
+#endif	=09
 	io_port_init();
=20
 #ifdef CONFIG_IA64_GENERIC
Index: linux-2.6.9.rc1/arch/ia64/kernel/smpboot.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.9.rc1.orig/arch/ia64/kernel/smpboot.c	2004-08-25 12:12:40.151=
866545 +1000
+++ linux-2.6.9.rc1/arch/ia64/kernel/smpboot.c	2004-08-25 12:16:50.59912910=
2 +1000
@@ -376,6 +376,11 @@
 	complete(&c_idle->done);
 }
=20
+#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
+/* required for do_boot_cpu, defined in init.c */
+extern unsigned int alloc_vhpt(int cpu);
+#endif
+
 static int __devinit
 do_boot_cpu (int sapicid, int cpu)
 {
@@ -399,6 +404,13 @@
 		panic("failed fork for CPU %d", cpu);
 	task_for_booting_cpu =3D c_idle.idle;
=20
+#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
+	if (alloc_vhpt(cpu)) {
+		panic("Couldn't allocate VHPT on CPU %d, size: 0x%lx\n", cpu, long_vhpt_=
size);
+	}
+	printk(KERN_INFO "Allocated long format VHPT for CPU %d at: 0x%lx, size: =
0x%lx\n", cpu, vhpt_base[cpu], long_vhpt_size);
+#endif /* CONFIG_IA64_LONG_FORMAT_VHPT */
+
 	Dprintk("Sending wakeup vector %lu to AP 0x%x/0x%x.\n", ap_wakeup_vector,=
 cpu, sapicid);
=20
 	platform_send_ipi(cpu, ap_wakeup_vector, IA64_IPI_DM_INT, 0);
Index: linux-2.6.9.rc1/arch/ia64/mm/init.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.9.rc1.orig/arch/ia64/mm/init.c	2004-08-25 12:15:37.148934689 =
+1000
+++ linux-2.6.9.rc1/arch/ia64/mm/init.c	2004-08-25 12:16:50.600105665 +1000
@@ -326,7 +326,7 @@
 void __devinit
 ia64_mmu_init (void *my_cpu_data)
 {
-	unsigned long psr, pta, impl_va_bits;
+	unsigned long psr, pta;
 	extern void __devinit tlb_init (void);
 	int cpu;
=20
@@ -336,16 +336,44 @@
 #	define VHPT_ENABLE_BIT	1
 #endif
=20
+#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
+	cpu =3D smp_processor_id();
+	if (cpu =3D=3D 0)
+	{
+		vhpt_base[cpu] =3D (unsigned long)__alloc_bootmem(long_vhpt_size, long_v=
hpt_size,=20
+								__pa(MAX_DMA_ADDRESS));
+		if (vhpt_base[cpu] =3D=3D 0) {
+			panic("Couldn't allocate VHPT on CPU %d, size: 0x%lx\n",=20
+			      cpu, long_vhpt_size);
+		}=20
+		printk(KERN_INFO "Allocated long format VHPT for CPU %d at: 0x%lx, size:=
 0x%lx\n",=20
+		       cpu, vhpt_base[cpu], long_vhpt_size);
+	}
+#endif
+
 	/* Pin mapping for percpu area into TLB */
 	psr =3D ia64_clear_ic();
 	ia64_itr(0x2, IA64_TR_PERCPU_DATA, PERCPU_ADDR,
 		 pte_val(pfn_pte(__pa(my_cpu_data) >> PAGE_SHIFT, PAGE_KERNEL)),
 		 PERCPU_PAGE_SHIFT);
=20
+#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
+	/* Insert the permanent translation for the VHPT */
+	ia64_itr(0x2, IA64_TR_LONG_VHPT, LONG_VHPT_BASE,
+		 pte_val(pfn_pte(__pa(vhpt_base[cpu]) >> PAGE_SHIFT, PAGE_KERNEL)), long=
_vhpt_bits);
+#endif
+
 	ia64_set_psr(psr);
 	ia64_srlz_i();
=20
+#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
+#	define VHPT_FORMAT_BIT		1
+#	define vhpt_bits		long_vhpt_bits
+	pta =3D LONG_VHPT_BASE;
+#else
 	/*
+	 * SHORT FORMAT VHPT (virtually mapped linear pagetable)
+	 *
 	 * Check if the virtually mapped linear page table (VMLPT) overlaps with =
a mapped
 	 * address space.  The IA-64 architecture guarantees that at least 50 bit=
s of
 	 * virtual address space are implemented but if we pick a large enough pa=
ge size
@@ -356,6 +384,7 @@
 	 * address space to not permit mappings that would overlap with the VMLPT.
 	 * --davidm 00/12/06
 	 */
+#	define VHPT_FORMAT_BIT		0
 #	define pte_bits			3
 #	define mapped_space_bits	(3*(PAGE_SHIFT - pte_bits) + PAGE_SHIFT)
 	/*
@@ -365,27 +394,30 @@
 	 * non-speculative accesses to the virtual page table, so the address ran=
ge of the
 	 * virtual page table itself needs to be covered by virtual page table.
 	 */
-#	define vmlpt_bits		(impl_va_bits - PAGE_SHIFT + pte_bits)
+#	define vhpt_bits		(impl_va_bits - PAGE_SHIFT + pte_bits)
 #	define POW2(n)			(1ULL << (n))
=20
+	unsigned long impl_va_bits;
 	impl_va_bits =3D ffz(~(local_cpu_data->unimpl_va_mask | (7UL << 61)));
=20
 	if (impl_va_bits < 51 || impl_va_bits > 61)
 		panic("CPU has bogus IMPL_VA_MSB value of %lu!\n", impl_va_bits - 1);
=20
 	/* place the VMLPT at the end of each page-table mapped region: */
-	pta =3D POW2(61) - POW2(vmlpt_bits);
+	pta =3D POW2(61) - POW2(vhpt_bits);
=20
 	if (POW2(mapped_space_bits) >=3D pta)
 		panic("mm/init: overlap between virtually mapped linear page table and "
 		      "mapped kernel space!");
+#endif
+
 	/*
 	 * Set the (virtually mapped linear) page table address.  Bit
 	 * 8 selects between the short and long format, bits 2-7 the
 	 * size of the table, and bit 0 whether the VHPT walker is
 	 * enabled.
 	 */
-	ia64_set_pta(pta | (0 << 8) | (vmlpt_bits << 2) | VHPT_ENABLE_BIT);
+	ia64_set_pta(pta | (VHPT_FORMAT_BIT << 8) | (vhpt_bits << 2) | VHPT_ENABL=
E_BIT);=20
=20
 	ia64_tlb_init();
=20

--QKdGvSO+nmPlgiQ/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="08-lf-VHPT-tlb-flush-dec.patch"
Content-Transfer-Encoding: quoted-printable

#flushing of the long format vhpt=20

diff -Nru a/include/asm-ia64/tlbflush.h b/include/asm-ia64/tlbflush.h
--- a/include/asm-ia64/tlbflush.h	2004-08-12 19:29:25 +10:00
+++ b/include/asm-ia64/tlbflush.h	2004-08-12 19:29:25 +10:00
@@ -19,6 +19,21 @@
  * can be very expensive, so try to avoid them whenever possible.
  */
=20
+/* Flushing a translation from the long format VHPT */
+#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
+# define INVALID_TAG (1UL << 63)
+
+static inline void
+flush_vhpt_page(unsigned long addr)
+{
+	long_pte_t *hpte;
+	hpte =3D (long_pte_t *)ia64_thash(addr);
+	hpte->tag =3D INVALID_TAG;
+}
+#else
+# define flush_vhpt_page(addr)	do { } while (0)
+#endif
+
 /*
  * Flush everything (kernel mapping may also have changed due to
  * vmalloc/vfree).

--QKdGvSO+nmPlgiQ/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="09-lf-VHPT-tlb-flush.patch"
Content-Transfer-Encoding: quoted-printable

# long format support for flushing vhpt

diff -Nru a/arch/ia64/mm/tlb.c b/arch/ia64/mm/tlb.c
--- a/arch/ia64/mm/tlb.c	2004-08-12 19:29:42 +10:00
+++ b/arch/ia64/mm/tlb.c	2004-08-12 19:29:42 +10:00
@@ -110,6 +110,14 @@
 {
 	unsigned long i, j, flags, count0, count1, stride0, stride1, addr;
=20
+#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
+	unsigned long page;
+
+	/* Admittedly 0 is a valid tag, but in that rare case the present bit wil=
l save us */
+	for (page =3D LONG_VHPT_BASE; page < LONG_VHPT_BASE+long_vhpt_size; page =
+=3D PAGE_SIZE)
+		clear_page((void *)page);
+#endif
+
 	addr    =3D local_cpu_data->ptce_base;
 	count0  =3D local_cpu_data->ptce_count[0];
 	count1  =3D local_cpu_data->ptce_count[1];
@@ -129,6 +137,37 @@
 }
 EXPORT_SYMBOL(local_flush_tlb_all);
=20
+#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
+static void
+flush_vhpt_range (struct mm_struct *mm, unsigned long from, unsigned long =
to)
+{
+	unsigned long addr;
+
+	for (addr =3D from; addr < to; addr +=3D PAGE_SIZE)
+		flush_vhpt_page(addr);
+
+#ifdef CONFIG_SMP
+	{
+		/* Urgh... flush VHPTs of any other CPUs that have run this mm */
+		extern unsigned long vhpt_base[];
+		unsigned long offset;
+		long_pte_t *hpte;
+		int cpu;
+
+		for_each_cpu_mask(cpu, mm->cpu_vm_mask)
+		{
+			for (addr =3D from; addr < to; addr +=3D PAGE_SIZE)
+			{
+				offset =3D ia64_thash(addr) & (long_vhpt_size-1);
+				hpte =3D (long_pte_t *)(vhpt_base[cpu] + offset);
+				hpte->tag =3D INVALID_TAG;
+			}
+		}
+	}
+#endif
+}
+#endif /* CONFIG_IA64_LONG_FORMAT_VHPT */
+
 void
 flush_tlb_range (struct vm_area_struct *vma, unsigned long start, unsigned=
 long end)
 {
@@ -145,6 +184,10 @@
 #endif
 		return;
 	}
+
+#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
+	flush_vhpt_range(mm, start, end);
+#endif
=20
 	nbits =3D ia64_fls(size + 0xfff);
 	while (unlikely (((1UL << nbits) & purge.mask) =3D=3D 0) && (nbits < purg=
e.max_bits))
diff -Nru a/include/asm-ia64/tlb.h b/include/asm-ia64/tlb.h
--- a/include/asm-ia64/tlb.h	2004-08-12 19:29:42 +10:00
+++ b/include/asm-ia64/tlb.h	2004-08-12 19:29:42 +10:00
@@ -107,8 +107,10 @@
 		vma.vm_mm =3D tlb->mm;
 		/* flush the address range from the tlb: */
 		flush_tlb_range(&vma, start, end);
+#ifndef CONFIG_IA64_LONG_FORMAT_VHPT
 		/* now flush the virt. page-table area mapping the address range: */
 		flush_tlb_range(&vma, ia64_thash(start), ia64_thash(end));
+#endif
 	}
=20
 	/* lastly, release the freed pages */
diff -Nru a/include/asm-ia64/tlbflush.h b/include/asm-ia64/tlbflush.h
--- a/include/asm-ia64/tlbflush.h	2004-08-12 19:29:42 +10:00
+++ b/include/asm-ia64/tlbflush.h	2004-08-12 19:29:42 +10:00
@@ -68,6 +68,7 @@
 		goto out;
=20
 	mm->context =3D 0;
+	cpu_clear(smp_processor_id(),mm->cpu_vm_mask);
=20
 	if (atomic_read(&mm->mm_users) =3D=3D 0)
 		goto out;		/* happens as a result of exit_mmap() */
@@ -93,7 +94,10 @@
 	flush_tlb_range(vma, (addr & PAGE_MASK), (addr & PAGE_MASK) + PAGE_SIZE);
 #else
 	if (vma->vm_mm =3D=3D current->active_mm)
+	{
+		flush_vhpt_page(addr);
 		ia64_ptcl(addr, (PAGE_SHIFT << 2));
+	}
 	else
 		vma->vm_mm->context =3D 0;
 #endif

--QKdGvSO+nmPlgiQ/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="10-lf-VHPT-mmu_context-dec.patch"
Content-Transfer-Encoding: quoted-printable

# optimisation around allocating rids in non-optimal order

diff -Nru a/include/asm-ia64/mmu_context.h b/include/asm-ia64/mmu_context.h
--- a/include/asm-ia64/mmu_context.h	2004-08-12 19:30:43 +10:00
+++ b/include/asm-ia64/mmu_context.h	2004-08-12 19:30:43 +10:00
@@ -17,6 +17,20 @@
=20
 #define IA64_REGION_ID_KERNEL	0 /* the kernel's region id (tlb.c depends o=
n this being 0) */
=20
+#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
+/*
+ * Due to a high number of collisions in the long format VHPT walker hash =
function
+ * when RIDs and similar address space layout occur "eg. fork()". The foll=
owing is
+ * used to space out the RIDs we present to the hardware without messing w=
ith Linux's=20
+ * sequential allocation scheme.=20
+ * Refer to 'Intel Itanium Processor Reference Manual for Software Develop=
ment'=20
+ * http://www.intel.com/design/itanium/manuals.htm=20
+ */
+#define redistribute_rid(rid)	(((rid) & ~0xffff) | (((rid) << 8) & 0xff00)=
 | (((rid) >> 8) & 0xff))
+#else
+#define redistribute_rid(rid)	(rid)
+#endif
+
 #define ia64_rid(ctx,addr)	(((ctx) << 3) | (addr >> 61))
=20
 # ifndef __ASSEMBLY__

diff -Nru a/include/asm-ia64/mmu_context.h b/include/asm-ia64/mmu_context.h
--- a/include/asm-ia64/mmu_context.h	2004-08-12 19:31:10 +10:00
+++ b/include/asm-ia64/mmu_context.h	2004-08-12 19:31:10 +10:00
@@ -31,7 +31,7 @@
 #define redistribute_rid(rid)	(rid)
 #endif
=20
-#define ia64_rid(ctx,addr)	(((ctx) << 3) | (addr >> 61))
+#define ia64_rid(ctx,addr)	redistribute_rid(((ctx) << 3) | (addr >> 61))
=20
 # ifndef __ASSEMBLY__
=20
@@ -158,7 +158,12 @@
=20
 	old_rr4 =3D ia64_get_rr(0x8000000000000000);
 	rid =3D context << 3;	/* make space for encoding the region number */
+#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
+	rid =3D redistribute_rid(rid);
+	rid_incr =3D 1 << 16;
+#else
 	rid_incr =3D 1 << 8;
+#endif
=20
 	/* encode the region id, preferred page size, and VHPT enable bit: */
 	rr0 =3D (rid << 8) | (PAGE_SHIFT << 2) | 1;

--QKdGvSO+nmPlgiQ/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="11-lf-VHPT-kconfig.patch"
Content-Transfer-Encoding: quoted-printable

# Add Kconfig option for lfvhpt
Index: linux-2.6.9.rc1/arch/ia64/Kconfig
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.9.rc1.orig/arch/ia64/Kconfig	2004-08-25 12:12:40.135264983 +1=
000
+++ linux-2.6.9.rc1/arch/ia64/Kconfig	2004-08-25 12:31:17.349118484 +1000
@@ -178,6 +178,16 @@
 	  or have huge holes in the physical address space for other reasons.
 	  See <file:Documentation/vm/numa> for more.
=20
+config IA64_LONG_FORMAT_VHPT
+	bool "Long format VHPT"
+	depends on !DISABLE_VHPT
+	help
+	  The long format VHPT is an alternative hashed page table. Advantages=20
+	  of the long format VHPT are lower memory usage when there are a large=
=20
+	  number of processes in the system.
+	  The short format page table walker is currently the Linux default.
+	  If you're unsure, answer N.
+
 config IA64_CYCLONE
 	bool "Cyclone (EXA) Time Source support"
 	help
Index: linux-2.6.9.rc1/Documentation/kernel-parameters.txt
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.9.rc1.orig/Documentation/kernel-parameters.txt	2004-08-25 12:=
17:14.643074120 +1000
+++ linux-2.6.9.rc1/Documentation/kernel-parameters.txt	2004-08-25 12:17:14=
=2E645027245 +1000
@@ -41,6 +41,7 @@
 	ISDN	Appropriate ISDN support is enabled.
 	JOY	Appropriate joystick support is enabled.
 	LP	Printer support is enabled.
+	LONG_FORMAT_VHPT Long Format VHPT is enabled
 	LOOP	Loopback device support is enabled.
 	M68k	M68k architecture is enabled.
 			These options have more detailed description inside of
@@ -596,6 +597,12 @@
 	ltpc=3D		[NET]
 			Format: <io>,<irq>,<dma>
=20
+	lvhpt_adjust=3D	[IA64,LONG_FORMAT_VHPT]
+			Format: <1-39>
+			Increase size of long format vhpt.  Base size is 2^22 bytes, maximum=20
+			is 2^61 bytes.  The lvhpt_adjust value is added to the exponent of the =
base
+			size (i.e. lvhpt_adjust=3D1 means size 2^23 bytes)
+
 	mac5380=3D	[HW,SCSI]
 			Format: <can_queue>,<cmd_per_lun>,<sg_tablesize>,<hostid>,<use_tags>
=20

--QKdGvSO+nmPlgiQ/--

--IpbVkmxF4tDyP/Kb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFBK/q/WDlSU/gp6ecRAteZAJ9feKmHmod97P+Yw7277VoxDkgD9wCcDkAm
GkvDdFQERtBr5cG5GLFzpWE=
=UMJj
-----END PGP SIGNATURE-----

--IpbVkmxF4tDyP/Kb--
