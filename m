From: Jiang Liu <liuj97@gmail.com>
Date: Sun, 01 Apr 2012 16:33:51 +0000
Subject: [PATCH 3/4] IRQ,IA64: remove redundant memory copy operations in chip->irq_set_affinity()
Message-Id: <1333298032-4047-3-git-send-email-jiang.liu@huawei.com>
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
method. If chip->irq_set_affinity() doesn't change the affinity mask passed in,
it should return IRQ_SET_MASK_OK and the core logic will copy the affinity
mask to irq_data->affinity field.

Several xxx_irq_set_affinity() methods for IA64 platforms still return
0(IRQ_SET_MASK_OK) after copying the affinity mask to irq_data->affinity field,
so remove the redundant memory copy operations.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
---
 arch/ia64/kernel/msi_ia64.c  |    2 --
 arch/ia64/sn/kernel/msi_sn.c |    1 -
 2 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/kernel/msi_ia64.c b/arch/ia64/kernel/msi_ia64.c
index fb2f1e6..05f5dc6 100644
--- a/arch/ia64/kernel/msi_ia64.c
+++ b/arch/ia64/kernel/msi_ia64.c
@@ -39,7 +39,6 @@ static int ia64_set_msi_irq_affinity(struct irq_data *idata,
 	msg.data = data;
 
 	write_msi_msg(irq, &msg);
-	cpumask_copy(idata->affinity, cpumask_of(cpu));
 
 	return 0;
 }
@@ -155,7 +154,6 @@ static int dmar_msi_set_affinity(struct irq_data *data,
 	msg.address_lo |= MSI_ADDR_DEST_ID_CPU(cpu_physical_id(cpu));
 
 	dmar_msi_write(irq, &msg);
-	cpumask_copy(data->affinity, mask);
 
 	return 0;
 }
diff --git a/arch/ia64/sn/kernel/msi_sn.c b/arch/ia64/sn/kernel/msi_sn.c
index 2b98b9e..a033fc9 100644
--- a/arch/ia64/sn/kernel/msi_sn.c
+++ b/arch/ia64/sn/kernel/msi_sn.c
@@ -206,7 +206,6 @@ static int sn_set_msi_irq_affinity(struct irq_data *data,
 	msg.address_lo = (u32)(bus_addr & 0x00000000ffffffff);
 
 	write_msi_msg(irq, &msg);
-	cpumask_copy(data->affinity, cpu_mask);
 
 	return 0;
 }
-- 
1.7.5.4

