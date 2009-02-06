From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Fri, 06 Feb 2009 23:17:09 +0000
Subject: Re: [PATCH] ia64: prevent irq migration race in __cpu_disable path
Message-Id: <20090206231709.GP10918@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090206162213.GD8208@ldl.fc.hp.com> <57C9024A16AD2D4C97DC78E552063EA36121A469@orsmsx505.amr.corp.intel.com> <20090206210550.GF2445@ldl.fc.hp.com>
In-Reply-To: <20090206210550.GF2445@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Chiang <achiang@hp.com>, "Luck, Tony" <tony.luck@intel.com>, "stable@kernel.org" <stable@kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Fri, Feb 06, 2009 at 02:05:50PM -0700, Alex Chiang wrote:
> * Luck, Tony <tony.luck@intel.com>:
> > > This is wrong because fixup_irqs calls migrate_irqs, and in
> > > migrate_irqs, we use the cpu_online_map to:
> > >
> > >       1. look for interrupts on current CPU
> > >       2. if we find one, move it to the first available CPU in
> > >       the cpu_online_map
> > >
> > > This means we can potentially migrate an interrupt off ourself
> > > back to... ourself. Uh oh.
> > 
> > Should we make migrate_irqs smarter then ... does any caller really
> > expect that it would "migrate" the irq to the same cpu?
> 
> The only thing migrate_irqs does is locate irqs that have their
> CPU affinity set to the current CPU, and if so, changes the
> affinity.
> 
> We still have possible pending timer interrupts that we need to
> handle, so I'm not seeing how changing the migrate_irqs
> implementation (to avoid migrating to ourself) will handle that.
> 
> On one hand, I think the only irq handler that can be called at
> this point is our timer_interrupt, which doesn't seem to be using
> any RCU APIs.
> 
> On the other hand, if we really want to make sure that we're not
> calling interrupt handlers with our CPU marked as 'offline', then
> we need to fix ia64_process_pending_intr() so that we're not
> firing our timer_interrupt with a NULL pt_regs.
> 
> Add in to the mix that x86 seems to have the same assumption that
> we do (that it's ok to call our timer interrupt handler even if
> we're already marked as 'offline').
> 
> I'm leaning towards reverting Paul's previous commit entirely
> because
> 
> 	- migrate_platform_irqs() doesn't cause any interrupt
> 	  handlers to be fired by itself
> 
> 	- it also uses cpu_online)map to find a new CPU to assign
> 	  CPEI to
> 
> Thoughts?

I would suggest at least a comment stating why it is safe to take the
interrupts on a CPU marked offline.  As to the eventual solution, you
guys are the experts on your architecture.

							Thanx, Paul
