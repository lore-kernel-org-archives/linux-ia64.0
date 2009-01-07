From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 07 Jan 2009 07:28:09 +0000
Subject: Re: [PATCH] configure HAVE_UNSTABLE_SCHED_CLOCK for SGI_SN systems
Message-Id: <1231313289.11687.172.camel@twins>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090106162741.GA7991@sgi.com>
	 <57C9024A16AD2D4C97DC78E552063EA35CB95575@orsmsx505.amr.corp.intel.com>
	 <20090106201950.GA3850@sgi.com>
	 <57C9024A16AD2D4C97DC78E552063EA35CB955B4@orsmsx505.amr.corp.intel.com>
	 <1231275441.11687.110.camel@twins> <20090106225054.GB3850@sgi.com>
	 <1231283763.11687.135.camel@twins>  <20090107030030.GH3390@wotan.suse.de>
In-Reply-To: <20090107030030.GH3390@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nick Piggin <npiggin@suse.de>
Cc: Robin Holt <holt@sgi.com>, "Luck, Tony" <tony.luck@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Greg KH <greg@kroah.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Gregory Haskins <ghaskins@novell.com>, Tony Luck <tony.luck@gmail.com>

On Wed, 2009-01-07 at 04:00 +0100, Nick Piggin wrote:
> On Wed, Jan 07, 2009 at 12:16:03AM +0100, Peter Zijlstra wrote:
> > > 
> > > But doesn't scheduler tick advance the rq->clock?  Why do the others
> > > need to fiddle with a remote runqueue's clock?  When that cpu starts
> > > taking ticks again, it will update it's rq->clock field and start the
> > > processes.  I guess I am a lot underinformed about the new scheduler
> > > design.
> > 
> > We try to do better than tick based time accounting these days.
> 
> But if you contain the drift to within one tick, it shouldn't be much
> problem to just truncate negative deltas I would have thought? The
> time between events on different CPUs is pretty fuzzy at the ns level
> anyway, I think ;)

That's basically what the HAVE_UNSTABLE_SCHED_CLOCK code does. It takes
a tick timestamp and tries to improve on that by using strict per cpu
sched_clock() deltas.

What we do to obtain remote time, is basically calculate local time and
pull remote time fwd if that was behind.

While doing that, it filters out any backward motion and large fwd leaps
so as to stay no worse than a jiffie clock.

