From: Josh Aas <josha@sgi.com>
Date: Fri, 06 Aug 2004 18:27:41 +0000
Subject: Re: free bootmem feedback patch
Message-Id: <4113CD9D.8000903@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40F46962.4090604@sgi.com>
In-Reply-To: <40F46962.4090604@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote:
> Does the change:
> -			ClearPageReserved(page);
> +			(page)->flags &= ~(1UL << PG_reserved);
> 
> in the "else if (v)" clause actually make any difference?  I would
> expect not (unless you have bizarrely fragmented memory), so you
> could just leave the atomic operations there.

I imagine that change would make an improvement, no matter how small it 
is. Why not just do it? Especially after I define a macro.

> But it might be prettier to define a BootClearPageReserved() function
> in page-flags.h rather than expose the details of the implementation
> here in bootmem.c (in which case you could use this new function
> in the "else if (v)" clause too for symmetry).

I'll go ahead and create a macro for the non-atomic bit clear. Perhaps 
call it "ClearPageReservedNoAtomic" instead of "BootClearPageReserved"?

> Finally you have a magic "16" in the prefetchw() path.  Where did
> it come from, and is it the right number for non-ia64 machines?

My bad for not explaining that. In my limited testing of this particular 
number it seemed to be the sweet spot for prefetching. I think it is a 
good number for all architectures because 32 bit architectures won't 
need the speed boost as much as 64 bit architectures. They are not 
likely to have > 4GB memory,, in which case this function's time is 
probably less than 1 second anyway. So even though you have to wait 16 
iterations before you start getting the prefetched advantage, 32 bit 
architectures still get the improvement on half the iterations. It 
should be good for other 64 bit architectures because all architectures 
should be able to complete the prefetch by the 16th iteration, and all 
64 bit architectures will get the prefetched advantage in 48/64 
iterations (that might be OBO but whatever). I haven't used any 64 bit 
machines other than ia64 (or used prefetching before for that matter), 
so let me know if my logic is wrong. I do think that number could be 
tuned to a slightly better value, but 16 is nice and safe for now. And I 
only have ia64 boxes around.

> Here's a "Signed-off-by: Tony Luck <tony.luck@intel.com>" that
> you can cut-n-paste onto the patch when you repost to LKML.

Thanks.

>>Unfortunately, this still leaves a ~1 minute delay with no
>>indication of what is going on for 4TB machines, and ~2 minutes
>>for 8TB.
> 
> 
> Agreed that's long enough to cause worry, concern, even panic
> amongst nervous system administrators.  But I think that wli will
> hack this time down a lot more when he gets his patch together.
> So I'd like to wait and see what that looks like before I add the
> progress dots patch.

Sounds good.

-- 
Josh Aas
Silicon Graphics, Inc. (SGI)
Linux System Software
651-683-3068
