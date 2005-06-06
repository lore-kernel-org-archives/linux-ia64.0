From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Mon, 06 Jun 2005 05:22:13 +0000
Subject: [PATCH] assign_irq_vector() should not panic
Message-Id: <42A3DD85.60009@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Current assign_irq_vector() will panic if interrupt vectors are running
out. But I think how to handle the case of lack of interrupt vectors
should be decided by the caller of this function. For example, some
PCI devices can raise the interrupt signal via both MSI and I/O
APIC. So even if the driver for these device fails to allocate a
vector for MSI, the driver still has a chance to use I/O APIC based
interrupt. But currently there is no chance for these driver to use
I/O APIC based interrupt because kernel will panic when
assign_irq_vector() fails to allocate interrupt vector for MSI.

The following patch changes assign_irq_vector() for ia64 to return
negative value on error instead of panic.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>


---

 linux-2.6.12-rc5-kanesige/arch/ia64/kernel/iosapic.c  |   10 +++++++---
 linux-2.6.12-rc5-kanesige/arch/ia64/kernel/irq_ia64.c |   13 +------------
 2 files changed, 8 insertions(+), 15 deletions(-)

diff -puN arch/ia64/kernel/iosapic.c~change_assign_irq_vector_ia64 arch/ia64/kernel/iosapic.c
--- linux-2.6.12-rc5/arch/ia64/kernel/iosapic.c~change_assign_irq_vector_ia64	2005-06-06 12:10:08.000000000 +0900
+++ linux-2.6.12-rc5-kanesige/arch/ia64/kernel/iosapic.c	2005-06-06 12:10:08.000000000 +0900
@@ -490,8 +490,6 @@ static int iosapic_find_sharable_vector 
 			}
 		}
 	}
-	if (vector < 0)
-		panic("%s: out of interrupt vectors!\n", __FUNCTION__);
 
 	return vector;
 }
@@ -507,6 +505,8 @@ iosapic_reassign_vector (int vector)
 
 	if (!list_empty(&iosapic_intr_info[vector].rtes)) {
 		new_vector = assign_irq_vector(AUTO_ASSIGN);
+		if (new_vector < 0)
+			panic("%s: out of interrupt vectors!\n", __FUNCTION__);
 		printk(KERN_INFO "Reassigning vector %d to %d\n", vector, new_vector);
 		memcpy(&iosapic_intr_info[new_vector], &iosapic_intr_info[vector],
 		       sizeof(struct iosapic_intr_info));
@@ -734,9 +734,11 @@ again:
 	spin_unlock_irqrestore(&iosapic_lock, flags);
 
 	/* If vector is running out, we try to find a sharable vector */
-	vector = assign_irq_vector_nopanic(AUTO_ASSIGN);
+	vector = assign_irq_vector(AUTO_ASSIGN);
 	if (vector < 0)
 		vector = iosapic_find_sharable_vector(trigger, polarity);
+	if (vector < 0)
+		panic("%s: out of interrupt vectors!\n", __FUNCTION__);
 
 	spin_lock_irqsave(&irq_descp(vector)->lock, flags);
 	spin_lock(&iosapic_lock);
@@ -881,6 +883,8 @@ iosapic_register_platform_intr (u32 int_
 		break;
 	      case ACPI_INTERRUPT_INIT:
 		vector = assign_irq_vector(AUTO_ASSIGN);
+		if (vector < 0)
+			panic("%s: out of interrupt vectors!\n", __FUNCTION__);
 		delivery = IOSAPIC_INIT;
 		break;
 	      case ACPI_INTERRUPT_CPEI:
diff -puN arch/ia64/kernel/irq_ia64.c~change_assign_irq_vector_ia64 arch/ia64/kernel/irq_ia64.c
--- linux-2.6.12-rc5/arch/ia64/kernel/irq_ia64.c~change_assign_irq_vector_ia64	2005-06-06 12:10:08.000000000 +0900
+++ linux-2.6.12-rc5-kanesige/arch/ia64/kernel/irq_ia64.c	2005-06-06 12:10:08.000000000 +0900
@@ -63,7 +63,7 @@ EXPORT_SYMBOL(isa_irq_to_vector_map);
 static unsigned long ia64_vector_mask[BITS_TO_LONGS(IA64_NUM_DEVICE_VECTORS)];
 
 int
-assign_irq_vector_nopanic (int irq)
+assign_irq_vector (int irq)
 {
 	int pos, vector;
  again:
@@ -76,17 +76,6 @@ assign_irq_vector_nopanic (int irq)
 	return vector;
 }
 
-int
-assign_irq_vector (int irq)
-{
-	int vector = assign_irq_vector_nopanic(irq);
-
-	if (vector < 0)
-		panic("assign_irq_vector: out of interrupt vectors!");
-
-	return vector;
-}
-
 void
 free_irq_vector (int vector)
 {

_
