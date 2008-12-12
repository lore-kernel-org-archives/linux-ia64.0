From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Fri, 12 Dec 2008 06:39:00 +0000
Subject: [PATCH 11/15] ia64/pv_ops: gate page paravirtualization.
Message-Id: <1229063944-27462-12-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

paravirtualize gate page by allowing each pv_ops instances
to define its own gate page.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/include/asm/native/patchlist.h |   38 ++++++++++++++
 arch/ia64/include/asm/paravirt.h         |   35 +++++++++++++
 arch/ia64/kernel/Makefile                |   32 ++----------
 arch/ia64/kernel/Makefile.gate           |   27 ++++++++++
 arch/ia64/kernel/gate.lds.S              |   17 ++++---
 arch/ia64/kernel/paravirt_patchlist.c    |   78 ++++++++++++++++++++++++++=
++++
 arch/ia64/kernel/paravirt_patchlist.h    |   28 +++++++++++
 arch/ia64/kernel/patch.c                 |   12 ++--
 arch/ia64/mm/init.c                      |    6 ++-
 9 files changed, 230 insertions(+), 43 deletions(-)
 create mode 100644 arch/ia64/include/asm/native/patchlist.h
 create mode 100644 arch/ia64/kernel/Makefile.gate
 create mode 100644 arch/ia64/kernel/paravirt_patchlist.c
 create mode 100644 arch/ia64/kernel/paravirt_patchlist.h

diff --git a/arch/ia64/include/asm/native/patchlist.h b/arch/ia64/include/a=
sm/native/patchlist.h
new file mode 100644
index 0000000..be16ca9
--- /dev/null
+++ b/arch/ia64/include/asm/native/patchlist.h
@@ -0,0 +1,38 @@
+/*************************************************************************=
*****
+ * arch/ia64/include/asm/native/inst.h
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
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  U=
SA
+ *
+ */
+
+#define __paravirt_start_gate_fsyscall_patchlist		\
+	__ia64_native_start_gate_fsyscall_patchlist
+#define __paravirt_end_gate_fsyscall_patchlist			\
+	__ia64_native_end_gate_fsyscall_patchlist
+#define __paravirt_start_gate_brl_fsys_bubble_down_patchlist	\
+	__ia64_native_start_gate_brl_fsys_bubble_down_patchlist
+#define __paravirt_end_gate_brl_fsys_bubble_down_patchlist	\
+	__ia64_native_end_gate_brl_fsys_bubble_down_patchlist
+#define __paravirt_start_gate_vtop_patchlist			\
+	__ia64_native_start_gate_vtop_patchlist
+#define __paravirt_end_gate_vtop_patchlist			\
+	__ia64_native_end_gate_vtop_patchlist
+#define __paravirt_start_gate_mckinley_e9_patchlist		\
+	__ia64_native_start_gate_mckinley_e9_patchlist
+#define __paravirt_end_gate_mckinley_e9_patchlist		\
+	__ia64_native_end_gate_mckinley_e9_patchlist
diff --git a/arch/ia64/include/asm/paravirt.h b/arch/ia64/include/asm/parav=
irt.h
index a73e77a..fc433f6 100644
--- a/arch/ia64/include/asm/paravirt.h
+++ b/arch/ia64/include/asm/paravirt.h
@@ -35,6 +35,41 @@ extern struct pv_fsys_data pv_fsys_data;
=20
 unsigned long *paravirt_get_fsyscall_table(void);
 char *paravirt_get_fsys_bubble_down(void);
+
+/*************************************************************************=
*****
+ * patchlist addresses for gate page
+ */
+enum pv_gate_patchlist {
+	PV_GATE_START_FSYSCALL,
+	PV_GATE_END_FSYSCALL,
+
+	PV_GATE_START_BRL_FSYS_BUBBLE_DOWN,
+	PV_GATE_END_BRL_FSYS_BUBBLE_DOWN,
+
+	PV_GATE_START_VTOP,
+	PV_GATE_END_VTOP,
+
+	PV_GATE_START_MCKINLEY_E9,
+	PV_GATE_END_MCKINLEY_E9,
+};
+
+struct pv_patchdata {
+	unsigned long start_fsyscall_patchlist;
+	unsigned long end_fsyscall_patchlist;
+	unsigned long start_brl_fsys_bubble_down_patchlist;
+	unsigned long end_brl_fsys_bubble_down_patchlist;
+	unsigned long start_vtop_patchlist;
+	unsigned long end_vtop_patchlist;
+	unsigned long start_mckinley_e9_patchlist;
+	unsigned long end_mckinley_e9_patchlist;
+
+	void *gate_section;
+};
+
+extern struct pv_patchdata pv_patchdata;
+
+unsigned long paravirt_get_gate_patchlist(enum pv_gate_patchlist type);
+void *paravirt_get_gate_section(void);
 #endif
=20
 #ifdef CONFIG_PARAVIRT_GUEST
diff --git a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
index 1ab150e..8dc9df8 100644
--- a/arch/ia64/kernel/Makefile
+++ b/arch/ia64/kernel/Makefile
@@ -5,7 +5,7 @@
 extra-y	:=3D head.o init_task.o vmlinux.lds
=20
 obj-y :=3D acpi.o entry.o efi.o efi_stub.o gate-data.o fsys.o ia64_ksyms.o=
 irq.o irq_ia64.o	\
-	 irq_lsapic.o ivt.o machvec.o pal.o patch.o process.o perfmon.o ptrace.o =
sal.o		\
+	 irq_lsapic.o ivt.o machvec.o pal.o paravirt_patchlist.o patch.o process.=
o perfmon.o ptrace.o sal.o		\
 	 salinfo.o setup.o signal.o sys_ia64.o time.o traps.o unaligned.o \
 	 unwind.o mca.o mca_asm.o topology.o
=20
@@ -47,35 +47,13 @@ ifeq ($(CONFIG_DMAR), y)
 obj-$(CONFIG_SWIOTLB)		+=3D pci-swiotlb.o
 endif
=20
-# The gate DSO image is built using a special linker script.
-targets +=3D gate.so gate-syms.o
-
-extra-y +=3D gate.so gate-syms.o gate.lds gate.o
-
 # fp_emulate() expects f2-f5,f16-f31 to contain the user-level state.
 CFLAGS_traps.o  +=3D -mfixed-range=F2-f5,f16-f31
=20
-CPPFLAGS_gate.lds :=3D -P -C -U$(ARCH)
-
-quiet_cmd_gate =3D GATE $@
-      cmd_gate =3D $(CC) -nostdlib $(GATECFLAGS_$(@F)) -Wl,-T,$(filter-out=
 FORCE,$^) -o $@
-
-GATECFLAGS_gate.so =3D -shared -s -Wl,-soname=3Dlinux-gate.so.1 \
-		     $(call ld-option, -Wl$(comma)--hash-style=3Dsysv)
-$(obj)/gate.so: $(obj)/gate.lds $(obj)/gate.o FORCE
-	$(call if_changed,gate)
-
-$(obj)/built-in.o: $(obj)/gate-syms.o
-$(obj)/built-in.o: ld_flags +=3D -R $(obj)/gate-syms.o
-
-GATECFLAGS_gate-syms.o =3D -r
-$(obj)/gate-syms.o: $(obj)/gate.lds $(obj)/gate.o FORCE
-	$(call if_changed,gate)
-
-# gate-data.o contains the gate DSO image as data in section .data.gate.
-# We must build gate.so before we can assemble it.
-# Note: kbuild does not track this dependency due to usage of .incbin
-$(obj)/gate-data.o: $(obj)/gate.so
+# The gate DSO image is built using a special linker script.
+include $(srctree)/arch/ia64/kernel/Makefile.gate
+# tell compiled for native
+CPPFLAGS_gate.lds +=3D -D__IA64_GATE_PARAVIRTUALIZED_NATIVE
=20
 # Calculate NR_IRQ =3D max(IA64_NATIVE_NR_IRQS, XEN_NR_IRQS, ...) based on=
 config
 define sed-y
diff --git a/arch/ia64/kernel/Makefile.gate b/arch/ia64/kernel/Makefile.gate
new file mode 100644
index 0000000..1d87f84
--- /dev/null
+++ b/arch/ia64/kernel/Makefile.gate
@@ -0,0 +1,27 @@
+# The gate DSO image is built using a special linker script.
+
+targets +=3D gate.so gate-syms.o
+
+extra-y +=3D gate.so gate-syms.o gate.lds gate.o
+
+CPPFLAGS_gate.lds :=3D -P -C -U$(ARCH)
+
+quiet_cmd_gate =3D GATE $@
+      cmd_gate =3D $(CC) -nostdlib $(GATECFLAGS_$(@F)) -Wl,-T,$(filter-out=
 FORCE,$^) -o $@
+
+GATECFLAGS_gate.so =3D -shared -s -Wl,-soname=3Dlinux-gate.so.1 \
+		     $(call ld-option, -Wl$(comma)--hash-style=3Dsysv)
+$(obj)/gate.so: $(obj)/gate.lds $(obj)/gate.o FORCE
+	$(call if_changed,gate)
+
+$(obj)/built-in.o: $(obj)/gate-syms.o
+$(obj)/built-in.o: ld_flags +=3D -R $(obj)/gate-syms.o
+
+GATECFLAGS_gate-syms.o =3D -r
+$(obj)/gate-syms.o: $(obj)/gate.lds $(obj)/gate.o FORCE
+	$(call if_changed,gate)
+
+# gate-data.o contains the gate DSO image as data in section .data.gate.
+# We must build gate.so before we can assemble it.
+# Note: kbuild does not track this dependency due to usage of .incbin
+$(obj)/gate-data.o: $(obj)/gate.so
diff --git a/arch/ia64/kernel/gate.lds.S b/arch/ia64/kernel/gate.lds.S
index 3cb1abc..88c64ed 100644
--- a/arch/ia64/kernel/gate.lds.S
+++ b/arch/ia64/kernel/gate.lds.S
@@ -7,6 +7,7 @@
=20
=20
 #include <asm/system.h>
+#include "paravirt_patchlist.h"
=20
 SECTIONS
 {
@@ -33,21 +34,21 @@ SECTIONS
 	. =3D GATE_ADDR + 0x600;
=20
 	.data.patch		: {
-		__start_gate_mckinley_e9_patchlist =3D .;
+		__paravirt_start_gate_mckinley_e9_patchlist =3D .;
 		*(.data.patch.mckinley_e9)
-		__end_gate_mckinley_e9_patchlist =3D .;
+		__paravirt_end_gate_mckinley_e9_patchlist =3D .;
=20
-		__start_gate_vtop_patchlist =3D .;
+		__paravirt_start_gate_vtop_patchlist =3D .;
 		*(.data.patch.vtop)
-		__end_gate_vtop_patchlist =3D .;
+		__paravirt_end_gate_vtop_patchlist =3D .;
=20
-		__start_gate_fsyscall_patchlist =3D .;
+		__paravirt_start_gate_fsyscall_patchlist =3D .;
 		*(.data.patch.fsyscall_table)
-		__end_gate_fsyscall_patchlist =3D .;
+		__paravirt_end_gate_fsyscall_patchlist =3D .;
=20
-		__start_gate_brl_fsys_bubble_down_patchlist =3D .;
+		__paravirt_start_gate_brl_fsys_bubble_down_patchlist =3D .;
 		*(.data.patch.brl_fsys_bubble_down)
-		__end_gate_brl_fsys_bubble_down_patchlist =3D .;
+		__paravirt_end_gate_brl_fsys_bubble_down_patchlist =3D .;
 	}						:readable
=20
 	.IA_64.unwind_info	: { *(.IA_64.unwind_info*) }
diff --git a/arch/ia64/kernel/paravirt_patchlist.c b/arch/ia64/kernel/parav=
irt_patchlist.c
new file mode 100644
index 0000000..bdefe9a
--- /dev/null
+++ b/arch/ia64/kernel/paravirt_patchlist.c
@@ -0,0 +1,78 @@
+/*************************************************************************=
*****
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
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  U=
SA
+ *
+ */
+
+#include <asm/paravirt.h>
+
+#define DECLARE(name)						\
+	extern unsigned long					\
+		__ia64_native_start_gate_##name##_patchlist[];	\
+	extern unsigned long					\
+		__ia64_native_end_gate_##name##_patchlist[]
+
+DECLARE(fsyscall);
+DECLARE(brl_fsys_bubble_down);
+DECLARE(vtop);
+DECLARE(mckinley_e9);
+
+extern unsigned long __start_gate_section[];
+
+#define ASSIGN(name)							    \
+	.start_##name##_patchlist =3D					    \
+		(unsigned long)__ia64_native_start_gate_##name##_patchlist, \
+	.end_##name##_patchlist =3D					    \
+		(unsigned long)__ia64_native_end_gate_##name##_patchlist
+
+struct pv_patchdata pv_patchdata __initdata =3D {
+	ASSIGN(fsyscall),
+	ASSIGN(brl_fsys_bubble_down),
+	ASSIGN(vtop),
+	ASSIGN(mckinley_e9),
+
+	.gate_section =3D (void*)__start_gate_section,
+};
+
+
+unsigned long __init
+paravirt_get_gate_patchlist(enum pv_gate_patchlist type)
+{
+
+#define CASE(NAME, name)					\
+	case PV_GATE_START_##NAME:				\
+		return pv_patchdata.start_##name##_patchlist;	\
+	case PV_GATE_END_##NAME:				\
+		return pv_patchdata.end_##name##_patchlist;	\
+
+	switch (type) {
+		CASE(FSYSCALL, fsyscall);
+		CASE(BRL_FSYS_BUBBLE_DOWN, brl_fsys_bubble_down);
+		CASE(VTOP, vtop);
+		CASE(MCKINLEY_E9, mckinley_e9);
+	default:
+		BUG();
+		break;
+	}
+	return 0;
+}
+
+void * __init
+paravirt_get_gate_section(void)
+{
+	return pv_patchdata.gate_section;
+}
diff --git a/arch/ia64/kernel/paravirt_patchlist.h b/arch/ia64/kernel/parav=
irt_patchlist.h
new file mode 100644
index 0000000..0684aa6
--- /dev/null
+++ b/arch/ia64/kernel/paravirt_patchlist.h
@@ -0,0 +1,28 @@
+/*************************************************************************=
*****
+ * linux/arch/ia64/xen/paravirt_patchlist.h
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
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  U=
SA
+ *
+ */
+
+#if defined(__IA64_GATE_PARAVIRTUALIZED_XEN)
+#include <asm/xen/patchlist.h>
+#else
+#include <asm/native/patchlist.h>
+#endif
+
diff --git a/arch/ia64/kernel/patch.c b/arch/ia64/kernel/patch.c
index c88f530..52a6b2c 100644
--- a/arch/ia64/kernel/patch.c
+++ b/arch/ia64/kernel/patch.c
@@ -227,13 +227,13 @@ patch_brl_fsys_bubble_down (unsigned long start, unsi=
gned long end)
 void __init
 ia64_patch_gate (void)
 {
-#	define START(name)	((unsigned long) __start_gate_##name##_patchlist)
-#	define END(name)	((unsigned long)__end_gate_##name##_patchlist)
+#	define START(name)	paravirt_get_gate_patchlist(PV_GATE_START_##name)
+#	define END(name)	paravirt_get_gate_patchlist(PV_GATE_END_##name)
=20
-	patch_fsyscall_table(START(fsyscall), END(fsyscall));
-	patch_brl_fsys_bubble_down(START(brl_fsys_bubble_down), END(brl_fsys_bubb=
le_down));
-	ia64_patch_vtop(START(vtop), END(vtop));
-	ia64_patch_mckinley_e9(START(mckinley_e9), END(mckinley_e9));
+	patch_fsyscall_table(START(FSYSCALL), END(FSYSCALL));
+	patch_brl_fsys_bubble_down(START(BRL_FSYS_BUBBLE_DOWN), END(BRL_FSYS_BUBB=
LE_DOWN));
+	ia64_patch_vtop(START(VTOP), END(VTOP));
+	ia64_patch_mckinley_e9(START(MCKINLEY_E9), END(MCKINLEY_E9));
 }
=20
 void ia64_patch_phys_stack_reg(unsigned long val)
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 7d9b964..790d94e 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -259,6 +259,7 @@ put_kernel_page (struct page *page, unsigned long addre=
ss, pgprot_t pgprot)
 static void __init
 setup_gate (void)
 {
+	void *gate_section;
 	struct page *page;
=20
 	/*
@@ -266,10 +267,11 @@ setup_gate (void)
 	 * headers etc. and once execute-only page to enable
 	 * privilege-promotion via "epc":
 	 */
-	page =3D virt_to_page(ia64_imva(__start_gate_section));
+	gate_section =3D paravirt_get_gate_section();
+	page =3D virt_to_page(ia64_imva(gate_section));
 	put_kernel_page(page, GATE_ADDR, PAGE_READONLY);
 #ifdef HAVE_BUGGY_SEGREL
-	page =3D virt_to_page(ia64_imva(__start_gate_section + PAGE_SIZE));
+	page =3D virt_to_page(ia64_imva(gate_section + PAGE_SIZE));
 	put_kernel_page(page, GATE_ADDR + PAGE_SIZE, PAGE_GATE);
 #else
 	put_kernel_page(page, GATE_ADDR + PERCPU_PAGE_SIZE, PAGE_GATE);
--=20
1.6.0.2

