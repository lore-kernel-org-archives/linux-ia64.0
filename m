From: Jesse Barnes <jbarnes@sgi.com>
Date: Thu, 17 Feb 2005 00:13:10 +0000
Subject: Re: Allow to change SD_NODES_PER_DOMAIN at configuration or boot time
Message-Id: <200502161613.11170.jbarnes@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42138013.3060909@bull.net>
In-Reply-To: <42138013.3060909@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday, February 16, 2005 4:08 pm, Luck, Tony wrote:
> I guess I still don't understand how defining the number of
> nodes per domain gets the *right* nodes assigned to a domain.
> Does this rely on node discovery code assigning logical node
> numbers in such a way that nodes 0, 1, 2, 3 belong to one
> domain, and nodes 4, 5, 6, 7 belong to the next domain (for
> a system where SD_NODES_PER_DOMAIN=4)?  What if we have a
> system where node numbers are effectively randomly assigned
> by firmware at power-on? Then nodes 0, 3, 6, 7 might make up
> a super-node, but we'll create a couple of domains that have
> a jumbled mix of nodes from each super-node.

It uses the SLIT table to put a cluster of SD_NODES_PER_DOMAIN nodes into a 
sched domain.  So if SD_NODES_PER_DOMAIN is 4, node 0 will be in a domain 
with the three nodes closest to node 0, which could be node 9, 15, and 2 for 
all we know...

> That's why I asked whether we need to parse the SLIT to determine
> how many nodes belong to a domain ... but also to find out
> which nodes are in which domain.

I don't think the SLIT gives us enough info to determine the best grouping of 
nodes, but it depends on how the various firmwares build it--some may.

Jesse
