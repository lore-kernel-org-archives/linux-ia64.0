From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 30 Jan 2003 00:23:46 +0000
Subject: [Linux-ia64] Re: Confused about fsystemcalls
Message-Id: <marc-linux-ia64-105590709805775@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 30 Jan 2003 11:07:51 +1100, Peter Chubb <peter@chubb.wattle.id.au> said:

  Peter> The mygetpid() call appears to return the correct value.

  Peter> Our figures show over an average of ten runs: --- glibc
  Peter> getpid() takes 579 cycles, stddev 24 --- mygetpid takes 1468
  Peter> cycles, stddev 286

Have you tried on a McKinley?  The numbers you quote for the standard
getpid() look like for Merced.  I never tried on Merced, though I
don't know of why it shouldn't work fast, off hand.

  Peter> I was also a little confused about the entry put into the ELF
  Peter> AUX vector -- was the value or the user-space address of
  Peter> syscall_via_epc meant to go into the vector?  Currently it
  Peter> says in include/asm-ia64/elf.h

Oh, it was broken.  I just fixed it today (since I got glibc to work
with the new syscall stub) and it's in the lia64 bk tree now.

	--david

