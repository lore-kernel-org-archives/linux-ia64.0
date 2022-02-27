From: Christoph Hellwig <hch@lst.de>
Date: Sun, 27 Feb 2022 14:30:44 +0000
Subject: cleanup swiotlb initialization v2
Message-Id: <20220227143055.335596-1-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: x86@kernel.org, Anshuman Khandual <anshuman.khandual@arm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Stefano Stabellini <sstabellini@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Lu Baolu <baolu.lu@linux.intel.com>, Robin Murphy <robin.murphy@arm.com>, linux-arm-kernel@lists.infradead.org, xen-devel@lists.xenproject.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-hyperv@vger.kernel.org, tboot-devel@lists.sourceforge.net, linux-pci@vger.kernel.org

Hi all,

this series tries to clean up the swiotlb initialization, including
that of swiotlb-xen.  To get there is also removes the x86 iommu table
infrastructure that massively obsfucates the initialization path.

Git tree:

    git://git.infradead.org/users/hch/misc.git swiotlb-init-cleanup

Gitweb:

    http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/swiotlb-init-cleanup

Changes since v1:
 - skip IOMMU initialization on Xen PV kernels
 - various small whitespace / typo fixes

Diffstat:
 arch/ia64/include/asm/iommu_table.h      |    7 -
 arch/x86/include/asm/iommu_table.h       |  102 -------------------
 arch/x86/include/asm/swiotlb.h           |   30 -----
 arch/x86/kernel/pci-iommu_table.c        |   77 --------------
 arch/x86/kernel/pci-swiotlb.c            |   77 --------------
 arch/x86/xen/pci-swiotlb-xen.c           |   96 ------------------
 b/arch/arm/mm/init.c                     |    6 -
 b/arch/arm/xen/mm.c                      |   23 ++--
 b/arch/arm64/mm/init.c                   |    6 -
 b/arch/ia64/mm/init.c                    |    4 
 b/arch/mips/cavium-octeon/dma-octeon.c   |   15 --
 b/arch/mips/loongson64/dma.c             |    2 
 b/arch/mips/pci/pci-octeon.c             |    2 
 b/arch/mips/sibyte/common/dma.c          |    2 
 b/arch/powerpc/include/asm/svm.h         |    4 
 b/arch/powerpc/include/asm/swiotlb.h     |    1 
 b/arch/powerpc/mm/mem.c                  |    6 -
 b/arch/powerpc/platforms/pseries/setup.c |    3 
 b/arch/powerpc/platforms/pseries/svm.c   |   26 ----
 b/arch/riscv/mm/init.c                   |    8 -
 b/arch/s390/mm/init.c                    |    3 
 b/arch/x86/include/asm/dma-mapping.h     |   12 --
 b/arch/x86/include/asm/gart.h            |    5 
 b/arch/x86/include/asm/iommu.h           |    8 +
 b/arch/x86/include/asm/xen/page.h        |    5 
 b/arch/x86/include/asm/xen/swiotlb-xen.h |    2 
 b/arch/x86/kernel/Makefile               |    2 
 b/arch/x86/kernel/amd_gart_64.c          |    5 
 b/arch/x86/kernel/aperture_64.c          |   14 --
 b/arch/x86/kernel/cpu/mshyperv.c         |    8 -
 b/arch/x86/kernel/pci-dma.c              |  109 ++++++++++++++++----
 b/arch/x86/kernel/tboot.c                |    1 
 b/arch/x86/kernel/vmlinux.lds.S          |   12 --
 b/arch/x86/mm/mem_encrypt_amd.c          |    3 
 b/arch/x86/pci/sta2x11-fixup.c           |    2 
 b/arch/x86/xen/Makefile                  |    2 
 b/drivers/iommu/amd/init.c               |    6 -
 b/drivers/iommu/amd/iommu.c              |    5 
 b/drivers/iommu/intel/dmar.c             |    6 -
 b/drivers/xen/swiotlb-xen.c              |  132 -------------------------
 b/include/linux/dmar.h                   |    6 -
 b/include/linux/swiotlb.h                |   22 ++--
 b/include/trace/events/swiotlb.h         |   29 +----
 b/include/xen/arm/page.h                 |    1 
 b/include/xen/swiotlb-xen.h              |    8 +
 b/kernel/dma/direct.h                    |    2 
 b/kernel/dma/swiotlb.c                   |  163 +++++++++++++++----------------
 47 files changed, 253 insertions(+), 817 deletions(-)
