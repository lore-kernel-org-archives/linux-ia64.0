From: Jiang Liu <liuj97@gmail.com>
Date: Sun, 01 Apr 2012 16:33:52 +0000
Subject: [PATCH 4/4] IRQ,IA64: normalize return value of chip->irq_set_affinity() method
Message-Id: <1333298032-4047-4-git-send-email-jiang.liu@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1333298032-4047-1-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1333298032-4047-1-git-send-email-jiang.liu@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Jiang Liu <jiang.liu@huawei.com>, Jiang Liu <liuj97@gmail.com>, Keping Chen <chenkeping@huawei.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-altix@sgi.com


Changeset 3b8249e7 has introduced standard return value IRQ_SET_MASK_OK(0) and
IRQ_SET_MASK_OK_NOCOPY(1) for interrupt controller chip's set_irq_affinity()
method. So use IRQ_SET_MASK_OK instead of 0 for consistency.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
---
 arch/ia64/kernel/iosapic.c   |    4 ++--
 arch/ia64/kernel/msi_ia64.c  |    4 ++--
 arch/ia64/sn/kernel/irq.c    |    2 +-
 arch/ia64/sn/kernel/msi_sn.c |    2 +-
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/arch/ia64/kernel/iosapic.c b/arch/ia64/kernel/iosapic.c
index ef4b5d8..5f67fcb 100644
--- a/arch/ia64/kernel/iosapic.c
+++ b/arch/ia64/kernel/iosapic.c
@@ -372,9 +372,9 @@ iosapic_set_affinity(struct irq_data *data, const struct cpumask *mask,
 		iosapic_write(iosapic, IOSAPIC_RTE_HIGH(rte_index), high32);
 		iosapic_write(iosapic, IOSAPIC_RTE_LOW(rte_index), low32);
 	}
-
 #endif
-	return 0;
+
+	return IRQ_SET_MASK_OK;
 }
 
 /*
diff --git a/arch/ia64/kernel/msi_ia64.c b/arch/ia64/kernel/msi_ia64.c
index 05f5dc6..e1cc71d 100644
--- a/arch/ia64/kernel/msi_ia64.c
+++ b/arch/ia64/kernel/msi_ia64.c
@@ -40,7 +40,7 @@ static int ia64_set_msi_irq_affinity(struct irq_data *idata,
 
 	write_msi_msg(irq, &msg);
 
-	return 0;
+	return IRQ_SET_MASK_OK;
 }
 #endif /* CONFIG_SMP */
 
@@ -155,7 +155,7 @@ static int dmar_msi_set_affinity(struct irq_data *data,
 
 	dmar_msi_write(irq, &msg);
 
-	return 0;
+	return IRQ_SET_MASK_OK;
 }
 #endif /* CONFIG_SMP */
 
diff --git a/arch/ia64/sn/kernel/irq.c b/arch/ia64/sn/kernel/irq.c
index 62cf4dd..57cedda 100644
--- a/arch/ia64/sn/kernel/irq.c
+++ b/arch/ia64/sn/kernel/irq.c
@@ -216,7 +216,7 @@ static int sn_set_affinity_irq(struct irq_data *data,
 				 sn_irq_lh[irq], list)
 		(void)sn_retarget_vector(sn_irq_info, nasid, slice);
 
-	return 0;
+	return IRQ_SET_MASK_OK;
 }
 
 #ifdef CONFIG_SMP
diff --git a/arch/ia64/sn/kernel/msi_sn.c b/arch/ia64/sn/kernel/msi_sn.c
index a033fc9..4249c87 100644
--- a/arch/ia64/sn/kernel/msi_sn.c
+++ b/arch/ia64/sn/kernel/msi_sn.c
@@ -207,7 +207,7 @@ static int sn_set_msi_irq_affinity(struct irq_data *data,
 
 	write_msi_msg(irq, &msg);
 
-	return 0;
+	return IRQ_SET_MASK_OK;
 }
 #endif /* CONFIG_SMP */
 
-- 
1.7.5.4

