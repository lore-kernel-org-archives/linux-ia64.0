From: Christoph Hellwig <hch@infradead.org>
Date: Sun, 18 Jun 2017 07:09:25 +0000
Subject: Re: [PATCH 03/44] dmaengine: ioat: don't use DMA_ERROR_CODE
Message-Id: <20170618070925.GA18526@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170616181059.19206-1-hch@lst.de>
 <20170616181059.19206-4-hch@lst.de>
 <CAKgT0UdxrimWrxNVsLMQ9G6ABBJZwfWHTcP18qqd4rT0Fa-KWg@mail.gmail.com>
In-Reply-To: <CAKgT0UdxrimWrxNVsLMQ9G6ABBJZwfWHTcP18qqd4rT0Fa-KWg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: Christoph Hellwig <hch@lst.de>, the arch/x86 maintainers <x86@kernel.org>, linux-arm-kernel@lists.infradead.org, xen-devel@lists.xenproject.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, openrisc@lists.librecores.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, dmaengine@vger.kernel.org, linux-tegra@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-samsung-soc@vger.kernel.org, "open list:INTEL IOMMU (VT-d)" <iommu@lists.linux-foundation.org>, Netdev <netdev@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Jun 16, 2017 at 01:40:24PM -0700, Alexander Duyck wrote:
> dma_unmap_page on dest_dma if "op = IOAT_OP_XOR"? Odds are it is what
> the compiler is already generating and will save a few lines of code
> so what you end up with is something like:

Honestly wanted to touch the code as little as possible :)  If we want
to make it prettier and more readable it needs to be refactored.

If you're interested I can take a stab at that, but I'd like to keep
it out of this already giant series.
