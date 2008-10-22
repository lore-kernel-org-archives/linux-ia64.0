From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 22 Oct 2008 19:19:43 +0000
Subject: Re: [PATCH 1/2] Allow rwlocks to re-enable interrupts
Message-Id: <1224703183.20069.55.camel@twins>
List-Id: <linux-ia64.vger.kernel.org>
References: <1224664414.4430.33.camel@elijah.suse.cz>
	 <1224664476.4430.38.camel@elijah.suse.cz> <1224665128.15448.4.camel@twins>
	 <1224665899.4430.48.camel@elijah.suse.cz> <1224696271.20069.8.camel@twins>
	 <20081022190510.GH26094@parisc-linux.org>
In-Reply-To: <20081022190510.GH26094@parisc-linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: Petr Tesarik <ptesarik@suse.cz>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, tee@sgi.com, Ingo Molnar <mingo@elte.hu>

On Wed, 2008-10-22 at 13:05 -0600, Matthew Wilcox wrote:
> On Wed, Oct 22, 2008 at 07:24:31PM +0200, Peter Zijlstra wrote:
> > > No problem. I could then also use it for _spin_lock_irqsave, if the
> > > answer to the above question is use CONFIG_LOCK_STAT there as well.
> > 
> > If you create LOCK_CONTEDED_FLAGS() the whole issue goes away nicely.

Gah, I looked at it again, and that #ifdef isn't only to select between
LOCK_CONTENDED and not, but we can't actually have the re-enable for
anything lockdep.

So I was wrong.

> Should it also be used for _spin_lock_irq()?  I'm puzzled why it's only
> used for _irqsave().

Right, not sure how this maze is done.

The thing is, with spin_lock_irq() you know the irq state and can do the
enable unconditionally - then again, with ticket locks we cannot do it
at all.

The _flags() version needs the flags to see if irqs was enabled before
we entered the op, if it wasn't we cannot go around enabling them.

> (should _spin_lock_bh() re-enable BHs while waiting?  Is it just not big
> enough of a deal?)

Doubt it.. dunno.. personally I'd rather see softirqs die sooner rather
than later.
