From: "Martin J. Bligh" <mbligh@aracnet.com>
Date: Mon, 14 Mar 2005 16:37:25 +0000
Subject: Re: ia64 needs to shake memory from quicklists when there is memory pressure.
Message-Id: <163690000.1110818244@[10.10.2.4]>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050309170915.GA1583@lnx-holt.americas.sgi.com> <2120000.1110388509@[10.10.2.4]> <20050314162412.GA9117@lnx-holt.americas.sgi.com>
In-Reply-To: <20050314162412.GA9117@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Robin Holt <holt@sgi.com>
Cc: akpm@osdl.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-mm@kvack.org

>> > The "ideal" would be to have a node aware slab cache.  Since that
>> > is probably a long time coming, 
>> 
>> Manfred already did one. Perhaps we can get that going again? would
>> be useful for more than just this ...
> 
> Is this the kmem_cache_alloc_node() stuff?  If so, when I use that

Yes, I think so.

> for page table allocations, running AIM7 on a 32 processor machine
> consistently live-locks the system.  Everybody is waiting inside
> kmem_cache_alloc_node() cachep->spinlock.
> 
> Is there a different patch I should be looking for?

Don't know of one, but maybe we can get Manfred to fix the existing one ;-)

M.

