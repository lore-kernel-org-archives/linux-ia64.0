From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Sat, 24 Dec 2011 07:00:14 +0000
Subject: Re: [PATCH 00/14] DMA-mapping framework redesign preparation
Message-Id: <1324710014.6632.23.camel@pasglop>
List-Id: <linux-ia64.vger.kernel.org>
References: <1324643253-3024-1-git-send-email-m.szyprowski@samsung.com>
	 <20111223163516.GO20129@parisc-linux.org>
In-Reply-To: <20111223163516.GO20129@parisc-linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Stephen Rothwell <sfr@canb.auug.org.au>, microblaze-uclinux@itee.uq.edu.au, linux-arch@vger.kernel.org, x86@kernel.org, linux-sh@vger.kernel.org, linux-alpha@vger.kernel.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mips@linux-mips.org, discuss@x86-64.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Jonathan Corbet <corbet@lwn.net>, Kyungmin Park <kyungmin.park@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>

On Fri, 2011-12-23 at 09:35 -0700, Matthew Wilcox wrote:
> I really think this wants to be a separate function.
> dma_alloc_coherent
> is for allocating memory to be shared between the kernel and a driver;
> we already have dma_map_sg for mapping userspace I/O as an alternative
> interface.  This feels like it's something different again rather than
> an option to dma_alloc_coherent. 

Depends. There can be some interesting issues with some of the ARM stuff
out there (and to a lesser extent older ppc embedded stuff).

For example, some devices really want a physically contiguous chunk, and
are not cache coherent. In that case, you can't keep the linear mapping
around. But you also don't waste your precious kernel virtual space
creating a separate non-cachable mapping for those.

In general, dma mapping attributes as a generic feature make sense,
whether this specific attribute does or not though. And we probably want
space for platform specific attributes, for example, FSL embedded
iommu's have "interesting" features for directing data toward a specific
core cache etc... that we might want to expose using such attributes.

Cheers,
Ben.


