From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Tue, 16 Oct 2007 13:39:24 +0000
Subject: [PATCH 6/9] ia64: VIRT_CPU_ACCOUNTING (accurate cpu time accounting)
Message-Id: <4714BF0C.4020602@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> [6/9] ia64_acct_gate_on_switch.patch

Well, let's begin building check points.

We have already get hook points by account_system_vtime(),
so we have points at:

 - irq_enter
 - irq_exit
 - softirq entrance
 - softirq exit

and the rests are points at:

 - context switch
 - kernel entrance
 - kernel exit

Start from first one.

This patch just create a hook point at context switch and
make a function for the point. The inside of this function
is written in last patch.

Thanks,
H.Seto

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>

---
 arch/ia64/kernel/time.c   |    5 +++++
 include/asm-ia64/system.h |    8 ++++++++
 2 files changed, 13 insertions(+)

Index: linux-2.6.23/arch/ia64/kernel/time.c
=================================--- linux-2.6.23.orig/arch/ia64/kernel/time.c
+++ linux-2.6.23/arch/ia64/kernel/time.c
@@ -64,6 +64,11 @@
 #include <linux/kernel_stat.h>
 #include <linux/posix-timers.h>

+void ia64_account_on_switch(struct task_struct *prev, struct task_struct *next)
+{
+
+}
+
 /*
  * Account time for a transition between system, hard irq
  * or soft irq state.
Index: linux-2.6.23/include/asm-ia64/system.h
=================================--- linux-2.6.23.orig/include/asm-ia64/system.h
+++ linux-2.6.23/include/asm-ia64/system.h
@@ -208,6 +208,13 @@
 extern void ia64_save_extra (struct task_struct *task);
 extern void ia64_load_extra (struct task_struct *task);

+#ifdef CONFIG_VIRT_CPU_ACCOUNTING
+extern void ia64_account_on_switch (struct task_struct *prev, struct task_struct *next);
+# define IA64_ACCOUNT_ON_SWITCH(p,n) ia64_account_on_switch(p,n)
+#else
+# define IA64_ACCOUNT_ON_SWITCH(p,n)
+#endif
+
 #ifdef CONFIG_PERFMON
   DECLARE_PER_CPU(unsigned long, pfm_syst_info);
 # define PERFMON_IS_SYSWIDE() (__get_cpu_var(pfm_syst_info) & 0x1)
@@ -220,6 +227,7 @@
 	 || IS_IA32_PROCESS(task_pt_regs(t)) || PERFMON_IS_SYSWIDE())

 #define __switch_to(prev,next,last) do {							 \
+	IA64_ACCOUNT_ON_SWITCH(prev, next);							 \
 	if (IA64_HAS_EXTRA_STATE(prev))								 \
 		ia64_save_extra(prev);								 \
 	if (IA64_HAS_EXTRA_STATE(next))								 \


