From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 09 Mar 2010 22:53:20 +0000
Subject: [PATCH v3 0/2] pci_root: track downstream bus range
Message-Id: <20100309225211.27167.54296.stgit@bob.kio>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Len Brown <lenb@kernel.org>
Cc: linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-pci@vger.kernel.org

These patches keep track of both the beginning and end of the bus number
range under a PCI host bridge (previously we only kept the beginning) and
make that range available to the arch code, which will need it to support
the _CBA mechanism for reporting MMCONFIG regions.

These apply on the acpi-test tree.

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
