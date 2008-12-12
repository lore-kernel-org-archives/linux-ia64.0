From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Fri, 12 Dec 2008 06:38:53 +0000
Subject: [PATCH 04/15] ia64/pv_ops/xen: preliminary to paravirtualizing fsys.S for xen.
Message-Id: <1229063944-27462-5-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This is a preliminary patch to paravirtualizing fsys.S.
compile fsys.S twice one for native and one for xen, and switch
them at run tine.
Later fsys.S will be paravirtualized.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/include/asm/xen/inst.h |    3 +++
 arch/ia64/xen/Makefile           |    2 +-
 arch/ia64/xen/xen_pv_ops.c       |   14 ++++++++++++++
 3 files changed, 18 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/include/asm/xen/inst.h b/arch/ia64/include/asm/xen/inst.h
index 19c2ae1..e8e01b2 100644
--- a/arch/ia64/include/asm/xen/inst.h
+++ b/arch/ia64/include/asm/xen/inst.h
@@ -33,6 +33,9 @@
 #define __paravirt_work_processed_syscall_target \
 						xen_work_processed_syscall
 
+#define paravirt_fsyscall_table			xen_fsyscall_table
+#define paravirt_fsys_bubble_down		xen_fsys_bubble_down
+
 #define MOV_FROM_IFA(reg)	\
 	movl reg = XSI_IFA;	\
 	;;			\
diff --git a/arch/ia64/xen/Makefile b/arch/ia64/xen/Makefile
index 0ad0224..b4ca2e6 100644
--- a/arch/ia64/xen/Makefile
+++ b/arch/ia64/xen/Makefile
@@ -10,7 +10,7 @@ obj-$(CONFIG_IA64_GENERIC) += machvec.o
 AFLAGS_xenivt.o += -D__IA64_ASM_PARAVIRTUALIZED_XEN
 
 # xen multi compile
-ASM_PARAVIRT_MULTI_COMPILE_SRCS = ivt.S entry.S
+ASM_PARAVIRT_MULTI_COMPILE_SRCS = ivt.S entry.S fsys.S
 ASM_PARAVIRT_OBJS = $(addprefix xen-,$(ASM_PARAVIRT_MULTI_COMPILE_SRCS:.S=.o))
 obj-y += $(ASM_PARAVIRT_OBJS)
 define paravirtualized_xen
diff --git a/arch/ia64/xen/xen_pv_ops.c b/arch/ia64/xen/xen_pv_ops.c
index 5d491d9..46b418a 100644
--- a/arch/ia64/xen/xen_pv_ops.c
+++ b/arch/ia64/xen/xen_pv_ops.c
@@ -24,6 +24,7 @@
 #include <linux/irq.h>
 #include <linux/kernel.h>
 #include <linux/pm.h>
+#include <linux/unistd.h>
 
 #include <asm/xen/hypervisor.h>
 #include <asm/xen/xencomm.h>
@@ -166,6 +167,18 @@ static struct pv_init_ops xen_init_ops __initdata = {
 };
 
 /***************************************************************************
+ * pv_fsys_data
+ * addresses for fsys
+ */
+
+extern unsigned long xen_fsyscall_table[NR_syscalls];
+extern char xen_fsys_bubble_down[];
+struct pv_fsys_data xen_fsys_data __initdata = {
+	.fsyscall_table = (unsigned long *)xen_fsyscall_table,
+	.fsys_bubble_down = (void *)xen_fsys_bubble_down,
+};
+
+/***************************************************************************
  * pv_cpu_ops
  * intrinsics hooks.
  */
@@ -355,6 +368,7 @@ xen_setup_pv_ops(void)
 	xen_info_init();
 	pv_info = xen_info;
 	pv_init_ops = xen_init_ops;
+	pv_fsys_data = xen_fsys_data;
 	pv_cpu_ops = xen_cpu_ops;
 	pv_iosapic_ops = xen_iosapic_ops;
 	pv_irq_ops = xen_irq_ops;
-- 
1.6.0.2

