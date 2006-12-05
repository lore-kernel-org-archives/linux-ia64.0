From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Tue, 05 Dec 2006 01:27:02 +0000
Subject: Fix link-time breakage
Message-Id: <17780.51942.167690.885206@croc.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org




Hi,
	I'm seeing:
 `acpiphp_glue_exit' referenced in section `.init.text' of
drivers/built-in.o: defined in discarded section `.exit.text' of
drivers/built-in.o

when trying to compile an IA64 kernel with PCI hotplug enabled.

I suggest this patch:

Signed-off-by: Peter Chubb <peterc@gelato.unsw.edu.au>

Index: linux-2.6-import/drivers/pci/hotplug/acpiphp_glue.c
=================================--- linux-2.6-import.orig/drivers/pci/hotplug/acpiphp_glue.c	2006-12-05 12:14:46.891069194 +1100
+++ linux-2.6-import/drivers/pci/hotplug/acpiphp_glue.c	2006-12-05 12:14:51.887039743 +1100
@@ -1682,7 +1682,7 @@ int __init acpiphp_glue_init(void)
  *
  * This function frees all data allocated in acpiphp_glue_init()
  */
-void __exit acpiphp_glue_exit(void)
+void  acpiphp_glue_exit(void)
 {
 	acpi_pci_unregister_driver(&acpi_pci_hp_driver);
 }

