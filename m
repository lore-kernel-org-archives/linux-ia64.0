From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 18 Mar 2005 17:40:02 +0000
Subject: RE: [patch 2.6.11] __copy_user breaks on unaligned src
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F031D5F3C@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <12404.1111129477@kao2.melbourne.sgi.com>
In-Reply-To: <12404.1111129477@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>That's a good thing to fix (it's definitely a performance bug).  However,
>lfetch.fault should be safe to use even on unmapped memory.  See this
>code in ia64_do_page_fault():
>
> /*
>  * This fault was due to a speculative load or lfetch.fault, set the "ed"
>  * bit in the psr to ensure forward progress.  (Target register will get a
>  * NaT for ld.s, lfetch will be canceled.)
>  */
>
>I don't see off-hand why this wouldn't work as intended.

That reminds me ... someone asked why we don't have the same test for
lfetch a few lines further down in ia64_do_page_fault() in the "no_context"
case (we only test for speculative access there).

The context for their question was using __copy_from_user_inatomic() after
calling inc_preempt_count().  On ia64 this just uses the standard code for
__copy_from_user().  If we happen to fault on the "lfetch", then we end up
in the "no_context" case because of the "if (in_atomic() || !mm)" test at the
top of ia64_do_page_fault.

-Tony
