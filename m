From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 22 Jul 2004 18:26:08 +0000
Subject: [PATCH] kill CONFIG_IA64_EARLY_PRINTK_SN
Message-Id: <200407221426.08636.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_AbAABVyUvh9yu1y"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--Boundary-00=_AbAABVyUvh9yu1y
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

This patch removes the obsolete sn specific early printk call.  Now that our 
driver supports early output, it's no longer necessary (and in fact no longer 
exists).  I'm too chicken to kill the other code, but maybe Bjorn will do 
that once the HP machines have a good early console driver.

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Jesse

--Boundary-00=_AbAABVyUvh9yu1y
Content-Type: text/x-diff;
  charset="us-ascii";
  name="kill-sn-early-printk.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="kill-sn-early-printk.patch"

===== kernel/printk.c 1.39 vs edited =====
--- 1.39/kernel/printk.c	2004-07-07 01:19:26 -04:00
+++ edited/kernel/printk.c	2004-07-22 14:21:41 -04:00
@@ -1013,9 +1013,6 @@
 #ifdef CONFIG_IA64_EARLY_PRINTK_VGA
 	early_printk_vga(str, len);
 #endif
-#ifdef CONFIG_IA64_EARLY_PRINTK_SGI_SN
- 	early_printk_sn_sal(str, len);
-#endif
 }
 
 #endif /* CONFIG_IA64_EARLY_PRINTK */
===== arch/ia64/Kconfig 1.64 vs edited =====
--- 1.64/arch/ia64/Kconfig	2004-06-29 17:54:52 -04:00
+++ edited/arch/ia64/Kconfig	2004-07-22 14:23:34 -04:00
@@ -454,10 +454,6 @@
 	bool "Early printk on VGA"
 	depends on IA64_EARLY_PRINTK
 
-config IA64_EARLY_PRINTK_SGI_SN
-	bool "Early printk on SGI SN serial console"
-	depends on IA64_EARLY_PRINTK && (IA64_GENERIC || IA64_SGI_SN2)
-
 config DEBUG_SLAB
 	bool "Debug memory allocations"
 	depends on DEBUG_KERNEL

--Boundary-00=_AbAABVyUvh9yu1y--
