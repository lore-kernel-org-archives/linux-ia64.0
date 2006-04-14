From: Andrew Morton <akpm@osdl.org>
Date: Fri, 14 Apr 2006 22:06:25 +0000
Subject: Re: [PATCH 00/05] robust per_cpu allocation for modules
Message-Id: <20060414150625.3ba369d2.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1145049535.1336.128.camel@localhost.localdomain>
In-Reply-To: <1145049535.1336.128.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>
Cc: linux-kernel@vger.kernel.org, torvalds@osdl.org, mingo@elte.hu, tglx@linutronix.de, ak@suse.de, mj@atrey.karlin.mff.cuni.cz, bjornw@axis.com, schwidefsky@de.ibm.com, benedict.gaster@superh.com, lethal@linux-sh.org, chris@zankel.net, marc@tensilica.com, joe@tensilica.com, davidm@hpl.hp.com, rth@twiddle.net, spyro@f2s.com, starvik@axis.com, tony.luck@intel.com, linux-ia64@vger.kernel.org, ralf@linux-mips.org, linux-mips@linux-mips.org, grundler@parisc-linux.org, parisc-linux@parisc-linux.org, linuxppc-dev@ozlabs.org, paulus@samba.org, linux390@de.ibm.com, davem@davemloft.net

Steven Rostedt <rostedt@goodmis.org> wrote:
>
> Example:
> 
>  DEFINE_PER_CPU(int, myint);
> 
>  would now create a variable called per_cpu_offset__myint in
> the .data.percpu_offset section.

Suppose two .c files each have

	DEFINE_STATIC_PER_CPU(myint)

Do we end up with two per_cpu_offset__myint's in the same section?
