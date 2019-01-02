From: Tony Luck <tony.luck@gmail.com>
Date: Wed, 02 Jan 2019 21:53:33 +0000
Subject: Re: [PATCH 02/15] swiotlb: remove dma_mark_clean
Message-Id: <CA+8MBb+9prWYSmp25K-LMUv1_0eekvFqXhoj87CV9zcaXfMDGg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181207190720.18517-1-hch@lst.de> <20181207190720.18517-3-hch@lst.de>
In-Reply-To: <20181207190720.18517-3-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: iommu@lists.linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Tariq Toukan <tariqt@mellanox.com>, Ilias Apalodimas <ilias.apalodimas@linaro.org>, =?UTF-8?B?VG9rZSBIw7hpbGFuZC1Kw7hyZ2Vuc2Vu?= <toke@toke.dk>, Robin Murphy <robin.murphy@arm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Fenghua Yu <fenghua.yu@intel.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Keith Busch <keith.busch@intel.com>, Jonathan Derrick <jonathan.derrick@intel.com>, linux-pci@vger.kernel.org, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, X86-ML <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, Dec 7, 2018 at 11:08 AM Christoph Hellwig <hch@lst.de> wrote:
>
> Instead of providing a special dma_mark_clean hook just for ia64, switch
> ia64 to use the normal arch_sync_dma_for_cpu hooks instead.
>
> This means that we now also set the PG_arch_1 bit for pages in the
> swiotlb buffer, which isn't stricly needed as we will never execute code
> out of the swiotlb buffer, but otherwise harmless.

ia64 build based on arch/ia64/configs/zx1_defconfig now fails with undefined
symbols arch_dma_alloc and arch_dma_free (used by kernel/dma/direct.c).

This config doesn't define CONFIG_SWIOTLB, so we don't get the
benefit of the routines in arch/ia64/kernel/dma-mapping.c

-Tony
