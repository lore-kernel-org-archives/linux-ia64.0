From: Andi Kleen <ak@suse.de>
Date: Wed, 17 May 2006 11:08:54 +0000
Subject: Re: [RFC PATCH 01/09] robust VM per_cpu core
Message-Id: <200605171308.56203.ak@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0605170547490.8408@gandalf.stny.rr.com> <200605171117.06060.ak@suse.de> <Pine.LNX.4.58.0605170640280.8408@gandalf.stny.rr.com>
In-Reply-To: <Pine.LNX.4.58.0605170640280.8408@gandalf.stny.rr.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Rusty Russell <rusty@rustcorp.com.au>, Paul Mackerras <paulus@samba.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Martin Mares <mj@atrey.karlin.mff.cuni.cz>, bjornw@axis.com, schwidefsky@de.ibm.com, lethal@linux-sh.org, Chris Zankel <chris@zankel.net>, Marc Gauthier <marc@tensilica.com>, Joe Taylor <joe@tensilica.com>, rth@twiddle.net, spyro@f2s.com, starvik@axis.com, tony.luck@intel.com, linux-ia64@vger.kernel.org, ralf@linux-mips.org, linux-mips@linux-mips.org, grundler@parisc-linux.org, parisc-linux@parisc-linux.org, linuxppc-dev@ozlabs.org, linux390@de.ibm.com, davem@davemloft.net, arnd@arndb.de, kenneth.w.chen@intel.com, sam@ravnborg.org, clameter@sgi.com, kiran@scalex86.org

On Wednesday 17 May 2006 12:46, Steven Rostedt wrote:
> 
> On Wed, 17 May 2006, Andi Kleen wrote:
> 
> >
> > > As well as the following three functions:
> > >
> > > pud_t *pud_boot_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long addr,
> > >                      int cpu);
> > > pmd_t *pmd_boot_alloc(struct mm_struct *mm, pud_t *pud, unsigned long addr,
> > >                      int cpu);
> > > pte_t *pte_boot_alloc(struct mm_struct *mm, pmd_t *pmd, unsigned long addr,
> > >                      int cpu);
> >
> > I'm not sure you can just put them like this into generic code. Some
> > architectures are doing strange things with them.
> 
> Hmm, like what?

Mostly managing their software TLBs I think.
 
> >
> > And we already have boot_ioremap on some architectures. Why is that not
> > enough?
> 
> I thought about using boot_ioremap, but it seems to be an abuse.  Since
> I'm not mapping io, but actual memory pages. 

We already use it for memory, e.g. for mapping some BIOS tables.

> So the solution to that 
> seemed more of a hack.  I then would need to worry about grabbing pages
> that were node specific 

alloc_bootmem_node

> and getting the physical addresses.  

virt_to_phys() 

[ + hacks to handle 32bit NUMA unfortunately ]

-Andi
