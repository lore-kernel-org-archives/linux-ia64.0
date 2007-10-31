From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Wed, 31 Oct 2007 11:06:21 +0000
Subject: [PATCH] ia64: Fix IOSAPIC delivery mode setting
Message-Id: <472861AD.5050107@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Fix the problem that redirect hit bit in I/O SAPIC RTE is set even
when it must be disabled (e.g. nointroute boot option is set, CPU
hotplug is enabled or percpu vector is enabled).

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>

---
 arch/ia64/kernel/iosapic.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

Index: linux-2.6.24-rc1/arch/ia64/kernel/iosapic.c
=================================--- linux-2.6.24-rc1.orig/arch/ia64/kernel/iosapic.c
+++ linux-2.6.24-rc1/arch/ia64/kernel/iosapic.c
@@ -762,6 +762,12 @@ iosapic_register_intr (unsigned int gsi,
 	unsigned long flags;
 	struct iosapic_rte_info *rte;
 	u32 low32;
+	unsigned char dmode;
+
+	if (smp_int_redirect & SMP_IRQ_REDIRECTION)
+		dmode = IOSAPIC_LOWEST_PRIORITY;
+	else
+		dmode = IOSAPIC_FIXED;
 
 	/*
 	 * If this GSI has already been registered (i.e., it's a
@@ -791,8 +797,7 @@ iosapic_register_intr (unsigned int gsi,
 
 	spin_lock(&irq_desc[irq].lock);
 	dest = get_target_cpu(gsi, irq);
-	err = register_intr(gsi, irq, IOSAPIC_LOWEST_PRIORITY,
-			    polarity, trigger);
+	err = register_intr(gsi, irq, dmode, polarity, trigger);
 	if (err < 0) {
 		spin_unlock(&irq_desc[irq].lock);
 		irq = err;

