From: "Martin K. Petersen" <mkp@sgi.com>
Date: Wed, 13 Oct 2004 19:42:48 +0000
Subject: Re: [RFC] Convert pgtable cache to slab
Message-Id: <yq1is9etnev.fsf@wilson.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1zn2qtpyo.fsf@wilson.mkp.net>
In-Reply-To: <yq1zn2qtpyo.fsf@wilson.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Tony" = Luck, Tony <tony.luck@intel.com> writes:

>>> Perhaps "zero_cache" isn't as descriptive a name as it might be
>>> (not that I have any better suggestions :-(
>>  Maybe pgtable_zero_cache or something?

Tony> I thought along those lines at first, but actually this cache
Tony> would be useful for any allocation that needed a page that has
Tony> been pre-zeroed.  So I don't think that the "pgtable" part is
Tony> helpful.  Some sense of the fact that the objects are one page
Tony> big is what I was looking for.

Yeah.  I suspect that's why Bill named it that in the first place.

What about zeroed_page_cache?

Now, this opens up another can of worms in terms of where to
initialize that cache in the first place.  pgtable_cache_init() might
not be the best place if it's generally used.  Only requirement is
that it needs to be early.

-- 
Martin K. Petersen	Silicon Graphics, Inc.
mkp@sgi.com		http://www.sgi.com/
