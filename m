From: Robin Holt <holt@sgi.com>
Date: Fri, 10 Sep 2004 11:16:34 +0000
Subject: Re: [RFC 2/2] Add SN2 Special Memory driver.
Message-Id: <20040910111634.GE25060@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040909175425.GB23863@lnx-holt.americas.sgi.com>
In-Reply-To: <20040909175425.GB23863@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> > Index: linux-2.6/mm/page_alloc.c
> > > =================================> > > --- linux-2.6.orig/mm/page_alloc.c	2004-09-09 09:22:31.000000000 -0500
> > > +++ linux-2.6/mm/page_alloc.c	2004-09-09 10:53:55.000000000 -0500
> > > @@ -42,6 +42,7 @@
> > >  int numnodes = 1;
> > >  int sysctl_lower_zone_protection = 0;
> > >  
> > > +EXPORT_SYMBOL(numnodes);
> > 
> > Umm, we had that as part of the xp module already and don't want this one
> > as a public API.
> 
> Can you make a wrapper that uses the existing cnode, numnodes, et al that
> will be compatible with the new way of looking at other nodes.  Without it,
> all work with node specific stuff seems to be on hold.

When is the node_online_mask (or whatever it is called) expected to be in
the mainline kernel?  Can we get a compatibility function written so we
can continue moving forward until then?

> > >  /*
> > > + * Walks the EFI memory map and calls 'callback' once for each EFI memory
> > > + * descriptor that has memory marked as only EFI_MEMORY_UC.
> > > + */
> > > +void
> > > +efi_memmap_walk_uc (efi_freemem_callback_t callback, void *arg)
> > 
> > See the thread starting in
> > http://www.gelato.unsw.edu.au/linux-ia64/0307/6218.html how to do this
> > properly.
> 
> I guess I don't see a resolution in this discussion.  Has this work been
> done?  I didn't stumble across anything in the kernel.

This allocator seems like a really big hammer for a fairly small nail.
Since there has not really been a demonstrated need for an allocator
that works on less than a page size, can we reimplement something like
the page_alloc function and then later on, the entity needing an allocation
of less than a page can write their own slab type allocator on top of
this?

Are there any other suggestions besides me having to write a large allocator
which will only be used to hand out page sized, page aligned chunks of
memory?

Thanks,
Robin
