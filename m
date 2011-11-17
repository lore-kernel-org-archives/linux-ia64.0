From: Thomas Meyer <thomas@m3y3r.de>
Date: Thu, 17 Nov 2011 22:43:40 +0000
Subject: [PATCH] ia64: sn: Use kmemdup rather than duplicating its
Message-Id: <1321569820.1624.269.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: jes@sgi.com, tony.luck@intel.com, fenghua.yu@intel.com, linux-altix@sgi.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

The semantic patch that makes this change is available
in scripts/coccinelle/api/memdup.cocci.

Signed-off-by: Thomas Meyer <thomas@m3y3r.de>
---

diff -u -p a/arch/ia64/sn/kernel/irq.c b/arch/ia64/sn/kernel/irq.c
--- a/arch/ia64/sn/kernel/irq.c 2011-11-07 19:37:22.046225104 +0100
+++ b/arch/ia64/sn/kernel/irq.c 2011-11-08 11:01:33.601378758 +0100
@@ -150,12 +150,11 @@ struct sn_irq_info *sn_retarget_vector(s
 	 * PROM does not support SAL_INTR_REDIRECT, or it failed.
 	 * Revert to old method.
 	 */
-	new_irq_info = kmalloc(sizeof(struct sn_irq_info), GFP_ATOMIC);
+	new_irq_info = kmemdup(sn_irq_info, sizeof(struct sn_irq_info),
+			       GFP_ATOMIC);
 	if (new_irq_info = NULL)
 		return NULL;
 
-	memcpy(new_irq_info, sn_irq_info, sizeof(struct sn_irq_info));
-
 	/* Free the old PROM new_irq_info structure */
 	sn_intr_free(local_nasid, local_widget, new_irq_info);
 	unregister_intr_pda(new_irq_info);
