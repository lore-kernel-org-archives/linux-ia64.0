From: Jeff Garzik <jeff@garzik.org>
Date: Fri, 26 Oct 2007 09:40:26 +0000
Subject: [PATCH] IA64, PPC, SPARC: minor irq handler cleanups
Message-Id: <d12d72446eb0ff40da5e709b1f658df479b92658.1193390975.git.jeff@garzik.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <9799624f63e093aa915947aea8fb1b8a5df959a1.1193390973.git.jeff@garzik.org>
In-Reply-To: <9799624f63e093aa915947aea8fb1b8a5df959a1.1193390973.git.jeff@garzik.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>
Cc: akpm@linux-foundation.org, davem@davemloft.net, tony.luck@intel.com, linux-ia64@vger.kernel.org, paulus@samba.org, benh@kernel.crashing.org, galak@kernel.crashing.org

ia64/sn/kernel/huberror.c:
	- remove pointless void* cast
	- add KERN_xxx prefix

ia64/sn/pci/tioce_provider.c: start functions at column zero

ppc/8xx_io/fec.c: kill prototype, remove extra whitespace

ppc/platforms/85xx/*
	'irq' argument in irq handler is used purely as a temporary
	variable.  Update the function to reflect this usage, changing
	the first arg's name from 'irq' to 'dummy'

ppc/platforms/sbc82xx.c: ditto

sparc/kernel/time.c: mark timer_interrupt() static (from DaveM)

Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
---
 arch/ia64/sn/kernel/huberror.c               |    4 ++--
 arch/ia64/sn/pci/tioce_provider.c            |    6 ++++--
 arch/ppc/8xx_io/fec.c                        |    3 +--
 arch/ppc/platforms/85xx/mpc8560_ads.c        |    4 +++-
 arch/ppc/platforms/85xx/mpc85xx_cds_common.c |    4 +++-
 arch/ppc/platforms/85xx/stx_gp3.c            |    4 +++-
 arch/ppc/platforms/85xx/tqm85xx.c            |    4 +++-
 arch/ppc/platforms/sbc82xx.c                 |    4 +++-
 arch/sparc/kernel/time.c                     |    2 +-
 9 files changed, 23 insertions(+), 12 deletions(-)

diff --git a/arch/ia64/sn/kernel/huberror.c b/arch/ia64/sn/kernel/huberror.c
index b663168..fc217c3 100644
--- a/arch/ia64/sn/kernel/huberror.c
+++ b/arch/ia64/sn/kernel/huberror.c
@@ -187,8 +187,8 @@ void hub_error_init(struct hubdev_info *hubdev_info)
 {
 
 	if (request_irq(SGI_II_ERROR, hub_eint_handler, IRQF_SHARED,
-			"SN_hub_error", (void *)hubdev_info)) {
-		printk("hub_error_init: Failed to request_irq for 0x%p\n",
+			"SN_hub_error", hubdev_info)) {
+		printk(KERN_ERR "hub_error_init: Failed to request_irq for 0x%p\n",
 		    hubdev_info);
 		return;
 	}
diff --git a/arch/ia64/sn/pci/tioce_provider.c b/arch/ia64/sn/pci/tioce_provider.c
index cee9379..714d6df 100644
--- a/arch/ia64/sn/pci/tioce_provider.c
+++ b/arch/ia64/sn/pci/tioce_provider.c
@@ -655,7 +655,8 @@ tioce_dma(struct pci_dev *pdev, u64 paddr, size_t byte_count, int dma_flags)
  *
  * Simply call tioce_do_dma_map() to create a map with the barrier bit set
  * in the address.
- */ static u64
+ */
+static u64
 tioce_dma_consistent(struct pci_dev *pdev, u64 paddr, size_t byte_count, int dma_flags)
 {
 	return tioce_do_dma_map(pdev, paddr, byte_count, 1, dma_flags);
@@ -668,7 +669,8 @@ tioce_dma_consistent(struct pci_dev *pdev, u64 paddr, size_t byte_count, int dma
  *
  * Handle a CE error interrupt.  Simply a wrapper around a SAL call which
  * defers processing to the SGI prom.
- */ static irqreturn_t
+ */
+static irqreturn_t
 tioce_error_intr_handler(int irq, void *arg)
 {
 	struct tioce_common *soft = arg;
diff --git a/arch/ppc/8xx_io/fec.c b/arch/ppc/8xx_io/fec.c
index 0288279..b31897d 100644
--- a/arch/ppc/8xx_io/fec.c
+++ b/arch/ppc/8xx_io/fec.c
@@ -199,7 +199,6 @@ static int fec_enet_start_xmit(struct sk_buff *skb, struct net_device *dev);
 #ifdef	CONFIG_USE_MDIO
 static void fec_enet_mii(struct net_device *dev);
 #endif	/* CONFIG_USE_MDIO */
-static irqreturn_t fec_enet_interrupt(int irq, void * dev_id);
 #ifdef CONFIG_FEC_PACKETHOOK
 static void  fec_enet_tx(struct net_device *dev, __u32 regval);
 static void  fec_enet_rx(struct net_device *dev, __u32 regval);
@@ -472,7 +471,7 @@ fec_timeout(struct net_device *dev)
  * This is called from the MPC core interrupt.
  */
 static	irqreturn_t
-fec_enet_interrupt(int irq, void * dev_id)
+fec_enet_interrupt(int irq, void *dev_id)
 {
 	struct	net_device *dev = dev_id;
 	volatile fec_t	*fecp;
diff --git a/arch/ppc/platforms/85xx/mpc8560_ads.c b/arch/ppc/platforms/85xx/mpc8560_ads.c
index 3a06046..9426293 100644
--- a/arch/ppc/platforms/85xx/mpc8560_ads.c
+++ b/arch/ppc/platforms/85xx/mpc8560_ads.c
@@ -211,8 +211,10 @@ mpc8560ads_setup_arch(void)
 #endif
 }
 
-static irqreturn_t cpm2_cascade(int irq, void *dev_id)
+static irqreturn_t cpm2_cascade(int dummy, void *dev_id)
 {
+	int irq;
+
 	while ((irq = cpm2_get_irq()) >= 0)
 		__do_IRQ(irq);
 	return IRQ_HANDLED;
diff --git a/arch/ppc/platforms/85xx/mpc85xx_cds_common.c b/arch/ppc/platforms/85xx/mpc85xx_cds_common.c
index 2d59eb7..791fef0 100644
--- a/arch/ppc/platforms/85xx/mpc85xx_cds_common.c
+++ b/arch/ppc/platforms/85xx/mpc85xx_cds_common.c
@@ -127,8 +127,10 @@ mpc85xx_cds_show_cpuinfo(struct seq_file *m)
 }
 
 #ifdef CONFIG_CPM2
-static irqreturn_t cpm2_cascade(int irq, void *dev_id)
+static irqreturn_t cpm2_cascade(int dummy, void *dev_id)
 {
+	int irq;
+
 	while((irq = cpm2_get_irq()) >= 0)
 		__do_IRQ(irq);
 	return IRQ_HANDLED;
diff --git a/arch/ppc/platforms/85xx/stx_gp3.c b/arch/ppc/platforms/85xx/stx_gp3.c
index b1f5b73..7444f85 100644
--- a/arch/ppc/platforms/85xx/stx_gp3.c
+++ b/arch/ppc/platforms/85xx/stx_gp3.c
@@ -156,8 +156,10 @@ gp3_setup_arch(void)
 	printk ("bi_immr_base = %8.8lx\n", binfo->bi_immr_base);
 }
 
-static irqreturn_t cpm2_cascade(int irq, void *dev_id)
+static irqreturn_t cpm2_cascade(int dummy, void *dev_id)
 {
+	int irq;
+
 	while ((irq = cpm2_get_irq()) >= 0)
 		__do_IRQ(irq);
 
diff --git a/arch/ppc/platforms/85xx/tqm85xx.c b/arch/ppc/platforms/85xx/tqm85xx.c
index 4ee2bd1..61e3429 100644
--- a/arch/ppc/platforms/85xx/tqm85xx.c
+++ b/arch/ppc/platforms/85xx/tqm85xx.c
@@ -181,8 +181,10 @@ tqm85xx_setup_arch(void)
 }
 
 #ifdef CONFIG_MPC8560
-static irqreturn_t cpm2_cascade(int irq, void *dev_id)
+static irqreturn_t cpm2_cascade(int dummy, void *dev_id)
 {
+	int irq;
+
 	while ((irq = cpm2_get_irq()) >= 0)
 		__do_IRQ(irq);
 	return IRQ_HANDLED;
diff --git a/arch/ppc/platforms/sbc82xx.c b/arch/ppc/platforms/sbc82xx.c
index cc0935c..0df6aac 100644
--- a/arch/ppc/platforms/sbc82xx.c
+++ b/arch/ppc/platforms/sbc82xx.c
@@ -121,8 +121,10 @@ struct hw_interrupt_type sbc82xx_i8259_ic = {
 	.end = sbc82xx_i8259_end_irq,
 };
 
-static irqreturn_t sbc82xx_i8259_demux(int irq, void *dev_id)
+static irqreturn_t sbc82xx_i8259_demux(int dummy, void *dev_id)
 {
+	int irq;
+
 	spin_lock(&sbc82xx_i8259_lock);
 
 	sbc82xx_i8259_map[0] = 0x0c;	/* OCW3: Read IR register on RD# pulse */
diff --git a/arch/sparc/kernel/time.c b/arch/sparc/kernel/time.c
index 4bf78a5..2f4e61d 100644
--- a/arch/sparc/kernel/time.c
+++ b/arch/sparc/kernel/time.c
@@ -106,7 +106,7 @@ __volatile__ unsigned int *master_l10_limit;
 
 #define TICK_SIZE (tick_nsec / 1000)
 
-irqreturn_t timer_interrupt(int irq, void *dev_id)
+static irqreturn_t timer_interrupt(int dummy, void *dev_id)
 {
 	/* last time the cmos clock got updated */
 	static long last_rtc_update;
-- 
1.5.2.4

