From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Mon, 13 Jul 2009 09:16:30 +0000
Subject: Re: [00/15] swiotlb cleanup
Message-Id: <20090713181558B.fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1247234512.4002.417.camel@zakaz.uk.xensource.com>
	<20090710141248.GE26264@elte.hu>
	<20090713131157V.fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <20090713131157V.fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mingo@elte.hu
Cc: Ian.Campbell@eu.citrix.com, jeremy@goop.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org, benh@kernel.crashing.org, tony.luck@intel.com, x86@kernel.org, beckyb@kernel.crashing.org, joerg.roedel@amd.com

On Mon, 13 Jul 2009 13:20:22 +0900
FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp> wrote:

> On Fri, 10 Jul 2009 16:12:48 +0200
> Ingo Molnar <mingo@elte.hu> wrote:
> 
> > > functionality and reimplemented the surrounding infrastructure in 
> > > terms of that (and incorporating our additional requirements). I 
> > > prototyped this (it is currently unworking, in fact it seems to 
> > > have developed rather a taste for filesystems :-() but the 
> > > diffstat of my WIP patch is:
> > >
> > >          arch/x86/kernel/pci-swiotlb.c |    6 
> > >          arch/x86/xen/pci-swiotlb.c    |    2 
> > >          drivers/pci/xen-iommu.c       |  385 ++++++++++++++++++++++++++++++++++++++++--
> > >          include/linux/swiotlb.h       |   12 +
> > >          lib/swiotlb.c                 |   10 -
> > >          5 files changed, 385 insertions(+), 30 deletions(-)
> > >
> > > where a fair number of the lines in xen-iommu.c are copies of 
> > > functions from swiotlb.c with minor modifications. As I say it 
> > > doesn't work yet but I think it's roughly indicative of what such 
> > > an approach would look like. I don't like it much but am happy to 
> > > run with it if it looks to be the most acceptable approach. [...]
> > 
> > +400 lines of code to avoid much fewer lines of generic code impact 
> > on the lib/swiotlb.c side sounds like a bad technical choice to me. 
> 
> The amount of code is not the point. The way to impact on the
> lib/swiotlb.c is totally wrong from the perspective of the kernel
> design; it uses architecture code in the very original (xen) way.

btw, '+400 lines of code to avoid much fewer lines of generic code
impact on the lib/swiotlb.c' doesn't sound true to me.

Here is a patch in the way that Xen people want to do:

http://patchwork.kernel.org/patch/26343/

---
 arch/x86/Kconfig                 |    4 +
 arch/x86/include/asm/io.h        |    2 +
 arch/x86/include/asm/pci_x86.h   |    1 +
 arch/x86/include/asm/xen/iommu.h |   12 ++
 arch/x86/kernel/pci-dma.c        |    3 +
 arch/x86/pci/Makefile            |    1 +
 arch/x86/pci/init.c              |    6 +
 arch/x86/pci/xen.c               |   51 +++++++
 drivers/pci/Makefile             |    2 +
 drivers/pci/xen-iommu.c          |  271 ++++++++++++++++++++++++++++++++++++++


Even with the way that Xen people want to do, drivers/pci/xen-iommu.c
is about 300 lines. And my patchset removes the nice amount of lines
for dom0 support. I don't see much difference wrt lines.
