From: William Lee Irwin III <wli@holomorphy.com>
Date: Tue, 03 Aug 2004 23:53:24 +0000
Subject: Re: free bootmem feedback patch
Message-Id: <20040803235324.GC2334@holomorphy.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40F46962.4090604@sgi.com>
In-Reply-To: <40F46962.4090604@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Aug 03, 2004 at 12:53:53PM -0500, Josh Aas wrote:
> Are there any outstanding issues with Tony's second revision of the 
> free_all_bootmem_core function? Do we still have the problem of making 
> sure longwork in node_bootmem_map[] corresponds to an order 6 page with 
> the right physical alignment? The second revision looks good to me. If I 
> could get some more feedback on it I'll clean up any remaining issues so 
> it can land sometime soon. I'll post test results (unpatched vs. 
> patched) on a big machine later this afternoon.

I think it's fine.

On Tue, Aug 03, 2004 at 12:53:53PM -0500, Josh Aas wrote:
> wli - do you still want to see the memory map for my big test machine 
> (512GB RAM)?

Sure.


-- wli
