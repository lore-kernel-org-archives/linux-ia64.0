From: Christoph Hellwig <hch@infradead.org>
Date: Wed, 25 Feb 2004 11:28:32 +0000
Subject: Re: [Lse-tech] fix zonelist ordering for NUMA
Message-Id: <20040225112832.A3066@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1077652196.26287.6.camel@arrakis>
In-Reply-To: <1077652196.26287.6.camel@arrakis>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Feb 25, 2004 at 07:59:33PM +0900, j-nomura@ce.jp.nec.com wrote:
> +#ifndef node_distance
> +#define node_distance(from,to) (1)
> +#endif

please move this to toplogy.h - it'll be usefull in a few other places.

> +#define PENALTY_FOR_NODE_WITH_CPUS  (1)

should probably also go to topology.h to allow architectures to change it.

> +	for(i = 0; i < numnodes; i++) {

minor  nitpick: please leave a space between the for and the opening brace


> +		while((node = find_next_best_node(local_node, used_mask)) >= 0)

same here.

