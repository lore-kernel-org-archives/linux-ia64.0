From: Greg KH <greg@kroah.com>
Date: Thu, 22 Jan 2009 19:04:52 +0000
Subject: Re: [PATCH] configure HAVE_UNSTABLE_SCHED_CLOCK for SGI_SN systems
Message-Id: <20090122190452.GA20770@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090106162741.GA7991@sgi.com> <20090115184832.GE10674@kroah.com> <57C9024A16AD2D4C97DC78E552063EA35CD8C4C3@orsmsx505.amr.corp.intel.com>
In-Reply-To: <57C9024A16AD2D4C97DC78E552063EA35CD8C4C3@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Dimitri Sivanich <sivanich@sgi.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Gregory Haskins <ghaskins@novell.com>, Nick Piggin <npiggin@suse.de>, Tony Luck <tony.luck@gmail.com>, Robin Holt <holt@sgi.com>

On Thu, Jan 15, 2009 at 11:21:05AM -0800, Luck, Tony wrote:
> > > Greg, if everyone is OK with this patch, this should also be applied
> > > to all stable trees starting with 2.6.26.
> 
> > What is the status of this going into Linus's tree?
> 
> I'm about to ask Linus to pull a modified version that does
> a "select HAVE_UNSTABLE_SCHED_CLOCK" for all IA64 systems ...
> SGI sched_clock() is a lot less "stable" than most, but all
> ia64 systems can hit this as the ar.itc cycle counter is only
> s/w synchronized between cpus.

Thanks, I see it now and will queue it up for the next -stable releases.

greg k-h
