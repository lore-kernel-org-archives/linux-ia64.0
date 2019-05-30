From: Zhen Lei <thunder.leizhen@huawei.com>
Date: Thu, 30 May 2019 03:48:24 +0000
Subject: [PATCH v8 0/7] iommu: enhance IOMMU default DMA mode build options
Message-Id: <20190530034831.4184-1-thunder.leizhen@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>, John Garry <john.garry@huawei.com>, Robin Murphy <robin.murphy@arm.com>, Will Deacon <will.deacon@arm.com>, Joerg Roedel <joro@8bytes.org>, Jonathan Corbet <corbet@lwn.net>, linux-doc <linux-doc@vger.kernel.org>, Sebastian Ott <sebott@linux.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>, David Woodhouse <dwmw2@infradead.org>, iommu <iommu@lists.linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, x86 <x86@kernel.org>, linux-ia64 <linux-ia64@vger.kernel.org>
Cc: Zhen Lei <thunder.leizhen@huawei.com>, Hanjun Guo <guohanjun@huawei.com>

v7--> v8
1. Split into multiple small patches base on ARCHs or IOMMU drivers.
2. Hide the unsupported build options on the related ARCH or IOMMU.

v6 --> v7:
1. Fix some text editing errors

v5 --> v6:
1. give up adding boot option iommu.dma_mode

v4 --> v5:
As Hanjun and Thomas Gleixner's suggestion:
1. Keep the old ARCH specific boot options no change.
2. Keep build option CONFIG_IOMMU_DEFAULT_PASSTHROUGH no change.

v4:
As Robin Murphy's suggestion:
"It's also not necessarily obvious to the user how this interacts with
IOMMU_DEFAULT_PASSTHROUGH, so if we really do go down this route, maybe it
would be better to refactor the whole lot into a single selection of something
like IOMMU_DEFAULT_MODE anyway."

In this version, I tried to normalize the IOMMU dma mode boot options for all
ARCHs. When IOMMU is enabled, there are 3 dma modes: paasthrough(bypass),
lazy(mapping but defer the IOTLB invalidation), strict. But currently each
ARCHs defined their private boot options, different with each other. For
example, to enable/disable "passthrough", ARM64 use iommu.passthrough=1/0,
X86 use iommu=pt/nopt, PPC/POWERNV use iommu=nobypass.

Zhen Lei (7):
  iommu: enhance IOMMU default DMA mode build options
  x86/dma: use IS_ENABLED() to simplify the code
  s390/pci: add support for IOMMU default DMA mode build options
  powernv/iommu: add support for IOMMU default DMA mode build options
  iommu/vt-d: add support for IOMMU default DMA mode build options
  iommu/amd: add support for IOMMU default DMA mode build options
  ia64: hide build option IOMMU_DEFAULT_PASSTHROUGH

 arch/powerpc/platforms/powernv/pci-ioda.c |  3 +-
 arch/s390/pci/pci_dma.c                   |  2 +-
 arch/x86/kernel/pci-dma.c                 |  7 ++---
 drivers/iommu/Kconfig                     | 46 ++++++++++++++++++++++++++-----
 drivers/iommu/amd_iommu_init.c            |  3 +-
 drivers/iommu/intel-iommu.c               |  2 +-
 drivers/iommu/iommu.c                     |  3 +-
 7 files changed, 49 insertions(+), 17 deletions(-)

-- 
1.8.3

