From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 17 Feb 2005 00:08:06 +0000
Subject: RE: Allow to change SD_NODES_PER_DOMAIN at configuration or boot time
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02EDE850@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42138013.3060909@bull.net>
In-Reply-To: <42138013.3060909@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>I remember this was discussed some months ago, but it still seems that 
>on 2.6.10, SD_NODES_PER_DOMAIN is statically defined to value 6.
>This is not what is expected on Bull ia64 platforms, based on 
>modules of 4 bricks of 4 cpus each.

I guess I still don't understand how defining the number of
nodes per domain gets the *right* nodes assigned to a domain.
Does this rely on node discovery code assigning logical node
numbers in such a way that nodes 0, 1, 2, 3 belong to one
domain, and nodes 4, 5, 6, 7 belong to the next domain (for
a system where SD_NODES_PER_DOMAIN=4)?  What if we have a
system where node numbers are effectively randomly assigned
by firmware at power-on? Then nodes 0, 3, 6, 7 might make up
a super-node, but we'll create a couple of domains that have
a jumbled mix of nodes from each super-node.

That's why I asked whether we need to parse the SLIT to determine
how many nodes belong to a domain ... but also to find out
which nodes are in which domain.

-Tony
