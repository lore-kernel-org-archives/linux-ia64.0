From: Takayoshi Kochi <t-kochi@bq.jp.nec.com>
Date: Mon, 01 Nov 2004 06:35:27 +0000
Subject: Re: [PATCH] top level scheduler domain for ia64
Message-Id: <20041101.153527.74753402.t-kochi@bq.jp.nec.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200410191427.27336.jbarnes@engr.sgi.com>
In-Reply-To: <200410191427.27336.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Jesse,

From: Jesse Barnes <jbarnes@engr.sgi.com>
Subject: Re: [PATCH] top level scheduler domain for ia64
Date: Thu, 28 Oct 2004 08:26:00 -0700

> > Our 32way machine still isn't configured well with the overwrapping
> > domain partitioning.  CPUs 0-15 belongs to domain (0 1 2 3 4 5 6)
> > and CPUs 16-31 belongs to domain (0 1 4 5 6 7), which is assymmetric
> > and at least does not reflect the real connection.
> 
> Hm, I was afraid of that since the top level domain is only built if the 
> system has more CPUs than SD_NODES_PER_DOMAIN * cpus_per_node.  We could 
> change that to be a simple if (numnodes > SD_NODES_PER_DOMAIN) instead.

But I don't think the domain partitioning thing will optimize anything
in all the cases that (numnodes > SD_NODES_PER_DOMAIN) is true.

> > dmesg of the machine is attached.
> >
> > The following patch makes the ia64 domain partitioning (maybe Altix
> > specific ;) optional and makes the magic number (6) configurable.
> >
> > What do you think of this?
> 
> Maybe a boot parameter would be better for configuring SD_NODES_PER_DOMAIN?  
> That would allow a single kernel binary to be configured to run well on many 
> types of NUMA systems.  It would also mean you could play with very large 
> node domains, with and w/o a top level domain.

It sounds good for -mm, but not for Linus?
That would be a pain for any ordinary user to test many parameters
for each configuration (and the number makes very little difference,
which would make it more difficult to find the best number).

What I'd like to do now is to get rid of subarch specific optimization
out of generic kernels.

Do you have any objection for the patch to be included in the mainline?

---
Takayoshi Kochi

