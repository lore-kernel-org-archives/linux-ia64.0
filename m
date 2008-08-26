From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Tue, 26 Aug 2008 05:58:39 +0000
Subject: [PATCH 27/30] ia64/xen: preliminary support for save/restore.
Message-Id: <1219730322-11687-28-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

preliminary support for save/restore.
Although Save/restore isn't fully working yet, this patch is necessary
to compile.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/xen/Makefile              |    2 +-
 arch/ia64/xen/{time.h => suspend.c} |   45 +++++++++++++++++++++++++++++++++-
 arch/ia64/xen/time.c                |   33 +++++++++++++++++++++++++
 arch/ia64/xen/time.h                |    1 +
 4 files changed, 78 insertions(+), 3 deletions(-)
 copy arch/ia64/xen/{time.h => suspend.c} (64%)

diff --git a/arch/ia64/xen/Makefile b/arch/ia64/xen/Makefile
index 972d085..0ad0224 100644
--- a/arch/ia64/xen/Makefile
+++ b/arch/ia64/xen/Makefile
@@ -3,7 +3,7 @@
 #
 
 obj-y := hypercall.o xenivt.o xensetup.o xen_pv_ops.o irq_xen.o \
-	 hypervisor.o xencomm.o xcom_hcall.o grant-table.o time.o
+	 hypervisor.o xencomm.o xcom_hcall.o grant-table.o time.o suspend.o
 
 obj-$(CONFIG_IA64_GENERIC) += machvec.o
 
diff --git a/arch/ia64/xen/time.h b/arch/ia64/xen/suspend.c
similarity index 64%
copy from arch/ia64/xen/time.h
copy to arch/ia64/xen/suspend.c
index b9c7ec5..fd66b04 100644
--- a/arch/ia64/xen/time.h
+++ b/arch/ia64/xen/suspend.c
@@ -1,5 +1,5 @@
 /******************************************************************************
- * arch/ia64/xen/time.h
+ * arch/ia64/xen/suspend.c
  *
  * Copyright (c) 2008 Isaku Yamahata <yamahata at valinux co jp>
  *                    VA Linux Systems Japan K.K.
@@ -18,6 +18,47 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  *
+ * suspend/resume
  */
 
-extern struct pv_time_ops xen_time_ops __initdata;
+#include <xen/xen-ops.h>
+#include <asm/xen/hypervisor.h>
+#include "time.h"
+
+void
+xen_mm_pin_all(void)
+{
+	/* nothing */
+}
+
+void
+xen_mm_unpin_all(void)
+{
+	/* nothing */
+}
+
+void xen_pre_device_suspend(void)
+{
+	/* nothing */
+}
+
+void
+xen_pre_suspend()
+{
+	/* nothing */
+}
+
+void
+xen_post_suspend(int suspend_cancelled)
+{
+	if (suspend_cancelled)
+		return;
+
+	xen_ia64_enable_opt_feature();
+	/* add more if necessary */
+}
+
+void xen_arch_resume(void)
+{
+	xen_timer_resume_on_aps();
+}
diff --git a/arch/ia64/xen/time.c b/arch/ia64/xen/time.c
index 3414f1e..5785469 100644
--- a/arch/ia64/xen/time.c
+++ b/arch/ia64/xen/time.c
@@ -26,6 +26,8 @@
 #include <linux/irq.h>
 #include <linux/clocksource.h>
 
+#include <asm/timex.h>
+
 #include <asm/xen/hypervisor.h>
 
 #include <xen/interface/vcpu.h>
@@ -163,3 +165,34 @@ struct pv_time_ops xen_time_ops __initdata = {
 	.do_steal_accounting		= xen_do_steal_accounting,
 	.clocksource_resume		= xen_itc_jitter_data_reset,
 };
+
+/* Called after suspend, to resume time.  */
+static void xen_local_tick_resume(void)
+{
+	/* Just trigger a tick.  */
+	ia64_cpu_local_tick();
+	touch_softlockup_watchdog();
+}
+
+void
+xen_timer_resume(void)
+{
+	unsigned int cpu;
+
+	xen_local_tick_resume();
+
+	for_each_online_cpu(cpu)
+		xen_init_missing_ticks_accounting(cpu);
+}
+
+static void ia64_cpu_local_tick_fn(void *unused)
+{
+	xen_local_tick_resume();
+	xen_init_missing_ticks_accounting(smp_processor_id());
+}
+
+void
+xen_timer_resume_on_aps(void)
+{
+	smp_call_function(&ia64_cpu_local_tick_fn, NULL, 1);
+}
diff --git a/arch/ia64/xen/time.h b/arch/ia64/xen/time.h
index b9c7ec5..f98d7e1 100644
--- a/arch/ia64/xen/time.h
+++ b/arch/ia64/xen/time.h
@@ -21,3 +21,4 @@
  */
 
 extern struct pv_time_ops xen_time_ops __initdata;
+void xen_timer_resume_on_aps(void);
-- 
1.6.0.rc0.42.g186458

