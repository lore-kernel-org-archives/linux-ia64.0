From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 25 Mar 2005 07:59:41 +0000
Subject: Re: [patch 2.6.11] __copy_user breaks on unaligned src
Message-Id: <16963.50413.78227.263769@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <12404.1111129477@kao2.melbourne.sgi.com>
In-Reply-To: <12404.1111129477@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 24 Mar 2005 17:17:49 -0800, David Mosberger <davidm@linux.hpl.hp.com> said:

>>>>> On Tue, 22 Mar 2005 14:04:55 +1100, Keith Owens <kaos@sgi.com> said:
  >>> I don't see off-hand why this wouldn't work as intended.

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

  David> Hmmh, odd indeed.  I changed prefetch()/prefetchw() to use
  David> lfetch.fault and now the kernel dies early on on an lfetch.fault that
  David> goes to address 0 (triggered by find_pid()).  Since that's a NaT page,
  David> you'd expect a general exception (NaT consumption).  However, the CPU
  David> seems to get stuck in an infinite loop of general exceptions.  From
  David> what I can tell, it get to "dispatch_to_fault_handler" and as soon as
  David> it re-enables PSR.IC or perhaps PSR.I (not sure which), it gets
  David> another general exception fault.

After some more digging, it appears that we do get a vhpt-miss fault
first and for some reason, that handler triggers a (nested) general
exception fault with ISR.code7:4}=3 (IA-64 Reserved Register/Field
fault, Unimplemented Data Address fault".  Not sure yet what triggers
the nested fault.  The odd thing is that the same kernel works fine
with the Ski simulator (where I do get the expected
ia64_do_page_fault() when find_pid prefetches address 0).

	--david
