From: jbarnes@sgi.com (Jesse Barnes)
Date: Thu, 18 Sep 2003 15:38:32 +0000
Subject: Re: [PATCH] fix build_zonelists for CONFIG_ACPI_NUMA
Message-Id: <marc-linux-ia64-106389966219366@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106383460616067@msgid-missing>
In-Reply-To: <marc-linux-ia64-106383460616067@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Sep 18, 2003 at 05:16:33PM +0200, Erich Focht wrote:
> this kind of patch is a GOOD THING!

Glad you approve! ;)

> I just have an objection regarding the sort order. On my computers
> (and on yours maybe too) I have matrices of the form:
> 
> 10 15 15 15
> 15 10 15 15
> 15 15 10 15
> 15 15 15 10
> 
> Now just sorting the distance matrix row by row leads to the following
> zonelists:
>  for node 1:  1, 2, 3, 4
>  for node 2:  2, 1, 3, 4
>  for node 3:  3, 1, 2, 4
>  for node 4:  4, 1, 2, 3
> 
> The first node in the list is fine and we'll get memory from the right
> node if it is free. But if not, we'll request memory from the second
> node in the zonelist and this will be (in most of the cases) node
> 1. Which means a pretty bad imbalance.

Yeah, that's a good point.  We should fix that.

> I'd prefer to see this more in a round-robin way, this would ease
> things. The following piece of (ugly) code does this, but expects that
> the existing values (in the example: 10 and 15) have been sorted into
> the array node_levels[]. 

Sounds good.

> #define node_distance(from,to) (acpi20_slit[from * numnodes + to])

I should use this in my code, I think it'll make it more readable :).

> static void __init
> permute_nodes(int curr, int *array)
> {
> 	int lev, perm, node, dist=0, minown, nodes=0;
> 
> 	array[nodes++] = curr;
> 	if (nr_node_levels = 1) return;
> 	for (node=0; node < numnodes; node++) {
> 		dist = node_distance(curr,node);
> 		if (dist = node_levels[1] || dist = node_levels[0])
> 			break;
> 	}
> 	minown = node;
> 	dist=0;
> 	for (lev=1; lev < nr_node_levels; lev++) {
> 		if (lev > 1) {
> 			for (perm=1; perm < numnodes; perm++) {
> 				node = (curr + perm) % numnodes;
> 				if (node_distance(curr, node) = node_levels[lev])
> 					break;
> 			}
> 			dist = perm + curr - minown;
> 		}
> 		for (perm=0; perm < numnodes; perm++) {
> 			node = (curr + perm + dist) % numnodes;
> 			if (node_distance(curr, node) = node_levels[lev])
> 				array[nodes++] = node;
> 		}
> 	}
> }

I'll look at integrating something like this into my patch and reposting
it.

Thanks,
Jesse
