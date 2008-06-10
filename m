From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Tue, 10 Jun 2008 07:47:04 +0000
Subject: [PATCH 08/27] ia64/xen: define helper functions for xen hypercalls.
Message-Id: <12130840431025-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

introduce helper functions for xen hypercalls which
traps to hypervisor.

Signed-off-by: Yaozu (Eddie) Dong <eddie.dong@intel.com>
Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/xen/Makefile           |    5 +
 arch/ia64/xen/hypercall.S        |   91 +++++++++++++
 include/asm-ia64/xen/hypercall.h |  265 ++++++++++++++++++++++++++++++++++++++
 include/asm-ia64/xen/privop.h    |  129 ++++++++++++++++++
 4 files changed, 490 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/xen/Makefile
 create mode 100644 arch/ia64/xen/hypercall.S
 create mode 100644 include/asm-ia64/xen/hypercall.h
 create mode 100644 include/asm-ia64/xen/privop.h

diff --git a/arch/ia64/xen/Makefile b/arch/ia64/xen/Makefile
new file mode 100644
index 0000000..c200704
--- /dev/null
+++ b/arch/ia64/xen/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for Xen components
+#
+
+obj-y := hypercall.o
diff --git a/arch/ia64/xen/hypercall.S b/arch/ia64/xen/hypercall.S
new file mode 100644
index 0000000..d4ff0b9
--- /dev/null
+++ b/arch/ia64/xen/hypercall.S
@@ -0,0 +1,91 @@
+/*
+ * Support routines for Xen hypercalls
+ *
+ * Copyright (C) 2005 Dan Magenheimer <dan.magenheimer@hp.com>
+ * Copyright (C) 2008 Yaozu (Eddie) Dong <eddie.dong@intel.com>
+ */
+
+#include <asm/asmmacro.h>
+#include <asm/intrinsics.h>
+#include <asm/xen/privop.h>
+
+/*
+ * Hypercalls without parameter.
+ */
+#define __HCALL0(name,hcall)		\
+	GLOBAL_ENTRY(name);		\
+	break	hcall;			\
+	br.ret.sptk.many rp;		\
+	END(name)
+
+/*
+ * Hypercalls with 1 parameter.
+ */
+#define __HCALL1(name,hcall)		\
+	GLOBAL_ENTRY(name);		\
+	mov r8=r32;			\
+	break	hcall;			\
+	br.ret.sptk.many rp;		\
+	END(name)
+
+/*
+ * Hypercalls with 2 parameters.
+ */
+#define __HCALL2(name,hcall)		\
+	GLOBAL_ENTRY(name);		\
+	mov r8=r32;			\
+	mov r9=r33;			\
+	break	hcall;			\
+	br.ret.sptk.many rp;		\
+	END(name)
+
+__HCALL0(xen_get_psr, HYPERPRIVOP_GET_PSR)
+__HCALL0(xen_get_ivr, HYPERPRIVOP_GET_IVR)
+__HCALL0(xen_get_tpr, HYPERPRIVOP_GET_TPR)
+__HCALL0(xen_hyper_ssm_i, HYPERPRIVOP_SSM_I)
+
+__HCALL1(xen_set_tpr, HYPERPRIVOP_SET_TPR)
+__HCALL1(xen_eoi, HYPERPRIVOP_EOI)
+__HCALL1(xen_thash, HYPERPRIVOP_THASH)
+__HCALL1(xen_set_itm, HYPERPRIVOP_SET_ITM)
+__HCALL1(xen_get_rr, HYPERPRIVOP_GET_RR)
+__HCALL1(xen_fc, HYPERPRIVOP_FC)
+__HCALL1(xen_get_cpuid, HYPERPRIVOP_GET_CPUID)
+__HCALL1(xen_get_pmd, HYPERPRIVOP_GET_PMD)
+
+__HCALL2(xen_ptcga, HYPERPRIVOP_PTC_GA)
+__HCALL2(xen_set_rr, HYPERPRIVOP_SET_RR)
+__HCALL2(xen_set_kr, HYPERPRIVOP_SET_KR)
+
+#ifdef CONFIG_IA32_SUPPORT
+__HCALL1(xen_get_eflag, HYPERPRIVOP_GET_EFLAG)
+__HCALL1(xen_set_eflag, HYPERPRIVOP_SET_EFLAG)	// refer SDM vol1 3.1.8
+#endif /* CONFIG_IA32_SUPPORT */
+
+GLOBAL_ENTRY(xen_set_rr0_to_rr4)
+	mov r8=r32
+	mov r9=r33
+	mov r10=r34
+	mov r11=r35
+	mov r14=r36
+	XEN_HYPER_SET_RR0_TO_RR4
+	br.ret.sptk.many rp
+	;;
+END(xen_set_rr0_to_rr4)
+
+GLOBAL_ENTRY(xen_send_ipi)
+	mov r14=r32
+	mov r15=r33
+	mov r2=0x400
+	break 0x1000
+	;;
+	br.ret.sptk.many rp
+	;;
+END(xen_send_ipi)
+
+GLOBAL_ENTRY(__hypercall)
+	mov r2=r37
+	break 0x1000
+	br.ret.sptk.many b0
+	;;
+END(__hypercall)
diff --git a/include/asm-ia64/xen/hypercall.h b/include/asm-ia64/xen/hypercall.h
new file mode 100644
index 0000000..96fc623
--- /dev/null
+++ b/include/asm-ia64/xen/hypercall.h
@@ -0,0 +1,265 @@
+/******************************************************************************
+ * hypercall.h
+ *
+ * Linux-specific hypervisor handling.
+ *
+ * Copyright (c) 2002-2004, K A Fraser
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation; or, when distributed
+ * separately from the Linux kernel or incorporated into other
+ * software packages, subject to the following license:
+ *
+ * Permission is hereby granted, free of charge, to any person obtaining a copy
+ * of this source file (the "Software"), to deal in the Software without
+ * restriction, including without limitation the rights to use, copy, modify,
+ * merge, publish, distribute, sublicense, and/or sell copies of the Software,
+ * and to permit persons to whom the Software is furnished to do so, subject to
+ * the following conditions:
+ *
+ * The above copyright notice and this permission notice shall be included in
+ * all copies or substantial portions of the Software.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
+ * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
+ * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
+ * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
+ * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
+ * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
+ * IN THE SOFTWARE.
+ */
+
+#ifndef _ASM_IA64_XEN_HYPERCALL_H
+#define _ASM_IA64_XEN_HYPERCALL_H
+
+#include <xen/interface/xen.h>
+#include <xen/interface/physdev.h>
+#include <xen/interface/sched.h>
+#include <asm/xen/xcom_hcall.h>
+struct xencomm_handle;
+extern unsigned long __hypercall(unsigned long a1, unsigned long a2,
+				 unsigned long a3, unsigned long a4,
+				 unsigned long a5, unsigned long cmd);
+
+/*
+ * Assembler stubs for hyper-calls.
+ */
+
+#define _hypercall0(type, name)					\
+({								\
+	long __res;						\
+	__res = __hypercall(0, 0, 0, 0, 0, __HYPERVISOR_##name);\
+	(type)__res;						\
+})
+
+#define _hypercall1(type, name, a1)				\
+({								\
+	long __res;						\
+	__res = __hypercall((unsigned long)a1,			\
+			     0, 0, 0, 0, __HYPERVISOR_##name);	\
+	(type)__res;						\
+})
+
+#define _hypercall2(type, name, a1, a2)				\
+({								\
+	long __res;						\
+	__res = __hypercall((unsigned long)a1,			\
+			    (unsigned long)a2,			\
+			    0, 0, 0, __HYPERVISOR_##name);	\
+	(type)__res;						\
+})
+
+#define _hypercall3(type, name, a1, a2, a3)			\
+({								\
+	long __res;						\
+	__res = __hypercall((unsigned long)a1,			\
+			    (unsigned long)a2,			\
+			    (unsigned long)a3,			\
+			    0, 0, __HYPERVISOR_##name);		\
+	(type)__res;						\
+})
+
+#define _hypercall4(type, name, a1, a2, a3, a4)			\
+({								\
+	long __res;						\
+	__res = __hypercall((unsigned long)a1,			\
+			    (unsigned long)a2,			\
+			    (unsigned long)a3,			\
+			    (unsigned long)a4,			\
+			    0, __HYPERVISOR_##name);		\
+	(type)__res;						\
+})
+
+#define _hypercall5(type, name, a1, a2, a3, a4, a5)		\
+({								\
+	long __res;						\
+	__res = __hypercall((unsigned long)a1,			\
+			    (unsigned long)a2,			\
+			    (unsigned long)a3,			\
+			    (unsigned long)a4,			\
+			    (unsigned long)a5,			\
+			    __HYPERVISOR_##name);		\
+	(type)__res;						\
+})
+
+
+static inline int
+xencomm_arch_hypercall_sched_op(int cmd, struct xencomm_handle *arg)
+{
+	return _hypercall2(int, sched_op_new, cmd, arg);
+}
+
+static inline long
+HYPERVISOR_set_timer_op(u64 timeout)
+{
+	unsigned long timeout_hi = (unsigned long)(timeout >> 32);
+	unsigned long timeout_lo = (unsigned long)timeout;
+	return _hypercall2(long, set_timer_op, timeout_lo, timeout_hi);
+}
+
+static inline int
+xencomm_arch_hypercall_multicall(struct xencomm_handle *call_list,
+				 int nr_calls)
+{
+	return _hypercall2(int, multicall, call_list, nr_calls);
+}
+
+static inline int
+xencomm_arch_hypercall_memory_op(unsigned int cmd, struct xencomm_handle *arg)
+{
+	return _hypercall2(int, memory_op, cmd, arg);
+}
+
+static inline int
+xencomm_arch_hypercall_event_channel_op(int cmd, struct xencomm_handle *arg)
+{
+	return _hypercall2(int, event_channel_op, cmd, arg);
+}
+
+static inline int
+xencomm_arch_hypercall_xen_version(int cmd, struct xencomm_handle *arg)
+{
+	return _hypercall2(int, xen_version, cmd, arg);
+}
+
+static inline int
+xencomm_arch_hypercall_console_io(int cmd, int count,
+				  struct xencomm_handle *str)
+{
+	return _hypercall3(int, console_io, cmd, count, str);
+}
+
+static inline int
+xencomm_arch_hypercall_physdev_op(int cmd, struct xencomm_handle *arg)
+{
+	return _hypercall2(int, physdev_op, cmd, arg);
+}
+
+static inline int
+xencomm_arch_hypercall_grant_table_op(unsigned int cmd,
+				      struct xencomm_handle *uop,
+				      unsigned int count)
+{
+	return _hypercall3(int, grant_table_op, cmd, uop, count);
+}
+
+int HYPERVISOR_grant_table_op(unsigned int cmd, void *uop, unsigned int count);
+
+extern int xencomm_arch_hypercall_suspend(struct xencomm_handle *arg);
+
+static inline int
+xencomm_arch_hypercall_callback_op(int cmd, struct xencomm_handle *arg)
+{
+	return _hypercall2(int, callback_op, cmd, arg);
+}
+
+static inline long
+xencomm_arch_hypercall_vcpu_op(int cmd, int cpu, void *arg)
+{
+	return _hypercall3(long, vcpu_op, cmd, cpu, arg);
+}
+
+static inline int
+HYPERVISOR_physdev_op(int cmd, void *arg)
+{
+	switch (cmd) {
+	case PHYSDEVOP_eoi:
+		return _hypercall1(int, ia64_fast_eoi,
+				   ((struct physdev_eoi *)arg)->irq);
+	default:
+		return xencomm_hypercall_physdev_op(cmd, arg);
+	}
+}
+
+static inline long
+xencomm_arch_hypercall_opt_feature(struct xencomm_handle *arg)
+{
+	return _hypercall1(long, opt_feature, arg);
+}
+
+/* for balloon driver */
+#define HYPERVISOR_update_va_mapping(va, new_val, flags) (0)
+
+/* Use xencomm to do hypercalls.  */
+#define HYPERVISOR_sched_op xencomm_hypercall_sched_op
+#define HYPERVISOR_event_channel_op xencomm_hypercall_event_channel_op
+#define HYPERVISOR_callback_op xencomm_hypercall_callback_op
+#define HYPERVISOR_multicall xencomm_hypercall_multicall
+#define HYPERVISOR_xen_version xencomm_hypercall_xen_version
+#define HYPERVISOR_console_io xencomm_hypercall_console_io
+#define HYPERVISOR_memory_op xencomm_hypercall_memory_op
+#define HYPERVISOR_suspend xencomm_hypercall_suspend
+#define HYPERVISOR_vcpu_op xencomm_hypercall_vcpu_op
+#define HYPERVISOR_opt_feature xencomm_hypercall_opt_feature
+
+/* to compile gnttab_copy_grant_page() in drivers/xen/core/gnttab.c */
+#define HYPERVISOR_mmu_update(req, count, success_count, domid) ({ BUG(); 0; })
+
+static inline int
+HYPERVISOR_shutdown(
+	unsigned int reason)
+{
+	struct sched_shutdown sched_shutdown = {
+		.reason = reason
+	};
+
+	int rc = HYPERVISOR_sched_op(SCHEDOP_shutdown, &sched_shutdown);
+
+	return rc;
+}
+
+/* for netfront.c, netback.c */
+#define MULTI_UVMFLAGS_INDEX 0 /* XXX any value */
+
+static inline void
+MULTI_update_va_mapping(
+	struct multicall_entry *mcl, unsigned long va,
+	pte_t new_val, unsigned long flags)
+{
+	mcl->op = __HYPERVISOR_update_va_mapping;
+	mcl->result = 0;
+}
+
+static inline void
+MULTI_grant_table_op(struct multicall_entry *mcl, unsigned int cmd,
+	void *uop, unsigned int count)
+{
+	mcl->op = __HYPERVISOR_grant_table_op;
+	mcl->args[0] = cmd;
+	mcl->args[1] = (unsigned long)uop;
+	mcl->args[2] = count;
+}
+
+static inline void
+MULTI_mmu_update(struct multicall_entry *mcl, struct mmu_update *req,
+		 int count, int *success_count, domid_t domid)
+{
+	mcl->op = __HYPERVISOR_mmu_update;
+	mcl->args[0] = (unsigned long)req;
+	mcl->args[1] = count;
+	mcl->args[2] = (unsigned long)success_count;
+	mcl->args[3] = domid;
+}
+
+#endif /* _ASM_IA64_XEN_HYPERCALL_H */
diff --git a/include/asm-ia64/xen/privop.h b/include/asm-ia64/xen/privop.h
new file mode 100644
index 0000000..71ec754
--- /dev/null
+++ b/include/asm-ia64/xen/privop.h
@@ -0,0 +1,129 @@
+#ifndef _ASM_IA64_XEN_PRIVOP_H
+#define _ASM_IA64_XEN_PRIVOP_H
+
+/*
+ * Copyright (C) 2005 Hewlett-Packard Co
+ *	Dan Magenheimer <dan.magenheimer@hp.com>
+ *
+ * Paravirtualizations of privileged operations for Xen/ia64
+ *
+ *
+ * inline privop and paravirt_alt support
+ * Copyright (c) 2007 Isaku Yamahata <yamahata at valinux co jp>
+ *                    VA Linux Systems Japan K.K.
+ *
+ */
+
+#ifndef __ASSEMBLY__
+#include <linux/types.h>		/* arch-ia64.h requires uint64_t */
+#endif
+#include <asm/xen/interface.h>
+
+/* At 1 MB, before per-cpu space but still addressable using addl instead
+   of movl. */
+#define XSI_BASE			0xfffffffffff00000
+
+/* Address of mapped regs.  */
+#define XMAPPEDREGS_BASE		(XSI_BASE + XSI_SIZE)
+
+#ifdef __ASSEMBLY__
+#define XEN_HYPER_RFI			break HYPERPRIVOP_RFI
+#define XEN_HYPER_RSM_PSR_DT		break HYPERPRIVOP_RSM_DT
+#define XEN_HYPER_SSM_PSR_DT		break HYPERPRIVOP_SSM_DT
+#define XEN_HYPER_COVER			break HYPERPRIVOP_COVER
+#define XEN_HYPER_ITC_D			break HYPERPRIVOP_ITC_D
+#define XEN_HYPER_ITC_I			break HYPERPRIVOP_ITC_I
+#define XEN_HYPER_SSM_I			break HYPERPRIVOP_SSM_I
+#define XEN_HYPER_GET_IVR		break HYPERPRIVOP_GET_IVR
+#define XEN_HYPER_THASH			break HYPERPRIVOP_THASH
+#define XEN_HYPER_ITR_D			break HYPERPRIVOP_ITR_D
+#define XEN_HYPER_SET_KR		break HYPERPRIVOP_SET_KR
+#define XEN_HYPER_GET_PSR		break HYPERPRIVOP_GET_PSR
+#define XEN_HYPER_SET_RR0_TO_RR4	break HYPERPRIVOP_SET_RR0_TO_RR4
+
+#define XSI_IFS				(XSI_BASE + XSI_IFS_OFS)
+#define XSI_PRECOVER_IFS		(XSI_BASE + XSI_PRECOVER_IFS_OFS)
+#define XSI_IFA				(XSI_BASE + XSI_IFA_OFS)
+#define XSI_ISR				(XSI_BASE + XSI_ISR_OFS)
+#define XSI_IIM				(XSI_BASE + XSI_IIM_OFS)
+#define XSI_ITIR			(XSI_BASE + XSI_ITIR_OFS)
+#define XSI_PSR_I_ADDR			(XSI_BASE + XSI_PSR_I_ADDR_OFS)
+#define XSI_PSR_IC			(XSI_BASE + XSI_PSR_IC_OFS)
+#define XSI_IPSR			(XSI_BASE + XSI_IPSR_OFS)
+#define XSI_IIP				(XSI_BASE + XSI_IIP_OFS)
+#define XSI_B1NAT			(XSI_BASE + XSI_B1NATS_OFS)
+#define XSI_BANK1_R16			(XSI_BASE + XSI_BANK1_R16_OFS)
+#define XSI_BANKNUM			(XSI_BASE + XSI_BANKNUM_OFS)
+#define XSI_IHA				(XSI_BASE + XSI_IHA_OFS)
+#endif
+
+#ifndef __ASSEMBLY__
+
+/************************************************/
+/* Instructions paravirtualized for correctness */
+/************************************************/
+
+/* "fc" and "thash" are privilege-sensitive instructions, meaning they
+ *  may have different semantics depending on whether they are executed
+ *  at PL0 vs PL!=0.  When paravirtualized, these instructions mustn't
+ *  be allowed to execute directly, lest incorrect semantics result. */
+extern void xen_fc(unsigned long addr);
+extern unsigned long xen_thash(unsigned long addr);
+
+/* Note that "ttag" and "cover" are also privilege-sensitive; "ttag"
+ * is not currently used (though it may be in a long-format VHPT system!)
+ * and the semantics of cover only change if psr.ic is off which is very
+ * rare (and currently non-existent outside of assembly code */
+
+/* There are also privilege-sensitive registers.  These registers are
+ * readable at any privilege level but only writable at PL0. */
+extern unsigned long xen_get_cpuid(int index);
+extern unsigned long xen_get_pmd(int index);
+
+extern unsigned long xen_get_eflag(void);	/* see xen_ia64_getreg */
+extern void xen_set_eflag(unsigned long);	/* see xen_ia64_setreg */
+
+/************************************************/
+/* Instructions paravirtualized for performance */
+/************************************************/
+
+/* Xen uses memory-mapped virtual privileged registers for access to many
+ * performance-sensitive privileged registers.  Some, like the processor
+ * status register (psr), are broken up into multiple memory locations.
+ * Others, like "pend", are abstractions based on privileged registers.
+ * "Pend" is guaranteed to be set if reading cr.ivr would return a
+ * (non-spurious) interrupt. */
+#define XEN_MAPPEDREGS ((struct mapped_regs *)XMAPPEDREGS_BASE)
+
+#define XSI_PSR_I			\
+	(*XEN_MAPPEDREGS->interrupt_mask_addr)
+#define xen_get_virtual_psr_i()		\
+	(!XSI_PSR_I)
+#define xen_set_virtual_psr_i(_val)	\
+	({ XSI_PSR_I = (uint8_t)(_val) ? 0 : 1; })
+#define xen_set_virtual_psr_ic(_val)	\
+	({ XEN_MAPPEDREGS->interrupt_collection_enabled = _val ? 1 : 0; })
+#define xen_get_virtual_pend()		\
+	(*(((uint8_t *)XEN_MAPPEDREGS->interrupt_mask_addr) - 1))
+
+/* Although all privileged operations can be left to trap and will
+ * be properly handled by Xen, some are frequent enough that we use
+ * hyperprivops for performance. */
+extern unsigned long xen_get_psr(void);
+extern unsigned long xen_get_ivr(void);
+extern unsigned long xen_get_tpr(void);
+extern void xen_hyper_ssm_i(void);
+extern void xen_set_itm(unsigned long);
+extern void xen_set_tpr(unsigned long);
+extern void xen_eoi(unsigned long);
+extern unsigned long xen_get_rr(unsigned long index);
+extern void xen_set_rr(unsigned long index, unsigned long val);
+extern void xen_set_rr0_to_rr4(unsigned long val0, unsigned long val1,
+			       unsigned long val2, unsigned long val3,
+			       unsigned long val4);
+extern void xen_set_kr(unsigned long index, unsigned long val);
+extern void xen_ptcga(unsigned long addr, unsigned long size);
+
+#endif /* !__ASSEMBLY__ */
+
+#endif /* _ASM_IA64_XEN_PRIVOP_H */
-- 
1.5.3

