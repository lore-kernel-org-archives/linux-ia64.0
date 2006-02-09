From: Prarit Bhargava <prarit@sgi.com>
Date: Thu, 09 Feb 2006 01:06:24 +0000
Subject: [PATCH 2/2]: Tollhouse HP: SGI hotplug driver changes
Message-Id: <20060209010600.26182.49088.sendpatchset@prarit.boston.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

SGI hotplug driver changes required to support Tollhouse system PCI
hotplug, and implements the PRF_HOTPLUG_SUPPORT feature bit.

Signed-off-by: Prarit Bhargava <prarit@sgi.com>

---
commit a082096f4d69fd71dfcb7cc981b8bb34b4abd84e
tree 4aee3fe438584e34e9804bb9535c8fd87cef3095
parent 2ab0f68bd8613bf0a41a28c122d36ffe63a4489c
author Prarit Bhargava <prarit@sgi.com> Wed, 08 Feb 2006 13:48:17 -0500
committer Prarit Bhargava <prarit@sgi.com> Wed, 08 Feb 2006 13:48:17 -0500

 drivers/pci/hotplug/sgi_hotplug.c |   42 +++++++++++++++++++------------------
 1 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/drivers/pci/hotplug/sgi_hotplug.c b/drivers/pci/hotplug/sgi_hotplug.c
index a32ae82..60f64bb 100644
--- a/drivers/pci/hotplug/sgi_hotplug.c
+++ b/drivers/pci/hotplug/sgi_hotplug.c
@@ -17,11 +17,13 @@
 #include <linux/types.h>
 
 #include <asm/sn/addrs.h>
+#include <asm/sn/geo.h>
 #include <asm/sn/l1.h>
 #include <asm/sn/module.h>
 #include <asm/sn/pcibr_provider.h>
 #include <asm/sn/pcibus_provider_defs.h>
 #include <asm/sn/pcidev.h>
+#include <asm/sn/sn_feature_sets.h>
 #include <asm/sn/sn_sal.h>
 #include <asm/sn/types.h>
 
@@ -101,8 +103,7 @@ static struct hotplug_slot_attribute sn_
 static int sn_pci_slot_valid(struct pci_bus *pci_bus, int device)
 {
 	struct pcibus_info *pcibus_info;
-	int bricktype;
-	int bus_num;
+	u16 busnum, segment, ioboard_type;
 
 	pcibus_info = SN_PCIBUS_BUSSOFT_INFO(pci_bus);
 
@@ -110,12 +111,14 @@ static int sn_pci_slot_valid(struct pci_
 	if (!(pcibus_info->pbi_valid_devices & (1 << device)))
 		return -EPERM;
 
-	bricktype = MODULE_GET_BTYPE(pcibus_info->pbi_moduleid);
-	bus_num = pcibus_info->pbi_buscommon.bs_persist_busnum & 0xf;
+	ioboard_type = sn_ioboard_to_pci_bus(pci_bus);
+	busnum = pcibus_info->pbi_buscommon.bs_persist_busnum;
+	segment = pci_domain_nr(pci_bus) & 0xf;
 
 	/* Do not allow hotplug operations on base I/O cards */
-	if ((bricktype = L1_BRICKTYPE_IX ||  bricktype = L1_BRICKTYPE_IA) &&
-	    (bus_num = 1 && device != 1))
+	if ((ioboard_type = L1_BRICKTYPE_IX ||
+	     ioboard_type = L1_BRICKTYPE_IA) &&
+	    (segment = 1 && busnum = 0 && device != 1))
 		return -EPERM;
 
 	return 1;
@@ -124,23 +127,23 @@ static int sn_pci_slot_valid(struct pci_
 static int sn_pci_bus_valid(struct pci_bus *pci_bus)
 {
 	struct pcibus_info *pcibus_info;
-	int asic_type;
-	int bricktype;
-
-	pcibus_info = SN_PCIBUS_BUSSOFT_INFO(pci_bus);
+	u32 asic_type;
+	u16 ioboard_type;
 
 	/* Don't register slots hanging off the TIOCA bus */
+	pcibus_info = SN_PCIBUS_BUSSOFT_INFO(pci_bus);
 	asic_type = pcibus_info->pbi_buscommon.bs_asic_type;
 	if (asic_type = PCIIO_ASIC_TYPE_TIOCA)
 		return -EPERM;
 
 	/* Only register slots in I/O Bricks that support hotplug */
-	bricktype = MODULE_GET_BTYPE(pcibus_info->pbi_moduleid);
-	switch (bricktype) {
+	ioboard_type = sn_ioboard_to_pci_bus(pci_bus);
+	switch (ioboard_type) {
 		case L1_BRICKTYPE_IX:
 		case L1_BRICKTYPE_PX:
 		case L1_BRICKTYPE_IA:
 		case L1_BRICKTYPE_PA:
+		case L1_BOARDTYPE_PCIX3SLOT:
 			return 1;
 			break;
 		default:
@@ -174,14 +177,11 @@ static int sn_hp_slot_private_alloc(stru
 	slot->pci_bus = pci_bus;
 	sprintf(bss_hotplug_slot->name, "%04x:%02x:%02x",
 		pci_domain_nr(pci_bus),
-		((int)pcibus_info->pbi_buscommon.bs_persist_busnum) & 0xf,
+		((u16)pcibus_info->pbi_buscommon.bs_persist_busnum),
 		device + 1);
-	sprintf(slot->physical_path, "module_%c%c%c%c%.2d",
-		'0'+RACK_GET_CLASS(MODULE_GET_RACK(pcibus_info->pbi_moduleid)),
-		'0'+RACK_GET_GROUP(MODULE_GET_RACK(pcibus_info->pbi_moduleid)),
-		'0'+RACK_GET_NUM(MODULE_GET_RACK(pcibus_info->pbi_moduleid)),
-		MODULE_GET_BTCHAR(pcibus_info->pbi_moduleid),
-		MODULE_GET_BPOS(pcibus_info->pbi_moduleid));
+
+	sn_generate_path(pci_bus, slot->physical_path);
+
 	slot->hotplug_slot = bss_hotplug_slot;
 	list_add(&slot->hp_list, &sn_hp_list);
 
@@ -552,8 +552,8 @@ static int sn_pci_hotplug_init(void)
 	int rc;
 	int registered = 0;
 
-	if (sn_sal_rev() < SGI_HOTPLUG_PROM_REV) {
-		printk(KERN_ERR "%s: PROM version must be greater than 4.30\n",
+	if (!sn_prom_feature_available(PRF_HOTPLUG_SUPPORT)) {
+		printk(KERN_ERR "%s: PROM version does not support hotplug.\n",
 		       __FUNCTION__);
 		return -EPERM;
 	}
