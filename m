From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 06 Aug 2004 20:09:34 +0000
Subject: RE: free bootmem feedback patch
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F01CB2F0B@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40F46962.4090604@sgi.com>
In-Reply-To: <40F46962.4090604@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>I'll go ahead and create a macro for the non-atomic bit clear. Perhaps 
>call it "ClearPageReservedNoAtomic" instead of "BootClearPageReserved"?

That looks like a more meaningful name than my suggestion.

>> Finally you have a magic "16" in the prefetchw() path.  Where did
>> it come from, and is it the right number for non-ia64 machines?
>
>My bad for not explaining that. In my limited testing of this particular 
>number it seemed to be the sweet spot for prefetching. I think it is a 
>good number for all architectures because 32 bit architectures won't 
>need the speed boost as much as 64 bit architectures. They are not 
>likely to have > 4GB memory,, in which case this function's time is 
>probably less than 1 second anyway.

There are quite a few x86 boxes running with 16GB ... but the max
is 64GB, which is still below the pain threshold for seeing an
unreasonable delay during this routine ... so I agree that perfect
tuning is irrelevent for 32-bit machines here.  You should include
your explanatory paragraph when you post to LKML.

-Tony
