From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Tue, 25 Nov 2008 12:57:47 +0000
Subject: [PATCH 06/13] ia64/pv_ops/xen: paravirtualize read/write ar.itc and ar.itm
Message-Id: <1227618131-3755-7-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

paravirtualize ar.itc and ar.itm in order to support save/restore.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/include/asm/xen/inst.h      |   21 +++++++++
 arch/ia64/include/asm/xen/interface.h |    9 ++++
 arch/ia64/include/asm/xen/minstate.h  |   11 ++++-
 arch/ia64/include/asm/xen/privop.h    |    2 +
 arch/ia64/kernel/asm-offsets.c        |    2 +
 arch/ia64/xen/xen_pv_ops.c            |   80 ++++++++++++++++++++++++++++++++-
 6 files changed, 123 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/include/asm/xen/inst.h b/arch/ia64/include/asm/xen/inst.h
index e8e01b2..90537dc 100644
--- a/arch/ia64/include/asm/xen/inst.h
+++ b/arch/ia64/include/asm/xen/inst.h
@@ -113,6 +113,27 @@
 .endm
 #define MOV_FROM_PSR(pred, reg, clob)	__MOV_FROM_PSR pred, reg, clob
 
+/* assuming ar.itc is read with interrupt disabled. */
+#define MOV_FROM_ITC(pred, pred_clob, reg, clob)		\
+(pred)	movl clob = XSI_ITC_OFFSET;				\
+	;;							\
+(pred)	ld8 clob = [clob];					\
+(pred)	mov reg = ar.itc;					\
+	;;							\
+(pred)	add reg = reg, clob;					\
+	;;							\
+(pred)	movl clob = XSI_ITC_LAST;				\
+	;;							\
+(pred)	ld8 clob = [clob];					\
+	;;							\
+(pred)	cmp.geu.unc pred_clob, p0 = clob, reg;			\
+	;;							\
+(pred_clob)	add reg = 1, clob;				\
+	;;							\
+(pred)	movl clob = XSI_ITC_LAST;				\
+	;;							\
+(pred)	st8 [clob] = reg
+
 
 #define MOV_TO_IFA(reg, clob)	\
 	movl clob = XSI_IFA;	\
diff --git a/arch/ia64/include/asm/xen/interface.h b/arch/ia64/include/asm/xen/interface.h
index f00fab4..e951e74 100644
--- a/arch/ia64/include/asm/xen/interface.h
+++ b/arch/ia64/include/asm/xen/interface.h
@@ -209,6 +209,15 @@ struct mapped_regs {
 			unsigned long krs[8];	/* kernel registers */
 			unsigned long tmp[16];	/* temp registers
 						   (e.g. for hyperprivops) */
+
+			/* itc paravirtualization
+			 * vAR.ITC = mAR.ITC + itc_offset
+			 * itc_last is one which was lastly passed to
+			 * the guest OS in order to prevent it from
+			 * going backwords.
+			 */
+			unsigned long itc_offset;
+			unsigned long itc_last;
 		};
 	};
 };
diff --git a/arch/ia64/include/asm/xen/minstate.h b/arch/ia64/include/asm/xen/minstate.h
index 4d92d9b..c57fa91 100644
--- a/arch/ia64/include/asm/xen/minstate.h
+++ b/arch/ia64/include/asm/xen/minstate.h
@@ -1,3 +1,12 @@
+
+#ifdef CONFIG_VIRT_CPU_ACCOUNTING
+/* read ar.itc in advance, and use it before leaving bank 0 */
+#define XEN_ACCOUNT_GET_STAMP		\
+	MOV_FROM_ITC(pUStk, p6, r20, r2);
+#else
+#define XEN_ACCOUNT_GET_STAMP
+#endif
+
 /*
  * DO_SAVE_MIN switches to the kernel stacks (if necessary) and saves
  * the minimum state necessary that allows us to turn psr.ic back
@@ -123,7 +132,7 @@
 	;;											\
 .mem.offset 0,0; st8.spill [r16]=r2,16;								\
 .mem.offset 8,0; st8.spill [r17]=r3,16;								\
-	ACCOUNT_GET_STAMP									\
+	XEN_ACCOUNT_GET_STAMP									\
 	adds r2=IA64_PT_REGS_R16_OFFSET,r1;							\
 	;;											\
 	EXTRA;											\
diff --git a/arch/ia64/include/asm/xen/privop.h b/arch/ia64/include/asm/xen/privop.h
index 71ec754..2261dda 100644
--- a/arch/ia64/include/asm/xen/privop.h
+++ b/arch/ia64/include/asm/xen/privop.h
@@ -55,6 +55,8 @@
 #define XSI_BANK1_R16			(XSI_BASE + XSI_BANK1_R16_OFS)
 #define XSI_BANKNUM			(XSI_BASE + XSI_BANKNUM_OFS)
 #define XSI_IHA				(XSI_BASE + XSI_IHA_OFS)
+#define XSI_ITC_OFFSET			(XSI_BASE + XSI_ITC_OFFSET_OFS)
+#define XSI_ITC_LAST			(XSI_BASE + XSI_ITC_LAST_OFS)
 #endif
 
 #ifndef __ASSEMBLY__
diff --git a/arch/ia64/kernel/asm-offsets.c b/arch/ia64/kernel/asm-offsets.c
index 742dbb1..af56501 100644
--- a/arch/ia64/kernel/asm-offsets.c
+++ b/arch/ia64/kernel/asm-offsets.c
@@ -316,5 +316,7 @@ void foo(void)
 	DEFINE_MAPPED_REG_OFS(XSI_BANK1_R16_OFS, bank1_regs[0]);
 	DEFINE_MAPPED_REG_OFS(XSI_B0NATS_OFS, vbnat);
 	DEFINE_MAPPED_REG_OFS(XSI_B1NATS_OFS, vnat);
+	DEFINE_MAPPED_REG_OFS(XSI_ITC_OFFSET_OFS, itc_offset);
+	DEFINE_MAPPED_REG_OFS(XSI_ITC_LAST_OFS, itc_last);
 #endif /* CONFIG_XEN */
 }
diff --git a/arch/ia64/xen/xen_pv_ops.c b/arch/ia64/xen/xen_pv_ops.c
index 46b418a..e83ede7 100644
--- a/arch/ia64/xen/xen_pv_ops.c
+++ b/arch/ia64/xen/xen_pv_ops.c
@@ -183,6 +183,75 @@ struct pv_fsys_data xen_fsys_data __initdata = {
  * intrinsics hooks.
  */
 
+static void
+xen_set_itm_with_offset(unsigned long val)
+{
+	/* ia64_cpu_local_tick() calls this with interrupt enabled. */
+	/* WARN_ON(!irqs_disabled()); */
+	xen_set_itm(val - XEN_MAPPEDREGS->itc_offset);
+}
+
+static unsigned long
+xen_get_itm_with_offset(void)
+{
+	/* unused at this moment */
+	printk(KERN_DEBUG "%s is called.\n", __func__);
+
+	WARN_ON(!irqs_disabled());
+	return ia64_native_getreg(_IA64_REG_CR_ITM) +
+		XEN_MAPPEDREGS->itc_offset;
+}
+
+/* ia64_set_itc() is only called by
+ * cpu_init() with ia64_set_itc(0) and ia64_sync_itc().
+ * So XEN_MAPPEDRESG->itc_offset cal be considered as almost constant.
+ */
+static void
+xen_set_itc(unsigned long val)
+{
+	unsigned long mitc;
+
+	WARN_ON(!irqs_disabled());
+	mitc = ia64_native_getreg(_IA64_REG_AR_ITC);
+	XEN_MAPPEDREGS->itc_offset = val - mitc;
+	XEN_MAPPEDREGS->itc_last = val;
+}
+
+static unsigned long
+xen_get_itc(void)
+{
+	unsigned long res;
+	unsigned long itc_offset;
+	unsigned long itc_last;
+	unsigned long ret_itc_last;
+
+	itc_offset = XEN_MAPPEDREGS->itc_offset;
+	do {
+		itc_last = XEN_MAPPEDREGS->itc_last;
+		res = ia64_native_getreg(_IA64_REG_AR_ITC);
+		res += itc_offset;
+		if (itc_last >= res)
+			res = itc_last + 1;
+		ret_itc_last = cmpxchg(&XEN_MAPPEDREGS->itc_last,
+				       itc_last, res);
+	} while (unlikely(ret_itc_last != itc_last));
+	return res;
+
+#if 0
+	/* ia64_itc_udelay() calls ia64_get_itc() with interrupt enabled.
+	   Should it be paravirtualized instead? */
+	WARN_ON(!irqs_disabled());
+	itc_offset = XEN_MAPPEDREGS->itc_offset;
+	itc_last = XEN_MAPPEDREGS->itc_last;
+	res = ia64_native_getreg(_IA64_REG_AR_ITC);
+	res += itc_offset;
+	if (itc_last >= res)
+		res = itc_last + 1;
+	XEN_MAPPEDREGS->itc_last = res;
+	return res;
+#endif
+}
+
 static void xen_setreg(int regnum, unsigned long val)
 {
 	switch (regnum) {
@@ -194,11 +263,14 @@ static void xen_setreg(int regnum, unsigned long val)
 		xen_set_eflag(val);
 		break;
 #endif
+	case _IA64_REG_AR_ITC:
+		xen_set_itc(val);
+		break;
 	case _IA64_REG_CR_TPR:
 		xen_set_tpr(val);
 		break;
 	case _IA64_REG_CR_ITM:
-		xen_set_itm(val);
+		xen_set_itm_with_offset(val);
 		break;
 	case _IA64_REG_CR_EOI:
 		xen_eoi(val);
@@ -222,6 +294,12 @@ static unsigned long xen_getreg(int regnum)
 		res = xen_get_eflag();
 		break;
 #endif
+	case _IA64_REG_AR_ITC:
+		res = xen_get_itc();
+		break;
+	case _IA64_REG_CR_ITM:
+		res = xen_get_itm_with_offset();
+		break;
 	case _IA64_REG_CR_IVR:
 		res = xen_get_ivr();
 		break;
-- 
1.6.0.2

