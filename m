From: "Vitezslav Samel" <samel@mail.cz>
Date: Mon, 17 Mar 2003 07:45:26 +0000
Subject: Re: [Linux-ia64] Re: [BUG] nanosleep() granularity bumps up in 2.5.64 (was: [PATCH] settimeofday() n
Message-Id: <marc-linux-ia64-105590709806134@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806094@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806094@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Mar 14, 2003 at 02:48:59PM +0000, Matthew Wilcox wrote:
> On Fri, Mar 14, 2003 at 03:34:36PM +0100, Eric Piel wrote:
> > I think lines like that from patch-2.5.64 are very suspicious to be
> > related to the bug:
> > +	base->timer_jiffies = INITIAL_JIFFIES;
> > +	base->tv1.index = INITIAL_JIFFIES & TVR_MASK;
> > +	base->tv2.index = (INITIAL_JIFFIES >> TVR_BITS) & TVN_MASK;
> > +	base->tv3.index = (INITIAL_JIFFIES >> (TVR_BITS+TVN_BITS)) & TVN_MASK;
> > +	base->tv4.index = (INITIAL_JIFFIES >> (TVR_BITS+2*TVN_BITS)) &
> > TVN_MASK;
> > +	base->tv5.index = (INITIAL_JIFFIES >> (TVR_BITS+3*TVN_BITS)) &
> > TVN_MASK;
> 
> No, I don't think so.  Those lines are for starting `jiffies' at a very
> high number so we spot jiffie-wrap bugs early on.

  The nanosleep() bug narrowed down to 2.5.63-bk2. That's version, the "initial
jiffies" patch went in. And yes, it's on i686 machine.

	Cheers,
		Vita

