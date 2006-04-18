From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Tue, 18 Apr 2006 06:42:40 +0000
Subject: Re: [PATCH 00/05] robust per_cpu allocation for modules
Message-Id: <44448A60.4040903@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <1145049535.1336.128.camel@localhost.localdomain> <4440855A.7040203@yahoo.com.au> <Pine.LNX.4.64.0604170953390.29732@schroedinger.engr.sgi.com> <20060417220238.GD3945@localhost.localdomain> <Pine.LNX.4.58.0604171936040.24264@gandalf.stny.rr.com>
In-Reply-To: <Pine.LNX.4.58.0604171936040.24264@gandalf.stny.rr.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Ravikiran G Thirumalai <kiran@scalex86.org>, Christoph Lameter <clameter@sgi.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <ak@suse.de>, Martin Mares <mj@atrey.karlin.mff.cuni.cz>, bjornw@axis.com, schwidefsky@de.ibm.com, benedict.gaster@superh.com, lethal@linux-sh.org, Chris Zankel <chris@zankel.net>, Marc Gauthier <marc@tensilica.com>, Joe Taylor <joe@tensilica.com>, David Mosberger-Tang <davidm@hpl.hp.com>, rth@twiddle.net, spyro@f2s.com, starvik@axis.com, tony.luck@intel.com, linux-ia64@vger.kernel.org, ralf@linux-mips.org, linux-mips@linux-mips.org, grundler@parisc-linux.org, parisc-linux@parisc-linux.org, linuxppc-dev@ozlabs.org, paulus@samba.org, linux390@de.ibm.com, davem@davemloft.net

Steven Rostedt wrote:

> Understood, but I'm going to start looking in the way Rusty and Arnd
> suggested with the vmalloc approach. This would allow for saving of
> memory and dynamic allocation of module memory making it more robust. And
> all this without that evil extra indirection!

Remember that this approach could effectively just move the indirection to
the TLB / page tables (well, I say "moves" because large kernel mappings
are effectively free compared with 4K mappings).

So be careful about coding up a large amount of work before unleashing it:
I doubt you'll be able to find a solution that doesn't involve tradeoffs
somewhere (but wohoo if you can).

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 
