From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 25 Mar 2005 01:17:49 +0000
Subject: Re: [patch 2.6.11] __copy_user breaks on unaligned src
Message-Id: <16963.26301.383089.505308@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <12404.1111129477@kao2.melbourne.sgi.com>
In-Reply-To: <12404.1111129477@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 22 Mar 2005 14:04:55 +1100, Keith Owens <kaos@sgi.com> said:

  >> I don't see off-hand why this wouldn't work as intended.

  Keith> It's got me puzzled as well.  On my test system, single
  Keith> stepping the offending instruction _WILL_ cause a fault, but
  Keith> letting it run normally does not cause an error.  A normal
  Keith> run (without single step) definitely uses lfetch with an
  Keith> invalid address, however ia64_fault() is not invoked, not
  Keith> even for isr.na.

  Keith> I am trying to get some time on the big system to reproduce
  Keith> the problem and see why lfetch is faulting there.  Is there
  Keith> any chance that a concurrent interrupt (the failing system
  Keith> does a lot of I/O) can lose the lfetch status?

Hmmh, odd indeed.  I changed prefetch()/prefetchw() to use
lfetch.fault and now the kernel dies early on on an lfetch.fault that
goes to address 0 (triggered by find_pid()).  Since that's a NaT page,
you'd expect a general exception (NaT consumption).  However, the CPU
seems to get stuck in an infinite loop of general exceptions.  From
what I can tell, it get to "dispatch_to_fault_handler" and as soon as
it re-enables PSR.IC or perhaps PSR.I (not sure which), it gets
another general exception fault.

	--david
