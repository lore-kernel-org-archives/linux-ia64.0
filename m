From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 29 Mar 2016 19:32:07 +0000
Subject: Re: [PATCH 2/3] swiotlb: prefix dma_to_phys and phys_to_dma functions
Message-Id: <6420021.rzhE3kJKJP@wuerfel>
List-Id: <linux-ia64.vger.kernel.org>
References: <1458252137-24497-1-git-send-email-okaya@codeaurora.org> <56EC1805.5060207@codeaurora.org> <CACJDEmrzKOExg-Rchjy2hfVzkzbCZ=WNn4Bu3EVgim748VvRig@mail.gmail.com>
In-Reply-To: <CACJDEmrzKOExg-Rchjy2hfVzkzbCZ=WNn4Bu3EVgim748VvRig@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org, Denys Vlasenko <dvlasenk@redhat.com>
Cc: Konrad Rzeszutek Wilk <konrad@kernel.org>, Sinan Kaya <okaya@codeaurora.org>, linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Max Filippov <jcmvbkbc@gmail.com>, Chris Metcalf <cmetcalf@ezchip.com>, Paul Mackerras <paulus@samba.org>, "H. Peter Anvin" <hpa@zytor.com>, Huacai Chen <chenhc@lemote.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Jisheng Zhang <jszhang@marvell.com>, Florian Fainelli <f.fainelli@gmail.com>, Russell King <linux@arm.linux.org.uk>, Aaro Koskinen <aaro.koskinen@iki.fi>, Michael Ellerman <mpe@ellerman.id.au>, timur@codeaurora.org, X86 <x86@kernel.org>, Ingo Molnar <mingo@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Guenter Roeck <linux@roeck-us.net>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Akinobu Mita <akinobu.mita@gmail.com>, cov@codeaurora.org, Bjorn Helgaas <bhelgaas@google.com>, Thomas Gleixner <tglx@linutronix.de>, Valentin Rothberg <valentinrothberg@gmail.com>, Chris Zankel <chris@zankel.net>, Tony Luck <tony.luck@intel.com>, linux-pci@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, Dean Nelson <dnelson@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Ralf Baechle <ralf@linux-mips.org>, "Suthikulpanit, Suravee" <Suravee.Suthikulpanit@amd.com>, Joe Perches <joe@perches.com>, Andrew Morton <akpm@linux-foundation.org>, Robin Murphy <robin.murphy@arm.com>, nwatters@codeaurora.org

On Monday 28 March 2016 14:29:29 Konrad Rzeszutek Wilk wrote:
> > diff --git a/arch/arm64/mm/dma-mapping.c b/arch/arm64/mm/dma-mapping.c
> > index ada00c3..8c0f66b 100644
> > --- a/arch/arm64/mm/dma-mapping.c
> > +++ b/arch/arm64/mm/dma-mapping.c
> > @@ -29,6 +29,14 @@
> >
> >  #include <asm/cacheflush.h>
> >
> > +/*
> > + * If you are building a system without IOMMU, then you are using SWIOTLB
> > + * library. The ARM64 adaptation of this library does not support address
> > + * translation and it assumes that physical address = dma address for such
> > + * a use case. Please don't build a platform that violates this.
> > + */
> 
> Why not just expand the ARM64 part to support address translation?

Because so far all hardware we have is relatively sane. We only
need to implement this if someone accidentally puts their DMA
space at the wrong address.

There is at least one platform that could in theory use this because
their RAM starts at an address that is outside of the reach of 32-bit
devices, and a static IOMMU mapping (created by firmware) could be
used to map the start of RAM into DMA address zero, to avoid having
to use an IOMMU all the time, but it was considered not worth the
effort to implement that.

	Arnd
