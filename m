From: Robin Holt <holt@sgi.com>
Date: Wed, 13 Oct 2004 19:50:47 +0000
Subject: Re: [RFC] Convert pgtable cache to slab
Message-Id: <20041013195047.GB11320@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1zn2qtpyo.fsf@wilson.mkp.net>
In-Reply-To: <yq1zn2qtpyo.fsf@wilson.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Oct 13, 2004 at 03:42:48PM -0400, Martin K. Petersen wrote:
> >>>>> "Tony" = Luck, Tony <tony.luck@intel.com> writes:
> 
> >>> Perhaps "zero_cache" isn't as descriptive a name as it might be
> >>> (not that I have any better suggestions :-(
> >>  Maybe pgtable_zero_cache or something?
> 
> Tony> I thought along those lines at first, but actually this cache
> Tony> would be useful for any allocation that needed a page that has
> Tony> been pre-zeroed.  So I don't think that the "pgtable" part is
> Tony> helpful.  Some sense of the fact that the objects are one page
> Tony> big is what I was looking for.
> 
> Yeah.  I suspect that's why Bill named it that in the first place.
> 
> What about zeroed_page_cache?
> 
> Now, this opens up another can of worms in terms of where to
> initialize that cache in the first place.  pgtable_cache_init() might
> not be the best place if it's generally used.  Only requirement is
> that it needs to be early.

Why don't we start with it here and move the init when we know who
the other users will be.  Just my 2 cents.

Robin

> 
> -- 
> Martin K. Petersen	Silicon Graphics, Inc.
> mkp@sgi.com		http://www.sgi.com/
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
