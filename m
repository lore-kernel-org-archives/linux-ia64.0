From: Nick Piggin <npiggin@suse.de>
Date: Wed, 02 Sep 2009 17:12:13 +0000
Subject: Re: discontigmem vs sparsemem on ia64 platforms
Message-Id: <20090902171213.GE28052@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090902163810.GC28052@wotan.suse.de>
In-Reply-To: <20090902163810.GC28052@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Sep 02, 2009 at 09:56:40AM -0700, Luck, Tony wrote:
> > I wonder why you have DISCONTIGMEM_DEFAULT selected for GENERIC, SN2, and > ZX1?
> > You don't explicitly disable SPARSEMEM for those platforms I think, so is
> > there another reason than bugs for this?
> 
> On ia64 DISCONTIGMEM was implemented first.  SPARSEMEM came later, and
> nobody has sent patches to switch the config defaults over to use it.
> I'd love it if somebody came up with some definitive arguments for
> why SPARSEMEM can replace DISCONTIGMEM so we could clear out some of
> the clutter that has accumulated by having both implementations. Last
> time I looked (a very long time ago) it looked like SPARSEMEM would
> have difficulties handling the extreme levels of sparseness on the
> SN2 platform (high order physical address bits are used to route
> memory traffic to the right node ... and since SN2 supports a lot
> of nodes, the bits in question are way up high).

Not too sure. SPARSEMEM certainly can handle sparseness within a
node better than DISCONTIGMEM I think (discontigmem is basically
like a flat mem per-node so it gets redundant mem_map over holes
within a node).

I figured it was probably something to do with sn2, but I wondered
about bugs in the other cases too.

> > My followup question... I wonder why memory hotplug is disabled for
> > discontigmem? It seems like there is code there to handle it (athough
> > I don't know the memory hotplug code well so I didn't look too closely).
> 
> Not at all sure of the history for this one.

OK, I thought I'd ask here because some of the ia64 people are
involved in developing mem hotplug.

Thanks,
Nick
