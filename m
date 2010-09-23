From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 23 Sep 2010 20:53:48 +0000
Subject: [PATCH] ia64: Add CONFIG_STACKTRACE_SUPPORT
Message-Id: <4c9bbe5c30258b2e5@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Several Linux features are dependent on stack trace support. Add
it so they can be enabled.

Signed-off-by: Tony Luck <tony.luck@intel.com>

---

commit 85718fae2a8d845e66762e6464152a255e323777
Author: Tony Luck <tony.luck@intel.com>
Date:   Thu Sep 23 13:52:07 2010 -0700

    [IA64] Add CONFIG_STACKTRACE_SUPPORT
    
    Several Linux features are dependent on stack trace support. Add
    it so they can be enabled.
    
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index ba22849..e93f44e 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -62,6 +62,9 @@ config NEED_SG_DMA_LENGTH
 config SWIOTLB
        bool
 
+config STACKTRACE_SUPPORT
+	def_bool y
+
 config GENERIC_LOCKBREAK
 	def_bool n
 
diff --git a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
index db10b1e..395c2f2 100644
--- a/arch/ia64/kernel/Makefile
+++ b/arch/ia64/kernel/Makefile
@@ -34,6 +34,7 @@ obj-$(CONFIG_AUDIT)		+= audit.o
 obj-$(CONFIG_PCI_MSI)		+= msi_ia64.o
 mca_recovery-y			+= mca_drv.o mca_drv_asm.o
 obj-$(CONFIG_IA64_MC_ERR_INJECT)+= err_inject.o
+obj-$(CONFIG_STACKTRACE)	+= stacktrace.o
 
 obj-$(CONFIG_PARAVIRT)		+= paravirt.o paravirtentry.o \
 				   paravirt_patch.o
diff --git a/arch/ia64/kernel/stacktrace.c b/arch/ia64/kernel/stacktrace.c
new file mode 100644
index 0000000..5af2783
--- /dev/null
+++ b/arch/ia64/kernel/stacktrace.c
@@ -0,0 +1,39 @@
+/*
+ * arch/ia64/kernel/stacktrace.c
+ *
+ * Stack trace management functions
+ *
+ */
+#include <linux/sched.h>
+#include <linux/stacktrace.h>
+#include <linux/module.h>
+
+static void
+ia64_do_save_stack(struct unw_frame_info *info, void *arg)
+{
+	struct stack_trace *trace = arg;
+	unsigned long ip;
+	int skip = trace->skip;
+
+	trace->nr_entries = 0;
+	do {
+		unw_get_ip(info, &ip);
+		if (ip = 0)
+			break;
+		if (skip = 0) {
+			trace->entries[trace->nr_entries++] = ip;
+			if (trace->nr_entries = trace->max_entries)
+				break;
+		} else
+			skip--;
+	} while (unw_unwind(info) >= 0);
+}
+
+/*
+ * Save stack-backtrace addresses into a stack_trace buffer.
+ */
+void save_stack_trace(struct stack_trace *trace)
+{
+	unw_init_running(ia64_do_save_stack, trace);
+}
+EXPORT_SYMBOL(save_stack_trace);
