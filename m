From: Christoph Lameter <clameter@sgi.com>
Date: Mon, 17 Apr 2006 16:55:02 +0000
Subject: Re: [PATCH 00/05] robust per_cpu allocation for modules
Message-Id: <Pine.LNX.4.64.0604170953390.29732@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1145049535.1336.128.camel@localhost.localdomain>
 <4440855A.7040203@yahoo.com.au>
In-Reply-To: <4440855A.7040203@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kiran@scalex86.org
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Steven Rostedt <rostedt@goodmis.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <ak@suse.de>, Martin Mares <mj@atrey.karlin.mff.cuni.cz>, bjornw@axis.com, schwidefsky@de.ibm.com, benedict.gaster@superh.com, lethal@linux-sh.org, Chris Zankel <chris@zankel.net>, Marc Gauthier <marc@tensilica.com>, Joe Taylor <joe@tensilica.com>, David Mosberger-Tang <davidm@hpl.hp.com>, rth@twiddle.net, spyro@f2s.com, starvik@axis.com, tony.luck@intel.com, linux-ia64@vger.kernel.org, ralf@linux-mips.org, linux-mips@linux-mips.org, grundler@parisc-linux.org, parisc-linux@parisc-linux.org, linuxppc-dev@ozlabs.org, paulus@samba.org, linux390@de.ibm.com, davem@davemloft.net

On Sat, 15 Apr 2006, Nick Piggin wrote:

> If I'm following you correctly, this adds another dependent load
> to a per-CPU data access, and from memory that isn't node-affine.

I am also concerned about that. Kiran has a patch to avoid allocpercpu
having to go through one level of indirection that I guess would no 
longer work with this scheme.
 
> If so, I think people with SMP and NUMA kernels would care more
> about performance and scalability than the few k of memory this
> saves.

Right.

