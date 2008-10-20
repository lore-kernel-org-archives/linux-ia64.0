From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Mon, 20 Oct 2008 03:55:09 +0000
Subject: [PATCH 07/13] ia64/pv_ops/pv_time_ops: add sched_clock hook.
Message-Id: <1224474915-17171-8-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1224474915-17171-1-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <1224474915-17171-1-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com, linux-ia64@vger.kernel.org
Cc: yamahata@valinux.co.jp, xen-ia64-devel@lists.xensource.com, mingo@elte.hu, virtualization@lists.linux-foundation.org

add sched_clock() hook to paravirtualize sched_clock().
ia64 sched_clock() is based on ar.itc which isn't stable
on virtualized environment because vcpu may move around on
pcpus. So it needs paravirtualization.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/include/asm/paravirt.h |    7 +++++++
 arch/ia64/include/asm/timex.h    |    1 +
 arch/ia64/kernel/head.S          |    4 ++--
 arch/ia64/kernel/paravirt.c      |    1 +
 arch/ia64/kernel/time.c          |   12 ++++++++++++
 5 files changed, 23 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/include/asm/paravirt.h b/arch/ia64/include/asm/paravirt.h
index 56f69f9..a73e77a 100644
--- a/arch/ia64/include/asm/paravirt.h
+++ b/arch/ia64/include/asm/paravirt.h
@@ -225,6 +225,8 @@ struct pv_time_ops {
 	int (*do_steal_accounting)(unsigned long *new_itm);
 
 	void (*clocksource_resume)(void);
+
+	unsigned long long (*sched_clock)(void);
 };
 
 extern struct pv_time_ops pv_time_ops;
@@ -242,6 +244,11 @@ paravirt_do_steal_accounting(unsigned long *new_itm)
 	return pv_time_ops.do_steal_accounting(new_itm);
 }
 
+static inline unsigned long long paravirt_sched_clock(void)
+{
+	return pv_time_ops.sched_clock();
+}
+
 #endif /* !__ASSEMBLY__ */
 
 #else
diff --git a/arch/ia64/include/asm/timex.h b/arch/ia64/include/asm/timex.h
index 4e03cfe..86c7db8 100644
--- a/arch/ia64/include/asm/timex.h
+++ b/arch/ia64/include/asm/timex.h
@@ -40,5 +40,6 @@ get_cycles (void)
 }
 
 extern void ia64_cpu_local_tick (void);
+extern unsigned long long ia64_native_sched_clock (void);
 
 #endif /* _ASM_IA64_TIMEX_H */
diff --git a/arch/ia64/kernel/head.S b/arch/ia64/kernel/head.S
index 66e491d..ca1336a 100644
--- a/arch/ia64/kernel/head.S
+++ b/arch/ia64/kernel/head.S
@@ -1050,7 +1050,7 @@ END(ia64_delay_loop)
  * except that the multiplication and the shift are done with 128-bit
  * intermediate precision so that we can produce a full 64-bit result.
  */
-GLOBAL_ENTRY(sched_clock)
+GLOBAL_ENTRY(ia64_native_sched_clock)
 	addl r8=THIS_CPU(cpu_info) + IA64_CPUINFO_NSEC_PER_CYC_OFFSET,r0
 	mov.m r9=ar.itc		// fetch cycle-counter				(35 cyc)
 	;;
@@ -1066,7 +1066,7 @@ GLOBAL_ENTRY(sched_clock)
 	;;
 	shrp r8=r9,r8,IA64_NSEC_PER_CYC_SHIFT
 	br.ret.sptk.many rp
-END(sched_clock)
+END(ia64_native_sched_clock)
 
 #ifdef CONFIG_VIRT_CPU_ACCOUNTING
 GLOBAL_ENTRY(cycle_to_cputime)
diff --git a/arch/ia64/kernel/paravirt.c b/arch/ia64/kernel/paravirt.c
index de35d8e..6ebbcc1 100644
--- a/arch/ia64/kernel/paravirt.c
+++ b/arch/ia64/kernel/paravirt.c
@@ -366,4 +366,5 @@ ia64_native_do_steal_accounting(unsigned long *new_itm)
 
 struct pv_time_ops pv_time_ops = {
 	.do_steal_accounting = ia64_native_do_steal_accounting,
+	.sched_clock = ia64_native_sched_clock,
 };
diff --git a/arch/ia64/kernel/time.c b/arch/ia64/kernel/time.c
index 65c10a4..6f6ca42 100644
--- a/arch/ia64/kernel/time.c
+++ b/arch/ia64/kernel/time.c
@@ -50,6 +50,18 @@ EXPORT_SYMBOL(last_cli_ip);
 #endif
 
 #ifdef CONFIG_PARAVIRT
+/* We need to define a real function for sched_clock, to override the
+   weak default version */
+unsigned long long sched_clock(void)
+{
+        return paravirt_sched_clock();
+}
+#else
+unsigned long long
+sched_clock(void) __attribute__((alias("ia64_native_sched_clock")));
+#endif
+
+#ifdef CONFIG_PARAVIRT
 static void
 paravirt_clocksource_resume(void)
 {
-- 
1.6.0.2

