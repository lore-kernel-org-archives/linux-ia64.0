From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Tue, 26 Feb 2008 13:58:57 +0000
Subject: [PATCH 6/8] ia64/pv_ops xen: xen paravirtualization of hand written assembly code. inst_xen.h
Message-Id: <12040343393125-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/xen/inst_xen.h |  307 ++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 307 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/xen/inst_xen.h

diff --git a/arch/ia64/xen/inst_xen.h b/arch/ia64/xen/inst_xen.h
new file mode 100644
index 0000000..c0bd736
--- /dev/null
+++ b/arch/ia64/xen/inst_xen.h
@@ -0,0 +1,307 @@
+/******************************************************************************
+ * inst_xen.h
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
+#define IA64_ASM_PARAVIRTUALIZED_XEN
+
+#define ia64_ivt				xen_ivt
+
+#define __paravirt_switch_to			xen_switch_to
+#define __paravirt_leave_syscall		xen_leave_syscall
+#define __paravirt_work_processed_syscall	xen_work_processed_syscall
+#define __paravirt_leave_kernel			xen_leave_kernel
+#define __paravirt_pending_syscall_end		xen_work_pending_syscall_end
+#define __paravirt_work_processed_syscall_target \
+						xen_work_processed_syscall
+
+#define MOV_FROM_IFA(reg)	\
+	movl reg = XSI_IFA;	\
+	;;			\
+	ld8 reg = [reg]
+
+#define MOV_FROM_ITIR(reg)	\
+	movl reg = XSI_ITIR;	\
+	;;			\
+	ld8 reg = [reg]
+
+#define MOV_FROM_ISR(reg)	\
+	movl reg = XSI_ISR;	\
+	;;			\
+	ld8 reg = [reg]
+
+#define MOV_FROM_IHA(reg)	\
+	movl reg = XSI_IHA;	\
+	;;			\
+	ld8 reg = [reg]
+
+#define MOV_FROM_IPSR(reg)	\
+	movl reg = XSI_IPSR;	\
+	;;			\
+	ld8 reg = [reg]
+
+#define MOV_FROM_IIM(reg)	\
+	movl reg = XSI_IIM;	\
+	;;			\
+	ld8 reg = [reg]
+
+#define MOV_FROM_IIP(reg)	\
+	movl reg = XSI_IIP;	\
+	;;			\
+	ld8 reg = [reg]
+
+#if 0
+#define MOV_FROM_IVR(reg, clob)	\
+	clob = r8;		\
+	;;			\
+	XEN_HYPER_GET_IVR	\
+	;;			\
+	mov reg = r8;		\
+	;;			\
+	mov r8 = clob
+#else
+#define MOV_FROM_IVR(reg)	\
+	;;			\
+	XEN_HYPER_GET_IVR	\
+	;;			\
+	mov reg = r8
+#endif
+
+#define MOV_FROM_PSR(pred, reg, clob)	\
+	(pred) mov clob = r8;		\
+	(pred) XEN_HYPER_GET_PSR;	\
+	;;				\
+	(pred) mov reg = r8;		\
+	(pred) mov r8 = clob;		\
+	;;
+
+
+#define MOV_TO_IFA(reg, clob)	\
+	movl clob = XSI_IFA;	\
+	;;			\
+	st8 [clob] = reg	\
+
+#define MOV_TO_ITIR(pred, reg, clob)	\
+	(pred) movl clob = XSI_ITIR;	\
+	;;				\
+	(pred) st8 [clob] = reg
+
+#define MOV_TO_IHA(pred, reg, clob)	\
+	(pred) movl clob = XSI_IHA;	\
+	;;				\
+	(pred) st8 [clob] = reg
+
+#define MOV_TO_IPSR(reg, clob)	\
+	movl clob = XSI_IPSR;	\
+	;;			\
+	st8 [clob] = r29;	\
+	;;
+
+#define MOV_TO_IFS(pred, reg, clob)	\
+	(pred) movl clob = XSI_IFS;	\
+	;;				\
+	(pred) st8 [clob] = reg;	\
+	;;
+
+#define MOV_TO_IIP(reg, clob)	\
+	movl clob = XSI_IIP;	\
+	;;			\
+	st8 [clob] = reg
+
+#if 0
+#define MOV_TO_KR(kr, reg, clob0, clob1)	\
+	mov clob0 = r8;				\
+	mov clob1 = r9;				\
+	;;					\
+	mov r8 = IA64_KR_ ## kr ;		\
+	mov r9 = reg;				\
+	;;					\
+	XEN_HYPER_SET_KR;			\
+	mov r8 = clob0;				\
+	mov r9 = clob1
+#else
+#define MOV_TO_KR(kr, reg)		\
+	mov r8 = IA64_KR_ ## kr;	\
+	mov r9 = reg;			\
+	;;				\
+	XEN_HYPER_SET_KR
+#endif
+
+
+#define ITC_I(pred, reg, clob)	\
+	(pred) mov clob = r8;	\
+	(pred) mov r8 = reg;	\
+	;;			\
+	(pred) XEN_HYPER_ITC_I; \
+	;;			\
+	(pred) mov r8 = clob;	\
+	;;
+
+#define ITC_D(pred, reg, clob)	\
+	(pred) mov clob = r8;	\
+	(pred) mov r8 = reg;	\
+	;;			\
+	(pred) XEN_HYPER_ITC_D; \
+	;;			\
+	(pred) mov r8 = clob;	\
+	;;
+
+#define ITC_I_AND_D(pred_i, pred_d, reg, clob)	\
+	mov clob = r8;				\
+	mov r8 = reg;				\
+	;;					\
+	(pred_i) XEN_HYPER_ITC_I;		\
+	;;					\
+	(pred_d) XEN_HYPER_ITC_D;		\
+	;;					\
+	mov r8 = clob;				\
+	;;
+
+#define THASH(pred, reg0, reg1, clob)	\
+	(pred) mov clob = r8;		\
+	(pred) mov r8 = reg1;		\
+	(pred) XEN_HYPER_THASH;		\
+	;;				\
+	(pred) mov reg0 = r8;		\
+	(pred) mov r8 = clob;		\
+	;;
+
+#define SSM_PSR_IC_AND_DEFAULT_BITS(clob0, clob1)	\
+	mov clob0 = 1;					\
+	movl clob1 = XSI_PSR_IC;			\
+	;;						\
+	st4 [clob1] = clob0				\
+	;;
+
+#define SSM_PSR_IC_AND_SRLZ_D(clob0, clob1)	\
+	;;					\
+	srlz.d;					\
+	mov clob1 = 1;				\
+	movl clob0=XSI_PSR_IC;			\
+	;;					\
+	st4 [clob0] = clob1
+
+#define RSM_PSR_IC(clob)	\
+	movl clob = XSI_PSR_IC;	\
+	;;			\
+	st4 [clob] = r0;	\
+	;;
+
+/* pred will be clobbered */
+#define MASK_TO_PEND_OFS    (-1)
+#define SSM_PSR_I(pred, clob)						\
+	(pred)	movl clob = XSI_PSR_I_ADDR				\
+	;;								\
+	(pred)	ld8 clob = [clob]					\
+	;;								\
+	/* if (pred) vpsr.i = 1 */					\
+	/* if (pred) (vcpu->vcpu_info->evtchn_upcall_mask)=0 */		\
+	(pred)	st1 [clob] = r0, MASK_TO_PEND_OFS			\
+	;;								\
+	/* if (vcpu->vcpu_info->evtchn_upcall_pending) */		\
+	(pred)	ld1 clob = [clob]					\
+	;;								\
+	(pred)	cmp.ne pred, p0 = clob, r0				\
+	;;								\
+	(pred)	XEN_HYPER_SSM_I	/* do areal ssm psr.i */
+
+#define RSM_PSR_I(pred, clob0, clob1)	\
+	movl clob0 = XSI_PSR_I_ADDR;	\
+	mov clob1 = 1;			\
+	;;				\
+	ld8 clob0 = [clob0];		\
+	;;				\
+	(pred)	st1 [clob0] = clob1
+
+#define RSM_PSR_I_IC(clob0, clob1, clob2)		\
+	movl clob0 = XSI_PSR_I_ADDR;			\
+	movl clob1 = XSI_PSR_IC;			\
+	;;						\
+	ld8 clob0 = [clob0];				\
+	mov clob2 = 1;					\
+	;;						\
+	/* note: clears both vpsr.i and vpsr.ic! */	\
+	st1 [clob0] = clob2;				\
+	st4 [clob1] = r0;				\
+	;;
+
+#define RSM_PSR_DT		\
+	XEN_HYPER_RSM_PSR_DT
+
+#define RSM_PSR_DT_AND_SRLZ_I	\
+	XEN_HYPER_RSM_PSR_DT
+
+#define SSM_PSR_DT_AND_SRLZ_I	\
+	XEN_HYPER_SSM_PSR_DT
+
+#define BSW_0(clob0, clob1, clob2)			\
+	;;						\
+	/* r16-r31 all now hold bank1 values */		\
+	mov clob2 = ar.unat;				\
+	movl clob0 = XSI_BANK1_R16;			\
+	movl clob1 = XSI_BANK1_R16 + 8;			\
+	;;						\
+	.mem.offset 0, 0; st8.spill [clob0] = r16, 16;	\
+	.mem.offset 8, 0; st8.spill [clob1] = r17, 16;	\
+	;;						\
+	.mem.offset 0, 0; st8.spill [clob0] = r18, 16;	\
+	.mem.offset 8, 0; st8.spill [clob1] = r19, 16;	\
+	;;						\
+	.mem.offset 0, 0; st8.spill [clob0] = r20, 16;	\
+	.mem.offset 8, 0; st8.spill [clob1] = r21, 16;	\
+	;;						\
+	.mem.offset 0, 0; st8.spill [clob0] = r22, 16;	\
+	.mem.offset 8, 0; st8.spill [clob1] = r23, 16;	\
+	;;						\
+	.mem.offset 0, 0; st8.spill [clob0] = r24, 16;	\
+	.mem.offset 8, 0; st8.spill [clob1] = r25, 16;	\
+	;;						\
+	.mem.offset 0, 0; st8.spill [clob0] = r26, 16;	\
+	.mem.offset 8, 0; st8.spill [clob1] = r27, 16;	\
+	;;						\
+	.mem.offset 0, 0; st8.spill [clob0] = r28, 16;	\
+	.mem.offset 8, 0; st8.spill [clob1] = r29, 16;	\
+	;;						\
+	.mem.offset 0, 0; st8.spill [clob0] = r30, 16;	\
+	.mem.offset 8, 0; st8.spill [clob1] = r31, 16;	\
+	;;						\
+	mov clob1 = ar.unat;				\
+	movl clob0 = XSI_B1NAT;				\
+	;;						\
+	st8 [clob0] = clob1;				\
+	mov ar.unat = clob2;				\
+	movl clob0 = XSI_BANKNUM;			\
+	;;						\
+	st4 [clob0] = r0
+
+	/* xen_bsw1 clobbers clob1 */
+#define BSW_1(clob0, clob1)		\
+	mov clob0 = b0;			\
+	br.call.sptk b0 = xen_bsw1;	\
+	;;				\
+	mov b0=clob0;			\
+	;;
+
+#define COVER	\
+	XEN_HYPER_COVER
+
+#define RFI			\
+	XEN_HYPER_RFI;		\
+	dv_serialize_data
-- 
1.5.3

