From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 05 Mar 2008 18:18:34 +0000
Subject: [PATCH 19/50] ia64/pv_ops: define ia64 privileged instruction intrinsics for paravirtualized guest k
Message-Id: <12047411461061-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Make ia64 privileged instruction intrinsics paravirtualizable with binary
patching allowing each pv instances to override each intrinsics.
Mark privileged instructions which needs paravirtualization and allow pv
instance can binary patch at early boot time.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/kernel/paravirtentry.S   |   37 +++
 include/asm-ia64/privop.h          |    4 +
 include/asm-ia64/privop_paravirt.h |  587 ++++++++++++++++++++++++++++++++++++
 3 files changed, 628 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/kernel/paravirtentry.S
 create mode 100644 include/asm-ia64/privop_paravirt.h

diff --git a/arch/ia64/kernel/paravirtentry.S b/arch/ia64/kernel/paravirtentry.S
new file mode 100644
index 0000000..013511f
--- /dev/null
+++ b/arch/ia64/kernel/paravirtentry.S
@@ -0,0 +1,37 @@
+/******************************************************************************
+ * linux/arch/ia64/xen/paravirtentry.S
+ *
+ * Copyright (c) 2007 Isaku Yamahata <yamahata at valinux co jp>
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
+#include <asm/types.h>
+#include <asm/asmmacro.h>
+#include <asm/paravirt_entry.h>
+#include <asm/privop_paravirt.h>
+
+#define BRANCH(sym, type)					\
+	GLOBAL_ENTRY(paravirt_ ## sym) ;			\
+		BR_COND_SPTK_MANY(native_ ## sym, type) ;	\
+	END(paravirt_ ## sym)
+
+	BRANCH(switch_to,		PARAVIRT_ENTRY_SWITCH_TO)
+	BRANCH(leave_syscall,		PARAVIRT_ENTRY_LEAVE_SYSCALL)
+	BRANCH(work_processed_syscall,	PARAVIRT_ENTRY_WORK_PROCESSED_SYSCALL)
+	BRANCH(leave_kernel,		PARAVIRT_ENTRY_LEAVE_KERNEL)
+	BRANCH(pal_call_static,		PARAVIRT_ENTRY_PAL_CALL_STATIC)
diff --git a/include/asm-ia64/privop.h b/include/asm-ia64/privop.h
index b0b74fd..69591e0 100644
--- a/include/asm-ia64/privop.h
+++ b/include/asm-ia64/privop.h
@@ -10,6 +10,10 @@
  *
  */
 
+#ifdef CONFIG_PARAVIRT
+#include <asm/privop_paravirt.h>
+#endif
+
 #ifdef CONFIG_XEN
 #include <asm/xen/privop.h>
 #endif
diff --git a/include/asm-ia64/privop_paravirt.h b/include/asm-ia64/privop_paravirt.h
new file mode 100644
index 0000000..bd7de70
--- /dev/null
+++ b/include/asm-ia64/privop_paravirt.h
@@ -0,0 +1,587 @@
+/******************************************************************************
+ * privops_paravirt.h
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
+#ifndef _ASM_IA64_PRIVOP_PARAVIRT_H
+#define _ASM_IA64_PRIVOP_PARAVIRT_H
+
+#define PARAVIRT_INST_START			0x1
+#define PARAVIRT_INST_RFI			(PARAVIRT_INST_START + 0x0)
+#define PARAVIRT_INST_RSM_DT			(PARAVIRT_INST_START + 0x1)
+#define PARAVIRT_INST_SSM_DT			(PARAVIRT_INST_START + 0x2)
+#define PARAVIRT_INST_COVER			(PARAVIRT_INST_START + 0x3)
+#define PARAVIRT_INST_ITC_D			(PARAVIRT_INST_START + 0x4)
+#define PARAVIRT_INST_ITC_I			(PARAVIRT_INST_START + 0x5)
+#define PARAVIRT_INST_SSM_I			(PARAVIRT_INST_START + 0x6)
+#define PARAVIRT_INST_GET_IVR			(PARAVIRT_INST_START + 0x7)
+#define PARAVIRT_INST_GET_TPR			(PARAVIRT_INST_START + 0x8)
+#define PARAVIRT_INST_SET_TPR			(PARAVIRT_INST_START + 0x9)
+#define PARAVIRT_INST_EOI			(PARAVIRT_INST_START + 0xa)
+#define PARAVIRT_INST_SET_ITM			(PARAVIRT_INST_START + 0xb)
+#define PARAVIRT_INST_THASH			(PARAVIRT_INST_START + 0xc)
+#define PARAVIRT_INST_PTC_GA			(PARAVIRT_INST_START + 0xd)
+#define PARAVIRT_INST_ITR_D			(PARAVIRT_INST_START + 0xe)
+#define PARAVIRT_INST_GET_RR			(PARAVIRT_INST_START + 0xf)
+#define PARAVIRT_INST_SET_RR			(PARAVIRT_INST_START + 0x10)
+#define PARAVIRT_INST_SET_KR			(PARAVIRT_INST_START + 0x11)
+#define PARAVIRT_INST_FC			(PARAVIRT_INST_START + 0x12)
+#define PARAVIRT_INST_GET_CPUID			(PARAVIRT_INST_START + 0x13)
+#define PARAVIRT_INST_GET_PMD			(PARAVIRT_INST_START + 0x14)
+#define PARAVIRT_INST_GET_EFLAG			(PARAVIRT_INST_START + 0x15)
+#define PARAVIRT_INST_SET_EFLAG			(PARAVIRT_INST_START + 0x16)
+#define PARAVIRT_INST_RSM_BE			(PARAVIRT_INST_START + 0x17)
+#define PARAVIRT_INST_GET_PSR			(PARAVIRT_INST_START + 0x18)
+#define PARAVIRT_INST_SET_RR0_TO_RR4		(PARAVIRT_INST_START + 0x19)
+
+#define PARAVIRT_BNDL_START			0x10000000
+#define PARAVIRT_BNDL_SSM_I			(PARAVIRT_BNDL_START + 0x0)
+#define PARAVIRT_BNDL_RSM_I			(PARAVIRT_BNDL_START + 0x1)
+#define PARAVIRT_BNDL_GET_PSR_I			(PARAVIRT_BNDL_START + 0x2)
+#define PARAVIRT_BNDL_INTRIN_LOCAL_IRQ_RESTORE	(PARAVIRT_BNDL_START + 0x3)
+
+/*
+ * struct task_struct* (*ia64_switch_to)(void* next_task);
+ * void *ia64_leave_syscall;
+ * void *ia64_work_processed_syscall
+ * void *ia64_leave_kernel;
+ * struct ia64_pal_retval (*pal_call_static)(u64, u64, u64, u64, u64);
+ */
+
+#define PARAVIRT_ENTRY_START			0x20000000
+#define PARAVIRT_ENTRY_SWITCH_TO		(PARAVIRT_ENTRY_START + 0)
+#define PARAVIRT_ENTRY_LEAVE_SYSCALL		(PARAVIRT_ENTRY_START + 1)
+#define PARAVIRT_ENTRY_WORK_PROCESSED_SYSCALL	(PARAVIRT_ENTRY_START + 2)
+#define PARAVIRT_ENTRY_LEAVE_KERNEL		(PARAVIRT_ENTRY_START + 3)
+#define PARAVIRT_ENTRY_PAL_CALL_STATIC		(PARAVIRT_ENTRY_START + 4)
+
+
+#ifndef __ASSEMBLER__
+
+#include <linux/stringify.h>
+#include <linux/types.h>
+#include <asm/paravirt_alt.h>
+#include <asm/kregs.h> /* for IA64_PSR_I */
+#include <asm/xen/interface.h>
+
+/************************************************/
+/* Instructions paravirtualized for correctness */
+/************************************************/
+/* Note that "ttag" and "cover" are also privilege-sensitive; "ttag"
+ * is not currently used (though it may be in a long-format VHPT system!) */
+#ifdef ASM_SUPPORTED
+static inline unsigned long
+paravirt_fc(unsigned long addr)
+{
+	register __u64 ia64_intri_res asm ("r8");
+	register __u64 __addr asm ("r8") = addr;
+	asm volatile (paravirt_alt_inst("fc %1", PARAVIRT_INST_THASH):
+		      "=r"(ia64_intri_res): "0"(__addr): "memory");
+	return ia64_intri_res;
+}
+#define paravirt_fc(addr)	paravirt_fc((unsigned long)addr)
+
+static inline unsigned long
+paravirt_thash(unsigned long addr)
+{
+	register __u64 ia64_intri_res asm ("r8");
+	register __u64 __addr asm ("r8") = addr;
+	asm volatile (paravirt_alt_inst("thash %0=%1", PARAVIRT_INST_THASH):
+		      "=r"(ia64_intri_res): "0"(__addr));
+	return ia64_intri_res;
+}
+
+static inline unsigned long
+paravirt_get_cpuid(int index)
+{
+	register __u64 ia64_intri_res asm ("r8");
+	register __u64 __index asm ("r8") = index;
+	asm volatile (paravirt_alt_inst("mov %0=cpuid[%r1]",
+				   PARAVIRT_INST_GET_CPUID):
+		      "=r"(ia64_intri_res): "0O"(__index));
+	return ia64_intri_res;
+}
+
+static inline unsigned long
+paravirt_get_pmd(int index)
+{
+	register __u64 ia64_intri_res asm ("r8");
+	register __u64 __index asm ("r8") = index;
+	asm volatile (paravirt_alt_inst("mov %0=pmd[%1]",
+					PARAVIRT_INST_GET_PMD):
+		      "=r"(ia64_intri_res): "0"(__index));
+	return ia64_intri_res;
+}
+
+static inline unsigned long
+paravirt_get_eflag(void)
+{
+	register __u64 ia64_intri_res asm ("r8");
+	asm volatile (paravirt_alt_inst("mov %0=ar%1",
+					PARAVIRT_INST_GET_EFLAG):
+		"=r"(ia64_intri_res):
+		"i"(_IA64_REG_AR_EFLAG - _IA64_REG_AR_KR0): "memory");
+	return ia64_intri_res;
+}
+
+static inline void
+paravirt_set_eflag(unsigned long val)
+{
+	register __u64 __val asm ("r8") = val;
+	asm volatile (paravirt_alt_inst("mov ar%0=%1",
+					PARAVIRT_INST_SET_EFLAG)::
+		      "i"(_IA64_REG_AR_EFLAG - _IA64_REG_AR_KR0), "r"(__val):
+		      "memory");
+}
+
+/************************************************/
+/* Instructions paravirtualized for performance */
+/************************************************/
+
+static inline unsigned long
+paravirt_get_psr(void)
+{
+	register __u64 ia64_intri_res asm ("r8");
+	asm volatile (paravirt_alt_inst("mov %0=psr", PARAVIRT_INST_GET_PSR):
+		      "=r"(ia64_intri_res));
+	return ia64_intri_res;
+}
+
+static inline unsigned long
+paravirt_get_ivr(void)
+{
+	register __u64 ia64_intri_res asm ("r8");
+	asm volatile (paravirt_alt_inst("mov %0=cr%1", PARAVIRT_INST_GET_IVR):
+		      "=r"(ia64_intri_res):
+		      "i" (_IA64_REG_CR_IVR - _IA64_REG_CR_DCR));
+	return ia64_intri_res;
+}
+
+static inline unsigned long
+paravirt_get_tpr(void)
+{
+	register __u64 ia64_intri_res asm ("r8");
+	asm volatile (paravirt_alt_inst("mov %0=cr%1", PARAVIRT_INST_GET_TPR):
+		      "=r"(ia64_intri_res):
+		      "i" (_IA64_REG_CR_TPR - _IA64_REG_CR_DCR));
+	return ia64_intri_res;
+}
+
+static inline void
+paravirt_set_tpr(unsigned long val)
+{
+	register __u64 __val asm ("r8") = val;
+	asm volatile (paravirt_alt_inst("mov cr%0=%1", PARAVIRT_INST_SET_TPR)::
+		      "i" (_IA64_REG_CR_TPR - _IA64_REG_CR_DCR), "r"(__val):
+		      "memory");
+}
+
+static inline void
+paravirt_eoi(unsigned long val)
+{
+	register __u64 __val asm ("r8") = val;
+	asm volatile (paravirt_alt_inst("mov cr%0=%1", PARAVIRT_INST_EOI)::
+		      "i" (_IA64_REG_CR_EOI - _IA64_REG_CR_DCR), "r"(__val):
+		      "memory");
+}
+
+static inline void
+paravirt_set_itm(unsigned long val)
+{
+	register __u64 __val asm ("r8") = val;
+	asm volatile (paravirt_alt_inst("mov cr%0=%1", PARAVIRT_INST_SET_ITM)::
+		      "i" (_IA64_REG_CR_ITM - _IA64_REG_CR_DCR), "r"(__val):
+		      "memory");
+}
+
+static inline void
+paravirt_ptcga(unsigned long addr, unsigned long size)
+{
+	register __u64 __addr asm ("r8") = addr;
+	register __u64 __size asm ("r9") = size;
+	asm volatile (paravirt_alt_inst("ptc.ga %0,%1", PARAVIRT_INST_PTC_GA)::
+		      "r"(__addr), "r"(__size): "memory");
+	ia64_dv_serialize_data();
+}
+
+static inline unsigned long
+paravirt_get_rr(unsigned long index)
+{
+	register __u64 ia64_intri_res asm ("r8");
+	register __u64 __index asm ("r8") = index;
+	asm volatile (paravirt_alt_inst("mov %0=rr[%1]", PARAVIRT_INST_GET_RR):
+		      "=r"(ia64_intri_res) : "0" (__index));
+	return ia64_intri_res;
+}
+
+static inline void
+paravirt_set_rr(unsigned long index, unsigned long val)
+{
+	register __u64 __index asm ("r8") = index;
+	register __u64 __val asm ("r9") = val;
+	asm volatile (paravirt_alt_inst("mov rr[%0]=%1", PARAVIRT_INST_SET_RR)::
+		      "r"(__index), "r"(__val): "memory");
+}
+
+static inline void
+paravirt_set_rr0_to_rr4(unsigned long val0, unsigned long val1,
+			unsigned long val2, unsigned long val3,
+			unsigned long val4)
+{
+	register __u64 __val0 asm ("r8") = val0;
+	register __u64 __val1 asm ("r9") = val1;
+	register __u64 __val2 asm ("r10") = val2;
+	register __u64 __val3 asm ("r11") = val3;
+	register __u64 __val4 asm ("r14") = val4;
+	asm volatile (paravirt_alt_inst("\t;;\n"
+					"\t{.mmi\n"
+					"\tmov rr[%0]=%1\n"
+					/*
+					 * without this stop bit
+					 * assembler complains.
+					 */
+					"\t;;\n"
+					"\tmov rr[%2]=%3\n"
+					"\tnop.i 0\n"
+					"\t}\n"
+					"\t{.mmi\n"
+					"\tmov rr[%4]=%5\n"
+					"\tmov rr[%6]=%7\n"
+					"\tnop.i 0\n"
+					"\t}\n"
+					"\tmov rr[%8]=%9;;\n",
+					PARAVIRT_INST_SET_RR0_TO_RR4)::
+		      "r"(0x0000000000000000UL), "r"(__val0),
+		      "r"(0x2000000000000000UL), "r"(__val1),
+		      "r"(0x4000000000000000UL), "r"(__val2),
+		      "r"(0x6000000000000000UL), "r"(__val3),
+		      "r"(0x8000000000000000UL), "r"(__val4) :
+		      "memory");
+}
+
+static inline void
+paravirt_set_kr(unsigned long index, unsigned long val)
+{
+	register __u64 __index asm ("r8") = index - _IA64_REG_AR_KR0;
+	register __u64 __val asm ("r9") = val;
+
+	/*
+	 * asm volatile ("break %0"::
+	 *	      "i"(PARAVIRT_INST_SET_KR), "r"(__index), "r"(__val));
+	 */
+#ifndef BUILD_BUG_ON
+#define BUILD_BUG_ON(condition) ((void)sizeof(char[1 - 2*!!(condition)]))
+#endif
+	BUILD_BUG_ON(!__builtin_constant_p(__index));
+	switch (index) {
+	case _IA64_REG_AR_KR0:
+		asm volatile (paravirt_alt_inst("mov ar%0=%2",
+					   PARAVIRT_INST_SET_KR)::
+			      "i" (_IA64_REG_AR_KR0 - _IA64_REG_AR_KR0),
+			      "r"(__index), "r"(__val):
+			      "memory");
+		break;
+	case _IA64_REG_AR_KR1:
+		asm volatile (paravirt_alt_inst("mov ar%0=%2",
+					   PARAVIRT_INST_SET_KR)::
+			      "i" (_IA64_REG_AR_KR1 - _IA64_REG_AR_KR0),
+			      "r"(__index), "r"(__val):
+			      "memory");
+		break;
+	case _IA64_REG_AR_KR2:
+		asm volatile (paravirt_alt_inst("mov ar%0=%2",
+					    PARAVIRT_INST_SET_KR)::
+			      "i" (_IA64_REG_AR_KR2 - _IA64_REG_AR_KR0),
+			      "r"(__index), "r"(__val):
+			      "memory");
+		break;
+	case _IA64_REG_AR_KR3:
+		asm volatile (paravirt_alt_inst("mov ar%0=%2",
+					   PARAVIRT_INST_SET_KR)::
+			      "i" (_IA64_REG_AR_KR3 - _IA64_REG_AR_KR0),
+			      "r"(__index), "r"(__val):
+			      "memory");
+		break;
+	case _IA64_REG_AR_KR4:
+		asm volatile (paravirt_alt_inst("mov ar%0=%2",
+					   PARAVIRT_INST_SET_KR)::
+			      "i" (_IA64_REG_AR_KR4 - _IA64_REG_AR_KR0),
+			      "r"(__index), "r"(__val):
+			      "memory");
+		break;
+	case _IA64_REG_AR_KR5:
+		asm volatile (paravirt_alt_inst("mov ar%0=%2",
+					   PARAVIRT_INST_SET_KR)::
+			      "i" (_IA64_REG_AR_KR5 - _IA64_REG_AR_KR0),
+			      "r"(__index), "r"(__val):
+			      "memory");
+		break;
+	case _IA64_REG_AR_KR6:
+		asm volatile (paravirt_alt_inst("mov ar%0=%2",
+					   PARAVIRT_INST_SET_KR)::
+			      "i" (_IA64_REG_AR_KR6 - _IA64_REG_AR_KR0),
+			      "r"(__index), "r"(__val):
+			      "memory");
+		break;
+	case _IA64_REG_AR_KR7:
+		asm volatile (paravirt_alt_inst("mov ar%0=%2",
+					   PARAVIRT_INST_SET_KR)::
+			      "i" (_IA64_REG_AR_KR7 - _IA64_REG_AR_KR0),
+			      "r"(__index), "r"(__val):
+			      "memory");
+		break;
+	default: {
+		extern void compile_error_ar_kr_index_must_be_copmile_time_constant(void);
+		compile_error_ar_kr_index_must_be_copmile_time_constant();
+		break;
+	}
+	}
+}
+#endif /* ASM_SUPPORTED */
+
+static inline unsigned long
+paravirt_getreg(unsigned long regnum)
+{
+	__u64 ia64_intri_res;
+
+	switch (regnum) {
+	case _IA64_REG_PSR:
+		ia64_intri_res = paravirt_get_psr();
+		break;
+	case _IA64_REG_CR_IVR:
+		ia64_intri_res = paravirt_get_ivr();
+		break;
+	case _IA64_REG_CR_TPR:
+		ia64_intri_res = paravirt_get_tpr();
+		break;
+	case _IA64_REG_AR_EFLAG:
+		ia64_intri_res = paravirt_get_eflag();
+		break;
+	default:
+		ia64_intri_res = native_getreg(regnum);
+		break;
+	}
+	return ia64_intri_res;
+ }
+
+static inline void
+paravirt_setreg(unsigned long regnum, unsigned long val)
+{
+	switch (regnum) {
+	case _IA64_REG_AR_KR0 ... _IA64_REG_AR_KR7:
+		paravirt_set_kr(regnum, val);
+		break;
+	case _IA64_REG_CR_ITM:
+		paravirt_set_itm(val);
+		break;
+	case _IA64_REG_CR_TPR:
+		paravirt_set_tpr(val);
+		break;
+	case _IA64_REG_CR_EOI:
+		paravirt_eoi(val);
+		break;
+	case _IA64_REG_AR_EFLAG:
+		paravirt_set_eflag(val);
+		break;
+	default:
+		native_setreg(regnum, val);
+		break;
+	}
+}
+
+#ifdef ASM_SUPPORTED
+
+#define NOP_BUNDLE				\
+	"{\n\t"					\
+	"nop 0\n\t"				\
+	"nop 0\n\t"				\
+	"nop 0\n\t"				\
+	"}\n\t"
+
+static inline void
+paravirt_ssm_i(void)
+{
+	/* five bundles */
+	asm volatile (paravirt_alt_bundle("{\n\t"
+					  "ssm psr.i\n\t"
+					  "nop 0\n\t"
+					  "nop 0\n\t"
+					  "}\n\t"
+					  NOP_BUNDLE
+					  NOP_BUNDLE
+					  NOP_BUNDLE
+					  NOP_BUNDLE,
+					  PARAVIRT_BNDL_SSM_I):::
+		      "r8", "r9", "r10",
+		      "p6", "p7",
+		      "memory");
+}
+
+static inline void
+paravirt_rsm_i(void)
+{
+	/* two budles */
+	asm volatile (paravirt_alt_bundle("{\n\t"
+					  "rsm psr.i\n\t"
+					  "nop 0\n\t"
+					  "nop 0\n\t"
+					  "}\n\t"
+					  NOP_BUNDLE,
+					  PARAVIRT_BNDL_RSM_I):::
+		      "r8", "r9",
+		      "memory");
+}
+
+static inline unsigned long
+paravirt_get_psr_i(void)
+{
+	register unsigned long psr_i asm ("r8");
+	register unsigned long mask asm ("r9");
+
+	/* three bundles */
+	asm volatile (paravirt_alt_bundle("{\n\t"
+					  "mov %0=psr\n\t"
+					  "mov %1=%2\n\t"
+					  ";;\n\t"
+					  "and %0=%0,%1\n\t"
+					  "}\n\t"
+					  NOP_BUNDLE
+					  NOP_BUNDLE,
+					  PARAVIRT_BNDL_GET_PSR_I):
+		      "=r"(psr_i),
+		      "=r"(mask)
+		      :
+		      "i"(IA64_PSR_I)
+		      :
+		      /* "r8", "r9", */
+		      "p6");
+	return psr_i;
+}
+
+static inline void
+paravirt_intrin_local_irq_restore(unsigned long flags)
+{
+	register unsigned long __flags asm ("r8") = flags;
+
+	/* six bundles */
+	asm volatile (paravirt_alt_bundle(";;\n\t"
+					  "{\n\t"
+					  "cmp.ne p6,p7=%0,r0;;\n\t"
+					  "(p6) ssm psr.i;\n\t"
+					  "nop 0\n\t"
+					  "}\n\t"
+					  "{\n\t"
+					  "(p7) rsm psr.i;;\n\t"
+					  "(p6) srlz.d\n\t"
+					  "nop 0\n\t"
+					  "}\n\t"
+					  NOP_BUNDLE
+					  NOP_BUNDLE
+					  NOP_BUNDLE
+					  NOP_BUNDLE,
+					  PARAVIRT_BNDL_INTRIN_LOCAL_IRQ_RESTORE)::
+		      "r"(__flags) :
+		      /* "r8",*/ "r9", "r10", "r11",
+		      "p6", "p7", "p8", "p9",
+		      "memory");
+
+}
+
+#undef NOP_BUNDLE
+
+#endif /* ASM_SUPPORTED */
+
+static inline void
+paravirt_ssm(unsigned long mask)
+{
+	if (mask = IA64_PSR_I)
+		paravirt_ssm_i();
+	else
+		native_ssm(mask);
+}
+
+static inline void
+paravirt_rsm(unsigned long mask)
+{
+	if (mask = IA64_PSR_I)
+		paravirt_rsm_i();
+	else
+		native_rsm(mask);
+}
+
+#if defined(ASM_SUPPORTED) && defined(CONFIG_PARAVIRT_ALT)
+
+#define IA64_PARAVIRTUALIZED_PRIVOP
+
+#define ia64_fc(addr)			paravirt_fc(addr)
+#define ia64_thash(addr)		paravirt_thash(addr)
+#define ia64_get_cpuid(i)		paravirt_get_cpuid(i)
+#define ia64_get_pmd(i)			paravirt_get_pmd(i)
+#define ia64_ptcga(addr, size)		paravirt_ptcga((addr), (size))
+#define ia64_set_rr(index, val)		paravirt_set_rr((index), (val))
+#define ia64_get_rr(index)		paravirt_get_rr(index)
+#define ia64_getreg(regnum)		paravirt_getreg(regnum)
+#define ia64_setreg(regnum, val)	paravirt_setreg((regnum), (val))
+#define ia64_set_rr0_to_rr4(val0, val1, val2, val3, val4)		\
+	paravirt_set_rr0_to_rr4((val0), (val1), (val2), (val3), (val4))
+
+#define ia64_ssm(mask)			paravirt_ssm(mask)
+#define ia64_rsm(mask)			paravirt_rsm(mask)
+#define ia64_get_psr_i()		paravirt_get_psr_i()
+#define ia64_intrin_local_irq_restore(x)	\
+	paravirt_intrin_local_irq_restore(x)
+
+/* the remainder of these are not performance-sensitive so its
+ * OK to not paravirtualize and just take a privop trap and emulate */
+#define ia64_hint			native_hint
+#define ia64_set_pmd			native_set_pmd
+#define ia64_itci			native_itci
+#define ia64_itcd			native_itcd
+#define ia64_itri			native_itri
+#define ia64_itrd			native_itrd
+#define ia64_tpa			native_tpa
+#define ia64_set_ibr			native_set_ibr
+#define ia64_set_pkr			native_set_pkr
+#define ia64_set_pmc			native_set_pmc
+#define ia64_get_ibr			native_get_ibr
+#define ia64_get_pkr			native_get_pkr
+#define ia64_get_pmc			native_get_pmc
+#define ia64_ptce			native_ptce
+#define ia64_ptcl			native_ptcl
+#define ia64_ptri			native_ptri
+#define ia64_ptrd			native_ptrd
+
+#endif /* ASM_SUPPORTED && CONFIG_PARAVIRT_ALT */
+
+#endif /* __ASSEMBLER__*/
+
+/* these routines utilize privilege-sensitive or performance-sensitive
+ * privileged instructions so the code must be replaced with
+ * paravirtualized versions */
+#ifdef CONFIG_PARAVIRT_ENTRY
+#define IA64_PARAVIRTUALIZED_ENTRY
+#define ia64_switch_to			paravirt_switch_to
+#define ia64_work_processed_syscall	paravirt_work_processed_syscall
+#define ia64_leave_syscall		paravirt_leave_syscall
+#define ia64_leave_kernel		paravirt_leave_kernel
+#define ia64_pal_call_static		paravirt_pal_call_static
+#endif /* CONFIG_PARAVIRT_ENTRY */
+
+#endif /* _ASM_IA64_PRIVOP_PARAVIRT_H */
-- 
1.5.3

