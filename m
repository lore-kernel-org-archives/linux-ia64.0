From: Andi Kleen <ak@suse.de>
Date: Mon, 18 Oct 2004 21:06:59 +0000
Subject: Re: [PATCH] General purpose zeroed page slab
Message-Id: <20041018210658.GA8203@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1oej5s0po.fsf@wilson.mkp.net> <20041014180427.GA7973@wotan.suse.de> <yq1ekjvrjd6.fsf@wilson.mkp.net> <20041018184210.GI16153@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20041018184210.GI16153@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: "Martin K. Petersen" <mkp@wildopensource.com>, Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, akpm@osdl.org, tony.luck@intel.com

> It's probably worth doing this with a static cachep in slab.c and only
> exposing a get_zeroed_page() / free_zeroed_page() interface, with the
> latter doing the memset to 0.  

Putting a memset in there would be dumb because the mm cleanup already
zeroes the page tables.

My dirty bitmap proposal would make that faster however, same as 
copy_page_range et.al.

> I disagree with Andi over the dumbness
> of zeroing the whole page.  That makes it cache-hot, which is what you
> want from a page you allocate from slab.

It's already cache hot from the page table free and you only want one cache
line in it cache hot, not the whole page.

-Andi
