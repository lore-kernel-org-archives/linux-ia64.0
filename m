From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Tue, 30 Oct 2007 07:01:49 +0000
Subject: [PATCH] ia64: Fix incorrect return value from ia64_setup_msi_irq()
Message-Id: <4726D6DD.9090300@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Here is a patch to fix the problem that pci_enable_msi() always fails
on ia64 platform.

Thanks,
Kenji Kaneshige
---

Fix the problem that pci_enable_msi() fails on ia64 platform. The cause of
this problem is incorrect return value of ia64_setup_msi_irq(). It must
return 0 on success, instead of irq number.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>

---
 arch/ia64/kernel/msi_ia64.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.24-rc1/arch/ia64/kernel/msi_ia64.c
=================================--- linux-2.6.24-rc1.orig/arch/ia64/kernel/msi_ia64.c
+++ linux-2.6.24-rc1/arch/ia64/kernel/msi_ia64.c
@@ -109,7 +109,7 @@ int ia64_setup_msi_irq(struct pci_dev *p
 	write_msi_msg(irq, &msg);
 	set_irq_chip_and_handler(irq, &ia64_msi_chip, handle_edge_irq);
 
-	return irq;
+	return 0;
 }
 
 void ia64_teardown_msi_irq(unsigned int irq)

