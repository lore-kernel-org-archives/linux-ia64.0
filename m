From: Ingo Molnar <mingo@elte.hu>
Date: Mon, 17 Nov 2008 08:15:26 +0000
Subject: Re: [PATCH] swiotlb: use coherent_dma_mask in alloc_coherent
Message-Id: <20081117081526.GA24603@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081117162445C.fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <20081117162445C.fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Joerg Roedel <joerg.roedel@amd.com>, Andrew Morton <akpm@linux-foundation.org>


* FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp> wrote:

> This patch fixes swiotlb to use dev->coherent_dma_mask in 
> alloc_coherent. Currently, swiotlb uses dev->dma_mask in 
> alloc_coherent but alloc_coherent is supposed to use 
> coherent_dma_mask. It could break drivers that uses smaller 
> coherent_dma_mask than dma_mask (though the current code works for 
> the majority that use the same mask for coherent_dma_mask and 
> dma_mask).
> 
> Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
> ---
>  lib/swiotlb.c |   10 +++++++---
>  1 files changed, 7 insertions(+), 3 deletions(-)

Applied it with the changelog below to tip/core/urgent, thanks!

I also flagged it for v2.6.28 inclusion. This bug was caused by the 
removal of the GFP_DMA hack in swiotlb_alloc_coherent() in this cycle. 
I havent seen it actually reported anywhere - have you perhaps?Or have 
you found this via code review?

Do we know roughly the range of devices/systems where there's a real 
address range that cannot be DMA-ed to coherently, and an estimation 
about how frequently they would be affected by this bug?

	Ingo

--------------->
From 1e74f3000b86969de421ca0da08f42e7d21cbd99 Mon Sep 17 00:00:00 2001
From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Mon, 17 Nov 2008 16:24:34 +0900
Subject: [PATCH] swiotlb: use coherent_dma_mask in alloc_coherent

Impact: fix DMA buffer allocation coherency bug in certain configs

This patch fixes swiotlb to use dev->coherent_dma_mask in
swiotlb_alloc_coherent().

coherent_dma_mask is a subset of dma_mask (equal to it most of
the time), enumerating the address range that a given device
is able to DMA to/from in a cache-coherent way.

But currently, swiotlb uses dev->dma_mask in alloc_coherent()
implicitly via address_needs_mapping(), but alloc_coherent is really
supposed to use coherent_dma_mask.

This bug could break drivers that uses smaller coherent_dma_mask than
dma_mask (though the current code works for the majority that use the
same mask for coherent_dma_mask and dma_mask).

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: tony.luck@intel.com
Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 lib/swiotlb.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/lib/swiotlb.c b/lib/swiotlb.c
index 78330c3..5f6c629 100644
--- a/lib/swiotlb.c
+++ b/lib/swiotlb.c
@@ -467,9 +467,13 @@ swiotlb_alloc_coherent(struct device *hwdev, size_t size,
 	dma_addr_t dev_addr;
 	void *ret;
 	int order = get_order(size);
+	u64 dma_mask = DMA_32BIT_MASK;
+
+	if (hwdev && hwdev->coherent_dma_mask)
+		dma_mask = hwdev->coherent_dma_mask;
 
 	ret = (void *)__get_free_pages(flags, order);
-	if (ret && address_needs_mapping(hwdev, virt_to_bus(ret), size)) {
+	if (ret && !is_buffer_dma_capable(dma_mask, virt_to_bus(ret), size)) {
 		/*
 		 * The allocated memory isn't reachable by the device.
 		 * Fall back on swiotlb_map_single().
@@ -493,9 +497,9 @@ swiotlb_alloc_coherent(struct device *hwdev, size_t size,
 	dev_addr = virt_to_bus(ret);
 
 	/* Confirm address can be DMA'd by device */
-	if (address_needs_mapping(hwdev, dev_addr, size)) {
+	if (!is_buffer_dma_capable(dma_mask, dev_addr, size)) {
 		printk("hwdev DMA mask = 0x%016Lx, dev_addr = 0x%016Lx\n",
-		       (unsigned long long)*hwdev->dma_mask,
+		       (unsigned long long)dma_mask,
 		       (unsigned long long)dev_addr);
 
 		/* DMA_TO_DEVICE to avoid memcpy in unmap_single */
