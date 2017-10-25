From: Kees Cook <keescook@chromium.org>
Date: Wed, 25 Oct 2017 10:25:43 +0000
Subject: [PATCH] ia64: Convert timers to use timer_setup()
Message-Id: <20171025102543.GA145788@beast>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>, Ingo Molnar <mingo@kernel.org>, Joe Perches <joe@perches.com>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

One less trivial change was removing the repeated casting for callers
of bte_error_handler() by fixing its function declaration and adding a
small wrapper for the timer callback instead.

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Joe Perches <joe@perches.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: linux-ia64@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 arch/ia64/include/asm/sn/bte.h  |  4 +++-
 arch/ia64/kernel/mca.c          |  8 ++++----
 arch/ia64/kernel/salinfo.c      |  5 ++---
 arch/ia64/sn/kernel/bte.c       | 12 ++++++++----
 arch/ia64/sn/kernel/bte_error.c | 17 ++++++-----------
 arch/ia64/sn/kernel/huberror.c  |  2 +-
 arch/ia64/sn/kernel/mca.c       |  5 ++---
 7 files changed, 26 insertions(+), 27 deletions(-)

diff --git a/arch/ia64/include/asm/sn/bte.h b/arch/ia64/include/asm/sn/bte.h
index cc6c4dbf53af..cd71ab5faf62 100644
--- a/arch/ia64/include/asm/sn/bte.h
+++ b/arch/ia64/include/asm/sn/bte.h
@@ -17,6 +17,8 @@
 #include <asm/sn/types.h>
 #include <asm/sn/shub_mmr.h>
 
+struct nodepda_s;
+
 #define IBCT_NOTIFY             (0x1UL << 4)
 #define IBCT_ZFIL_MODE          (0x1UL << 0)
 
@@ -210,7 +212,7 @@ struct bteinfo_s {
  */
 extern bte_result_t bte_copy(u64, u64, u64, u64, void *);
 extern bte_result_t bte_unaligned_copy(u64, u64, u64, u64);
-extern void bte_error_handler(unsigned long);
+extern void bte_error_handler(struct nodepda_s *);
 
 #define bte_zero(dest, len, mode, notification) \
 	bte_copy(0, dest, len, ((mode) | BTE_ZERO_FILL), notification)
diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index 555b11180156..6115464d5f03 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -1513,7 +1513,7 @@ ia64_mca_cmc_int_caller(int cmc_irq, void *arg)
  *
  */
 static void
-ia64_mca_cmc_poll (unsigned long dummy)
+ia64_mca_cmc_poll (struct timer_list *unused)
 {
 	/* Trigger a CMC interrupt cascade  */
 	platform_send_ipi(cpumask_first(cpu_online_mask), IA64_CMCP_VECTOR,
@@ -1590,7 +1590,7 @@ ia64_mca_cpe_int_caller(int cpe_irq, void *arg)
  *
  */
 static void
-ia64_mca_cpe_poll (unsigned long dummy)
+ia64_mca_cpe_poll (struct timer_list *unused)
 {
 	/* Trigger a CPE interrupt cascade  */
 	platform_send_ipi(cpumask_first(cpu_online_mask), IA64_CPEP_VECTOR,
@@ -2098,7 +2098,7 @@ ia64_mca_late_init(void)
 		return 0;
 
 	/* Setup the CMCI/P vector and handler */
-	setup_timer(&cmc_poll_timer, ia64_mca_cmc_poll, 0UL);
+	timer_setup(&cmc_poll_timer, ia64_mca_cmc_poll, 0);
 
 	/* Unmask/enable the vector */
 	cmc_polling_enabled = 0;
@@ -2109,7 +2109,7 @@ ia64_mca_late_init(void)
 #ifdef CONFIG_ACPI
 	/* Setup the CPEI/P vector and handler */
 	cpe_vector = acpi_request_vector(ACPI_INTERRUPT_CPEI);
-	setup_timer(&cpe_poll_timer, ia64_mca_cpe_poll, 0UL);
+	timer_setup(&cpe_poll_timer, ia64_mca_cpe_poll, 0);
 
 	{
 		unsigned int irq;
diff --git a/arch/ia64/kernel/salinfo.c b/arch/ia64/kernel/salinfo.c
index 63dc9cdc95c5..52c404b08904 100644
--- a/arch/ia64/kernel/salinfo.c
+++ b/arch/ia64/kernel/salinfo.c
@@ -263,7 +263,7 @@ salinfo_timeout_check(struct salinfo_data *data)
 }
 
 static void
-salinfo_timeout (unsigned long arg)
+salinfo_timeout(struct timer_list *unused)
 {
 	ia64_mlogbuf_dump();
 	salinfo_timeout_check(salinfo_data + SAL_INFO_TYPE_MCA);
@@ -623,9 +623,8 @@ salinfo_init(void)
 
 	*sdir++ = salinfo_dir;
 
-	init_timer(&salinfo_timer);
+	timer_setup(&salinfo_timer, salinfo_timeout, 0);
 	salinfo_timer.expires = jiffies + SALINFO_TIMER_DELAY;
-	salinfo_timer.function = &salinfo_timeout;
 	add_timer(&salinfo_timer);
 
 	i = cpuhp_setup_state(CPUHP_AP_ONLINE_DYN, "ia64/salinfo:online",
diff --git a/arch/ia64/sn/kernel/bte.c b/arch/ia64/sn/kernel/bte.c
index b2eb48490754..9146192b86f5 100644
--- a/arch/ia64/sn/kernel/bte.c
+++ b/arch/ia64/sn/kernel/bte.c
@@ -219,7 +219,7 @@ bte_result_t bte_copy(u64 src, u64 dest, u64 len, u64 mode, void *notification)
 				BTE_LNSTAT_LOAD(bte), *bte->most_rcnt_na) );
 			bte->bte_error_count++;
 			bte->bh_error = IBLS_ERROR;
-			bte_error_handler((unsigned long)NODEPDA(bte->bte_cnode));
+			bte_error_handler(NODEPDA(bte->bte_cnode));
 			*bte->most_rcnt_na = BTE_WORD_AVAILABLE;
 			goto retry_bteop;
 		}
@@ -414,6 +414,12 @@ EXPORT_SYMBOL(bte_unaligned_copy);
  * Block Transfer Engine initialization functions.
  *
  ***********************************************************************/
+static void bte_recovery_timeout(struct timer_list *t)
+{
+	struct nodepda_s *nodepda = from_timer(nodepda, t, bte_recovery_timer);
+
+	bte_error_handler(nodepda);
+}
 
 /*
  * bte_init_node(nodepda, cnode)
@@ -436,9 +442,7 @@ void bte_init_node(nodepda_t * mynodepda, cnodeid_t cnode)
 	 * will point at this one bte_recover structure to get the lock.
 	 */
 	spin_lock_init(&mynodepda->bte_recovery_lock);
-	init_timer(&mynodepda->bte_recovery_timer);
-	mynodepda->bte_recovery_timer.function = bte_error_handler;
-	mynodepda->bte_recovery_timer.data = (unsigned long)mynodepda;
+	timer_setup(&mynodepda->bte_recovery_timer, bte_recovery_timeout, 0);
 
 	for (i = 0; i < BTES_PER_NODE; i++) {
 		u64 *base_addr;
diff --git a/arch/ia64/sn/kernel/bte_error.c b/arch/ia64/sn/kernel/bte_error.c
index 4cb09f3f1efc..d92786c09b34 100644
--- a/arch/ia64/sn/kernel/bte_error.c
+++ b/arch/ia64/sn/kernel/bte_error.c
@@ -27,15 +27,12 @@
  * transfers to be queued.
  */
 
-void bte_error_handler(unsigned long);
-
 /*
  * Wait until all BTE related CRBs are completed
  * and then reset the interfaces.
  */
-int shub1_bte_error_handler(unsigned long _nodepda)
+static int shub1_bte_error_handler(struct nodepda_s *err_nodepda)
 {
-	struct nodepda_s *err_nodepda = (struct nodepda_s *)_nodepda;
 	struct timer_list *recovery_timer = &err_nodepda->bte_recovery_timer;
 	nasid_t nasid;
 	int i;
@@ -131,9 +128,8 @@ int shub1_bte_error_handler(unsigned long _nodepda)
  * Wait until all BTE related CRBs are completed
  * and then reset the interfaces.
  */
-int shub2_bte_error_handler(unsigned long _nodepda)
+static int shub2_bte_error_handler(struct nodepda_s *err_nodepda)
 {
-	struct nodepda_s *err_nodepda = (struct nodepda_s *)_nodepda;
 	struct timer_list *recovery_timer = &err_nodepda->bte_recovery_timer;
 	struct bteinfo_s *bte;
 	nasid_t nasid;
@@ -170,9 +166,8 @@ int shub2_bte_error_handler(unsigned long _nodepda)
  * Wait until all BTE related CRBs are completed
  * and then reset the interfaces.
  */
-void bte_error_handler(unsigned long _nodepda)
+void bte_error_handler(struct nodepda_s *err_nodepda)
 {
-	struct nodepda_s *err_nodepda = (struct nodepda_s *)_nodepda;
 	spinlock_t *recovery_lock = &err_nodepda->bte_recovery_lock;
 	int i;
 	unsigned long irq_flags;
@@ -199,12 +194,12 @@ void bte_error_handler(unsigned long _nodepda)
 	}
 
 	if (is_shub1()) {
-		if (shub1_bte_error_handler(_nodepda)) {
+		if (shub1_bte_error_handler(err_nodepda)) {
 			spin_unlock_irqrestore(recovery_lock, irq_flags);
 			return;
 		}
 	} else {
-		if (shub2_bte_error_handler(_nodepda)) {
+		if (shub2_bte_error_handler(err_nodepda)) {
 			spin_unlock_irqrestore(recovery_lock, irq_flags);
 			return;
 		}
@@ -255,6 +250,6 @@ bte_crb_error_handler(cnodeid_t cnode, int btenum,
 
 	BTE_PRINTK(("Got an error on cnode %d bte %d: HW error type 0x%x\n",
 		bte->bte_cnode, bte->bte_num, ioe->ie_errortype));
-	bte_error_handler((unsigned long) NODEPDA(cnode));
+	bte_error_handler(NODEPDA(cnode));
 }
 
diff --git a/arch/ia64/sn/kernel/huberror.c b/arch/ia64/sn/kernel/huberror.c
index f925dec2da92..97fa56dddf50 100644
--- a/arch/ia64/sn/kernel/huberror.c
+++ b/arch/ia64/sn/kernel/huberror.c
@@ -50,7 +50,7 @@ static irqreturn_t hub_eint_handler(int irq, void *arg)
 			if ((int)ret_stuff.v0)
 				panic("%s: Fatal TIO Error", __func__);
 		} else
-			bte_error_handler((unsigned long)NODEPDA(nasid_to_cnodeid(nasid)));
+			bte_error_handler(NODEPDA(nasid_to_cnodeid(nasid)));
 
 	return IRQ_HANDLED;
 }
diff --git a/arch/ia64/sn/kernel/mca.c b/arch/ia64/sn/kernel/mca.c
index 5b799d4deb74..bc3bd930c74c 100644
--- a/arch/ia64/sn/kernel/mca.c
+++ b/arch/ia64/sn/kernel/mca.c
@@ -72,7 +72,7 @@ static void sn_cpei_handler(int irq, void *devid, struct pt_regs *regs)
 	ia64_sn_plat_cpei_handler();
 }
 
-static void sn_cpei_timer_handler(unsigned long dummy)
+static void sn_cpei_timer_handler(struct timer_list *unused)
 {
 	sn_cpei_handler(-1, NULL, NULL);
 	mod_timer(&sn_cpei_timer, jiffies + CPEI_INTERVAL);
@@ -80,9 +80,8 @@ static void sn_cpei_timer_handler(unsigned long dummy)
 
 void sn_init_cpei_timer(void)
 {
-	init_timer(&sn_cpei_timer);
+	timer_setup(&sn_cpei_timer, sn_cpei_timer_handler, 0);
 	sn_cpei_timer.expires = jiffies + CPEI_INTERVAL;
-	sn_cpei_timer.function = sn_cpei_timer_handler;
 	add_timer(&sn_cpei_timer);
 }
 
-- 
2.7.4


-- 
Kees Cook
Pixel Security
