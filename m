From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Wed, 07 Sep 2005 05:06:25 +0000
Subject: [PATCH 2.6.13 2/3] Minor cleanups - remove CONFIG_ACPI_DEALLOCATE_IRQ
Message-Id: <431E7551.60304@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The config option 'CONFIG_ACPI_DEALLOCATE_IRQ' is no longer
needed. This patch removes it.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
---

 arch/ia64/Kconfig                 |    5 -----
 arch/ia64/configs/sn2_defconfig   |    1 -
 arch/ia64/configs/tiger_defconfig |    1 -
 arch/ia64/configs/zx1_defconfig   |    1 -
 arch/ia64/defconfig               |    1 -
 arch/ia64/kernel/acpi.c           |    2 --
 arch/ia64/kernel/iosapic.c        |    2 --
 arch/ia64/pci/pci.c               |    2 --
 include/asm-ia64/iosapic.h        |    2 --
 9 files changed, 17 deletions(-)

diff -puN arch/ia64/configs/sn2_defconfig~ia64-cleanup-remove-CONFIG_ACPI_DEALLOCATE_IRQ arch/ia64/configs/sn2_defconfig
--- linux-2.6.13/arch/ia64/configs/sn2_defconfig~ia64-cleanup-remove-CONFIG_ACPI_DEALLOCATE_IRQ	2005-09-07 11:53:18.000000000 +0900
+++ linux-2.6.13-kanesige/arch/ia64/configs/sn2_defconfig	2005-09-07 11:53:18.000000000 +0900
@@ -111,7 +111,6 @@ CONFIG_COMPAT=y
 CONFIG_IA64_MCA_RECOVERY=y
 CONFIG_PERFMON=y
 CONFIG_IA64_PALINFO=y
-CONFIG_ACPI_DEALLOCATE_IRQ=y
 
 #
 # Firmware Drivers
diff -puN arch/ia64/configs/tiger_defconfig~ia64-cleanup-remove-CONFIG_ACPI_DEALLOCATE_IRQ arch/ia64/configs/tiger_defconfig
--- linux-2.6.13/arch/ia64/configs/tiger_defconfig~ia64-cleanup-remove-CONFIG_ACPI_DEALLOCATE_IRQ	2005-09-07 11:53:18.000000000 +0900
+++ linux-2.6.13-kanesige/arch/ia64/configs/tiger_defconfig	2005-09-07 11:53:18.000000000 +0900
@@ -109,7 +109,6 @@ CONFIG_COMPAT=y
 CONFIG_IA64_MCA_RECOVERY=y
 CONFIG_PERFMON=y
 CONFIG_IA64_PALINFO=y
-CONFIG_ACPI_DEALLOCATE_IRQ=y
 
 #
 # Firmware Drivers
diff -puN arch/ia64/configs/zx1_defconfig~ia64-cleanup-remove-CONFIG_ACPI_DEALLOCATE_IRQ arch/ia64/configs/zx1_defconfig
--- linux-2.6.13/arch/ia64/configs/zx1_defconfig~ia64-cleanup-remove-CONFIG_ACPI_DEALLOCATE_IRQ	2005-09-07 11:53:18.000000000 +0900
+++ linux-2.6.13-kanesige/arch/ia64/configs/zx1_defconfig	2005-09-07 11:53:18.000000000 +0900
@@ -109,7 +109,6 @@ CONFIG_COMPAT=y
 CONFIG_IA64_MCA_RECOVERY=y
 CONFIG_PERFMON=y
 CONFIG_IA64_PALINFO=y
-CONFIG_ACPI_DEALLOCATE_IRQ=y
 
 #
 # Firmware Drivers
diff -puN arch/ia64/defconfig~ia64-cleanup-remove-CONFIG_ACPI_DEALLOCATE_IRQ arch/ia64/defconfig
--- linux-2.6.13/arch/ia64/defconfig~ia64-cleanup-remove-CONFIG_ACPI_DEALLOCATE_IRQ	2005-09-07 11:53:18.000000000 +0900
+++ linux-2.6.13-kanesige/arch/ia64/defconfig	2005-09-07 11:53:18.000000000 +0900
@@ -99,7 +99,6 @@ CONFIG_COMPAT=y
 CONFIG_IA64_MCA_RECOVERY=y
 CONFIG_PERFMON=y
 CONFIG_IA64_PALINFO=y
-CONFIG_ACPI_DEALLOCATE_IRQ=y
 
 #
 # Firmware Drivers
diff -puN arch/ia64/Kconfig~ia64-cleanup-remove-CONFIG_ACPI_DEALLOCATE_IRQ arch/ia64/Kconfig
--- linux-2.6.13/arch/ia64/Kconfig~ia64-cleanup-remove-CONFIG_ACPI_DEALLOCATE_IRQ	2005-09-07 11:53:18.000000000 +0900
+++ linux-2.6.13-kanesige/arch/ia64/Kconfig	2005-09-07 11:53:18.000000000 +0900
@@ -338,11 +338,6 @@ config IA64_PALINFO
 	  To use this option, you have to ensure that the "/proc file system
 	  support" (CONFIG_PROC_FS) is enabled, too.
 
-config ACPI_DEALLOCATE_IRQ
-	bool
-	depends on IOSAPIC && EXPERIMENTAL
-	default y
-
 source "drivers/firmware/Kconfig"
 
 source "fs/Kconfig.binfmt"
diff -puN arch/ia64/kernel/acpi.c~ia64-cleanup-remove-CONFIG_ACPI_DEALLOCATE_IRQ arch/ia64/kernel/acpi.c
--- linux-2.6.13/arch/ia64/kernel/acpi.c~ia64-cleanup-remove-CONFIG_ACPI_DEALLOCATE_IRQ	2005-09-07 11:53:18.000000000 +0900
+++ linux-2.6.13-kanesige/arch/ia64/kernel/acpi.c	2005-09-07 11:53:18.000000000 +0900
@@ -575,14 +575,12 @@ acpi_register_gsi (u32 gsi, int edge_lev
 }
 EXPORT_SYMBOL(acpi_register_gsi);
 
-#ifdef CONFIG_ACPI_DEALLOCATE_IRQ
 void
 acpi_unregister_gsi (u32 gsi)
 {
 	iosapic_unregister_intr(gsi);
 }
 EXPORT_SYMBOL(acpi_unregister_gsi);
-#endif /* CONFIG_ACPI_DEALLOCATE_IRQ */
 
 static int __init
 acpi_parse_fadt (unsigned long phys_addr, unsigned long size)
diff -puN arch/ia64/kernel/iosapic.c~ia64-cleanup-remove-CONFIG_ACPI_DEALLOCATE_IRQ arch/ia64/kernel/iosapic.c
--- linux-2.6.13/arch/ia64/kernel/iosapic.c~ia64-cleanup-remove-CONFIG_ACPI_DEALLOCATE_IRQ	2005-09-07 11:53:18.000000000 +0900
+++ linux-2.6.13-kanesige/arch/ia64/kernel/iosapic.c	2005-09-07 11:53:18.000000000 +0900
@@ -776,7 +776,6 @@ again:
 	return vector;
 }
 
-#ifdef CONFIG_ACPI_DEALLOCATE_IRQ
 void
 iosapic_unregister_intr (unsigned int gsi)
 {
@@ -859,7 +858,6 @@ iosapic_unregister_intr (unsigned int gs
 	spin_unlock(&iosapic_lock);
 	spin_unlock_irqrestore(&idesc->lock, flags);
 }
-#endif /* CONFIG_ACPI_DEALLOCATE_IRQ */
 
 /*
  * ACPI calls this when it finds an entry for a platform interrupt.
diff -puN arch/ia64/pci/pci.c~ia64-cleanup-remove-CONFIG_ACPI_DEALLOCATE_IRQ arch/ia64/pci/pci.c
--- linux-2.6.13/arch/ia64/pci/pci.c~ia64-cleanup-remove-CONFIG_ACPI_DEALLOCATE_IRQ	2005-09-07 11:53:18.000000000 +0900
+++ linux-2.6.13-kanesige/arch/ia64/pci/pci.c	2005-09-07 11:53:18.000000000 +0900
@@ -499,13 +499,11 @@ pcibios_enable_device (struct pci_dev *d
 	return acpi_pci_irq_enable(dev);
 }
 
-#ifdef CONFIG_ACPI_DEALLOCATE_IRQ
 void
 pcibios_disable_device (struct pci_dev *dev)
 {
 	acpi_pci_irq_disable(dev);
 }
-#endif /* CONFIG_ACPI_DEALLOCATE_IRQ */
 
 void
 pcibios_align_resource (void *data, struct resource *res,
diff -puN include/asm-ia64/iosapic.h~ia64-cleanup-remove-CONFIG_ACPI_DEALLOCATE_IRQ include/asm-ia64/iosapic.h
--- linux-2.6.13/include/asm-ia64/iosapic.h~ia64-cleanup-remove-CONFIG_ACPI_DEALLOCATE_IRQ	2005-09-07 11:53:18.000000000 +0900
+++ linux-2.6.13-kanesige/include/asm-ia64/iosapic.h	2005-09-07 11:53:18.000000000 +0900
@@ -83,9 +83,7 @@ extern int gsi_to_irq (unsigned int gsi)
 extern void iosapic_enable_intr (unsigned int vector);
 extern int iosapic_register_intr (unsigned int gsi, unsigned long polarity,
 				  unsigned long trigger);
-#ifdef CONFIG_ACPI_DEALLOCATE_IRQ
 extern void iosapic_unregister_intr (unsigned int irq);
-#endif
 extern void __init iosapic_override_isa_irq (unsigned int isa_irq, unsigned int gsi,
 				      unsigned long polarity,
 				      unsigned long trigger);
_

