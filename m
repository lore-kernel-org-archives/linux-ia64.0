From: domen@coderock.org
Date: Mon, 10 Jan 2005 19:46:35 +0000
Subject: [patch 2/3] Replace pci_find_device with pci_get_device
Message-Id: <20050110194635.844AE1F203@trashy.coderock.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org




As pci_find_device is going away soon I have replaced the call with pci_get_device.
Judith, could you run these 3 ia64 ones through PLM, please? 

Thanks a lot.

Hanna Linder
IBM Linux Technology Center

Signed-off-by: Hanna Linder <hannal@us.ibm.com>
Acked-by: Judith Lebzelter <judith@osdl.org>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>

---

Signed-off-by: Domen Puncer <domen@coderock.org>
---


 kj-domen/arch/ia64/pci/pci.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN arch/ia64/pci/pci.c~pci_dev_present-arch_ia64_pci_pci arch/ia64/pci/pci.c
--- kj/arch/ia64/pci/pci.c~pci_dev_present-arch_ia64_pci_pci	2005-01-10 18:00:15.000000000 +0100
+++ kj-domen/arch/ia64/pci/pci.c	2005-01-10 18:00:15.000000000 +0100
@@ -154,7 +154,7 @@ extern acpi_status acpi_map_iosapic (acp
 		printk(KERN_INFO "** was specified.  If this was required to make a driver work,\n");
 		printk(KERN_INFO "** please email the output of \"lspci\" to bjorn.helgaas@hp.com\n");
 		printk(KERN_INFO "** so I can fix the driver.\n");
-		while ((dev = pci_find_device(PCI_ANY_ID, PCI_ANY_ID, dev)) != NULL)
+		while ((dev = pci_get_device(PCI_ANY_ID, PCI_ANY_ID, dev)) != NULL)
 			acpi_pci_irq_enable(dev);
 	} else {
 		printk(KERN_INFO "** PCI interrupts are no longer routed automatically.  If this\n");
_
