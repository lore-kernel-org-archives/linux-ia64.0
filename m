From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Mon, 01 Nov 2004 17:07:32 +0000
Subject: Re: [PATCH] top level scheduler domain for ia64
Message-Id: <200411010907.32114.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200410191427.27336.jbarnes@engr.sgi.com>
In-Reply-To: <200410191427.27336.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sunday, October 31, 2004 10:35 pm, Takayoshi Kochi wrote:
> > Maybe a boot parameter would be better for configuring
> > SD_NODES_PER_DOMAIN? That would allow a single kernel binary to be
> > configured to run well on many types of NUMA systems.  It would also mean
> > you could play with very large node domains, with and w/o a top level
> > domain.
>
> It sounds good for -mm, but not for Linus?
> That would be a pain for any ordinary user to test many parameters
> for each configuration (and the number makes very little difference,
> which would make it more difficult to find the best number).
>
> What I'd like to do now is to get rid of subarch specific optimization
> out of generic kernels.
>
> Do you have any objection for the patch to be included in the mainline?

I don't want it included since it hurts generic kernels on large systems (i.e. 
either they wouldn't boot or wouldn't see all the CPUs).  It should be 
possible to use a runtime check (whether a boot parameter or just a 
comparison on numnodes) instead to avoid non-overlapping domains.

If I understand you right, you don't want a top level domain for your 32 way 
systems, but you *do* want the node domains to span the whole thing.  Is that 
right?

If so, you could do something like this I think?

 if (numnodes <= SMALL_SYSTEM_THRESHOLD) {
  SD_NODES_PER_DOMAIN = numnodes;
  build_node_domains(); /* each one spans the system */
 } else {
  SD_NODES_PER_DOMAIN = 4; /* or whatever */
  build_node_domains(); /* only spans nearby nodes */
  build_top_level_domain(); /* whole system, infrequently balanced */
 }

Would that address your concerns?

Jesse
