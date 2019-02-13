From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 13 Feb 2019 10:32:31 +0000
Subject: Re: [PATCH v3 2/2] mm: be more verbose about zonelist initialization
Message-Id: <20190213103231.GN32494@hirez.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190212095343.23315-3-mhocko@kernel.org>
 <20190213094315.3504-1-mhocko@kernel.org>
In-Reply-To: <20190213094315.3504-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Pingfan Liu <kernelfans@gmail.com>, Dave Hansen <dave.hansen@intel.com>, x86@kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Michal Hocko <mhocko@suse.com>

On Wed, Feb 13, 2019 at 10:43:15AM +0100, Michal Hocko wrote:
> @@ -5259,6 +5261,11 @@ static void build_zonelists(pg_data_t *pgdat)
>  
>  	build_zonelists_in_node_order(pgdat, node_order, nr_nodes);
>  	build_thisnode_zonelists(pgdat);
> +
> +	pr_info("node[%d] zonelist: ", pgdat->node_id);
> +	for_each_zone_zonelist(zone, z, &pgdat->node_zonelists[ZONELIST_FALLBACK], MAX_NR_ZONES-1)
> +		pr_cont("%d:%s ", zone_to_nid(zone), zone->name);
> +	pr_cont("\n");
>  }

Have you ran this by the SGI and other stupid large machine vendors?
Traditionally they tend to want to remove such things instead of adding
them.

