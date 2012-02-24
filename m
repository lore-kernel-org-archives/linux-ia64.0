From: Jiri Slaby <jslaby@suse.cz>
Date: Fri, 24 Feb 2012 11:10:17 +0000
Subject: [PATCH 3/4] IA64: hpsim, initialize chip for assigned irqs
Message-Id: <1330081818-15517-3-git-send-email-jslaby@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1330081818-15517-1-git-send-email-jslaby@suse.cz>
In-Reply-To: <1330081818-15517-1-git-send-email-jslaby@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: fenghua.yu@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, jirislaby@gmail.com

Currently, when assign_irq_vector is called and the irq connected in
the simulator, the irq is not ready. request_irq will return ENOSYS
immediately. It is because the irq chip is unset.

Hence set the chip properly to irq_type_hp_sim. And make sure this is
done from both users of simulated interrupts.

Also we have to set handler here, otherwise we end up in
handle_bad_int resulting in spam in logs and no irqs handled. We use
handle_simple_irq as these are SW interrupts that need no ACK or
anything.

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
---
 arch/ia64/hp/sim/hpsim_irq.c   |   36 ++++++++++++++++++++++++++++++------
 arch/ia64/hp/sim/hpsim_setup.c |    6 ------
 arch/ia64/hp/sim/simeth.c      |   19 +++----------------
 arch/ia64/hp/sim/simserial.c   |    3 +--
 arch/ia64/include/asm/hpsim.h  |    2 +-
 5 files changed, 35 insertions(+), 31 deletions(-)

diff --git a/arch/ia64/hp/sim/hpsim_irq.c b/arch/ia64/hp/sim/hpsim_irq.c
index 4bd9a63..0aa70eb 100644
--- a/arch/ia64/hp/sim/hpsim_irq.c
+++ b/arch/ia64/hp/sim/hpsim_irq.c
@@ -10,6 +10,8 @@
 #include <linux/sched.h>
 #include <linux/irq.h>
 
+#include "hpsim_ssc.h"
+
 static unsigned int
 hpsim_irq_startup(struct irq_data *data)
 {
@@ -37,15 +39,37 @@ static struct irq_chip irq_type_hp_sim = {
 	.irq_set_affinity =	hpsim_set_affinity_noop,
 };
 
+static void hpsim_irq_set_chip(int irq)
+{
+	struct irq_chip *chip = irq_get_chip(irq);
+
+	if (chip = &no_irq_chip)
+		irq_set_chip(irq, &irq_type_hp_sim);
+}
+
+static void hpsim_connect_irq(int intr, int irq)
+{
+	ia64_ssc(intr, irq, 0, 0, SSC_CONNECT_INTERRUPT);
+}
+
+int hpsim_get_irq(int intr)
+{
+	int irq = assign_irq_vector(AUTO_ASSIGN);
+
+	if (irq >= 0) {
+		hpsim_irq_set_chip(irq);
+		irq_set_handler(irq, handle_simple_irq);
+		hpsim_connect_irq(intr, irq);
+	}
+
+	return irq;
+}
+
 void __init
 hpsim_irq_init (void)
 {
 	int i;
 
-	for_each_active_irq(i) {
-		struct irq_chip *chip = irq_get_chip(i);
-
-		if (chip = &no_irq_chip)
-			irq_set_chip(i, &irq_type_hp_sim);
-	}
+	for_each_active_irq(i)
+		hpsim_irq_set_chip(i);
 }
diff --git a/arch/ia64/hp/sim/hpsim_setup.c b/arch/ia64/hp/sim/hpsim_setup.c
index f629e90..664a540 100644
--- a/arch/ia64/hp/sim/hpsim_setup.c
+++ b/arch/ia64/hp/sim/hpsim_setup.c
@@ -26,12 +26,6 @@
 #include "hpsim_ssc.h"
 
 void
-ia64_ssc_connect_irq (long intr, long irq)
-{
-	ia64_ssc(intr, irq, 0, 0, SSC_CONNECT_INTERRUPT);
-}
-
-void
 ia64_ctl_trace (long on)
 {
 	ia64_ssc(on, 0, 0, 0, SSC_CTL_TRACE);
diff --git a/arch/ia64/hp/sim/simeth.c b/arch/ia64/hp/sim/simeth.c
index 47afcc6..e343357 100644
--- a/arch/ia64/hp/sim/simeth.c
+++ b/arch/ia64/hp/sim/simeth.c
@@ -129,17 +129,6 @@ netdev_probe(char *name, unsigned char *ether)
 
 
 static inline int
-netdev_connect(int irq)
-{
-	/* XXX Fix me
-	 * this does not support multiple cards
-	 * also no return value
-	 */
-	ia64_ssc_connect_irq(NETWORK_INTR, irq);
-	return 0;
-}
-
-static inline int
 netdev_attach(int fd, int irq, unsigned int ipaddr)
 {
 	/* this puts the host interface in the right mode (start interrupting) */
@@ -226,15 +215,13 @@ simeth_probe1(void)
 		return err;
 	}
 
-	if ((rc = assign_irq_vector(AUTO_ASSIGN)) < 0)
-		panic("%s: out of interrupt vectors!\n", __func__);
-	dev->irq = rc;
-
 	/*
 	 * attach the interrupt in the simulator, this does enable interrupts
 	 * until a netdev_attach() is called
 	 */
-	netdev_connect(dev->irq);
+	if ((rc = hpsim_get_irq(NETWORK_INTR)) < 0)
+		panic("%s: out of interrupt vectors!\n", __func__);
+	dev->irq = rc;
 
 	printk(KERN_INFO "%s: hosteth=%s simfd=%d, HwAddr",
 	       dev->name, simeth_device, local->simfd);
diff --git a/arch/ia64/hp/sim/simserial.c b/arch/ia64/hp/sim/simserial.c
index 974cac8..797e89a 100644
--- a/arch/ia64/hp/sim/simserial.c
+++ b/arch/ia64/hp/sim/simserial.c
@@ -947,11 +947,10 @@ simrs_init (void)
 		if (state->type = PORT_UNKNOWN) continue;
 
 		if (!state->irq) {
-			if ((rc = assign_irq_vector(AUTO_ASSIGN)) < 0)
+			if ((rc = hpsim_get_irq(KEYBOARD_INTR)) < 0)
 				panic("%s: out of interrupt vectors!\n",
 				      __func__);
 			state->irq = rc;
-			ia64_ssc_connect_irq(KEYBOARD_INTR, state->irq);
 		}
 
 		printk(KERN_INFO "ttyS%d at 0x%04lx (irq = %d) is a %s\n",
diff --git a/arch/ia64/include/asm/hpsim.h b/arch/ia64/include/asm/hpsim.h
index 892ab19..0fe5022 100644
--- a/arch/ia64/include/asm/hpsim.h
+++ b/arch/ia64/include/asm/hpsim.h
@@ -10,7 +10,7 @@ int simcons_register(void);
 struct tty_driver;
 extern struct tty_driver *hp_simserial_driver;
 
-void ia64_ssc_connect_irq(long intr, long irq);
+extern int hpsim_get_irq(int intr);
 void ia64_ctl_trace(long on);
 
 #endif
-- 
1.7.9


