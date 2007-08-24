From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Date: Fri, 24 Aug 2007 16:58:40 +0000
Subject: Re: [PATCH] Fix find_next_best_node (Re: [BUG] 2.6.23-rc3-mm1 Kernel
Message-Id: <46CF0B70.1050302@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A023EB020@scsmsx411.amr.corp.intel.com> <20070823142133.9359a1ce.akpm@linux-foundation.org> <20070824153945.3C75.Y-GOTO@jp.fujitsu.com>
In-Reply-To: <20070824153945.3C75.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@skynet.ie>, "Luck, Tony" <tony.luck@intel.com>, Jeremy Higdon <jeremy@sgi.com>, Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-ia64@vger.kernel.org, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org

Yasunori Goto wrote:
> I found find_next_best_node() was wrong.
> I confirmed boot up by the following patch.
> Mel-san, Kamalesh-san, could you try this?
>
> Bye.
> ---
>
> Fix decision of memoryless node in find_next_best_node().
> This can be cause of SW-IOMMU's allocation failure.
>
> This patch is for 2.6.23-rc3-mm1.
>
> Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>
>
> ---
>  mm/page_alloc.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> Index: current/mm/page_alloc.c
> =================================> --- current.orig/mm/page_alloc.c	2007-08-24 16:03:17.000000000 +0900
> +++ current/mm/page_alloc.c	2007-08-24 16:04:06.000000000 +0900
> @@ -2136,7 +2136,7 @@ static int find_next_best_node(int node,
>  		 * Note:  N_HIGH_MEMORY state not guaranteed to be
>  		 *        populated yet.
>  		 */
> -		if (pgdat->node_present_pages)
> +		if (!pgdat->node_present_pages)
>  			continue;
>
>  		/* Don't want a node to appear more than once */
>
>   
This patch resolves the kernel panic problem.

-
Kamalesh Babulal.
