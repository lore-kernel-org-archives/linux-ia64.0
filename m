From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Thu, 17 Jul 2008 02:10:38 +0000
Subject: [PATCH 06/29] ia64/xen: define several constants for ia64/xen.
Message-Id: <12162606623056-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

define several constants for ia64/xen.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/kernel/asm-offsets.c |   27 +++++++++++++++++++++++++++
 1 files changed, 27 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/kernel/asm-offsets.c b/arch/ia64/kernel/asm-offsets.c
index c64a55a..6bd3fc5 100644
--- a/arch/ia64/kernel/asm-offsets.c
+++ b/arch/ia64/kernel/asm-offsets.c
@@ -16,6 +16,8 @@
 #include <asm-ia64/sigcontext.h>
 #include <asm-ia64/mca.h>
 
+#include <asm-ia64/xen/interface.h>
+
 #include "../kernel/sigframe.h"
 #include "../kernel/fsyscall_gtod_data.h"
 
@@ -286,4 +288,29 @@ void foo(void)
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
-- 
1.5.3

