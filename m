From: Amit Gud <gud@eth.net>
Date: Tue, 29 Mar 2005 12:32:09 +0000
Subject: [PATCH 3/91] get rid of pci_find_{device,subsys} arch/ia64
Message-Id: <ITPXCHFE1eemY5Z6NBt00002069@itpxchfe1.enterprise.veritas.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050329122242.GA26755@infradead.org>
In-Reply-To: <20050329122242.GA26755@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Replace pci_find_{device,subsys} with pci_get_{device,subsys}.



Signed-off-by: Amit Gud <gud@eth.net>

---
diff -upr orig-2.6.12-rc1/arch/ia64/sn/kernel/io_init.c work-2.6.12-rc1/arch/ia64/sn/kernel/io_init.c
--- orig-2.6.12-rc1/arch/ia64/sn/kernel/io_init.c	2005-03-15 21:00:10.000000000 +0530
+++ work-2.6.12-rc1/arch/ia64/sn/kernel/io_init.c	2005-03-24 15:29:23.539955472 +0530
@@ -365,8 +365,9 @@ static int __init sn_pci_init(void)
 	 */
 
 	while ((pci_dev -		pci_find_device(PCI_ANY_ID, PCI_ANY_ID, pci_dev)) != NULL) {
+		pci_get_device(PCI_ANY_ID, PCI_ANY_ID, pci_dev)) != NULL) {
 		sn_pci_fixup_slot(pci_dev);
+		pci_dev_put(dev);
 	}
 
 	sn_ioif_inited = 1;	/* sn I/O infrastructure now initialized */
