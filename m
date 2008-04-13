From: Adrian Bunk <bunk@kernel.org>
Date: Sun, 13 Apr 2008 18:15:43 +0000
Subject: [2.6 patch] add SGI_IOC4 hardware dependencies
Message-Id: <20080413181543.GF2182@cs181133002.pp.htv.fi>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Considering that all users of this code depend on
(IA64_SGI_SN2 || IA64_GENERIC) the SGI_IOC4 option
should also depend on it.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
6b2d1a0c7d1a46f6a99966a0454cb1feaa7f1562 diff --git a/drivers/misc/Kconfig b/drivers/misc/Kconfig
index 962817e..85888d2 100644
--- a/drivers/misc/Kconfig
+++ b/drivers/misc/Kconfig
@@ -62,7 +62,7 @@ config EEPROM_93CX6
 
 config SGI_IOC4
 	tristate "SGI IOC4 Base IO support"
-	depends on PCI
+	depends on PCI && (IA64_SGI_SN2 || IA64_GENERIC)
 	---help---
 	  This option enables basic support for the IOC4 chip on certain
 	  SGI IO controller cards (IO9, IO10, and PCI-RT).  This option

