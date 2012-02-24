From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 24 Feb 2012 15:48:59 +0000
Subject: Re: [PATCH 00/14] DMA-mapping framework redesign preparation
Message-Id: <201202241548.59791.arnd@arndb.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1324643253-3024-1-git-send-email-m.szyprowski@samsung.com>
In-Reply-To: <1324643253-3024-1-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, microblaze-uclinux@itee.uq.edu.au, linux-arch@vger.kernel.org, x86@kernel.org, linux-sh@vger.kernel.org, linux-alpha@vger.kernel.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mips@linux-mips.org, discuss@x86-64.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Jonathan Corbet <corbet@lwn.net>, Kyungmin Park <kyungmin.park@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>

On Friday 23 December 2011, Marek Szyprowski wrote:
> The solution we found is to introduce a new public dma mapping functions
> with additional attributes argument: dma_alloc_attrs and
> dma_free_attrs(). This way all different kinds of architecture specific
> buffer mappings can be hidden behind the attributes without the need of
> creating several versions of dma_alloc_ function.

Since the patches are now in linux-next, we should make sure that they
can actually get merged into 3.4.

I've looked at all the patches again and found them to be straightforward
and helpful, I hope we can get them merged next time. Please add my

Reviewed-by: Arnd Bergmann <arnd@arndb.de>
