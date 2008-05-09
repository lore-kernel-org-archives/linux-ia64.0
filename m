From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 09 May 2008 15:21:32 +0000
Subject: Re: [PATCH 0/3] ia64: Migrate data off physical pages with correctable
Message-Id: <alpine.LFD.1.10.0805090817280.3142@woody.linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080509150937.GA16523@sgi.com>
In-Reply-To: <20080509150937.GA16523@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russ Anderson <rja@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Christoph Lameter <clameter@sgi.com>



On Fri, 9 May 2008, Russ Anderson wrote:
> 
>   [2/3] page.discard.v2: Avoid putting a bad page back on the LRU.
> 
> 	page.discard are the arch independent changes.  It adds a new
> 	page flag (PG_memerror) to mark the page as bad and prevent it
> 	from being put back on the LRU.  PG_memerror is only defined
> 	on 64 bit architectures. 

So I haven't looked at this a lot, but it strikes me that it look to be 
much simple if you were to just increment the page count instead of 
playing games in mm/page_alloc.c.

That will make sure that it never goes back on any free lists, and 
requires no changes to the allocator. Hmm?

I'm also not really seeing why this triggers on lru_cache_add(), since 
that should only happen to new pages anyway. Who does lru_cache_add() on 
old pages?

			Linus
