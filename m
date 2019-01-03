From: Tony Luck <tony.luck@gmail.com>
Date: Thu, 03 Jan 2019 17:35:08 +0000
Subject: Re: [PATCH 02/15] swiotlb: remove dma_mark_clean
Message-Id: <CA+8MBbKXTRGLn1Wvpp1avQCZ186i5Cbo0puvSoNNuKO7_AcwZg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181207190720.18517-1-hch@lst.de> <20181207190720.18517-3-hch@lst.de>
 <CA+8MBb+9prWYSmp25K-LMUv1_0eekvFqXhoj87CV9zcaXfMDGg@mail.gmail.com> <20190103072356.GA24163@lst.de>
In-Reply-To: <20190103072356.GA24163@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Christoph Hellwig <hch@lst.de>
Cc: iommu@lists.linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Tariq Toukan <tariqt@mellanox.com>, Ilias Apalodimas <ilias.apalodimas@linaro.org>, =?UTF-8?B?VG9rZSBIw7hpbGFuZC1Kw7hyZ2Vuc2Vu?= <toke@toke.dk>, Robin Murphy <robin.murphy@arm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Fenghua Yu <fenghua.yu@intel.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Keith Busch <keith.busch@intel.com>, Jonathan Derrick <jonathan.derrick@intel.com>, linux-pci@vger.kernel.org, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, X86-ML <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, Jan 2, 2019 at 11:23 PM Christoph Hellwig <hch@lst.de> wrote:
> I think something like the patch below should fix it:
>
> diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
> index ccd56f5df8cd..8d7396bd1790 100644
> --- a/arch/ia64/Kconfig
> +++ b/arch/ia64/Kconfig
> @@ -31,7 +31,7 @@ config IA64
>         select HAVE_MEMBLOCK_NODE_MAP
>         select HAVE_VIRT_CPU_ACCOUNTING
>         select ARCH_HAS_DMA_COHERENT_TO_PFN if SWIOTLB
> -       select ARCH_HAS_SYNC_DMA_FOR_CPU
> +       select ARCH_HAS_SYNC_DMA_FOR_CPU if SWIOTLB

Close. But no cigar. Now I get:

  CC      arch/ia64/mm/init.o
arch/ia64/mm/init.c:75:6: error: redefinition of ‘arch_sync_dma_for_cpu’
./include/linux/dma-noncoherent.h:61:20: note: previous definition of
‘arch_sync_dma_for_cpu’ was here
make[1]: *** [arch/ia64/mm/init.o] Error 1
make: *** [arch/ia64/mm/init.o] Error 2


-Tony
