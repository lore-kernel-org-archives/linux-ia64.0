From: Yijing Wang <wangyijing@huawei.com>
Date: Tue, 12 Aug 2014 07:25:53 +0000
Subject: [RFC PATCH 00/20] Use msi_chip to configure MSI/MSI-X in all platforms
Message-Id: <1407828373-24322-1-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-pci@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, arnab.basu@freescale.com, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Yijing Wang <wangyijing@huawei.com>

This series is mainly to use msi_chip instead of currently weak arch functions
across all platforms. Also clean up current MSI code and make drivers support
MSI easier.  

Yijing Wang (20):
  x86/xen/MSI: Eliminate arch_msix_mask_irq() and arch_msi_mask_irq()
  MSI: Clean up struct msi_chip argument
  PCI/MSI: Remove useless bus->msi assignment
  MSI: Remove the redundant irq_set_chip_data()
  MSI: Refactor struct msi_chip to become more common
  PCI/MSI: Introduce arch_get_match_msi_chip() to find the match
    msi_chip
  x86/MSI: Use msi_chip instead of arch func to configure MSI/MSI-X
  x86/xen/MSI: Use msi_chip instead of arch func to configure MSI/MSI-X
  irq_remapping/MSI: Use msi_chip instead of arch func to configure
    MSI/MSI-X
  x86/MSI: Remove unused MSI weak arch functions
  MIPS/Octeon/MSI: Use msi_chip instead of arch func to configure
    MSI/MSI-X
  MIPS/Xlp/MSI: Use msi_chip instead of arch func to configure
    MSI/MSI-X
  MIPS/xlr/MSI: Use msi_chip instead of arch func to configure
    MSI/MSI-X
  Powerpc/MSI: Use msi_chip instead of arch func to configure MSI/MSI-X
  s390/MSI: Use msi_chip instead of arch func to configure MSI/MSI-X
  arm/iop13xx/MSI: Use msi_chip instead of arch func to configure
    MSI/MSI-X
  IA64/MSI: Use msi_chip instead of arch func to configure MSI/MSI-X
  Sparc/MSI: Use msi_chip instead of arch func to configure MSI/MSI-X
  tile/MSI: Use msi_chip instead of arch func to configure MSI/MSI-X
  PCI/MSI: Clean up unused MSI arch functions

 arch/arm/mach-iop13xx/include/mach/pci.h |    2 +
 arch/arm/mach-iop13xx/iq81340mc.c        |    1 +
 arch/arm/mach-iop13xx/iq81340sc.c        |    1 +
 arch/arm/mach-iop13xx/msi.c              |   14 +++-
 arch/arm/mach-iop13xx/pci.c              |    6 ++
 arch/ia64/kernel/msi_ia64.c              |   18 +++-
 arch/mips/pci/msi-octeon.c               |   45 ++++------
 arch/mips/pci/msi-xlp.c                  |   15 +++-
 arch/mips/pci/pci-xlr.c                  |   19 +++-
 arch/powerpc/kernel/msi.c                |   23 ++++--
 arch/s390/pci/pci.c                      |   16 +++-
 arch/sparc/kernel/pci.c                  |   18 +++-
 arch/tile/kernel/pci_gx.c                |   20 +++-
 arch/x86/include/asm/pci.h               |    4 +-
 arch/x86/include/asm/x86_init.h          |    3 -
 arch/x86/kernel/apic/io_apic.c           |   35 +++++++-
 arch/x86/kernel/x86_init.c               |   34 -------
 arch/x86/pci/xen.c                       |  139 ++++++++++++++++--------------
 drivers/iommu/irq_remapping.c            |   13 ++-
 drivers/irqchip/irq-armada-370-xp.c      |   12 +--
 drivers/pci/host/pci-tegra.c             |    9 ++-
 drivers/pci/host/pcie-designware.c       |    6 +-
 drivers/pci/host/pcie-rcar.c             |    9 ++-
 drivers/pci/msi.c                        |  118 ++++++++++++--------------
 drivers/pci/probe.c                      |    1 -
 include/linux/msi.h                      |   13 ++--
 26 files changed, 338 insertions(+), 256 deletions(-)

