From: Paul Mackerras <paulus@samba.org>
Date: Sun, 16 Apr 2006 06:35:09 +0000
Subject: Re: [PATCH 00/05] robust per_cpu allocation for modules
Message-Id: <17473.58781.901412.135671@cargo.ozlabs.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1145049535.1336.128.camel@localhost.localdomain>
In-Reply-To: <1145049535.1336.128.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@osdl.org>, linux-mips@linux-mips.org, David Mosberger-Tang <davidm@hpl.hp.com>, linux-ia64@vger.kernel.org, Martin Mares <mj@atrey.karlin.mff.cuni.cz>, spyro@f2s.com, Joe Taylor <joe@tensilica.com>, linuxppc-dev@ozlabs.org, benedict.gaster@superh.com, bjornw@axis.com, Ingo Molnar <mingo@elte.hu>, grundler@parisc-linux.org, starvik@axis.com, Linus Torvalds <torvalds@osdl.org>, Thomas Gleixner <tglx@linutronix.de>, rth@twiddle.net, chris@zankel.net, tony.luck@intel.com, Andi Kleen <ak@suse.de>, ralf@linux-mips.org, Marc Gauthier <marc@tensilica.com>, lethal@linux-sh.org, schwidefsky@de.ibm.com, linux390@de.ibm.com, davem@davemloft.net, parisc-linux@parisc-linux.org

Steven Rostedt writes:

> The data in .data.percpu_offset holds is referenced by the per_cpu
> variable name which points to the __per_cpu_offset array.  For modules,
> it will point to the per_cpu_offset array of the module.
> 
> Example:
> 
>  DEFINE_PER_CPU(int, myint);
> 
>  would now create a variable called per_cpu_offset__myint in
> the .data.percpu_offset section.  This variable will point to the (if
> defined in the kernel) __per_cpu_offset[] array.  If this was a module
> variable, it would point to the module per_cpu_offset[] array which is
> created when the modules is loaded.

This sounds like you have an extra memory reference each time a
per-cpu variable is accessed.  Have you tried to measure the
performance impact of that?  If so, how much performance does it lose?

Paul.
