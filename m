From: Arnd Bergmann <arnd@arndb.de>
Date: Sun, 16 Apr 2006 15:34:18 +0000
Subject: Re: [PATCH 00/05] robust per_cpu allocation for modules
Message-Id: <200604161734.20256.arnd@arndb.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1145049535.1336.128.camel@localhost.localdomain> <17473.60411.690686.714791@cargo.ozlabs.ibm.com> <1145194804.27407.103.camel@localhost.localdomain>
In-Reply-To: <1145194804.27407.103.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Paul Mackerras <paulus@samba.org>, Nick Piggin <nickpiggin@yahoo.com.au>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <ak@suse.de>, Martin Mares <mj@atrey.karlin.mff.cuni.cz>, bjornw@axis.com, schwidefsky@de.ibm.com, benedict.gaster@superh.com, lethal@linux-sh.org, Chris Zankel <chris@zankel.net>, Marc Gauthier <marc@tensilica.com>, Joe Taylor <joe@tensilica.com>, David Mosberger-Tang <davidm@hpl.hp.com>, rth@twiddle.net, spyro@f2s.com, starvik@axis.com, tony.luck@intel.com, linux-ia64@vger.kernel.org, ralf@linux-mips.org, linux-mips@linux-mips.org, grundler@parisc-linux.org, parisc-linux@parisc-linux.org, linuxppc-dev@ozlabs.org, linux390@de.ibm.com, davem@davemloft.net, rusty@rustcorp.com.au

On Sunday 16 April 2006 15:40, Steven Rostedt wrote:
> I'll think more about this, but maybe someone else has some crazy ideas
> that can find a solution to this that is both fast and robust.

Ok, you asked for a crazy idea, you're going to get it ;-)

You could take a fixed range from the vmalloc area (e.g. 1MB per cpu)
and use that to remap pages on demand when you need per cpu data.

#define PER_CPU_BASE 0xe000000000000000UL /* arch dependant */
#define PER_CPU_SHIFT 0x100000UL
#define __per_cpu_offset(__cpu) (PER_CPU_BASE + PER_CPU_STRIDE * (__cpu))
#define per_cpu(var, cpu) (*RELOC_HIDE(&per_cpu__##var, __per_cpu_offset(cpu)))
#define __get_cpu_var(var) per_cpu(var, smp_processor_id())

This is a lot like the current sparc64 implementation already is.

The tricky part here is the remapping of pages. You'd need to 
alloc_pages_node() new pages whenever the already reserved space is
not enough for the module you want to load and then map_vm_area()
them into the space reserved for them.

Advantages of this solution are:
- no dependant load access for per_cpu()
- might be flexible enough to implement a faster per_cpu_ptr()
- can be combined with ia64-style per-cpu remapping

Disadvantages are:
- you can't use huge tlbs for mapping per cpu data like the
  regular linear mapping -> may be slower on some archs
- does not work in real mode, so percpu data can't be used
  inside exception handlers on some architectures.
- memory consumption is rather high when PAGE_SIZE is large

	Arnd <><
