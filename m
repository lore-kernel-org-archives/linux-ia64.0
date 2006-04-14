From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 14 Apr 2006 22:12:52 +0000
Subject: RE: [PATCH 00/05] robust per_cpu allocation for modules
Message-Id: <4t16i2$ma94t@orsmga001.jf.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <1145049535.1336.128.camel@localhost.localdomain>
References: <1145049535.1336.128.camel@localhost.localdomain>
In-Reply-To: <1145049535.1336.128.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Steven Rostedt' <rostedt@goodmis.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@osdl.org>
Cc: Linus Torvalds <torvalds@osdl.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <ak@suse.de>, Martin Mares <mj@atrey.karlin.mff.cuni.cz>, bjornw@axis.com, schwidefsky@de.ibm.com, benedict.gaster@superh.com, lethal@linux-sh.org, Chris Zankel <chris@zankel.net>, Marc Gauthier <marc@tensilica.com>, Joe Taylor <joe@tensilica.com>, David Mosberger-Tang <davidm@hpl.hp.com>, rth@twiddle.net, spyro@f2s.com, starvik@axis.com, "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, ralf@linux-mips.org, linux-mips@linux-mips.org, grundler@parisc-linux.org, parisc-linux@parisc-linux.org, linuxppc-dev@ozlabs.org, paulus@samba.org, linux390@de.ibm.com, lethal@linux-sh.org, davem@davemloft.net, chris@zankel.net

Steven Rostedt wrote on Friday, April 14, 2006 2:19 PM
> So the current solution has two flaws:
> 1. not robust. If we someday add more modules that together take up
>    more than 14K, we need to manually update the PERCPU_ENOUGH_ROOM.
> 2. waste of memory.  We have 14K of memory wasted per CPU. Remember
>    a 64 processor machine would be wasting 896K of memory!

If someone who has the money to own a 64-process machine, 896K of memory
is pocket change ;-)

- Ken
