From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Mon, 05 Jan 2009 14:36:05 +0000
Subject: [PATCH 0/13] IA64: unifying ways to handle multiple sets of dma mapping ops
Message-Id: <1231166178-20050-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, fujita.tomonori@lab.ntt.co.jp

This patchset is the first part of the unification of ways to handle
multiple sets of dma mapping API. The whole work consists of three
patchset. This is for IA64 and can be applied independently.

dma_mapping_ops (or dma_ops) struct is used to handle multiple sets of
dma mapping API by X86, SPARC, and POWER. IA64 also handle multiple
sets of dma mapping API but in a very different way (some define
magic).

X86 and IA64 share VT-d and SWIOTLB code. We need several workarounds
for it because of the deference of ways to handle multiple sets of dma
mapping API (e.g., X86 people can't freely change struct
dma_mapping_ops in x86's dma-mapping.h now because it could break
IA64).  Seems POWER will use SWIOTLB code soon. I think that it's time
to unify ways to handle multiple sets of dma mapping API. After
applying the whole work, we have struct dma_map_ops
include/linux/dma-mapping.h (I also dream of changing all the archs to
use SWIOTLB in order to remove the bounce code in the block and
network stacks...).

This patchset changes IA64 to handle multiple sets of dma mapping API
in the common way (as X86, SPARC, and POWER do):

- removing dma operation hooks in struct ia64_machine_vector.

- adding a global pointer to struct dma_mapping_ops, which point to an
appropriate set of dma mapping API (VT-d, SBA, SN2, SWIOTLB, or HWSW).


I can access to a HP IA64 box and tested this patch with CONFIG
IA64_GENERIC, IA64_HP_ZX1, and IA64_HP_ZX1_SWIOTLB.

 arch/ia64/dig/dig_vtd_iommu.c                 |   18 +++
 arch/ia64/hp/common/hwsw_iommu.c              |  165 ++----------------------
 arch/ia64/hp/common/sba_iommu.c               |   57 ++++++---
 arch/ia64/include/asm/dma-mapping.h           |  144 +++++++++++++++------
 arch/ia64/include/asm/machvec.h               |   99 ++-------------
 arch/ia64/include/asm/machvec_dig_vtd.h       |   20 ---
 arch/ia64/include/asm/machvec_hpzx1.h         |   23 +---
 arch/ia64/include/asm/machvec_hpzx1_swiotlb.h |   27 +----
 arch/ia64/include/asm/machvec_sn2.h           |   27 +----
 arch/ia64/kernel/Makefile                     |    4 +-
 arch/ia64/kernel/dma-mapping.c                |   10 ++
 arch/ia64/kernel/pci-dma.c                    |   11 +-
 arch/ia64/kernel/pci-swiotlb.c                |   15 ++-
 arch/ia64/sn/pci/pci_dma.c                    |   83 +++++++------
 14 files changed, 262 insertions(+), 441 deletions(-)


