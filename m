From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 18 Dec 2007 06:26:42 +0000
Subject: Re: [PATCH] ia64: Avoid unnecessary TLB flushes when allocating
Message-Id: <20071218152642.4761ae4a.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <7575980D7C4188408E8BDB171DA164B73A875A92A6@G3W1111.americas.hpqcorp.net>
	<20071218100545.14ae2c73.kamezawa.hiroyu@jp.fujitsu.com>
	<20071218060015.GE16467@fattire.cabal.ca>
In-Reply-To: <20071218060015.GE16467@fattire.cabal.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kyle McMartin <kyle@mcmartin.ca>
Cc: "de Dinechin, Christophe (Integrity VM)" <christophe.de-dinechin@hp.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Picco, Robert W." <robert.picco@hp.com>, "tony.luck@intel.com" <tony.luck@intel.com>

On Tue, 18 Dec 2007 01:00:15 -0500
Kyle McMartin <kyle@mcmartin.ca> wrote:

> On Tue, Dec 18, 2007 at 10:05:45AM +0900, KAMEZAWA Hiroyuki wrote:
> > On Thu, 13 Dec 2007 15:03:07 +0000
> > 
> > > +       if (mm != active_mm) {
> > > +               /* Restore region IDs for mm */
> > > +               if (mm && active_mm) {
> > > +                       activate_context(mm);
> > > +               } else {
> > > +                       flush_tlb_all();
> > > +                       return;
> > > +               }
> > >         }
> > should be 
> > 
> 
> platform_global_tlb_purge is already (and afaict, only) called under
> preempt_disable already. then again, the sn2 global_tlb_purge
> does it, so possibly for completeness sake it should be added here as
> well?
> 
Thank you. I see. flush_tlb_range() is the only caller.

...maybe adding comment is helpful (for me :).

Thanks,
-Kame

