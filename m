From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 06 Apr 2004 22:25:24 +0000
Subject: [PATCH] allow simscsi to be a module
Message-Id: <200404061625.24639.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Requiring CONFIG_HP_SIMSCSI to be either "y" or "n" breaks
allmodconfig, because simscsi ends up built-in, while scsi itself
is a module.  So allow simscsi to be a module also.

=== arch/ia64/hp/sim/Kconfig 1.3 vs edited ==--- 1.3/arch/ia64/hp/sim/Kconfig	Tue Jun  3 05:24:27 2003
+++ edited/arch/ia64/hp/sim/Kconfig	Tue Apr  6 16:10:15 2004
@@ -13,7 +13,7 @@
 	depends on HP_SIMSERIAL
 
 config HP_SIMSCSI
-	bool "Simulated SCSI disk"
+	tristate "Simulated SCSI disk"
 	depends on SCSI
 
 endmenu

