From: David Miller <davem@davemloft.net>
Date: Mon, 04 Aug 2008 22:14:48 +0000
Subject: Re: [BISECTION RESULT] sched: revert cpu_clock to
Message-Id: <20080804.151448.190011603.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <57C9024A16AD2D4C97DC78E552063EA308329110@orsmsx505.amr.corp.intel.com>
	<20080804.150249.71509974.davem@davemloft.net>
	<57C9024A16AD2D4C97DC78E552063EA308329139@orsmsx505.amr.corp.intel.com>
In-Reply-To: <57C9024A16AD2D4C97DC78E552063EA308329139@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: nacc@us.ibm.com, mingo@elte.hu, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 4 Aug 2008 15:10:40 -0700

> > Can you guys on IA64 possibly set ar.k3 simply to zero or to some
> > other similar value which cancels out the per-cpu computation?
> >
> > That's what sparc64 and other platforms do.
> 
> In cpu_init() we set ar.k3 to the base physical address of the percpu
> area.  The alt-dtlb miss handler uses this register to set up a
> TLB mapping from virtual address 0xffffffffffff0000 to this physical
> address.
> 
> This means that most per-cpu accesses are very cheap (as the compiler
> can use a small -ve offset from register r0 to load the virtual
> address).
> 
> Accessing ar.k3 is a bit slow ... so making the per-cpu code
> use that on every access to a per-cpu variable would be unpleasant.

I understand that you use TLB mappings.

What I'm suggesting is to very early on set ar.k3 to something which
makes accesses go through the __per_cpu image copy in the main kernel
image.

You could even set up a dummy TLB mapping during this early boot
period.

Otherwise it's just cleverness that is unique to IA64 and is going to
constantly run into issues like this.  An alternative is to implement
your own sched_clock() et al. where you can adhere to whatever special
rules your platform may have.
