From: Alex Williamson <alex.williamson@hp.com>
Date: Wed, 04 Aug 2004 16:20:36 +0000
Subject: [PATCH] fix zx1 config to work on NUMA sx1000 systems
Message-Id: <1091636436.8451.15.camel@tdi>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


   Using CONFIG_IA64_HP_ZX1 on an sx1000 system setup w/ multiple NUMA
nodes (configured for cell local memory) currently crashes because
MAX_NUMNODES defaults to 1.  The patch below sets up things to make this
work.  Tony, please apply.  Thanks,

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab


=== arch/ia64/Kconfig 1.76 vs edited ==--- 1.76/arch/ia64/Kconfig	Wed Jun 23 12:19:08 2004
+++ edited/arch/ia64/Kconfig	Wed Aug  4 10:01:01 2004
@@ -170,7 +170,7 @@
 
 config DISCONTIGMEM
 	bool "Discontiguous memory support"
-	depends on (IA64_DIG || IA64_SGI_SN2 || IA64_GENERIC) && NUMA && VIRTUAL_MEM_MAP
+	depends on (IA64_DIG || IA64_SGI_SN2 || IA64_GENERIC || IA64_HP_ZX1) && NUMA && VIRTUAL_MEM_MAP
 	default y if (IA64_SGI_SN2 || IA64_GENERIC) && NUMA
 	help
 	  Say Y to support efficient handling of discontiguous physical memory,
=== include/asm-ia64/numnodes.h 1.4 vs edited ==--- 1.4/include/asm-ia64/numnodes.h	Mon Nov 24 05:45:35 2003
+++ edited/include/asm-ia64/numnodes.h	Wed Aug  4 10:02:07 2004
@@ -4,6 +4,9 @@
 #ifdef CONFIG_IA64_DIG
 /* Max 8 Nodes */
 #define NODES_SHIFT	3
+#elif defined(CONFIG_IA64_HP_ZX1)
+/* Max 32 Nodes */
+#define NODES_SHIFT	5
 #elif defined(CONFIG_IA64_SGI_SN2) || defined(CONFIG_IA64_GENERIC)
 /* Max 256 Nodes */
 #define NODES_SHIFT	8



