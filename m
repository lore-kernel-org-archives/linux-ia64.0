From: Zhen Lei <thunder.leizhen@huawei.com>
Date: Tue, 09 Apr 2019 12:53:02 +0000
Subject: [PATCH v5 0/6] add generic boot option for IOMMU dma mode
Message-Id: <20190409125308.18304-1-thunder.leizhen@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>, John Garry <john.garry@huawei.com>, Robin Murphy <robin.murphy@arm.com>, Will Deacon <will.deacon@arm.com>, Joerg Roedel <joro@8bytes.org>, Jonathan Corbet <corbet@lwn.net>, linux-doc <linux-doc@vger.kernel.org>, Sebastian Ott <sebott@linux.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>, David Woodhouse <dwmw2@infradead.org>, iommu <iommu@lists.linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, x86 <x86@kernel.org>, linux-ia64 <linux-ia64@vger.kernel.org>
Cc: Zhen Lei <thunder.leizhen@huawei.com>, Hanjun Guo <guohanjun@huawei.com>

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

Zhen Lei (6):
  iommu: add generic boot option iommu.dma_mode
  iommu: add build options corresponding to iommu.dma_mode
  iommu: add iommu_default_dma_mode_get/set() helper
  s390/pci: add support for generic boot option iommu.dma_mode
  powernv/iommu: add support for generic boot option iommu.dma_mode
  x86/iommu: add support for generic boot option iommu.dma_mode

 Documentation/admin-guide/kernel-parameters.txt | 19 +++++++
 arch/ia64/include/asm/iommu.h                   |  2 -
 arch/ia64/kernel/pci-dma.c                      |  2 -
 arch/powerpc/platforms/powernv/pci-ioda.c       |  5 +-
 arch/s390/pci/pci_dma.c                         | 14 ++---
 arch/x86/include/asm/iommu.h                    |  1 -
 arch/x86/kernel/pci-dma.c                       | 35 ++++++------
 drivers/iommu/Kconfig                           | 45 ++++++++++++---
 drivers/iommu/amd_iommu.c                       | 10 ++--
 drivers/iommu/amd_iommu_init.c                  |  4 +-
 drivers/iommu/amd_iommu_types.h                 |  6 --
 drivers/iommu/intel-iommu.c                     |  9 ++-
 drivers/iommu/iommu.c                           | 73 ++++++++++++++++++++-----
 include/linux/iommu.h                           | 23 ++++++++
 14 files changed, 176 insertions(+), 72 deletions(-)

-- 
1.8.3

