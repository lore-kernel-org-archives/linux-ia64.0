From: Joerg Roedel <joro@8bytes.org>
Date: Mon, 26 Nov 2012 11:22:17 +0000
Subject: Re: [PATCH 0/9] dma_debug: add debug_dma_mapping_error support to architectures that support DMA_DEB
Message-Id: <20121126112217.GG25742@8bytes.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1353706142.5270.93.camel@lorien2>
In-Reply-To: <1353706142.5270.93.camel@lorien2>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

Hi Shuah,

On Fri, Nov 23, 2012 at 02:29:02PM -0700, Shuah Khan wrote:
> x86 - done in the first patch that added the feature.
> 
> ARM64: dma_debug: add debug_dma_mapping_error support
> c6x: dma_debug: add debug_dma_mapping_error support
> ia64: dma_debug: add debug_dma_mapping_error support
> microblaze: dma-mapping: support debug_dma_mapping_error
> mips: dma_debug: add debug_dma_mapping_error support
> powerpc: dma_debug: add debug_dma_mapping_error support
> sh: dma_debug: add debug_dma_mapping_error support
> sparc: dma_debug: add debug_dma_mapping_error support
> tile: dma_debug: add debug_dma_mapping_error support

Have you compile-tested the invididual archs you are changing here?


	Joerg


