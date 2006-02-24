From: "'David Gibson'" <david@gibson.dropbear.id.au>
Date: Fri, 24 Feb 2006 04:05:43 +0000
Subject: Re: [patch] fix ia64 hugetlb_free_pgd_range
Message-Id: <20060224040543.GE28368@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060224024431.GC28368@localhost.localdomain> <200602240305.k1O35Ng06352@unix-os.sc.intel.com>
In-Reply-To: <200602240305.k1O35Ng06352@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Hugh Dickins' <hugh@veritas.com>, "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Feb 23, 2006 at 07:05:23PM -0800, Chen, Kenneth W wrote:
> David Gibson wrote on Thursday, February 23, 2006 6:45 PM
> > However... I suspect in fact that the transformations should be
> > unconditional.
> 
> No, that won't be correct.

But I don't see how not transforming them sometimes can be correct.
Suppose 'floor' is only a little way below 'addr' - addr will be
shifted down, but floor won't, so floor may now be above addr, which
will cause weird results.

Afaict the *only* thing floor and ceiling are used for is bounds
checking the address range we're examining.  How can that ever be
right if one address has been scaled down, but the other hasn't.

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson
