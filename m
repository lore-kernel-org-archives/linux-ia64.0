From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Tue, 26 Aug 2008 05:58:33 +0000
Subject: [PATCH 21/30] ia64/pv_ops/xen: paravirtualize entry.S for ia64/xen.
Message-Id: <1219730322-11687-22-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

paravirtualize entry.S for ia64/xen by multi compile.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/include/asm/xen/inst.h |    8 ++++++++
 arch/ia64/xen/Makefile           |    2 +-
 arch/ia64/xen/xen_pv_ops.c       |   18 ++++++++++++++++++
 3 files changed, 27 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/include/asm/xen/inst.h b/arch/ia64/include/asm/xen/inst.h
index e6a25c3..19c2ae1 100644
--- a/arch/ia64/include/asm/xen/inst.h
+++ b/arch/ia64/include/asm/xen/inst.h
@@ -25,6 +25,14 @@
 #define ia64_ivt				xen_ivt
 #define DO_SAVE_MIN				XEN_DO_SAVE_MIN
 
+#define __paravirt_switch_to			xen_switch_to
+#define __paravirt_leave_syscall		xen_leave_syscall
+#define __paravirt_work_processed_syscall	xen_work_processed_syscall
+#define __paravirt_leave_kernel			xen_leave_kernel
+#define __paravirt_pending_syscall_end		xen_work_pending_syscall_end
+#define __paravirt_work_processed_syscall_target \
+						xen_work_processed_syscall
+
 #define MOV_FROM_IFA(reg)	\
 	movl reg = XSI_IFA;	\
 	;;			\
diff --git a/arch/ia64/xen/Makefile b/arch/ia64/xen/Makefile
index 5c87e4a..9b77e8a 100644
--- a/arch/ia64/xen/Makefile
+++ b/arch/ia64/xen/Makefile
@@ -8,7 +8,7 @@ obj-y := hypercall.o xenivt.o xensetup.o xen_pv_ops.o \
 AFLAGS_xenivt.o += -D__IA64_ASM_PARAVIRTUALIZED_XEN
 
 # xen multi compile
-ASM_PARAVIRT_MULTI_COMPILE_SRCS = ivt.S
+ASM_PARAVIRT_MULTI_COMPILE_SRCS = ivt.S entry.S
 ASM_PARAVIRT_OBJS = $(addprefix xen-,$(ASM_PARAVIRT_MULTI_COMPILE_SRCS:.S=.o))
 obj-y += $(ASM_PARAVIRT_OBJS)
 define paravirtualized_xen
diff --git a/arch/ia64/xen/xen_pv_ops.c b/arch/ia64/xen/xen_pv_ops.c
index c236f04..5b23cd5 100644
--- a/arch/ia64/xen/xen_pv_ops.c
+++ b/arch/ia64/xen/xen_pv_ops.c
@@ -275,6 +275,22 @@ static const struct pv_cpu_ops xen_cpu_ops __initdata = {
 			= xen_intrin_local_irq_restore,
 };
 
+/******************************************************************************
+ * replacement of hand written assembly codes.
+ */
+
+extern char xen_switch_to;
+extern char xen_leave_syscall;
+extern char xen_work_processed_syscall;
+extern char xen_leave_kernel;
+
+const struct pv_cpu_asm_switch xen_cpu_asm_switch = {
+	.switch_to		= (unsigned long)&xen_switch_to,
+	.leave_syscall		= (unsigned long)&xen_leave_syscall,
+	.work_processed_syscall	= (unsigned long)&xen_work_processed_syscall,
+	.leave_kernel		= (unsigned long)&xen_leave_kernel,
+};
+
 /***************************************************************************
  * pv_ops initialization
  */
@@ -286,4 +302,6 @@ xen_setup_pv_ops(void)
 	pv_info = xen_info;
 	pv_init_ops = xen_init_ops;
 	pv_cpu_ops = xen_cpu_ops;
+
+	paravirt_cpu_asm_init(&xen_cpu_asm_switch);
 }
-- 
1.6.0.rc0.42.g186458

