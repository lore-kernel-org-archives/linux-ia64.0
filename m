From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Wed, 10 May 2006 03:42:22 +0000
Subject: [RFC 3/6] LVHPT - ivt.S long format support
Message-Id: <20060510034222.17792.56505.sendpatchset@wagner.orchestra.cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060510034206.17792.82504.sendpatchset@wagner.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20060510034206.17792.82504.sendpatchset@wagner.orchestra.cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org
Cc: linux-mm@kvack.org, Ian Wienand <ianw@gelato.unsw.edu.au>

LVHPT ivt long format support

Add templates for long format VHPT support, to be merged into ivt.S


Signed-Off-By: Ian Wienand <ianw@gelato.unsw.edu.au>

---

 Kconfig              |   10 +
 kernel/Makefile      |    9=20
 kernel/ivt-lfvhpt.in |  466 ++++++++++++++++++++++++++++++++++++++++++++++=
+++++
 3 files changed, 484 insertions(+), 1 deletion(-)

Index: linux-2.6.17-rc3-lvhpt-v2-fresh/arch/ia64/kernel/Makefile
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.17-rc3-lvhpt-v2-fresh.orig/arch/ia64/=
kernel/Makefile	2006-05-05 10:09:38.000000000 +1000
+++ linux-2.6.17-rc3-lvhpt-v2-fresh/arch/ia64/kernel/Makefile	2006-05-05 10=
:12:36.000000000 +1000
@@ -62,5 +62,12 @@
=20
 # The real ivt.S needs to be built
 AFLAGS_ivt.o +=3D -I$(srctree)/arch/ia64/kernel
-$(obj)/ivt.S: $(src)/ivt.S.in $(src)/ivt-sfvhpt.in
+
+ifeq ($(CONFIG_IA64_LONG_FORMAT_VHPT),)
+fault_handler_in =3D ivt-sfvhpt.in
+else
+fault_handler_in =3D ivt-lfvhpt.in
+endif
+
+$(obj)/ivt.S: $(src)/ivt.S.in $(src)/$(fault_handler_in)
 	$(srctree)/arch/ia64/scripts/merge.py $@ $^
Index: linux-2.6.17-rc3-lvhpt-v2-fresh/arch/ia64/kernel/ivt-lfvhpt.in
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.17-rc3-lvhpt-v2-fresh/arch/ia64/kernel/ivt-lfvhpt.in	2006-05-=
05 10:12:36.000000000 +1000
@@ -0,0 +1,466 @@
+/*
+ * Long Format VHPT fault handlers
+ *
+ * Copyright (C) 2006; see ivt.S for original authors
+ * These bits by
+ *  Matthew Chapman <matthewc@cse.unsw.edu.au>
+ *  Darren Williams <darren.williams@nicta.com.au>
+ *  Ian Wienand <ianw@gelato.unsw.edu.au>
+ *
+ * This file is to be processed and inserted into the actual ivt.S
+ *
+ * Any variable $name in ivt.S will be replaced with what is between
+ *__begin_name__ and __end_name__ in this file.
+ *
+ */
+
+//vhpt_miss
+__begin_vhpt_miss_handler__
+// This fault can not happen with long format VHPT
+	FAULT(0)
+__end_vhpt_miss_handler__
+
+// itlb_miss
+__begin_itlb_miss_handler__
+        mov r16=3Dcr.ifa                          // get virtual address
+        mov r29=B0                              // save b0
+        mov r31=3Dpr                              // save predicates
+	;;
+.itlb_fault:
+	// walk the page table to satisfy this miss
+	rsm psr.dt                              // switch to using physical data =
addressing
+        mov r19=3DIA64_KR(PT_BASE)                // get the page table ba=
se address
+        shl r21=3Dr16,3                           // shift bit 60 into sig=
n bit
+        mov r18=3Dcr.itir
+        ;;
+        shr.u r17=3Dr16,61                      // get the region number i=
nto ppte
+        extr.u r18=3Dr18,2,6                      // get the faulting page=
 size
+        ;;
+        cmp.eq p6,p7=3D5,r17                  // is faulting address in re=
gion 5?
+        add r22=3D-PAGE_SHIFT,r18                 // adjustment for hugetl=
b address
+        add r18=3DPGDIR_SHIFT-PAGE_SHIFT,r18
+        ;;
+        shr.u r22=3Dr16,r22
+        shr.u r18=3Dr16,r18
+(p7)	dep r17=3Dr17,r19,(PAGE_SHIFT-3),3    // put region number bits in pl=
ace
+
+        srlz.d
+        LOAD_PHYSICAL(p6, r19, swapper_pg_dir) // region 5 is rooted at sw=
apper_pg_dir
+
+        .pred.rel "mutex", p6, p7
+(p6)	shr.u r21=3Dr21,PGDIR_SHIFT+PAGE_SHIFT
+(p7)	shr.u r21=3Dr21,PGDIR_SHIFT+PAGE_SHIFT-3
+	;;
+(p6)	dep r17=3Dr18,r19,3,(PAGE_SHIFT-3)      // ppte=3Dpgd_offset for regi=
on 5
+(p7)	dep r17=3Dr18,r17,3,(PAGE_SHIFT-3)-3  // ppte=3Dpgd_offset for region=
[0-4]
+	cmp.eq p7,p6=3D0,r21                    // unused address bits all zeroes?
+#ifdef CONFIG_PGTABLE_4
+        shr.u r18=3Dr22,PUD_SHIFT                 // shift pud index into =
position
+#else
+        shr.u r18=3Dr22,PMD_SHIFT                 // shift pmd index into =
position
+#endif
+        ;;
+        ld8 r17=3D[r17]                       // get *pgd (may be 0)
+        ;;
+(p7)	cmp.eq p6,p7=3Dr17,r0                 // was pgd_present(*pgd) =3D NU=
LL?
+        dep r17=3Dr18,r17,3,(PAGE_SHIFT-3)    // ppte=3Dp[u|m]d_offset(pgd=
,addr)
+        ;;
+#ifdef CONFIG_PGTABLE_4
+(p7)	ld8 r17=3D[r17]                       // get *pud (may be 0)
+        shr.u r18=3Dr22,PMD_SHIFT                 // shift pmd index into =
position
+        ;;
+(p7)   cmp.eq.or.andcm p6,p7=3Dr17,r0        // was pud_present(*pud) =3D =
NULL?
+        dep r17=3Dr18,r17,3,(PAGE_SHIFT-3)    // ppte=3Dpmd_offset(pud,add=
r)
+        ;;
+#endif
+(p7)	ld8 r17=3D[r17]                       // get *pmd (may be 0)
+        shr.u r19=3Dr22,PAGE_SHIFT                // shift pte index into =
position
+        ;;
+(p7)	cmp.eq.or.andcm p6,p7=3Dr17,r0        // was pmd_present(*pmd) =3D NU=
LL?
+	dep r17=3Dr19,r17,3,(PAGE_SHIFT-3)    // ppte=3Dpte_offset(pmd,addr)
+	;;
+(p7)    ld8 r18=3D[r17]
+        ;;
+(p7)    tbit.z p6,p0=3Dr18,_PAGE_P_BIT           /* page present bit clear=
ed? */
+(p6)    br.cond.spnt page_fault
+	// insert vhpt mapping
+        mov r22=3Dcr.iha
+        mov r26=3Dcr.itir
+        ;;
+        tpa r22=3Dr22         /* make hash address physical */
+        ttag r25=3Dr16
+        ;;
+        add r24=16,r22
+        ;;
+        st8 [r22]=3Dr18,8      /* fill out VHPT entry */
+        st8 [r24]=3Dr25,8
+        ;;
+        st8 [r22]=3Dr26,8
+        st8 [r24]=3Dr17
+	//insert actual translation
+	;;
+	itc.i r18
+        ;;
+#ifdef CONFIG_SMP
+        /*
+         * Tell the assemblers dependency-violation checker that the above=
 "itc" instructions
+         * cannot possibly affect the following loads:
+         */
+        dv_serialize_data
+
+        ld8 r19=3D[r17]                           // read *pte again and s=
ee if same
+        mov r20=3DPAGE_SHIFT<<2                   // setup page size for p=
urge
+        ;;
+        cmp.ne p7,p0=3Dr18,r19
+        ;;
+(p7)	dep r25=3D-1,r0,63,1      /* set tag-invalid bit */
+	;;
+(p7)	st8 [r22]=3Dr25         /* hpte already points to tag (see above) */
+(p7)    ptc.l r16,r20
+#endif
+        mov pr=3Dr31,-1
+        rfi
+__end_itlb_miss_handler__
+
+// dtlb_miss
+__begin_dtlb_miss_handler__
+        mov r16=3Dcr.ifa                          // get virtual address
+        mov r29=B0                              // save b0
+        mov r31=3Dpr                              // save predicates
+	;;
+.dtlb_fault:
+	// walk the page table to satisfy this miss
+	rsm psr.dt                              // switch to using physical data =
addressing
+        mov r19=3DIA64_KR(PT_BASE)                // get the page table ba=
se address
+        shl r21=3Dr16,3                           // shift bit 60 into sig=
n bit
+        mov r18=3Dcr.itir
+        ;;
+        shr.u r17=3Dr16,61                      // get the region number i=
nto ppte
+        extr.u r18=3Dr18,2,6                      // get the faulting page=
 size
+        ;;
+        cmp.eq p6,p7=3D5,r17                  // is faulting address in re=
gion 5?
+        add r22=3D-PAGE_SHIFT,r18                 // adjustment for hugetl=
b address
+        add r18=3DPGDIR_SHIFT-PAGE_SHIFT,r18
+        ;;
+        shr.u r22=3Dr16,r22
+        shr.u r18=3Dr16,r18
+(p7)   dep r17=3Dr17,r19,(PAGE_SHIFT-3),3    // put region number bits in =
place
+
+        srlz.d
+        LOAD_PHYSICAL(p6, r19, swapper_pg_dir) // region 5 is rooted at sw=
apper_pg_dir
+
+        .pred.rel "mutex", p6, p7
+(p6)   shr.u r21=3Dr21,PGDIR_SHIFT+PAGE_SHIFT
+(p7)   shr.u r21=3Dr21,PGDIR_SHIFT+PAGE_SHIFT-3
+        ;;
+(p6)   dep r17=3Dr18,r19,3,(PAGE_SHIFT-3)      // ppte=3Dpgd_offset for re=
gion 5
+(p7)   dep r17=3Dr18,r17,3,(PAGE_SHIFT-3)-3  // ppte=3Dpgd_offset for regi=
on[0-4]
+        cmp.eq p7,p6=3D0,r21                    // unused address bits all=
 zeroes?
+#ifdef CONFIG_PGTABLE_4
+        shr.u r18=3Dr22,PUD_SHIFT                 // shift pud index into =
position
+#else
+        shr.u r18=3Dr22,PMD_SHIFT                 // shift pmd index into =
position
+#endif
+        ;;
+        ld8 r17=3D[r17]                       // get *pgd (may be 0)
+        ;;
+(p7)   cmp.eq p6,p7=3Dr17,r0                 // was pgd_present(*pgd) =3D =
NULL?
+        dep r17=3Dr18,r17,3,(PAGE_SHIFT-3)    // ppte=3Dp[u|m]d_offset(pgd=
,addr)
+        ;;
+#ifdef CONFIG_PGTABLE_4
+(p7)   ld8 r17=3D[r17]                       // get *pud (may be 0)
+        shr.u r18=3Dr22,PMD_SHIFT                 // shift pmd index into =
position
+        ;;
+(p7)   cmp.eq.or.andcm p6,p7=3Dr17,r0        // was pud_present(*pud) =3D =
NULL?
+        dep r17=3Dr18,r17,3,(PAGE_SHIFT-3)    // ppte=3Dpmd_offset(pud,add=
r)
+        ;;
+#endif
+(p7)   ld8 r17=3D[r17]                       // get *pmd (may be 0)
+        shr.u r19=3Dr22,PAGE_SHIFT                // shift pte index into =
position
+        ;;
+(p7)   cmp.eq.or.andcm p6,p7=3Dr17,r0        // was pmd_present(*pmd) =3D =
NULL?
+       dep r17=3Dr19,r17,3,(PAGE_SHIFT-3)    // ppte=3Dpte_offset(pmd,addr)
+	;;
+(p7)    ld8 r18=3D[r17]
+        ;;
+(p7)    tbit.z p6,p0=3Dr18,_PAGE_P_BIT           /* page present bit clear=
ed? */
+(p6)    br.cond.spnt page_fault
+// insert vhpt mapping
+        mov r22=3Dcr.iha
+        mov r26=3Dcr.itir
+        ;;
+        tpa r22=3Dr22         /* make hash address physical */
+        ttag r25=3Dr16
+        ;;
+        add r24=16,r22
+        ;;
+        st8 [r22]=3Dr18,8      /* fill out VHPT entry */
+        st8 [r24]=3Dr25,8
+        ;;
+        st8 [r22]=3Dr26,8
+        st8 [r24]=3Dr17
+//insert actual translation
+	;;
+	itc.d r18
+        ;;
+#ifdef CONFIG_SMP
+        /*
+         * Tell the assemblers dependency-violation checker that the above=
 "itc" instructions
+         * cannot possibly affect the following loads:
+         */
+        dv_serialize_data
+
+        ld8 r19=3D[r17]                           // read *pte again and s=
ee if same
+        mov r20=3DPAGE_SHIFT<<2                   // setup page size for p=
urge
+        ;;
+        cmp.ne p7,p0=3Dr18,r19
+        ;;
+(p7)	dep r25=3D-1,r0,63,1      /* set tag-invalid bit */
+	;;
+(p7)	st8 [r22]=3Dr25         /* hpte already points to tag (see above) */
+(p7)    ptc.l r16,r20
+#endif
+        mov pr=3Dr31,-1
+        rfi
+__end_dtlb_miss_handler__
+
+// nested_dtlb_miss
+__begin_nested_dtlb_miss_handler__
+// This fault can not happen with long format VHPT
+	FAULT(5)
+__end_nested_dtlb_miss_handler__
+
+// dirty bit
+__begin_dirty_bit_handler__
+	mov r16=3Dcr.ifa				// get the address that caused the fault
+	mov r29=B0				// save b0 for nested fault (XXX)
+	mov r31=3Dpr				// save pr
+	/*
+	 * we try to find the address via the VHPT, if not fall back to
+	 * dtlb_fault.
+	 */
+	;;
+        thash r28=3Dr16
+        rsm psr.dt
+        ;;
+        tpa r22=3Dr28           			// make hash address physical
+        ttag r25=3Dr16
+        ;;
+        srlz.d
+        add r24=16,r22
+        add r17$,r22
+        ;;
+        ld8 r26=3D[r24]           		// load tag
+        ld8 r17=3D[r17]
+        ;;
+        cmp.ne p6,p7=3Dr26, r25   		// verify tag
+        ;;
+(p7)    ld8 r18=3D[r17]
+        ;;
+(p6)    mov cr.iha=3Dr28          		// set cr.iha only if we are going to =
take
+(p6)    br.cond.spnt .dtlb_fault 		// the failfn fault - it depends on it.
+#ifdef CONFIG_SMP
+	mov r28=3Dar.ccv				// save ar.ccv
+	;;
+	mov ar.ccv=3Dr18				// set compare value for cmpxchg
+	or r25=3D_PAGE_D|_PAGE_A,r18		// set the dirty and accessed bits
+	tbit.z p7,p6 =3D r18,_PAGE_P_BIT		// Check present bit
+	;;
+(p6)	cmpxchg8.acq r26=3D[r17],r25,ar.ccv	// Only update if page is present
+	mov r24=3DPAGE_SHIFT<<2
+	;;
+(p6)	cmp.eq p6,p7=3Dr26,r18			// Only compare if page is present
+	;;
+(p6)    st8 [r22]=3Dr18,16			// update VHPT
+(p6)	itc.d r25				// install updated PTE
+	;;
+	/*
+	 * Tell the assemblers dependency-violation checker that the above "itc" =
instructions
+	 * cannot possibly affect the following loads:
+	 */
+	dv_serialize_data
+
+	ld8 r18=3D[r17]				// read PTE again
+	;;
+	cmp.eq p6,p7=3Dr18,r25			// is it same as the newly installed
+	;;
+(p7)	dep r25=3D-1,r0,63,1      		// set tag-invalid bit
+	;;
+(p7)	st8 [r22]=3Dr25         			// hpte already points to tag (see above)
+(p7)	ptc.l r16,r24
+	mov b0=3Dr29				// restore b0
+	mov ar.ccv=3Dr28
+#else
+	;;
+	or r18=3D_PAGE_D|_PAGE_A,r18		// set the dirty and accessed bits
+	mov b0=3Dr29				// restore b0
+	;;
+	st8 [r17]=3Dr18				// store back updated PTE
+(p0)	st8 [r22]=3Dr18,16			// update VHPT (p0 set from dtlb_fault)
+	itc.d r18				// install updated PTE
+#endif
+	mov pr=3Dr31,-1				// restore pr
+	rfi
+__end_dirty_bit_handler__
+
+// iaccess bit
+__begin_iaccess_bit_handler__
+	// Like dirty bit handler, except for instruction access
+	mov r16=3Dcr.ifa				// get the address that caused the fault
+	mov r29=B0
+	mov r31=3Dpr				// save predicates
+	;;
+	/*
+	 * we try to find the address via the VHPT, if not fall back to
+	 * dtlb_fault.
+	 */
+        thash r28=3Dr16
+        rsm psr.dt
+        ;;
+        tpa r22=3Dr28           			// make hash address physical
+        ttag r25=3Dr16
+        ;;
+        srlz.d
+        add r24=16,r22
+        add r17$,r22
+        ;;
+        ld8 r26=3D[r24]           		// load tag
+        ld8 r17=3D[r17]
+        ;;
+        cmp.ne p6,p7=3Dr26, r25   		// verify tag
+        ;;
+(p7)    ld8 r18=3D[r17]
+        ;;
+(p6)    mov cr.iha=3Dr28          		// set cr.iha only if we are going to =
take
+(p6)    br.cond.spnt .itlb_fault 		// the failfn fault - it depends on it.
+#ifdef CONFIG_ITANIUM
+	/*
+	 * Erratum 10 (IFA may contain incorrect address) has "NoFix" status.
+	 */
+	mov r17=3Dcr.ipsr
+	;;
+	mov r18=3Dcr.iip
+	tbit.z p6,p0=3Dr17,IA64_PSR_IS_BIT	// IA64 instruction set?
+	;;
+(p6)	mov r16=3Dr18				// if so, use cr.iip instead of cr.ifa
+#endif /* CONFIG_ITANIUM */
+	;;
+	mov b0=3Dr29				// restore b0
+#ifdef CONFIG_SMP
+	mov r28=3Dar.ccv				// save ar.ccv
+	;;
+	mov ar.ccv=3Dr18				// set compare value for cmpxchg
+	or r25=3D_PAGE_A,r18			// set the accessed bit
+	tbit.z p7,p6 =3D r18,_PAGE_P_BIT	 	// Check present bit
+	;;
+(p6)	cmpxchg8.acq r26=3D[r17],r25,ar.ccv	// Only if page present
+	mov r24=3DPAGE_SHIFT<<2
+	;;
+(p6)	cmp.eq p6,p7=3Dr26,r18			// Only if page present
+	;;
+(p6)	st8 [r22]=3Dr18,16			// update VHPT
+(p6)	itc.i r25				// install updated PTE
+	;;
+	/*
+	 * Tell the assemblers dependency-violation checker that the above "itc" =
instructions
+	 * cannot possibly affect the following loads:
+	 */
+	dv_serialize_data
+
+	ld8 r18=3D[r17]				// read PTE again
+	;;
+	cmp.eq p6,p7=3Dr18,r25			// is it same as the newly installed
+	;;
+(p7)	dep r25=3D-1,r0,63,1      		// set tag-invalid bit
+	;;
+(p7)	st8 [r22]=3Dr25         			// hpte already points to tag (see above)
+(p7)	ptc.l r16,r24
+	mov b0=3Dr29				// restore b0
+	mov ar.ccv=3Dr28
+#else /* !CONFIG_SMP */
+	;;
+	or r18=3D_PAGE_A,r18			// set the accessed bit
+	mov b0=3Dr29				// restore b0
+	;;
+	st8 [r17]=3Dr18				// store back updated PTE
+(p0)	st8 [r22]=3Dr18,16			// update VHPT (p0 from itlb_miss)
+	itc.i r18				// install updated PTE
+#endif /* !CONFIG_SMP */
+	mov pr=3Dr31,-1
+	rfi
+__end_iaccess_bit_handler__
+
+// daccess bit
+__begin_daccess_bit_handler__
+	// Like dirty bit handler, except for data access
+	mov r16=3Dcr.ifa				// get the address that caused the fault
+	mov r29=B0
+	mov r31=3Dpr				// save predicates
+	;;
+	/*
+	 * we try to find the address via the VHPT, if not fall back to
+	 * dtlb_fault.
+	 */
+	;;
+        thash r28=3Dr16
+        rsm psr.dt
+        ;;
+        tpa r22=3Dr28           			// make hash address physical
+        ttag r25=3Dr16
+        ;;
+        srlz.d
+        add r24=16,r22
+        add r17$,r22
+        ;;
+        ld8 r26=3D[r24]           		// load tag
+        ld8 r17=3D[r17]
+        ;;
+        cmp.ne p6,p7=3Dr26, r25   		// verify tag
+        ;;
+(p7)    ld8 r18=3D[r17]
+        ;;
+(p6)    mov cr.iha=3Dr28          		// set cr.iha only if we are going to =
take
+(p6)    br.cond.spnt .dtlb_fault 		// the failfn fault - it depends on it.
+#ifdef CONFIG_SMP
+	mov r28=3Dar.ccv				// save ar.ccv
+	;;
+	mov ar.ccv=3Dr18				// set compare value for cmpxchg
+	or r25=3D_PAGE_A,r18			// set the accessed bit
+	tbit.z p7,p6 =3D r18,_PAGE_P_BIT	 	// Check present bit
+	;;
+(p6)	cmpxchg8.acq r26=3D[r17],r25,ar.ccv	// Only if page present
+	mov r24=3DPAGE_SHIFT<<2
+	;;
+(p6)	cmp.eq p6,p7=3Dr26,r18			// Only if page present
+	;;
+(p6)	st8 [r22]=3Dr18,16			// update VHPT
+(p6)	itc.d r25				// install updated PTE
+	;;
+	/*
+	 * Tell the assemblers dependency-violation checker that the above "itc" =
instructions
+	 * cannot possibly affect the following loads:
+	 */
+	dv_serialize_data
+
+	ld8 r18=3D[r17]				// read PTE again
+	;;
+	cmp.eq p6,p7=3Dr18,r25			// is it same as the newly installed
+	;;
+(p7)	dep r25=3D-1,r0,63,1      		// set tag-invalid bit
+	;;
+(p7)	st8 [r22]=3Dr25         			// hpte already points to tag (see above)
+(p7)	ptc.l r16,r24
+	mov b0=3Dr29				// restore b0
+	mov ar.ccv=3Dr28
+#else /* !CONFIG_SMP */
+	;;
+	or r18=3D_PAGE_A,r18			// set the accessed bit
+	mov b0=3Dr29				// restore b0
+	;;
+	st8 [r17]=3Dr18				// store back updated PTE
+(p0)	st8 [r22]=3Dr18,16			// update VHPT (p0 from itlb_miss)
+	itc.i r18				// install updated PTE
+#endif /* !CONFIG_SMP */
+	mov pr=3Dr31,-1
+	rfi
+__end_daccess_bit_handler__
Index: linux-2.6.17-rc3-lvhpt-v2-fresh/arch/ia64/Kconfig
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.17-rc3-lvhpt-v2-fresh.orig/arch/ia64/=
Kconfig	2006-05-05 10:02:39.000000000 +1000
+++ linux-2.6.17-rc3-lvhpt-v2-fresh/arch/ia64/Kconfig	2006-05-05 10:12:36.0=
00000000 +1000
@@ -374,6 +374,16 @@
 	def_bool y
 	depends on NEED_MULTIPLE_NODES
=20
+config IA64_LONG_FORMAT_VHPT
+ 	bool "Long format VHPT"
+ 	depends on !DISABLE_VHPT
+ 	help
+ 	  The long format VHPT is an alternative hashed page table.
+	  It is more TLB friendly, but less cache friendly.  By its
+	  self this may have a negative, neutral, or positive impact
+	  on performance, depending on your workloads.  If you're
+	  unsure, answer N and keep the default short-format VHPT.
+
 config IA32_SUPPORT
 	bool "Support for Linux/x86 binaries"
 	help
