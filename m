From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 06 Aug 2004 17:58:33 +0000
Subject: RE: free bootmem feedback patch
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F01CB2E55@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40F46962.4090604@sgi.com>
In-Reply-To: <40F46962.4090604@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Josh Aas wrote:
>Attached is an improved version of Tony Luck's patch. It 
>shaves another ~25% off by not using atomic ops to clear the
>page reserved bits and prefetching. Tony - will you sign off
>on it with me and we'll get this in?

Does the change:
-			ClearPageReserved(page);
+			(page)->flags &= ~(1UL << PG_reserved);

in the "else if (v)" clause actually make any difference?  I would
expect not (unless you have bizarrely fragmented memory), so you
could just leave the atomic operations there.

But it might be prettier to define a BootClearPageReserved() function
in page-flags.h rather than expose the details of the implementation
here in bootmem.c (in which case you could use this new function
in the "else if (v)" clause too for symmetry).

Finally you have a magic "16" in the prefetchw() path.  Where did
it come from, and is it the right number for non-ia64 machines?

Here's a "Signed-off-by: Tony Luck <tony.luck@intel.com>" that
you can cut-n-paste onto the patch when you repost to LKML.

>Unfortunately, this still leaves a ~1 minute delay with no
>indication of what is going on for 4TB machines, and ~2 minutes
>for 8TB.

Agreed that's long enough to cause worry, concern, even panic
amongst nervous system administrators.  But I think that wli will
hack this time down a lot more when he gets his patch together.
So I'd like to wait and see what that looks like before I add the
progress dots patch.

-Tony
