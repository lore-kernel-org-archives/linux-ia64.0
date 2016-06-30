From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Date: Thu, 30 Jun 2016 08:23:39 +0000
Subject: [PATCH v5 00/44] dma-mapping: Use unsigned long for dma_attrs
Message-Id: <1467275019-30789-1-git-send-email-k.kozlowski@samsung.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, Krzysztof Kozlowski <k.kozlowski-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fbdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-samsung-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-c6x-dev-jPsnJVOj+W6hPH1hqNUYSQ@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-hexagon-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, nouveau-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org, linux-snps-arc-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org, Bartlomiej Zolnierkiewicz <b.zolnierkie-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>, linux-arm-msm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-m68k-cunTk1MwBs8S/qaLPR03pWD2FQJk+8+b@public.gmane.org, linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XcXa4x6EXUF0@public.gmane.org

Hi,


This is fifth approach for replacing struct dma_attrs with unsigned
long.

The main patch (1/44) doing the change is split into many subpatches
for easier review (2-42).  They should be squashed together when
applying.


Rebased on v4.7-rc5.

For easier testing the patchset is available here:
repo:   https://github.com/krzk/linux
branch: for-next/dma-attrs-const-v5


Changes since v4
========
1. Collect some acks. Still need more.
2. Minor fixes pointed by Robin Murphy.
3. Applied changes from Bart Van Assche's comment.
4. More tests and builds (using https://www.kernel.org/pub/tools/crosstool/).


Changes since v3
========
1. Collect some acks.
2. Drop wrong patch 1/45 ("powerpc: dma-mapping: Don't hard-code
   the value of DMA_ATTR_WEAK_ORDERING").
3. Minor fix pointed out by Michael Ellerman.


Changes since v2
========
1. Follow Christoph Hellwig's comments (don't use BIT add
   documentation, remove dma_get_attr).


Rationale
====The dma-mapping core and the implementations do not change the
DMA attributes passed by pointer.  Thus the pointer can point to const
data.  However the attributes do not have to be a bitfield. Instead
unsigned long will do fine:

1. This is just simpler.  Both in terms of reading the code and setting
   attributes.  Instead of initializing local attributes on the stack
   and passing pointer to it to dma_set_attr(), just set the bits.

2. It brings safeness and checking for const correctness because the
   attributes are passed by value.


Best regards,
Krzysztof


Krzysztof Kozlowski (44):
  dma-mapping: Use unsigned long for dma_attrs
  alpha: dma-mapping: Use unsigned long for dma_attrs
  arc: dma-mapping: Use unsigned long for dma_attrs
  ARM: dma-mapping: Use unsigned long for dma_attrs
  arm64: dma-mapping: Use unsigned long for dma_attrs
  avr32: dma-mapping: Use unsigned long for dma_attrs
  blackfin: dma-mapping: Use unsigned long for dma_attrs
  c6x: dma-mapping: Use unsigned long for dma_attrs
  cris: dma-mapping: Use unsigned long for dma_attrs
  frv: dma-mapping: Use unsigned long for dma_attrs
  drm/exynos: dma-mapping: Use unsigned long for dma_attrs
  drm/mediatek: dma-mapping: Use unsigned long for dma_attrs
  drm/msm: dma-mapping: Use unsigned long for dma_attrs
  drm/nouveau: dma-mapping: Use unsigned long for dma_attrs
  drm/rockship: dma-mapping: Use unsigned long for dma_attrs
  infiniband: dma-mapping: Use unsigned long for dma_attrs
  iommu: dma-mapping: Use unsigned long for dma_attrs
  [media] dma-mapping: Use unsigned long for dma_attrs
  xen: dma-mapping: Use unsigned long for dma_attrs
  swiotlb: dma-mapping: Use unsigned long for dma_attrs
  powerpc: dma-mapping: Use unsigned long for dma_attrs
  video: dma-mapping: Use unsigned long for dma_attrs
  x86: dma-mapping: Use unsigned long for dma_attrs
  iommu: intel: dma-mapping: Use unsigned long for dma_attrs
  h8300: dma-mapping: Use unsigned long for dma_attrs
  hexagon: dma-mapping: Use unsigned long for dma_attrs
  ia64: dma-mapping: Use unsigned long for dma_attrs
  m68k: dma-mapping: Use unsigned long for dma_attrs
  metag: dma-mapping: Use unsigned long for dma_attrs
  microblaze: dma-mapping: Use unsigned long for dma_attrs
  mips: dma-mapping: Use unsigned long for dma_attrs
  mn10300: dma-mapping: Use unsigned long for dma_attrs
  nios2: dma-mapping: Use unsigned long for dma_attrs
  openrisc: dma-mapping: Use unsigned long for dma_attrs
  parisc: dma-mapping: Use unsigned long for dma_attrs
  misc: mic: dma-mapping: Use unsigned long for dma_attrs
  s390: dma-mapping: Use unsigned long for dma_attrs
  sh: dma-mapping: Use unsigned long for dma_attrs
  sparc: dma-mapping: Use unsigned long for dma_attrs
  tile: dma-mapping: Use unsigned long for dma_attrs
  unicore32: dma-mapping: Use unsigned long for dma_attrs
  xtensa: dma-mapping: Use unsigned long for dma_attrs
  dma-mapping: Remove dma_get_attr
  dma-mapping: Document the DMA attributes next to the declaration

 Documentation/DMA-API.txt                          |  33 +++---
 Documentation/DMA-attributes.txt                   |   2 +-
 arch/alpha/include/asm/dma-mapping.h               |   2 -
 arch/alpha/kernel/pci-noop.c                       |   2 +-
 arch/alpha/kernel/pci_iommu.c                      |  12 +-
 arch/arc/mm/dma.c                                  |  12 +-
 arch/arm/common/dmabounce.c                        |   4 +-
 arch/arm/include/asm/dma-mapping.h                 |  13 +--
 arch/arm/include/asm/xen/page-coherent.h           |  16 +--
 arch/arm/mm/dma-mapping.c                          | 117 +++++++++----------
 arch/arm/xen/mm.c                                  |   8 +-
 arch/arm64/mm/dma-mapping.c                        |  66 +++++------
 arch/avr32/mm/dma-coherent.c                       |  12 +-
 arch/blackfin/kernel/dma-mapping.c                 |   8 +-
 arch/c6x/include/asm/dma-mapping.h                 |   4 +-
 arch/c6x/kernel/dma.c                              |   9 +-
 arch/c6x/mm/dma-coherent.c                         |   4 +-
 arch/cris/arch-v32/drivers/pci/dma.c               |   9 +-
 arch/frv/mb93090-mb00/pci-dma-nommu.c              |   8 +-
 arch/frv/mb93090-mb00/pci-dma.c                    |   9 +-
 arch/h8300/kernel/dma.c                            |   8 +-
 arch/hexagon/include/asm/dma-mapping.h             |   1 -
 arch/hexagon/kernel/dma.c                          |   8 +-
 arch/ia64/hp/common/sba_iommu.c                    |  22 ++--
 arch/ia64/include/asm/machvec.h                    |   1 -
 arch/ia64/kernel/pci-swiotlb.c                     |   4 +-
 arch/ia64/sn/pci/pci_dma.c                         |  22 ++--
 arch/m68k/kernel/dma.c                             |  12 +-
 arch/metag/kernel/dma.c                            |  16 +--
 arch/microblaze/include/asm/dma-mapping.h          |   1 -
 arch/microblaze/kernel/dma.c                       |  12 +-
 arch/mips/cavium-octeon/dma-octeon.c               |   8 +-
 arch/mips/loongson64/common/dma-swiotlb.c          |  10 +-
 arch/mips/mm/dma-default.c                         |  20 ++--
 arch/mips/netlogic/common/nlm-dma.c                |   4 +-
 arch/mn10300/mm/dma-alloc.c                        |   8 +-
 arch/nios2/mm/dma-mapping.c                        |  12 +-
 arch/openrisc/kernel/dma.c                         |  21 ++--
 arch/parisc/kernel/pci-dma.c                       |  18 +--
 arch/powerpc/include/asm/dma-mapping.h             |   7 +-
 arch/powerpc/include/asm/iommu.h                   |  10 +-
 arch/powerpc/kernel/dma-iommu.c                    |  12 +-
 arch/powerpc/kernel/dma.c                          |  18 +--
 arch/powerpc/kernel/ibmebus.c                      |  12 +-
 arch/powerpc/kernel/iommu.c                        |  12 +-
 arch/powerpc/kernel/vio.c                          |  12 +-
 arch/powerpc/platforms/cell/iommu.c                |  28 ++---
 arch/powerpc/platforms/pasemi/iommu.c              |   2 +-
 arch/powerpc/platforms/powernv/npu-dma.c           |   8 +-
 arch/powerpc/platforms/powernv/pci-ioda.c          |   4 +-
 arch/powerpc/platforms/powernv/pci.c               |   2 +-
 arch/powerpc/platforms/powernv/pci.h               |   2 +-
 arch/powerpc/platforms/ps3/system-bus.c            |  18 +--
 arch/powerpc/platforms/pseries/iommu.c             |   6 +-
 arch/powerpc/sysdev/dart_iommu.c                   |   2 +-
 arch/s390/include/asm/dma-mapping.h                |   1 -
 arch/s390/pci/pci_dma.c                            |  23 ++--
 arch/sh/include/asm/dma-mapping.h                  |   4 +-
 arch/sh/kernel/dma-nommu.c                         |   4 +-
 arch/sh/mm/consistent.c                            |   4 +-
 arch/sparc/kernel/iommu.c                          |  12 +-
 arch/sparc/kernel/ioport.c                         |  24 ++--
 arch/sparc/kernel/pci_sun4v.c                      |  12 +-
 arch/tile/kernel/pci-dma.c                         |  28 ++---
 arch/unicore32/mm/dma-swiotlb.c                    |   4 +-
 arch/x86/include/asm/dma-mapping.h                 |   5 +-
 arch/x86/include/asm/swiotlb.h                     |   4 +-
 arch/x86/include/asm/xen/page-coherent.h           |   9 +-
 arch/x86/kernel/amd_gart_64.c                      |  20 ++--
 arch/x86/kernel/pci-calgary_64.c                   |  14 +--
 arch/x86/kernel/pci-dma.c                          |   4 +-
 arch/x86/kernel/pci-nommu.c                        |   4 +-
 arch/x86/kernel/pci-swiotlb.c                      |   4 +-
 arch/x86/pci/sta2x11-fixup.c                       |   2 +-
 arch/x86/pci/vmd.c                                 |  16 +--
 arch/xtensa/kernel/pci-dma.c                       |  12 +-
 drivers/gpu/drm/exynos/exynos_drm_fbdev.c          |   2 +-
 drivers/gpu/drm/exynos/exynos_drm_g2d.c            |  12 +-
 drivers/gpu/drm/exynos/exynos_drm_gem.c            |  20 ++--
 drivers/gpu/drm/exynos/exynos_drm_gem.h            |   2 +-
 drivers/gpu/drm/mediatek/mtk_drm_gem.c             |  13 +--
 drivers/gpu/drm/mediatek/mtk_drm_gem.h             |   2 +-
 drivers/gpu/drm/msm/msm_drv.c                      |  13 +--
 .../gpu/drm/nouveau/nvkm/subdev/instmem/gk20a.c    |  13 +--
 drivers/gpu/drm/rockchip/rockchip_drm_gem.c        |  17 ++-
 drivers/gpu/drm/rockchip/rockchip_drm_gem.h        |   2 +-
 drivers/infiniband/core/umem.c                     |   7 +-
 drivers/iommu/amd_iommu.c                          |  12 +-
 drivers/iommu/dma-iommu.c                          |   8 +-
 drivers/iommu/intel-iommu.c                        |  12 +-
 drivers/media/platform/sti/bdisp/bdisp-hw.c        |  26 ++---
 drivers/media/v4l2-core/videobuf2-dma-contig.c     |  30 ++---
 drivers/media/v4l2-core/videobuf2-dma-sg.c         |  19 +--
 drivers/misc/mic/host/mic_boot.c                   |  20 ++--
 drivers/parisc/ccio-dma.c                          |  16 +--
 drivers/parisc/sba_iommu.c                         |  16 +--
 drivers/video/fbdev/omap2/omapfb/omapfb-main.c     |  12 +-
 drivers/video/fbdev/omap2/omapfb/omapfb.h          |   3 +-
 drivers/xen/swiotlb-xen.c                          |  14 +--
 include/linux/dma-attrs.h                          |  71 ------------
 include/linux/dma-iommu.h                          |   6 +-
 include/linux/dma-mapping.h                        | 128 ++++++++++++++-------
 include/linux/swiotlb.h                            |  10 +-
 include/media/videobuf2-dma-contig.h               |   7 +-
 include/rdma/ib_verbs.h                            |   8 +-
 include/xen/swiotlb-xen.h                          |  12 +-
 lib/dma-noop.c                                     |   9 +-
 lib/swiotlb.c                                      |  13 ++-
 108 files changed, 689 insertions(+), 789 deletions(-)
 delete mode 100644 include/linux/dma-attrs.h

-- 
1.9.1

