From: Yijing Wang <wangyijing@huawei.com>
Date: Tue, 21 Apr 2015 11:34:19 +0000
Subject: [PATCH v10 00/29] Refine PCI scan interfaces and make generic pci host bridge
Message-Id: <1429616088-10249-1-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, dja@axtens.net, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>

This series could be pulled from:
https://github.com/YijingWang/linux-pci.git enumer10

v9->v10:
	Dynamically allocate busn resource if callers don't supply.
	Try to adjust busn resource if host bridge busn resource conlict.
	Rebase whole series on Bjorn's latest pci-next branch.
	Major v9->v10 changes are in patch 5,6,7,10.
v8->v9:
	Add Thierry's Acked-by and Tested-by.
	Fix the building error for powerpc found by Daniel.
	Change pci_host_assign_domain_nr() to static.
v7->v8:
	Fix some cross building errors found by kbuild test.
	Drop the rename patch for find_pci_host_bridge().
v6->v7:
	Drop previous patch which combined the domain and bus in one argument.
	Make the pci_host_bridge hold the default busn resource, so we could
	check whether new host busn resource is conflict with existing ones.
	Move pci_host_assign_domain_nr() to drivers/pci/host-bridge.c
	Other changes suggested by Bjorn and Suravee.
v5->v6:
	Fix cross building errors found by kbuild test.
	Export busn_resource to Xen pcifront driver.
v4->v5:
	Fix some code style issues and rename some functions suggested by Bjorn.
	Fix some code flaw(Eg. call pci_bus_add_devices() before resources claim
	or lack the return checking).
v3->v4:
	Fix the rebase issue.
v2->v3:
	Rebase this series on v4.0-rc1.
v1->v2:
	Split pci_host_bridge_list into a new patch, remove .phb_probe_mode
	and rework powerpc .phb_of_scan_bus() for simpilicty suggested by
	Arnd. Refresh some patch description log, and add a new patch to fix
	build warning in ia64.

This series is based on Bjorn's pci/enumeration branch.
You could pull it from https://github.com/YijingWang/linux-pci.git enumer9

Now in kernel, we scan pci bus use the following ways:
1. pci_scan_bus. 
	parent = NULL, default io/mem/bus resources
	call pci_bus_add_devices()

2. pci_scan_bus_parented() + pci_bus_add_devices()
	default io/mem/bus resources, only used by xen

3. pci_scan_root_bus() + pci_bus_add_devices()

4. pci_create_root_bus() + pci_scan_child_bus() + pci_bus_add_devices()

5. pci_create_root_bus() + xx_of_scan_bus()  +  pci_bus_add_devices()

And we have a lot of arch specific pci_domain_nr() and other platform
specific weak function like pcibios_root_bridge_prepare().

After applied this series, we have following scan interfaces:

1. pci_scan_bus() 
	parent = NULL, default io/mem/bus resources.
	for legacy pci scan

2. pci_scan_root_bus()
	for callers provide its own parent and io/mem/bus resources
	but no platform specific pci_host_bridge operations

3. pci_scan_host_bridge()
	for callers provide its own parent and io/mem/bus resources



Arnd Bergmann (1):
  xen/PCI: Don't use deprecated function pci_scan_bus_parented()

Yijing Wang (28):
  PCI: Remove deprecated pci_scan_bus_parented()
  PCI: Save domain in pci_host_bridge
  PCI: Move pci_bus_assign_domain_nr() declaration into
    drivers/pci/pci.h
  PCI: Remove argument bus for pci_create_root_bus()
  PCI: Alloc busn resource dynamically for pci_scan_bus()
  PCI: Allocate busn resource for pci_scan_root_bus()
  PCI: Introduce pci_host_assign_domain_nr() to assign domain
  PCI: Separate pci_host_bridge creation out of pci_create_root_bus()
  PCI: Introduce pci_host_bridge_list to manage host bridges
  PCI: Save sysdata in pci_host_bridge drvdata
  powerpc/PCI: Rename pcibios_root_bridge_prepare() to
    pcibios_set_root_bus_speed()
  PCI: Move pcibios_root_bridge_prepare() to pci_create_host_bridge()
  PCI: Introduce pci_host_bridge_ops to support host specific
    operations
  PCI: Introduce new scan function pci_scan_host_bridge()
  PCI: Introduce pci_bus_child_max_busnr()
  x86/PCI: Refine pci_acpi_scan_root() with generic pci_host_bridge
  ia64/PCI: Refine pci_acpi_scan_root() with generic pci_host_bridge
  powerpc/pci: Use pci_scan_host_bridge() for simplicity
  PCI: Remove pcibios_root_bridge_prepare() and
    pcibos_set_root_bus_speed()
  sparc/PCI: Use pci_scan_host_bridge() for simplicity
  parisc/PCI: Use pci_scan_root_bus() for simplicity
  PCI/mvebu: Use pci_common_init_dev() to simplify code
  PCI/tegra: Remove redundant tegra_pcie_scan_bus()
  PCI/designware: Use pci_scan_root_bus() for simplicity
  PCI/xgene: Use pci_scan_root_bus() instead of pci_create_root_bus()
  PCI: Rename __pci_create_root_bus() to pci_create_root_bus()
  PCI: Remove platform specific pci_domain_nr()
  PCI: Remove pci_bus_assign_domain_nr()

 arch/alpha/include/asm/pci.h             |    2 -
 arch/alpha/kernel/pci.c                  |    4 +-
 arch/alpha/kernel/sys_nautilus.c         |    2 +-
 arch/arm/kernel/bios32.c                 |    2 +-
 arch/arm/mach-dove/pcie.c                |    2 +-
 arch/arm/mach-iop13xx/pci.c              |    4 +-
 arch/arm/mach-mv78xx0/pcie.c             |    2 +-
 arch/arm/mach-orion5x/pci.c              |    4 +-
 arch/frv/mb93090-mb00/pci-vdk.c          |    3 +-
 arch/ia64/include/asm/pci.h              |    1 -
 arch/ia64/pci/pci.c                      |   35 ++--
 arch/ia64/sn/kernel/io_init.c            |    4 +-
 arch/m68k/coldfire/pci.c                 |    2 +-
 arch/microblaze/pci/pci-common.c         |   15 +--
 arch/mips/include/asm/pci.h              |    2 -
 arch/mips/pci/pci.c                      |    4 +-
 arch/mn10300/unit-asb2305/pci.c          |    3 +-
 arch/powerpc/include/asm/machdep.h       |    2 +-
 arch/powerpc/kernel/pci-common.c         |   79 +++++-----
 arch/powerpc/platforms/pseries/pci.c     |    8 +-
 arch/powerpc/platforms/pseries/pseries.h |    2 +-
 arch/powerpc/platforms/pseries/setup.c   |    2 +-
 arch/s390/pci/pci.c                      |   10 +-
 arch/sh/drivers/pci/pci.c                |    4 +-
 arch/sh/include/asm/pci.h                |    2 -
 arch/sparc/kernel/leon_pci.c             |    2 +-
 arch/sparc/kernel/pci.c                  |   45 +++---
 arch/sparc/kernel/pcic.c                 |    2 +-
 arch/tile/include/asm/pci.h              |    2 -
 arch/tile/kernel/pci.c                   |    4 +-
 arch/tile/kernel/pci_gx.c                |    4 +-
 arch/unicore32/kernel/pci.c              |    2 +-
 arch/x86/include/asm/pci.h               |    6 -
 arch/x86/pci/acpi.c                      |   37 +++--
 arch/x86/pci/common.c                    |    2 +-
 arch/xtensa/kernel/pci.c                 |    2 +-
 drivers/parisc/dino.c                    |    6 +-
 drivers/parisc/lba_pci.c                 |    6 +-
 drivers/pci/host-bridge.c                |  223 +++++++++++++++++++++++++
 drivers/pci/host/pci-mvebu.c             |   18 +--
 drivers/pci/host/pci-tegra.c             |   16 --
 drivers/pci/host/pci-versatile.c         |    3 +-
 drivers/pci/host/pci-xgene.c             |    5 +-
 drivers/pci/host/pcie-designware.c       |    6 +-
 drivers/pci/host/pcie-xilinx.c           |    2 +-
 drivers/pci/hotplug/acpiphp_glue.c       |   29 +---
 drivers/pci/hotplug/ibmphp_core.c        |    2 +-
 drivers/pci/pci.c                        |   85 +++-------
 drivers/pci/pci.h                        |    5 +
 drivers/pci/probe.c                      |  265 ++++++++++++++---------------
 drivers/pci/xen-pcifront.c               |   16 ++-
 include/linux/pci.h                      |   45 +++---
 52 files changed, 573 insertions(+), 467 deletions(-)

