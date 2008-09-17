From: shaohua.li@intel.com
Date: Wed, 17 Sep 2008 08:13:23 +0000
Subject: [patch 3/4] enable trace hook config
Message-Id: <20080917082022.296530683@sli10-desk.sh.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Enable trace hook config

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
---
 arch/ia64/Kconfig |    1 +
 1 file changed, 1 insertion(+)

Index: linux/arch/ia64/Kconfig
=================================--- linux.orig/arch/ia64/Kconfig	2008-09-17 13:30:25.000000000 +0800
+++ linux/arch/ia64/Kconfig	2008-09-17 13:55:39.000000000 +0800
@@ -21,6 +21,7 @@ config IA64
 	select HAVE_KRETPROBES
 	select HAVE_DMA_ATTRS
 	select HAVE_KVM
+	select HAVE_ARCH_TRACEHOOK
 	default y
 	help
 	  The Itanium Processor Family is Intel's 64-bit successor to

-- 
