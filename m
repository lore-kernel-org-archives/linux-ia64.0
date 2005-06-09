From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 09 Jun 2005 22:26:39 +0000
Subject: Re: [PATCH 00/10] IOCHK interface for I/O error handling/detecting
Message-Id: <1118355999.6850.177.camel@gaston>
List-Id: <linux-ia64.vger.kernel.org>
References: <42A8386F.2060100@jp.fujitsu.com>
	 <20050609171332.GC24611@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20050609171332.GC24611@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Linas Vepstas <linas@austin.ibm.com>, long <tlnguyen@snoqualmie.dp.intel.com>, linux-pci@atrey.karlin.mff.cuni.cz, linuxppc64-dev <linuxppc64-dev@ozlabs.org>


> It makes sense to sandwich other kinds of device accesses.  I don't
> think the previous clear/read_pci_errors() interface was intended *only*
> to sandwich readX().

On many platforms, only read() is guaranteed to reliably report errors
though.

> > - Additionally adds special token - abstract "iocookie" structure
> >   to control/identifies/manage I/Os, by passing it to OS.
> >   Actual type of "iocookie" could be arch-specific. Device drivers
> >   could use the iocookie structure without knowing its detail.
> 
> I'm not sure we need this.  Surely it can be deduced from the pci_dev or
> struct device?

Might be useful to know more though, wether it was PIO or MMIO or other
things. Also, I'd like to carry around the possible error details as can
be returned by the firmware in some platforms.

In fact, Is there any reason this is not ioerr_cookie instead of
iocookie ? :)

> > Expected usage(sample) is:
> > ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> > #include <linux/pci.h>
> > #include <asm/io.h>
> > 
> > int sample_read_with_iochk(struct pci_dev *dev, u32 *buf, int words)
> > {
> >     unsigned long ofs = pci_resource_start(dev, 0) + DATA_OFFSET;
> >     int i;
> > 
> >     /* Create magical cookie on the stack */
> >     iocookie cookie;
> > 
> >     /* Critical section start */
> >     iochk_clear(&dev, &cookie);
> >     {
> >         /* Get the whole packet of data */
> >         for (i = 0; i < words; i++)
> >             *buf++ = ioread32(dev, ofs);
> 
> You do know that ioread32() doesn't take a pci_dev, right?  I hope you
> weren't counting on that for the rest of your implementation.
> 
> >     }
> >     /* Critical section end. Did we have any trouble? */
> >     if ( iochk_read(&cookie) ) return -1;
> > 
> >     /* OK, all system go. */
> >     return 0;
> > }
> 

