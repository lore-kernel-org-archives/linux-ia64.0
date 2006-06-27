From: Horms <horms@verge.net.au>
Date: Tue, 27 Jun 2006 07:16:02 +0000
Subject: [PATCH] ia64, kexec: shutting down the PCI devices does not seem to be neccessary
Message-Id: <20060627071600.GA25965@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

As suggested by Nanhai Zou, it seems that the pci shutdown code in kdump
is not neccessary. I tested the patch on a Tiger2 box, and it seems
to work fine.

Signed-off-by: Horms <horms@verge.net.au>

 arch/ia64/kernel/crash.c |   21 ---------------------
 1 file changed, 21 deletions(-)

db4590a1c287d873fc97d81230579065c4927ac6
diff --git a/arch/ia64/kernel/crash.c b/arch/ia64/kernel/crash.c
index 6623bfc..3f46ee6 100644
--- a/arch/ia64/kernel/crash.c
+++ b/arch/ia64/kernel/crash.c
@@ -22,26 +22,6 @@ #include <linux/elf.h>
 #include <linux/elfcore.h>
 #include <linux/device.h>
 
-static void device_shootdown(void)
-{
-       struct pci_dev *dev;
-       irq_desc_t *desc;
-       u16 pci_command;
-
-       list_for_each_entry(dev, &pci_devices, global_list) {
-               desc = irq_descp(dev->irq);
-               if (!desc->action)
-                       continue;
-               pci_read_config_word(dev, PCI_COMMAND, &pci_command);
-               if (pci_command & PCI_COMMAND_MASTER) {
-                       pci_command &= ~PCI_COMMAND_MASTER;
-                       pci_write_config_word(dev, PCI_COMMAND, pci_command);
-               }
-               disable_irq_nosync(dev->irq);
-               desc->handler->end(dev->irq);
-       }
-}
-
 static Elf64_Word
 *append_elf_note(Elf64_Word *buf, char *name, unsigned type, void *data,
 		size_t data_len)
@@ -123,7 +103,6 @@ machine_crash_shutdown(struct pt_regs *p
 		ia64_eoi();
 	}
 	crash_save_this_cpu();
-	device_shootdown();
 #ifdef CONFIG_SMP
 	smp_send_stop();
 #endif
