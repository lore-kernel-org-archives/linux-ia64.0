From: "Jim Hull" <jim.hull@hp.com>
Date: Fri, 19 Sep 2003 23:32:23 +0000
Subject: RE: Inefficient ia64 system call implementation in glibc
Message-Id: <marc-linux-ia64-106401435007961@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106398916511816@msgid-missing>
In-Reply-To: <marc-linux-ia64-106398916511816@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

John Worley wrote:

>      The real inefficiency here is the compiler output. Given the
> realities of the Itanium 2 implementation, the first two bundles
> will require 3 cycles to execute. A better coding would be:
>=20
> 	{	.mmi
> 		alloc	r36=3Dar.pfs,14,6,0
> 		mov	r15=1212
> 		mov	r35=B0
> 	}
> 	{	.mmi
> 		mov	r37=3Dr1
> 		mov	r39=3Dr34
> 		sxt4	r38=3Dr33
> 	} ;;
>=20
>      which will execute in one cycle. The sign extension, although
> "unnecessary" doesn't cost any cycles. Admittedly you could use the
> mi;;i bundle to pack the break instruction in the second bundle if
> you didn't have to sign-extend, but I'd rather see the 3 v. 1 cycle
> problem addressed first.

Hi John!

Your scheduling of this code is definitely better than the original.
One minor point:  Even if you could get the tools to understand that the
sign-extension is unnecessary, you still need to copy the input argument
to the output region (from r33 to r38 in this example), so you can't
eliminate any instructions and get better bundle packing.  The only
advantage the copy would have vs. the sxt is that it is an A-type
instruction, instead of I-type, which might save a cycle or so in some
other syscall stub that is sign-extending several int argument (as
opposed to the single one here).

But my real issue with the performance of this code is not with
sign-extend or the scheduling these instructions, it's with the break
instruction.  I may be mistaken, but hasn't it been many months since
David Mosberger implemented all the kernel infrastructure needed to
support syscalls using the epc instruction?  When will glibc be changed
to take advantage of this?  I would think that only after this has
happened should we worrying about squeezing out the last cycle or two of
overhead in the syscall stubs.

 -- Jim
    HP PA-RISC/Itanium Processor Architect

