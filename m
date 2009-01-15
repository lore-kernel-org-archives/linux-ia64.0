From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 15 Jan 2009 19:21:05 +0000
Subject: RE: [PATCH] configure HAVE_UNSTABLE_SCHED_CLOCK for SGI_SN systems
Message-Id: <57C9024A16AD2D4C97DC78E552063EA35CD8C4C3@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090106162741.GA7991@sgi.com>
 <20090115184832.GE10674@kroah.com>
In-Reply-To: <20090115184832.GE10674@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg KH <greg@kroah.com>, Dimitri Sivanich <sivanich@sgi.com>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Gregory Haskins <ghaskins@novell.com>, Nick Piggin <npiggin@suse.de>, Tony Luck <tony.luck@gmail.com>, Robin Holt <holt@sgi.com>

> > Greg, if everyone is OK with this patch, this should also be applied
> > to all stable trees starting with 2.6.26.

> What is the status of this going into Linus's tree?

I'm about to ask Linus to pull a modified version that does
a "select HAVE_UNSTABLE_SCHED_CLOCK" for all IA64 systems ...
SGI sched_clock() is a lot less "stable" than most, but all
ia64 systems can hit this as the ar.itc cycle counter is only
s/w synchronized between cpus.

-Tony
