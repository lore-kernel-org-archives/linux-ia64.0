From: Rajesh Shah <rajesh.shah@intel.com>
Date: Fri, 18 Mar 2005 22:16:30 +0000
Subject: [patch 09/12] Read bridge resources when fixing up the bus
Message-Id: <20050318141630.I1145@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050318133856.A878@unix-os.sc.intel.com>
In-Reply-To: <20050318133856.A878-39QZ/XbsZ5/mO6KZMuUCQVaTQe2KTcn/@public.gmane.org>; from rajesh.shah-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org on Fri, Mar 18, 2005 at 01:38:57PM -0800
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: gregkh-l3A5Bk7waGM@public.gmane.org, tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
Cc: linux-pci-jyMamyUUXNJG4ohzP4jBZS1Fcj925eT/@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, pcihpd-discuss-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, acpi-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org

Read bridge io/mem/pfmem ranges when fixing up the bus so that 
bus resources are tracked. This is required to properly support
pci end device and bridge hotplug.

Signed-off-by: Rajesh Shah <rajesh.shah@intel.com>
---

 linux-2.6.11-mm4-iohp-rshah1/arch/ia64/pci/pci.c |    4 ++++
 1 files changed, 4 insertions(+)

diff -puN arch/ia64/pci/pci.c~ia64-read_bridge_bases arch/ia64/pci/pci.c
--- linux-2.6.11-mm4-iohp/arch/ia64/pci/pci.c~ia64-read_bridge_bases	2005-03-16 13:07:30.503257168 -0800
+++ linux-2.6.11-mm4-iohp-rshah1/arch/ia64/pci/pci.c	2005-03-16 13:07:30.612632167 -0800
@@ -436,6 +436,10 @@ pcibios_fixup_bus (struct pci_bus *b)
 {
 	struct pci_dev *dev;
 
+	if (b->self) {
+		pci_read_bridge_bases(b);
+		pcibios_fixup_device_resources(b->self);
+	}
 	list_for_each_entry(dev, &b->devices, bus_list)
 		pcibios_fixup_device_resources(dev);
 
_
