From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Mon, 01 Nov 2004 18:36:26 +0000
Subject: Re: [PATCH] top level scheduler domain for ia64
Message-Id: <200411011036.26808.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200410191427.27336.jbarnes@engr.sgi.com>
In-Reply-To: <200410191427.27336.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday, November 1, 2004 9:16 am, Matthew Wilcox wrote:
> On Mon, Nov 01, 2004 at 09:07:32AM -0800, Jesse Barnes wrote:
> > If I understand you right, you don't want a top level domain for your 32
> > way systems, but you *do* want the node domains to span the whole thing. 
> > Is that right?
> >
> > If so, you could do something like this I think?
> >
> >  if (numnodes <= SMALL_SYSTEM_THRESHOLD) {
> >   SD_NODES_PER_DOMAIN = numnodes;
> >   build_node_domains(); /* each one spans the system */
> >  } else {
> >   SD_NODES_PER_DOMAIN = 4; /* or whatever */
> >   build_node_domains(); /* only spans nearby nodes */
> >   build_top_level_domain(); /* whole system, infrequently balanced */
> >  }
> >
> > Would that address your concerns?
>
> Doesn't sound like a great idea.  HP's already shipping 128-way Superdome
> IA-64 systems, and they'll want to be set up rather differently from the
> Altix systems.  I think this code needs to be autotuning so it doesn't
> need to be touched whenever a vendor releases a new configuration (I
> think I heard that NASA's Altixes had a custom CPU brick with twice the
> CPUs in it?)

Yeah, but still the same number of CPUs/FSB.  I agree that autotuning would be 
best (the above is a crude example of that).  Any suggestions?

Jesse
