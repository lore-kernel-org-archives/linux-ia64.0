From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 06 Jan 2005 19:42:52 +0000
Subject: Re: [PATCH] cleanup swiotlb.c a bit
Message-Id: <200501061142.52267.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501060945.12364.jbarnes@engr.sgi.com>
In-Reply-To: <200501060945.12364.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday, January 6, 2005 11:38 am, David Mosberger wrote:
> >>>>> On Thu, 6 Jan 2005 09:45:12 -0800, Jesse Barnes
> >>>>> <jbarnes@engr.sgi.com> said:
>
>   Jesse> This patch mostly cleans up trailing whitespace
>
> That's OK, and really needed.  I was tempted to do that with my last
> swiotlb fix, but didn't want to mix formatting cleanups with real
> fixes.

Usually a good idea, I figured that a cleanup patch should stand by itself.

>   Jesse> and long lines
>
> Well, I don't like how you "fixed" some of them and I continue to be
> of the opinion that 100 cols is OK (yes, I know that somebody managed
> to get the 80 cols into the kernel formatting document, but that
> doesn't change reality...).

Yeah, I know, but your opinion is wrong :)  I often find myself editing files 
on VTs or other 80 col terminals, and long lines are a pain...

> For example, something like this:
>
> + io_tlb_start = alloc_bootmem_low_pages(io_tlb_nslabs *
> +            (1 << IO_TLB_SHIFT));
>
> I find more readable if it's formatted as:
>
>  io_tlb_start = alloc_bootmem_low_pages(io_tlb_nslabs
>             * (1 << IO_TLB_SHIFT));

I can change that, though I think the former is more common.

>   Jesse> gets rid of some unnecessary {} blocks.
>
> The blocks where there to indicate locking.  I find that useful, even
> if Andrew (and perhaps others) disagree.

I thought that might be controversial, I can change it back.

>   Jesse> Does it look ok to you David?  I was thinking it might be
>   Jesse> nice to abstract it slightly more to make the swiotlb
>   Jesse> functions callable from a platform's regular PCI mapping
>   Jesse> routines as needed, since swiotlb assumes that physical
>   Jesse> addresses and bus addresses are the same.
>
> Well, it probably should move outside of the ia64 tree anyhow.  The
> way x86_64 includes swiotlb.c at the moment is just absolutely gross.

That was going to be step two.  include/linux/swiotlb.h and lib/swiotlb.c seem 
like the right way to go in the long run, along with a few abstractions.

Thanks,
Jesse
