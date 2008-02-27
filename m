From: Akio Takebe <takebe_akio@jp.fujitsu.com>
Date: Wed, 27 Feb 2008 01:35:33 +0000
Subject: Re: [Xen-ia64-devel] [PATCH 7/8] ia64/xen: paravirtualize minstate.h, DO_SAVE_MIN.
Message-Id: <6C878E10BB9F9takebe_akio@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <5C878E08C9E9Btakebe_akio@jp.fujitsu.com>
In-Reply-To: <5C878E08C9E9Btakebe_akio@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi, Isaku

>Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
>---
> arch/ia64/xen/xenminstate.h |  148 ++++++++++++++++++++++++++++++++++++++++
>+++
> 1 files changed, 148 insertions(+), 0 deletions(-)
> create mode 100644 arch/ia64/xen/xenminstate.h
>
>diff --git a/arch/ia64/xen/xenminstate.h b/arch/ia64/xen/xenminstate.h
>new file mode 100644
>index 0000000..cdaf910
>--- /dev/null
>+++ b/arch/ia64/xen/xenminstate.h
>@@ -0,0 +1,148 @@
>+#include <asm/cache.h>
>+
>+#ifdef CONFIG_XEN
>+#include "../kernel/entry.h"
>+#else
>+#include "entry.h"
>+#endif
>+
>+#ifdef __IA64_ASM_PARAVIRTUALIZED_XEN
>+/*
>+ * DO_SAVE_MIN switches to the kernel stacks (if necessary) and saves
>+ * the minimum state necessary that allows us to turn psr.ic back
>+ * on.
>+ *
>+ * Assumed state upon entry:
>+ *	psr.ic: off
>+ *	r31:	contains saved predicates (pr)
>+ *
>+ * Upon exit, the state is as follows:
>+ *	psr.ic: off
>+ *	 r2 = points to &pt_regs.r16
>+ *	 r8 = contents of ar.ccv
>+ *	 r9 = contents of ar.csd
>+ *	r10 = contents of ar.ssd
>+ *	r11 = FPSR_DEFAULT
>+ *	r12 = kernel sp (kernel virtual address)
>+ *	r13 = points to current task_struct (kernel virtual address)
>+ *	p15 = TRUE if psr.i is set in cr.ipsr
>+ *	predicate registers (other than p2, p3, and p15), b6, r3, r14, r15:
>+ *		preserved
>+ * CONFIG_XEN note: p6/p7 are not preserved
>+ *
>+ * Note that psr.ic is NOT turned on by this macro.  This is so that
>+ * we can pass interruption state as arguments to a handler.
>+ */
>+#define DO_SAVE_MIN(COVER,SAVE_IFS,EXTRA)					
		\
>+	mov r16=IA64_KR(CURRENT);	/* M */					
		\
>+	mov r27=ar.rsc;			/* M */					
		\
>+	mov r20=r1;			/* A */					
		\
>+	mov r25=ar.unat;		/* M */					
		\
>+	/* mov r29=cr.ipsr;		/* M */					
		\
>+	movl r29=XSI_IPSR;;							
		\
>+	ld8 r29=[r29];;								
		\
>+	mov r26=ar.pfs;			/* I */					
		\
>+	/* mov r28=cr.iip;		/* M */					
		\
>+	movl r28=XSI_IIP;;							
		\
>+	ld8 r28=[r28];;								
		\
>+	mov r21=ar.fpsr;		/* M */					
		\
>+	COVER;				/* B;; (or nothing) */			
		\
We may mis-read the above COVER as COVER in arch/ia64/xen/inst_xen.h.
Why don't chage the name?

Best Regards,

Akio Takebe

