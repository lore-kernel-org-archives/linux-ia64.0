From: Robin Holt <holt@sgi.com>
Date: Fri, 10 Sep 2004 08:28:33 +0000
Subject: Re: [RFC 2/2] Add SN2 Special Memory driver.
Message-Id: <20040910082833.GC25060@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040909175425.GB23863@lnx-holt.americas.sgi.com>
In-Reply-To: <20040909175425.GB23863@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Sep 10, 2004 at 08:41:13AM +0100, Christoph Hellwig wrote:
> > Index: linux-2.6/arch/ia64/sn/kernel/mspec.c
> > =================================> > --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> > +++ linux-2.6/arch/ia64/sn/kernel/mspec.c	2004-09-09 10:53:55.000000000 -0500
> > @@ -0,0 +1,658 @@
> > +/*
> > + * SN Platform Special Memory (mspec) Support
> > + *
> > + * This driver exports the SN special memory (mspec) facility to user processes.
> > + * There are three types of memory made available thru this driver:
> > + * fetchops, uncached and cached.
> > + *
> > + * Fetchops are atomic memory operations that are implemented in the
> > + * memory controller on SGI SN hardware.
> > + *
> > + * Uncached are used for memory write combining feature of the ia64
> > + * cpu.
> > + *
> > + * Cached are used for areas of memory that are used as cached addresses
> > + * on our partition and used as uncached addresses from other partitions.
> > + * Due to a design constraint of the SN2 Shub, you can not have processors
> > + * on the same FSB perform both a cached and uncached reference to the
> > + * same cache line.  These special memory cached regions prevent the
> > + * kernel from ever dropping in a TLB entry and therefore prevent the
> > + * processor from ever speculating a cache line from this page.
> > + */
> > +
> > +/*
> > + * Copyright (C) 2001-2004 Silicon Graphics, Inc.  All rights
> > + * reserved.
> > + *
> > + * This program is free software; you can redistribute it and/or modify it
> > + * under the terms of version 2 of the GNU General Public License
> > + * as published by the Free Software Foundation.
> > + */
> 
> Usually the copyright headerz is before the description.

Fixed.

> 
> Index: linux-2.6/mm/page_alloc.c
> > =================================> > --- linux-2.6.orig/mm/page_alloc.c	2004-09-09 09:22:31.000000000 -0500
> > +++ linux-2.6/mm/page_alloc.c	2004-09-09 10:53:55.000000000 -0500
> > @@ -42,6 +42,7 @@
> >  int numnodes = 1;
> >  int sysctl_lower_zone_protection = 0;
> >  
> > +EXPORT_SYMBOL(numnodes);
> 
> Umm, we had that as part of the xp module already and don't want this one
> as a public API.

Can you make a wrapper that uses the existing cnode, numnodes, et al that
will be compatible with the new way of looking at other nodes.  Without it,
all work with node specific stuff seems to be on hold.

> 
> >  
> >  /*
> > + * Walks the EFI memory map and calls 'callback' once for each EFI memory
> > + * descriptor that has memory marked as only EFI_MEMORY_UC.
> > + */
> > +void
> > +efi_memmap_walk_uc (efi_freemem_callback_t callback, void *arg)
> 
> See the thread starting in
> http://www.gelato.unsw.edu.au/linux-ia64/0307/6218.html how to do this
> properly.

I guess I don't see a resolution in this discussion.  Has this work been
done?  I didn't stumble across anything in the kernel.
