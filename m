From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Fri, 17 Oct 2008 02:18:02 +0000
Subject: [PATCH 22/33] ia64/pv_ops/xen: paravirtualize DO_SAVE_MIN for xen.
Message-Id: <1224209893-2032-23-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

paravirtualize DO_SAVE_MIN in minstate.h for xen.

Signed-off-by: Yaozu (Eddie) Dong <eddie.dong@intel.com>
Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/include/asm/xen/inst.h     |    2 +
 arch/ia64/include/asm/xen/minstate.h |  134 ++++++++++++++++++++++++++++++=
++++
 2 files changed, 136 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/include/asm/xen/minstate.h

diff --git a/arch/ia64/include/asm/xen/inst.h b/arch/ia64/include/asm/xen/i=
nst.h
index 03895e9..1e92ed0 100644
--- a/arch/ia64/include/asm/xen/inst.h
+++ b/arch/ia64/include/asm/xen/inst.h
@@ -22,6 +22,8 @@
=20
 #include <asm/xen/privop.h>
=20
+#define DO_SAVE_MIN				XEN_DO_SAVE_MIN
+
 #define MOV_FROM_IFA(reg)	\
 	movl reg =3D XSI_IFA;	\
 	;;			\
diff --git a/arch/ia64/include/asm/xen/minstate.h b/arch/ia64/include/asm/x=
en/minstate.h
new file mode 100644
index 0000000..4d92d9b
--- /dev/null
+++ b/arch/ia64/include/asm/xen/minstate.h
@@ -0,0 +1,134 @@
+/*
+ * DO_SAVE_MIN switches to the kernel stacks (if necessary) and saves
+ * the minimum state necessary that allows us to turn psr.ic back
+ * on.
+ *
+ * Assumed state upon entry:
+ *	psr.ic: off
+ *	r31:	contains saved predicates (pr)
+ *
+ * Upon exit, the state is as follows:
+ *	psr.ic: off
+ *	 r2 =3D points to &pt_regs.r16
+ *	 r8 =3D contents of ar.ccv
+ *	 r9 =3D contents of ar.csd
+ *	r10 =3D contents of ar.ssd
+ *	r11 =3D FPSR_DEFAULT
+ *	r12 =3D kernel sp (kernel virtual address)
+ *	r13 =3D points to current task_struct (kernel virtual address)
+ *	p15 =3D TRUE if psr.i is set in cr.ipsr
+ *	predicate registers (other than p2, p3, and p15), b6, r3, r14, r15:
+ *		preserved
+ * CONFIG_XEN note: p6/p7 are not preserved
+ *
+ * Note that psr.ic is NOT turned on by this macro.  This is so that
+ * we can pass interruption state as arguments to a handler.
+ */
+#define XEN_DO_SAVE_MIN(__COVER,SAVE_IFS,EXTRA,WORKAROUND)					\
+	mov r16=3DIA64_KR(CURRENT);	/* M */							\
+	mov r27=3Dar.rsc;			/* M */							\
+	mov r20=3Dr1;			/* A */							\
+	mov r25=3Dar.unat;		/* M */							\
+	MOV_FROM_IPSR(p0,r29);		/* M */							\
+	MOV_FROM_IIP(r28);		/* M */							\
+	mov r21=3Dar.fpsr;		/* M */							\
+	mov r26=3Dar.pfs;			/* I */							\
+	__COVER;			/* B;; (or nothing) */					\
+	adds r16=3DIA64_TASK_THREAD_ON_USTACK_OFFSET,r16;						\
+	;;											\
+	ld1 r17=3D[r16];				/* load current->thread.on_ustack flag */	\
+	st1 [r16]=3Dr0;				/* clear current->thread.on_ustack flag */	\
+	adds r1=3D-IA64_TASK_THREAD_ON_USTACK_OFFSET,r16						\
+	/* switch from user to kernel RBS: */							\
+	;;											\
+	invala;				/* M */							\
+	/* SAVE_IFS;*/ /* see xen special handling below */					\
+	cmp.eq pKStk,pUStk=3Dr0,r17;		/* are we in kernel mode already? */		\
+	;;											\
+(pUStk)	mov ar.rsc=3D0;		/* set enforced lazy mode, pl 0, little-endian, l=
oadrs=3D0 */	\
+	;;											\
+(pUStk)	mov.m r24=3Dar.rnat;									\
+(pUStk)	addl r22=3DIA64_RBS_OFFSET,r1;			/* compute base of RBS */		\
+(pKStk) mov r1=3Dsp;					/* get sp  */				\
+	;;											\
+(pUStk) lfetch.fault.excl.nt1 [r22];								\
+(pUStk)	addl r1=3DIA64_STK_OFFSET-IA64_PT_REGS_SIZE,r1;	/* compute base of=
 memory stack */	\
+(pUStk)	mov r23=3Dar.bspstore;				/* save ar.bspstore */			\
+	;;											\
+(pUStk)	mov ar.bspstore=3Dr22;				/* switch to kernel RBS */		\
+(pKStk) addl r1=3D-IA64_PT_REGS_SIZE,r1;			/* if in kernel mode, use sp (r=
12) */	\
+	;;											\
+(pUStk)	mov r18=3Dar.bsp;										\
+(pUStk)	mov ar.rsc=3D0x3;		/* set eager mode, pl 0, little-endian, loadrs=
=3D0 */		\
+	adds r17=3D2*L1_CACHE_BYTES,r1;		/* really: biggest cache-line size */		\
+	adds r16=3DPT(CR_IPSR),r1;								\
+	;;											\
+	lfetch.fault.excl.nt1 [r17],L1_CACHE_BYTES;						\
+	st8 [r16]=3Dr29;		/* save cr.ipsr */						\
+	;;											\
+	lfetch.fault.excl.nt1 [r17];								\
+	tbit.nz p15,p0=3Dr29,IA64_PSR_I_BIT;							\
+	mov r29=B0										\
+	;;											\
+	WORKAROUND;										\
+	adds r16=3DPT(R8),r1;	/* initialize first base pointer */				\
+	adds r17=3DPT(R9),r1;	/* initialize second base pointer */				\
+(pKStk)	mov r18=3Dr0;		/* make sure r18 isn't NaT */					\
+	;;											\
+.mem.offset 0,0; st8.spill [r16]=3Dr8,16;								\
+.mem.offset 8,0; st8.spill [r17]=3Dr9,16;								\
+        ;;											\
+.mem.offset 0,0; st8.spill [r16]=3Dr10,24;							\
+	movl r8=3DXSI_PRECOVER_IFS;								\
+.mem.offset 8,0; st8.spill [r17]=3Dr11,24;							\
+        ;;											\
+	/* xen special handling for possibly lazy cover */					\
+	/* SAVE_MIN case in dispatch_ia32_handler: mov r30=3Dr0 */				\
+	ld8 r30=3D[r8];										\
+(pUStk)	sub r18=3Dr18,r22;	/* r18=3DRSE.ndirty*8 */						\
+	st8 [r16]=3Dr28,16;	/* save cr.iip */						\
+	;;											\
+	st8 [r17]=3Dr30,16;	/* save cr.ifs */						\
+	mov r8=3Dar.ccv;										\
+	mov r9=3Dar.csd;										\
+	mov r10=3Dar.ssd;										\
+	movl r11=3DFPSR_DEFAULT;   /* L-unit */							\
+	;;											\
+	st8 [r16]=3Dr25,16;	/* save ar.unat */						\
+	st8 [r17]=3Dr26,16;	/* save ar.pfs */						\
+	shl r18=3Dr18,16;		/* compute ar.rsc to be used for "loadrs" */			\
+	;;											\
+	st8 [r16]=3Dr27,16;	/* save ar.rsc */						\
+(pUStk)	st8 [r17]=3Dr24,16;	/* save ar.rnat */						\
+(pKStk)	adds r17=16,r17;	/* skip over ar_rnat field */					\
+	;;			/* avoid RAW on r16 & r17 */					\
+(pUStk)	st8 [r16]=3Dr23,16;	/* save ar.bspstore */						\
+	st8 [r17]=3Dr31,16;	/* save predicates */						\
+(pKStk)	adds r16=16,r16;	/* skip over ar_bspstore field */				\
+	;;											\
+	st8 [r16]=3Dr29,16;	/* save b0 */							\
+	st8 [r17]=3Dr18,16;	/* save ar.rsc value for "loadrs" */				\
+	cmp.eq pNonSys,pSys=3Dr0,r0	/* initialize pSys=3D0, pNonSys=3D1 */			\
+	;;											\
+.mem.offset 0,0; st8.spill [r16]=3Dr20,16;	/* save original r1 */				\
+.mem.offset 8,0; st8.spill [r17]=3Dr12,16;							\
+	adds r12=3D-16,r1;	/* switch to kernel memory stack (with 16 bytes of scr=
atch) */	\
+	;;											\
+.mem.offset 0,0; st8.spill [r16]=3Dr13,16;							\
+.mem.offset 8,0; st8.spill [r17]=3Dr21,16;	/* save ar.fpsr */				\
+	mov r13=3DIA64_KR(CURRENT);	/* establish `current' */				\
+	;;											\
+.mem.offset 0,0; st8.spill [r16]=3Dr15,16;							\
+.mem.offset 8,0; st8.spill [r17]=3Dr14,16;							\
+	;;											\
+.mem.offset 0,0; st8.spill [r16]=3Dr2,16;								\
+.mem.offset 8,0; st8.spill [r17]=3Dr3,16;								\
+	ACCOUNT_GET_STAMP									\
+	adds r2=3DIA64_PT_REGS_R16_OFFSET,r1;							\
+	;;											\
+	EXTRA;											\
+	movl r1=3D__gp;		/* establish kernel global pointer */				\
+	;;											\
+	ACCOUNT_SYS_ENTER									\
+	BSW_1(r3,r14);	/* switch back to bank 1 (must be last in insn group) */		\
+	;;
--=20
1.6.0.2

