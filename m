From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Mon, 10 Jan 2005 21:52:04 +0000
Subject: [PATCH] gcc4 fixes for sn2
Message-Id: <200501101352.04806.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_Ekv4BnYlQL1PuKc"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Boundary-00=_Ekv4BnYlQL1PuKc
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

This patch is needed since "warning: use of cast expressions as lvalues is 
deprecated" turned into an error in gcc4.  We can use the convenience macros 
for read access and explicit assignments for initialization.  I thought about 
using Alexandre's fixes, but this seemed a little simpler.

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Thanks,
Jesse

--Boundary-00=_Ekv4BnYlQL1PuKc
Content-Type: text/plain;
  charset="us-ascii";
  name="sn2-io-init-gcc4-fixes.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="sn2-io-init-gcc4-fixes.patch"

===== arch/ia64/sn/kernel/io_init.c 1.7 vs edited =====
--- 1.7/arch/ia64/sn/kernel/io_init.c	2005-01-07 21:44:03 -08:00
+++ edited/arch/ia64/sn/kernel/io_init.c	2005-01-10 13:50:14 -08:00
@@ -201,7 +201,7 @@
 	struct pci_dev *host_pci_dev;
 	int status = 0;
 
-	SN_PCIDEV_INFO(dev) = kmalloc(sizeof(struct pcidev_info), GFP_KERNEL);
+	dev->sysdata = kmalloc(sizeof(struct pcidev_info), GFP_KERNEL);
 	if (SN_PCIDEV_INFO(dev) <= 0)
 		BUG();		/* Cannot afford to run out of memory */
 	memset(SN_PCIDEV_INFO(dev), 0, sizeof(struct pcidev_info));
@@ -309,8 +309,8 @@
 	 * after this point.
 	 */
 
-	PCI_CONTROLLER(bus) = controller;
-	SN_PCIBUS_BUSSOFT(bus) = provider_soft;
+	bus->sysdata = controller;
+	PCI_CONTROLLER(bus)->platform_data = provider_soft;
 
 	nasid = NASID_GET(SN_PCIBUS_BUSSOFT(bus)->bs_base);
 	cnode = nasid_to_cnodeid(nasid);

--Boundary-00=_Ekv4BnYlQL1PuKc--
