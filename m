From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 12 Oct 2001 01:11:23 +0000
Subject: Re: [Linux-ia64] Probable seamless bug: can't pop es
Message-Id: <marc-linux-ia64-105590698805338@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805337@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805337@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 11 Oct 2001 17:19:32 -0700, "Robboy, David G" <david.g.robboy@intel.com> said:

  David.R> The following simple program runs on a P4 linux system, but
  David.R> gets a SIGSEGV on an Itanium.  Most likely a seamless bug
  David.R> rather than a hardware bug.  Even though we don't use
  David.R> segment registers in Linux, it is legal to push and pop
  David.R> them, isn't it?

Actually, even segmentation is supported (via modify_ldt()), so the
program should work.  GDB says it dies on the "popl" instruction.  The
address that triggering the fault is 0x4c.  I don't see where this is
coming from.  My suspicion is that the segv happens when the CPU
attempts to load the segment descriptor from the GDT, but if that's
the case, the address should be somewhere in the 0xc0000000 range.
Another possibility is that the GDTD is not set up properly, but I
don't see anything obvious that's wrong there.

Perhaps someone more familiar with x86 could take a look?

	--david

