From: Mike Rapoport <rppt@linux.ibm.com>
Date: Fri, 25 Jan 2019 19:25:04 +0000
Subject: Re: [RFC PATCH] x86, numa: always initialize all possible nodes
Message-Id: <20190125192504.GG31519@rapoport-lnx>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190114082416.30939-1-mhocko@kernel.org>
 <20190124141727.GN4087@dhcp22.suse.cz>
 <20190124175144.GF13790@rapoport-lnx>
 <20190125104023.GI3560@dhcp22.suse.cz>
In-Reply-To: <20190125104023.GI3560@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Pingfan Liu <kernelfans@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <peterz@infradead.org>, x86@kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Fri, Jan 25, 2019 at 11:40:23AM +0100, Michal Hocko wrote:
> On Thu 24-01-19 19:51:44, Mike Rapoport wrote:
> > On Thu, Jan 24, 2019 at 03:17:27PM +0100, Michal Hocko wrote:
> > > a friendly ping for this. Does anybody see any problem with this
> > > approach?
> > 
> > FWIW, it looks fine to me.
> > 
> > It'd just be nice to have a few more words in the changelog about *how* the
> > x86 init was reworked ;-)
> 
> Heh, I thought it was there but nope... It probably just existed in my
> head. Sorry about that. What about the following paragraphs added?
> "
> The new code relies on the arch specific initialization to allocate all
> possible NUMA nodes (including memory less) - numa_register_memblks in
> this case. Generic code then initializes both zonelists (__build_all_zonelists)
> and allocator internals (free_area_init_nodes) for all non-null pgdats
> rather than online ones.
> 
> For the x86 specific part also do not make new node online in alloc_node_data
> because this is too early to know that. numa_register_memblks knows that
> a node has some memory so it can make the node online appropriately.
> init_memory_less_node hack can be safely removed altogether now.
> "

LGTM, thanks!
 
> -- 
> Michal Hocko
> SUSE Labs
> 

-- 
Sincerely yours,
Mike.
