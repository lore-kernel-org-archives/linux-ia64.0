From: Yong Zhang <yong.zhang0@gmail.com>
Date: Thu, 22 Sep 2011 08:58:35 +0000
Subject: [PATCH 08/55] ia64: irq: Remove IRQF_DISABLED
Message-Id: <1316681962-8217-9-git-send-email-yong.zhang0@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1316681962-8217-1-git-send-email-yong.zhang0@gmail.com>
In-Reply-To: <1316681962-8217-1-git-send-email-yong.zhang0@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org
Cc: tglx@linutronix.de, yong.zhang0@gmail.com, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Kroah-Hartman <gregkh@suse.de>, Alan Cox <alan@linux.intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Jesper Nilsson <jesper.nilsson@axis.com>, Chris Metcalf <cmetcalf@tilera.com>, Jeff Mahoney <jeffm@suse.com>, Nick Piggin <npiggin@kernel.dk>, Al Viro <viro@zeniv.linux.org.uk>, Joe Perches <joe@perches.com>, Jesper Juhl <jj@chaosbits.net>, John Stultz <johnstul@us.ibm.com>, Eric Dumazet <eric.dumazet@gmail.com>, Torben Hohn <torbenh@gmx.de>, Russell King <rmk+kernel@arm.linux.org.uk>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-ia64@vger.kernel.org

Since commit [e58aa3d2: genirq: Run irq handlers with interrupts disabled],
We run all interrupt handlers with interrupts disabled
and we even check and yell when an interrupt handler
returns with interrupts enabled (see commit [b738a50a:
genirq: Warn when handler enables interrupts]).

So now this flag is a NOOP and can be removed.

Signed-off-by: Yong Zhang <yong.zhang0@gmail.com>
---
 arch/ia64/hp/sim/simserial.c |    2 +-
 arch/ia64/kernel/irq_ia64.c  |    4 ----
 arch/ia64/kernel/mca.c       |    6 ------
 arch/ia64/kernel/perfmon.c   |    1 -
 arch/ia64/kernel/time.c      |    2 +-
 arch/ia64/xen/irq_xen.c      |    3 ---
 6 files changed, 2 insertions(+), 16 deletions(-)

diff --git a/arch/ia64/hp/sim/simserial.c b/arch/ia64/hp/sim/simserial.c
index bff0824..2fa31be 100644
--- a/arch/ia64/hp/sim/simserial.c
+++ b/arch/ia64/hp/sim/simserial.c
@@ -43,7 +43,7 @@
 
 #define NR_PORTS	1	/* only one port for now */
 
-#define IRQ_T(info) ((info->flags & ASYNC_SHARE_IRQ) ? IRQF_SHARED : IRQF_DISABLED)
+#define IRQ_T(info) ((info->flags & ASYNC_SHARE_IRQ) ? IRQF_SHARED : 0)
 
 #define SSC_GETCHAR	21
 
diff --git a/arch/ia64/kernel/irq_ia64.c b/arch/ia64/kernel/irq_ia64.c
index 782c3a35..80b07ad 100644
--- a/arch/ia64/kernel/irq_ia64.c
+++ b/arch/ia64/kernel/irq_ia64.c
@@ -366,7 +366,6 @@ static irqreturn_t smp_irq_move_cleanup_interrupt(int irq, void *dev_id)
 
 static struct irqaction irq_move_irqaction = {
 	.handler =	smp_irq_move_cleanup_interrupt,
-	.flags =	IRQF_DISABLED,
 	.name =		"irq_move"
 };
 
@@ -604,7 +603,6 @@ static irqreturn_t dummy_handler (int irq, void *dev_id)
 
 static struct irqaction ipi_irqaction = {
 	.handler =	handle_IPI,
-	.flags =	IRQF_DISABLED,
 	.name =		"IPI"
 };
 
@@ -613,13 +611,11 @@ static struct irqaction ipi_irqaction = {
  */
 static struct irqaction resched_irqaction = {
 	.handler =	dummy_handler,
-	.flags =	IRQF_DISABLED,
 	.name =		"resched"
 };
 
 static struct irqaction tlb_irqaction = {
 	.handler =	dummy_handler,
-	.flags =	IRQF_DISABLED,
 	.name =		"tlb_flush"
 };
 
diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index 84fb405..3df4fe0 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -1769,38 +1769,32 @@ __setup("disable_cpe_poll", ia64_mca_disable_cpe_polling);
 
 static struct irqaction cmci_irqaction = {
 	.handler =	ia64_mca_cmc_int_handler,
-	.flags =	IRQF_DISABLED,
 	.name =		"cmc_hndlr"
 };
 
 static struct irqaction cmcp_irqaction = {
 	.handler =	ia64_mca_cmc_int_caller,
-	.flags =	IRQF_DISABLED,
 	.name =		"cmc_poll"
 };
 
 static struct irqaction mca_rdzv_irqaction = {
 	.handler =	ia64_mca_rendez_int_handler,
-	.flags =	IRQF_DISABLED,
 	.name =		"mca_rdzv"
 };
 
 static struct irqaction mca_wkup_irqaction = {
 	.handler =	ia64_mca_wakeup_int_handler,
-	.flags =	IRQF_DISABLED,
 	.name =		"mca_wkup"
 };
 
 #ifdef CONFIG_ACPI
 static struct irqaction mca_cpe_irqaction = {
 	.handler =	ia64_mca_cpe_int_handler,
-	.flags =	IRQF_DISABLED,
 	.name =		"cpe_hndlr"
 };
 
 static struct irqaction mca_cpep_irqaction = {
 	.handler =	ia64_mca_cpe_int_caller,
-	.flags =	IRQF_DISABLED,
 	.name =		"cpe_poll"
 };
 #endif /* CONFIG_ACPI */
diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index 89accc6..e807a57 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -6432,7 +6432,6 @@ pfm_flush_pmds(struct task_struct *task, pfm_context_t *ctx)
 
 static struct irqaction perfmon_irqaction = {
 	.handler = pfm_interrupt_handler,
-	.flags   = IRQF_DISABLED,
 	.name    = "perfmon"
 };
 
diff --git a/arch/ia64/kernel/time.c b/arch/ia64/kernel/time.c
index 43920de..ef64514 100644
--- a/arch/ia64/kernel/time.c
+++ b/arch/ia64/kernel/time.c
@@ -397,7 +397,7 @@ static cycle_t itc_get_cycles(struct clocksource *cs)
 
 static struct irqaction timer_irqaction = {
 	.handler =	timer_interrupt,
-	.flags =	IRQF_DISABLED | IRQF_IRQPOLL,
+	.flags =	IRQF_IRQPOLL,
 	.name =		"timer"
 };
 
diff --git a/arch/ia64/xen/irq_xen.c b/arch/ia64/xen/irq_xen.c
index b279e14..d794270 100644
--- a/arch/ia64/xen/irq_xen.c
+++ b/arch/ia64/xen/irq_xen.c
@@ -113,19 +113,16 @@ xen_resched_handler(int irq, void *dev_id)
 
 static struct irqaction xen_ipi_irqaction = {
 	.handler =	handle_IPI,
-	.flags =	IRQF_DISABLED,
 	.name =		"IPI"
 };
 
 static struct irqaction xen_resched_irqaction = {
 	.handler =	xen_resched_handler,
-	.flags =	IRQF_DISABLED,
 	.name =		"resched"
 };
 
 static struct irqaction xen_tlb_irqaction = {
 	.handler =	xen_dummy_handler,
-	.flags =	IRQF_DISABLED,
 	.name =		"tlb_flush"
 };
 #endif
-- 
1.7.4.1

