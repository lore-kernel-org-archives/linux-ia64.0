From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Mon, 08 Sep 2008 09:10:09 +0000
Subject: [PATCH 0/5] fix exhaustion of ZONE_DMA with swiotlb (in x86 tree)
Message-Id: <1220865014-1169-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: mingo@redhat.com, joerg.roedel@amd.com, tony.luck@intel.com, linux-ia64@vger.kernel.org, iommu@lists.linux-foundation.org, fujita.tomonori@lab.ntt.co.jp

This patchset (against tip/master) fixes the problem that swiotlb
exhausts ZONE_DMA:

http://lkml.org/lkml/2008/8/31/16

The root problem is that swiotlb_alloc_coherent always use ZONE_DMA,
which is fine for IA64 but not for x86_64.

This patchset makes the callers set up the gfp flags so that
swiotlb_alloc_coherent can stop playing with the gfp flags.

I think that it would be better to remove the allocation code in
swiotlb_alloc_coherent theoretically (what swiotlb should do is taking
care of the swiotlb memory. And swiotlb_alloc_coherent is not useful
since we use it only when we can't allocate memory reachable by the
device or we are in out of memory). But that code works for both x86
and IA64 so it's not so bad, I guess.

#1 is for IA64, #2-4 for x86, and #5 is for swiotlb.

 arch/ia64/include/asm/dma-mapping.h |    4 ++-
 arch/x86/kernel/pci-nommu.c         |   21 +------------------
 include/asm-x86/dma-mapping.h       |   37 +++++++++++++++++++++++++++++++---
 lib/swiotlb.c                       |    7 ------
 4 files changed, 37 insertions(+), 32 deletions(-)


