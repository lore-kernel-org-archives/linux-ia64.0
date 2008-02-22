From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Fri, 22 Feb 2008 05:10:44 +0000
Subject: [PATCH 25/28] ia64/xen: gate page paravirtualization
Message-Id: <12036570481177-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/kernel/Makefile       |   58 +++++++++++++++++++++++++++++++++++++++
 arch/ia64/kernel/gate.S         |   55 +++++++++++++++++++++++++++++++++++++
 arch/ia64/kernel/gate.lds.S     |   18 ++++++++++++
 arch/ia64/kernel/patch.c        |   28 +++++++++++++++++++
 arch/ia64/kernel/vmlinux.lds.S  |    6 ++++
 arch/ia64/kernel/xengate-data.S |    3 ++
 arch/ia64/mm/init.c             |   22 +++++++++++++-
 7 files changed, 188 insertions(+), 2 deletions(-)
 create mode 100644 arch/ia64/kernel/xengate-data.S

diff --git a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
index d0e22bb..661619c 100644
--- a/arch/ia64/kernel/Makefile
+++ b/arch/ia64/kernel/Makefile
@@ -75,3 +75,61 @@ $(obj)/gate-syms.o: $(obj)/gate.lds $(obj)/gate.o FORCE
 # We must build gate.so before we can assemble it.
 # Note: kbuild does not track this dependency due to usage of .incbin
 $(obj)/gate-data.o: $(obj)/gate.so
+
+#
+# gate page paravirtualization for xen
+#
+obj-$(CONFIG_XEN) += xengate-data.o
+
+ifeq ($(CONFIG_XEN), y)
+# The gate DSO image is built using a special linker script.
+targets += xengate.so xengate-syms.o
+endif
+
+extra-$(CONFIG_XEN) += xengate.so xengate.lds xengate.o
+
+AFLAGS_xengate.o += -D__XEN_IA64_VDSO_PARAVIRT
+$(obj)/xengate.o: $(src)/gate.S FORCE
+	$(call if_changed_dep,as_o_S)
+
+CPPFLAGS_xengate.lds := -P -C -U$(ARCH) -D__XEN_IA64_VDSO_PARAVIRT
+$(obj)/xengate.lds: $(src)/gate.lds.S
+	$(call if_changed_dep,cpp_lds_S)
+
+GATECFLAGS_xengate.so = -shared -s -Wl,-soname=linux-gate.so.1 \
+		     $(call ld-option, -Wl$(comma)--hash-style=sysv)
+$(obj)/xengate.so: $(obj)/xengate.lds $(obj)/xengate.o FORCE
+	$(call if_changed,gate)
+
+ifeq ($(CONFIG_XEN), y)
+$(obj)/built-in.o: $(obj)/xengate-syms.o
+$(obj)/built-in.o: ld_flags += -R $(obj)/xengate-syms.o
+$(obj)/mca_recovery.o: $(obj)/gate-syms.o $(obj)/xengate-syms.o
+endif
+
+GATECFLAGS_xengate-syms.o = -r
+$(obj)/xengate-syms.o: $(obj)/xengate.lds $(obj)/xengate.o FORCE
+	$(call if_changed,gate)
+$(obj)/xengate-data.o: $(obj)/xengate.so
+
+#
+# .tmp_gate.o to calculate padding size for __kernel_syscall_via_epc
+#
+extra-$(CONFIG_XEN) += gate-skip.s .tmp_gate.o
+
+ifeq ($(CONFIG_XEN), y)
+AFLAGS_gate.o += -D__KERNEL_SYSCALL_VIA_EPC_PADDING
+$(obj)/gate.o: $(obj)/gate-skip.s FORCE
+endif
+
+$(obj)/.tmp_gate.o: $(src)/gate.S FORCE
+	$(call if_changed_dep,as_o_S)
+
+quiet_cmd_gate_size = GATE_SIZE	$@
+      cmd_gate_size = $(NM) --extern-only --print-size $(obj)/xengate.o | \
+	$(AWK) '/__kernel_syscall_via_epc/{printf "\t.skip 0x"$$2" - "}' > $@; \
+	$(NM) --extern-only --print-size $(obj)/.tmp_gate.o | \
+	$(AWK) '/__kernel_syscall_via_epc/{printf "0x"$$2"\n"}' >> $@
+
+$(obj)/gate-skip.s: $(obj)/xengate.o $(obj)/.tmp_gate.o FORCE
+	$(call if_changed,gate_size)
diff --git a/arch/ia64/kernel/gate.S b/arch/ia64/kernel/gate.S
index 74b1ccc..7c62417 100644
--- a/arch/ia64/kernel/gate.S
+++ b/arch/ia64/kernel/gate.S
@@ -77,15 +77,40 @@ GLOBAL_ENTRY(__kernel_syscall_via_epc)
 	epc					// B	causes split-issue
 }
 	;;
+#ifdef __XEN_IA64_VDSO_PARAVIRT
+	// r20 = 1
+	// r22 = &vcpu->vcpu_info->evtchn_upcall_mask
+	// r24 = &vcpu->vcpu_info->evtchn_upcall_pending
+	// r25 = tmp
+	// r31 = tmp
+	// p11 = tmp
+	// p14 = tmp
+	mov r20=1
+	movl r22=XSI_PSR_I_ADDR
+	;;
+	ld8 r22=[r22]
+	;;
+	st1 [r22]=r20
+	rum psr.be
+	adds r24=-1,r22
+#else
 	rsm psr.be | psr.i			// M2 (5 cyc to srlz.d)
+#endif
 	LOAD_FSYSCALL_TABLE(r14)		// X
 	;;
 	mov r16=IA64_KR(CURRENT)		// M2 (12 cyc)
 	shladd r18=r17,3,r14			// A
 	mov r19=NR_syscalls-1			// A
+#ifdef __XEN_IA64_VDSO_PARAVIRT
+	XEN_HYPER_GET_PSR
+	;;
+	lfetch [r18]				// M0|1
+	mov r29=r8
+#else
 	;;
 	lfetch [r18]				// M0|1
 	mov r29=psr				// M2 (12 cyc)
+#endif
 	// If r17 is a NaT, p6 will be zero
 	cmp.geu p6,p7=r19,r17			// A    (sysnr > 0 && sysnr < 1024+NR_syscalls)?
 	;;
@@ -99,9 +124,27 @@ GLOBAL_ENTRY(__kernel_syscall_via_epc)
 	;;
 	nop.m 0
 (p6)	tbit.z.unc p8,p0=r18,0			// I0 (dual-issues with "mov b7=r18"!)
+#ifdef __XEN_IA64_VDSO_PARAVIRT
+
+#define XEN_SET_PSR_I(pred)		\
+(pred)	ld1 r31=[r22];			\
+	;; ;				\
+(pred)	st1 [r22]=r0;			\
+(pred)	cmp.ne.unc p14,p0=r0,r31;	\
+	;; ;				\
+(p14)	ld1 r25=[r24];			\
+	;; ;				\
+(p14)	cmp.ne.unc p11,p0=r0,r25;	\
+	;; ;				\
+(p11)	XEN_HYPER_SSM_I;
+
+	;;
+	XEN_SET_PSR_I(p8)
+#else
 	nop.i 0
 	;;
 (p8)	ssm psr.i
+#endif
 (p6)	mov b7=r18				// I0
 (p8)	br.dptk.many b7				// B
 
@@ -122,11 +165,23 @@ GLOBAL_ENTRY(__kernel_syscall_via_epc)
 #else
 	BRL_COND_FSYS_BUBBLE_DOWN(p6)
 #endif
+#ifdef __XEN_IA64_VDSO_PARAVIRT
+	XEN_SET_PSR_I(p0)
+#else
 	ssm psr.i
+#endif
 	mov r10=-1
 (p10)	mov r8=EINVAL
 (p9)	mov r8=ENOSYS
 	FSYS_RETURN
+#ifdef __KERNEL_SYSCALL_VIA_EPC_PADDING
+	/*
+	 * All values/sizes of __kernel_xxx symbol in gate.so and xengate.so
+	 * must be same to each other.
+	 * Adjust symbol size in gate.so to be same to the one in xengate.so.
+	 */
+.include "arch/ia64/kernel/gate-skip.s"
+#endif
 END(__kernel_syscall_via_epc)
 
 #	define ARG0_OFF		(16 + IA64_SIGFRAME_ARG0_OFFSET)
diff --git a/arch/ia64/kernel/gate.lds.S b/arch/ia64/kernel/gate.lds.S
index 3cb1abc..b9615cf 100644
--- a/arch/ia64/kernel/gate.lds.S
+++ b/arch/ia64/kernel/gate.lds.S
@@ -33,6 +33,24 @@ SECTIONS
 	. = GATE_ADDR + 0x600;
 
 	.data.patch		: {
+#ifdef __XEN_IA64_VDSO_PARAVIRT
+#define __start_gate_mckinley_e9_patchlist \
+	__start_gate_mckinley_e9_patchlist_xen
+#define __end_gate_mckinley_e9_patchlist \
+	__end_gate_mckinley_e9_patchlist_xen
+#define __start_gate_vtop_patchlist \
+	__start_gate_vtop_patchlist_xen
+#define __end_gate_vtop_patchlist \
+	__end_gate_vtop_patchlist_xen
+#define __start_gate_fsyscall_patchlist \
+	__start_gate_fsyscall_patchlist_xen
+#define __end_gate_fsyscall_patchlist \
+	__end_gate_fsyscall_patchlist_xen
+#define __start_gate_brl_fsys_bubble_down_patchlist \
+	__start_gate_brl_fsys_bubble_down_patchlist_xen
+#define __end_gate_brl_fsys_bubble_down_patchlist \
+	__end_gate_brl_fsys_bubble_down_patchlist_xen
+#endif
 		__start_gate_mckinley_e9_patchlist = .;
 		*(.data.patch.mckinley_e9)
 		__end_gate_mckinley_e9_patchlist = .;
diff --git a/arch/ia64/kernel/patch.c b/arch/ia64/kernel/patch.c
index 2cb9425..4676ac4 100644
--- a/arch/ia64/kernel/patch.c
+++ b/arch/ia64/kernel/patch.c
@@ -181,9 +181,37 @@ patch_brl_fsys_bubble_down (unsigned long start, unsigned long end)
 	ia64_srlz_i();
 }
 
+#ifdef CONFIG_XEN
+void __init
+ia64_patch_gate_xen (void)
+{
+	extern char __start_gate_mckinley_e9_patchlist_xen[], __end_gate_mckinley_e9_patchlist_xen[];
+	extern char __start_gate_vtop_patchlist_xen[], __end_gate_vtop_patchlist_xen[];
+	extern char __start_gate_fsyscall_patchlist_xen[], __end_gate_fsyscall_patchlist_xen[];
+	extern char __start_gate_brl_fsys_bubble_down_patchlist_xen[], __end_gate_brl_fsys_bubble_down_patchlist_xen[];
+#	define START(name)	((unsigned long) __start_gate_##name##_patchlist_xen)
+#	define END(name)	((unsigned long)__end_gate_##name##_patchlist_xen)
+
+	patch_fsyscall_table(START(fsyscall), END(fsyscall));
+	patch_brl_fsys_bubble_down(START(brl_fsys_bubble_down), END(brl_fsys_bubble_down));
+	ia64_patch_vtop(START(vtop), END(vtop));
+	ia64_patch_mckinley_e9(START(mckinley_e9), END(mckinley_e9));
+
+#	undef START
+#	undef END
+}
+#else
+#define ia64_patch_gate_xen()	do { } while (0)
+#endif
+
 void __init
 ia64_patch_gate (void)
 {
+	if (is_running_on_xen()) {
+		ia64_patch_gate_xen();
+		return;
+	}
+
 #	define START(name)	((unsigned long) __start_gate_##name##_patchlist)
 #	define END(name)	((unsigned long)__end_gate_##name##_patchlist)
 
diff --git a/arch/ia64/kernel/vmlinux.lds.S b/arch/ia64/kernel/vmlinux.lds.S
index 0cbe0a1..0cedc30 100644
--- a/arch/ia64/kernel/vmlinux.lds.S
+++ b/arch/ia64/kernel/vmlinux.lds.S
@@ -230,6 +230,12 @@ SECTIONS
 	  __start_gate_section = .;
 	  *(.data.gate)
 	  __stop_gate_section = .;
+#if defined(CONFIG_XEN)
+	  . = ALIGN(PAGE_SIZE);
+	  __start_xen_gate_section = .;
+	  *(.data.gate.xen)
+	  __stop_xen_gate_section = .;
+#endif
 	}
   . = ALIGN(PAGE_SIZE);		/* make sure the gate page doesn't expose
   				 * kernel data
diff --git a/arch/ia64/kernel/xengate-data.S b/arch/ia64/kernel/xengate-data.S
new file mode 100644
index 0000000..122bb5f
--- /dev/null
+++ b/arch/ia64/kernel/xengate-data.S
@@ -0,0 +1,3 @@
+	.section .data.gate.xen, "aw"
+
+	.incbin "arch/ia64/kernel/xengate.so"
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 25aef62..5e327ac 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -267,16 +267,34 @@ static void __init
 setup_gate (void)
 {
 	struct page *page;
+	void *gate_page_addr = __start_gate_section;
+
+#ifdef CONFIG_XEN
+	unsigned long unused_gate;
+	extern char __start_xen_gate_section[];
+	if (is_running_on_xen()) {
+		gate_page_addr = __start_xen_gate_section;
+		unused_gate = (unsigned long)ia64_imva(__start_gate_section);
+	} else
+		unused_gate +			(unsigned long)ia64_imva(__start_xen_gate_section);
+#ifndef HAVE_BUGGY_SEGREL
+	ClearPageReserved(virt_to_page(unused_gate));
+	init_page_count(virt_to_page(unused_gate));
+	free_page(unused_gate);
+	++totalram_pages;
+#endif
+#endif
 
 	/*
 	 * Map the gate page twice: once read-only to export the ELF
 	 * headers etc. and once execute-only page to enable
 	 * privilege-promotion via "epc":
 	 */
-	page = virt_to_page(ia64_imva(__start_gate_section));
+	page = virt_to_page(ia64_imva(gate_page_addr));
 	put_kernel_page(page, GATE_ADDR, PAGE_READONLY);
 #ifdef HAVE_BUGGY_SEGREL
-	page = virt_to_page(ia64_imva(__start_gate_section + PAGE_SIZE));
+	page = virt_to_page(ia64_imva(gate_page_addr + PAGE_SIZE));
 	put_kernel_page(page, GATE_ADDR + PAGE_SIZE, PAGE_GATE);
 #else
 	put_kernel_page(page, GATE_ADDR + PERCPU_PAGE_SIZE, PAGE_GATE);
-- 
1.5.3

