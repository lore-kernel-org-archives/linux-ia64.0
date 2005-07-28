From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Thu, 28 Jul 2005 07:58:23 +0000
Subject: [PATCH 2.6.13-rc3 6/6] failure of acpi_register_gsi() should be handled
Message-Id: <42E8901F.6050804@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42E88DC8.7050507@jp.fujitsu.com>
In-Reply-To: <42E88DC8.7050507@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org
Cc: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>


Change iosapic_register_intr(), which called by acpi_register_gsi(),
to return negative value on error instead of panic.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>


---

 linux-2.6.13-rc3-kanesige/arch/ia64/kernel/iosapic.c |   20 ++++++++++++-------
 1 files changed, 13 insertions(+), 7 deletions(-)

diff -puN arch/ia64/kernel/iosapic.c~handle-error-acpi_register_gsi-remove-panic-iosapic-ia64 arch/ia64/kernel/iosapic.c
--- linux-2.6.13-rc3/arch/ia64/kernel/iosapic.c~handle-error-acpi_register_gsi-remove-panic-iosapic-ia64	2005-07-28 01:01:19.000000000 +0900
+++ linux-2.6.13-rc3-kanesige/arch/ia64/kernel/iosapic.c	2005-07-28 01:01:19.000000000 +0900
@@ -561,7 +561,7 @@ static inline int vector_is_shared (int 
 	return (iosapic_intr_info[vector].count > 1);
 }
 
-static void
+static int
 register_intr (unsigned int gsi, int vector, unsigned char delivery,
 	       unsigned long polarity, unsigned long trigger)
 {
@@ -576,7 +576,7 @@ register_intr (unsigned int gsi, int vec
 	index = find_iosapic(gsi);
 	if (index < 0) {
 		printk(KERN_WARNING "%s: No IOSAPIC for GSI %u\n", __FUNCTION__, gsi);
-		return;
+		return -ENODEV;
 	}
 
 	iosapic_address = iosapic_lists[index].addr;
@@ -587,7 +587,7 @@ register_intr (unsigned int gsi, int vec
 		rte = iosapic_alloc_rte();
 		if (!rte) {
 			printk(KERN_WARNING "%s: cannot allocate memory\n", __FUNCTION__);
-			return;
+			return -ENOMEM;
 		}
 
 		rte_index = gsi - gsi_base;
@@ -603,7 +603,7 @@ register_intr (unsigned int gsi, int vec
 		struct iosapic_intr_info *info = &iosapic_intr_info[vector];
 		if (info->trigger != trigger || info->polarity != polarity) {
 			printk (KERN_WARNING "%s: cannot override the interrupt\n", __FUNCTION__);
-			return;
+			return -EINVAL;
 		}
 	}
 
@@ -623,6 +623,7 @@ register_intr (unsigned int gsi, int vec
 			       __FUNCTION__, vector, idesc->handler->typename, irq_type->typename);
 		idesc->handler = irq_type;
 	}
+	return 0;
 }
 
 static unsigned int
@@ -710,7 +711,7 @@ int
 iosapic_register_intr (unsigned int gsi,
 		       unsigned long polarity, unsigned long trigger)
 {
-	int vector, mask = 1;
+	int vector, mask = 1, err;
 	unsigned int dest;
 	unsigned long flags;
 	struct iosapic_rte_info *rte;
@@ -738,7 +739,7 @@ again:
 	if (vector < 0) {
 		vector = iosapic_find_sharable_vector(trigger, polarity);
 		if (vector < 0)
-			panic("%s: out of interrupt vectors!\n", __FUNCTION__);
+			return -ENOSPC;
 	}
 
 	spin_lock_irqsave(&irq_descp(vector)->lock, flags);
@@ -753,8 +754,13 @@ again:
 		}
 
 		dest = get_target_cpu(gsi, vector);
-		register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY,
+		err = register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY,
 			      polarity, trigger);
+		if (err < 0) {
+			spin_unlock(&iosapic_lock);
+			spin_unlock_irqrestore(&irq_descp(vector)->lock, flags);
+			return err;
+		}
 
 		/*
 		 * If the vector is shared and already unmasked for

_

