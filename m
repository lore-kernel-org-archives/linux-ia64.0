From: Bob Picco <bob.picco@hp.com>
Date: Tue, 27 Sep 2005 14:09:20 +0000
Subject: Re: [PATCH 0/4] V4 ia64 SPARSEMEM
Message-Id: <20050927140920.GO16066@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050922161418.GW16066@localhost.localdomain>
In-Reply-To: <20050922161418.GW16066@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

luck wrote:	[Mon Sep 26 2005, 08:03:09PM EDT]
> >I'm assuming you refer to the config changes in arch/ia64/Kconfig. Well the
> >new ones are documented in mm/Kconfig.  If that documentation is inadequate,
> >then I can attempt to supply more.
> 
> There aren't any words in there about why I might want to use
> sparsemem ... just a standard version of if you don't know what
> to pick, go with the old discontig stuff.
I can't say there is disagreement with this point. So you'd obviously like
more help text in mm/Kconfig?
> 
> 
> >Should you think we won't get sufficient test converage without some default
> >configuration files, then I'd suggest the two mentioned about be introduced.
> 
> This is definitely the prime issue ... config space on ia64
> is already very fragmented, so testting of some combination
> of options is rare to non-existant.  If SPARSEMEM isn't turned
> on, then it won't be used by anyone that isn't already reading
> the lhms list.  Coupled with the lack of sales pitch in the
> Kconfig help files, it looks like this isn't going to be used
> by anyone!
Yep. I thought this is what you are after.
> 
> >Long term should SPARSEMEM become the default and DISCONTIG+VIRTUAL_MEM_MAP
> >be obsoleted then we could remove the config files.
> 
> If benchmarks show no difference, then I'll consolidate the
> configuration options.  I still think that VIRTUAL_MEM_MAP
> has a great deal of elegance to it ... auto-sizing to just
> about any degree of sparseness, but I think we need to
> simplify.
Well I'm not attempting to be critical of VIRTUAL_MEM_MAP. Obviously it 
satisfies a solution which was previously unanswered. I'm just hoping to reduce
our configuration options.  We aren't even remotely close to possibly
considering this.
> 
The bigsur problem isn't nodedata.h related. It's in arch/ia64/Kconfig which
figures. I should have this resolved some time today after checking
the default configs.
> -Tony
> -
bob
