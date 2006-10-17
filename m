From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Tue, 17 Oct 2006 02:41:04 +0000
Subject: Mspec driver and non-SN platforms?
Message-Id: <877iyz4qbj.peterc%peterc@gelato.unsw.edu.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hi,
	If you try to enable mspec when compiling for other than SN,
you get undefined references to uncached_free_page,
per_cpu__sn_hub_info, physical_node_map, and bte_copy.

Maybe the attached patch is needed... which disables fetchop for other
than Altix or generic kernels.  If and when the facility becomes
available on other platforms, it's probably going to need a new driver
(and new CONFIG option) anyway.

Signed-off-by: Peter Chubb <peterc@gelato.unsw.edu.au>

Index: linux-2.6-import/drivers/char/Kconfig
=================================--- linux-2.6-import.orig/drivers/char/Kconfig	2006-10-17 12:26:48.740866650 +1000
+++ linux-2.6-import/drivers/char/Kconfig	2006-10-17 12:27:23.852701733 +1000
@@ -411,9 +411,9 @@ config SGI_MBCS
 
 config MSPEC
 	tristate "Memory special operations driver"
-	depends on IA64
+	depends on (IA64_SGI_SN2 || IA64_GENERIC)
 	help
-	  If you have an ia64 and you want to enable memory special
+	  If you have an SGI Altix and you want to enable memory special
 	  operations support (formerly known as fetchop), say Y here,
 	  otherwise say N.
 
