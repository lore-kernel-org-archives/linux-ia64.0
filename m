From: Keith Owens <kaos@ocs.com.au>
Date: Sat, 28 Apr 2001 02:49:29 +0000
Subject: [Linux-ia64] Cleanup include/asm-ia64/offsets.h
Message-Id: <marc-linux-ia64-105590693005486@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Content-Type: text/plain; charset=us-ascii

include/asm-ia64/offsets.h is causing problems for source control
systems and patches.  Because it is shipped as part of the ia64 tree
and then overwritten wth values that are based on the local config it
generates spurious changes.

There is also the problem of when offsets.h gets updated.  At the
moment it only gets updated by make dep so changes to structures or
config options which affect the offsets are not automatically detected.
Change a config option, forget to run make dep and you get an
inconsistent kernel.

As part of my makefile rewrite for 2.5 I am cleaning up problems like
this.  The patch below deletes include/asm-ia64/offsets.h from the
shipped tree, restricts its use to assembler code only and makes sure
that assembler code always gets the latest offset values.  C code is
not a problem, the dependency system handles structure and config
changes for C code.

If you have a "don't diff" list, add include/asm-ia64/offsets.h,
include/asm/offsets.h and arch/ia64/tools/offsets.h to that list after
applying this patch.

Against 2.4.3-ia64-010405.

Index: 3.20/include/asm-ia64/processor.h
- --- 3.20/include/asm-ia64/processor.h Tue, 24 Apr 2001 11:02:09 +1000 kaos (linux-2.4/s/49_processor. 1.1.5.1 644)
+++ 3.20(w)/include/asm-ia64/processor.h Sat, 28 Apr 2001 12:29:37 +1000 kaos (linux-2.4/s/49_processor. 1.1.5.1 644)
@@ -187,7 +187,6 @@
 #include <linux/threads.h>
 
 #include <asm/fpu.h>
- -#include <asm/offsets.h>
 #include <asm/page.h>
 #include <asm/rse.h>
 #include <asm/unwind.h>
@@ -787,7 +786,11 @@ thread_saved_pc (struct thread_struct *t
 	unsigned long ip;
 
 	/* XXX ouch: Linus, please pass the task pointer to thread_saved_pc() instead! */
- -	struct task_struct *p = (void *) ((unsigned long) t - IA64_TASK_THREAD_OFFSET);
+	/* When thread_saved_pc() gets the task pointer instead, delete
+	 * ia64_task_thread_offset below and in arch/ia64/kernel/process.c. KAO
+	 */
+	extern const long ia64_task_thread_offset;
+	struct task_struct *p = (void *) ((unsigned long) t - ia64_task_thread_offset);
 
 	unw_init_from_blocked_task(&info, p);
 	if (unw_unwind(&info) < 0)
Index: 3.20/include/asm-ia64/ptrace.h
- --- 3.20/include/asm-ia64/ptrace.h Tue, 24 Apr 2001 11:02:09 +1000 kaos (linux-2.4/t/4_ptrace.h 1.1.4.1 644)
+++ 3.20(w)/include/asm-ia64/ptrace.h Sat, 28 Apr 2001 12:29:37 +1000 kaos (linux-2.4/t/4_ptrace.h 1.1.4.1 644)
@@ -51,7 +51,6 @@
 #include <linux/config.h>
 
 #include <asm/fpu.h>
- -#include <asm/offsets.h>
 
 /*
  * Base-2 logarithm of number of pages to allocate per task structure
@@ -67,7 +66,8 @@
 # define IA64_TASK_STRUCT_LOG_NUM_PAGES		0
 #endif
 
- -#define IA64_RBS_OFFSET			((IA64_TASK_SIZE + 15) & ~15)
+#define IA64_RBS_OFFSET			((IA64_TASK_SIZE + 15) & ~15)			/* .S */
+#define ia64_rbs_offset			((sizeof (struct task_struct) + 15) & ~15)	/* .c */
 #define IA64_STK_OFFSET			((1 << IA64_TASK_STRUCT_LOG_NUM_PAGES)*PAGE_SIZE)
 
 #define INIT_TASK_SIZE			IA64_STK_OFFSET
Index: 3.20/arch/ia64/tools/Makefile
- --- 3.20/arch/ia64/tools/Makefile Fri, 05 Jan 2001 13:42:29 +1100 kaos (linux-2.4/q/c/1_Makefile 1.1 644)
+++ 3.20(w)/arch/ia64/tools/Makefile Sat, 28 Apr 2001 12:13:49 +1000 kaos (linux-2.4/q/c/1_Makefile 1.1 644)
@@ -2,14 +2,7 @@ CFLAGS	= -g -O2 -Wall $(CPPFLAGS)
 
 TARGET	= $(TOPDIR)/include/asm-ia64/offsets.h
 
- -all: 
- -
- -mrproper:
- -
- -clean:
- -	rm -f print_offsets.s print_offsets offsets.h
- -
- -fastdep: offsets.h
+all: offsets.h
 	@if ! cmp -s offsets.h ${TARGET}; then	\
 		echo -e "*** Updating ${TARGET}...";	\
 		cp offsets.h ${TARGET};		\
@@ -17,6 +10,12 @@ fastdep: offsets.h
 		echo "*** ${TARGET} is up to date";	\
 	fi
 
+clean:
+	rm -f print_offsets.s print_offsets offsets.h .tmp_*
+
+mrproper: clean
+	rm -f $(TARGET)
+
 #
 # If we're cross-compiling, we use the cross-compiler to translate
 # print_offsets.c into an assembly file and then awk to translate this
@@ -26,24 +25,30 @@ fastdep: offsets.h
 # print_offsets and run it. --davidm
 #
 
+#
+# The offsets depend on several include files which depend on other include
+# files and config options.  Instead of trying to list the full dependency chain
+# (which will be obsolete tomorrow), always make offsets.h and it compare with
+# the current version.  This Makefile is only invoked from arch/ia64/kernel and
+# arch/ia64/ia32 so the overhead of making offsets.h each time is minimal.  KAO
+#
+
 ifeq ($(CROSS_COMPILE),)
 
 offsets.h: print_offsets
- -	./print_offsets > offsets.h
+	./print_offsets > .tmp_offsets.h_$$$$ && mv .tmp_offsets.h_$$$$ $@
 
- -print_offsets: print_offsets.c FORCE_RECOMPILE
+print_offsets: FORCE_BUILD
 	$(CC) $(CFLAGS) print_offsets.c -o $@
 
- -FORCE_RECOMPILE:
- -
 else
 
 offsets.h: print_offsets.s
- -	$(AWK) -f print_offsets.awk $^ > $@
+	$(AWK) -f print_offsets.awk $^ > .tmp_offsets.h_$$$$ && mv .tmp_offsets.h_$$$$ $@
 
- -print_offsets.s: print_offsets.c
+print_offsets.s: FORCE_BUILD
 	$(CC) $(CFLAGS) -S print_offsets.c -o $@
 
 endif
 
- -.PHONY: all modules modules_install
+.PHONY: all modules modules_install fastdep FORCE_BUILD
Index: 3.20/arch/ia64/kernel/unaligned.c
- --- 3.20/arch/ia64/kernel/unaligned.c Tue, 24 Apr 2001 11:02:09 +1000 kaos (linux-2.4/r/c/40_unaligned. 1.1.5.1 644)
+++ 3.20(w)/arch/ia64/kernel/unaligned.c Sat, 28 Apr 2001 11:32:13 +1000 kaos (linux-2.4/r/c/40_unaligned. 1.1.5.1 644)
@@ -278,7 +278,7 @@ set_rse_reg (struct pt_regs *regs, unsig
 {
 	struct switch_stack *sw = (struct switch_stack *) regs - 1;
 	unsigned long *bsp, *bspstore, *addr, *rnat_addr, *ubs_end;
- -	unsigned long *kbs = (void *) current + IA64_RBS_OFFSET;
+	unsigned long *kbs = (void *) current + ia64_rbs_offset;
 	unsigned long rnats, nat_mask;
 	unsigned long on_kbs;
 	long sof = (regs->cr_ifs) & 0x7f;
@@ -349,7 +349,7 @@ get_rse_reg (struct pt_regs *regs, unsig
 {
 	struct switch_stack *sw = (struct switch_stack *) regs - 1;
 	unsigned long *bsp, *addr, *rnat_addr, *ubs_end, *bspstore;
- -	unsigned long *kbs = (void *) current + IA64_RBS_OFFSET;
+	unsigned long *kbs = (void *) current + ia64_rbs_offset;
 	unsigned long rnats, nat_mask;
 	unsigned long on_kbs;
 	long sof = (regs->cr_ifs) & 0x7f;
Index: 3.20/arch/ia64/kernel/unwind.c
- --- 3.20/arch/ia64/kernel/unwind.c Tue, 24 Apr 2001 11:02:09 +1000 kaos (linux-2.4/r/c/42_unwind.c 1.1.2.1.3.1 644)
+++ 3.20(w)/arch/ia64/kernel/unwind.c Sat, 28 Apr 2001 11:43:05 +1000 kaos (linux-2.4/r/c/42_unwind.c 1.1.2.1.3.1 644)
@@ -1800,7 +1800,7 @@ unw_init_frame_info (struct unw_frame_in
 	 */
 	memset(info, 0, sizeof(*info));
 
- -	rbslimit = (unsigned long) t + IA64_RBS_OFFSET;
+	rbslimit = (unsigned long) t + ia64_rbs_offset;
 	rbstop   = sw->ar_bspstore;
 	if (rbstop - (unsigned long) t >= IA64_STK_OFFSET)
 		rbstop = rbslimit;
@@ -1946,21 +1946,21 @@ unw_init (void)
 	if (8*sizeof(unw_hash_index_t) < UNW_LOG_HASH_SIZE)
 		unw_hash_index_t_is_too_narrow();
 
- -	unw.sw_off[unw.preg_index[UNW_REG_PRI_UNAT_GR]] = SW(AR_UNAT);
- -	unw.sw_off[unw.preg_index[UNW_REG_BSPSTORE]] = SW(AR_BSPSTORE);
- -	unw.sw_off[unw.preg_index[UNW_REG_PFS]] = SW(AR_UNAT);
- -	unw.sw_off[unw.preg_index[UNW_REG_RP]] = SW(B0);
- -	unw.sw_off[unw.preg_index[UNW_REG_UNAT]] = SW(AR_UNAT);
- -	unw.sw_off[unw.preg_index[UNW_REG_PR]] = SW(PR);
- -	unw.sw_off[unw.preg_index[UNW_REG_LC]] = SW(AR_LC);
- -	unw.sw_off[unw.preg_index[UNW_REG_FPSR]] = SW(AR_FPSR);
- -	for (i = UNW_REG_R4, off = SW(R4); i <= UNW_REG_R7; ++i, off += 8)
+	unw.sw_off[unw.preg_index[UNW_REG_PRI_UNAT_GR]] = offsetof(struct switch_stack, ar_unat);
+	unw.sw_off[unw.preg_index[UNW_REG_BSPSTORE]] = offsetof(struct switch_stack, ar_bspstore);
+	unw.sw_off[unw.preg_index[UNW_REG_PFS]] = offsetof(struct switch_stack, ar_unat);
+	unw.sw_off[unw.preg_index[UNW_REG_RP]] = offsetof(struct switch_stack, b0);
+	unw.sw_off[unw.preg_index[UNW_REG_UNAT]] = offsetof(struct switch_stack, ar_unat);
+	unw.sw_off[unw.preg_index[UNW_REG_PR]] = offsetof(struct switch_stack, pr);
+	unw.sw_off[unw.preg_index[UNW_REG_LC]] = offsetof(struct switch_stack, ar_lc);
+	unw.sw_off[unw.preg_index[UNW_REG_FPSR]] = offsetof(struct switch_stack, ar_fpsr);
+	for (i = UNW_REG_R4, off = offsetof(struct switch_stack, r4); i <= UNW_REG_R7; ++i, off += 8)
 		unw.sw_off[unw.preg_index[i]] = off;
- -	for (i = UNW_REG_B1, off = SW(B1); i <= UNW_REG_B5; ++i, off += 8)
+	for (i = UNW_REG_B1, off = offsetof(struct switch_stack, b1); i <= UNW_REG_B5; ++i, off += 8)
 		unw.sw_off[unw.preg_index[i]] = off;
- -	for (i = UNW_REG_F2, off = SW(F2); i <= UNW_REG_F5; ++i, off += 16)
+	for (i = UNW_REG_F2, off = offsetof(struct switch_stack, f2); i <= UNW_REG_F5; ++i, off += 16)
 		unw.sw_off[unw.preg_index[i]] = off;
- -	for (i = UNW_REG_F16, off = SW(F16); i <= UNW_REG_F31; ++i, off += 16)
+	for (i = UNW_REG_F16, off = offsetof(struct switch_stack, f16); i <= UNW_REG_F31; ++i, off += 16)
 		unw.sw_off[unw.preg_index[i]] = off;
 
 	for (i = 0; i < UNW_CACHE_SIZE; ++i) {
Index: 3.20/arch/ia64/kernel/setup.c
- --- 3.20/arch/ia64/kernel/setup.c Tue, 24 Apr 2001 11:02:09 +1000 kaos (linux-2.4/r/c/48_setup.c 1.1.5.1 644)
+++ 3.20(w)/arch/ia64/kernel/setup.c Sat, 28 Apr 2001 11:40:52 +1000 kaos (linux-2.4/r/c/48_setup.c 1.1.5.1 644)
@@ -42,10 +42,6 @@
 # include <linux/blk.h>
 #endif
 
- -#if defined(CONFIG_SMP) && (IA64_CPU_SIZE > PAGE_SIZE)
- -# error "struct cpuinfo_ia64 too big!"
- -#endif
- -
 extern char _end;
 
 /* cpu_data[0] is data for the bootstrap processor: */
Index: 3.20/arch/ia64/kernel/process.c
- --- 3.20/arch/ia64/kernel/process.c Tue, 24 Apr 2001 11:02:09 +1000 kaos (linux-2.4/r/c/50_process.c 1.1.5.1 644)
+++ 3.20(w)/arch/ia64/kernel/process.c Sat, 28 Apr 2001 11:35:27 +1000 kaos (linux-2.4/r/c/50_process.c 1.1.5.1 644)
@@ -28,6 +28,11 @@
 #include <asm/unwind.h>
 #include <asm/user.h>
 
+/* When thread_saved_pc() gets the task pointer instead, delete
+ * ia64_task_thread_offset below and in include/asm-ia64/processor.h. KAO
+ */
+const long ia64_task_thread_offset = offsetof(struct task_struct, thread);
+
 static void
 do_show_stack (struct unw_frame_info *info, void *arg)
 {
@@ -225,8 +230,8 @@ copy_thread (int nr, unsigned long clone
 	/* copy parent's switch_stack & pt_regs to child: */
 	memcpy(child_stack, stack, stack_used);
 
- -	rbs = (unsigned long) current + IA64_RBS_OFFSET;
- -	child_rbs = (unsigned long) p + IA64_RBS_OFFSET;
+	rbs = (unsigned long) current + ia64_rbs_offset;
+	child_rbs = (unsigned long) p + ia64_rbs_offset;
 	rbs_size = stack->ar_bspstore - rbs;
 
 	/* copy the parent's register backing store to the child: */
Index: 3.20/arch/ia64/kernel/ptrace.c
- --- 3.20/arch/ia64/kernel/ptrace.c Tue, 24 Apr 2001 11:02:09 +1000 kaos (linux-2.4/s/c/2_ptrace.c 1.2.3.1 644)
+++ 3.20(w)/arch/ia64/kernel/ptrace.c Sat, 28 Apr 2001 11:33:00 +1000 kaos (linux-2.4/s/c/2_ptrace.c 1.2.3.1 644)
@@ -302,7 +302,7 @@ ia64_peek (struct task_struct *child, un
 	child_regs = ia64_task_regs(child);
 	child_stack = (struct switch_stack *) (child->thread.ksp + 16);
 	bspstore = (unsigned long *) child_regs->ar_bspstore;
- -	krbs = (unsigned long *) child + IA64_RBS_OFFSET/8;
+	krbs = (unsigned long *) child + ia64_rbs_offset/8;
 	if (laddr >= bspstore && laddr <= ia64_rse_rnat_addr(ubsp)) {
 		/*
 		 * Attempt to read the RBS in an area that's actually on the kernel RBS =>
@@ -338,7 +338,7 @@ ia64_poke (struct task_struct *child, un
 	child_regs = ia64_task_regs(child);
 	child_stack = (struct switch_stack *) (child->thread.ksp + 16);
 	bspstore = (unsigned long *) child_regs->ar_bspstore;
- -	krbs = (unsigned long *) child + IA64_RBS_OFFSET/8;
+	krbs = (unsigned long *) child + ia64_rbs_offset/8;
 	if (laddr >= bspstore && laddr <= ia64_rse_rnat_addr(ubsp)) {
 		/*
 		 * Attempt to write the RBS in an area that's actually on the kernel RBS
@@ -369,7 +369,7 @@ ia64_get_user_bsp (struct task_struct *c
 	struct unw_frame_info info;
 	long ndirty;
 
- -	krbs = (unsigned long *) child + IA64_RBS_OFFSET/8;
+	krbs = (unsigned long *) child + ia64_rbs_offset/8;
 	bspstore = (unsigned long *) pt->ar_bspstore;
 	ndirty = ia64_rse_num_regs(krbs, krbs + (pt->loadrs >> 19));
 
Index: 3.20/arch/ia64/kernel/mca_asm.S
- --- 3.20/arch/ia64/kernel/mca_asm.S Tue, 24 Apr 2001 11:02:09 +1000 kaos (linux-2.4/s/c/3_mca_asm.S 1.1.6.1 644)
+++ 3.20(w)/arch/ia64/kernel/mca_asm.S Sat, 28 Apr 2001 11:49:49 +1000 kaos (linux-2.4/s/c/3_mca_asm.S 1.1.6.1 644)
@@ -9,6 +9,7 @@
 //
 #include <linux/config.h>
 
+#include <asm/offsets.h>
 #include <asm/pgtable.h>
 #include <asm/processor.h>
 #include <asm/mca_asm.h>
Index: 3.20/arch/ia64/kernel/entry.S
- --- 3.20/arch/ia64/kernel/entry.S Tue, 24 Apr 2001 11:02:09 +1000 kaos (linux-2.4/s/c/15_entry.S 1.1.5.1 644)
+++ 3.20(w)/arch/ia64/kernel/entry.S Sat, 28 Apr 2001 11:42:09 +1000 kaos (linux-2.4/s/c/15_entry.S 1.1.5.1 644)
@@ -41,6 +41,10 @@
 
 #include "minstate.h"
 
+#if defined(CONFIG_SMP) && (IA64_CPU_SIZE > PAGE_SIZE)
+# error "struct cpuinfo_ia64 too big!"
+#endif
+
 	/*
 	 * execve() is special because in case of success, we need to
 	 * setup a null register window frame.
Index: 3.20/arch/ia64/kernel/Makefile
- --- 3.20/arch/ia64/kernel/Makefile Tue, 24 Apr 2001 11:02:09 +1000 kaos (linux-2.4/s/c/19_Makefile 1.1.5.1 644)
+++ 3.20(w)/arch/ia64/kernel/Makefile Sat, 28 Apr 2001 11:49:31 +1000 kaos (linux-2.4/s/c/19_Makefile 1.1.5.1 644)
@@ -25,4 +25,10 @@ obj-$(CONFIG_SMP) += smp.o smpboot.o
 obj-$(CONFIG_IA64_MCA) += mca.o mca_asm.o
 obj-$(CONFIG_IA64_BRL_EMU) += brl_emu.o
 
+.PHONY: include/asm/offsets.h
+include/asm/offsets.h:
+	$(MAKE) -C $(TOPDIR)/arch/$(ARCH)/tools
+
+ivt.o head.o entry.o mca_asm.o: include/asm/offsets.h
+
 include $(TOPDIR)/Rules.make
Index: 3.20/arch/ia64/ia32/Makefile
- --- 3.20/arch/ia64/ia32/Makefile Fri, 05 Jan 2001 13:42:29 +1100 kaos (linux-2.4/s/c/27_Makefile 1.1 644)
+++ 3.20(w)/arch/ia64/ia32/Makefile Fri, 27 Apr 2001 17:59:21 +1000 kaos (linux-2.4/s/c/27_Makefile 1.1 644)
@@ -13,6 +13,12 @@ O_TARGET := ia32.o
 
 obj-y := ia32_entry.o sys_ia32.o ia32_ioctl.o ia32_signal.o ia32_support.o ia32_traps.o binfmt_elf32.o
 
+.PHONY: include/asm/offsets.h
+include/asm/offsets.h:
+	$(MAKE) -C $(TOPDIR)/arch/$(ARCH)/tools
+
+ia32_entry.o: include/asm/offsets.h
+
 clean::
 
 include $(TOPDIR)/Rules.make
Index: 3.20/arch/ia64/Makefile
- --- 3.20/arch/ia64/Makefile Tue, 24 Apr 2001 11:02:09 +1000 kaos (linux-2.4/s/c/42_Makefile 1.1.5.1 644)
+++ 3.20(w)/arch/ia64/Makefile Sat, 28 Apr 2001 12:26:42 +1000 kaos (linux-2.4/s/c/42_Makefile 1.1.5.1 644)
@@ -87,7 +87,7 @@ endif
 
 HEAD := arch/$(ARCH)/kernel/head.o arch/ia64/kernel/init_task.o
 
- -SUBDIRS := arch/$(ARCH)/tools arch/$(ARCH)/kernel arch/$(ARCH)/mm arch/$(ARCH)/lib $(SUBDIRS)
+SUBDIRS := arch/$(ARCH)/kernel arch/$(ARCH)/mm arch/$(ARCH)/lib $(SUBDIRS)
 CORE_FILES := arch/$(ARCH)/kernel/kernel.o arch/$(ARCH)/mm/mm.o $(CORE_FILES)
 
 LIBS := $(TOPDIR)/arch/$(ARCH)/lib/lib.a $(LIBS) \
Index: 3.20(w)/include/asm-ia64/offsets.h
- --- 3.20/include/asm-ia64/offsets.h Tue, 24 Apr 2001 11:02:09 +1000 kaos (linux-2.4/t/6_offsets.h 1.1.5.1 644)
+++ 3.20(w)/include/asm-ia64/offsets.h Sat, 28 Apr 2001 12:36:30 +1000 kaos ()
@@ -1,134 +0,0 @@
- -#ifndef _ASM_IA64_OFFSETS_H
- -#define _ASM_IA64_OFFSETS_H
- -
- -/*
- - * DO NOT MODIFY
- - *
- - * This file was generated by arch/ia64/tools/print_offsets.
- - *
- - */
- -
- -#define PT_PTRACED_BIT			0
- -#define PT_TRACESYS_BIT			1
- -
- -#define IA64_TASK_SIZE			3904	/* 0xf40 */
- -#define IA64_PT_REGS_SIZE		400	/* 0x190 */
- -#define IA64_SWITCH_STACK_SIZE		560	/* 0x230 */
- -#define IA64_SIGINFO_SIZE		128	/* 0x80 */
- -#define IA64_CPU_SIZE			16384	/* 0x4000 */
- -#define UNW_FRAME_INFO_SIZE		448	/* 0x1c0 */
- -
- -#define IA64_TASK_PTRACE_OFFSET		48	/* 0x30 */
- -#define IA64_TASK_SIGPENDING_OFFSET	16	/* 0x10 */
- -#define IA64_TASK_NEED_RESCHED_OFFSET	40	/* 0x28 */
- -#define IA64_TASK_PROCESSOR_OFFSET	100	/* 0x64 */
- -#define IA64_TASK_THREAD_OFFSET		1456	/* 0x5b0 */
- -#define IA64_TASK_THREAD_KSP_OFFSET	1456	/* 0x5b0 */
- -#define IA64_TASK_THREAD_SIGMASK_OFFSET	3752	/* 0xea8 */
- -#define IA64_TASK_PFM_NOTIFY_OFFSET	3648	/* 0xe40 */
- -#define IA64_TASK_PID_OFFSET		196	/* 0xc4 */
- -#define IA64_TASK_MM_OFFSET		88	/* 0x58 */
- -#define IA64_PT_REGS_CR_IPSR_OFFSET	0	/* 0x0 */
- -#define IA64_PT_REGS_CR_IIP_OFFSET	8	/* 0x8 */
- -#define IA64_PT_REGS_CR_IFS_OFFSET	16	/* 0x10 */
- -#define IA64_PT_REGS_AR_UNAT_OFFSET	24	/* 0x18 */
- -#define IA64_PT_REGS_AR_PFS_OFFSET	32	/* 0x20 */
- -#define IA64_PT_REGS_AR_RSC_OFFSET	40	/* 0x28 */
- -#define IA64_PT_REGS_AR_RNAT_OFFSET	48	/* 0x30 */
- -#define IA64_PT_REGS_AR_BSPSTORE_OFFSET	56	/* 0x38 */
- -#define IA64_PT_REGS_PR_OFFSET		64	/* 0x40 */
- -#define IA64_PT_REGS_B6_OFFSET		72	/* 0x48 */
- -#define IA64_PT_REGS_LOADRS_OFFSET	80	/* 0x50 */
- -#define IA64_PT_REGS_R1_OFFSET		88	/* 0x58 */
- -#define IA64_PT_REGS_R2_OFFSET		96	/* 0x60 */
- -#define IA64_PT_REGS_R3_OFFSET		104	/* 0x68 */
- -#define IA64_PT_REGS_R12_OFFSET		112	/* 0x70 */
- -#define IA64_PT_REGS_R13_OFFSET		120	/* 0x78 */
- -#define IA64_PT_REGS_R14_OFFSET		128	/* 0x80 */
- -#define IA64_PT_REGS_R15_OFFSET		136	/* 0x88 */
- -#define IA64_PT_REGS_R8_OFFSET		144	/* 0x90 */
- -#define IA64_PT_REGS_R9_OFFSET		152	/* 0x98 */
- -#define IA64_PT_REGS_R10_OFFSET		160	/* 0xa0 */
- -#define IA64_PT_REGS_R11_OFFSET		168	/* 0xa8 */
- -#define IA64_PT_REGS_R16_OFFSET		176	/* 0xb0 */
- -#define IA64_PT_REGS_R17_OFFSET		184	/* 0xb8 */
- -#define IA64_PT_REGS_R18_OFFSET		192	/* 0xc0 */
- -#define IA64_PT_REGS_R19_OFFSET		200	/* 0xc8 */
- -#define IA64_PT_REGS_R20_OFFSET		208	/* 0xd0 */
- -#define IA64_PT_REGS_R21_OFFSET		216	/* 0xd8 */
- -#define IA64_PT_REGS_R22_OFFSET		224	/* 0xe0 */
- -#define IA64_PT_REGS_R23_OFFSET		232	/* 0xe8 */
- -#define IA64_PT_REGS_R24_OFFSET		240	/* 0xf0 */
- -#define IA64_PT_REGS_R25_OFFSET		248	/* 0xf8 */
- -#define IA64_PT_REGS_R26_OFFSET		256	/* 0x100 */
- -#define IA64_PT_REGS_R27_OFFSET		264	/* 0x108 */
- -#define IA64_PT_REGS_R28_OFFSET		272	/* 0x110 */
- -#define IA64_PT_REGS_R29_OFFSET		280	/* 0x118 */
- -#define IA64_PT_REGS_R30_OFFSET		288	/* 0x120 */
- -#define IA64_PT_REGS_R31_OFFSET		296	/* 0x128 */
- -#define IA64_PT_REGS_AR_CCV_OFFSET	304	/* 0x130 */
- -#define IA64_PT_REGS_AR_FPSR_OFFSET	312	/* 0x138 */
- -#define IA64_PT_REGS_B0_OFFSET		320	/* 0x140 */
- -#define IA64_PT_REGS_B7_OFFSET		328	/* 0x148 */
- -#define IA64_PT_REGS_F6_OFFSET		336	/* 0x150 */
- -#define IA64_PT_REGS_F7_OFFSET		352	/* 0x160 */
- -#define IA64_PT_REGS_F8_OFFSET		368	/* 0x170 */
- -#define IA64_PT_REGS_F9_OFFSET		384	/* 0x180 */
- -#define IA64_SWITCH_STACK_CALLER_UNAT_OFFSET 0	/* 0x0 */
- -#define IA64_SWITCH_STACK_AR_FPSR_OFFSET	8	/* 0x8 */
- -#define IA64_SWITCH_STACK_F2_OFFSET	16	/* 0x10 */
- -#define IA64_SWITCH_STACK_F3_OFFSET	32	/* 0x20 */
- -#define IA64_SWITCH_STACK_F4_OFFSET	48	/* 0x30 */
- -#define IA64_SWITCH_STACK_F5_OFFSET	64	/* 0x40 */
- -#define IA64_SWITCH_STACK_F10_OFFSET	80	/* 0x50 */
- -#define IA64_SWITCH_STACK_F11_OFFSET	96	/* 0x60 */
- -#define IA64_SWITCH_STACK_F12_OFFSET	112	/* 0x70 */
- -#define IA64_SWITCH_STACK_F13_OFFSET	128	/* 0x80 */
- -#define IA64_SWITCH_STACK_F14_OFFSET	144	/* 0x90 */
- -#define IA64_SWITCH_STACK_F15_OFFSET	160	/* 0xa0 */
- -#define IA64_SWITCH_STACK_F16_OFFSET	176	/* 0xb0 */
- -#define IA64_SWITCH_STACK_F17_OFFSET	192	/* 0xc0 */
- -#define IA64_SWITCH_STACK_F18_OFFSET	208	/* 0xd0 */
- -#define IA64_SWITCH_STACK_F19_OFFSET	224	/* 0xe0 */
- -#define IA64_SWITCH_STACK_F20_OFFSET	240	/* 0xf0 */
- -#define IA64_SWITCH_STACK_F21_OFFSET	256	/* 0x100 */
- -#define IA64_SWITCH_STACK_F22_OFFSET	272	/* 0x110 */
- -#define IA64_SWITCH_STACK_F23_OFFSET	288	/* 0x120 */
- -#define IA64_SWITCH_STACK_F24_OFFSET	304	/* 0x130 */
- -#define IA64_SWITCH_STACK_F25_OFFSET	320	/* 0x140 */
- -#define IA64_SWITCH_STACK_F26_OFFSET	336	/* 0x150 */
- -#define IA64_SWITCH_STACK_F27_OFFSET	352	/* 0x160 */
- -#define IA64_SWITCH_STACK_F28_OFFSET	368	/* 0x170 */
- -#define IA64_SWITCH_STACK_F29_OFFSET	384	/* 0x180 */
- -#define IA64_SWITCH_STACK_F30_OFFSET	400	/* 0x190 */
- -#define IA64_SWITCH_STACK_F31_OFFSET	416	/* 0x1a0 */
- -#define IA64_SWITCH_STACK_R4_OFFSET	432	/* 0x1b0 */
- -#define IA64_SWITCH_STACK_R5_OFFSET	440	/* 0x1b8 */
- -#define IA64_SWITCH_STACK_R6_OFFSET	448	/* 0x1c0 */
- -#define IA64_SWITCH_STACK_R7_OFFSET	456	/* 0x1c8 */
- -#define IA64_SWITCH_STACK_B0_OFFSET	464	/* 0x1d0 */
- -#define IA64_SWITCH_STACK_B1_OFFSET	472	/* 0x1d8 */
- -#define IA64_SWITCH_STACK_B2_OFFSET	480	/* 0x1e0 */
- -#define IA64_SWITCH_STACK_B3_OFFSET	488	/* 0x1e8 */
- -#define IA64_SWITCH_STACK_B4_OFFSET	496	/* 0x1f0 */
- -#define IA64_SWITCH_STACK_B5_OFFSET	504	/* 0x1f8 */
- -#define IA64_SWITCH_STACK_AR_PFS_OFFSET	512	/* 0x200 */
- -#define IA64_SWITCH_STACK_AR_LC_OFFSET	520	/* 0x208 */
- -#define IA64_SWITCH_STACK_AR_UNAT_OFFSET	528	/* 0x210 */
- -#define IA64_SWITCH_STACK_AR_RNAT_OFFSET	536	/* 0x218 */
- -#define IA64_SWITCH_STACK_AR_BSPSTORE_OFFSET 544	/* 0x220 */
- -#define IA64_SWITCH_STACK_PR_OFFSET	552	/* 0x228 */
- -#define IA64_SIGCONTEXT_AR_BSP_OFFSET	72	/* 0x48 */
- -#define IA64_SIGCONTEXT_AR_RNAT_OFFSET	80	/* 0x50 */
- -#define IA64_SIGCONTEXT_FLAGS_OFFSET	0	/* 0x0 */
- -#define IA64_SIGCONTEXT_CFM_OFFSET	48	/* 0x30 */
- -#define IA64_SIGCONTEXT_FR6_OFFSET	560	/* 0x230 */
- -#define IA64_CLONE_VFORK			16384	/* 0x4000 */
- -#define IA64_CLONE_VM			256	/* 0x100 */
- -#define IA64_CPU_IRQ_COUNT_OFFSET	8	/* 0x8 */
- -#define IA64_CPU_BH_COUNT_OFFSET		12	/* 0xc */
- -#define IA64_CPU_SOFTIRQ_ACTIVE_OFFSET	0	/* 0x0 */
- -#define IA64_CPU_SOFTIRQ_MASK_OFFSET	4	/* 0x4 */
- -#define IA64_CPU_PHYS_STACKED_SIZE_P8_OFFSET 16	/* 0x10 */
- -
- -#endif /* _ASM_IA64_OFFSETS_H */

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.3 (GNU/Linux)
Comment: Exmh version 2.1.1 10/15/1999

iD8DBQE66i+4i4UHNye0ZOoRAv7kAJ0ezXOkXPGBXjumEDckgVSECqe0CQCfaGDA
nTFuoc1JdZBoRW46c6x5k/Y=zDzu
-----END PGP SIGNATURE-----


