From: Bob Montgomery <bob.montgomery@hp.com>
Date: Mon, 28 Mar 2005 18:47:36 +0000
Subject: Re: Can't unwind through dispatch_illegal_op_fault
Message-Id: <1112035656.498.157.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1111801791.498.151.camel@localhost.localdomain>
In-Reply-To: <1111801791.498.151.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Sat, 2005-03-26 at 00:38 -0800, David Mosberger wrote:
> >>>>> On Fri, 25 Mar 2005 18:49:51 -0700, Bob Montgomery <bob.montgomery@=
hp.com> said:
>=20
>   Bob> I accidentally discovered that another good way for my buncho
>   Bob> crash test module to oops the system is to mov from ar.bspstore
>   Bob> without zeroing the mode bits on ar.rsc.  The resulting illegal
>   Bob> op doesn't unwind past dispatch_illegal_op_fault.
...
>=20
> Ah, dispatch_illegal_op_fault() is an oddball since after calling
> ia64_illegal_op_fault() it does some other work and returns to
> ia64_leave_kernel only at that point.  Because of that, it
> needs to have unwind info.  Hopefully all that it needs is
> a PT_REGS_UNWIND_INFO(0) after SAVE_REST.

That does make it unwind (see below), but at the expense of this message
in the make log:

ERROR: dispatch_illegal_op_fault: 156 slots, total region length =3D 16

Is it a reasonable patch?

Thanks,
Bob M.
----------------------

Call Trace:
 [<a000000100012940>] show_stack+0x80/0xa0
                                sp=E000000100fdf8d0 bsp=E000000100fd8fb8
 [<a0000001000131c0>] show_regs+0x800/0x820
                                sp=E000000100fdfaa0 bsp=E000000100fd8f60
    r32 : e000000100fdfc60 r33 : 0000000000000000 r34 : e000000100fdfd18
    r35 : e000000100fdfcd8 r36 : e000000100fdfcf0 r37 : e000000100fdfcb0
    r38 : e000000100fdfca0 r39 : 00000fffffffbfff r40 : a000000100036b50
    r41 : 000000000000040e r42 : e000000180fdfbde
 [<a000000100036b50>] die+0x150/0x2c0
                                sp=E000000100fdfab0 bsp=E000000100fd8f20
    r32 : e000000100fdfbe0 r33 : e000000100fdfc60 r34 : 0000000000000000
    r35 : a00000010067a1b8 r36 : a00000010067a1bc r37 : a000000100036d00
    r38 : 0000000000000309 r39 : a000000100570c08
 [<a000000100036d00>] die_if_kernel+0x40/0x60
                                sp=E000000100fdfb30 bsp=E000000100fd8ef0
    r32 : e000000100fdfbe0 r33 : e000000100fdfc60 r34 : 0000000000000000
    r35 : a0000001000376c0 r36 : 000000000000048c r37 : e000000100fdfde0
 [<a0000001000376c0>] ia64_illegal_op_fault+0x60/0x160
                                sp=E000000100fdfb30 bsp=E000000100fd8ea8
    r32 : e000000100fdfb60 r33 : 0000000000000000 r34 : e000000100fdfbe0
    r35 : a000000100974450 r36 : e000000100fd8000 r37 : 0000000000000015
    r38 : a000000100003f20 r39 : 0000000000000001 r40 : e000000100fdfde0
 [<a000000100003f20>] dispatch_illegal_op_fault+0x300/0x800
                                sp=E000000100fdfc50 bsp=E000000100fd8ea8
 [<a0000002000f8a40>] buncho_going_to_illegal_op+0x40/0xa0 [buncho]
                                sp=E000000100fdfe20 bsp=E000000100fd8e80
    r32 : a0000002000f8eb0 r33 : 0000000000000389 r34 : a0000002002f8000
    r35 : a0000002000f9940 r36 : 0000000000000000
 [<a0000002000f8eb0>] buncho_ioctl+0x410/0x420 [buncho]
                                sp=E000000100fdfe20 bsp=E000000100fd8e48
    r32 : e00000000567c158 r33 : e0000001015a4a00 r34 : 0000000000000072
    r35 : 0000000000000000 r36 : a000000100157fc0 r37 : 0000000000000895
    r38 : a0000002002f8000
 [<a000000100157fc0>] sys_ioctl+0x240/0x6c0
                                sp=E000000100fdfe20 bsp=E000000100fd8db8
    r32 : 0000000000000003 r33 : 0000000000000072 r34 : 0000000000000000
    r35 : 0000000000000002 r36 : 60000fffffffb9d8 r37 : 4000000000002780
    r38 : 4000000000002770 r39 : 200000000003a660 r40 : 0000000000000072
    r41 : a0000002000f8aa0 r42 : ffffffffffffffe7 r43 : e0000001015a4a00
    r44 : a0000002000fb000 r45 : a00000010000aba0 r46 : 0000000000000008
    r47 : a000000100974450 r48 : 0000000000168359
 [<a00000010000aba0>] ia64_ret_from_syscall+0x0/0x20
                                sp=E000000100fdfe30 bsp=E000000100fd8db8





