From: Ashok Raj <ashok.raj@intel.com>
Date: Wed, 09 Feb 2005 17:53:21 +0000
Subject: Re: [PATCH] CPU hotplug returns CPUs to SAL
Message-Id: <20050209095321.A30221@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1107970828.5478.22.camel@tdi>
In-Reply-To: <1107970828.5478.22.camel@tdi>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Wed, Feb 09, 2005 at 09:40:28AM -0800, Alex Williamson wrote:

Hi Alex

In fact i did submit a patch for this about a month ago. I was sharing some
code from mca side for tlb purge, and this code has been in the swamp for=20
several weeks now. I hope they are settled now, and  i will re submit my=20
patches once again.

link from old post

http://marc.theaimsgroup.com/?l=3Dlinux-ia64&m=110239954713260&w=3D2

I will repost to match whats there in tony-'s test/release tree asap.

ashok
>=20
>        When  a  CPU  is sent offline, it currently goes into a dummy spin
>    loop
>    and  pretends  to be gone.  This patch returns the CPU back to SAL via
>    the
>    mechanism described in the SAL spec.  The state of secondary CPUs is
>    saved off to a dynamically allocated stack for use on return to SAL.
>    I've munged the _start code in head.S to avoid trampling over some of
>    the preserved registers before we get a chance to save them.  The
>    assembly could probably use some optimizations, but these are hardly
>    performance paths.  It seems to work reliably on zx1 and sx1000 boxes,
>    but needs some exposure on others.  Patch against current bk.  Thanks,
>=20
>            Alex
>=20
>    --
>    Signed-off-by: Alex Williamson <alex.williamson@hp.com>
>=20
>    =3D=3D=3D arch/ia64/kernel/head.S 1.31 vs edited =3D=3D>    --- 1.31/a=
rch/ia64/kernel/head.S        2005-01-28 16:50:13 -07:00
>    +++ edited/arch/ia64/kernel/head.S      2005-02-09 09:32:04 -07:00
>    @@ -63,6 +63,14 @@
>            ;;
>            srlz.i
>            ;;
>    +
>    +       /*
>    +        * Store SAL gp, sp and tp so we don't clobber them
>    +        */
>    +       mov r31=3Dr1
>    +       mov r30=3Dr12
>    +       mov r29=3Dr13
>    +
>            /*
>             * Initialize kernel region registers:
>             *      rr[0]: VHPT enabled, page size =3D PAGE_SHIFT
>    @@ -76,31 +84,65 @@
>             * We initialize all of them to prevent inadvertently assuming
>              *  something about the state of address translation early in
>    boot.
>             */
>    -        mov  r6=3D((ia64_rid(IA64_REGION_ID_KERNEL,  (0<<61))  <<  8)=
 |
>    (PAGE_SHIFT << 2) | 1)
>    -       movl r7=3D(0<<61)
>    -        mov  r8=3D((ia64_rid(IA64_REGION_ID_KERNEL,  (1<<61))  <<  8)=
 |
>    (PAGE_SHIFT << 2) | 1)
>    -       movl r9=3D(1<<61)
>    -        mov  r10=3D((ia64_rid(IA64_REGION_ID_KERNEL,  (2<<61))  << 8)=
 |
>    (PAGE_SHIFT << 2) | 1)
>    -       movl r11=3D(2<<61)
>    +        mov  r9=3D((ia64_rid(IA64_REGION_ID_KERNEL,  (0<<61))  <<  8)=
 |
>    (PAGE_SHIFT << 2) | 1)
>    +        mov  r10=3D((ia64_rid(IA64_REGION_ID_KERNEL,  (1<<61))  << 8)=
 |
>    (PAGE_SHIFT << 2) | 1)
>    +        mov  r11=3D((ia64_rid(IA64_REGION_ID_KERNEL,  (2<<61))  << 8)=
 |
>    (PAGE_SHIFT << 2) | 1)
>             mov  r12=3D((ia64_rid(IA64_REGION_ID_KERNEL,  (3<<61))  << 8)=
 |
>    (PAGE_SHIFT << 2) | 1)
>    -       movl r13=3D(3<<61)
>    -        mov  r14=3D((ia64_rid(IA64_REGION_ID_KERNEL,  (4<<61))  << 8)=
 |
>    (PAGE_SHIFT << 2) | 1)
>    -       movl r15=3D(4<<61)
>    -        mov  r16=3D((ia64_rid(IA64_REGION_ID_KERNEL,  (5<<61))  << 8)=
 |
>    (PAGE_SHIFT << 2) | 1)
>    -       movl r17=3D(5<<61)
>    -        mov  r18=3D((ia64_rid(IA64_REGION_ID_KERNEL,  (6<<61))  << 8)=
 |
>    (IA64_GRANULE_SHIFT << 2))
>    -       movl r19=3D(6<<61)
>    -        mov  r20=3D((ia64_rid(IA64_REGION_ID_KERNEL,  (7<<61))  << 8)=
 |
>    (IA64_GRANULE_SHIFT << 2))
>    -       movl r21=3D(7<<61)
>    -       ;;
>    -       mov rr[r7]=3Dr6
>    -       mov rr[r9]=3Dr8
>    -       mov rr[r11]=3Dr10
>    -       mov rr[r13]=3Dr12
>    -       mov rr[r15]=3Dr14
>    -       mov rr[r17]=3Dr16
>    -       mov rr[r19]=3Dr18
>    -       mov rr[r21]=3Dr20
>    +        mov  r13=3D((ia64_rid(IA64_REGION_ID_KERNEL,  (4<<61))  << 8)=
 |
>    (PAGE_SHIFT << 2) | 1)
>    +        mov  r14=3D((ia64_rid(IA64_REGION_ID_KERNEL,  (5<<61))  << 8)=
 |
>    (PAGE_SHIFT << 2) | 1)
>    +        mov  r15=3D((ia64_rid(IA64_REGION_ID_KERNEL,  (6<<61))  << 8)=
 |
>    (IA64_GRANULE_SHIFT << 2))
>    +        mov  r16=3D((ia64_rid(IA64_REGION_ID_KERNEL,  (7<<61))  << 8)=
 |
>    (IA64_GRANULE_SHIFT << 2))
>    +
>    +       /*
>    +        * Original SAL RRs stored in r8-r15 for later use
>    +        */
>    +       movl r2=3D(0<<61)
>    +       ;;
>    +       mov r8=3Drr[r2]
>    +       ;;
>    +       mov rr[r2]=3Dr9
>    +       ;;
>    +       movl r2=3D(1<<61)
>    +       ;;
>    +       mov r9=3Drr[r2]
>    +       ;;
>    +       mov rr[r2]=3Dr10
>    +       ;;
>    +       movl r2=3D(2<<61)
>    +       ;;
>    +       mov r10=3Drr[r2]
>    +       ;;
>    +       mov rr[r2]=3Dr11
>    +       ;;
>    +       movl r2=3D(3<<61)
>    +       ;;
>    +       mov r11=3Drr[r2]
>    +       ;;
>    +       mov rr[r2]=3Dr12
>    +       ;;
>    +       movl r2=3D(4<<61)
>    +       ;;
>    +       mov r12=3Drr[r2]
>    +       ;;
>    +       mov rr[r2]=3Dr13
>    +       ;;
>    +       movl r2=3D(5<<61)
>    +       ;;
>    +       mov r13=3Drr[r2]
>    +       ;;
>    +       mov rr[r2]=3Dr14
>    +       ;;
>    +       movl r2=3D(6<<61)
>    +       ;;
>    +       mov r14=3Drr[r2]
>    +       ;;
>    +       mov rr[r2]=3Dr15
>    +       ;;
>    +       movl r2=3D(7<<61)
>    +       ;;
>    +       mov r15=3Drr[r2]
>    +       ;;
>    +       mov rr[r2]=3Dr16
>            ;;
>            /*
>             * Now pin mappings into the TLB for kernel text and data
>    @@ -141,6 +183,12 @@
>            rfi
>            ;;
>     1:     // now we are in virtual mode
>    +
>    +       /*
>    +        * Preserved CR/ARs for return to SAL before clobbering
>    +        */
>    +       mov r27=3Dcr.iva
>    +       mov r26=3Dar.fpsr
>=20
>            // set IVT entry point---can't access I/O ports without it
>            movl r3=3Dia64_ivt
>    @@ -154,8 +202,8 @@
>            mov ar.fpsr=3Dr2
>            ;;
>=20
>    -#define isAP   p2      // are we an Application Processor?
>    -#define isBP   p3      // are we the Bootstrap Processor?
>    +#define isAP   p6      // are we an Application Processor?
>    +#define isBP   p7      // are we the Bootstrap Processor?
>=20
>     #ifdef CONFIG_SMP
>            /*
>    @@ -170,6 +218,169 @@
>            cmp.eq isBP,isAP=3Dr3,r0
>            ;;
>     (isAP) mov r2=3Dr3
>    +#ifdef CONFIG_HOTPLUG_CPU
>    +       /*
>    +        * Save SAL off information for possible return to SAL
>    +        */
>    +(isAP) movl r3=3Dsal_handoff_state
>    +       ;;
>    +(isAP) ld8 r3=3D[r3]
>    +       ;;
>    +(isBP) movl r3=3D0
>    +       ;;
>    +       cmp.eq p8,p9=3Dr3,r0      // Saving state predicated on p9
>    +       ;;
>    +       /* Branch registers 1-5 are preserved, 0 contains SAL re-entry
>    point */
>    +(p9)   mov r16=B0
>    +       ;;
>    +(p9)   st8 [r3]=3Dr16,8  // b0
>    +       ;;
>    +(p9)   mov r16=B1
>    +       ;;
>    +(p9)   st8 [r3]=3Dr16,8  // b1
>    +       ;;
>    +(p9)   mov r16=B2
>    +       ;;
>    +(p9)   st8 [r3]=3Dr16,8  // b2
>    +       ;;
>    +(p9)   mov r16=B3
>    +       ;;
>    +(p9)   st8 [r3]=3Dr16,8  // b3
>    +       ;;
>    +(p9)   mov r16=B4
>    +       ;;
>    +(p9)   st8 [r3]=3Dr16,8  // b4
>    +       ;;
>    +(p9)   mov r16=B5
>    +       ;;
>    +(p9)   st8 [r3]=3Dr16,8  // b5
>    +       ;;
>    +       /* Region registers are preserved */
>    +(p9)   st8 [r3]=3Dr8,8   // rr0
>    +       ;;
>    +(p9)   st8 [r3]=3Dr9,8   // rr1
>    +       ;;
>    +(p9)   st8 [r3]=3Dr10,8  // rr2
>    +       ;;
>    +(p9)   st8 [r3]=3Dr11,8  // rr3
>    +       ;;
>    +(p9)   st8 [r3]=3Dr12,8  // rr4
>    +       ;;
>    +(p9)   st8 [r3]=3Dr13,8  // rr5
>    +       ;;
>    +(p9)   st8 [r3]=3Dr14,8  // rr6
>    +       ;;
>    +(p9)   st8 [r3]=3Dr15,8  // rr7
>    +(p9)   mov r16=3Dpr
>    +       ;;
>    +(p9)   st8 [r3]=3Dr16,8  // predicates
>    +       ;;
>    +(p9)   mov r16=3Dar.bspstore
>    +       ;;
>    +(p9)   st8 [r3]=3Dr16,8  // ar.bspstore
>    +       ;;
>    +(p9)   mov r16=3Dar.rnat
>    +       ;;
>    +(p9)   st8 [r3]=3Dr16,8  // ar.rnat
>    +       ;;
>    +(p9)   mov r16=3Dar.unat
>    +       ;;
>    +(p9)   st8 [r3]=3Dr16,8  // ar.unat
>    +       ;;
>    +(p9)   st8 [r3]=3Dr26,8  // ar.fpsr
>    +       ;;
>    +(p9)   mov r16=3Dar.pfs
>    +       ;;
>    +(p9)   st8 [r3]=3Dr16,8  // ar.pfs
>    +       ;;
>    +(p9)   mov r16=3Dar.lc
>    +       ;;
>    +(p9)   st8 [r3]=3Dr16,8  // ar.lc
>    +       ;;
>    +(p9)   mov r16=3Dcr.dcr
>    +       ;;
>    +(p9)   st8 [r3]=3Dr16,8  // cr.dcr
>    +       ;;
>    +(p9)   st8 [r3]=3Dr27,8  // cr.iva
>    +       ;;
>    +(p9)   mov r16=3Dcr.pta
>    +       ;;
>    +(p9)   st8 [r3]=3Dr16,8  // cr.pta
>    +       ;;
>    +(p9)   mov r16=3Dcr.itv
>    +       ;;
>    +(p9)   st8 [r3]=3Dr16,8  // cr.itv
>    +       ;;
>    +(p9)   mov r16=3Dcr.pmv
>    +       ;;
>    +(p9)   st8 [r3]=3Dr16,8  // cr.pmv
>    +       ;;
>    +(p9)   mov r16=3Dcr.cmcv
>    +       ;;
>    +(p9)   st8 [r3]=3Dr16,8  // cr.cmcv
>    +       ;;
>    +(p9)   mov r16=3Dcr.lrr0
>    +       ;;
>    +(p9)   st8 [r3]=3Dr16,8  // cr.lrr0
>    +       ;;
>    +(p9)   mov r16=3Dcr.lrr1
>    +       ;;
>    +(p9)   st8 [r3]=3Dr16,8  // cr.lrr1
>    +       ;;
>    +(p9)   st8 [r3]=3Dr31,8  // gp
>    +       ;;
>    +(p9)   st8 [r3]=3Dr30,8  // sp
>    +       ;;
>    +(p9)   st8 [r3]=3Dr29,8  // tp
>    +       ;;
>    +(p9)   st8 [r3]=3Dr4,8   // gr4
>    +       ;;
>    +(p9)   st8 [r3]=3Dr5,8   // gr5
>    +       ;;
>    +(p9)   st8 [r3]=3Dr6,8   // gr6
>    +       ;;
>    +(p9)   st8 [r3]=3Dr7,8   // gr7
>    +       ;;
>    +(p9)   stf.spill.nta [r3]=F2,16
>    +       ;;
>    +(p9)   stf.spill.nta [r3]=F3,16
>    +       ;;
>    +(p9)   stf.spill.nta [r3]=F4,16
>    +       ;;
>    +(p9)   stf.spill.nta [r3]=F5,16
>    +       ;;
>    +(p9)   stf.spill.nta [r3]=F16,16
>    +       ;;
>    +(p9)   stf.spill.nta [r3]=F17,16
>    +       ;;
>    +(p9)   stf.spill.nta [r3]=F18,16
>    +       ;;
>    +(p9)   stf.spill.nta [r3]=F19,16
>    +       ;;
>    +(p9)   stf.spill.nta [r3]=F20,16
>    +       ;;
>    +(p9)   stf.spill.nta [r3]=F21,16
>    +       ;;
>    +(p9)   stf.spill.nta [r3]=F22,16
>    +       ;;
>    +(p9)   stf.spill.nta [r3]=F23,16
>    +       ;;
>    +(p9)   stf.spill.nta [r3]=F24,16
>    +       ;;
>    +(p9)   stf.spill.nta [r3]=F25,16
>    +       ;;
>    +(p9)   stf.spill.nta [r3]=F26,16
>    +       ;;
>    +(p9)   stf.spill.nta [r3]=F27,16
>    +       ;;
>    +(p9)   stf.spill.nta [r3]=F28,16
>    +       ;;
>    +(p9)   stf.spill.nta [r3]=F29,16
>    +       ;;
>    +(p9)   stf.spill.nta [r3]=F30,16
>    +       ;;
>    +(p9)   stf.spill.nta [r3]=F31,16
>    +#endif /* CONFIG_HOTPLUG_CPU */
>     #else
>            movl r2=3Dinit_task
>            cmp.eq isBP,isAP=3Dr0,r0
>    @@ -256,6 +467,263 @@
>     self:  hint @pause
>            br.sptk.many self               // endless loop
>     END(_start)
>    +
>    +#ifdef CONFIG_HOTPLUG_CPU
>    +GLOBAL_ENTRY(ia64_return_to_sal)
>    +       alloc r16=3Dar.pfs,2,0,0,0
>    +       ;;
>    +       mov ar.rsc=3D0    // place RSE in enforced lazy mode
>    +       ;;
>    +       flushrs
>    +       ;;
>    +       movl r16=3D(IA64_PSR_AC|IA64_PSR_BN)
>    +       ;;
>    +       br.call.sptk.many rp=3Dia64_switch_mode_phys // physical mode
>    +1:
>    +       /* Purge kernel TRs */
>    +       movl r16=3DKERNEL_START
>    +       mov r18=3DKERNEL_TR_PAGE_SHIFT<<2
>    +       ;;
>    +       ptr.i r16,r18
>    +       ptr.d r16,r18
>    +       ;;
>    +       srlz.i
>    +       ;;
>    +       srlz.d
>    +       ;;
>    +       /* Purge percpu TR */
>    +       movl r16=3DPERCPU_ADDR
>    +       mov r18=3DPERCPU_PAGE_SHIFT<<2
>    +       ;;
>    +       ptr.d r16,r18
>    +       ;;
>    +       srlz.d
>    +       ;;
>    +       /* Purge PAL TR - purge before getting here */
>    +       /* Purge stack TR */
>    +       mov r16=3DIA64_KR(CURRENT_STACK)
>    +       ;;
>    +       shl r16=3Dr16,IA64_GRANULE_SHIFT
>    +       movl r19=3DPAGE_OFFSET
>    +       ;;
>    +       add r16=3Dr19,r16
>    +       mov r18=3DIA64_GRANULE_SHIFT<<2
>    +       ;;
>    +       ptr.d r16,r18
>    +       ;;
>    +       srlz.i
>    +       ;;
>    +       mov r3=3Dr32
>    +       ;;
>    +       /* Branch registers 1-5 are preserved, 0 contains SAL re-entry
>    point */
>    +       ld8 r2=3D[r3],8   // b0
>    +       ;;
>    +       mov b0=3Dr2
>    +       ;;
>    +       ld8 r2=3D[r3],8   // b1
>    +       ;;
>    +       mov b1=3Dr2
>    +       ;;
>    +       ld8 r2=3D[r3],8   // b2
>    +       ;;
>    +       mov b2=3Dr2
>    +       ;;
>    +       ld8 r2=3D[r3],8   // b3
>    +       ;;
>    +       mov b3=3Dr2
>    +       ;;
>    +       ld8 r2=3D[r3],8   // b4
>    +       ;;
>    +       mov b4=3Dr2
>    +       ;;
>    +       ld8 r2=3D[r3],8   // b5
>    +       ;;
>    +       mov b5=3Dr2
>    +       ;;
>    +       /* Region registers are preserved */
>    +       ld8 r2=3D[r3],8   // rr0
>    +       movl r16=3D(0<<61)
>    +       ;;
>    +       mov rr[r16]=3Dr2
>    +       ;;
>    +       srlz.d
>    +       ;;
>    +       ld8 r2=3D[r3],8   // rr1
>    +       movl r16=3D(1<<61)
>    +       ;;
>    +       mov rr[r16]=3Dr2
>    +       ;;
>    +       srlz.d
>    +       ;;
>    +       ld8 r2=3D[r3],8   // rr2
>    +       movl r16=3D(2<<61)
>    +       ;;
>    +       mov rr[r16]=3Dr2
>    +       ;;
>    +       srlz.d
>    +       ;;
>    +       ld8 r2=3D[r3],8   // rr3
>    +       movl r16=3D(3<<61)
>    +       ;;
>    +       mov rr[r16]=3Dr2
>    +       ;;
>    +       srlz.d
>    +       ;;
>    +       ld8 r2=3D[r3],8   // rr4
>    +       movl r16=3D(4<<61)
>    +       ;;
>    +       mov rr[r16]=3Dr2
>    +       ;;
>    +       srlz.d
>    +       ;;
>    +       ld8 r2=3D[r3],8   // rr5
>    +       movl r16=3D(5<<61)
>    +       ;;
>    +       mov rr[r16]=3Dr2
>    +       ;;
>    +       srlz.d
>    +       ;;
>    +       ld8 r2=3D[r3],8   // rr6
>    +       movl r16=3D(6<<61)
>    +       ;;
>    +       mov rr[r16]=3Dr2
>    +       ;;
>    +       srlz.d
>    +       ;;
>    +       ld8 r2=3D[r3],8   // rr7
>    +       movl r16=3D(7<<61)
>    +       ;;
>    +       mov rr[r16]=3Dr2
>    +       ;;
>    +       srlz.d
>    +       ;;
>    +       ld8 r2=3D[r3],8   // predicates
>    +       ;;
>    +       mov pr=3Dr2,-1
>    +       ;;
>    +       ld8 r2=3D[r3],8   // ar.bspstore
>    +       ;;
>    +       mov ar.bspstore=3Dr2
>    +       ;;
>    +       ld8 r2=3D[r3],8   // ar.rnat
>    +       ;;
>    +       mov ar.rnat=3Dr2
>    +       ;;
>    +       ld8 r2=3D[r3],8   // ar.unat
>    +       ;;
>    +       mov ar.unat=3Dr2
>    +       ;;
>    +       ld8 r2=3D[r3],8   // ar.fpsr
>    +       ;;
>    +       mov ar.fpsr=3Dr2
>    +       ;;
>    +       ld8 r2=3D[r3],8   // ar.pfs
>    +       ;;
>    +       mov ar.pfs=3Dr2
>    +       ;;
>    +       ld8 r2=3D[r3],8   // ar.lc
>    +       ;;
>    +       mov ar.lc=3Dr2
>    +       ;;
>    +       ld8 r2=3D[r3],8   // cr.dcr
>    +       ;;
>    +       mov cr.dcr=3Dr2
>    +       ;;
>    +       ld8 r2=3D[r3],8   // cr.iva
>    +       ;;
>    +       mov cr.iva=3Dr2
>    +       ;;
>    +       ld8 r2=3D[r3],8   // cr.pta
>    +       ;;
>    +       mov cr.pta=3Dr2
>    +       ;;
>    +       ld8 r2=3D[r3],8   // cr.itv
>    +       ;;
>    +       mov cr.itv=3Dr2
>    +       ;;
>    +       ld8 r2=3D[r3],8   // cr.pmv
>    +       ;;
>    +       mov cr.pmv=3Dr2
>    +       ;;
>    +       ld8 r2=3D[r3],8   // cr.cmcv
>    +       ;;
>    +       mov cr.cmcv=3Dr2
>    +       ;;
>    +       ld8 r2=3D[r3],8   // cr.lrr0
>    +       ;;
>    +       mov cr.lrr0=3Dr2
>    +       ;;
>    +       ld8 r2=3D[r3],8   // cr.lrr1
>    +       ;;
>    +       mov cr.lrr1=3Dr2
>    +       ;;
>    +       ld8 gp=3D[r3],8   // gp
>    +       ;;
>    +       ld8 r12=3D[r3],8  // sp
>    +       ;;
>    +       ld8 r13=3D[r3],8  // tp
>    +       ;;
>    +       ld8 r4=3D[r3],8   // gr4
>    +       ;;
>    +       ld8 r5=3D[r3],8   // gr5
>    +       ;;
>    +       ld8 r6=3D[r3],8   // gr6
>    +       ;;
>    +       ld8 r7=3D[r3],8   // gr7
>    +       ;;
>    +       ldf.fill.nta f2=3D[r3],16
>    +       ;;
>    +       ldf.fill.nta f3=3D[r3],16
>    +       ;;
>    +       ldf.fill.nta f4=3D[r3],16
>    +       ;;
>    +       ldf.fill.nta f5=3D[r3],16
>    +       ;;
>    +       ldf.fill.nta f16=3D[r3],16
>    +       ;;
>    +       ldf.fill.nta f17=3D[r3],16
>    +       ;;
>    +       ldf.fill.nta f18=3D[r3],16
>    +       ;;
>    +       ldf.fill.nta f19=3D[r3],16
>    +       ;;
>    +       ldf.fill.nta f20=3D[r3],16
>    +       ;;
>    +       ldf.fill.nta f21=3D[r3],16
>    +       ;;
>    +       ldf.fill.nta f22=3D[r3],16
>    +       ;;
>    +       ldf.fill.nta f23=3D[r3],16
>    +       ;;
>    +       ldf.fill.nta f24=3D[r3],16
>    +       ;;
>    +       ldf.fill.nta f25=3D[r3],16
>    +       ;;
>    +       ldf.fill.nta f26=3D[r3],16
>    +       ;;
>    +       ldf.fill.nta f27=3D[r3],16
>    +       ;;
>    +       ldf.fill.nta f28=3D[r3],16
>    +       ;;
>    +       ldf.fill.nta f29=3D[r3],16
>    +       ;;
>    +       ldf.fill.nta f30=3D[r3],16
>    +       ;;
>    +       ldf.fill.nta f31=3D[r3],16
>    +       ;;
>    +       ssm psr.ic      // SAL wants ic=3D1
>    +       srlz.d
>    +       ;;
>    +#define CPU_DEAD       0x0007
>    +       mov r3=3DCPU_DEAD
>    +       ;;
>    +       st4 [r33]=3Dr3    // Ack Going offline
>    +       ;;
>    +       mf
>    +       ;;
>    +       br.ret.sptk.many b0
>    +END(ia64_return_to_sal)
>    +#endif /* CONFIG_HOTPLUG_CPU */
>=20
>     GLOBAL_ENTRY(ia64_save_debug_regs)
>            alloc r16=3Dar.pfs,1,0,0,0
>    =3D=3D=3D arch/ia64/kernel/process.c 1.73 vs edited =3D=3D>    --- 1.7=
3/arch/ia64/kernel/process.c     2005-01-22 15:19:21 -07:00
>    +++ edited/arch/ia64/kernel/process.c   2005-02-09 10:02:11 -07:00
>    @@ -199,28 +199,31 @@
>     /* We don't actually take CPU down, just spin without interrupts. */
>     static inline void play_dead(void)
>     {
>    -       extern void ia64_cpu_local_tick (void);
>    -       /* Ack it */
>    -       __get_cpu_var(cpu_state) =3D CPU_DEAD;
>    +       void *pal_vaddr =3D efi_get_pal_addr();
>    +
>    +       extern void ia64_return_to_sal (sal_handoff_state_t *, int *);
>    +       extern sal_handoff_state_t *sal_handoff_state;
>=20
>    -       /* We shouldn't have to disable interrupts while dead, but
>    -        * some interrupts just don't seem to go away, and this makes
>    -        * it "work" for testing purposes. */
>            max_xtp();
>            local_irq_disable();
>    -       /* Death loop */
>    -       while (__get_cpu_var(cpu_state) !=3D CPU_UP_PREPARE)
>    -               cpu_relax();
>    -
>    -       /*
>    -        * Enable timer interrupts from now on
>    -        * Not required if we put processor in SAL_BOOT_RENDEZ mode.
>    -        */
>            local_flush_tlb_all();
>    -       cpu_set(smp_processor_id(), cpu_online_map);
>    -       wmb();
>    -       ia64_cpu_local_tick ();
>    -       local_irq_enable();
>    +
>    +       if (pal_vaddr) {
>    +               /*
>    +                * Easier to purge PAL TR here
>    +                */
>    +               ia64_clear_ic();
>    +                         ia64_ptr(0x1,     GRANULEROUNDDOWN((unsigned
>    long)pal_vaddr),
>    +                        IA64_GRANULE_SHIFT);
>    +               ia64_srlz_i();
>    +       }
>    +
>    +                              ia64_return_to_sal((sal_handoff_state_t
>    *)__pa(sal_handoff_state),
>    +                          (int *)__pa(&__get_cpu_var(cpu_state)));
>    +
>    +       printk(KERN_ERR "CPU%d didn't die\n", smp_processor_id());
>    +       for (;;)
>    +               cpu_relax();
>     }
>     #else
>     static inline void play_dead(void)
>    =3D=3D=3D arch/ia64/kernel/smpboot.c 1.65 vs edited =3D=3D>    --- 1.6=
5/arch/ia64/kernel/smpboot.c     2005-01-22 14:13:47 -07:00
>    +++ edited/arch/ia64/kernel/smpboot.c   2005-02-09 09:32:05 -07:00
>    @@ -22,6 +22,7 @@
>     #include <linux/irq.h>
>     #include <linux/kernel.h>
>     #include <linux/kernel_stat.h>
>    +#include <linux/list.h>
>     #include <linux/mm.h>
>     #include <linux/notifier.h>
>     #include <linux/smp.h>
>    @@ -79,6 +80,14 @@
>=20
>     task_t *task_for_booting_cpu;
>=20
>    +#ifdef CONFIG_HOTPLUG_CPU
>    +/*
>    + * Info for return to SAL
>    + */
>    +sal_handoff_state_t *sal_handoff_state;
>    +static LIST_HEAD(sal_handoff_list);
>    +#endif
>    +
>     /*
>      * State for each CPU
>      */
>    @@ -297,6 +306,8 @@
>            cpu_set(cpuid, cpu_online_map);
>            unlock_ipi_calllock();
>=20
>    +       __get_cpu_var(cpu_state)=3DCPU_ONLINE;
>    +
>            smp_setup_percpu_timer();
>=20
>            ia64_mca_cmc_vector_setup();    /* Setup vector on AP */
>    @@ -398,6 +409,15 @@
>                    panic("failed fork for CPU %d", cpu);
>            task_for_booting_cpu =3D c_idle.idle;
>=20
>    +#ifdef CONFIG_HOTPLUG_CPU
>    +         sal_handoff_state   =3D   kmalloc(sizeof(sal_handoff_state_t=
),
>    GFP_KERNEL);
>    +       if (!sal_handoff_state)
>    +                 printk(KERN_ERR "Processor 0x%x/0x%x cannot save SAL
>    handoff "
>    +                               "state\n", cpu, sapicid);
>    +       else
>    +               memset(sal_handoff_state, 0,
>    sizeof(sal_handoff_state_t));
>    +#endif
>    +
>             Dprintk("Sending  wakeup  vector  %lu  to  AP  0x%x/0x%x.\n",
>    ap_wakeup_vector, cpu, sapicid);
>=20
>            platform_send_ipi(cpu, ap_wakeup_vector, IA64_IPI_DM_INT, 0);
>    @@ -419,6 +439,10 @@
>                       cpu_clear(cpu,  cpu_online_map);   /*  was  set  in
>    smp_callin() */
>                    return -EINVAL;
>            }
>    +#ifdef CONFIG_HOTPLUG_CPU
>    +       list_add(&sal_handoff_state->list, &sal_handoff_list);
>    +       sal_handoff_state =3D NULL;
>    +#endif
>            return 0;
>     }
>=20
>    @@ -590,6 +614,15 @@
>            if (cpu =3D 0)
>                    return -EBUSY;
>=20
>    +       /*
>    +        * Need a SAL state to restore
>    +        */
>    +       if (list_empty(&sal_handoff_list))
>    +               return -EBUSY;
>    +
>    +       sal_handoff_state =3D list_entry(sal_handoff_list.next,
>    +                                      sal_handoff_state_t, list);
>    +       list_del(&sal_handoff_state->list);
>            fixup_irqs();
>            local_flush_tlb_all();
>            printk ("Disabled cpu %u\n", smp_processor_id());
>    @@ -604,12 +637,14 @@
>                    /* They ack this in play_dead by setting CPU_DEAD */
>                    if (per_cpu(cpu_state, cpu) =3D CPU_DEAD)
>                    {
>    -                       /*
>    -                        * TBD: Enable this when physical removal
>    -                        * or when we put the processor is put in
>    -                        * SAL_BOOT_RENDEZ mode
>    -                        * cpu_clear(cpu, cpu_callin_map);
>    -                        */
>    +                       cpu_clear(cpu, cpu_callin_map);
>    +                       if (sal_handoff_state) {
>    +                               kfree(sal_handoff_state);
>    +                               sal_handoff_state =3D NULL;
>    +                       } else {
>    +                                   printk(KERN_ERR "CPU %u had no SAL
>    handoff "
>    +                                               "info\n", cpu);
>    +                       }
>                            return;
>                    }
>                    msleep(100);
>    =3D=3D=3D include/asm-ia64/sal.h 1.27 vs edited =3D=3D>    --- 1.27/in=
clude/asm-ia64/sal.h 2005-01-22 15:57:26 -07:00
>    +++ edited/include/asm-ia64/sal.h       2005-02-09 09:32:06 -07:00
>    @@ -640,6 +640,36 @@
>            u8 oem_data_pad[1024];
>     } ia64_err_rec_t;
>=20
>    +/* Return to SAL state and info */
>    +typedef struct sal_handoff_state {
>    +       u64 br[6];  /* restore 1-5, 0 is SAL entry point */
>    +       u64 rr[8];
>    +       u64 preds;
>    +       /* ARs */
>    +       u64 bspstore;
>    +       u64 rnat;
>    +       u64 unat;
>    +       u64 fpsr;
>    +       u64 pfs;
>    +       u64 lc;
>    +       /* CRs */
>    +       u64 dcr;
>    +       u64 iva;
>    +       u64 pta;
>    +       u64 itv;
>    +       u64 pmv;
>    +       u64 cmcv;
>    +       u64 lrr[2];
>    +       /* GRs */
>    +       u64 gp;
>    +       u64 sp;
>    +       u64 tp;
>    +       u64 gr[4];
>    +       /* FPs */
>    +       struct ia64_fpreg fp[20];
>    +       struct list_head list;
>    +} sal_handoff_state_t;
>    +
>     /*
>      * Now define a couple of inline functions for improved type checking
>      * and convenience.
>=20
>    -
>    To  unsubscribe from this list: send the line "unsubscribe linux-ia64"
>    in
>    the body of a message to majordomo@vger.kernel.org
>    More majordomo info at  [1]http://vger.kernel.org/majordomo-info.html
>=20
> References
>=20
>    1. http://vger.kernel.org/majordomo-info.html

--=20
Cheers,
Ashok Raj
- Linux OS & Technology Team
