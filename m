From: Ingo Molnar <mingo@kernel.org>
Date: Mon, 11 Feb 2019 13:49:09 +0000
Subject: Re: [RFC PATCH] x86, numa: always initialize all possible nodes
Message-Id: <20190211134909.GA107845@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190114082416.30939-1-mhocko@kernel.org>
 <20190124141727.GN4087@dhcp22.suse.cz>
 <3a7a3cf2-b7d9-719e-85b0-352be49a6d0f@intel.com>
 <20190125105008.GJ3560@dhcp22.suse.cz>
In-Reply-To: <20190125105008.GJ3560@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michal Hocko <mhocko@kernel.org>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, Pingfan Liu <kernelfans@gmail.com>, Peter Zijlstra <peterz@infradead.org>, x86@kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>


* Michal Hocko <mhocko@kernel.org> wrote:

> On Thu 24-01-19 11:10:50, Dave Hansen wrote:
> > On 1/24/19 6:17 AM, Michal Hocko wrote:
> > > and nr_cpus set to 4. The underlying reason is tha the device is bound
> > > to node 2 which doesn't have any memory and init_cpu_to_node only
> > > initializes memory-less nodes for possible cpus which nr_cpus restrics.
> > > This in turn means that proper zonelists are not allocated and the page
> > > allocator blows up.
> > 
> > This looks OK to me.
> > 
> > Could we add a few DEBUG_VM checks that *look* for these invalid
> > zonelists?  Or, would our existing list debugging have caught this?
> 
> Currently we simply blow up because those zonelists are NULL. I do not
> think we have a way to check whether an existing zonelist is actually 
> _correct_ other thatn check it for NULL. But what would we do in the
> later case?
> 
> > Basically, is this bug also a sign that we need better debugging around
> > this?
> 
> My earlier patch had a debugging printk to display the zonelists and
> that might be worthwhile I guess. Basically something like this
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 2e097f336126..c30d59f803fb 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5259,6 +5259,11 @@ static void build_zonelists(pg_data_t *pgdat)
>  
>  	build_zonelists_in_node_order(pgdat, node_order, nr_nodes);
>  	build_thisnode_zonelists(pgdat);
> +
> +	pr_info("node[%d] zonelist: ", pgdat->node_id);
> +	for_each_zone_zonelist(zone, z, &pgdat->node_zonelists[ZONELIST_FALLBACK], MAX_NR_ZONES-1)
> +		pr_cont("%d:%s ", zone_to_nid(zone), zone->name);
> +	pr_cont("\n");
>  }

Looks like this patch fell through the cracks - any update on this?

Thanks,

	Ingo
