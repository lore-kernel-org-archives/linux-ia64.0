From: Prarit Bhargava <prarit@sgi.com>
Date: Tue, 02 Aug 2005 17:08:22 +0000
Subject: [PATCH]: SN fix bus->sysdata pointer and memory cleanups
Message-Id: <42EFA886.9020503@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------080107020501010905070202"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------080107020501010905070202
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch fixes two things

The main issue is that bus_fixup calls may potentially call
functions that require a valid bus->sysdata pointer.  Since
this is the case, we must set the bus->sysdata pointer before
calling the bus_fixup functions.  The remaining changes are
simple fixes to make sure memory is cleaned up in the function.

This patch was generated against Tony Luck's latest ia64 tree.

Signed-off-by: Prarit Bhargava <prarit@sgi.com>

P.

--------------080107020501010905070202
Content-Type: text/plain;
 name="tioca_fixup.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="tioca_fixup.patch"

This patch fixes two things

The main issue is that bus_fixup calls may potentially call
functions that require a valid bus->sysdata pointer.  Since
this is the case, we must set the bus->sysdata pointer before
calling the bus_fixup functions.  The remaining changes are
simple fixes to make sure memory is cleaned up in the function.

This patch was generated against Tony Luck's latest ia64 tree.

Signed-off-by: Prarit Bhargava <prarit@sgi.com>

diff --git a/arch/ia64/sn/kernel/io_init.c b/arch/ia64/sn/kernel/io_init.c
--- a/arch/ia64/sn/kernel/io_init.c
+++ b/arch/ia64/sn/kernel/io_init.c
@@ -322,7 +322,7 @@ void sn_pci_controller_fixup(int segment
 	struct pci_controller *controller;
 	struct pcibus_bussoft *prom_bussoft_ptr;
 	struct hubdev_info *hubdev_info;
-	void *provider_soft;
+	void *provider_soft = NULL;
 	struct sn_pcibus_provider *provider;
 
  	status = sal_get_pcibus_info((u64) segment, (u64) busnum,
@@ -338,7 +338,7 @@ void sn_pci_controller_fixup(int segment
 	if (bus == NULL) {
  		bus = pci_scan_bus(busnum, &pci_root_ops, controller);
  		if (bus == NULL)
- 			return;	/* error, or bus already scanned */
+ 			goto error_return; /* error, or bus already scanned */
  		bus->sysdata = NULL;
 	}
 
@@ -351,28 +351,30 @@ void sn_pci_controller_fixup(int segment
 	 */
 
 	if (prom_bussoft_ptr->bs_asic_type >= PCIIO_ASIC_MAX_TYPES)
-		return;		/* unsupported asic type */
+		goto error_return; /* unsupported asic type */
 
 	if (prom_bussoft_ptr->bs_asic_type == PCIIO_ASIC_TYPE_PPB)
 		goto error_return; /* no further fixup necessary */
 
 	provider = sn_pci_provider[prom_bussoft_ptr->bs_asic_type];
 	if (provider == NULL)
-		return;		/* no provider registerd for this asic */
+		goto error_return; /* no provider registerd for this asic */
 
-	provider_soft = NULL;
+	bus->sysdata = controller;
 	if (provider->bus_fixup)
 		provider_soft = (*provider->bus_fixup) (prom_bussoft_ptr, controller);
 
-	if (provider_soft == NULL)
-		return;		/* fixup failed or not applicable */
+	if (provider_soft == NULL) {
+		/* fixup failed or not applicable */
+		bus->sysdata = NULL;
+		goto error_return;
+	}
 
 	/*
 	 * Generic bus fixup goes here.  Don't reference prom_bussoft_ptr
 	 * after this point.
 	 */
 
-	bus->sysdata = controller;
 	PCI_CONTROLLER(bus)->platform_data = provider_soft;
 	nasid = NASID_GET(SN_PCIBUS_BUSSOFT(bus)->bs_base);
 	cnode = nasid_to_cnodeid(nasid);

--------------080107020501010905070202--
