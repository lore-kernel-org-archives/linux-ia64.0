From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 22 Oct 2018 20:22:54 +0000
Subject: [GIT PULL] ia64 changes for v4.20 (v5.0?) merge window
Message-Id: <20181022202254.GA9915@agluck-desk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following changes since commit ad3273d5f1b99d7319a986ab568dcbde2f9e53dd:

  Merge tag 'ext4_for_linus_stable' of git://git.kernel.org/pub/scm/linux/kernel/git/tytso/ext4 (2018-09-17 09:13:47 +0200)

are available in the Git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git tags/please-pull-next

for you to fetch changes up to 02b4da5f84d157f6a27e05ca017bdb74bcf01bee:

  intel-iommu: mark intel_dma_ops static (2018-09-17 10:15:58 -0700)

----------------------------------------------------------------
Miscellaneous ia64 fixes from Christoph

----------------------------------------------------------------
Christoph Hellwig (9):
      ia64: remove the kern_mem_attribute export
      ia64: remove the dead iommu_sac_force variable
      ia64: remove iommu_dma_supported
      ia64: remove the unused bad_dma_address symbol
      ia64: remove the unused pci_iommu_shutdown function
      ia64: remove the unused iommu_dma_init function
      ia64/sn2: remove no-ops dma sync methods
      ia64: remove machvec_dma_sync_{single,sg}
      intel-iommu: mark intel_dma_ops static

 arch/ia64/hp/common/sba_iommu.c     |  4 ---
 arch/ia64/include/asm/dma-mapping.h |  5 ----
 arch/ia64/include/asm/iommu.h       |  2 --
 arch/ia64/kernel/efi.c              |  1 -
 arch/ia64/kernel/machvec.c          | 16 -----------
 arch/ia64/kernel/pci-dma.c          | 55 -------------------------------------
 arch/ia64/sn/pci/pci_dma.c          | 29 -------------------
 drivers/iommu/intel-iommu.c         |  4 +--
 8 files changed, 1 insertion(+), 115 deletions(-)
