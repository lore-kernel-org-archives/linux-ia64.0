From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 11 Mar 2005 21:23:14 +0000
Subject: Re: [RFC] Enhanced show_stack output to add backing store regs
Message-Id: <16946.3138.31881.366108@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1110566404.498.79.camel@localhost.localdomain>
In-Reply-To: <1110566404.498.79.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 11 Mar 2005 14:19:49 -0700, Bob Montgomery <bob.montgomery@hp=
.com> said:

  Bob> You might trust the unwinder, and that *might* be a reason to lop off
  Bob> the top two (show regs and show stack), but I still want to see what
  Bob> kernel handler was used, and it's still reassuring to be able to che=
ck
  Bob> at show_stack to verify that bsp < sp to eliminate stack overflow as
  Bob> the source of either the problem, or the problem with the unwinding =
that
  Bob> follows.

That's true.

  Bob> I'm assuming in my example, that not printing until the interruption
  Bob> frame would eliminate what is shown below, and I would like to keep
  Bob> that:

  Bob> [<a000000100036b50>] die+0x150/0x280
  Bob> sp=E0000001200dfb40 bsp=E0000001200d8f20
  Bob> [<a000000100036cc0>] die_if_kernel+0x40/0x60
  Bob> sp=E0000001200dfb40 bsp=E0000001200d8ef0
  Bob> [<a0000001000378d0>] ia64_fault+0x150/0xac0
  Bob> sp=E0000001200dfb40 bsp=E0000001200d8ea8
  Bob> [<a00000010000ad20>] ia64_leave_kernel+0x0/0x260
  Bob> sp=E0000001200dfc40 bsp=E0000001200d8ea8

  Bob> and not just see the stack top out at

  Bob> [<a0000002000689d0>] buncho_going_to_regnat+0x50/0xa0 [buncho]
  Bob> sp=E0000001200dfe10 bsp=E0000001200d8e80
  Bob> ...

  Bob> where the error occurred.

No, other arches start past the interrupt frame, i.e., you'd get the
latter output.

Stack-corruption is an important concern, I agree.  That's the only
reason I haven't gotten rid of the "sp" and "bsp" printing.

	--david
