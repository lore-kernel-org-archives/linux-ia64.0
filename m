From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Date: Thu, 25 Sep 2014 14:23:40 +0000
Subject: Re: [PATCH v2 00/22] Use MSI chip framework to configure MSI/MSI-X in all platforms
Message-Id: <20140925142340.GE20089@laptop.dumpdata.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1411614872-4009-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1411614872-4009-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yijing Wang <wangyijing@huawei.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, linux-arch@vger.kernel.org, arnab.basu@freescale.com, Bharat.Bhushan@freescale.com, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Ralf Baechle <ralf@linux-mips.org>, Lucas Stach <l.stach@pengutronix.de>, David Vrabel <david.vrabel@citrix.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, Michael Ellerman <mpe@ellerman.id.au>, Thierry Reding <thierry.reding@gmail.com>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>

On Thu, Sep 25, 2014 at 11:14:10AM +0800, Yijing Wang wrote:
> This series is based Bjorn's pci/msi branch
> git://git.kernel.org/pub/scm/linux/kernel/git/helgaas/pci.git pci/msi

Is there a git tree for these patches?
> 
> Currently, there are a lot of weak arch functions in MSI code.
> Thierry Reding Introduced MSI chip framework to configure MSI/MSI-X in arm.
> This series use MSI chip framework to refactor MSI code across all platforms
> to eliminate weak arch functions. Then all MSI irqs will be managed in a 
> unified framework. Because this series changed a lot of ARCH MSI code,
> so tests in the platforms which MSI code modified are warmly welcomed!
> 
> v1->v2:
> Add a patch to make s390 MSI code build happy between patch "x86/xen/MSI: E.."
> and "s390/MSI: Use MSI..". Fix several typo problems found by Lucas.
> 
> RFC->v1: 
> Updated "[patch 4/21] x86/xen/MSI: Eliminate...", export msi_chip instead
> of #ifdef to fix MSI bug in xen running in x86. 
> Rename arch_get_match_msi_chip() to arch_find_msi_chip().
> Drop use struct device as the msi_chip argument, we will do that
> later in another patchset.
> 
> Yijing Wang (22):
>   PCI/MSI: Clean up struct msi_chip argument
>   PCI/MSI: Remove useless bus->msi assignment
>   MSI: Remove the redundant irq_set_chip_data()
>   x86/xen/MSI: Eliminate arch_msix_mask_irq() and arch_msi_mask_irq()
>   s390/MSI: Use __msi_mask_irq() instead of default_msi_mask_irq()
>   PCI/MSI: Introduce weak arch_find_msi_chip() to find MSI chip
>   PCI/MSI: Refactor struct msi_chip to make it become more common
>   x86/MSI: Use MSI chip framework to configure MSI/MSI-X irq
>   x86/xen/MSI: Use MSI chip framework to configure MSI/MSI-X irq
>   Irq_remapping/MSI: Use MSI chip framework to configure MSI/MSI-X irq
>   x86/MSI: Remove unused MSI weak arch functions
>   MIPS/Octeon/MSI: Use MSI chip framework to configure MSI/MSI-X irq
>   MIPS/Xlp: Remove the dead function destroy_irq() to fix build error
>   MIPS/Xlp/MSI: Use MSI chip framework to configure MSI/MSI-X irq
>   MIPS/Xlr/MSI: Use MSI chip framework to configure MSI/MSI-X irq
>   Powerpc/MSI: Use MSI chip framework to configure MSI/MSI-X irq
>   s390/MSI: Use MSI chip framework to configure MSI/MSI-X irq
>   arm/iop13xx/MSI: Use MSI chip framework to configure MSI/MSI-X irq
>   IA64/MSI: Use MSI chip framework to configure MSI/MSI-X irq
>   Sparc/MSI: Use MSI chip framework to configure MSI/MSI-X irq
>   tile/MSI: Use MSI chip framework to configure MSI/MSI-X irq
>   PCI/MSI: Clean up unused MSI arch functions
> 
>  arch/arm/mach-iop13xx/include/mach/pci.h |    2 +
>  arch/arm/mach-iop13xx/iq81340mc.c        |    1 +
>  arch/arm/mach-iop13xx/iq81340sc.c        |    1 +
>  arch/arm/mach-iop13xx/msi.c              |    9 ++-
>  arch/arm/mach-iop13xx/pci.c              |    6 ++
>  arch/ia64/kernel/msi_ia64.c              |   18 ++++-
>  arch/mips/pci/msi-octeon.c               |   35 ++++++----
>  arch/mips/pci/msi-xlp.c                  |   18 ++++--
>  arch/mips/pci/pci-xlr.c                  |   15 ++++-
>  arch/powerpc/kernel/msi.c                |   14 +++-
>  arch/s390/pci/pci.c                      |   18 ++++-
>  arch/sparc/kernel/pci.c                  |   14 +++-
>  arch/tile/kernel/pci_gx.c                |   14 +++-
>  arch/x86/include/asm/apic.h              |    4 +
>  arch/x86/include/asm/pci.h               |    4 +-
>  arch/x86/include/asm/x86_init.h          |    7 --
>  arch/x86/kernel/apic/io_apic.c           |   16 ++++-
>  arch/x86/kernel/x86_init.c               |   34 ---------
>  arch/x86/pci/xen.c                       |   60 +++++++++-------
>  drivers/iommu/irq_remapping.c            |    9 ++-
>  drivers/irqchip/irq-armada-370-xp.c      |    8 +--
>  drivers/pci/host/pci-tegra.c             |    8 ++-
>  drivers/pci/host/pcie-designware.c       |    4 +-
>  drivers/pci/host/pcie-rcar.c             |    8 ++-
>  drivers/pci/msi.c                        |  114 ++++++++++++++----------------
>  drivers/pci/probe.c                      |    1 -
>  include/linux/msi.h                      |   26 ++-----
>  27 files changed, 266 insertions(+), 202 deletions(-)
> 
