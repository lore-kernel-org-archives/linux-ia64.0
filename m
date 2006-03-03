From: Jack Steiner <steiner@sgi.com>
Date: Fri, 03 Mar 2006 19:49:20 +0000
Subject: Re: [PATCH] fix for-loop in sn_hwperf_geoid_to_cnode()
Message-Id: <20060303194920.GA23999@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060303150312.GA32225@sgi.com>
In-Reply-To: <20060303150312.GA32225@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Mar 03, 2006 at 09:01:57AM -0800, Luck, Tony wrote:
> -	for_each_node(cnode) {
> +	for (cnode = 0; cnode < num_cnodes; cnode++) {
> 
> Do we really need to fix "for_each_node()" ... having a macro
> named this way that doesn't actually loop over all nodes looks
> like an invitation to get things wrong in the future.

I don't think that will work in the short term. Once we
get to ACPI3.0, yes.

The problem is that SN & the generic kernel are not in agreement 
on the definition of a "node". There are several problems.

ACPI2.0 limits the total number of nodes to 256 (PXM), SN needs 
more.  

In addition, it is difficult to describe IO-only nodes to the 
generic kernel.  We would need SRAT entries for IO-only nodes 
but those tables don't currently exist. Even if they did, we still 
have the 256 node limit.

As an interim & admittedly "hackey" solution, we have introduced the
notion of "cnodes". For cpu & memory nodes, the cnode number is
the same as the nid (generic kernel node number). IO nodes are
guaranteed to have numbers assigned after the last nid. IO nodes
may have number >= 256.

Only SN code is aware of cnodes. For example, IO cnodes are not in any
of the node maps: node_online_map, node_possible_map, etc.
IO cnodes don't have many (any?) of the usual per-node tables. 



Perhaps for consistency, we should add an SN macro:

	for_each_cnode(cnode)
	     or
	for_each_sn_cnode(cnode)	# to indicate this is SN only


All of these ugly hacks will go away when we get to ACPI3.0.
