From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 15 May 2001 15:11:54 +0000
Subject: RE: [Linux-ia64] Replacements for local_irq_xxx()
Message-Id: <marc-linux-ia64-105590693005579@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005562@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005562@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

  Keith> I have measured the slowdown and I believe that it is
  Keith> acceptable, expecially when the benefit is far better
  Keith> debugging and the ability to use an NMI watchdog.  The module
  Keith> below measures the cost of the existing method (rsm psr.i)
  Keith> and my replacement method using cr.tpr.mmi.  Using psr.i
  Keith> takes 8 cycles while using cr.tpr.mmi takes 109 cycles to
  Keith> disable then reenable interrupts.  Typical values on a BigSur
  Keith> dual B3 @ 700MHz, build 99.

Slowing down local_irq_xxx() by more than 13 times is certainly not
acceptable.  Definitely not for kdb.  Let me make this clear: ia64
linux is designed and optimized for the case of running ia64
applications on native hardware.  It's NOT optimized for running IA-32
binaries (though we do want to do that well, too), it's NOT optimized
for running in a virtual machine environment, it's NOT optimized for
running KDB, etc., etc.  I hope you get the idea: writing a lean and
mean kernel is the goal here.

Note that your performance assement pretty much ignored that a TPR
based interrupt masking scheme would result in significant code bloat.
This could easily make the difference between a tight loop fitting or
exceeding the i-cache size.  Also, I really don't like the argument
that just because kernel compiles slow down by "only" X seconds, it's
somehow OK to make a performance critical operation so much slower.  I
am not sure which macro-level benchmark would show the most impact,
but I do know that if interrupt masking takes >100 cycles, people WILL
come up with software-optimizations which will make the kernel more
complicated and will introduce more variability (many papers have been
written on this subject, btw).  I'm glad that IA-64 is one of the few
architectures that can efficiently (few instructions & at CPU speeds)
mask interrupts.  I'm certainly not going to give that up without a
VERY good reason.

  Keith> Using an INIT interrupt goes through PAL and SAL before it
  Keith> gets to the OS, any side effects of INIT are going to be
  Keith> platform dependent.It is bad enough maintaining kdb for
  Keith> multiple architectures, I do not want to handle multiple
  Keith> platforms as well.

Have you tried this?  PAL and SAL are quite explicit about the events
that happen in response to an INIT.  I didn't think there is much room
for platform dependent side effects.  Note that we already have an OS
INIT handler in arch/ia64/kernel/mca.c.

  Keith> Also INIT is far too expensive to use as a watchdog.

  Keith> 3. Use INIT interrupt.  Platform dependent side effects, too
  Keith> expensive for a watchdog.

This sounds like it's at least worth trying.

	--david

