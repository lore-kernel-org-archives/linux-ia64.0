From: Christoph Hellwig <hch@infradead.org>
Date: Thu, 17 Jul 2003 15:20:56 +0000
Subject: Re: HUGETLB pages on multiple nodes
Message-Id: <marc-linux-ia64-105845539430747@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105821072317881@msgid-missing>
In-Reply-To: <marc-linux-ia64-105821072317881@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Jul 14, 2003 at 12:20:37PM -0700, Nick Pollitt wrote:
> +#ifdef CONFIG_NUMA
> +		int node = i % num_memblks;
> +		page = alloc_pages_node(node, __GFP_HIGHMEM, HUGETLB_PAGE_ORDER);
> +#else
>  		page = alloc_pages(__GFP_HIGHMEM, HUGETLB_PAGE_ORDER);
> +#endif /* CONFIG_NUMA */

Why the num_memblks?  We care for nodes, not memblks, don't we?

Also you can just use alloc_pages_node directly in the non-NUMA code.

See how alloc_pages is implemented in 2.5:

#define alloc_pages(gfp_mask, order) \
                alloc_pages_node(numa_node_id(), gfp_mask, order)

