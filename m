From: Keith Owens <kaos@melbourne.sgi.com>
Date: Wed, 21 Mar 2001 06:03:00 +0000
Subject: Re: [Linux-ia64] Unwind problem for __attribute__ noreturn
Message-Id: <marc-linux-ia64-105590693005309@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005303@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005303@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Tue, 20 Mar 2001 13:10:16 +1100,=20
Keith Owens <kaos@melbourne.sgi.com> wrote:
>panic() is defined as __attribute__ ((noreturn)).  Either gcc is
>generating invalid unwind data for this attribute or the kernel unwind
>code is mishandling the data.

Replying to my own mail.  It is a fencepost problem caused by gcc
discarding code after a call to a noreturn function.  The user that hit
this problem wanted an unconditional panic when scsi_malloc was called
so he inserted panic("testing\n") into scsi_malloc().  gcc recognised
that the rest of scsi_malloc could never be reached and discarded all
the following code.  The generated object contains

e0000000007c0ea0 <scsi_malloc>:
e0000000007c0ea0:       01 08 0d 04 80 05       [MII]       alloc r33=3Dar.=
pfs,3,2,0
e0000000007c0ea6:       20 82 f6 d7 4f 00                   addl r34=3D-260=
8,r1
e0000000007c0eac:       04 00 c4 00                         mov r32=B0;;
e0000000007c0eb0:       11 10 01 44 18 10       [MIB]       ld8 r34=3D[r34]
e0000000007c0eb6:       00 00 00 02 00 00                   nop.i 0x0
e0000000007c0ebc:       58 67 e2 58                         br.call.sptk.ma=
ny b0=E0000000005e7600 <panic>;;

e0000000007c0ec0 <scsi_free>:
e0000000007c0ec0:       00 18 15 08 80 05       [MII]       alloc r35=3Dar.=
pfs,5,4,0
e0000000007c0ec6:       20 02 00 62 00 00                   mov r34=B0
e0000000007c0ecc:       00 00 04 00                         nop.i 0x0

panic() called kdb, kdb used the unwind data to work out where panic
was called from.  Alas b0 is pointing at the first instruction of
scsi_free which completely confuses the unwinder.  Instead of unwinding
the body of scsi_malloc it tries to unwind the prologue of scsi_free
and gets gibberish.

My first thought was for the unwind code to adjust b0 to reflect where
the call instruction was issued, which would correctly pick up
scsi_malloc.  However bits of the kernel set b0 explicitly instead of
via call so adjusting b0 would not work in all cases.

The long term fix is for gcc to add nop after calls to non-return
functions.  That would preserve enough of a code body for the unwinder
to work correctly.  BTW this problem almost certainly affects gdb as
well as the kernel.  Jim, do you need a gcc change request for this?

The short term fix is to use conditional calls to panic() and other
routines marked as noreturn.  Make it conditional on something that you
know is true but the compiler cannot optimize away.  This works:

        if (current)
		panic("testing\n");

I will look at hacking kdb to recognise a panic call as a special case
and work around this problem.


