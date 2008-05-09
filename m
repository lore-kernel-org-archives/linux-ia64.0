From: Russ Anderson <rja@sgi.com>
Date: Fri, 09 May 2008 16:27:35 +0000
Subject: Re: [PATCH 0/3] ia64: Migrate data off physical pages with correctable errors v3
Message-Id: <20080509162734.GA11841@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080509150937.GA16523@sgi.com> <alpine.LFD.1.10.0805090817280.3142@woody.linux-foundation.org>
In-Reply-To: <alpine.LFD.1.10.0805090817280.3142@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Christoph Lameter <clameter@sgi.com>

On Fri, May 09, 2008 at 08:21:32AM -0700, Linus Torvalds wrote:
> On Fri, 9 May 2008, Russ Anderson wrote:
> > 
> >   [2/3] page.discard.v2: Avoid putting a bad page back on the LRU.
> > 
> > 	page.discard are the arch independent changes.  It adds a new
> > 	page flag (PG_memerror) to mark the page as bad and prevent it
> > 	from being put back on the LRU.  PG_memerror is only defined
> > 	on 64 bit architectures. 
> 
> So I haven't looked at this a lot, but it strikes me that it look to be 
> much simple if you were to just increment the page count instead of 
> playing games in mm/page_alloc.c.

FWIW, that is how the ia64 mca_recovery code prevents pages with
uncorrectable errors from getting reused.

> That will make sure that it never goes back on any free lists, and 
> requires no changes to the allocator. Hmm?

I tried incrementing the page count but it did not play well with the
migration code (mm/migrate.c).  The migration code is used to copy
the data off the bad page to a new good page.  It currently will
try to free the old page after migrating.  My attempts to modify
that behavior would result in either the migration code not migrating
or pages with non zero page counts on a free list.

> I'm also not really seeing why this triggers on lru_cache_add(), since 
> that should only happen to new pages anyway. Who does lru_cache_add() on 
> old pages?

unmap_and_move() calls move_to_lru() which calls lru_cache_add().
This code only deals with pages that can be isolated. (isolate_lru_page())

> 
> 			Linus

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
