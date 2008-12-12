From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Fri, 12 Dec 2008 06:38:52 +0000
Subject: [PATCH 03/15] ia64/pv_ops: add hooks to paravirtualize fsyscall implementation.
Message-Id: <1229063944-27462-4-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Add two hooks, paravirt_get_fsyscall_table() and
paravirt_get_fsys_bubble_doen() to paravirtualize fsyscall implementation.
This patch just add the hooks fsyscall and don't paravirtualize it.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/include/asm/native/inst.h |    3 +++
 arch/ia64/include/asm/paravirt.h    |   15 +++++++++++++++
 arch/ia64/kernel/Makefile           |    4 ++--
 arch/ia64/kernel/fsys.S             |   17 +++++++++--------
 arch/ia64/kernel/patch.c            |   26 +++++++++++++++++++++++---
 arch/ia64/mm/init.c                 |    2 +-
 6 files changed, 53 insertions(+), 14 deletions(-)

diff --git a/arch/ia64/include/asm/native/inst.h b/arch/ia64/include/asm/na=
tive/inst.h
index 0a1026c..5e4e151 100644
--- a/arch/ia64/include/asm/native/inst.h
+++ b/arch/ia64/include/asm/native/inst.h
@@ -30,6 +30,9 @@
 #define __paravirt_work_processed_syscall_target \
 						ia64_work_processed_syscall
=20
+#define paravirt_fsyscall_table			ia64_native_fsyscall_table
+#define paravirt_fsys_bubble_down		ia64_native_fsys_bubble_down
+
 #ifdef CONFIG_PARAVIRT_GUEST_ASM_CLOBBER_CHECK
 # define PARAVIRT_POISON	0xdeadbeefbaadf00d
 # define CLOBBER(clob)				\
diff --git a/arch/ia64/include/asm/paravirt.h b/arch/ia64/include/asm/parav=
irt.h
index 2bf3636..56f69f9 100644
--- a/arch/ia64/include/asm/paravirt.h
+++ b/arch/ia64/include/asm/paravirt.h
@@ -22,6 +22,21 @@
 #ifndef __ASM_PARAVIRT_H
 #define __ASM_PARAVIRT_H
=20
+#ifndef __ASSEMBLY__
+/*************************************************************************=
*****
+ * fsys related addresses
+ */
+struct pv_fsys_data {
+	unsigned long *fsyscall_table;
+	void *fsys_bubble_down;
+};
+
+extern struct pv_fsys_data pv_fsys_data;
+
+unsigned long *paravirt_get_fsyscall_table(void);
+char *paravirt_get_fsys_bubble_down(void);
+#endif
+
 #ifdef CONFIG_PARAVIRT_GUEST
=20
 #define PARAVIRT_HYPERVISOR_TYPE_DEFAULT	0
diff --git a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
index c381ea9..1ab150e 100644
--- a/arch/ia64/kernel/Makefile
+++ b/arch/ia64/kernel/Makefile
@@ -111,9 +111,9 @@ include/asm-ia64/nr-irqs.h: arch/$(SRCARCH)/kernel/nr-i=
rqs.s
 clean-files +=3D $(objtree)/include/asm-ia64/nr-irqs.h
=20
 #
-# native ivt.S and entry.S
+# native ivt.S, entry.S and fsys.S
 #
-ASM_PARAVIRT_OBJS =3D ivt.o entry.o
+ASM_PARAVIRT_OBJS =3D ivt.o entry.o fsys.o
 define paravirtualized_native
 AFLAGS_$(1) +=3D -D__IA64_ASM_PARAVIRTUALIZED_NATIVE
 AFLAGS_pvchk-sed-$(1) +=3D -D__IA64_ASM_PARAVIRTUALIZED_PVCHECK
diff --git a/arch/ia64/kernel/fsys.S b/arch/ia64/kernel/fsys.S
index c1625c7..788319f 100644
--- a/arch/ia64/kernel/fsys.S
+++ b/arch/ia64/kernel/fsys.S
@@ -25,6 +25,7 @@
 #include <asm/unistd.h>
=20
 #include "entry.h"
+#include "paravirt_inst.h"
=20
 /*
  * See Documentation/ia64/fsys.txt for details on fsyscalls.
@@ -602,7 +603,7 @@ ENTRY(fsys_fallback_syscall)
 	mov r26=3Dar.pfs
 END(fsys_fallback_syscall)
 	/* FALL THROUGH */
-GLOBAL_ENTRY(fsys_bubble_down)
+GLOBAL_ENTRY(paravirt_fsys_bubble_down)
 	.prologue
 	.altrp b6
 	.body
@@ -640,7 +641,7 @@ GLOBAL_ENTRY(fsys_bubble_down)
 	 *
 	 * PSR.BE : already is turned off in __kernel_syscall_via_epc()
 	 * PSR.AC : don't care (kernel normally turns PSR.AC on)
-	 * PSR.I  : already turned off by the time fsys_bubble_down gets
+	 * PSR.I  : already turned off by the time paravirt_fsys_bubble_down gets
 	 *	    invoked
 	 * PSR.DFL: always 0 (kernel never turns it on)
 	 * PSR.DFH: don't care --- kernel never touches f32-f127 on its own
@@ -650,7 +651,7 @@ GLOBAL_ENTRY(fsys_bubble_down)
 	 * PSR.DB : don't care --- kernel never enables kernel-level
 	 *	    breakpoints
 	 * PSR.TB : must be 0 already; if it wasn't zero on entry to
-	 *          __kernel_syscall_via_epc, the branch to fsys_bubble_down
+	 *          __kernel_syscall_via_epc, the branch to paravirt_fsys_bubble_=
down
 	 *          will trigger a taken branch; the taken-trap-handler then
 	 *          converts the syscall into a break-based system-call.
 	 */
@@ -741,14 +742,14 @@ GLOBAL_ENTRY(fsys_bubble_down)
 	nop.m 0
 (p8)	br.call.sptk.many b6=B6			// B    (ignore return address)
 	br.cond.spnt ia64_trace_syscall		// B
-END(fsys_bubble_down)
+END(paravirt_fsys_bubble_down)
=20
 	.rodata
 	.align 8
-	.globl fsyscall_table
+	.globl paravirt_fsyscall_table
=20
-	data8 fsys_bubble_down
-fsyscall_table:
+	data8 paravirt_fsys_bubble_down
+paravirt_fsyscall_table:
 	data8 fsys_ni_syscall
 	data8 0				// exit			// 1025
 	data8 0				// read
@@ -1033,4 +1034,4 @@ fsyscall_table:
=20
 	// fill in zeros for the remaining entries
 	.zero:
-	.space fsyscall_table + 8*NR_syscalls - .zero, 0
+	.space paravirt_fsyscall_table + 8*NR_syscalls - .zero, 0
diff --git a/arch/ia64/kernel/patch.c b/arch/ia64/kernel/patch.c
index 5660069..c88f530 100644
--- a/arch/ia64/kernel/patch.c
+++ b/arch/ia64/kernel/patch.c
@@ -7,6 +7,7 @@
 #include <linux/init.h>
 #include <linux/string.h>
=20
+#include <asm/paravirt.h>
 #include <asm/patch.h>
 #include <asm/processor.h>
 #include <asm/sections.h>
@@ -169,16 +170,35 @@ ia64_patch_mckinley_e9 (unsigned long start, unsigned=
 long end)
 	ia64_srlz_i();
 }
=20
+extern unsigned long ia64_native_fsyscall_table[NR_syscalls];
+extern char ia64_native_fsys_bubble_down[];
+struct pv_fsys_data pv_fsys_data __initdata =3D {
+	.fsyscall_table =3D (unsigned long *)ia64_native_fsyscall_table,
+	.fsys_bubble_down =3D (void *)ia64_native_fsys_bubble_down,
+};
+
+unsigned long * __init
+paravirt_get_fsyscall_table(void)
+{
+	return pv_fsys_data.fsyscall_table;
+}
+
+char * __init
+paravirt_get_fsys_bubble_down(void)
+{
+	return pv_fsys_data.fsys_bubble_down;
+}
+
 static void __init
 patch_fsyscall_table (unsigned long start, unsigned long end)
 {
-	extern unsigned long fsyscall_table[NR_syscalls];
+	u64 fsyscall_table =3D (u64)paravirt_get_fsyscall_table();
 	s32 *offp =3D (s32 *) start;
 	u64 ip;
=20
 	while (offp < (s32 *) end) {
 		ip =3D (u64) ia64_imva((char *) offp + *offp);
-		ia64_patch_imm64(ip, (u64) fsyscall_table);
+		ia64_patch_imm64(ip, fsyscall_table);
 		ia64_fc(ip);
 		++offp;
 	}
@@ -189,7 +209,7 @@ patch_fsyscall_table (unsigned long start, unsigned lon=
g end)
 static void __init
 patch_brl_fsys_bubble_down (unsigned long start, unsigned long end)
 {
-	extern char fsys_bubble_down[];
+	u64 fsys_bubble_down =3D (u64)paravirt_get_fsys_bubble_down();
 	s32 *offp =3D (s32 *) start;
 	u64 ip;
=20
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 054bcd9..7d9b964 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -667,8 +667,8 @@ mem_init (void)
 	 * code can tell them apart.
 	 */
 	for (i =3D 0; i < NR_syscalls; ++i) {
-		extern unsigned long fsyscall_table[NR_syscalls];
 		extern unsigned long sys_call_table[NR_syscalls];
+		unsigned long *fsyscall_table =3D paravirt_get_fsyscall_table();
=20
 		if (!fsyscall_table[i] || nolwsys)
 			fsyscall_table[i] =3D sys_call_table[i] | 1;
--=20
1.6.0.2

