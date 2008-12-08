From: Robin Holt <holt@sgi.com>
Date: Mon, 08 Dec 2008 14:43:47 +0000
Subject: [Patch 4/4] Clear up section mismatch for ioc4_ide_attach_one.
Message-Id: <20081208144346.959154466@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


The generic_defconfig has three section mismatches.  This clears up
ioc4_ide_attach_one().

Signed-off-by: Robin Holt <holt@sgi.com>
Signed-off-by: Mike Reid <mdr@sgi.com>

---

 drivers/ide/sgiioc4.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)
Index: v2.6.28-rc7-20081208-218d11a/drivers/ide/sgiioc4.c
=================================--- v2.6.28-rc7-20081208-218d11a.orig/drivers/ide/sgiioc4.c	2008-12-08 08:23:34.955487702 -0600
+++ v2.6.28-rc7-20081208-218d11a/drivers/ide/sgiioc4.c	2008-12-08 08:24:41.191746826 -0600
@@ -633,7 +633,7 @@ out:
 	return ret;
 }
 
-int
+int __devinit
 ioc4_ide_attach_one(struct ioc4_driver_data *idd)
 {
 	/* PCI-RT does not bring out IDE connection.
@@ -645,7 +645,7 @@ ioc4_ide_attach_one(struct ioc4_driver_d
 	return pci_init_sgiioc4(idd->idd_pdev);
 }
 
-static struct ioc4_submodule ioc4_ide_submodule = {
+static struct ioc4_submodule __devinitdata ioc4_ide_submodule = {
 	.is_name = "IOC4_ide",
 	.is_owner = THIS_MODULE,
 	.is_probe = ioc4_ide_attach_one,

