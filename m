From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 15 Dec 2004 17:00:18 +0000
Subject: Re: [PATCH] add legacy I/O and memory access routines to /proc/bus/pci API
Message-Id: <200412150900.18890.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200412140941.56116.jbarnes@engr.sgi.com> <200412141655.04416.bjorn.helgaas@hp.com> <1103101057.6246.19.camel@gaston>
In-Reply-To: <1103101057.6246.19.camel@gaston>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Bjorn Helgaas <bjorn.helgaas@hp.com>, linux-pci@atrey.karlin.mff.cu, linux-ia64@vger.kernel.org, Linux Kernel list <linux-kernel@vger.kernel.org>

On Wednesday, December 15, 2004 12:57 am, Benjamin Herrenschmidt wrote:
> > I think by "legacy I/O space", you mean specifically "legacy
> > I/O *port* space", right?  Maybe there's no current use for it,
> > but I can imagine supporting MMIO accesses this way, too.
>
> Legacy IO ports, there should be one space per PCI domain. There is also
> legacy ISA memory space though on some ppc's, this doesn't exist at all.
> I suspect we want to expose both in a way.

This interface exports both.

> > On i386, anyway ;-)  But on ia64, we support multiple 64k I/O port
> > spaces (one of them being the 0-64K space that corresponds to the
> > i386 "legacy" space).  Shouldn't we be able to access them with this
> > interface, too?
>
> We should imho. On ppc, we have a 64k space per domain. One of the main
> set of HW that has use for these are VGA cards. It's perfectly possible
> to have a Mac with an AGP card in the AGP port and a PCI video card in
> one of hte PCI slots, and those are on 2 different domains with
> different legacy (0...64k) IO spaces.
>
> We defininitely want whatever interface we define to deal with that.

Good, because that's exactly what it does.  The arch is responsible for 
returning the legacy I/O port or legacy ISA memory base address given a 
pci_dev, which is used as a base for the page offset passed into mmap.  So 
e.g. mmap(..., 0xa0000) after doing ioctl(fd, PCIIOC_MMAP_IS_LEGACY_MEM, ...) 
would get you the VGA framebuffer for the device corresponding to 'fd'.

> There is some work done by Jon Smirl in this area (a VGA access
> arbitration driver).

I think Dave Airlie did a version of the vga class driver, and the backend 
used for /proc/bus/pci could be used for both drivers.  I'm 
using /proc/bus/pci because it's available now and nearly good enough (i.e. 
this patch was all I needed to get going).

Anyway, I'll post another version with Bjorn's suggestion about the ioctl for 
choosing config or legacy I/O port read/writes, since it looks like the rest 
of your concerns are dealt with.

Thanks,
Jesse
