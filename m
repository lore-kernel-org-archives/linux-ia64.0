From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Fri, 23 May 2003 01:09:14 +0000
Subject: Re: [Linux-ia64] offsets.h generation
MIME-Version: 1
Content-Type: multipart/mixed; boundary="yVUBdvd9fx"
Message-Id: <marc-linux-ia64-105590723705992@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705941@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705941@msgid-missing>
To: linux-ia64@vger.kernel.org

--yVUBdvd9fx
Content-Type: text/plain; charset=us-ascii
Content-Description: message body text
Content-Transfer-Encoding: 7bit


David> Is processor.h the only cause of this recursive dependency?  As
David> far as I remember, we don't even need to include offsets.h in
David> processor.h anymore.  It used to be necessary for get_wchan(),
David> but that's now an out-of-line function.

Now there's also a dependency in thread_info.h that unfortunately
can't be worked around, and in ptrace.h


Anyway, here's hopefully the final patch, against the IA64-2.5 BK tree as of
this morning.


--yVUBdvd9fx
Content-Type: text/plain
Content-Disposition: inline;
	filename="p2"
Content-Transfer-Encoding: 7bit

diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-ia64-2.5/arch/ia64/Makefile linux-ia64-2.5-wip/arch/ia64/Makefile
--- linux-ia64-2.5/arch/ia64/Makefile	Fri May 23 09:17:50 2003
+++ linux-ia64-2.5-wip/arch/ia64/Makefile	Fri May 23 10:44:54 2003
@@ -66,7 +66,6 @@
 drivers-$(CONFIG_IA64_GENERIC)	+= arch/ia64/hp/common/ arch/ia64/hp/zx1/ arch/ia64/hp/sim/
 
 boot := arch/ia64/boot
-tools := arch/ia64/tools
 
 .PHONY: boot compressed check
 
@@ -80,17 +79,17 @@
 
 archclean:
 	$(Q)$(MAKE) $(clean)=$(boot)
-	$(Q)$(MAKE) $(clean)=$(tools)
 
 CLEAN_FILES += include/asm-ia64/offsets.h vmlinux.gz bootloader
 
-prepare: include/asm-ia64/offsets.h
+prepare: include/asm-ia64/offsets.h
+
+include/asm-$(ARCH)/offsets.h: arch/$(ARCH)/kernel/asm-offsets.s
+	$(call filechk,gen-asm-offsets)
 
 boot:	lib/lib.a vmlinux
 	$(Q)$(MAKE) $(build)=$(boot) $@
 
-include/asm-ia64/offsets.h:
-	$(Q)$(MAKE) $(build)=$(tools) $@
 
 define archhelp
   echo '  compressed	- Build compressed kernel image'
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-ia64-2.5/arch/ia64/kernel/Makefile linux-ia64-2.5-wip/arch/ia64/kernel/Makefile
--- linux-ia64-2.5/arch/ia64/kernel/Makefile	Fri May 23 09:17:50 2003
+++ linux-ia64-2.5-wip/arch/ia64/kernel/Makefile	Fri May 23 09:43:14 2003
@@ -18,3 +18,11 @@
 obj-$(CONFIG_IOSAPIC)		+= iosapic.o
 obj-$(CONFIG_MODULES)		+= module.o
 obj-$(CONFIG_SMP)		+= smp.o smpboot.o
+
+arch/$(ARCH)/kernel/asm-offsets.s: include/asm-$(ARCH)/.offsets.h.stamp
+
+include/asm-$(ARCH)/.offsets.h.stamp: 
+	[ -s include/asm-$(ARCH)/offsets.h ] || echo "#define IA64_TASK_SIZE 0" > include/asm-$(ARCH)/offsets.h
+	touch $@
+
+CLEAN_FILES += include/asm-ia64/.offsets.h.stamp
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-ia64-2.5/arch/ia64/kernel/asm-offsets.c linux-ia64-2.5-wip/arch/ia64/kernel/asm-offsets.c
--- linux-ia64-2.5/arch/ia64/kernel/asm-offsets.c	Thu Jan  1 10:00:00 1970
+++ linux-ia64-2.5-wip/arch/ia64/kernel/asm-offsets.c	Fri May 23 09:26:15 2003
@@ -0,0 +1,182 @@
+/*
+ * Generate definitions needed by assembly language modules.
+ * This code generates raw asm output which is post-processed
+ * to extract and format the required data.
+ */
+
+#include <linux/config.h>
+
+#include <linux/sched.h>
+
+#include <asm-ia64/processor.h>
+#include <asm-ia64/ptrace.h>
+#include <asm-ia64/siginfo.h>
+#include <asm-ia64/sigcontext.h>
+
+#include "../kernel/sigframe.h"
+
+#define DEFINE(sym, val) \
+        asm volatile("\n->" #sym " %0 " #val : : "i" (val))
+
+#define BLANK() asm volatile("\n->" : : )
+
+void foo(void)
+{
+	DEFINE(IA64_TASK_SIZE, sizeof (struct task_struct));
+	DEFINE(IA64_THREAD_INFO_SIZE, sizeof (struct thread_info));
+	DEFINE(IA64_PT_REGS_SIZE, sizeof (struct pt_regs));
+	DEFINE(IA64_SWITCH_STACK_SIZE, sizeof (struct switch_stack));
+	DEFINE(IA64_SIGINFO_SIZE, sizeof (struct siginfo));
+	DEFINE(IA64_CPU_SIZE, sizeof (struct cpuinfo_ia64));
+	DEFINE(SIGFRAME_SIZE, sizeof (struct sigframe));
+	DEFINE(UNW_FRAME_INFO_SIZE, sizeof (struct unw_frame_info));
+
+	BLANK();
+
+	DEFINE(IA64_TASK_CLEAR_CHILD_TID_OFFSET, offsetof (struct task_struct, clear_child_tid));
+	DEFINE(IA64_TASK_GROUP_LEADER_OFFSET, offsetof (struct task_struct, group_leader));
+	DEFINE(IA64_TASK_PID_OFFSET, offsetof (struct task_struct, pid));
+	DEFINE(IA64_TASK_REAL_PARENT_OFFSET, offsetof (struct task_struct, real_parent));
+	DEFINE(IA64_TASK_TGID_OFFSET, offsetof (struct task_struct, tgid));
+	DEFINE(IA64_TASK_THREAD_KSP_OFFSET, offsetof (struct task_struct, thread.ksp));
+	DEFINE(IA64_TASK_THREAD_ON_USTACK_OFFSET, offsetof (struct task_struct, thread.on_ustack));
+
+	BLANK();
+
+	DEFINE(IA64_PT_REGS_CR_IPSR_OFFSET, offsetof (struct pt_regs, cr_ipsr));
+	DEFINE(IA64_PT_REGS_CR_IIP_OFFSET, offsetof (struct pt_regs, cr_iip));
+	DEFINE(IA64_PT_REGS_CR_IFS_OFFSET, offsetof (struct pt_regs, cr_ifs));
+	DEFINE(IA64_PT_REGS_AR_UNAT_OFFSET, offsetof (struct pt_regs, ar_unat));
+	DEFINE(IA64_PT_REGS_AR_PFS_OFFSET, offsetof (struct pt_regs, ar_pfs));
+	DEFINE(IA64_PT_REGS_AR_RSC_OFFSET, offsetof (struct pt_regs, ar_rsc));
+	DEFINE(IA64_PT_REGS_AR_RNAT_OFFSET, offsetof (struct pt_regs, ar_rnat));
+	DEFINE(IA64_PT_REGS_AR_BSPSTORE_OFFSET, offsetof (struct pt_regs, ar_bspstore));
+	DEFINE(IA64_PT_REGS_PR_OFFSET, offsetof (struct pt_regs, pr));
+	DEFINE(IA64_PT_REGS_B6_OFFSET, offsetof (struct pt_regs, b6));
+	DEFINE(IA64_PT_REGS_LOADRS_OFFSET, offsetof (struct pt_regs, loadrs));
+
+	DEFINE(IA64_PT_REGS_R1_OFFSET, offsetof (struct pt_regs, r1));
+	DEFINE(IA64_PT_REGS_R2_OFFSET, offsetof (struct pt_regs, r2));
+	DEFINE(IA64_PT_REGS_R3_OFFSET, offsetof (struct pt_regs, r3));
+	DEFINE(IA64_PT_REGS_R8_OFFSET, offsetof (struct pt_regs, r8));
+	DEFINE(IA64_PT_REGS_R9_OFFSET, offsetof (struct pt_regs, r9));
+	DEFINE(IA64_PT_REGS_R10_OFFSET, offsetof (struct pt_regs, r10));
+	DEFINE(IA64_PT_REGS_R11_OFFSET, offsetof (struct pt_regs, r11));
+	DEFINE(IA64_PT_REGS_R12_OFFSET, offsetof (struct pt_regs, r12));
+	DEFINE(IA64_PT_REGS_R13_OFFSET, offsetof (struct pt_regs, r13));
+	DEFINE(IA64_PT_REGS_R14_OFFSET, offsetof (struct pt_regs, r14));
+	DEFINE(IA64_PT_REGS_R15_OFFSET, offsetof (struct pt_regs, r15));
+	DEFINE(IA64_PT_REGS_R16_OFFSET, offsetof (struct pt_regs, r16));
+	DEFINE(IA64_PT_REGS_R17_OFFSET, offsetof (struct pt_regs, r17));
+	DEFINE(IA64_PT_REGS_R18_OFFSET, offsetof (struct pt_regs, r18));
+	DEFINE(IA64_PT_REGS_R19_OFFSET, offsetof (struct pt_regs, r19));
+	DEFINE(IA64_PT_REGS_R20_OFFSET, offsetof (struct pt_regs, r20));
+	DEFINE(IA64_PT_REGS_R21_OFFSET, offsetof (struct pt_regs, r21));
+	DEFINE(IA64_PT_REGS_R22_OFFSET, offsetof (struct pt_regs, r22));
+	DEFINE(IA64_PT_REGS_R23_OFFSET, offsetof (struct pt_regs, r23));
+	DEFINE(IA64_PT_REGS_R24_OFFSET, offsetof (struct pt_regs, r24));
+	DEFINE(IA64_PT_REGS_R25_OFFSET, offsetof (struct pt_regs, r25));
+	DEFINE(IA64_PT_REGS_R26_OFFSET, offsetof (struct pt_regs, r26));
+	DEFINE(IA64_PT_REGS_R27_OFFSET, offsetof (struct pt_regs, r27));
+	DEFINE(IA64_PT_REGS_R28_OFFSET, offsetof (struct pt_regs, r28));
+	DEFINE(IA64_PT_REGS_R29_OFFSET, offsetof (struct pt_regs, r29));
+	DEFINE(IA64_PT_REGS_R30_OFFSET, offsetof (struct pt_regs, r30));
+	DEFINE(IA64_PT_REGS_R31_OFFSET, offsetof (struct pt_regs, r31));
+	DEFINE(IA64_PT_REGS_AR_CCV_OFFSET, offsetof (struct pt_regs, ar_ccv));
+	DEFINE(IA64_PT_REGS_AR_FPSR_OFFSET, offsetof (struct pt_regs, ar_fpsr));
+	BLANK();
+	DEFINE(IA64_PT_REGS_B0_OFFSET, offsetof (struct pt_regs, b0));
+	DEFINE(IA64_PT_REGS_B7_OFFSET, offsetof (struct pt_regs, b7));
+	DEFINE(IA64_PT_REGS_F6_OFFSET, offsetof (struct pt_regs, f6));
+	DEFINE(IA64_PT_REGS_F7_OFFSET, offsetof (struct pt_regs, f7));
+	DEFINE(IA64_PT_REGS_F8_OFFSET, offsetof (struct pt_regs, f8));
+	DEFINE(IA64_PT_REGS_F9_OFFSET, offsetof (struct pt_regs, f9));
+
+	BLANK();
+
+	DEFINE(IA64_SWITCH_STACK_CALLER_UNAT_OFFSET, offsetof (struct switch_stack, caller_unat));
+	DEFINE(IA64_SWITCH_STACK_AR_FPSR_OFFSET, offsetof (struct switch_stack, ar_fpsr));
+	DEFINE(IA64_SWITCH_STACK_F2_OFFSET, offsetof (struct switch_stack, f2));
+	DEFINE(IA64_SWITCH_STACK_F3_OFFSET, offsetof (struct switch_stack, f3));
+	DEFINE(IA64_SWITCH_STACK_F4_OFFSET, offsetof (struct switch_stack, f4));
+	DEFINE(IA64_SWITCH_STACK_F5_OFFSET, offsetof (struct switch_stack, f5));
+	DEFINE(IA64_SWITCH_STACK_F10_OFFSET, offsetof (struct switch_stack, f10));
+	DEFINE(IA64_SWITCH_STACK_F11_OFFSET, offsetof (struct switch_stack, f11));
+	DEFINE(IA64_SWITCH_STACK_F12_OFFSET, offsetof (struct switch_stack, f12));
+	DEFINE(IA64_SWITCH_STACK_F13_OFFSET, offsetof (struct switch_stack, f13));
+	DEFINE(IA64_SWITCH_STACK_F14_OFFSET, offsetof (struct switch_stack, f14));
+	DEFINE(IA64_SWITCH_STACK_F15_OFFSET, offsetof (struct switch_stack, f15));
+	DEFINE(IA64_SWITCH_STACK_F16_OFFSET, offsetof (struct switch_stack, f16));
+	DEFINE(IA64_SWITCH_STACK_F17_OFFSET, offsetof (struct switch_stack, f17));
+	DEFINE(IA64_SWITCH_STACK_F18_OFFSET, offsetof (struct switch_stack, f18));
+	DEFINE(IA64_SWITCH_STACK_F19_OFFSET, offsetof (struct switch_stack, f19));
+	DEFINE(IA64_SWITCH_STACK_F20_OFFSET, offsetof (struct switch_stack, f20));
+	DEFINE(IA64_SWITCH_STACK_F21_OFFSET, offsetof (struct switch_stack, f21));
+	DEFINE(IA64_SWITCH_STACK_F22_OFFSET, offsetof (struct switch_stack, f22));
+	DEFINE(IA64_SWITCH_STACK_F23_OFFSET, offsetof (struct switch_stack, f23));
+	DEFINE(IA64_SWITCH_STACK_F24_OFFSET, offsetof (struct switch_stack, f24));
+	DEFINE(IA64_SWITCH_STACK_F25_OFFSET, offsetof (struct switch_stack, f25));
+	DEFINE(IA64_SWITCH_STACK_F26_OFFSET, offsetof (struct switch_stack, f26));
+	DEFINE(IA64_SWITCH_STACK_F27_OFFSET, offsetof (struct switch_stack, f27));
+	DEFINE(IA64_SWITCH_STACK_F28_OFFSET, offsetof (struct switch_stack, f28));
+	DEFINE(IA64_SWITCH_STACK_F29_OFFSET, offsetof (struct switch_stack, f29));
+	DEFINE(IA64_SWITCH_STACK_F30_OFFSET, offsetof (struct switch_stack, f30));
+	DEFINE(IA64_SWITCH_STACK_F31_OFFSET, offsetof (struct switch_stack, f31));
+	DEFINE(IA64_SWITCH_STACK_R4_OFFSET, offsetof (struct switch_stack, r4));
+	DEFINE(IA64_SWITCH_STACK_R5_OFFSET, offsetof (struct switch_stack, r5));
+	DEFINE(IA64_SWITCH_STACK_R6_OFFSET, offsetof (struct switch_stack, r6));
+	DEFINE(IA64_SWITCH_STACK_R7_OFFSET, offsetof (struct switch_stack, r7));
+	DEFINE(IA64_SWITCH_STACK_B0_OFFSET, offsetof (struct switch_stack, b0));
+	DEFINE(IA64_SWITCH_STACK_B1_OFFSET, offsetof (struct switch_stack, b1));
+	DEFINE(IA64_SWITCH_STACK_B2_OFFSET, offsetof (struct switch_stack, b2));
+	DEFINE(IA64_SWITCH_STACK_B3_OFFSET, offsetof (struct switch_stack, b3));
+	DEFINE(IA64_SWITCH_STACK_B4_OFFSET, offsetof (struct switch_stack, b4));
+	DEFINE(IA64_SWITCH_STACK_B5_OFFSET, offsetof (struct switch_stack, b5));
+	DEFINE(IA64_SWITCH_STACK_AR_PFS_OFFSET, offsetof (struct switch_stack, ar_pfs));
+	DEFINE(IA64_SWITCH_STACK_AR_LC_OFFSET, offsetof (struct switch_stack, ar_lc));
+	DEFINE(IA64_SWITCH_STACK_AR_UNAT_OFFSET, offsetof (struct switch_stack, ar_unat));
+	DEFINE(IA64_SWITCH_STACK_AR_RNAT_OFFSET, offsetof (struct switch_stack, ar_rnat));
+	DEFINE(IA64_SWITCH_STACK_AR_BSPSTORE_OFFSET, offsetof (struct switch_stack, ar_bspstore));
+	DEFINE(IA64_SWITCH_STACK_PR_OFFSET, offsetof (struct switch_stack, pr));
+	BLANK();
+	DEFINE(IA64_SIGCONTEXT_IP_OFFSET, offsetof (struct sigcontext, sc_ip));
+	DEFINE(IA64_SIGCONTEXT_AR_BSP_OFFSET, offsetof (struct sigcontext, sc_ar_bsp));
+	DEFINE(IA64_SIGCONTEXT_AR_FPSR_OFFSET, offsetof (struct sigcontext, sc_ar_fpsr));
+	DEFINE(IA64_SIGCONTEXT_AR_RNAT_OFFSET, offsetof (struct sigcontext, sc_ar_rnat));
+	DEFINE(IA64_SIGCONTEXT_AR_UNAT_OFFSET, offsetof (struct sigcontext, sc_ar_unat));
+	DEFINE(IA64_SIGCONTEXT_B0_OFFSET, offsetof (struct sigcontext, sc_br[0]));
+	DEFINE(IA64_SIGCONTEXT_CFM_OFFSET, offsetof (struct sigcontext, sc_cfm));
+	DEFINE(IA64_SIGCONTEXT_FLAGS_OFFSET, offsetof (struct sigcontext, sc_flags));
+	DEFINE(IA64_SIGCONTEXT_FR6_OFFSET, offsetof (struct sigcontext, sc_fr[6]));
+	DEFINE(IA64_SIGCONTEXT_PR_OFFSET, offsetof (struct sigcontext, sc_pr));
+	DEFINE(IA64_SIGCONTEXT_R12_OFFSET, offsetof (struct sigcontext, sc_gr[12]));
+	DEFINE(IA64_SIGCONTEXT_RBS_BASE_OFFSET, offsetof (struct sigcontext, sc_rbs_base));
+	DEFINE(IA64_SIGCONTEXT_LOADRS_OFFSET, offsetof (struct sigcontext, sc_loadrs));
+	BLANK();
+	DEFINE(IA64_SIGFRAME_ARG0_OFFSET, offsetof (struct sigframe, arg0));
+	DEFINE(IA64_SIGFRAME_ARG1_OFFSET, offsetof (struct sigframe, arg1));
+	DEFINE(IA64_SIGFRAME_ARG2_OFFSET, offsetof (struct sigframe, arg2));
+	DEFINE(IA64_SIGFRAME_HANDLER_OFFSET, offsetof (struct sigframe, handler));
+	DEFINE(IA64_SIGFRAME_SIGCONTEXT_OFFSET, offsetof (struct sigframe, sc));
+    /* for assembly files which can't include sched.h: */
+	BLANK();
+	DEFINE(IA64_CLONE_VFORK, CLONE_VFORK);
+	DEFINE(IA64_CLONE_VM, CLONE_VM);
+	BLANK();
+    /* used by fsys_gettimeofday in arch/ia64/kernel/fsys.S */
+	DEFINE(IA64_CPUINFO_ITM_DELTA_OFFSET, offsetof (struct cpuinfo_ia64, itm_delta));
+	DEFINE(IA64_CPUINFO_ITM_NEXT_OFFSET, offsetof (struct cpuinfo_ia64, itm_next));
+	DEFINE(IA64_CPUINFO_NSEC_PER_CYC_OFFSET, offsetof (struct cpuinfo_ia64, nsec_per_cyc));
+	DEFINE(IA64_TIMESPEC_TV_NSEC_OFFSET, offsetof (struct timespec, tv_nsec));
+
+	DEFINE(CLONE_IDLETASK_BIT, 12);
+#if CLONE_IDLETASK != (1 << 12)
+# error "CLONE_IDLETASK_BIT incorrect, please fix"
+#endif
+
+	DEFINE(CLONE_SETTLS_BIT, 19);
+#if CLONE_SETTLS != (1<<19)
+# error "CLONE_SETTLS_BIT incorrect, please fix"
+#endif
+
+}
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-ia64-2.5/arch/ia64/tools/Makefile linux-ia64-2.5-wip/arch/ia64/tools/Makefile
--- linux-ia64-2.5/arch/ia64/tools/Makefile	Fri May 23 09:17:50 2003
+++ linux-ia64-2.5-wip/arch/ia64/tools/Makefile	Thu Jan  1 10:00:00 1970
@@ -1,51 +0,0 @@
-CFLAGS	= -g -O2 -Wall $(CPPFLAGS)
-
-TARGET	= include/asm-ia64/offsets.h
-
-src = $(obj)
-
-clean-files := print_offsets.s print_offsets offsets.h
-
-$(TARGET): $(obj)/offsets.h
-	@if ! cmp -s $(obj)/offsets.h ${TARGET}; then	\
-		echo -e "*** Updating ${TARGET}...";	\
-		cp $(obj)/offsets.h ${TARGET};		\
-	else						\
-		echo "*** ${TARGET} is up to date";	\
-	fi
-
-#
-# If we're cross-compiling, we use the cross-compiler to translate
-# print_offsets.c into an assembly file and then awk to translate this
-# file into offsets.h.  This avoids having to use a simulator to
-# generate this file.  This is based on an idea suggested by Asit
-# Mallick.  If we're running natively, we can of course just build
-# print_offsets and run it. --davidm
-#
-
-ifeq ($(CROSS_COMPILE),)
-
-$(obj)/offsets.h: $(obj)/print_offsets
-	$(obj)/print_offsets > $(obj)/offsets.h
-
-comma	:= ,
-
-$(obj)/print_offsets: $(src)/print_offsets.c FORCE
-	[ -r $(TARGET) ] || echo "#define IA64_TASK_SIZE 0" > $(TARGET)
-	$(CC) $(CFLAGS) -DKBUILD_BASENAME=$(subst $(comma),_,$(subst -,_,$(*F))) \
-		$(src)/print_offsets.c -o $@
-
-FORCE:
-
-else
-
-$(obj)/offsets.h: $(obj)/print_offsets.s
-	$(AWK) -f $(src)/print_offsets.awk $^ > $@
-
-$(obj)/print_offsets.s: $(src)/print_offsets.c
-	[ -r $(TARGET) ] || echo "#define IA64_TASK_SIZE 0" > $(TARGET)
-	$(CC) $(CFLAGS) -DKBUILD_BASENAME=$(subst $(comma),_,$(subst -,_,$(*F))) -S $^ -o $@
-
-endif
-
-.PHONY: all modules modules_install
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-ia64-2.5/arch/ia64/tools/print_offsets.awk linux-ia64-2.5-wip/arch/ia64/tools/print_offsets.awk
--- linux-ia64-2.5/arch/ia64/tools/print_offsets.awk	Fri May 23 09:17:50 2003
+++ linux-ia64-2.5-wip/arch/ia64/tools/print_offsets.awk	Thu Jan  1 10:00:00 1970
@@ -1,72 +0,0 @@
-BEGIN {
-	print "#ifndef _ASM_IA64_OFFSETS_H"
-	print "#define _ASM_IA64_OFFSETS_H"
-	print "/*"
-	print " * DO NOT MODIFY"
-	print " *"
-	print " * This file was generated by arch/ia64/tools/print_offsets.awk."
-	print " *"
-	print " */"
-	print ""
-	print "#define CLONE_IDLETASK_BIT	12"
-	print "#define CLONE_SETTLS_BIT	19"
-}
-
-# look for .tab:
-#	stringz "name"
-#	data value
-# sequence
-
-/.*[.]size/ {
-	inside_table = 0
-}
-
-/\/\/ end/ {
-	inside_table = 0
-}
-
-/.*[.]rodata/ {
-	inside_table = 0
-}
-
-{
-	if (inside_table) {
-		if ($1 == "//") getline;
-		name=$2
-		getline
-		getline
-		if ($1 == "//") getline;
-		value=$2
-		len = length(name)
-		name = substr(name, 2, len - 2)
-		len -= 2
-		if (len == 0)
-			print ""
-		else {
-			len += 8
-			if (len >= 40) {
-				space=" "
-			} else {
-				space=""
-				while (len < 40) {
-					len += 8
-					space = space"\t"
-				}
-			}
-			printf("#define %s%s%lu\t/* 0x%lx */\n", name, space, value, value)
-		}
-	}
-}
-
-/tab:/ {
-	inside_table = 1
-}
-
-/tab\#:/ {
-	inside_table = 1
-}
-
-END {
-	print ""
-	print "#endif /* _ASM_IA64_OFFSETS_H */"
-}
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-ia64-2.5/arch/ia64/tools/print_offsets.c linux-ia64-2.5-wip/arch/ia64/tools/print_offsets.c
--- linux-ia64-2.5/arch/ia64/tools/print_offsets.c	Fri May 23 09:17:50 2003
+++ linux-ia64-2.5-wip/arch/ia64/tools/print_offsets.c	Thu Jan  1 10:00:00 1970
@@ -1,220 +0,0 @@
-/*
- * Utility to generate asm-ia64/offsets.h.
- *
- * Copyright (C) 1999-2003 Hewlett-Packard Co
- *	David Mosberger-Tang <davidm@hpl.hp.com>
- *
- * Note that this file has dual use: when building the kernel
- * natively, the file is translated into a binary and executed.  When
- * building the kernel in a cross-development environment, this file
- * gets translated into an assembly file which, in turn, is processed
- * by awk to generate offsets.h.  So if you make any changes to this
- * file, be sure to verify that the awk procedure still works (see
- * print_offsets.awk).
- */
-#include <linux/config.h>
-
-#include <linux/sched.h>
-
-#include <asm-ia64/processor.h>
-#include <asm-ia64/ptrace.h>
-#include <asm-ia64/siginfo.h>
-#include <asm-ia64/sigcontext.h>
-
-#include "../kernel/sigframe.h"
-
-#ifdef offsetof
-# undef offsetof
-#endif
-
-/*
- * We _can't_ include the host's standard header file, as those are in
- *  potential conflict with the what the Linux kernel declares for the
- *  target system.
- */
-extern int printf (const char *, ...);
-
-#define offsetof(type,field)	((char *) &((type *) 0)->field - (char *) 0)
-
-struct
-  {
-    const char name[256];
-    unsigned long value;
-  }
-tab[] =
-  {
-    { "IA64_TASK_SIZE",			sizeof (struct task_struct) },
-    { "IA64_THREAD_INFO_SIZE",		sizeof (struct thread_info) },
-    { "IA64_PT_REGS_SIZE",		sizeof (struct pt_regs) },
-    { "IA64_SWITCH_STACK_SIZE",		sizeof (struct switch_stack) },
-    { "IA64_SIGINFO_SIZE",		sizeof (struct siginfo) },
-    { "IA64_CPU_SIZE",			sizeof (struct cpuinfo_ia64) },
-    { "SIGFRAME_SIZE",			sizeof (struct sigframe) },
-    { "UNW_FRAME_INFO_SIZE",		sizeof (struct unw_frame_info) },
-    { "", 0 },			/* spacer */
-    { "IA64_TASK_CLEAR_CHILD_TID_OFFSET",offsetof (struct task_struct, clear_child_tid) },
-    { "IA64_TASK_GROUP_LEADER_OFFSET",	offsetof (struct task_struct, group_leader) },
-    { "IA64_TASK_PID_OFFSET",		offsetof (struct task_struct, pid) },
-    { "IA64_TASK_REAL_PARENT_OFFSET",	offsetof (struct task_struct, real_parent) },
-    { "IA64_TASK_TGID_OFFSET",		offsetof (struct task_struct, tgid) },
-    { "IA64_TASK_THREAD_KSP_OFFSET",	offsetof (struct task_struct, thread.ksp) },
-    { "IA64_TASK_THREAD_ON_USTACK_OFFSET", offsetof (struct task_struct, thread.on_ustack) },
-    { "IA64_PT_REGS_CR_IPSR_OFFSET",	offsetof (struct pt_regs, cr_ipsr) },
-    { "IA64_PT_REGS_CR_IIP_OFFSET",	offsetof (struct pt_regs, cr_iip) },
-    { "IA64_PT_REGS_CR_IFS_OFFSET",	offsetof (struct pt_regs, cr_ifs) },
-    { "IA64_PT_REGS_AR_UNAT_OFFSET",	offsetof (struct pt_regs, ar_unat) },
-    { "IA64_PT_REGS_AR_PFS_OFFSET",	offsetof (struct pt_regs, ar_pfs) },
-    { "IA64_PT_REGS_AR_RSC_OFFSET",	offsetof (struct pt_regs, ar_rsc) },
-    { "IA64_PT_REGS_AR_RNAT_OFFSET",	offsetof (struct pt_regs, ar_rnat) },
-    { "IA64_PT_REGS_AR_BSPSTORE_OFFSET",offsetof (struct pt_regs, ar_bspstore) },
-    { "IA64_PT_REGS_PR_OFFSET",		offsetof (struct pt_regs, pr) },
-    { "IA64_PT_REGS_B6_OFFSET",		offsetof (struct pt_regs, b6) },
-    { "IA64_PT_REGS_LOADRS_OFFSET",	offsetof (struct pt_regs, loadrs) },
-    { "IA64_PT_REGS_R1_OFFSET",		offsetof (struct pt_regs, r1) },
-    { "IA64_PT_REGS_R2_OFFSET",		offsetof (struct pt_regs, r2) },
-    { "IA64_PT_REGS_R3_OFFSET",		offsetof (struct pt_regs, r3) },
-    { "IA64_PT_REGS_R12_OFFSET",	offsetof (struct pt_regs, r12) },
-    { "IA64_PT_REGS_R13_OFFSET",	offsetof (struct pt_regs, r13) },
-    { "IA64_PT_REGS_R14_OFFSET",	offsetof (struct pt_regs, r14) },
-    { "IA64_PT_REGS_R15_OFFSET",	offsetof (struct pt_regs, r15) },
-    { "IA64_PT_REGS_R8_OFFSET",		offsetof (struct pt_regs, r8) },
-    { "IA64_PT_REGS_R9_OFFSET",		offsetof (struct pt_regs, r9) },
-    { "IA64_PT_REGS_R10_OFFSET",	offsetof (struct pt_regs, r10) },
-    { "IA64_PT_REGS_R11_OFFSET",	offsetof (struct pt_regs, r11) },
-    { "IA64_PT_REGS_R16_OFFSET",	offsetof (struct pt_regs, r16) },
-    { "IA64_PT_REGS_R17_OFFSET",	offsetof (struct pt_regs, r17) },
-    { "IA64_PT_REGS_R18_OFFSET",	offsetof (struct pt_regs, r18) },
-    { "IA64_PT_REGS_R19_OFFSET",	offsetof (struct pt_regs, r19) },
-    { "IA64_PT_REGS_R20_OFFSET",	offsetof (struct pt_regs, r20) },
-    { "IA64_PT_REGS_R21_OFFSET",	offsetof (struct pt_regs, r21) },
-    { "IA64_PT_REGS_R22_OFFSET",	offsetof (struct pt_regs, r22) },
-    { "IA64_PT_REGS_R23_OFFSET",	offsetof (struct pt_regs, r23) },
-    { "IA64_PT_REGS_R24_OFFSET",	offsetof (struct pt_regs, r24) },
-    { "IA64_PT_REGS_R25_OFFSET",	offsetof (struct pt_regs, r25) },
-    { "IA64_PT_REGS_R26_OFFSET",	offsetof (struct pt_regs, r26) },
-    { "IA64_PT_REGS_R27_OFFSET",	offsetof (struct pt_regs, r27) },
-    { "IA64_PT_REGS_R28_OFFSET",	offsetof (struct pt_regs, r28) },
-    { "IA64_PT_REGS_R29_OFFSET",	offsetof (struct pt_regs, r29) },
-    { "IA64_PT_REGS_R30_OFFSET",	offsetof (struct pt_regs, r30) },
-    { "IA64_PT_REGS_R31_OFFSET",	offsetof (struct pt_regs, r31) },
-    { "IA64_PT_REGS_AR_CCV_OFFSET",	offsetof (struct pt_regs, ar_ccv) },
-    { "IA64_PT_REGS_AR_FPSR_OFFSET",	offsetof (struct pt_regs, ar_fpsr) },
-    { "IA64_PT_REGS_B0_OFFSET",		offsetof (struct pt_regs, b0) },
-    { "IA64_PT_REGS_B7_OFFSET",		offsetof (struct pt_regs, b7) },
-    { "IA64_PT_REGS_F6_OFFSET",		offsetof (struct pt_regs, f6) },
-    { "IA64_PT_REGS_F7_OFFSET",		offsetof (struct pt_regs, f7) },
-    { "IA64_PT_REGS_F8_OFFSET",		offsetof (struct pt_regs, f8) },
-    { "IA64_PT_REGS_F9_OFFSET",		offsetof (struct pt_regs, f9) },
-    { "IA64_SWITCH_STACK_CALLER_UNAT_OFFSET",	offsetof (struct switch_stack, caller_unat) },
-    { "IA64_SWITCH_STACK_AR_FPSR_OFFSET",	offsetof (struct switch_stack, ar_fpsr) },
-    { "IA64_SWITCH_STACK_F2_OFFSET",		offsetof (struct switch_stack, f2) },
-    { "IA64_SWITCH_STACK_F3_OFFSET",		offsetof (struct switch_stack, f3) },
-    { "IA64_SWITCH_STACK_F4_OFFSET",		offsetof (struct switch_stack, f4) },
-    { "IA64_SWITCH_STACK_F5_OFFSET",		offsetof (struct switch_stack, f5) },
-    { "IA64_SWITCH_STACK_F10_OFFSET",		offsetof (struct switch_stack, f10) },
-    { "IA64_SWITCH_STACK_F11_OFFSET",		offsetof (struct switch_stack, f11) },
-    { "IA64_SWITCH_STACK_F12_OFFSET",		offsetof (struct switch_stack, f12) },
-    { "IA64_SWITCH_STACK_F13_OFFSET",		offsetof (struct switch_stack, f13) },
-    { "IA64_SWITCH_STACK_F14_OFFSET",		offsetof (struct switch_stack, f14) },
-    { "IA64_SWITCH_STACK_F15_OFFSET",		offsetof (struct switch_stack, f15) },
-    { "IA64_SWITCH_STACK_F16_OFFSET",		offsetof (struct switch_stack, f16) },
-    { "IA64_SWITCH_STACK_F17_OFFSET",		offsetof (struct switch_stack, f17) },
-    { "IA64_SWITCH_STACK_F18_OFFSET",		offsetof (struct switch_stack, f18) },
-    { "IA64_SWITCH_STACK_F19_OFFSET",		offsetof (struct switch_stack, f19) },
-    { "IA64_SWITCH_STACK_F20_OFFSET",		offsetof (struct switch_stack, f20) },
-    { "IA64_SWITCH_STACK_F21_OFFSET",		offsetof (struct switch_stack, f21) },
-    { "IA64_SWITCH_STACK_F22_OFFSET",		offsetof (struct switch_stack, f22) },
-    { "IA64_SWITCH_STACK_F23_OFFSET",		offsetof (struct switch_stack, f23) },
-    { "IA64_SWITCH_STACK_F24_OFFSET",		offsetof (struct switch_stack, f24) },
-    { "IA64_SWITCH_STACK_F25_OFFSET",		offsetof (struct switch_stack, f25) },
-    { "IA64_SWITCH_STACK_F26_OFFSET",		offsetof (struct switch_stack, f26) },
-    { "IA64_SWITCH_STACK_F27_OFFSET",		offsetof (struct switch_stack, f27) },
-    { "IA64_SWITCH_STACK_F28_OFFSET",		offsetof (struct switch_stack, f28) },
-    { "IA64_SWITCH_STACK_F29_OFFSET",		offsetof (struct switch_stack, f29) },
-    { "IA64_SWITCH_STACK_F30_OFFSET",		offsetof (struct switch_stack, f30) },
-    { "IA64_SWITCH_STACK_F31_OFFSET",		offsetof (struct switch_stack, f31) },
-    { "IA64_SWITCH_STACK_R4_OFFSET",		offsetof (struct switch_stack, r4) },
-    { "IA64_SWITCH_STACK_R5_OFFSET",		offsetof (struct switch_stack, r5) },
-    { "IA64_SWITCH_STACK_R6_OFFSET",		offsetof (struct switch_stack, r6) },
-    { "IA64_SWITCH_STACK_R7_OFFSET",		offsetof (struct switch_stack, r7) },
-    { "IA64_SWITCH_STACK_B0_OFFSET",		offsetof (struct switch_stack, b0) },
-    { "IA64_SWITCH_STACK_B1_OFFSET",		offsetof (struct switch_stack, b1) },
-    { "IA64_SWITCH_STACK_B2_OFFSET",		offsetof (struct switch_stack, b2) },
-    { "IA64_SWITCH_STACK_B3_OFFSET",		offsetof (struct switch_stack, b3) },
-    { "IA64_SWITCH_STACK_B4_OFFSET",		offsetof (struct switch_stack, b4) },
-    { "IA64_SWITCH_STACK_B5_OFFSET",		offsetof (struct switch_stack, b5) },
-    { "IA64_SWITCH_STACK_AR_PFS_OFFSET",	offsetof (struct switch_stack, ar_pfs) },
-    { "IA64_SWITCH_STACK_AR_LC_OFFSET",		offsetof (struct switch_stack, ar_lc) },
-    { "IA64_SWITCH_STACK_AR_UNAT_OFFSET",	offsetof (struct switch_stack, ar_unat) },
-    { "IA64_SWITCH_STACK_AR_RNAT_OFFSET",	offsetof (struct switch_stack, ar_rnat) },
-    { "IA64_SWITCH_STACK_AR_BSPSTORE_OFFSET",	offsetof (struct switch_stack, ar_bspstore) },
-    { "IA64_SWITCH_STACK_PR_OFFSET",	offsetof (struct switch_stack, pr) },
-    { "IA64_SIGCONTEXT_IP_OFFSET",	offsetof (struct sigcontext, sc_ip) },
-    { "IA64_SIGCONTEXT_AR_BSP_OFFSET",	offsetof (struct sigcontext, sc_ar_bsp) },
-    { "IA64_SIGCONTEXT_AR_FPSR_OFFSET", offsetof (struct sigcontext, sc_ar_fpsr) },
-    { "IA64_SIGCONTEXT_AR_RNAT_OFFSET",	offsetof (struct sigcontext, sc_ar_rnat) },
-    { "IA64_SIGCONTEXT_AR_UNAT_OFFSET", offsetof (struct sigcontext, sc_ar_unat) },
-    { "IA64_SIGCONTEXT_B0_OFFSET",	offsetof (struct sigcontext, sc_br[0]) },
-    { "IA64_SIGCONTEXT_CFM_OFFSET",	offsetof (struct sigcontext, sc_cfm) },
-    { "IA64_SIGCONTEXT_FLAGS_OFFSET",	offsetof (struct sigcontext, sc_flags) },
-    { "IA64_SIGCONTEXT_FR6_OFFSET",	offsetof (struct sigcontext, sc_fr[6]) },
-    { "IA64_SIGCONTEXT_PR_OFFSET",	offsetof (struct sigcontext, sc_pr) },
-    { "IA64_SIGCONTEXT_R12_OFFSET",	offsetof (struct sigcontext, sc_gr[12]) },
-    { "IA64_SIGCONTEXT_RBS_BASE_OFFSET",offsetof (struct sigcontext, sc_rbs_base) },
-    { "IA64_SIGCONTEXT_LOADRS_OFFSET",	offsetof (struct sigcontext, sc_loadrs) },
-    { "IA64_SIGFRAME_ARG0_OFFSET",		offsetof (struct sigframe, arg0) },
-    { "IA64_SIGFRAME_ARG1_OFFSET",		offsetof (struct sigframe, arg1) },
-    { "IA64_SIGFRAME_ARG2_OFFSET",		offsetof (struct sigframe, arg2) },
-    { "IA64_SIGFRAME_HANDLER_OFFSET",		offsetof (struct sigframe, handler) },
-    { "IA64_SIGFRAME_SIGCONTEXT_OFFSET",	offsetof (struct sigframe, sc) },
-    /* for assembly files which can't include sched.h: */
-    { "IA64_CLONE_VFORK",		CLONE_VFORK },
-    { "IA64_CLONE_VM",			CLONE_VM },
-    /* used by fsys_gettimeofday in arch/ia64/kernel/fsys.S */
-    { "IA64_CPUINFO_ITM_DELTA_OFFSET", 		offsetof (struct cpuinfo_ia64, itm_delta) },
-    { "IA64_CPUINFO_ITM_NEXT_OFFSET", 		offsetof (struct cpuinfo_ia64, itm_next) },
-    { "IA64_CPUINFO_NSEC_PER_CYC_OFFSET",	offsetof (struct cpuinfo_ia64, nsec_per_cyc) },
-    { "IA64_TIMESPEC_TV_NSEC_OFFSET", 		offsetof (struct timespec, tv_nsec) },
-
-};
-
-static const char *tabs = "\t\t\t\t\t\t\t\t\t\t";
-
-int
-main (int argc, char **argv)
-{
-  const char *space;
-  int i, num_tabs;
-  size_t len;
-
-  printf ("#ifndef _ASM_IA64_OFFSETS_H\n");
-  printf ("#define _ASM_IA64_OFFSETS_H\n\n");
-
-  printf ("/*\n * DO NOT MODIFY\n *\n * This file was generated by "
-	  "arch/ia64/tools/print_offsets.\n *\n */\n\n");
-
-  for (i = 0; i < (int) (sizeof (tab) / sizeof (tab[0])); ++i)
-    {
-      if (tab[i].name[0] == '\0')
-	printf ("\n");
-      else
-	{
-	  len = strlen (tab[i].name);
-
-	  num_tabs = (40 - len) / 8;
-	  if (num_tabs <= 0)
-	    space = " ";
-	  else
-	    space = strchr(tabs, '\0') - (40 - len) / 8;
-
-	  printf ("#define %s%s%lu\t/* 0x%lx */\n",
-		  tab[i].name, space, tab[i].value, tab[i].value);
-	}
-    }
-
-  printf ("\n#define CLONE_IDLETASK_BIT	%ld\n", ia64_fls (CLONE_IDLETASK));
-  printf ("\n#define CLONE_SETTLS_BIT	%ld\n", ia64_fls (CLONE_SETTLS));
-
-  printf ("\n#endif /* _ASM_IA64_OFFSETS_H */\n");
-  return 0;
-}

--yVUBdvd9fx--

