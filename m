From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 05 Mar 2008 18:18:47 +0000
Subject: [PATCH 32/50] ia64/xen: define xen assembler constants which will be used later.
Message-Id: <12047411463153-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/kernel/asm-offsets.c |   25 ++++++++++++++
 include/asm-ia64/xen/privop.h  |   73 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 98 insertions(+), 0 deletions(-)
 create mode 100644 include/asm-ia64/xen/privop.h

diff --git a/arch/ia64/kernel/asm-offsets.c b/arch/ia64/kernel/asm-offsets.c
index 0aebc6f..1a81c64 100644
--- a/arch/ia64/kernel/asm-offsets.c
+++ b/arch/ia64/kernel/asm-offsets.c
@@ -278,4 +278,29 @@ void foo(void)
 		offsetof (struct itc_jitter_data_t, itc_jitter));
 	DEFINE(IA64_ITC_LASTCYCLE_OFFSET,
 		offsetof (struct itc_jitter_data_t, itc_lastcycle));
+
+#ifdef CONFIG_XEN
+	BLANK();
+
+#define DEFINE_MAPPED_REG_OFS(sym, field) \
+	DEFINE(sym, (XMAPPEDREGS_OFS + offsetof(struct mapped_regs, field)))
+
+	DEFINE_MAPPED_REG_OFS(XSI_PSR_I_ADDR_OFS, interrupt_mask_addr);
+	DEFINE_MAPPED_REG_OFS(XSI_IPSR_OFS, ipsr);
+	DEFINE_MAPPED_REG_OFS(XSI_IIP_OFS, iip);
+	DEFINE_MAPPED_REG_OFS(XSI_IFS_OFS, ifs);
+	DEFINE_MAPPED_REG_OFS(XSI_PRECOVER_IFS_OFS, precover_ifs);
+	DEFINE_MAPPED_REG_OFS(XSI_ISR_OFS, isr);
+	DEFINE_MAPPED_REG_OFS(XSI_IFA_OFS, ifa);
+	DEFINE_MAPPED_REG_OFS(XSI_IIPA_OFS, iipa);
+	DEFINE_MAPPED_REG_OFS(XSI_IIM_OFS, iim);
+	DEFINE_MAPPED_REG_OFS(XSI_IHA_OFS, iha);
+	DEFINE_MAPPED_REG_OFS(XSI_ITIR_OFS, itir);
+	DEFINE_MAPPED_REG_OFS(XSI_PSR_IC_OFS, interrupt_collection_enabled);
+	DEFINE_MAPPED_REG_OFS(XSI_BANKNUM_OFS, banknum);
+	DEFINE_MAPPED_REG_OFS(XSI_BANK0_R16_OFS, bank0_regs[0]);
+	DEFINE_MAPPED_REG_OFS(XSI_BANK1_R16_OFS, bank1_regs[0]);
+	DEFINE_MAPPED_REG_OFS(XSI_B0NATS_OFS, vbnat);
+	DEFINE_MAPPED_REG_OFS(XSI_B1NATS_OFS, vnat);
+#endif /* CONFIG_XEN */
 }
diff --git a/include/asm-ia64/xen/privop.h b/include/asm-ia64/xen/privop.h
new file mode 100644
index 0000000..dd3e5ec
--- /dev/null
+++ b/include/asm-ia64/xen/privop.h
@@ -0,0 +1,73 @@
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
+#include <linux/stringify.h>
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
+#define XEN_HYPER_GET_TPR		break HYPERPRIVOP_GET_TPR
+#define XEN_HYPER_SET_TPR		break HYPERPRIVOP_SET_TPR
+#define XEN_HYPER_EOI			break HYPERPRIVOP_EOI
+#define XEN_HYPER_SET_ITM		break HYPERPRIVOP_SET_ITM
+#define XEN_HYPER_THASH			break HYPERPRIVOP_THASH
+#define XEN_HYPER_PTC_GA		break HYPERPRIVOP_PTC_GA
+#define XEN_HYPER_ITR_D			break HYPERPRIVOP_ITR_D
+#define XEN_HYPER_GET_RR		break HYPERPRIVOP_GET_RR
+#define XEN_HYPER_SET_RR		break HYPERPRIVOP_SET_RR
+#define XEN_HYPER_SET_KR		break HYPERPRIVOP_SET_KR
+#define XEN_HYPER_FC			break HYPERPRIVOP_FC
+#define XEN_HYPER_GET_CPUID		break HYPERPRIVOP_GET_CPUID
+#define XEN_HYPER_GET_PMD		break HYPERPRIVOP_GET_PMD
+#define XEN_HYPER_GET_EFLAG		break HYPERPRIVOP_GET_EFLAG
+#define XEN_HYPER_SET_EFLAG		break HYPERPRIVOP_SET_EFLAG
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
+#endif /* _ASM_IA64_XEN_PRIVOP_H */
-- 
1.5.3

