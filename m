From: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Date: Sat, 07 Dec 2013 06:21:16 +0000
Subject: [PATCH][RESEND] ia64: remove deprecated IRQF_DISABLED
Message-Id: <1386397276-12288-1-git-send-email-michael.opdenacker@free-electrons.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1378534208-6275-1-git-send-email-michael.opdenacker@free-electrons.com>
In-Reply-To: <1378534208-6275-1-git-send-email-michael.opdenacker@free-electrons.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com, fenghua.yu@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Michael Opdenacker <michael.opdenacker@free-electrons.com>

This patch proposes to remove the IRQF_DISABLED flag from ia64 architecture
code. It's a NOOP since 2.6.35 and it will be removed one day.

Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>
---
 arch/ia64/kernel/irq_ia64.c | 4 ----
 arch/ia64/kernel/mca.c      | 6 ------
 arch/ia64/kernel/perfmon.c  | 1 -
 arch/ia64/kernel/time.c     | 2 +-
 arch/ia64/xen/irq_xen.c     | 3 ---
 5 files changed, 1 insertion(+), 15 deletions(-)

diff --git a/arch/ia64/kernel/irq_ia64.c b/arch/ia64/kernel/irq_ia64.c
index 1034884b77da..b5a7dba56366 100644
--- a/arch/ia64/kernel/irq_ia64.c
+++ b/arch/ia64/kernel/irq_ia64.c
@@ -364,7 +364,6 @@ static irqreturn_t smp_irq_move_cleanup_interrupt(int irq, void *dev_id)
 
 static struct irqaction irq_move_irqaction = {
 	.handler =	smp_irq_move_cleanup_interrupt,
-	.flags =	IRQF_DISABLED,
 	.name =		"irq_move"
 };
 
@@ -602,7 +601,6 @@ static irqreturn_t dummy_handler (int irq, void *dev_id)
 
 static struct irqaction ipi_irqaction = {
 	.handler =	handle_IPI,
-	.flags =	IRQF_DISABLED,
 	.name =		"IPI"
 };
 
@@ -611,13 +609,11 @@ static struct irqaction ipi_irqaction = {
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
index b8edfa75a83f..33f1462b3379 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -1772,38 +1772,32 @@ __setup("disable_cpe_poll", ia64_mca_disable_cpe_polling);
 
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
index cb592773c78b..d841c4bd6864 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -6387,7 +6387,6 @@ pfm_flush_pmds(struct task_struct *task, pfm_context_t *ctx)
 
 static struct irqaction perfmon_irqaction = {
 	.handler = pfm_interrupt_handler,
-	.flags   = IRQF_DISABLED,
 	.name    = "perfmon"
 };
 
diff --git a/arch/ia64/kernel/time.c b/arch/ia64/kernel/time.c
index fbaac1afb844..71c52bc7c28d 100644
--- a/arch/ia64/kernel/time.c
+++ b/arch/ia64/kernel/time.c
@@ -380,7 +380,7 @@ static cycle_t itc_get_cycles(struct clocksource *cs)
 
 static struct irqaction timer_irqaction = {
 	.handler =	timer_interrupt,
-	.flags =	IRQF_DISABLED | IRQF_IRQPOLL,
+	.flags =	IRQF_IRQPOLL,
 	.name =		"timer"
 };
 
diff --git a/arch/ia64/xen/irq_xen.c b/arch/ia64/xen/irq_xen.c
index efb74dafec4d..fcf940751b09 100644
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
1.8.3.2

