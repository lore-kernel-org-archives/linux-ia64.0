From: Jiang Liu <liuj97@gmail.com>
Date: Tue, 06 Mar 2012 15:01:52 +0000
Subject: [PATCH] IRQ: normalize chip->irq_set_affinity return value on x86 and IA64
Message-Id: <1331046112-19526-1-git-send-email-jiang.liu@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Jes Sorensen <jes@sgi.com>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Yinghai Lu <yinghai@kernel.org>, Thomas Meyer <thomas@m3y3r.de>
Cc: Jiang Liu <jiang.liu@huawei.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-altix@sgi.com, x86@kernel.org, chenkeping@huawei.com

On x86 and IA64 platforms, interrupt controller chip's irq_set_affinity()
method always copies affinity mask to irq_data->affinity field but still
returns 0(IRQ_SET_MASK_OK). That return value causes the interrupt core
logic unnecessarily copies the mask to irq_data->affinity field again.
So return IRQ_SET_MASK_OK_NOCOPY instead of IRQ_SET_MASK_OK to get rid of
the duplicated copy operation.

This patch applies to v3.3-rc6 and has been tested on x86 platforms.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
---
 arch/ia64/kernel/iosapic.c     |    4 +++-
 arch/ia64/kernel/msi_ia64.c    |    4 ++--
 arch/ia64/sn/kernel/irq.c      |    2 +-
 arch/ia64/sn/kernel/msi_sn.c   |    2 +-
 arch/x86/kernel/apic/io_apic.c |   11 ++++++-----
 arch/x86/platform/uv/uv_irq.c  |    2 +-
 kernel/irq/internals.h         |    3 +++
 kernel/irq/manage.c            |   39 ++++++++++++++++++++++-----------------
 kernel/irq/migration.c         |    6 +-----
 9 files changed, 40 insertions(+), 33 deletions(-)

diff --git a/arch/ia64/kernel/iosapic.c b/arch/ia64/kernel/iosapic.c
index b0f9afe..98f5fa6 100644
--- a/arch/ia64/kernel/iosapic.c
+++ b/arch/ia64/kernel/iosapic.c
@@ -374,8 +374,10 @@ iosapic_set_affinity(struct irq_data *data, const struct cpumask *mask,
 		iosapic_write(iosapic, IOSAPIC_RTE_LOW(rte_index), low32);
 	}
 
+	return IRQ_SET_MASK_OK_NOCOPY;
+#else
+	return IRQ_SET_MASK_OK;
 #endif
-	return 0;
 }
 
 /*
diff --git a/arch/ia64/kernel/msi_ia64.c b/arch/ia64/kernel/msi_ia64.c
index 94e0db7..e155770 100644
--- a/arch/ia64/kernel/msi_ia64.c
+++ b/arch/ia64/kernel/msi_ia64.c
@@ -41,7 +41,7 @@ static int ia64_set_msi_irq_affinity(struct irq_data *idata,
 	write_msi_msg(irq, &msg);
 	cpumask_copy(idata->affinity, cpumask_of(cpu));
 
-	return 0;
+	return IRQ_SET_MASK_OK_NOCOPY;
 }
 #endif /* CONFIG_SMP */
 
@@ -157,7 +157,7 @@ static int dmar_msi_set_affinity(struct irq_data *data,
 	dmar_msi_write(irq, &msg);
 	cpumask_copy(data->affinity, mask);
 
-	return 0;
+	return IRQ_SET_MASK_OK_NOCOPY;
 }
 #endif /* CONFIG_SMP */
 
diff --git a/arch/ia64/sn/kernel/irq.c b/arch/ia64/sn/kernel/irq.c
index dfac09a..f444208 100644
--- a/arch/ia64/sn/kernel/irq.c
+++ b/arch/ia64/sn/kernel/irq.c
@@ -216,7 +216,7 @@ static int sn_set_affinity_irq(struct irq_data *data,
 				 sn_irq_lh[irq], list)
 		(void)sn_retarget_vector(sn_irq_info, nasid, slice);
 
-	return 0;
+	return IRQ_SET_MASK_OK_NOCOPY;
 }
 
 #ifdef CONFIG_SMP
diff --git a/arch/ia64/sn/kernel/msi_sn.c b/arch/ia64/sn/kernel/msi_sn.c
index 2b98b9e..ebb5b55 100644
--- a/arch/ia64/sn/kernel/msi_sn.c
+++ b/arch/ia64/sn/kernel/msi_sn.c
@@ -208,7 +208,7 @@ static int sn_set_msi_irq_affinity(struct irq_data *data,
 	write_msi_msg(irq, &msg);
 	cpumask_copy(data->affinity, cpu_mask);
 
-	return 0;
+	return IRQ_SET_MASK_OK_NOCOPY;
 }
 #endif /* CONFIG_SMP */
 
diff --git a/arch/x86/kernel/apic/io_apic.c b/arch/x86/kernel/apic/io_apic.c
index fb07275..a81f888 100644
--- a/arch/x86/kernel/apic/io_apic.c
+++ b/arch/x86/kernel/apic/io_apic.c
@@ -2346,6 +2346,7 @@ ioapic_set_affinity(struct irq_data *data, const struct cpumask *mask,
 		/* Only the high 8 bits are valid. */
 		dest = SET_APIC_LOGICAL_ID(dest);
 		__target_IO_APIC_irq(irq, dest, data->chip_data);
+		ret = IRQ_SET_MASK_OK_NOCOPY;
 	}
 	raw_spin_unlock_irqrestore(&ioapic_lock, flags);
 	return ret;
@@ -2404,7 +2405,7 @@ ir_ioapic_set_affinity(struct irq_data *data, const struct cpumask *mask,
 		send_cleanup_vector(cfg);
 
 	cpumask_copy(data->affinity, mask);
-	return 0;
+	return IRQ_SET_MASK_OK_NOCOPY;
 }
 
 #else
@@ -3209,7 +3210,7 @@ msi_set_affinity(struct irq_data *data, const struct cpumask *mask, bool force)
 
 	__write_msi_msg(data->msi_desc, &msg);
 
-	return 0;
+	return IRQ_SET_MASK_OK_NOCOPY;
 }
 #endif /* CONFIG_SMP */
 
@@ -3366,7 +3367,7 @@ dmar_msi_set_affinity(struct irq_data *data, const struct cpumask *mask,
 
 	dmar_msi_write(irq, &msg);
 
-	return 0;
+	return IRQ_SET_MASK_OK_NOCOPY;
 }
 
 #endif /* CONFIG_SMP */
@@ -3419,7 +3420,7 @@ static int hpet_msi_set_affinity(struct irq_data *data,
 
 	hpet_msi_write(data->handler_data, &msg);
 
-	return 0;
+	return IRQ_SET_MASK_OK_NOCOPY;
 }
 
 #endif /* CONFIG_SMP */
@@ -3499,7 +3500,7 @@ ht_set_affinity(struct irq_data *data, const struct cpumask *mask, bool force)
 		return -1;
 
 	target_ht_irq(data->irq, dest, cfg->vector);
-	return 0;
+	return IRQ_SET_MASK_OK_NOCOPY;
 }
 
 #endif
diff --git a/arch/x86/platform/uv/uv_irq.c b/arch/x86/platform/uv/uv_irq.c
index f25c276..a22c416 100644
--- a/arch/x86/platform/uv/uv_irq.c
+++ b/arch/x86/platform/uv/uv_irq.c
@@ -222,7 +222,7 @@ uv_set_irq_affinity(struct irq_data *data, const struct cpumask *mask,
 	if (cfg->move_in_progress)
 		send_cleanup_vector(cfg);
 
-	return 0;
+	return IRQ_SET_MASK_OK_NOCOPY;
 }
 
 /*
diff --git a/kernel/irq/internals.h b/kernel/irq/internals.h
index b795231..2c49c40 100644
--- a/kernel/irq/internals.h
+++ b/kernel/irq/internals.h
@@ -103,6 +103,9 @@ extern int irq_select_affinity_usr(unsigned int irq, struct cpumask *mask);
 
 extern void irq_set_thread_affinity(struct irq_desc *desc);
 
+extern int irq_do_set_affinity(struct irq_data *data,
+			       const struct cpumask *dest, bool force);
+
 /* Inline functions for support of irq chips on slow busses */
 static inline void chip_bus_lock(struct irq_desc *desc)
 {
diff --git a/kernel/irq/manage.c b/kernel/irq/manage.c
index a9a9dbe..b410b0b 100644
--- a/kernel/irq/manage.c
+++ b/kernel/irq/manage.c
@@ -139,6 +139,25 @@ static inline void
 irq_get_pending(struct cpumask *mask, struct irq_desc *desc) { }
 #endif
 
+int irq_do_set_affinity(struct irq_data *data, const struct cpumask *mask,
+			bool force)
+{
+	struct irq_desc *desc = irq_data_to_desc(data);
+	struct irq_chip *chip = irq_data_get_irq_chip(data);
+	int ret;
+
+	ret = chip->irq_set_affinity(data, mask, false);
+	switch (ret) {
+	case IRQ_SET_MASK_OK:
+		cpumask_copy(data->affinity, mask);
+	case IRQ_SET_MASK_OK_NOCOPY:
+		irq_set_thread_affinity(desc);
+		ret = 0;
+	}
+
+	return ret;
+}
+
 int __irq_set_affinity_locked(struct irq_data *data, const struct cpumask *mask)
 {
 	struct irq_chip *chip = irq_data_get_irq_chip(data);
@@ -149,14 +168,7 @@ int __irq_set_affinity_locked(struct irq_data *data, const struct cpumask *mask)
 		return -EINVAL;
 
 	if (irq_can_move_pcntxt(data)) {
-		ret = chip->irq_set_affinity(data, mask, false);
-		switch (ret) {
-		case IRQ_SET_MASK_OK:
-			cpumask_copy(data->affinity, mask);
-		case IRQ_SET_MASK_OK_NOCOPY:
-			irq_set_thread_affinity(desc);
-			ret = 0;
-		}
+		ret = irq_do_set_affinity(data, mask, false);
 	} else {
 		irqd_set_move_pending(data);
 		irq_copy_pending(desc, mask);
@@ -280,9 +292,7 @@ EXPORT_SYMBOL_GPL(irq_set_affinity_notifier);
 static int
 setup_affinity(unsigned int irq, struct irq_desc *desc, struct cpumask *mask)
 {
-	struct irq_chip *chip = irq_desc_get_chip(desc);
 	struct cpumask *set = irq_default_affinity;
-	int ret;
 
 	/* Excludes PER_CPU and NO_BALANCE interrupts */
 	if (!irq_can_set_affinity(irq))
@@ -301,13 +311,8 @@ setup_affinity(unsigned int irq, struct irq_desc *desc, struct cpumask *mask)
 	}
 
 	cpumask_and(mask, cpu_online_mask, set);
-	ret = chip->irq_set_affinity(&desc->irq_data, mask, false);
-	switch (ret) {
-	case IRQ_SET_MASK_OK:
-		cpumask_copy(desc->irq_data.affinity, mask);
-	case IRQ_SET_MASK_OK_NOCOPY:
-		irq_set_thread_affinity(desc);
-	}
+	irq_do_set_affinity(&desc->irq_data, mask, false);
+
 	return 0;
 }
 #else
diff --git a/kernel/irq/migration.c b/kernel/irq/migration.c
index 4742090..ef04dab 100644
--- a/kernel/irq/migration.c
+++ b/kernel/irq/migration.c
@@ -44,11 +44,7 @@ void irq_move_masked_irq(struct irq_data *idata)
 	 */
 	if (likely(cpumask_any_and(desc->pending_mask, cpu_online_mask)
 		   < nr_cpu_ids))
-		if (!chip->irq_set_affinity(&desc->irq_data,
-					    desc->pending_mask, false)) {
-			cpumask_copy(desc->irq_data.affinity, desc->pending_mask);
-			irq_set_thread_affinity(desc);
-		}
+		irq_do_set_affinity(&desc->irq_data, desc->pending_mask, false);
 
 	cpumask_clear(desc->pending_mask);
 }
-- 
1.7.5.4

