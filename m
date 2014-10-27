From: Yijing Wang <wangyijing@huawei.com>
Date: Mon, 27 Oct 2014 12:46:40 +0000
Subject: [PATCH 00/16] Use MSI controller framework to configure MSI/MSI-X
Message-Id: <1414416142-31239-1-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Ralf Baechle <ralf@linux-mips.org>, Lucas Stach <l.stach@pengutronix.de>, David Vrabel <david.vrabel@citrix.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, Michael Ellerman <mpe@ellerman.id.au>, Thierry Reding <thierry.reding@gmail.com>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Yijing Wang <wangyijing@huawei.com>

This series is based on "[PATCH 00/10] Save MSI chip in pci_sys_data",
https://lkml.org/lkml/2014/10/27/85.

This series is the v4 of "Use MSI chip framework to configure MSI/MSI-X in all platforms".
I split it out and post it together.

v3->new:
Some trivial changes in "IA64/MSI: Use MSI controller framework to configure MSI/MSI-X irq".

Old history:
v2->v3:
1. For patch "x86/xen/MSI: Eliminate...", introduce a new global flag "pci_msi_ignore_mask"
to control the msi mask instead of replacing the irqchip->mask with nop function,
the latter method has problem pointed out by Konrad Rzeszutek Wilk.
2. Save msi chip in arch pci sysdata instead of associating msi chip to pci bus.
Because pci devices under same host share the same msi chip, so I think associate
msi chip to pci host/pci sysdata is better than to bother every pci bus/devices.
A better solution suggested by Liviu is to rip out pci_host_bridge from pci_create_root_bus(), 
then we can save some pci host common attributes like domain_nr, msi_chip, resources,
into the generic pci_host_bridge. Because this changes to pci host bridge is also 
a large series, so I think we should go step by step, I will try to post it in another
series later.
4. Clean up arm pcibios_add_bus() and pcibios_remove_bus() which were used to associate
msi chip to pci bus.

v1->v2:
Add a patch to make s390 MSI code build happy between patch "x86/xen/MSI: E.."
and "s390/MSI: Use MSI..". Fix several typo problems found by Lucas.

RFC->v1: 
Updated "[patch 4/21] x86/xen/MSI: Eliminate...", export msi_chip instead
of #ifdef to fix MSI bug in xen running in x86. 
Rename arch_get_match_msi_chip() to arch_find_msi_chip().
Drop use struct device as the msi_chip argument, we will do that
later in another patchset.

Yijing Wang (16):
  PCI/MSI: Refactor MSI controller to make it become more common
  x86/MSI: Use MSI controller framework to configure MSI/MSI-X irq
  x86/xen/MSI: Use MSI controller framework to configure MSI/MSI-X irq
  Irq_remapping/MSI: Use MSI controller framework to configure
    MSI/MSI-X irq
  x86/MSI: Remove unused MSI weak arch functions
  Mips/MSI: Save MSI controller in pci sysdata
  MIPS/Octeon/MSI: Use MSI controller framework to configure MSI/MSI-X
    irq
  MIPS/Xlp/MSI: Use MSI controller framework to configure MSI/MSI-X irq
  MIPS/Xlr/MSI: Use MSI controller framework to configure MSI/MSI-X irq
  Powerpc/MSI: Use MSI controller framework to configure MSI/MSI-X irq
  s390/MSI: Use MSI controller framework to configure MSI/MSI-X irq
  arm/iop13xx/MSI: Use MSI controller framework to configure MSI/MSI-X
    irq
  IA64/MSI: Use MSI controller framework to configure MSI/MSI-X irq
  Sparc/MSI: Use MSI controller framework to configure MSI/MSI-X irq
  tile/MSI: Use MSI controller framework to configure MSI/MSI-X irq
  PCI/MSI: Clean up unused MSI arch functions

 arch/arm/mach-iop13xx/include/mach/pci.h        |    4 +
 arch/arm/mach-iop13xx/iq81340mc.c               |    3 +
 arch/arm/mach-iop13xx/iq81340sc.c               |    5 +-
 arch/arm/mach-iop13xx/msi.c                     |   11 ++-
 arch/ia64/include/asm/pci.h                     |    3 +-
 arch/ia64/kernel/msi_ia64.c                     |   24 ++++--
 arch/ia64/pci/pci.c                             |    1 +
 arch/mips/include/asm/netlogic/xlp-hal/pcibus.h |    1 +
 arch/mips/include/asm/octeon/pci-octeon.h       |    4 +
 arch/mips/include/asm/pci.h                     |    3 +
 arch/mips/pci/msi-octeon.c                      |   31 ++++---
 arch/mips/pci/msi-xlp.c                         |   11 ++-
 arch/mips/pci/pci-octeon.c                      |    3 +
 arch/mips/pci/pci-xlp.c                         |    3 +
 arch/mips/pci/pci-xlr.c                         |   17 ++++-
 arch/mips/pci/pci.c                             |    9 ++
 arch/powerpc/include/asm/pci-bridge.h           |    8 ++
 arch/powerpc/kernel/msi.c                       |   19 ++++-
 arch/powerpc/kernel/pci-common.c                |    3 +
 arch/s390/include/asm/pci.h                     |    1 +
 arch/s390/pci/pci.c                             |   19 ++++-
 arch/sparc/kernel/pci.c                         |   20 ++++-
 arch/sparc/kernel/pci_impl.h                    |    3 +
 arch/tile/include/asm/pci.h                     |    2 +
 arch/tile/kernel/pci_gx.c                       |   18 ++++-
 arch/x86/include/asm/pci.h                      |    9 +-
 arch/x86/include/asm/x86_init.h                 |    4 -
 arch/x86/kernel/apic/io_apic.c                  |   18 ++++-
 arch/x86/kernel/x86_init.c                      |   24 ------
 arch/x86/pci/acpi.c                             |    1 +
 arch/x86/pci/common.c                           |    3 +
 arch/x86/pci/xen.c                              |   45 ++++++----
 drivers/iommu/irq_remapping.c                   |   11 ++-
 drivers/pci/msi.c                               |   97 ++++++++++------------
 include/linux/msi.h                             |   19 ++---
 35 files changed, 301 insertions(+), 156 deletions(-)

