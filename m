From: Andi Kleen <ak@suse.de>
Date: Mon, 17 Apr 2006 17:10:46 +0000
Subject: Re: [PATCH 00/05] robust per_cpu allocation for modules
Message-Id: <200604171910.48838.ak@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1145049535.1336.128.camel@localhost.localdomain> <Pine.LNX.4.58.0604152323560.16853@gandalf.stny.rr.com> <4441ECE6.5010709@yahoo.com.au>
In-Reply-To: <4441ECE6.5010709@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Steven Rostedt <rostedt@goodmis.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Martin Mares <mj@atrey.karlin.mff.cuni.cz>, bjornw@axis.com, schwidefsky@de.ibm.com, benedict.gaster@superh.com, lethal@linux-sh.org, Chris Zankel <chris@zankel.net>, Marc Gauthier <marc@tensilica.com>, Joe Taylor <joe@tensilica.com>, David Mosberger-Tang <davidm@hpl.hp.com>, rth@twiddle.net, spyro@f2s.com, starvik@axis.com, tony.luck@intel.com, linux-ia64@vger.kernel.org, ralf@linux-mips.org, linux-mips@linux-mips.org, grundler@parisc-linux.org, parisc-linux@parisc-linux.org, linuxppc-dev@ozlabs.org, paulus@samba.org, linux390@de.ibm.com, davem@davemloft.net

On Sunday 16 April 2006 09:06, Nick Piggin wrote:

> I still don't understand what the justification is for slowing down
> this critical bit of infrastructure for something that is only a
> problem in the -rt patchset, and even then only a problem when tracing
> is enabled.

There are actually problems outside -rt. e.g. the Xen kernel was running
into a near overflow and as more and more code is using per cpu variables
others might too.

I'm confident the problem can be solved without adding more variables
though - e.g. in the way rusty proposed.

-Andi


