From: Ingo Molnar <mingo@elte.hu>
Date: Tue, 27 Jan 2009 14:46:02 +0000
Subject: Re: [PATCH -tip] IA64: fix the compile error on IA64_DIG_VTD
Message-Id: <20090127144602.GA12183@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090127233530U.fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <20090127233530U.fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org


* FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp> wrote:

> Sorry about fallout from my dma mapping ops unification.
> 
> > From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
> Subject: [PATCH] IA64: fix the compile error on IA64_DIG_VTD
> 
> This moves iommu_detected to arch/ia64/kernel/dma-mapping.c from
> arch/ia64/kernel/pci-swiotlb.c to fix the following error on on
> IA64_DIG_VTD:
> 
> arch/ia64/kernel/built-in.o: In function `pci_iommu_init':
> pci-dma.c:(.init.text+0xa021): undefined reference to `iommu_detected'
> pci-dma.c:(.init.text+0xa030): undefined reference to `iommu_detected'
> drivers/built-in.o: In function `detect_intel_iommu':
> (.init.text+0x11c0): undefined reference to `iommu_detected'
> drivers/built-in.o: In function `detect_intel_iommu':
> (.init.text+0x11e1): undefined reference to `iommu_detected'
> 
> iommu_detected is used to handle IOMMUs so I guess that
> arch/ia64/kernel/dma-mapping.c is ok (there might be a better place
> for it though).
> 
> Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
> ---
>  arch/ia64/kernel/dma-mapping.c |    3 +++
>  arch/ia64/kernel/pci-swiotlb.c |    3 ---
>  2 files changed, 3 insertions(+), 3 deletions(-)

Applied to tip/core/iommu, thanks!

	Ingo
