From: Jiang Liu <jiang.liu@linux.intel.com>
Date: Mon, 01 Jun 2015 08:05:44 +0000
Subject: [Patch v3 35/36] genirq: Pass irq_data to helper function __irq_set_chip_handler_name_locked()
Message-Id: <1433145945-789-36-git-send-email-jiang.liu@linux.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1433145945-789-1-git-send-email-jiang.liu@linux.intel.com>
In-Reply-To: <1433145945-789-1-git-send-email-jiang.liu-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Bjorn Helgaas <bhelgaas-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Randy Dunlap <rdunlap-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Yinghai Lu <yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Borislav Petkov <bp-Gina5bIWoIWzQB+pC5nmwQ@public.gmane.org>, Tony Luck <tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Fenghua Yu <fenghua.yu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Ralf Baechle <ralf-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org>, Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Michal Simek <michal.simek-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>, =?UTF-8?q?S=C3=B6ren=20Brinkmann?= <soren.brinkmann-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>, James Hogan <james.hogan-1AXoQHu6uovQT0dZR+AlfA@public.gmane.org>, Jason Cooper <jason-NLaQJdtUoK4Be96aLqz0jA@public.gmane.org>, Jiang Liu <jiang.liu-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, Manuel Lauss <manuel.lauss-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Marc Zyngier <marc.zyngier-5wv7dgnIgG8@public.gmane.org>
Cc: Konrad Rzeszutek Wilk <konrad.wilk-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, linux-gpio-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

For most cases, callers pass irq_data->irq to helper function
__irq_set_chip_handler_name_locked() and __irq_set_chip_handler_name_locked()
looks up irq_data again by calling irq_get_irq_data(irq_data->irq).

So pass irq_data directly instead of irq_data->irq to
__irq_set_chip_handler_name_locked().

This also helps to better support hierarchy irqdomain in irq core.

Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
---
 arch/ia64/kernel/iosapic.c      |    6 +++---
 arch/mips/alchemy/common/irq.c  |    4 ++--
 drivers/gpio/gpio-zynq.c        |    9 ++++-----
 drivers/irqchip/irq-metag-ext.c |    5 ++---
 drivers/irqchip/irq-mips-gic.c  |   11 ++++-------
 include/linux/irqdesc.h         |    7 +++----
 6 files changed, 18 insertions(+), 24 deletions(-)

diff --git a/arch/ia64/kernel/iosapic.c b/arch/ia64/kernel/iosapic.c
index 4d2698d43c39..317993e92cba 100644
--- a/arch/ia64/kernel/iosapic.c
+++ b/arch/ia64/kernel/iosapic.c
@@ -610,9 +610,9 @@ register_intr (unsigned int gsi, int irq, unsigned char delivery,
 			       chip->name, irq_type->name);
 		chip = irq_type;
 	}
-	__irq_set_chip_handler_name_locked(irq, chip, trigger = IOSAPIC_EDGE ?
-					   handle_edge_irq : handle_level_irq,
-					   NULL);
+	__irq_set_chip_handler_name_locked(irq_get_irq_data(irq), chip,
+		trigger = IOSAPIC_EDGE ? handle_edge_irq : handle_level_irq,
+		NULL);
 	return 0;
 }
 
diff --git a/arch/mips/alchemy/common/irq.c b/arch/mips/alchemy/common/irq.c
index 6cb60abfdcc9..026c4eed37d5 100644
--- a/arch/mips/alchemy/common/irq.c
+++ b/arch/mips/alchemy/common/irq.c
@@ -491,7 +491,7 @@ static int au1x_ic_settype(struct irq_data *d, unsigned int flow_type)
 	default:
 		ret = -EINVAL;
 	}
-	__irq_set_chip_handler_name_locked(d->irq, chip, handler, name);
+	__irq_set_chip_handler_name_locked(d, chip, handler, name);
 
 	wmb();
 
@@ -703,7 +703,7 @@ static int au1300_gpic_settype(struct irq_data *d, unsigned int type)
 		return -EINVAL;
 	}
 
-	__irq_set_chip_handler_name_locked(d->irq, &au1300_gpic, hdl, name);
+	__irq_set_chip_handler_name_locked(d, &au1300_gpic, hdl, name);
 
 	au1300_gpic_chgcfg(d->irq - ALCHEMY_GPIC_INT_BASE, GPIC_CFG_IC_MASK, s);
 
diff --git a/drivers/gpio/gpio-zynq.c b/drivers/gpio/gpio-zynq.c
index 184c4b1b2558..aea6075e5b2e 100644
--- a/drivers/gpio/gpio-zynq.c
+++ b/drivers/gpio/gpio-zynq.c
@@ -422,13 +422,12 @@ static int zynq_gpio_set_irq_type(struct irq_data *irq_data, unsigned int type)
 	writel_relaxed(int_any,
 		       gpio->base_addr + ZYNQ_GPIO_INTANY_OFFSET(bank_num));
 
-	if (type & IRQ_TYPE_LEVEL_MASK) {
-		__irq_set_chip_handler_name_locked(irq_data->irq,
+	if (type & IRQ_TYPE_LEVEL_MASK)
+		__irq_set_chip_handler_name_locked(irq_data,
 			&zynq_gpio_level_irqchip, handle_fasteoi_irq, NULL);
-	} else {
-		__irq_set_chip_handler_name_locked(irq_data->irq,
+	else
+		__irq_set_chip_handler_name_locked(irq_data,
 			&zynq_gpio_edge_irqchip, handle_level_irq, NULL);
-	}
 
 	return 0;
 }
diff --git a/drivers/irqchip/irq-metag-ext.c b/drivers/irqchip/irq-metag-ext.c
index 2cb474ad8809..52e501d8c8f0 100644
--- a/drivers/irqchip/irq-metag-ext.c
+++ b/drivers/irqchip/irq-metag-ext.c
@@ -404,7 +404,6 @@ static int meta_intc_irq_set_type(struct irq_data *data, unsigned int flow_type)
 #ifdef CONFIG_METAG_SUSPEND_MEM
 	struct meta_intc_priv *priv = &meta_intc_priv;
 #endif
-	unsigned int irq = data->irq;
 	irq_hw_number_t hw = data->hwirq;
 	unsigned int bit = 1 << meta_intc_offset(hw);
 	void __iomem *level_addr = meta_intc_level_addr(hw);
@@ -413,10 +412,10 @@ static int meta_intc_irq_set_type(struct irq_data *data, unsigned int flow_type)
 
 	/* update the chip/handler */
 	if (flow_type & IRQ_TYPE_LEVEL_MASK)
-		__irq_set_chip_handler_name_locked(irq, &meta_intc_level_chip,
+		__irq_set_chip_handler_name_locked(data, &meta_intc_level_chip,
 						   handle_level_irq, NULL);
 	else
-		__irq_set_chip_handler_name_locked(irq, &meta_intc_edge_chip,
+		__irq_set_chip_handler_name_locked(data, &meta_intc_edge_chip,
 						   handle_edge_irq, NULL);
 
 	/* and clear/set the bit in HWLEVELEXT */
diff --git a/drivers/irqchip/irq-mips-gic.c b/drivers/irqchip/irq-mips-gic.c
index 09257c301bd2..fb2e64b1f414 100644
--- a/drivers/irqchip/irq-mips-gic.c
+++ b/drivers/irqchip/irq-mips-gic.c
@@ -365,15 +365,12 @@ static int gic_set_type(struct irq_data *d, unsigned int type)
 		break;
 	}
 
-	if (is_edge) {
-		__irq_set_chip_handler_name_locked(d->irq,
-						   &gic_edge_irq_controller,
+	if (is_edge)
+		__irq_set_chip_handler_name_locked(d, &gic_edge_irq_controller,
 						   handle_edge_irq, NULL);
-	} else {
-		__irq_set_chip_handler_name_locked(d->irq,
-						   &gic_level_irq_controller,
+	else
+		__irq_set_chip_handler_name_locked(d, &gic_level_irq_controller,
 						   handle_level_irq, NULL);
-	}
 	spin_unlock_irqrestore(&gic_lock, flags);
 
 	return 0;
diff --git a/include/linux/irqdesc.h b/include/linux/irqdesc.h
index 41544024f464..4dfa46b99a14 100644
--- a/include/linux/irqdesc.h
+++ b/include/linux/irqdesc.h
@@ -177,15 +177,14 @@ static inline void __irq_set_handler_locked(unsigned int irq,
 
 /* caller has locked the irq_desc and both params are valid */
 static inline void
-__irq_set_chip_handler_name_locked(unsigned int irq, struct irq_chip *chip,
+__irq_set_chip_handler_name_locked(struct irq_data *data, struct irq_chip *chip,
 				   irq_flow_handler_t handler, const char *name)
 {
-	struct irq_desc *desc;
+	struct irq_desc *desc = irq_data_to_desc(data);
 
-	desc = irq_to_desc(irq);
-	irq_desc_get_irq_data(desc)->chip = chip;
 	desc->handle_irq = handler;
 	desc->name = name;
+	data->chip = chip;
 }
 
 static inline int irq_balancing_disabled(unsigned int irq)
-- 
1.7.10.4

