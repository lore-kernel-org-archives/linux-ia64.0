From: Yijing Wang <wangyijing@huawei.com>
Date: Thu, 06 Jun 2013 07:34:47 +0000
Subject: [PATCH -v5 2/8] PCI/IA64: SN: use normal resource instead of pci_window
Message-Id: <1370504093-14908-3-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1370504093-14908-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1370504093-14908-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Yinghai Lu <yinghai@kernel.org>, linux-pci@vger.kernel.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, Hanjun Guo <guohanjun@huawei.com>, jiang.liu@huawei.com, Yijing Wang <wangyijing@huawei.com>, John Keller <jpk@sgi.com>, Jay Lan <jlan@engr.sgi.com>, Jack Steiner <steiner@sgi.com>, Mark Maule <maule@sgi.com>

Pci_window in pci_controller will not be used again,
use normal resource instead of pci_window in
sn_legacy_pci_window_fixup(), this patch is to prepare
remove pci_window in IA64.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
Cc: John Keller <jpk@sgi.com>
Cc: Jay Lan <jlan@engr.sgi.com>
Cc: Jack Steiner <steiner@sgi.com>
Cc: Mark Maule <maule@sgi.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/sn/kernel/io_init.c |   56 +++++++++++++++++++----------------------
 1 files changed, 26 insertions(+), 30 deletions(-)

diff --git a/arch/ia64/sn/kernel/io_init.c b/arch/ia64/sn/kernel/io_init.c
index 06a172c..2b00ade 100644
--- a/arch/ia64/sn/kernel/io_init.c
+++ b/arch/ia64/sn/kernel/io_init.c
@@ -118,34 +118,26 @@ static void __init sn_fixup_ionodes(void)
 }
 
 /*
- * sn_pci_legacy_window_fixup - Create PCI controller windows for
+ * sn_pci_legacy_window_fixup - Setup PCI resources for
  *				legacy IO and MEM space. This needs to
  *				be done here, as the PROM does not have
  *				ACPI support defining the root buses
  *				and their resources (_CRS),
  */
 static void
-sn_legacy_pci_window_fixup(struct pci_controller *controller,
-			   u64 legacy_io, u64 legacy_mem)
+sn_legacy_pci_window_fixup(struct resource *res,
+		u64 legacy_io, u64 legacy_mem)
 {
-		controller->window = kcalloc(2, sizeof(struct pci_window),
-					     GFP_KERNEL);
-		BUG_ON(controller->window = NULL);
-		controller->window[0].offset = legacy_io;
-		controller->window[0].resource.name = "legacy_io";
-		controller->window[0].resource.flags = IORESOURCE_IO;
-		controller->window[0].resource.start = legacy_io;
-		controller->window[0].resource.end -	    			controller->window[0].resource.start + 0xffff;
-		controller->window[0].resource.parent = &ioport_resource;
-		controller->window[1].offset = legacy_mem;
-		controller->window[1].resource.name = "legacy_mem";
-		controller->window[1].resource.flags = IORESOURCE_MEM;
-		controller->window[1].resource.start = legacy_mem;
-		controller->window[1].resource.end -	    	       controller->window[1].resource.start + (1024 * 1024) - 1;
-		controller->window[1].resource.parent = &iomem_resource;
-		controller->windows = 2;
+		res[0].name = "legacy_io";
+		res[0].flags = IORESOURCE_IO;
+		res[0].start = legacy_io;
+		res[0].end = res[0].start + 0xffff;
+		res[0].parent = &ioport_resource;
+		res[1].name = "legacy_mem";
+		res[1].flags = IORESOURCE_MEM;
+		res[1].start = legacy_mem;
+		res[1].end = res[1].start + (1024 * 1024) - 1;
+		res[1].parent = &iomem_resource;
 }
 
 /*
@@ -244,8 +236,8 @@ sn_pci_controller_fixup(int segment, int busnum, struct pci_bus *bus)
 	s64 status = 0;
 	struct pci_controller *controller;
 	struct pcibus_bussoft *prom_bussoft_ptr;
+	struct resource *res;
 	LIST_HEAD(resources);
-	int i;
 
  	status = sal_get_pcibus_info((u64) segment, (u64) busnum,
  				     (u64) ia64_tpa(&prom_bussoft_ptr));
@@ -257,19 +249,23 @@ sn_pci_controller_fixup(int segment, int busnum, struct pci_bus *bus)
 	BUG_ON(!controller);
 	controller->segment = segment;
 
+	res = kcalloc(2, sizeof(struct resource), GFP_KERNEL);
+	BUG_ON(!res);
+
 	/*
 	 * Temporarily save the prom_bussoft_ptr for use by sn_bus_fixup().
 	 * (platform_data will be overwritten later in sn_common_bus_fixup())
 	 */
 	controller->platform_data = prom_bussoft_ptr;
 
-	sn_legacy_pci_window_fixup(controller,
-				   prom_bussoft_ptr->bs_legacy_io,
-				   prom_bussoft_ptr->bs_legacy_mem);
-	for (i = 0; i < controller->windows; i++)
-		pci_add_resource_offset(&resources,
-					&controller->window[i].resource,
-					controller->window[i].offset);
+	sn_legacy_pci_window_fixup(res,
+			prom_bussoft_ptr->bs_legacy_io,
+			prom_bussoft_ptr->bs_legacy_mem);
+	pci_add_resource_offset(&resources,	&res[0],
+			prom_bussoft_ptr->bs_legacy_io);
+	pci_add_resource_offset(&resources,	&res[1],
+			prom_bussoft_ptr->bs_legacy_mem);
+
 	bus = pci_scan_root_bus(NULL, busnum, &pci_root_ops, controller,
 				&resources);
  	if (bus = NULL)
@@ -280,7 +276,7 @@ sn_pci_controller_fixup(int segment, int busnum, struct pci_bus *bus)
 	return;
 
 error_return:
-
+	kfree(res);
 	kfree(controller);
 	return;
 }
-- 
1.7.1


