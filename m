From: Matthew Wilcox <willy@fc.hp.com>
Date: Wed, 12 Jun 2002 16:19:36 +0000
Subject: [Linux-ia64] [PATCH] random ia64 acpi fixes
Message-Id: <marc-linux-ia64-105590701905666@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Several changes in this message, pay attention ;-)

This change is required on systems which don't support both legacy &
acpi modes.

diff -urNX ../dontdiff linux-2418/drivers/acpi/hardware/hwacpi.c linux-acpi/drivers/acpi/hardware/hwacpi.c
--- linux-2418/drivers/acpi/hardware/hwacpi.c	Wed Jun 12 09:08:54 2002
+++ linux-acpi/drivers/acpi/hardware/hwacpi.c	Wed Jun 12 09:49:25 2002
@@ -96,6 +96,14 @@
 
 	ACPI_FUNCTION_TRACE ("Hw_set_mode");
 
+
+	if (mode = acpi_hw_get_mode())
+		return_ACPI_STATUS (AE_OK);
+
+	/* If no SMI_CMD, system does not support SMI */
+	if (!acpi_gbl_FADT->smi_cmd)
+		return_ACPI_STATUS (AE_NO_HARDWARE_RESPONSE);
+
 	switch (mode) {
 	case ACPI_SYS_MODE_ACPI:
 
@@ -108,6 +116,10 @@
 
 	case ACPI_SYS_MODE_LEGACY:
 
+		/* If both enable/disable are zero, legacy mode is not supported */
+		if (!acpi_gbl_FADT->acpi_enable && !acpi_gbl_FADT->acpi_disable)
+			return_ACPI_STATUS (AE_NO_HARDWARE_RESPONSE);
+			
 		/*
 		 * BIOS should clear all fixed status bits and restore fixed event
 		 * enable bits to default


Four changes in this file.  First, we don't define _IA64, only
CONFIG_IA64.  Second, we should check the writeback bit, not the
uncacheable bit.  Third, these aren't ISA irqs, they're GSIs, so they're
actually in a different number space from the ISA irqs.  And fourth,
skipping the braces in this kind of construct always leads to trouble.

diff -urNX ../dontdiff linux-2418/drivers/acpi/osl.c linux-acpi/drivers/acpi/osl.c
--- linux-2418/drivers/acpi/osl.c	Wed Jun 12 09:08:54 2002
+++ linux-acpi/drivers/acpi/osl.c	Wed Jun 12 07:20:26 2002
@@ -41,7 +41,7 @@
 u64 efi_mem_attributes (u64 phys_addr);
 #endif
 
-#ifdef _IA64
+#ifdef CONFIG_IA64
 #include <asm/hw_irq.h>
 #include <asm/delay.h>
 #endif
@@ -176,7 +176,7 @@
 acpi_os_map_memory(ACPI_PHYSICAL_ADDRESS phys, ACPI_SIZE size, void **virt)
 {
 #ifdef CONFIG_ACPI_EFI
-	if (EFI_MEMORY_UC & efi_mem_attributes(phys)) {
+	if (!(EFI_MEMORY_WB & efi_mem_attributes(phys))) {
 		*virt = ioremap(phys, size);
 	} else {
 		*virt = phys_to_virt(phys);
@@ -234,9 +234,9 @@
 acpi_status
 acpi_os_install_interrupt_handler(u32 irq, OSD_HANDLER handler, void *context)
 {
-#ifdef _IA64
-	irq = isa_irq_to_vector(irq);
-#endif /*_IA64*/
+#ifdef CONFIG_IA64
+	irq = gsi_to_vector(irq);
+#endif /* CONFIG_IA64 */
 	acpi_irq_irq = irq;
 	acpi_irq_handler = handler;
 	acpi_irq_context = context;
@@ -252,9 +252,9 @@
 acpi_os_remove_interrupt_handler(u32 irq, OSD_HANDLER handler)
 {
 	if (acpi_irq_handler) {
-#ifdef _IA64
-		irq = isa_irq_to_vector(irq);
-#endif /*_IA64*/
+#ifdef CONFIG_IA64
+		irq = gsi_to_vector(irq);
+#endif /* CONFIG_IA64 */
 		free_irq(irq, acpi_irq);
 		acpi_irq_handler = NULL;
 	}
@@ -352,9 +352,9 @@
 	if (EFI_MEMORY_UC & efi_mem_attributes(phys_addr)) {
 		iomem = 1;
 		virt_addr = ioremap(phys_addr, width);
-	} 
-	else
+	} else {
 		virt_addr = phys_to_virt(phys_addr);
+	}
 #else
 	virt_addr = phys_to_virt(phys_addr);
 #endif
@@ -397,9 +397,9 @@
 	if (EFI_MEMORY_UC & efi_mem_attributes(phys_addr)) {
 		iomem = 1;
 		virt_addr = ioremap(phys_addr,width);
-	} 
-	else
+	} else {
 		virt_addr = phys_to_virt(phys_addr);
+	}
 #else
 	virt_addr = phys_to_virt(phys_addr);
 #endif


Won't build on ia64 without this change.

diff -urNX ../dontdiff linux-2418/drivers/acpi/system.c linux-acpi/drivers/acpi/system.c
--- linux-2418/drivers/acpi/system.c	Wed Jun 12 09:08:54 2002
+++ linux-acpi/drivers/acpi/system.c	Wed Jun 12 07:20:26 2002
@@ -37,7 +37,9 @@
 #include <linux/proc_fs.h>
 #include <asm/uaccess.h>
 #include <asm/acpi.h>
+#ifdef __i386__
 #include <asm/save_state.h>
+#endif
 #include "acpi_bus.h"
 #include "acpi_drivers.h"
 

-- 
It's always legal to use Linux (TM) systems
http://www.gnu.org/philosophy/why-free.html

