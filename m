From: Roland McGrath <roland@redhat.com>
Date: Wed, 12 Dec 2007 22:36:27 +0000
Subject: Re: [PATCH] arch_ptrace_stop
Message-Id: <20071212223627.DDF1726F8D9@magilla.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1196959793.6586.3.camel@elijah.suse.cz>
	<20071208011152.CDA8E26F8EA@magilla.localdomain>
	<20071211215135.95ae3f6d.akpm@linux-foundation.org>
In-Reply-To: Andrew Morton's message of  Tuesday, 11 December 2007 21:51:35 -0800 <20071211215135.95ae3f6d.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Petr Tesarik <ptesarik@suse.cz>, tony.luck@intel.com

> Mutter.  These would be better as static inlines.  A macro just invites
> variable-unused warnings on non-ia64 and outright compilation errors on
> ia64.  Speaking from experience...
> 
> static inline void arch_ptrace_stop(int exit_code, siginfo_t *info)
> {
> }
> #define arch_ptrace_stop arch_ptrace_stop
> 
> should work?

That's fine with me.  I just followed the example of e.g. arch_ptrace_attach.

> >  /*
> > + * Return nonzero if there is a SIGKILL that should be waking us up.
> > + * Called with the siglock held.
> > + */
> > +static int sigkill_pending(struct task_struct *tsk)
> > +{
> > +	return ((sigismember(&tsk->pending.signal, SIGKILL) ||
> > +		 sigismember(&tsk->signal->shared_pending.signal, SIGKILL)) &&
> > +		!unlikely(sigismember(&tsk->blocked, SIGKILL)));
> > +}
> 
> Could you please take a peek at the infrastructure added by
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.24-rc4/2.6.24-rc4-mm1/broken-out/add-lock_page_killable.patch
> and see if there is exploitable commonality?

I haven't reviewed that whole set in detail yet.  So I'd rather leave this
for a later cleanup.  (This ptrace change alone, along with its ia64
pieces, can probably go in much earlier without disrupting anything else.)

The fatal_signal_pending function in that patch is not exactly the same as
this check, though it might turn out that it's actually equivalent due to
higher-level constraints.  


Thanks,
Roland
