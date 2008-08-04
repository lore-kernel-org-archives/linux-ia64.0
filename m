From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 04 Aug 2008 22:22:37 +0000
Subject: RE: [BISECTION RESULT] sched: revert cpu_clock to
Message-Id: <57C9024A16AD2D4C97DC78E552063EA308329161@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <57C9024A16AD2D4C97DC78E552063EA308329110@orsmsx505.amr.corp.intel.com>
	<20080804.150249.71509974.davem@davemloft.net>
	<57C9024A16AD2D4C97DC78E552063EA308329139@orsmsx505.amr.corp.intel.com>
 <20080804.151448.190011603.davem@davemloft.net>
In-Reply-To: <20080804.151448.190011603.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>
Cc: "nacc@us.ibm.com" <nacc@us.ibm.com>, "mingo@elte.hu" <mingo@elte.hu>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

> What I'm suggesting is to very early on set ar.k3 to something which
> makes accesses go through the __per_cpu image copy in the main kernel
> image.

I'm looking at that ... but it is a bit more complex.  We only have
a "__per_cpu" block in the kernel on uni-processor systems. For
larger systems we dynamically allocate, and we have two different
mechanisms to that (one for SMP and one for NUMA).

> You could even set up a dummy TLB mapping during this early boot
> period.

Also a plausible idea ... though I'm not sure which physical address
I'd point this mapping at given the above allocation techniques.
Some of the problem here is that the kernel makes printk() calls
before any architecture dependent C code gets run.

> Otherwise it's just cleverness that is unique to IA64 and is going to
> constantly run into issues like this.  An alternative is to implement
> your own sched_clock() et al. where you can adhere to whatever special
> rules your platform may have.

Sigh.  we used to have our own (added by akpm in 2005) until it
got deleted :-(

-Tony
