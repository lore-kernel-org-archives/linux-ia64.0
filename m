From: Dave Hansen <haveblue@us.ibm.com>
Date: Tue, 04 Jan 2005 23:45:42 +0000
Subject: Re: Prezeroing V3 [1/4]: Allow request for zeroed memory
Message-Id: <1104882342.16305.12.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F02900FBD@scsmsx401.amr.corp.intel.com>
	 <41C20E3E.3070209@yahoo.com.au>
	 <Pine.LNX.4.58.0412211154100.1313@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.58.0412231119540.31791@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.58.0412231132170.31791@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.58.0412231133130.31791@schroedinger.engr.sgi.com>
	 <Pine.GSO.4.61.0501011123550.27452@waterleaf.sonytel.be>
	 <Pine.LNX.4.58.0501041510430.1536@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.58.0501041512450.1536@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0501041512450.1536@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Development <linux-kernel@vger.kernel.org>

On Tue, 2005-01-04 at 15:13 -0800, Christoph Lameter wrote:
> +		if (gfp_flags & __GFP_ZERO) {
> +#ifdef CONFIG_HIGHMEM
> +			if (PageHighMem(page)) {
> +				int n = 1 << order;
> +
> +				while (n-- >0)
> +					clear_highpage(page + n);
> +			} else
> +#endif
> +			clear_page(page_address(page), order);
> +		}
>  		if (order && (gfp_flags & __GFP_COMP))
>  			prep_compound_page(page, order);

That #ifdef can probably die.  The compiler should get that all by
itself:

> #ifdef CONFIG_HIGHMEM
> #define PageHighMem(page)       test_bit(PG_highmem, &(page)->flags)
> #else
> #define PageHighMem(page)       0 /* needed to optimize away at compile time */
> #endif

-- Dave

