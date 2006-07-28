From: Greg Edwards <edwardsg@sgi.com>
Date: Fri, 28 Jul 2006 14:36:26 +0000
Subject: [PATCH] add platform check to a couple sn2-only drivers
Message-Id: <20060728143626.GD27686@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Non-sn2 boxes occasionally run into problems when they execute module_init
functions for sn2 drivers, if those drivers go off and try to read a
register that doesn't exist, or maybe dereference a variable that isn't
defined for the non-sn2 case.

This patch adds a platform check for the ioc4 and snsc driver init
functions.  It's a bit overkill for the ioc4 case, but erring on the
conservative side doesn't hurt.

Signed-off-by: Greg Edwards <edwardsg@sgi.com>

---
 drivers/char/snsc.c |    7 ++++++-
 drivers/sn/ioc4.c   |    3 +++
 2 files changed, 9 insertions(+), 1 deletion(-)

Index: git-linus/drivers/char/snsc.c
=================================--- git-linus.orig/drivers/char/snsc.c	2006-07-27 09:15:02.524672764 -0500
+++ git-linus/drivers/char/snsc.c	2006-07-27 09:15:13.630016184 -0500
@@ -374,7 +374,12 @@ scdrv_init(void)
 	struct sysctl_data_s *scd;
 	void *salbuf;
 	dev_t first_dev, dev;
-	nasid_t event_nasid = ia64_sn_get_console_nasid();
+	nasid_t event_nasid;
+
+	if (!ia64_platform_is("sn2"))
+		return -ENODEV;
+
+	event_nasid = ia64_sn_get_console_nasid();
 
 	if (alloc_chrdev_region(&first_dev, 0, num_cnodes,
 				SYSCTL_BASENAME) < 0) {
Index: git-linus/drivers/sn/ioc4.c
=================================--- git-linus.orig/drivers/sn/ioc4.c	2006-07-27 09:29:41.000000000 -0500
+++ git-linus/drivers/sn/ioc4.c	2006-07-27 09:54:49.186272223 -0500
@@ -455,6 +455,9 @@ MODULE_DEVICE_TABLE(pci, ioc4_id_table);
 static int __devinit
 ioc4_init(void)
 {
+	if (!ia64_platform_is("sn2"))
+		return -ENODEV;
+
 	return pci_register_driver(&ioc4_driver);
 }
 
