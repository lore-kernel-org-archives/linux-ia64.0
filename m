From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Tue, 06 Sep 2016 17:04:40 +0000
Subject: [PATCH 04/21] ia64: mca: Convert to hotplug state machine
Message-Id: <20160906170457.32393-5-bigeasy@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160906170457.32393-1-bigeasy@linutronix.de>
In-Reply-To: <20160906170457.32393-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, rt@linutronix.de, tglx@linutronix.de, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

Install the callbacks via the state machine and let the core invoke
the callbacks on the already online CPUs.

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 arch/ia64/kernel/mca.c | 26 ++++----------------------
 1 file changed, 4 insertions(+), 22 deletions(-)

diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index eb9220cde76c..c2858865b146 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -1890,7 +1890,7 @@ ia64_mca_cpu_init(void *cpu_data)
 							      PAGE_KERNEL)));
 }
 
-static void ia64_mca_cmc_vector_adjust(void *dummy)
+static int ia64_mca_cpu_online(unsigned int cpu)
 {
 	unsigned long flags;
 
@@ -1898,25 +1898,9 @@ static void ia64_mca_cmc_vector_adjust(void *dummy)
 	if (!cmc_polling_enabled)
 		ia64_mca_cmc_vector_enable(NULL);
 	local_irq_restore(flags);
+	return 0;
 }
 
-static int mca_cpu_callback(struct notifier_block *nfb,
-				      unsigned long action,
-				      void *hcpu)
-{
-	switch (action) {
-	case CPU_ONLINE:
-	case CPU_ONLINE_FROZEN:
-		ia64_mca_cmc_vector_adjust(NULL);
-		break;
-	}
-	return NOTIFY_OK;
-}
-
-static struct notifier_block mca_cpu_notifier = {
-	.notifier_call = mca_cpu_callback
-};
-
 /*
  * ia64_mca_init
  *
@@ -2111,15 +2095,13 @@ ia64_mca_late_init(void)
 	if (!mca_init)
 		return 0;
 
-	register_hotcpu_notifier(&mca_cpu_notifier);
-
 	/* Setup the CMCI/P vector and handler */
 	setup_timer(&cmc_poll_timer, ia64_mca_cmc_poll, 0UL);
 
 	/* Unmask/enable the vector */
 	cmc_polling_enabled = 0;
-	schedule_work(&cmc_enable_work);
-
+	cpuhp_setup_state(CPUHP_AP_ONLINE_DYN, "ia64/mca:online",
+			  ia64_mca_cpu_online, NULL);
 	IA64_MCA_DEBUG("%s: CMCI/P setup and enabled.\n", __func__);
 
 #ifdef CONFIG_ACPI
-- 
2.9.3

