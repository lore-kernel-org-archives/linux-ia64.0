From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 16 Dec 2004 16:26:31 +0000
Subject: Re: [PATCH] add legacy I/O and memory access routines to /proc/bus/pci API
Message-Id: <200412160826.32315.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200412140941.56116.jbarnes@engr.sgi.com> <200412150900.18890.jbarnes@engr.sgi.com> <1103208922.25262.10.camel@gaston>
In-Reply-To: <1103208922.25262.10.camel@gaston>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Bjorn Helgaas <bjorn.helgaas@hp.com>, linux-ia64@vger.kernel.org, Linux Kernel list <linux-kernel@vger.kernel.org>

On Thursday, December 16, 2004 6:55 am, Benjamin Herrenschmidt wrote:
> On Wed, 2004-12-15 at 09:00 -0800, Jesse Barnes wrote:
> > Good, because that's exactly what it does.  The arch is responsible for
> > returning the legacy I/O port or legacy ISA memory base address given a
> > pci_dev, which is used as a base for the page offset passed into mmap. 
> > So e.g. mmap(..., 0xa0000) after doing ioctl(fd,
> > PCIIOC_MMAP_IS_LEGACY_MEM, ...) would get you the VGA framebuffer for the
> > device corresponding to 'fd'.
>
> Sounds good... The only thing is a pci_dev may not be available if you
> have a PCI->ISA bridge, tho you may just use the pci_dev of the
> bridge...

Well, you'll have to have a fake one at least.  Remember the fds used in the 
above example come from fd = open("/proc/bus/pci/BB/SS.F", O_RDWR)...

Jesse
