From: Erich Focht <efocht@hpce.nec.com>
Date: Thu, 18 Sep 2003 15:16:33 +0000
Subject: Re: [PATCH] fix build_zonelists for CONFIG_ACPI_NUMA
Message-Id: <marc-linux-ia64-106389825517355@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106383460616067@msgid-missing>
In-Reply-To: <marc-linux-ia64-106383460616067@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Jesse,

this kind of patch is a GOOD THING!

I just have an objection regarding the sort order. On my computers
(and on yours maybe too) I have matrices of the form:

10 15 15 15
15 10 15 15
15 15 10 15
15 15 15 10

Now just sorting the distance matrix row by row leads to the following
zonelists:
 for node 1:  1, 2, 3, 4
 for node 2:  2, 1, 3, 4
 for node 3:  3, 1, 2, 4
 for node 4:  4, 1, 2, 3

The first node in the list is fine and we'll get memory from the right
node if it is free. But if not, we'll request memory from the second
node in the zonelist and this will be (in most of the cases) node
1. Which means a pretty bad imbalance.

I'd prefer to see this more in a round-robin way, this would ease
things. The following piece of (ugly) code does this, but expects that
the existing values (in the example: 10 and 15) have been sorted into
the array node_levels[]. 

Just an idea...

Regards,
Erich

#define node_distance(from,to) (acpi20_slit[from * numnodes + to])

static void __init
permute_nodes(int curr, int *array)
{
	int lev, perm, node, dist=0, minown, nodes=0;

	array[nodes++] = curr;
	if (nr_node_levels = 1) return;
	for (node=0; node < numnodes; node++) {
		dist = node_distance(curr,node);
		if (dist = node_levels[1] || dist = node_levels[0])
			break;
	}
	minown = node;
	dist=0;
	for (lev=1; lev < nr_node_levels; lev++) {
		if (lev > 1) {
			for (perm=1; perm < numnodes; perm++) {
				node = (curr + perm) % numnodes;
				if (node_distance(curr, node) = node_levels[lev])
					break;
			}
			dist = perm + curr - minown;
		}
		for (perm=0; perm < numnodes; perm++) {
			node = (curr + perm + dist) % numnodes;
			if (node_distance(curr, node) = node_levels[lev])
				array[nodes++] = node;
		}
	}
}



On Wednesday 17 September 2003 23:31, Jesse Barnes wrote:
> Here's a ugly little patch to make build_zonelists use the ACPI SLIT
> table on ia64 if it's present.  Comments?  Should we have a generic
> Linux distance table that we use for this?  That way people could
> populate it at early boot and we could make this code work for all
> platforms.
>
> Btw, this patch sits on top of the last discontig patch I posted.
>
> Thanks,
> Jesse
...
> +sort_distance_array(unsigned int *slit, int *nodes, int size)
> +{
> +	unsigned int i, j, k, x, y;
> +
> +	/*
> +	 * Initialize the nodes array and weight the SLIT values
> +	 */
> +	for (i = 0; i < size; i++)
> +		nodes[i] = i;
> +
> +	for (i = 0; i < size - 1; i++) {
> +		k = i;
> +
> +		for (j = k + 1; j < size; j++) {
> +			if (slit[j] < slit[k])
> +				k = j;
> +		}
> +
> +		if (k != i) {
> +			x = slit[k]; slit[k] = slit[i]; slit[i] = x;
> +			y = nodes[k]; nodes[k] = nodes[i]; nodes[i] = y;
> +		}
> +	}
> +}


