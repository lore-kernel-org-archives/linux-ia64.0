From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 15 Jul 2003 05:02:04 +0000
Subject: minimai ACPI pci_irq.c for ia64
Message-Id: <marc-linux-ia64-105824533214900@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Andy,

Here is a patch for pci_irq.c.  It's the minimum needed to get PCI
irqs to work on ia64.  In the past, we did some irq.link -> irq
translation magic in this file as well, but since I understand that
the acpi_parse_prt() code is supposed to set the irq member instead,
I updated the ia64 code to do just that.

Would it be possible to get this to Linus asap?  I'm hoping to have
the ia64 kernel be buildable from Linus' sources by the time
2.6.0-test2 is out (yeah, maybe wishful thinking... ;-)

Thanks!

	--david

diff -Nru a/drivers/acpi/pci_irq.c b/drivers/acpi/pci_irq.c
--- a/drivers/acpi/pci_irq.c	Mon Jul 14 21:59:32 2003
+++ b/drivers/acpi/pci_irq.c	Mon Jul 14 21:59:32 2003
@@ -24,6 +24,8 @@
  * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  */
 
+#include <linux/config.h>
+
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/init.h>
@@ -36,6 +38,9 @@
 #ifdef CONFIG_X86_IO_APIC
 #include <asm/mpspec.h>
 #endif
+#ifdef CONFIG_IOSAPIC
+# include <asm/iosapic.h>
+#endif
 #include <acpi/acpi_bus.h>
 #include <acpi/acpi_drivers.h>
 
@@ -369,6 +374,10 @@
 		irq_mask |= (1 << dev->irq);
 		eisa_set_level_irq(dev->irq);
 	}
+#endif
+#ifdef CONFIG_IOSAPIC
+	if (acpi_irq_model = ACPI_IRQ_MODEL_IOSAPIC)
+		iosapic_enable_intr(dev->irq);
 #endif
 
 	return_VALUE(dev->irq);
