From: Michal Hocko <mhocko@kernel.org>
Date: Wed, 13 Feb 2019 13:41:15 +0000
Subject: Re: [PATCH v3 2/2] mm: be more verbose about zonelist initialization
Message-Id: <20190213134115.GO4525@dhcp22.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190212095343.23315-3-mhocko@kernel.org>
 <20190213094315.3504-1-mhocko@kernel.org>
 <20190213103231.GN32494@hirez.programming.kicks-ass.net>
 <20190213115014.GC4525@dhcp22.suse.cz>
 <20190213131131.GS32494@hirez.programming.kicks-ass.net>
In-Reply-To: <20190213131131.GS32494@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-mm@kvack.org, Pingfan Liu <kernelfans@gmail.com>, Dave Hansen <dave.hansen@intel.com>, x86@kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>

On Wed 13-02-19 14:11:31, Peter Zijlstra wrote:
> On Wed, Feb 13, 2019 at 12:50:14PM +0100, Michal Hocko wrote:
> > On Wed 13-02-19 11:32:31, Peter Zijlstra wrote:
> > > On Wed, Feb 13, 2019 at 10:43:15AM +0100, Michal Hocko wrote:
> > > > @@ -5259,6 +5261,11 @@ static void build_zonelists(pg_data_t *pgdat)
> > > >  
> > > >  	build_zonelists_in_node_order(pgdat, node_order, nr_nodes);
> > > >  	build_thisnode_zonelists(pgdat);
> > > > +
> > > > +	pr_info("node[%d] zonelist: ", pgdat->node_id);
> > > > +	for_each_zone_zonelist(zone, z, &pgdat->node_zonelists[ZONELIST_FALLBACK], MAX_NR_ZONES-1)
> > > > +		pr_cont("%d:%s ", zone_to_nid(zone), zone->name);
> > > > +	pr_cont("\n");
> > > >  }
> > > 
> > > Have you ran this by the SGI and other stupid large machine vendors?
> > 
> > I do not have such a large machine handy. The biggest I have has
> > handfull (say dozen) of NUMA nodes.
> > 
> > > Traditionally they tend to want to remove such things instead of adding
> > > them.
> > 
> > I do not insist on this patch but I find it handy. If there is an
> > opposition I will not miss it much.
> 
> Well, I don't have machines like that either and don't mind the patch.
> Just raising the issue; I've had the big iron boys complain about
> similar things (typically printing something for every CPU, which gets
> out of hand much faster than zones, but still).

Maybe we can try to push this through and revert if somebody complains
about an excessive output.

-- 
Michal Hocko
SUSE Labs
