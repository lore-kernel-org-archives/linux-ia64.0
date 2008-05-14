From: Russ Anderson <rja@sgi.com>
Date: Wed, 14 May 2008 21:30:02 +0000
Subject: Re: [PATCH 1/3] mm: Minor clean-up of page flags in mm/page_alloc.c v4
Message-Id: <20080514213001.GA13702@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080513230220.GB26722@sgi.com> <alpine.LFD.1.10.0805141321020.3019@woody.linux-foundation.org>
In-Reply-To: <alpine.LFD.1.10.0805141321020.3019@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Christoph Lameter <clameter@sgi.com>

On Wed, May 14, 2008 at 01:28:53PM -0700, Linus Torvalds wrote:
> On Tue, 13 May 2008, Russ Anderson wrote:
> >
> > Minor source code cleanup of page flags in mm/page_alloc.c.  
> 
> Could we (a) make the naming reflect the *use* rather than the flags 
> involved and (b) perhaps add a comment about that use at the point of 
> definition?

Yes, will do.  The reason for the cleanup is the following patch
defines PG_memerror, but only on configs with extended page flags.
So checking them in page_alloc.c would require adding #ifdef, which
would be rather ugly.  Moving the definitions into page-flags.h
allows the #ifdef to be in the header file rather than the C code.

From page.discard.v4:
+#ifdef CONFIG_PAGEFLAGS_EXTENDED
+PAGEFLAG(MemError, memerror)
+#define        PAGE_FLAGS      (PAGE_FLAGS_BASE | 1UL << PG_memerror)
+#else
+PAGEFLAG_FALSE(MemError)
+#define        PAGE_FLAGS      (PAGE_FLAGS_BASE)
+#endif

 
> > @@ -237,16 +237,7 @@ static void bad_page(struct page *page)
> >  	printk(KERN_EMERG "Trying to fix it up, but a reboot is needed\n"
> >  		KERN_EMERG "Backtrace:\n");
> >  	dump_stack();
> > -	page->flags &= ~(1 << PG_lru	|
> > -			1 << PG_private |
> > -			1 << PG_locked	|
> > -			1 << PG_active	|
> > -			1 << PG_dirty	|
> > -			1 << PG_reclaim |
> > -			1 << PG_slab    |
> > -			1 << PG_swapcache |
> > -			1 << PG_writeback |
> > -			1 << PG_buddy );
> > +	page->flags &= ~(PAGE_FLAGS_RECLAIM);
> 
> Because here I'm now otherwise looking at the code, and I wonder
>  - why the extra odd parenthesis?
>  - what does PAGE_FLAG_RECLAIM mean?
> 
> and it would be much nicer (I think) if the mask was instead called 
> something that reflected what it was all about, ie something along the 
> lines of PAGE_FLAG_CLEAR_WHEN_BAD instead.

I'll make those changes.

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
