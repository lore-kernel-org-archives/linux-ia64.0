From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Mon, 01 Nov 2004 22:39:08 +0000
Subject: Re: [PATCH] top level scheduler domain for ia64
Message-Id: <200411011439.08947.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200410191427.27336.jbarnes@engr.sgi.com>
In-Reply-To: <200410191427.27336.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday, November 1, 2004 11:45 am, Luck, Tony wrote:
> I'd pose a broader question ... are the manufacturers of big machines happy
> with three domains?  Perhaps it makes sense to allow for more levels that
> match the physical parameters of the machine.  E.g. the NEC box has 4 cpus
> per-node, and 4 nodes in a "super-node", and 2 "super-nodes" in a machine.
> It would make sense to me if there was a scheduler domain level that would
> handle balancing between the nodes in a super-node in addition to the
> top-level domain to handle balancing between super-nodes.
>
> While the values in SLIT can be somewhat abstract, they could be used to
> derive the whole node, super-node, hyper-node, ultra-node,
> marketting-zeta-node structure to build as many levels as make sense into
> the scheduler.
>
> Or am I over-engineering?

Just guessing, but I think that might be overkill.  We'd have to collect data 
to know for sure though (which means someone has to implement it :).

Jesse
