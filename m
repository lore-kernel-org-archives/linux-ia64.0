From: j-nomura@ce.jp.nec.com
Date: Wed, 25 Feb 2004 05:02:42 +0000
Subject: Re: [Lse-tech] fix zonelist ordering for NUMA
Message-Id: <20040225.140242.884013675.nomura@linux.bs1.fc.nec.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1077652196.26287.6.camel@arrakis>
In-Reply-To: <1077652196.26287.6.camel@arrakis>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

> > + 		for (node = 1; node < numnodes; node++)
> > + 			j = build_zonelists_node(SORTED_NODE_DATA(local_node, node), zonelist, j, k);
> 
> Shouldn't that for loop be:
> 	for (node = 0; node < numnodes; node++)
> 		j = ....
> 
> or we'll be leaving a node out of the zonelists, right?

No. The zonelist for the local_node is built before the code above.

The whole code looks like:

> local_node = pgdat->node_id;
> ...
> j = build_zonelists_node(pgdat, zonelist, j, k);
> ...
> for (node = 1; node < numnodes; node++)
>     j = build_zonelists_node(SORTED_NODE_DATA(local_node,node), zonelist, j, k);

Actually, we might be able to clean it up like:

> for (idx = 0; idx < numnodes; idx++)
>     j = build_zonelists_node(SORTED_NODE_DATA(local_node,idx), zonelist, j, k);

Best regards.
--
NOMURA, Jun'ichi <j-nomura@ce.jp.nec.com>
