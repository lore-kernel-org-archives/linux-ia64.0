From: Robin Holt <holt@sgi.com>
Date: Wed, 02 Mar 2005 20:44:37 +0000
Subject: Re: [Patch 1/3] Reclaim pmd and pte entries to quicklists.
Message-Id: <20050302204437.GA16903@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050226142541.GE10965@lnx-holt.americas.sgi.com>
In-Reply-To: <20050226142541.GE10965@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Mar 02, 2005 at 10:43:41AM -0800, David Mosberger wrote:
> >>>>> On Wed, 2 Mar 2005 12:33:25 -0600, Robin Holt <holt@sgi.com> said:
> 
>   >> I wasn't suggesting to support multiple sizes, just to add a
>   >> BUG_ON(size != PAGE_SIZE) or something like that.
> 
>   Robin> What is the motivation for this?
> 
> To make the kernel more resilient against inconsistencies.  Sure, it
> won't be perfect, but while mucking with it anyway, why not improve
> it?  Me thinks you'd want something along the lines of:
> 
> pgd_alloc:
> 
> 	...
> 	pgd = alloc_one_fast(mm, PTRS_PER_PGD * sizeof(pgd_t));

Since the size of page tables does not change on a running system,
would you accept three BUG_ONs in mm/init.c that check pgd, pmd, and
pte allocation sizes?  That will be clearer and definitely not have any
chance of impacting runtime.

Thanks,
Robin
