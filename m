From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 07 Aug 2003 02:37:03 +0000
Subject: Re: [lia64-sim] Simulator segfaults
Message-Id: <marc-linux-ia64-106022394409862@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 7 Aug 2003 09:51:44 +1000, Peter Chubb <peter@chubb.wattle.id.au> said:

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:
  Peter> however, I'd expect that attempting to execute an IA32
  Peter> instruction that wasn't implemented would generate an
  Peter> unimplemented instruction trap to the operating system, not
  Peter> cause a segfault.

  David> I agree the Ski behavior isn't pretty for this case, but I
  David> suspect we may have to just live with it.  AFAIK, nobody
  David> seriously cares about x86 emulation on Ski, because it's
  David> woefully incomplete at any rate (well, it may be useful for
  David> DOS-area programs, but certainly not for x86 Linux programs).

  Peter> Yes, well, I was trying to use it to work out how to fix IA32
  Peter> coredumps on the IA64 kernel --- curerntly an easy way to
  Peter> crash 2.6.0 is to run an IA32 program that segfaults.

Hmmh, I think Arun has patches to make ia32 core-dumps work.  Arun,
can you confirm?

	--david
