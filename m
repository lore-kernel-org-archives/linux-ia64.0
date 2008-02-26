From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Tue, 26 Feb 2008 13:58:59 +0000
Subject: [PATCH 8/8] ia64/pv_ops/xen: multi compiling switch_leave.S and ivt.S for xen.
Message-Id: <1204034339887-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/kernel/Makefile |   24 ++++++++++++++++++++++++
 1 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
index 9281bf6..05ea5f8 100644
--- a/arch/ia64/kernel/Makefile
+++ b/arch/ia64/kernel/Makefile
@@ -76,3 +76,27 @@ $(obj)/gate-data.o: $(obj)/gate.so
 #
 AFLAGS_ivt.o += -D__IA64_ASM_PARAVIRTUALIZED_NATIVE
 AFLAGS_switch_leave.o += -D__IA64_ASM_PARAVIRTUALIZED_NATIVE
+
+#
+# xenivt.o
+#
+obj-$(CONFIG_XEN) += xen_ivt.o
+ifeq ($(CONFIG_XEN), y)
+targets += xen_ivt.o
+$(obj)/build-in.o: xen_ivt.o
+endif
+AFLAGS_xen_ivt.o += -D__IA64_ASM_PARAVIRTUALIZED_XEN
+$(obj)/xen_ivt.o: $(src)/ivt.S FORCE
+	$(call if_changed_dep,as_o_S)
+
+#
+# xen_switch_leave.o
+#
+obj-$(CONFIG_XEN) += xen_switch_leave.o
+ifeq ($(CONFIG_XEN), y)
+targets += xen_switch_leave.o
+$(obj)/build-in.o: xen_switch_leave.o
+endif
+AFLAGS_xen_switch_leave.o += -D__IA64_ASM_PARAVIRTUALIZED_XEN
+$(obj)/xen_switch_leave.o: $(src)/switch_leave.S FORCE
+	$(call if_changed_dep,as_o_S)
-- 
1.5.3

