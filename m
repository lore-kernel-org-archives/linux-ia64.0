From: Matthew Dobson <colpatch@us.ibm.com>
Date: Tue, 24 Feb 2004 19:49:56 +0000
Subject: Re: [Lse-tech] fix zonelist ordering for NUMA
Message-Id: <1077652196.26287.6.camel@arrakis>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 2004-02-24 at 01:20, j-nomura@ce.jp.nec.com wrote:
> - 		for (node = local_node + 1; node < numnodes; node++)
> - 			j = build_zonelists_node(NODE_DATA(node), zonelist, j, k);
> - 		for (node = 0; node < local_node; node++)
> - 			j = build_zonelists_node(NODE_DATA(node), zonelist, j, k);
> + 		for (node = 1; node < numnodes; node++)
> + 			j = build_zonelists_node(SORTED_NODE_DATA(local_node, node), zonelist, j, k);

Shouldn't that for loop be:
	for (node = 0; node < numnodes; node++)
		j = ....

or we'll be leaving a node out of the zonelists, right?

-Matt

