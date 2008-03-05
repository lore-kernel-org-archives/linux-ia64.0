From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 05 Mar 2008 18:18:52 +0000
Subject: [PATCH 37/50] ia64/pv_ops/xen: multi compile switch_leave.S and ivt.S for xen.
Message-Id: <12047411462336-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/kernel/Makefile |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
index 7849bc3..a80dd3f 100644
--- a/arch/ia64/kernel/Makefile
+++ b/arch/ia64/kernel/Makefile
@@ -83,3 +83,18 @@ $(obj)/gate-data.o: $(obj)/gate.so
 #
 AFLAGS_ivt.o += -D__IA64_ASM_PARAVIRTUALIZED_NATIVE
 AFLAGS_switch_leave.o += -D__IA64_ASM_PARAVIRTUALIZED_NATIVE
+
+# xen multi compile
+$(obj)/xen_%.o: $(src)/%.S FORCE
+	$(call if_changed_dep,as_o_S)
+
+#
+# xenivt.o, xen_switch_leave.o
+#
+obj-$(CONFIG_XEN) += xen_ivt.o xen_switch_leave.o
+ifeq ($(CONFIG_XEN), y)
+targets += xen_ivt.o xen_switch_leave.o
+$(obj)/build-in.o: xen_ivt.o xen_switch_leave.o
+endif
+AFLAGS_xen_ivt.o += -D__IA64_ASM_PARAVIRTUALIZED_XEN
+AFLAGS_xen_switch_leave.o += -D__IA64_ASM_PARAVIRTUALIZED_XEN
-- 
1.5.3

