From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 17 Feb 2004 19:29:33 +0000
Subject: fix ia64 build failure
Message-Id: <200402171929.i1HJTXbD003900@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The attached trivial patch should fix the "i1-dig" build failure reported
on this page:

	http://www.gelato.unsw.edu.au/kerncomp/

and should make it easier to build a properly configured ia64 kernel.

Thanks,

	--david

=== drivers/char/agp/Kconfig 1.28 vs edited ==--- 1.28/drivers/char/agp/Kconfig	Wed Sep 24 20:34:24 2003
+++ edited/drivers/char/agp/Kconfig	Tue Feb 17 11:12:46 2004
@@ -127,14 +127,14 @@
 
 config AGP_I460
 	tristate "Intel 460GX chipset support"
-	depends on AGP && IA64
+	depends on AGP && (IA64_DIG || IA64_GENERIC)
 	help
 	  This option gives you AGP GART support for the Intel 460GX chipset
 	  for IA64 processors.
 
 config AGP_HP_ZX1
 	tristate "HP ZX1 chipset AGP support"
-	depends on AGP && IA64
+	depends on AGP && (IA64_HP_ZX1 || IA64_GENERIC)
 	help
 	  This option gives you AGP GART support for the HP ZX1 chipset
 	  for IA64 processors.
