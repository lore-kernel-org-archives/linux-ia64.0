From: Russ Anderson <rja@sgi.com>
Date: Thu, 09 Dec 2004 04:15:57 +0000
Subject: Re: [patch] per cpu MCA/INIT save areas (take 2)
Message-Id: <200412090415.iB94FwxW091670@ben.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200411122327.iACNRR5h131335@ben.americas.sgi.com>
In-Reply-To: <200411122327.iACNRR5h131335@ben.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Keith Owens wrote:
> On Tue, 23 Nov 2004 17:36:41 -0600 (CST),=20
> Russ Anderson <rja@sgi.com> wrote:
> >--- tonyluck2.6.10.new.orig/linux/arch/ia64/kernel/mca_asm.S	2004-11-17 =
16:22:30.041624520 -0600
> >+++ tonyluck2.6.10.new/linux/arch/ia64/kernel/mca_asm.S	2004-11-23 13:49=
:27.631179608 -0600
>=20
> > 	rse_switch_context(r6,r3,r2);;	// RSC management in this new context
> >-	movl	r12=3Dia64_mca_stack
> >+
> >+	mov	r2=3Dr12;;		// phys addr of MCA save area
> >+	addl	r2=3DIA64_MCA_STACK,r2;;
> >+	mov	r12=3Dr2
> > 	mov	r2=3D8*1024;;		// stack size must be same as C array
> > 	add	r12=3Dr2,r12;;		// stack base @ bottom of array
> > 	adds	r12=3D-16,r12;;		// allow 16 bytes of scratch
> > 					// (C calling convention)
>=20
> Replace with mov r2=3DIA64_MCA_STACK+8*1024-16;; add r12=3Dr12,r2;; plus =
suitable comments.

Looking closer at the original code, r12 is converted to PA, but isn't used=
=20
after that, that I can see.  Could someone explain where r12 is used?


        // Setup new stack frame for OS_MCA handling
        movl    r2=3Dia64_mca_bspstore;;  // local bspstore area location i=
n r2
        DATA_VA_TO_PA(r2);;
        movl    r3=3Dia64_mca_stackframe;; // save stack frame to memory in=
 r3
        DATA_VA_TO_PA(r3);;
        rse_switch_context(r6,r3,r2);;  // RSC management in this new conte=
xt
        movl    r12=3Dia64_mca_stack
        mov     r2=3D8*1024;;             // stack size must be same as C a=
rray
        add     r12=3Dr2,r12;;            // stack base @ bottom of array
        adds    r12=3D-16,r12;;           // allow 16 bytes of scratch
                                        // (C calling convention)
        DATA_VA_TO_PA(r12);;

        // Enter virtual mode from physical mode
        VIRTUAL_MODE_ENTER(r2, r3, ia64_os_mca_virtual_begin, r4)
ia64_os_mca_virtual_begin:

        // Call virtual mode handler
        movl            r2=3Dia64_mca_ucmc_handler;;
        mov             b6=3Dr2;;
        br.call.sptk.many    b0=B6;;
.ret0:
        // Revert back to physical mode before going back to SAL
        PHYSICAL_MODE_ENTER(r2, r3, ia64_os_mca_virtual_end, r4)
ia64_os_mca_virtual_end:


Thanks,
--=20
Russ Anderson, OS RAS/Partitioning Project Lead =20
SGI - Silicon Graphics Inc          rja@sgi.com
