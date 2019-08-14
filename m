From: Joerg Roedel <joro@8bytes.org>
Date: Wed, 14 Aug 2019 13:38:31 +0000
Subject: [PATCH 00/10 v2] Cleanup IOMMU passthrough setting (and disable IOMMU Passthrough when SME is active
Message-Id: <20190814133841.7095-1-joro@8bytes.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joerg Roedel <joro@8bytes.org>
Cc: corbet@lwn.net, tony.luck@intel.com, fenghua.yu@intel.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-ia64@vger.kernel.org, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, Thomas.Lendacky@amd.com, Suravee.Suthikulpanit@amd.com

Hi,

This patch-set started out small to overwrite the default passthrough
setting (through CONFIG_IOMMU_DEFAULT_PASSTHROUGH=y) when SME is active.

But on the way to that Tom reminded me that the current ways to
configure passthrough/no-passthrough modes for IOMMU on x86 is a mess.
So I added a few more patches to clean that up a bit, getting rid of the
iommu_pass_through variable on the way.This information is now kept only
in iommu code, with helpers to change that setting from architecture
code.

And of course this patch-set still disables IOMMU Passthrough mode when
SME is active even when CONFIG_IOMMU_DEFAULT_PASSTHROUGH=y is set.

The reason for that change is that SME with passthrough mode turned out
to be fragile with devices requiring SWIOTLB, mainly because SWIOTLB has
a maximum allocation size of 256kb and a limit overall size of the
bounce buffer.

Therefore having IOMMU in translation mode by default is better when SME
is active on a system.

Please review.

Thanks,

	Joerg

Changes since v1:

	- Cleaned up the kernel command line parameters to
	  configure passthrough/translated mode, getting rid
	  of the global iommu_pass_through variable

Joerg Roedel (10):
  iommu: Add helpers to set/get default domain type
  iommu/amd: Request passthrough mode from IOMMU core
  iommu/vt-d: Request passthrough mode from IOMMU core
  x86/dma: Get rid of iommu_pass_through
  ia64: Get rid of iommu_pass_through
  iommu: Remember when default domain type was set on kernel command
    line
  iommu: Print default domain type on boot
  iommu: Set default domain type at runtime
  iommu: Disable passthrough mode when SME is active
  Documentation: Update Documentation for iommu.passthrough

 .../admin-guide/kernel-parameters.txt         |  2 +-
 arch/ia64/include/asm/iommu.h                 |  2 -
 arch/ia64/kernel/pci-dma.c                    |  2 -
 arch/x86/include/asm/iommu.h                  |  1 -
 arch/x86/kernel/pci-dma.c                     | 11 +--
 drivers/iommu/amd_iommu.c                     |  6 +-
 drivers/iommu/intel-iommu.c                   |  2 +-
 drivers/iommu/iommu.c                         | 83 +++++++++++++++++--
 include/linux/iommu.h                         | 16 ++++
 9 files changed, 101 insertions(+), 24 deletions(-)

-- 
2.17.1
