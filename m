From: Andrew Morton <akpm@osdl.org>
Date: Mon, 14 Mar 2005 21:39:52 +0000
Subject: Re: ia64 needs to shake memory from quicklists when there is memory
Message-Id: <20050314133952.2a935d54.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050309170915.GA1583@lnx-holt.americas.sgi.com>
	<20050309113227.3501fb76.akpm@osdl.org>
	<20050314164051.GB9117@lnx-holt.americas.sgi.com>
In-Reply-To: <20050314164051.GB9117@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Robin Holt <holt@sgi.com>
Cc: tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-mm@kvack.org

Robin Holt <holt@sgi.com> wrote:
>
> > > The "ideal" would be to have a node aware slab cache.  Since that
>  > > is probably a long time coming, I was wondering if there would be
>  > > any possibility of getting some sort of hook into wakeup_kswapd(),
>  > > kswapd(), or balance_pgdat().  Since the quicklists are maintained per
>  > > cpu, we would need to perform an smp_call_function_single() for other
>  > > cpus on this node.  Is there some mechanism in place already to handle
>  > > anything similar to this?  Is there a better way to accomplish this?
>  > > Can you offer any suggestions?
>  > > 
>  > 
>  > Suggest you hook into the existing set_shrinker() API.
>  > 
>  > Then, in the shrinker callback, perform reclaim of the calling CPU's
>  > node's pages.
>  > 
>  > Try to return the right numbers from the shrinker callback so that
>  > shrink_slab() will keep this cache balanced wrt all the other ones which it
>  > is managing.
> 
>  I wedged a shrinker in which simply does a smp_call_function() to invoke
>  the cache shrinker.  I did modify the shrinker function to return the
>  number of pages freed, but am currently doing nothing with it as this
>  will require a spinlock/atomic operation and am not ready to take that
>  performance hit.  The one issue I have is we lose information about
>  which nodes to shake memory from and therefore end up calling the function
>  for every node in the system.  This appears very heavy handed.

As I said, "in the shrinker callback, perform reclaim of the calling CPU's
node's pages.".  kswapd is already node-affine, as are callers of
try_to_free_pages().

