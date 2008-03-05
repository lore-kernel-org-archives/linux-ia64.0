From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 05 Mar 2008 18:18:49 +0000
Subject: [PATCH 34/50] ia64/xen: helper functions for xen fault handlers.
Message-Id: <12047411461064-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/xen/xenivt.S |   59 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 59 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/xen/xenivt.S

diff --git a/arch/ia64/xen/xenivt.S b/arch/ia64/xen/xenivt.S
new file mode 100644
index 0000000..99bb37a
--- /dev/null
+++ b/arch/ia64/xen/xenivt.S
@@ -0,0 +1,59 @@
+/*
+ * arch/ia64/xen/ivt.S
+ *
+ * Copyright (C) 2005 Hewlett-Packard Co
+ *	Dan Magenheimer <dan.magenheimer@hp.com>
+ *
+ * Copyright (c) 2008 Isaku Yamahata <yamahata at valinux co jp>
+ *                    VA Linux Systems Japan K.K.
+ *                    pv_ops.
+ */
+
+#include <asm/asmmacro.h>
+#include <asm/kregs.h>
+#include <asm/pgtable.h>
+
+#define __IA64_ASM_PARAVIRTUALIZED_XEN
+#include "inst_xen.h"
+#include "xenminstate.h"
+#include "../kernel/minstate.h"
+
+	.section .text,"ax"
+GLOBAL_ENTRY(xen_event_callback)
+	mov r31=pr		// prepare to save predicates
+	;;
+	SAVE_MIN_WITH_COVER	// uses r31; defines r2 and r3
+	;;
+	movl r3=XSI_PSR_IC
+	mov r14=1
+	;;
+	st4 [r3]=r14
+	;;
+	adds r3=8,r2		// set up second base pointer for SAVE_REST
+	srlz.i			// ensure everybody knows psr.ic is back on
+	;;
+	SAVE_REST
+	;;
+1:
+	alloc r14=ar.pfs,0,0,1,0 // must be first in an insn group
+	add out0,sp		// pass pointer to pt_regs as first arg
+	;;
+	br.call.sptk.many b0=xen_evtchn_do_upcall
+	;;
+	movl r20=XSI_PSR_I_ADDR
+	;;
+	ld8 r20=[r20]
+	;;
+	adds r20=-1,r20		// vcpu_info->evtchn_upcall_pending
+	;;
+	ld1 r20=[r20]
+	;;
+	cmp.ne p6,p0=r20,r0	// if there are pending events,
+	(p6) br.spnt.few 1b	// call evtchn_do_upcall again.
+	br.sptk.many ia64_leave_kernel
+END(xen_event_callback)
+
+GLOBAL_ENTRY(xen_bsw1)
+	XEN_BSW_1(r14)
+	br.ret.sptk.many b0
+END(xen_bsw1)
-- 
1.5.3

