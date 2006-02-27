From: David Gibson <david@gibson.dropbear.id.au>
Date: Mon, 27 Feb 2006 00:27:42 +0000
Subject: Re: [patch] fix ia64 hugetlb_free_pgd_range
Message-Id: <20060227002742.GC24422@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <B05667366EE6204181EABE9C1B1C0EB509C43438@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B05667366EE6204181EABE9C1B1C0EB509C43438@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: Hugh Dickins <hugh@veritas.com>, "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Feb 23, 2006 at 10:30:39PM -0800, Chen, Kenneth W wrote:
> David Gibson wrote on Thursday, February 23, 2006 8:06 PM
> > But I don't see how not transforming them sometimes can be correct.
> > Suppose 'floor' is only a little way below 'addr' - addr will be
> > shifted down, but floor won't, so floor may now be above addr, which
> > will cause weird results.
> > 
> > Afaict the *only* thing floor and ceiling are used for is bounds
> > checking the address range we're examining.  How can that ever be
> > right if one address has been scaled down, but the other hasn't.
> 
> The scale down isn't exactly on every address bits.  Top 3 bits of
> virtual address are preserved.

Ah.. yes.

> #define htlbpage_to_page(x)    (((unsigned long) REGION_NUMBER(x) << 61)
>                                  | (REGION_OFFSET(x) >>
> (HPAGE_SHIFT-PAGE_SHIFT)))
> 
> So scaled address for a hugetlb address will never be below unscaled
> normal page address.  That is adjusted addr will never below unchanged
> floor.

Ok.  So in fact it wouldn't matter whether or not addresses outside
the region are scaled, but conceptually they probably should be.

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson
