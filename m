From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Thu, 14 Jul 2005 09:18:10 +0000
Subject: [RFC][patch 1/10] Multiple vector domain support - change ia64 Kconfig
Message-Id: <42D62DD2.9000701@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch adds the following configs options into arch/ia64/Kconfig

    o VECTOR_DOMAIN	      Multiple vector domain support
    o NR_VECTOR_DOMAINS	      # of vector domains

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
 

---

 linux-2.6.13-rc1-kanesige/arch/ia64/Kconfig      |   17 +++++++++++++++++
 linux-2.6.13-rc1-kanesige/include/asm-ia64/irq.h |    8 +++++++-
 2 files changed, 24 insertions(+), 1 deletion(-)

diff -puN arch/ia64/Kconfig~vector-domain-ia64-change-Kconfig arch/ia64/Kconfig
--- linux-2.6.13-rc1/arch/ia64/Kconfig~vector-domain-ia64-change-Kconfig	2005-07-13 14:33:47.000000000 +0900
+++ linux-2.6.13-rc1-kanesige/arch/ia64/Kconfig	2005-07-13 14:51:35.000000000 +0900
@@ -350,6 +350,23 @@ config ACPI_DEALLOCATE_IRQ
 	depends on IOSAPIC && EXPERIMENTAL
 	default y
 
+config VECTOR_DOMAIN
+	bool "Multiple vector domain support"
+	depends on (SMP && !HOTPLUG_CPU && !PCI_MSI)
+	default n
+	help
+	  This option enables multiple vector domain support. If you
+	  system has many interrupt sources, you should say Y here. If
+	  unsure, say N here.
+
+config NR_VECTOR_DOMAINS
+	int "Maximum number of vector domains (2-512)"
+	range 2 512
+	depends on VECTOR_DOMAIN
+	default 2
+	help
+	  This option specifies muximum number of vector domains.
+
 source "drivers/firmware/Kconfig"
 
 source "fs/Kconfig.binfmt"
diff -puN include/asm-ia64/irq.h~vector-domain-ia64-change-Kconfig include/asm-ia64/irq.h
--- linux-2.6.13-rc1/include/asm-ia64/irq.h~vector-domain-ia64-change-Kconfig	2005-07-13 14:33:47.000000000 +0900
+++ linux-2.6.13-rc1-kanesige/include/asm-ia64/irq.h	2005-07-13 14:50:34.000000000 +0900
@@ -11,7 +11,13 @@
  * 02/29/00     D.Mosberger	moved most things into hw_irq.h
  */
 
-#define NR_IRQS		256
+#ifndef CONFIG_VECTOR_DOMAIN
+#define NR_VECTOR_DOMAINS	(1)
+#else
+#define NR_VECTOR_DOMAINS	CONFIG_NR_VECTOR_DOMAINS
+#endif /* CONFIG_VECTOR_DOMAIN */
+
+#define NR_IRQS		(256 * NR_VECTOR_DOMAINS)
 #define NR_IRQ_VECTORS	NR_IRQS
 
 static __inline__ int

_


