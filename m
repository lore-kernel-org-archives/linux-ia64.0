From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 11 Mar 2010 19:20:00 +0000
Subject: [PATCH v4 0/2] pci_root: track downstream bus range
Message-Id: <20100311191936.17859.3619.stgit@bob.kio>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Len Brown <lenb@kernel.org>
Cc: linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>

These patches keep track of both the beginning and end of the bus number
range under a PCI host bridge (previously we only kept the beginning) and
make that range available to the arch code, which will need it so support
the _CBA mechanism for reporting MMCONFIG regions.

Changes from v3 to v4:
    - Cleanup secondary.start init (Kenji).

Changes from v2 to v3:
    - Rework to use struct resource with IORESOURCE_BUS.
---

Bjorn Helgaas (2):
      ACPI: pci_root: save downstream bus range
      ACPI: pci_root: pass acpi_pci_root to arch-specific scan


 arch/ia64/pci/pci.c         |    5 +++
 arch/x86/pci/acpi.c         |    5 +++
 drivers/acpi/pci_root.c     |   67 ++++++++++++++++++++++++++-----------------
 include/acpi/acpi_bus.h     |    2 +
 include/acpi/acpi_drivers.h |    3 +-
 5 files changed, 50 insertions(+), 32 deletions(-)
