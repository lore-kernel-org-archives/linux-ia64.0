From: Bob Montgomery <bob.montgomery@hp.com>
Date: Fri, 11 Mar 2005 21:19:49 +0000
Subject: Re: [RFC] Enhanced show_stack output to add backing store regs
Message-Id: <1110575989.498.89.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1110566404.498.79.camel@localhost.localdomain>
In-Reply-To: <1110566404.498.79.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Fri, 2005-03-11 at 12:59 -0800, David Mosberger wrote:
> >>>>> On Fri, 11 Mar 2005 20:25:26 +0000, Matthew Wilcox <matthew@wil.cx>=
 said:
>=20
>   Matthew> I know your patch leaaves this unchanged, but I don't think it=
's helpful
>   Matthew> to show the 'show_stack' and 'show_regs' frames.  Can we get r=
id of them,
>   Matthew> or is there a reason they're useful?
>=20
> There were useful in the early days, when I didn't trust the unwinder... =
;-)
> I agree that we should drop them.  Just unwind to the interruption-frame
> (pt_regs), then start printing the frames.
>=20
> That'll also be more in line with the other arches.


You might trust the unwinder, and that *might* be a reason to lop off
the top two (show regs and show stack), but I still want to see what
kernel handler was used, and it's still reassuring to be able to check
at show_stack to verify that bsp < sp to eliminate stack overflow as
the source of either the problem, or the problem with the unwinding that
follows.


I'm assuming in my example, that not printing until the interruption
frame would eliminate what is shown below, and I would like to keep
that:

 [<a000000100036b50>] die+0x150/0x280
                                sp=E0000001200dfb40 bsp=E0000001200d8f20
 [<a000000100036cc0>] die_if_kernel+0x40/0x60
                                sp=E0000001200dfb40 bsp=E0000001200d8ef0
 [<a0000001000378d0>] ia64_fault+0x150/0xac0
                                sp=E0000001200dfb40 bsp=E0000001200d8ea8
 [<a00000010000ad20>] ia64_leave_kernel+0x0/0x260
                                sp=E0000001200dfc40 bsp=E0000001200d8ea8

and not just see the stack top out at
=20
 [<a0000002000689d0>] buncho_going_to_regnat+0x50/0xa0 [buncho]
                                sp=E0000001200dfe10 bsp=E0000001200d8e80
...

where the error occurred.

--=20
Bob Montgomery <bob.montgomery@hp.com>

