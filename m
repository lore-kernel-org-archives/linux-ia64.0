From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Tue, 26 Aug 2008 05:58:32 +0000
Subject: [PATCH 20/30] ia64/pv_ops/xen: paravirtualize ivt.S for xen.
Message-Id: <1219730322-11687-21-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

paravirtualize ivt.S for xen by multi compile.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/include/asm/xen/inst.h |    1 +
 arch/ia64/xen/Makefile           |   16 +++++++++++-
 arch/ia64/xen/xenivt.S           |   52 ++++++++++++++++++++++++++++++++++++++
 3 files changed, 68 insertions(+), 1 deletions(-)
 create mode 100644 arch/ia64/xen/xenivt.S

diff --git a/arch/ia64/include/asm/xen/inst.h b/arch/ia64/include/asm/xen/inst.h
index 1e92ed0..e6a25c3 100644
--- a/arch/ia64/include/asm/xen/inst.h
+++ b/arch/ia64/include/asm/xen/inst.h
@@ -22,6 +22,7 @@
 
 #include <asm/xen/privop.h>
 
+#define ia64_ivt				xen_ivt
 #define DO_SAVE_MIN				XEN_DO_SAVE_MIN
 
 #define MOV_FROM_IFA(reg)	\
diff --git a/arch/ia64/xen/Makefile b/arch/ia64/xen/Makefile
index 7cb4247..5c87e4a 100644
--- a/arch/ia64/xen/Makefile
+++ b/arch/ia64/xen/Makefile
@@ -2,5 +2,19 @@
 # Makefile for Xen components
 #
 
-obj-y := hypercall.o xensetup.o xen_pv_ops.o \
+obj-y := hypercall.o xenivt.o xensetup.o xen_pv_ops.o \
 	 hypervisor.o xencomm.o xcom_hcall.o grant-table.o
+
+AFLAGS_xenivt.o += -D__IA64_ASM_PARAVIRTUALIZED_XEN
+
+# xen multi compile
+ASM_PARAVIRT_MULTI_COMPILE_SRCS = ivt.S
+ASM_PARAVIRT_OBJS = $(addprefix xen-,$(ASM_PARAVIRT_MULTI_COMPILE_SRCS:.S=.o))
+obj-y += $(ASM_PARAVIRT_OBJS)
+define paravirtualized_xen
+AFLAGS_$(1) += -D__IA64_ASM_PARAVIRTUALIZED_XEN
+endef
+$(foreach o,$(ASM_PARAVIRT_OBJS),$(eval $(call paravirtualized_xen,$(o))))
+
+$(obj)/xen-%.o: $(src)/../kernel/%.S FORCE
+	$(call if_changed_dep,as_o_S)
diff --git a/arch/ia64/xen/xenivt.S b/arch/ia64/xen/xenivt.S
new file mode 100644
index 0000000..3e71d50
--- /dev/null
+++ b/arch/ia64/xen/xenivt.S
@@ -0,0 +1,52 @@
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
+	br.sptk.many xen_leave_kernel	// we know ia64_leave_kernel is
+					// paravirtualized as xen_leave_kernel
+END(xen_event_callback)
-- 
1.6.0.rc0.42.g186458

