From: Robin Holt <holt@sgi.com>
Date: Mon, 14 Mar 2005 16:24:13 +0000
Subject: Re: ia64 needs to shake memory from quicklists when there is memory pressure.
Message-Id: <20050314162412.GA9117@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050309170915.GA1583@lnx-holt.americas.sgi.com> <2120000.1110388509@[10.10.2.4]>
In-Reply-To: <2120000.1110388509@[10.10.2.4]>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Robin Holt <holt@sgi.com>, akpm@osdl.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-mm@kvack.org

On Wed, Mar 09, 2005 at 09:15:10AM -0800, Martin J. Bligh wrote:
> > The "ideal" would be to have a node aware slab cache.  Since that
> > is probably a long time coming, 
> 
> Manfred already did one. Perhaps we can get that going again? would
> be useful for more than just this ...

Is this the kmem_cache_alloc_node() stuff?  If so, when I use that
for page table allocations, running AIM7 on a 32 processor machine
consistently live-locks the system.  Everybody is waiting inside
kmem_cache_alloc_node() cachep->spinlock.

Is there a different patch I should be looking for?

Thanks,
Robin
