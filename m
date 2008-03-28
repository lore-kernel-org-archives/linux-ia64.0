From: Akio Takebe <takebe_akio@jp.fujitsu.com>
Date: Fri, 28 Mar 2008 13:02:19 +0000
Subject: Re: [08/17][PATCH] kvm/ia64: Add interruption vector table for vmm.
Message-Id: <88C890D3F4B4D9takebe_akio@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDCFF7EF8@pdsmsx415.ccr.corp.intel.com>
In-Reply-To: <42DFA526FC41B1429CE7279EF83C6BDCFF7EF8@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: "Zhang, Xiantao" <xiantao.zhang@intel.com>, Avi Kivity <avi@qumranet.com>, "Luck, Tony" <tony.luck@intel.com>, "Xu, Anthony" <anthony.xu@intel.com>, Jes Sorensen <jes@sgi.com>, kv

Hi, Xiantao

a comments is below.


>+// 0x3000 Entry 12 (size 64 bundles) External Interrupt (4)
>+ENTRY(kvm_interrupt)
>+    mov r31=3Dpr		// prepare to save predicates
>+    mov r19=12
>+    mov r29=3Dcr.ipsr
>+    ;;
>+    tbit.z p6,p7=3Dr29,IA64_PSR_VM_BIT
>+    tbit.z p0,p15=3Dr29,IA64_PSR_I_BIT
>+    ;;
>+(p7) br.sptk kvm_dispatch_interrupt
>+    ;;
>+    mov r27=3Dar.rsc		/* M */
>+    mov r20=3Dr1			/* A */
>+    mov r25=3Dar.unat		/* M */
>+    mov r26=3Dar.pfs		/* I */
>+    mov r28=3Dcr.iip		/* M */
>+    cover			/* B (or nothing) */
>+    ;;
>+    mov r1=3Dsp
>+    ;;
>+    invala			/* M */
>+    mov r30=3Dcr.ifs
>+    ;;
>+    addl r1=3D-VMM_PT_REGS_SIZE,r1
>+    ;;
>+    adds r17=3D2*L1_CACHE_BYTES,r1	/* really: biggest cache-line
>size */
>+    adds r16=3DPT(CR_IPSR),r1
>+    ;;
>+    lfetch.fault.excl.nt1 [r17],L1_CACHE_BYTES
>+    st8 [r16]=3Dr29			/* save cr.ipsr */
>+    ;;
>+    lfetch.fault.excl.nt1 [r17]
>+    mov r29=B0
>+    ;;
>+    adds r16=3DPT(R8),r1  	/* initialize first base pointer */
>+    adds r17=3DPT(R9),r1  	/* initialize second base pointer */
>+    mov r18=3Dr0      		/* make sure r18 isn't NaT */
>+    ;;
>+.mem.offset 0,0; st8.spill [r16]=3Dr8,16
>+.mem.offset 8,0; st8.spill [r17]=3Dr9,16
>+        ;;
>+.mem.offset 0,0; st8.spill [r16]=3Dr10,24
>+.mem.offset 8,0; st8.spill [r17]=3Dr11,24
>+        ;;
>+    st8 [r16]=3Dr28,16		/* save cr.iip */
>+    st8 [r17]=3Dr30,16		/* save cr.ifs */
>+    mov r8=3Dar.fpsr		/* M */
>+    mov r9=3Dar.csd
>+    mov r10=3Dar.ssd
>+    movl r11=3DFPSR_DEFAULT	/* L-unit */
>+    ;;
>+    st8 [r16]=3Dr25,16		/* save ar.unat */
>+    st8 [r17]=3Dr26,16		/* save ar.pfs */
>+    shl r18=3Dr18,16		/* compute ar.rsc to be used for
>"loadrs" */
>+    ;;
>+    st8 [r16]=3Dr27,16		/* save ar.rsc */
>+    adds r17=16,r17		/* skip over ar_rnat field */
>+    ;;
>+    st8 [r17]=3Dr31,16		/* save predicates */
>+    adds r16=16,r16		/* skip over ar_bspstore field */
>+    ;;
>+    st8 [r16]=3Dr29,16		/* save b0 */
>+    st8 [r17]=3Dr18,16		/* save ar.rsc value for "loadrs" */
>+    ;;
>+.mem.offset 0,0; st8.spill [r16]=3Dr20,16    /* save original r1 */
>+.mem.offset 8,0; st8.spill [r17]=3Dr12,16
>+    adds r12=3D-16,r1
>+    /* switch to kernel memory stack (with 16 bytes of scratch) */
>+    ;;
>+.mem.offset 0,0; st8.spill [r16]=3Dr13,16
>+.mem.offset 8,0; st8.spill [r17]=3Dr8,16 /* save ar.fpsr */
>+    ;;
>+.mem.offset 0,0; st8.spill [r16]=3Dr15,16
>+.mem.offset 8,0; st8.spill [r17]=3Dr14,16
>+    dep r14=3D-1,r0,60,4
>+    ;;
>+.mem.offset 0,0; st8.spill [r16]=3Dr2,16
>+.mem.offset 8,0; st8.spill [r17]=3Dr3,16
>+    adds r2=3DVMM_PT_REGS_R16_OFFSET,r1
>+    adds r14 =3D VMM_VCPU_GP_OFFSET,r13
>+    ;;
>+    mov r8=3Dar.ccv
>+    ld8 r14 =3D [r14]
>+    ;;
>+    mov r1=3Dr14       /* establish kernel global pointer */
>+    ;;                                          \
>+    bsw.1
>+    ;;
>+    alloc r14=3Dar.pfs,0,0,1,0	// must be first in an insn group
>+    mov out0=3Dr13
>+    ;;
>+    ssm psr.ic
>+    ;;
>+    srlz.i
>+    ;;
>+    //(p15) ssm psr.i
Why do you comments out some ssm psr.i?
>+    adds r3=3D8,r2		// set up second base pointer for
>SAVE_REST
>+    srlz.i			// ensure everybody knows psr.ic is back
>on
Hmm, if the above ssm is not necessary, this srlz.i is also necessary.

Best Regards,

Akio Takebe

