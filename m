From: jbarnes@sgi.com (Jesse Barnes)
Date: Tue, 24 Feb 2004 17:13:34 +0000
Subject: Re: fix zonelist ordering for NUMA
Message-Id: <20040224171334.GA13504@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040224.182028.884032071.nomura@linux.bs1.fc.nec.co.jp>
In-Reply-To: <20040224.182028.884032071.nomura@linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Feb 24, 2004 at 06:20:28PM +0900, j-nomura@ce.jp.nec.com wrote:
> The attached patch makes use of arch-dependent info for building zonelist.
> The patch uses ACPI SLIT for ia64.
> Other arch may have their own method to determine the order.
> 
> This kind of ordering is very important for the NUMA system in which
> the distance between nodes is not uniform.
> 
> The patch doing this was posted by Jesse Barnes in linux-ia64:
> http://marc.theaimsgroup.com/?t6383477500001&r=1&w=2
> however, I couldn't find it in current tree...

Yeah, I haven't pushed it yet (I didn't think it was ready yet and I
haven't done a good version for 2.6 yet).

> The sorting can be extended to, for example, more fine grained round-robin
> like Erich suggested. But let's start from the simple one.
> 
> Any comments?

Yeah, it looks ok.  What I was hoping to do in the patch that ultimately
gets in:

  1) make it arch independent
     this means having arch code populate a SLIT-like table for use by
     the generic zonelist building code
  2) handle the cases that Erich talked about a bit better
  3) some systems have pgdats w/o any CPUs associated with them, they
     need to be dealt with differently than regular nodes, maybe as
     extensions to an existing node

The final routine might look something like (many thanks to pj for
hitting me with a cluebat about this):


/**
 * find_next_best_node - find the next node that should appear in a given
 *    node's fallback list
 * @node: node whose fallback list we're appending
 *
 * We use a number of factors to determine which is the next node that should
 * appear on a given node's fallback list.  The node should not have appeared
 * already in @node's fallback list, and it should be the next closest node
 * according to the distance array (which contains arbitrary distance values
 * from each node to each node in the system), and should also prefer nodes
 * with no CPUs, since presumably they'll have very little allocation pressure
 * on them otherwise.
 */
int find_next_best_node(int node)
{
	int i, val, min_val, best_node;

	for (i = 0; i < numnodes; i++) {
		/* Don't want a node to appear more than once */
		if (node_present(node, i))
		    continue;

		/* Use the distance array to find the distance */
		val = node_distance(node, i);

		/* Give preference to headless and unused nodes */
		val += nid_enabled_cpu_count[i] * 255;
		val += node_load[i];

		if (val < min_val) {
			min_val = val;
			best_node = i;
		}
	}

	return best_node;
}

Jesse
