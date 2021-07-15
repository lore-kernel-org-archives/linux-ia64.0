From: Logan Gunthorpe <logang@deltatee.com>
Date: Thu, 15 Jul 2021 16:45:28 +0000
Subject: [PATCH v1 00/16] .map_sg() error cleanup
Message-Id: <20210715164544.6827-1-logang@deltatee.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, iommu@lists.linux-foundation.org, linux-parisc@vger.kernel.org, xen-devel@lists.xenproject.org
Cc: Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>, Stephen Bates <sbates@raithlin.com>, Martin Oliveira <martin.oliveira@eideticom.com>, Logan Gunthorpe <logang@deltatee.com>

Hi,

This series is spun out and expanded from my work to add P2PDMA support
to DMA map operations[1].

The P2PDMA work requires distinguishing different error conditions in
a map_sg operation. dma_map_sgtable() already allows for returning an
error code (where as dma_map_sg() is only allowed to return zero)
however, it currently only returns -EINVAL when a .map_sg() call returns
zero.

This series cleans up all .map_sg() implementations to return appropriate
error codes. After the cleanup, dma_map_sg() will still return zero,
however dma_map_sgtable() will pass the error code from the .map_sg()
call. Thanks go to Martn Oliveira for doing a lot of the cleanup of the
obscure implementations.

The patch set is based off of v5.14-rc1 and a git repo can be found
here:

  https://github.com/sbates130272/linux-p2pmem map_sg_err_cleanup_v1

Thanks,

Logan

[1] https://lore.kernel.org/linux-block/20210513223203.5542-1-logang@deltatee.com/

--

Logan Gunthorpe (5):
  dma-mapping: Allow map_sg() ops to return negative error codes
  dma-direct: Return appropriate error code from dma_direct_map_sg()
  iommu: Return full error code from iommu_map_sg[_atomic]()
  dma-iommu: Return error code from iommu_dma_map_sg()
  dma-mapping: Disallow .map_sg operations from returning zero on error

Martin Oliveira (11):
  alpha: return error code from alpha_pci_map_sg()
  ARM/dma-mapping: return error code from .map_sg() ops
  ia64/sba_iommu: return error code from sba_map_sg_attrs()
  MIPS/jazzdma: return error code from jazz_dma_map_sg()
  powerpc/iommu: return error code from .map_sg() ops
  s390/pci: return error code from s390_dma_map_sg()
  sparc/iommu: return error codes from .map_sg() ops
  parisc: return error code from .map_sg() ops
  xen: swiotlb: return error code from xen_swiotlb_map_sg()
  x86/amd_gart: return error code from gart_map_sg()
  dma-mapping: return error code from dma_dummy_map_sg()

 arch/alpha/kernel/pci_iommu.c           | 10 +++-
 arch/arm/mm/dma-mapping.c               | 22 +++++---
 arch/ia64/hp/common/sba_iommu.c         |  9 +--
 arch/mips/jazz/jazzdma.c                |  2 +-
 arch/powerpc/kernel/iommu.c             |  4 +-
 arch/powerpc/platforms/ps3/system-bus.c |  2 +-
 arch/powerpc/platforms/pseries/vio.c    |  5 +-
 arch/s390/pci/pci_dma.c                 | 12 ++--
 arch/sparc/kernel/iommu.c               |  4 +-
 arch/sparc/kernel/pci_sun4v.c           |  4 +-
 arch/sparc/mm/iommu.c                   |  2 +-
 arch/x86/kernel/amd_gart_64.c           | 16 +++---
 drivers/iommu/dma-iommu.c               | 20 ++++---
 drivers/iommu/iommu.c                   | 15 +++--
 drivers/parisc/ccio-dma.c               |  2 +-
 drivers/parisc/sba_iommu.c              |  2 +-
 drivers/xen/swiotlb-xen.c               |  2 +-
 include/linux/dma-map-ops.h             |  6 +-
 include/linux/dma-mapping.h             | 35 +++---------
 include/linux/iommu.h                   | 22 ++++----
 kernel/dma/direct.c                     |  2 +-
 kernel/dma/dummy.c                      |  2 +-
 kernel/dma/mapping.c                    | 73 ++++++++++++++++++++++---
 23 files changed, 165 insertions(+), 108 deletions(-)


base-commit: e73f0f0ee7541171d89f2e2491130c7771ba58d3
--
2.20.1
