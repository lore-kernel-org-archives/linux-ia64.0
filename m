From: Christoph Hellwig <hch@lst.de>
Date: Mon, 04 Apr 2022 05:05:44 +0000
Subject: cleanup swiotlb initialization v8
Message-Id: <20220404050559.132378-1-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: Juergen Gross <jgross@suse.com>, Tom Lendacky <thomas.lendacky@amd.com>, linux-s390@vger.kernel.org, Stefano Stabellini <sstabellini@kernel.org>, linux-ia64@vger.kernel.org, Anshuman Khandual <anshuman.khandual@arm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Robin Murphy <robin.murphy@arm.com>, x86@kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, tboot-devel@lists.sourceforge.net, linux-hyperv@vger.kernel.org, linux-pci@vger.kernel.org, xen-devel@lists.xenproject.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Woodhouse <dwmw2@infradead.org>, linux-riscv@lists.infradead.org, linux-arm-kernel@lists.infradead.org

Hi all,

this series tries to clean up the swiotlb initialization, including
that of swiotlb-xen.  To get there is also removes the x86 iommu table
infrastructure that massively obsfucates the initialization path.

Git tree:

    git://git.infradead.org/users/hch/misc.git swiotlb-init-cleanup

Gitweb:

    http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/swiotlb-init-cleanup

Changes since v7:
 - rebased to Linux 5.18-rc1
 - better document the lower bound swiotlb size for xen-swiotlb
 - improve the nslabs calculation for the retry case in
   swiotlb_init_remap and swiotlb_init_late

Changes since v6:
 - use IO_TLB_MIN_SLABS instead of open coding the constant
 - call the remap callback later in swiotlb_init_late
 - set SWIOTLB_ANY for xen/x86

Changes since v5:
 - split a patch into three
 - fix setting x86_swiotlb_enable for Xen
 - fix a comment about forced bounce buffering for guest memory
   encryption
 - remove the xen_initial_domain check from
   xen_create_contiguous_region

Changes since v3:
 - fix a compilation issue on some powerpc configfs
 - fix and cleanup how forced bounce buffering is enabled for
   guest memory encryption

Changes since v2:
 - make ppc_swiotlb_flags actually work again
 - also force enable swiotlb for guest encrypted memory to cater
   to hyperv which doesn't set the host encrypted memory flag

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
 b/arch/arm/xen/mm.c                      |   26 ++--
 b/arch/arm64/mm/init.c                   |    6 -
 b/arch/ia64/mm/init.c                    |    4 
 b/arch/mips/cavium-octeon/dma-octeon.c   |   15 --
 b/arch/mips/loongson64/dma.c             |    2 
 b/arch/mips/pci/pci-octeon.c             |    2 
 b/arch/mips/sibyte/common/dma.c          |    2 
 b/arch/powerpc/include/asm/svm.h         |    4 
 b/arch/powerpc/include/asm/swiotlb.h     |    1 
 b/arch/powerpc/kernel/dma-swiotlb.c      |    1 
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
 b/arch/x86/kernel/pci-dma.c              |  114 +++++++++++++++++----
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
 b/kernel/dma/swiotlb.c                   |  163 ++++++++++++++-----------------
 48 files changed, 252 insertions(+), 827 deletions(-)
