From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 17 Jan 2006 19:22:28 +0000
Subject: Re: First Montecito Reference Manual is now available
Message-Id: <20060117192228.GA5521@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F05701C2A@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F05701C2A@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ian,

Thanks for taking the time to look at this document. Here are the
answers from an Itanium architect:

> On page 173 it mentions "cycles we run with PCR.sd" set.  What's that?
A1)  This is a too low level reference.  It basically indicates the
cycles where we artificially prevent thread switching from occurring.
Only firmware has the ability to do this.  It should very low.  I will
make a note to ensure this is addressed in 1.0.

> On page 174 it talks about THREAD_SWITCH_GATED.  What is a gated
> thread switch?  Particularly it mentions being gated due to LP, what
> is that?
A2) A thread switch has been queued, but can be delayed for various
reasons -- specifically if target thread is in low-power mode (LP),
there are pipeline stalls that need to be removed in order to complete
architectural state of the source thread, and for forward progress
(we have not given the current thread sufficient time in the core).
I will see about getting LP addressed and explained better.

> On page 176 it mentions a srlz.i instruction causes a "microtrap" and
> an xpn-flush.  What are they?
[Ref is actually on p.164, p.176 is blank]
A3) Again this is too low level and should be changed to be something
like: "(because it causes a pipeline flush)".  The other information is
how it does the flush and not relevant.

> TLB entries are tagged with the hardware thread.  Is there any
> possibility to override this (I mean, even theoretically)?
A4) The thread identifier is considered part of the VA to ensure that VA
and PA aliases between threads do not turn up problems (such as different
access rights and or accessed/dirty behaviors.  It cannot be undone.
There is some thread TLB aliasing that is allowed in the L1I TLB but
we actually cause a miss on the old thread and then re-insert the new
thread's page information on top of the old thread.  This preserves the
L1I cache contents for that 4k L1I TLB entry.

-Tony
