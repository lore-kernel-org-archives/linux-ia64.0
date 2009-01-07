From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 07 Jan 2009 09:53:57 +0000
Subject: Re: [PATCH] configure HAVE_UNSTABLE_SCHED_CLOCK for SGI_SN systems
Message-Id: <1231322037.11687.178.camel@twins>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090106162741.GA7991@sgi.com>
	 <57C9024A16AD2D4C97DC78E552063EA35CB95575@orsmsx505.amr.corp.intel.com>
	 <20090106201950.GA3850@sgi.com>
	 <57C9024A16AD2D4C97DC78E552063EA35CB955B4@orsmsx505.amr.corp.intel.com>
	 <1231275441.11687.110.camel@twins> <20090106225054.GB3850@sgi.com>
	 <1231283763.11687.135.camel@twins> <20090107030030.GH3390@wotan.suse.de>
	 <1231313289.11687.172.camel@twins>  <20090107094328.GD3850@sgi.com>
In-Reply-To: <20090107094328.GD3850@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Robin Holt <holt@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, "Luck, Tony" <tony.luck@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Greg KH <greg@kroah.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Gregory Haskins <ghaskins@novell.com>, Tony Luck <tony.luck@gmail.com>

On Wed, 2009-01-07 at 03:43 -0600, Robin Holt wrote:
> On Wed, Jan 07, 2009 at 08:28:09AM +0100, Peter Zijlstra wrote:
> > That's basically what the HAVE_UNSTABLE_SCHED_CLOCK code does. It takes
> > a tick timestamp and tries to improve on that by using strict per cpu
> > sched_clock() deltas.
> > 
> > What we do to obtain remote time, is basically calculate local time and
> > pull remote time fwd if that was behind.
> 
> But what happens when the remote clock then takes a single tick and
> pulls forward a different remote clock by both your tick and its tick.
> Multiply that by 4096 and I am starting to feel that time is likely to
> go racing forward in a really random fashion.

I'm having trouble parsing that...

Clock state is kept per-cpu, and locked with a spinlock. When we request
a remote time-stamp we lock both our local and the remote clock state,
compute our local time, and set both the remote and local clock to the
max of local,remote clock.

An interrupt on the remote cpu will spin for its clock state lock before
doing anything - also, the tick interrupt will never bother with remote
clock state.

So I'm not exactly seeing what could go wrong here.

Please read kernel/sched_clock.c, its only 266 lines and could use an
extra eyeball, I'd be glad to answer any questions.
