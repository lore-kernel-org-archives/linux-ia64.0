From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 09 May 2008 16:38:25 +0000
Subject: Re: [PATCH 0/3] ia64: Migrate data off physical pages with correctable
Message-Id: <Pine.LNX.4.64.0805090935520.18195@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080509150937.GA16523@sgi.com>
 <alpine.LFD.1.10.0805090817280.3142@woody.linux-foundation.org>
In-Reply-To: <alpine.LFD.1.10.0805090817280.3142@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Russ Anderson <rja@sgi.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>

On Fri, 9 May 2008, Linus Torvalds wrote:

> So I haven't looked at this a lot, but it strikes me that it look to be 
> much simple if you were to just increment the page count instead of 
> playing games in mm/page_alloc.c.

We are taking a refcount when isolating the page from the LRU. The 
problem is that the migration code attempts to free the page. That code 
could be changed to do something else instead like putting the page on the 
bad list.
 
> I'm also not really seeing why this triggers on lru_cache_add(), since 
> that should only happen to new pages anyway. Who does lru_cache_add() on 
> old pages?

Migration code does the adding back to the LRU when migration is complete. 
So he hooked into that I guess.

