From: "Jim Hull" <jim_hull@hp.com>
Date: Fri, 16 Feb 2001 19:12:16 +0000
Subject: RE: [Linux-ia64] Intermittent errors on mov rr
Message-Id: <marc-linux-ia64-105590693005162@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005157@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005157@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keith:

> I get intermittent errors in copy_mm+0x6b0, where it is setting the new
> region registers.  This only happens under high load, like compiling
> gcc.  I cannot see why IA64 is complaining here, any ideas?

The Reserved Register/Field fault occured on this instruction:

> 0xe000000000565496 copy_mm+0x6b6	     mov rr[r16]=r14

with:
r16 = 0
r14 = 0x04000039

There's no problem with r16.  Decoding r14, according to the Region
Register format, gives us:

rv     0
rid    0x040000
ps     14 (16K)
rv     0
ve     1

The fault happens because you are attempting to use a rid value which
requires 19 bits, but Itanium only supports 18-bit rids (the minimum
required by the architecture).  The implemented rid size is returned by
PAL_VM_SUMMARY, which you can examine with:

  cat /proc/pal/cpu0/vm_info | grep RR.rid

I know nothing about how IA-64 Linux manages rid values, whether it makes
use of the rid size field returned by PAL_VM_SUMMARY, etc., so I can't help
you any more than this.  Probably David Mosberger can track down the root
cause of this problem.

 -- Jim


