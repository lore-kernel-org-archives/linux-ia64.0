From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 28 Jul 2003 20:39:32 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <marc-linux-ia64-105942507026161@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please do a

	bk pull http://lia64.bkbits.net/to-linus-2.5

This fixes a stupid typo and works around a problem caused by a recent
ACPI change by moving the bootmem initialization before ACPI
initialization.  Together with a three-liner change to the ACPI
subsystem (attached below for the benefit of the linux-ia64 list),
this makes 2.6.0-test2 work on ia64.

Thanks!

	--david

 arch/ia64/kernel/setup.c |    3 +--
 include/asm-ia64/io.h    |    2 +-
 2 files changed, 2 insertions(+), 3 deletions(-)

through these ChangeSets:

<davidm@tiger.hpl.hp.com> (03/07/26 1.1486)
   ia64: Two small fixes to make ia64 build & work again.

=== drivers/acpi/pci_irq.c 1.18 vs edited ==--- 1.18/drivers/acpi/pci_irq.c	Wed Jun 11 09:54:02 2003
+++ edited/drivers/acpi/pci_irq.c	Sat Jul 26 00:05:17 2003
@@ -370,6 +370,10 @@
 		eisa_set_level_irq(dev->irq);
 	}
 #endif
+#ifdef CONFIG_IOSAPIC
+	if (acpi_irq_model = ACPI_IRQ_MODEL_IOSAPIC)
+		iosapic_enable_intr(dev->irq);
+#endif
 
 	return_VALUE(dev->irq);
 }
