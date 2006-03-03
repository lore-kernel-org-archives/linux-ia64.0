From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 03 Mar 2006 21:52:56 +0000
Subject: RE: [PATCH] fix for-loop in sn_hwperf_geoid_to_cnode()
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F05DDCCC6@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060303150312.GA32225@sgi.com>
In-Reply-To: <20060303150312.GA32225@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>As an interim & admittedly "hackey" solution, we have introduced the
>notion of "cnodes". For cpu & memory nodes, the cnode number is
>the same as the nid (generic kernel node number). IO nodes are
>guaranteed to have numbers assigned after the last nid. IO nodes
>may have number >= 256.

Right now there are only three uses of for_each_node().  The two
in mm/slab.c only need to worry about nodes that have memory, so from
your description above, they won't be at all concerned about the I/O
only nodes that they will fail to scan.

Any ideas on the relative proportions of nodes with/without memory?
Should we consider renaming "for_each_node()" as "for_each_mnode()"
(meaning only scan nodes with memory).  That would stop mm/slab.c
from allocating useless arraycaches for nodes with no memory.  But
this is turning into a discussion that would have to happen on LKML.

Perhaps you could add an /*ACPI3.0-FIXME*/ comment (or some such)
to the loop in Dean's patch as a reminder to fix this later?  That
might also serve as a clue to any janitor that tries to clean
up this code back to using "for_each_node()" (and a reminder to
me to not take such a patch).

-Tony
