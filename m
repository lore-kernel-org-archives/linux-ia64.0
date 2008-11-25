From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Tue, 25 Nov 2008 12:57:53 +0000
Subject: [PATCH 10/13] ia64/pv_ops/xen: define xen specific gate page.
Message-Id: <1227618131-3755-11-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

define xen specific gate page.
At this phase bits in the gate page is same to native.
At the next phase, it will be paravirtualized.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/include/asm/xen/patchlist.h |   38 +++++++++++++++++++++++++++++++++
 arch/ia64/kernel/vmlinux.lds.S        |    6 +++++
 arch/ia64/xen/Makefile                |   16 +++++++++++++-
 arch/ia64/xen/gate-data.S             |    3 ++
 arch/ia64/xen/xen_pv_ops.c            |   32 +++++++++++++++++++++++++++
 5 files changed, 94 insertions(+), 1 deletions(-)
 create mode 100644 arch/ia64/include/asm/xen/patchlist.h
 create mode 100644 arch/ia64/xen/gate-data.S

diff --git a/arch/ia64/include/asm/xen/patchlist.h b/arch/ia64/include/asm/xen/patchlist.h
new file mode 100644
index 0000000..eae944e
--- /dev/null
+++ b/arch/ia64/include/asm/xen/patchlist.h
@@ -0,0 +1,38 @@
+/******************************************************************************
+ * arch/ia64/include/asm/xen/patchlist.h
+ *
+ * Copyright (c) 2008 Isaku Yamahata <yamahata at valinux co jp>
+ *                    VA Linux Systems Japan K.K.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ *
+ */
+
+#define __paravirt_start_gate_fsyscall_patchlist		\
+	__xen_start_gate_fsyscall_patchlist
+#define __paravirt_end_gate_fsyscall_patchlist			\
+	__xen_end_gate_fsyscall_patchlist
+#define __paravirt_start_gate_brl_fsys_bubble_down_patchlist	\
+	__xen_start_gate_brl_fsys_bubble_down_patchlist
+#define __paravirt_end_gate_brl_fsys_bubble_down_patchlist	\
+	__xen_end_gate_brl_fsys_bubble_down_patchlist
+#define __paravirt_start_gate_vtop_patchlist			\
+	__xen_start_gate_vtop_patchlist
+#define __paravirt_end_gate_vtop_patchlist			\
+	__xen_end_gate_vtop_patchlist
+#define __paravirt_start_gate_mckinley_e9_patchlist		\
+	__xen_start_gate_mckinley_e9_patchlist
+#define __paravirt_end_gate_mckinley_e9_patchlist		\
+	__xen_end_gate_mckinley_e9_patchlist
diff --git a/arch/ia64/kernel/vmlinux.lds.S b/arch/ia64/kernel/vmlinux.lds.S
index 10a7d47..92ae7e8 100644
--- a/arch/ia64/kernel/vmlinux.lds.S
+++ b/arch/ia64/kernel/vmlinux.lds.S
@@ -201,6 +201,12 @@ SECTIONS
 	  __start_gate_section = .;
 	  *(.data.gate)
 	  __stop_gate_section = .;
+#ifdef CONFIG_XEN
+	  . = ALIGN(PAGE_SIZE);
+	  __xen_start_gate_section = .;
+	  *(.data.gate.xen)
+	  __xen_stop_gate_section = .;
+#endif
 	}
   . = ALIGN(PAGE_SIZE);		/* make sure the gate page doesn't expose
   				 * kernel data
diff --git a/arch/ia64/xen/Makefile b/arch/ia64/xen/Makefile
index b4ca2e6..94f0d8e 100644
--- a/arch/ia64/xen/Makefile
+++ b/arch/ia64/xen/Makefile
@@ -3,10 +3,24 @@
 #
 
 obj-y := hypercall.o xenivt.o xensetup.o xen_pv_ops.o irq_xen.o \
-	 hypervisor.o xencomm.o xcom_hcall.o grant-table.o time.o suspend.o
+	 hypervisor.o xencomm.o xcom_hcall.o grant-table.o time.o suspend.o \
+	 gate-data.o
 
 obj-$(CONFIG_IA64_GENERIC) += machvec.o
 
+# The gate DSO image is built using a special linker script.
+include $(srctree)/arch/ia64/kernel/Makefile.gate
+
+# tell compiled for xen
+CPPFLAGS_gate.lds += -D__IA64_GATE_PARAVIRTUALIZED_XEN
+
+# use same file of native.
+$(obj)/gate.o: $(src)/../kernel/gate.S FORCE
+	$(call if_changed_dep,as_o_S)
+$(obj)/gate.lds: $(src)/../kernel/gate.lds.S FORCE
+	$(call if_changed_dep,cpp_lds_S)
+
+
 AFLAGS_xenivt.o += -D__IA64_ASM_PARAVIRTUALIZED_XEN
 
 # xen multi compile
diff --git a/arch/ia64/xen/gate-data.S b/arch/ia64/xen/gate-data.S
new file mode 100644
index 0000000..7d4830a
--- /dev/null
+++ b/arch/ia64/xen/gate-data.S
@@ -0,0 +1,3 @@
+	.section .data.gate.xen, "aw"
+
+	.incbin "arch/ia64/xen/gate.so"
diff --git a/arch/ia64/xen/xen_pv_ops.c b/arch/ia64/xen/xen_pv_ops.c
index e83ede7..eda13a8 100644
--- a/arch/ia64/xen/xen_pv_ops.c
+++ b/arch/ia64/xen/xen_pv_ops.c
@@ -179,6 +179,37 @@ struct pv_fsys_data xen_fsys_data __initdata = {
 };
 
 /***************************************************************************
+ * pv_patchdata
+ * patchdata addresses
+ */
+
+#define DECLARE(name)							\
+	extern unsigned long __xen_start_gate_##name##_patchlist[];	\
+	extern unsigned long __xen_end_gate_##name##_patchlist[]
+
+DECLARE(fsyscall);
+DECLARE(brl_fsys_bubble_down);
+DECLARE(vtop);
+DECLARE(mckinley_e9);
+
+extern unsigned long __xen_start_gate_section[];
+
+#define ASSIGN(name)							\
+	.start_##name##_patchlist =					\
+		(unsigned long)__xen_start_gate_##name##_patchlist,	\
+	.end_##name##_patchlist =					\
+		(unsigned long)__xen_end_gate_##name##_patchlist
+
+static struct pv_patchdata xen_patchdata __initdata = {
+	ASSIGN(fsyscall),
+	ASSIGN(brl_fsys_bubble_down),
+	ASSIGN(vtop),
+	ASSIGN(mckinley_e9),
+
+	.gate_section = (void*)__xen_start_gate_section,
+};
+
+/***************************************************************************
  * pv_cpu_ops
  * intrinsics hooks.
  */
@@ -447,6 +478,7 @@ xen_setup_pv_ops(void)
 	pv_info = xen_info;
 	pv_init_ops = xen_init_ops;
 	pv_fsys_data = xen_fsys_data;
+	pv_patchdata = xen_patchdata;
 	pv_cpu_ops = xen_cpu_ops;
 	pv_iosapic_ops = xen_iosapic_ops;
 	pv_irq_ops = xen_irq_ops;
-- 
1.6.0.2

