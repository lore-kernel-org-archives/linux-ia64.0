From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 18 Dec 2003 20:29:37 +0000
Subject: [PATCH] Force generic and hp kernels to use 16MB granules
Message-Id: <marc-linux-ia64-107177939524653@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

ia64: Force generic and hp kernels to use 16MB granules.

This forces the granule size to 16MB for HP zx1 and generic
kernels.  HP sx1000 machines require this.

=== arch/ia64/Kconfig 1.48 vs edited ==--- 1.48/arch/ia64/Kconfig	Wed Oct 15 02:35:33 2003
+++ edited/arch/ia64/Kconfig	Thu Nov 20 14:57:19 2003
@@ -579,6 +579,7 @@
 
 config IA64_GRANULE_64MB
 	bool "64MB"
+	depends on !(IA64_GENERIC || IA64_HP_ZX1)
 
 endchoice
 

