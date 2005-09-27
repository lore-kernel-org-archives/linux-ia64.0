From: Bob Picco <bob.picco@hp.com>
Date: Tue, 27 Sep 2005 14:07:37 +0000
Subject: Re: [Lhms-devel] Re: [PATCH 0/4] V4 ia64 SPARSEMEM
Message-Id: <20050927140737.GN16066@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1127779977.10315.6.camel@localhost>
In-Reply-To: <1127779977.10315.6.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger-Tang wrote:	[Mon Sep 26 2005, 09:20:08PM EDT]
> On 9/26/05, Luck, Tony <tony.luck@intel.com> wrote:
> 
> > >Long term should SPARSEMEM become the default and DISCONTIG+VIRTUAL_MEM_MAP
> > >be obsoleted then we could remove the config files.
> >
> > If benchmarks show no difference, then I'll consolidate the
> > configuration options.  I still think that VIRTUAL_MEM_MAP
> > has a great deal of elegance to it ... auto-sizing to just
> > about any degree of sparseness, but I think we need to
> > simplify.
> 
> Benchmarks cannot prove the absence of a performance difference in
> *general*, they can only do that for specific tests and workloads. 
> So, unless SPARSEMEM actually performs *better* on some benchmarks
> (and no worse on others), the proper course seems to be to stick with
> VIRTUAL_MEM_MAP where SPARSEMEM isn't needed.
> 
> I have voice my objection in the past to Bob's suggestion that
> SPARSEMEM should replace VIRTUAL_MEM_MAP and since then I haven't seen
> any convincing argument why that should be the case, so I do not
> understand why Bob keeps bringing that up.
Well I'm not attempting to stir up controversy. It's just that should SPARSEMEM
and VIRTUAL_MEM_MAP perform equally, then there doesn't appear any point
in retaining both. We are a long way from that decision should there ever
be consensus to make it.
> 
>   --david
bob
