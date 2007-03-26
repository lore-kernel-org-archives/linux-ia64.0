From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Mon, 26 Mar 2007 00:38:42 +0000
Subject: [PATCH][BUG] Fix possible invalid memory access in ia64_setup_msi_irq()
Message-Id: <46071612.4040900@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following 'if' statement in ia64_setup_msi_irq() always fails even
if create_irq() returns <0 value, because variable 'irq' is defined as
unsigned int. It would cause invalid memory access.

        irq = create_irq();
        if (irq < 0)
                return irq;

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
---
 arch/ia64/kernel/msi_ia64.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.21-rc5/arch/ia64/kernel/msi_ia64.c
=================================--- linux-2.6.21-rc5.orig/arch/ia64/kernel/msi_ia64.c	2007-03-26 09:24:26.000000000 +0900
+++ linux-2.6.21-rc5/arch/ia64/kernel/msi_ia64.c	2007-03-26 09:25:51.000000000 +0900
@@ -68,7 +68,7 @@
 {
 	struct msi_msg	msg;
 	unsigned long	dest_phys_id;
-	unsigned int	irq, vector;
+	int	irq, vector;
 
 	irq = create_irq();
 	if (irq < 0)

