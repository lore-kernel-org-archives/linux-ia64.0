From: akpm@osdl.org
Date: Wed, 30 Mar 2005 21:39:58 +0000
Subject: [patch 2/3] ia64 CONFIG_APCI_NUMA fix
Message-Id: <200503302139.j2ULdmIa029249@shell0.pdx.osdl.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



arch/ia64/kernel/smpboot.c:511:17: #error Fixme: Dunno how to build CPU-to-node 
map.

Seems that CONFIG_NUMA requires CONFIG_ACPI_NUMA.

Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/arch/ia64/Kconfig |    1 +
 1 files changed, 1 insertion(+)

diff -puN arch/ia64/Kconfig~ia64-config_apci_numa-fix arch/ia64/Kconfig
--- 25/arch/ia64/Kconfig~ia64-config_apci_numa-fix	2005-02-23 01:47:48.000000000 -0800
+++ 25-akpm/arch/ia64/Kconfig	2005-02-23 01:47:48.000000000 -0800
@@ -169,6 +169,7 @@ config NUMA
 	bool "NUMA support"
 	depends on !IA64_HP_SIM
 	default y if IA64_SGI_SN2
+	select ACPI_NUMA
 	help
 	  Say Y to compile the kernel to support NUMA (Non-Uniform Memory
 	  Access).  This option is for configuring high-end multiprocessor
_
