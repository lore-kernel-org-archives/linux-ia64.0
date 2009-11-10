From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 10 Nov 2009 17:11:28 +0000
Subject: [PATCH v2 0/3] pci_root: track downstream bus range for _CBA
Message-Id: <20091110170802.10645.91272.stgit@bob.kio>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Len Brown <lenb@kernel.org>
Cc: linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-pci@vger.kernel.org

The PCI Firmware Spec requires BIOS to use _CBA, not MCFG, to report
MMCONFIG regions of hot-pluggable host bridges.  Therefore, if the
hardware and firmware support host bridge hotplug, we will encounter
_CBA even if Linux itself doesn't support hotplug.

These patches make the pci_root driver keep track of the downstream
bus range and make it available so arch-specific code can register
MMCONFIG regions if necessary.

The first patch merely *prints* the downstream range, without saving it.
I posted that patch alone previously, before I realized that we actually
need to save the range for _CBA.

---

Bjorn Helgaas (3):
      ACPI: pci_root: show entire downstream bus range
      ACPI: pci_root: save downstream bus range
      ACPI: pci_root: pass acpi_pci_root to arch-specific scan


 arch/ia64/pci/pci.c         |    5 ++++-
 arch/x86/pci/acpi.c         |    5 ++++-
 drivers/acpi/pci_root.c     |   46 ++++++++++++++++++++++++++-----------------
 include/acpi/acpi_bus.h     |    1 +
 include/acpi/acpi_drivers.h |    3 +--
 5 files changed, 38 insertions(+), 22 deletions(-)

-- 
Bjorn
