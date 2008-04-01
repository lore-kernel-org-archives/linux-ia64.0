From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Tue, 01 Apr 2008 10:49:10 +0000
Subject: [11/18] KVM:IA64: Add trampoline for guest/host mode switch.
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDC0104872A@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C893E6.04B0681B"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C893E6.04B0681B
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From 59b4b2d53ecdc27b64bc15cec547ae2ae6145e98 Mon Sep 17 00:00:00 2001
From: Xiantao Zhang <xiantao.zhang@intel.com>
Date: Tue, 1 Apr 2008 14:54:42 +0800
Subject: [PATCH] KVM:IA64: Add trampoline for guest/host mode switch.

trampoline code targets for guest/host world switch.
Signed-off-by: Xiantao Zhang <xiantao.zhang@intel.com>
---
 arch/ia64/kvm/trampoline.S | 1040
++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 1040 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/kvm/trampoline.S

diff --git a/arch/ia64/kvm/trampoline.S b/arch/ia64/kvm/trampoline.S
new file mode 100644
index 0000000..d3232b5
--- /dev/null
+++ b/arch/ia64/kvm/trampoline.S
@@ -0,0 +1,1040 @@
+/* Save all processor states
+ *
+ * Copyright (c) 2007 Fleming Feng <fleming.feng@intel.com>
+ * Copyright (c) 2007 Anthony Xu   <anthony.xu@intel.com>
+ */
+
+#include <asm/asmmacro.h>
+#include "asm-offsets.h"
+
+
+#define CTX(name)    VMM_CTX_##name##_OFFSET
+
+	/*
+	 *	r32:		context_t base address
+	 */
+#define	SAVE_BRANCH_REGS			\
+	add	r2 =3D CTX(B0),r32;		\
+	add	r3 =3D CTX(B1),r32;		\
+	mov	r16 =3D b0;			\
+	mov	r17 =3D b1;			\
+	;;					\
+	st8	[r2]=3Dr16,16;			\
+	st8	[r3]=3Dr17,16;			\
+	;;					\
+	mov	r16 =3D b2;			\
+	mov	r17 =3D b3;			\
+	;;					\
+	st8	[r2]=3Dr16,16;			\
+	st8	[r3]=3Dr17,16;			\
+	;;					\
+	mov	r16 =3D b4;			\
+	mov	r17 =3D b5;			\
+	;;					\
+	st8	[r2]=3Dr16;   			\
+	st8	[r3]=3Dr17;   			\
+	;;
+
+	/*
+	 *	r33:		context_t base address
+	 */
+#define	RESTORE_BRANCH_REGS			\
+	add	r2 =3D CTX(B0),r33;		\
+	add	r3 =3D CTX(B1),r33;		\
+	;;					\
+	ld8	r16=3D[r2],16;			\
+	ld8	r17=3D[r3],16;			\
+	;;					\
+	mov	b0 =3D r16;			\
+	mov	b1 =3D r17;			\
+	;;					\
+	ld8	r16=3D[r2],16;			\
+	ld8	r17=3D[r3],16;			\
+	;;					\
+	mov	b2 =3D r16;			\
+	mov	b3 =3D r17;			\
+	;;					\
+	ld8	r16=3D[r2];   			\
+	ld8	r17=3D[r3];   			\
+	;;					\
+	mov	b4=3Dr16;				\
+	mov	b5=3Dr17;				\
+	;;
+
+
+	/*
+	 *	r32: context_t base address
+	 *	bsw =3D=3D 1
+	 *	Save all bank1 general registers, r4 ~ r7
+	 */
+#define	SAVE_GENERAL_REGS			\
+	add	r2=3DCTX(R4),r32;			\
+	add	r3=3DCTX(R5),r32;			\
+	;;					\
+.mem.offset 0,0;        			\
+	st8.spill	[r2]=3Dr4,16;		\
+.mem.offset 8,0;        			\
+	st8.spill	[r3]=3Dr5,16;		\
+	;;					\
+.mem.offset 0,0;        			\
+	st8.spill	[r2]=3Dr6,48;		\
+.mem.offset 8,0;        			\
+	st8.spill	[r3]=3Dr7,48;		\
+	;;                          		\
+.mem.offset 0,0;        			\
+    st8.spill    [r2]=3Dr12;			\
+.mem.offset 8,0;				\
+    st8.spill    [r3]=3Dr13;			\
+    ;;
+
+	/*
+	 *	r33: context_t base address
+	 *	bsw =3D=3D 1
+	 */
+#define	RESTORE_GENERAL_REGS			\
+	add	r2=3DCTX(R4),r33;			\
+	add	r3=3DCTX(R5),r33;			\
+	;;					\
+	ld8.fill	r4=3D[r2],16;		\
+	ld8.fill	r5=3D[r3],16;		\
+	;;					\
+	ld8.fill	r6=3D[r2],48;		\
+	ld8.fill	r7=3D[r3],48;		\
+	;;					\
+	ld8.fill    r12=3D[r2];			\
+	ld8.fill    r13 =3D[r3];			\
+	;;
+
+
+
+
+	/*
+	 *	r32:		context_t base address
+	 */
+#define	SAVE_KERNEL_REGS			\
+	add	r2 =3D CTX(KR0),r32;		\
+	add	r3 =3D CTX(KR1),r32;		\
+	mov	r16 =3D ar.k0;			\
+	mov	r17 =3D ar.k1;			\
+	;;		        		\
+	st8	[r2] =3D r16,16;			\
+	st8	[r3] =3D r17,16;			\
+	;;		        		\
+	mov	r16 =3D ar.k2;			\
+	mov	r17 =3D ar.k3;			\
+	;;		        		\
+	st8	[r2] =3D r16,16;			\
+	st8	[r3] =3D r17,16;			\
+	;;					\
+	mov	r16 =3D ar.k4;			\
+	mov	r17 =3D ar.k5;			\
+	;;				    	\
+	st8	[r2] =3D r16,16;			\
+	st8	[r3] =3D r17,16;			\
+	;;					\
+	mov	r16 =3D ar.k6;			\
+	mov	r17 =3D ar.k7;			\
+	;;		    			\
+	st8	[r2] =3D r16;     		\
+	st8	[r3] =3D r17;			\
+	;;
+
+
+
+	/*
+	 *	r33:		context_t base address
+	 */
+#define	RESTORE_KERNEL_REGS			\
+	add	r2 =3D CTX(KR0),r33;		\
+	add	r3 =3D CTX(KR1),r33;		\
+	;;		    			\
+	ld8	r16=3D[r2],16;     		\
+	ld8	r17=3D[r3],16;			\
+	;;					\
+	mov	ar.k0=3Dr16;  			\
+	mov	ar.k1=3Dr17;	    		\
+	;;		        		\
+	ld8	r16=3D[r2],16;			\
+	ld8	r17=3D[r3],16;			\
+	;;		        		\
+	mov	ar.k2=3Dr16;   			\
+	mov	ar.k3=3Dr17;	    		\
+	;;		        		\
+	ld8	r16=3D[r2],16;			\
+	ld8	r17=3D[r3],16;			\
+	;;					\
+	mov	ar.k4=3Dr16;			\
+	mov	ar.k5=3Dr17;	    		\
+	;;				    	\
+	ld8	r16=3D[r2],16;			\
+	ld8	r17=3D[r3],16;			\
+	;;					\
+	mov	ar.k6=3Dr16;  			\
+	mov	ar.k7=3Dr17;	    		\
+	;;
+
+
+
+	/*
+	 *	r32:		context_t base address
+	 */
+#define	SAVE_APP_REGS				\
+	add  r2 =3D CTX(BSPSTORE),r32;		\
+	mov  r16 =3D ar.bspstore;			\
+	;;					\
+	st8  [r2] =3D r16,CTX(RNAT)-CTX(BSPSTORE);\
+	mov  r16 =3D ar.rnat;			\
+	;;					\
+	st8  [r2] =3D r16,CTX(FCR)-CTX(RNAT);	\
+	mov  r16 =3D ar.fcr;			\
+	;;					\
+	st8  [r2] =3D r16,CTX(EFLAG)-CTX(FCR);	\
+	mov  r16 =3D ar.eflag;			\
+	;;					\
+	st8  [r2] =3D r16,CTX(CFLG)-CTX(EFLAG);	\
+	mov  r16 =3D ar.cflg;			\
+	;;					\
+	st8  [r2] =3D r16,CTX(FSR)-CTX(CFLG);	\
+	mov  r16 =3D ar.fsr;			\
+	;;					\
+	st8  [r2] =3D r16,CTX(FIR)-CTX(FSR);	\
+	mov  r16 =3D ar.fir;			\
+	;;					\
+	st8  [r2] =3D r16,CTX(FDR)-CTX(FIR);	\
+	mov  r16 =3D ar.fdr;			\
+	;;					\
+	st8  [r2] =3D r16,CTX(UNAT)-CTX(FDR);	\
+	mov  r16 =3D ar.unat;			\
+	;;					\
+	st8  [r2] =3D r16,CTX(FPSR)-CTX(UNAT);	\
+	mov  r16 =3D ar.fpsr;			\
+	;;					\
+	st8  [r2] =3D r16,CTX(PFS)-CTX(FPSR);	\
+	mov  r16 =3D ar.pfs;			\
+	;;					\
+	st8  [r2] =3D r16,CTX(LC)-CTX(PFS);	\
+	mov  r16 =3D ar.lc;			\
+	;;					\
+	st8  [r2] =3D r16;			\
+	;;
+
+	/*
+	 *	r33:		context_t base address
+	 */
+#define	RESTORE_APP_REGS			\
+	add  r2=3DCTX(BSPSTORE),r33;		\
+	;;					\
+	ld8  r16=3D[r2],CTX(RNAT)-CTX(BSPSTORE);	\
+	;;					\
+	mov  ar.bspstore=3Dr16;			\
+	ld8  r16=3D[r2],CTX(FCR)-CTX(RNAT);	\
+	;;					\
+	mov  ar.rnat=3Dr16;			\
+	ld8  r16=3D[r2],CTX(EFLAG)-CTX(FCR);	\
+	;;					\
+	mov  ar.fcr=3Dr16;			\
+	ld8  r16=3D[r2],CTX(CFLG)-CTX(EFLAG);	\
+	;;					\
+	mov  ar.eflag=3Dr16;			\
+	ld8  r16=3D[r2],CTX(FSR)-CTX(CFLG);	\
+	;;					\
+	mov  ar.cflg=3Dr16;			\
+	ld8  r16=3D[r2],CTX(FIR)-CTX(FSR);	\
+	;;					\
+	mov  ar.fsr=3Dr16;			\
+	ld8  r16=3D[r2],CTX(FDR)-CTX(FIR);	\
+	;;					\
+	mov  ar.fir=3Dr16;			\
+	ld8  r16=3D[r2],CTX(UNAT)-CTX(FDR);	\
+	;;					\
+	mov  ar.fdr=3Dr16;			\
+	ld8  r16=3D[r2],CTX(FPSR)-CTX(UNAT);	\
+	;;					\
+	mov  ar.unat=3Dr16;			\
+	ld8  r16=3D[r2],CTX(PFS)-CTX(FPSR);	\
+	;;					\
+	mov  ar.fpsr=3Dr16;			\
+	ld8  r16=3D[r2],CTX(LC)-CTX(PFS);		\
+	;;					\
+	mov  ar.pfs=3Dr16;			\
+	ld8  r16=3D[r2];				\
+	;;					\
+	mov  ar.lc=3Dr16;				\
+	;;
+
+	/*
+	 *	r32:		context_t base address
+	 */
+#define	SAVE_CTL_REGS				\
+	add	r2 =3D CTX(DCR),r32;		\
+	mov	r16 =3D cr.dcr;			\
+	;;					\
+	st8	[r2] =3D r16,CTX(IVA)-CTX(DCR);	\
+	;;                          		\
+	mov	r16 =3D cr.iva;			\
+	;;					\
+	st8	[r2] =3D r16,CTX(PTA)-CTX(IVA);	\
+	;;					\
+	mov r16 =3D cr.pta;			\
+	;;					\
+	st8 [r2] =3D r16 ;			\
+	;;
+
+	/*
+	 *	r33:		context_t base address
+	 */
+#define	RESTORE_CTL_REGS				\
+	add	r2 =3D CTX(DCR),r33;	        	\
+	;;						\
+	ld8	r16 =3D [r2],CTX(IVA)-CTX(DCR);		\
+	;;                      			\
+	mov	cr.dcr =3D r16;				\
+	dv_serialize_data;				\
+	;;						\
+	ld8	r16 =3D [r2],CTX(PTA)-CTX(IVA);		\
+	;;						\
+	mov	cr.iva =3D r16;				\
+	dv_serialize_data;				\
+	;;						\
+	ld8 r16 =3D [r2];					\
+	;;						\
+	mov cr.pta =3D r16;				\
+	dv_serialize_data;				\
+	;;
+
+
+	/*
+	 *	r32:		context_t base address
+	 */
+#define	SAVE_REGION_REGS			\
+	add	r2=3DCTX(RR0),r32;		\
+	mov	r16=3Drr[r0];			\
+	dep.z	r18=3D1,61,3;			\
+	;;					\
+	st8	[r2]=3Dr16,8;			\
+	mov	r17=3Drr[r18];			\
+	dep.z	r18=3D2,61,3;			\
+	;;					\
+	st8	[r2]=3Dr17,8;			\
+	mov	r16=3Drr[r18];			\
+	dep.z	r18=3D3,61,3;			\
+	;;					\
+	st8	[r2]=3Dr16,8;			\
+	mov	r17=3Drr[r18];			\
+	dep.z	r18=3D4,61,3;			\
+	;;					\
+	st8	[r2]=3Dr17,8;			\
+	mov	r16=3Drr[r18];			\
+	dep.z	r18=3D5,61,3;			\
+	;;					\
+	st8	[r2]=3Dr16,8;			\
+	mov	r17=3Drr[r18];			\
+	dep.z	r18=3D7,61,3;			\
+	;;					\
+	st8	[r2]=3Dr17,16;			\
+	mov	r16=3Drr[r18];			\
+	;;					\
+	st8	[r2]=3Dr16,8;			\
+	;;
+
+	/*
+	 *	r33:context_t base address
+	 */
+#define	RESTORE_REGION_REGS	\
+	add	r2=3DCTX(RR0),r33;\
+	mov r18=3Dr0;		\
+	;;			\
+	ld8	r20=3D[r2],8;	\
+	;;	/* rr0 */	\
+	ld8	r21=3D[r2],8;	\
+	;;	/* rr1 */	\
+	ld8	r22=3D[r2],8;	\
+	;;	/* rr2 */	\
+	ld8	r23=3D[r2],8;	\
+	;;	/* rr3 */	\
+	ld8	r24=3D[r2],8;	\
+	;;	/* rr4 */	\
+	ld8	r25=3D[r2],16;	\
+	;;	/* rr5 */	\
+	ld8	r27=3D[r2];	\
+	;;	/* rr7 */	\
+	mov rr[r18]=3Dr20;	\
+	dep.z	r18=3D1,61,3;	\
+	;;  /* rr1 */		\
+	mov rr[r18]=3Dr21;	\
+	dep.z	r18=3D2,61,3;	\
+	;;  /* rr2 */		\
+	mov rr[r18]=3Dr22;	\
+	dep.z	r18=3D3,61,3;	\
+	;;  /* rr3 */		\
+	mov rr[r18]=3Dr23;	\
+	dep.z	r18=3D4,61,3;	\
+	;;  /* rr4 */		\
+	mov rr[r18]=3Dr24;	\
+	dep.z	r18=3D5,61,3;	\
+	;;  /* rr5 */		\
+	mov rr[r18]=3Dr25;	\
+	dep.z	r18=3D7,61,3;	\
+	;;  /* rr7 */		\
+	mov rr[r18]=3Dr27;	\
+	;;			\
+	srlz.i;			\
+	;;
+
+
+
+	/*
+	 *	r32:	context_t base address
+	 *	r36~r39:scratch registers
+	 */
+#define	SAVE_DEBUG_REGS				\
+	add	r2=3DCTX(IBR0),r32;		\
+	add	r3=3DCTX(DBR0),r32;		\
+	mov	r16=3Dibr[r0];			\
+	mov	r17=3Ddbr[r0];			\
+	;;					\
+	st8	[r2]=3Dr16,8; 			\
+	st8	[r3]=3Dr17,8;	    		\
+	add	r18=3D1,r0;		    	\
+	;;					\
+	mov	r16=3Dibr[r18];			\
+	mov	r17=3Ddbr[r18];			\
+	;;					\
+	st8	[r2]=3Dr16,8;		    	\
+	st8	[r3]=3Dr17,8;			\
+	add	r18=3D2,r0;			\
+	;;					\
+	mov	r16=3Dibr[r18];			\
+	mov	r17=3Ddbr[r18];			\
+	;;					\
+	st8	[r2]=3Dr16,8;		    	\
+	st8	[r3]=3Dr17,8;			\
+	add	r18=3D2,r0;			\
+	;;					\
+	mov	r16=3Dibr[r18];			\
+	mov	r17=3Ddbr[r18];			\
+	;;					\
+	st8	[r2]=3Dr16,8;		    	\
+	st8	[r3]=3Dr17,8;			\
+	add	r18=3D3,r0;			\
+	;;					\
+	mov	r16=3Dibr[r18];			\
+	mov	r17=3Ddbr[r18];			\
+	;;					\
+	st8	[r2]=3Dr16,8;		    	\
+	st8	[r3]=3Dr17,8;			\
+	add	r18=3D4,r0;			\
+	;;					\
+	mov	r16=3Dibr[r18];			\
+	mov	r17=3Ddbr[r18];			\
+	;;					\
+	st8	[r2]=3Dr16,8;		    	\
+	st8	[r3]=3Dr17,8;			\
+	add	r18=3D5,r0;			\
+	;;					\
+	mov	r16=3Dibr[r18];			\
+	mov	r17=3Ddbr[r18];			\
+	;;					\
+	st8	[r2]=3Dr16,8;		    	\
+	st8	[r3]=3Dr17,8;			\
+	add	r18=3D6,r0;			\
+	;;					\
+	mov	r16=3Dibr[r18];			\
+	mov	r17=3Ddbr[r18];			\
+	;;					\
+	st8	[r2]=3Dr16,8;		    	\
+	st8	[r3]=3Dr17,8;			\
+	add	r18=3D7,r0;			\
+	;;					\
+	mov	r16=3Dibr[r18];			\
+	mov	r17=3Ddbr[r18];			\
+	;;					\
+	st8	[r2]=3Dr16,8;		    	\
+	st8	[r3]=3Dr17,8;			\
+	;;
+
+
+/*
+ *      r33:    point to context_t structure
+ *      ar.lc are corrupted.
+ */
+#define RESTORE_DEBUG_REGS			\
+	add	r2=3DCTX(IBR0),r33;		\
+	add	r3=3DCTX(DBR0),r33;		\
+	mov r16=3D7;    				\
+	mov r17=3Dr0;				\
+	;;                    			\
+	mov ar.lc =3D r16;			\
+	;; 					\
+1:						\
+	ld8 r18=3D[r2],8;		    		\
+	ld8 r19=3D[r3],8;				\
+	;;					\
+	mov ibr[r17]=3Dr18;			\
+	mov dbr[r17]=3Dr19;			\
+	;;   					\
+	srlz.i;					\
+	;; 					\
+	add r17=3D1,r17;				\
+	br.cloop.sptk 1b;			\
+	;;
+
+
+	/*
+	 *	r32:		context_t base address
+	 */
+#define	SAVE_FPU_LOW				\
+	add	r2=3DCTX(F2),r32;			\
+	add	r3=3DCTX(F3),r32;			\
+	;;					\
+	stf.spill.nta	[r2]=3Df2,32;		\
+	stf.spill.nta	[r3]=3Df3,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df4,32;		\
+	stf.spill.nta	[r3]=3Df5,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df6,32;		\
+	stf.spill.nta	[r3]=3Df7,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df8,32;		\
+	stf.spill.nta	[r3]=3Df9,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df10,32;		\
+	stf.spill.nta	[r3]=3Df11,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df12,32;		\
+	stf.spill.nta	[r3]=3Df13,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df14,32;		\
+	stf.spill.nta	[r3]=3Df15,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df16,32;		\
+	stf.spill.nta	[r3]=3Df17,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df18,32;		\
+	stf.spill.nta	[r3]=3Df19,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df20,32;		\
+	stf.spill.nta	[r3]=3Df21,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df22,32;		\
+	stf.spill.nta	[r3]=3Df23,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df24,32;		\
+	stf.spill.nta	[r3]=3Df25,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df26,32;		\
+	stf.spill.nta	[r3]=3Df27,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df28,32;		\
+	stf.spill.nta	[r3]=3Df29,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df30;		\
+	stf.spill.nta	[r3]=3Df31;		\
+	;;
+
+	/*
+	 *	r32:		context_t base address
+	 */
+#define	SAVE_FPU_HIGH				\
+	add	r2=3DCTX(F32),r32;		\
+	add	r3=3DCTX(F33),r32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df32,32;		\
+	stf.spill.nta	[r3]=3Df33,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df34,32;		\
+	stf.spill.nta	[r3]=3Df35,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df36,32;		\
+	stf.spill.nta	[r3]=3Df37,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df38,32;		\
+	stf.spill.nta	[r3]=3Df39,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df40,32;		\
+	stf.spill.nta	[r3]=3Df41,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df42,32;		\
+	stf.spill.nta	[r3]=3Df43,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df44,32;		\
+	stf.spill.nta	[r3]=3Df45,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df46,32;		\
+	stf.spill.nta	[r3]=3Df47,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df48,32;		\
+	stf.spill.nta	[r3]=3Df49,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df50,32;		\
+	stf.spill.nta	[r3]=3Df51,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df52,32;		\
+	stf.spill.nta	[r3]=3Df53,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df54,32;		\
+	stf.spill.nta	[r3]=3Df55,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df56,32;		\
+	stf.spill.nta	[r3]=3Df57,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df58,32;		\
+	stf.spill.nta	[r3]=3Df59,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df60,32;		\
+	stf.spill.nta	[r3]=3Df61,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df62,32;		\
+	stf.spill.nta	[r3]=3Df63,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df64,32;		\
+	stf.spill.nta	[r3]=3Df65,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df66,32;		\
+	stf.spill.nta	[r3]=3Df67,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df68,32;		\
+	stf.spill.nta	[r3]=3Df69,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df70,32;		\
+	stf.spill.nta	[r3]=3Df71,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df72,32;		\
+	stf.spill.nta	[r3]=3Df73,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df74,32;		\
+	stf.spill.nta	[r3]=3Df75,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df76,32;		\
+	stf.spill.nta	[r3]=3Df77,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df78,32;		\
+	stf.spill.nta	[r3]=3Df79,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df80,32;		\
+	stf.spill.nta	[r3]=3Df81,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df82,32;		\
+	stf.spill.nta	[r3]=3Df83,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df84,32;		\
+	stf.spill.nta	[r3]=3Df85,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df86,32;		\
+	stf.spill.nta	[r3]=3Df87,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df88,32;		\
+	stf.spill.nta	[r3]=3Df89,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df90,32;		\
+	stf.spill.nta	[r3]=3Df91,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df92,32;		\
+	stf.spill.nta	[r3]=3Df93,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df94,32;		\
+	stf.spill.nta	[r3]=3Df95,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df96,32;		\
+	stf.spill.nta	[r3]=3Df97,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df98,32;		\
+	stf.spill.nta	[r3]=3Df99,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df100,32;		\
+	stf.spill.nta	[r3]=3Df101,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df102,32;		\
+	stf.spill.nta	[r3]=3Df103,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df104,32;		\
+	stf.spill.nta	[r3]=3Df105,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df106,32;		\
+	stf.spill.nta	[r3]=3Df107,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df108,32;		\
+	stf.spill.nta	[r3]=3Df109,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df110,32;		\
+	stf.spill.nta	[r3]=3Df111,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df112,32;		\
+	stf.spill.nta	[r3]=3Df113,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df114,32;		\
+	stf.spill.nta	[r3]=3Df115,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df116,32;		\
+	stf.spill.nta	[r3]=3Df117,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df118,32;		\
+	stf.spill.nta	[r3]=3Df119,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df120,32;		\
+	stf.spill.nta	[r3]=3Df121,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df122,32;		\
+	stf.spill.nta	[r3]=3Df123,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df124,32;		\
+	stf.spill.nta	[r3]=3Df125,32;		\
+	;;					\
+	stf.spill.nta	[r2]=3Df126;		\
+	stf.spill.nta	[r3]=3Df127;		\
+	;;
+
+     /*
+      *      r33:    point to context_t structure
+      */
+#define	RESTORE_FPU_LOW				\
+    add     r2 =3D CTX(F2), r33;			\
+    add     r3 =3D CTX(F3), r33;			\
+    ;;						\
+    ldf.fill.nta f2 =3D [r2], 32;			\
+    ldf.fill.nta f3 =3D [r3], 32;			\
+    ;;						\
+    ldf.fill.nta f4 =3D [r2], 32;			\
+    ldf.fill.nta f5 =3D [r3], 32;			\
+    ;;						\
+    ldf.fill.nta f6 =3D [r2], 32;			\
+    ldf.fill.nta f7 =3D [r3], 32;			\
+    ;;						\
+    ldf.fill.nta f8 =3D [r2], 32;			\
+    ldf.fill.nta f9 =3D [r3], 32;			\
+    ;;						\
+    ldf.fill.nta f10 =3D [r2], 32;		\
+    ldf.fill.nta f11 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f12 =3D [r2], 32;		\
+    ldf.fill.nta f13 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f14 =3D [r2], 32;		\
+    ldf.fill.nta f15 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f16 =3D [r2], 32;		\
+    ldf.fill.nta f17 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f18 =3D [r2], 32;		\
+    ldf.fill.nta f19 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f20 =3D [r2], 32;		\
+    ldf.fill.nta f21 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f22 =3D [r2], 32;		\
+    ldf.fill.nta f23 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f24 =3D [r2], 32;		\
+    ldf.fill.nta f25 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f26 =3D [r2], 32;		\
+    ldf.fill.nta f27 =3D [r3], 32;		\
+	;;					\
+    ldf.fill.nta f28 =3D [r2], 32;		\
+    ldf.fill.nta f29 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f30 =3D [r2], 32;		\
+    ldf.fill.nta f31 =3D [r3], 32;		\
+    ;;
+
+
+
+    /*
+     *      r33:    point to context_t structure
+     */
+#define	RESTORE_FPU_HIGH			\
+    add     r2 =3D CTX(F32), r33;			\
+    add     r3 =3D CTX(F33), r33;			\
+    ;;						\
+    ldf.fill.nta f32 =3D [r2], 32;		\
+    ldf.fill.nta f33 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f34 =3D [r2], 32;		\
+    ldf.fill.nta f35 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f36 =3D [r2], 32;		\
+    ldf.fill.nta f37 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f38 =3D [r2], 32;		\
+    ldf.fill.nta f39 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f40 =3D [r2], 32;		\
+    ldf.fill.nta f41 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f42 =3D [r2], 32;		\
+    ldf.fill.nta f43 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f44 =3D [r2], 32;		\
+    ldf.fill.nta f45 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f46 =3D [r2], 32;		\
+    ldf.fill.nta f47 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f48 =3D [r2], 32;		\
+    ldf.fill.nta f49 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f50 =3D [r2], 32;		\
+    ldf.fill.nta f51 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f52 =3D [r2], 32;		\
+    ldf.fill.nta f53 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f54 =3D [r2], 32;		\
+    ldf.fill.nta f55 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f56 =3D [r2], 32;		\
+    ldf.fill.nta f57 =3D [r3], 32;   		\
+    ;;						\
+    ldf.fill.nta f58 =3D [r2], 32;		\
+    ldf.fill.nta f59 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f60 =3D [r2], 32;		\
+    ldf.fill.nta f61 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f62 =3D [r2], 32;		\
+    ldf.fill.nta f63 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f64 =3D [r2], 32;		\
+    ldf.fill.nta f65 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f66 =3D [r2], 32;		\
+    ldf.fill.nta f67 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f68 =3D [r2], 32;		\
+    ldf.fill.nta f69 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f70 =3D [r2], 32;		\
+    ldf.fill.nta f71 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f72 =3D [r2], 32;		\
+    ldf.fill.nta f73 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f74 =3D [r2], 32;		\
+    ldf.fill.nta f75 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f76 =3D [r2], 32;		\
+    ldf.fill.nta f77 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f78 =3D [r2], 32;		\
+    ldf.fill.nta f79 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f80 =3D [r2], 32;		\
+    ldf.fill.nta f81 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f82 =3D [r2], 32;		\
+    ldf.fill.nta f83 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f84 =3D [r2], 32;		\
+    ldf.fill.nta f85 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f86 =3D [r2], 32;		\
+    ldf.fill.nta f87 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f88 =3D [r2], 32;		\
+    ldf.fill.nta f89 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f90 =3D [r2], 32;		\
+    ldf.fill.nta f91 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f92 =3D [r2], 32;		\
+    ldf.fill.nta f93 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f94 =3D [r2], 32;		\
+    ldf.fill.nta f95 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f96 =3D [r2], 32;		\
+    ldf.fill.nta f97 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f98 =3D [r2], 32;		\
+    ldf.fill.nta f99 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f100 =3D [r2], 32;		\
+    ldf.fill.nta f101 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f102 =3D [r2], 32;		\
+    ldf.fill.nta f103 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f104 =3D [r2], 32;		\
+    ldf.fill.nta f105 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f106 =3D [r2], 32;		\
+    ldf.fill.nta f107 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f108 =3D [r2], 32;		\
+    ldf.fill.nta f109 =3D [r3], 32;   		\
+    ;;						\
+    ldf.fill.nta f110 =3D [r2], 32;		\
+    ldf.fill.nta f111 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f112 =3D [r2], 32;		\
+    ldf.fill.nta f113 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f114 =3D [r2], 32;		\
+    ldf.fill.nta f115 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f116 =3D [r2], 32;		\
+    ldf.fill.nta f117 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f118 =3D [r2], 32;		\
+    ldf.fill.nta f119 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f120 =3D [r2], 32;		\
+    ldf.fill.nta f121 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f122 =3D [r2], 32;		\
+    ldf.fill.nta f123 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f124 =3D [r2], 32;		\
+    ldf.fill.nta f125 =3D [r3], 32;		\
+    ;;						\
+    ldf.fill.nta f126 =3D [r2], 32;		\
+    ldf.fill.nta f127 =3D [r3], 32;		\
+    ;;
+
+	/*
+	 *	r32:		context_t base address
+	 */
+#define	SAVE_PTK_REGS				\
+    add r2=3DCTX(PKR0), r32;			\
+    mov r16=3D7;    				\
+    ;;                         			\
+    mov ar.lc=3Dr16;  				\
+    mov r17=3Dr0;					\
+    ;;						\
+1:						\
+    mov r18=3Dpkr[r17];				\
+    ;;                     			\
+    srlz.i;					\
+    ;; 						\
+    st8 [r2]=3Dr18, 8;				\
+    ;;    					\
+    add r17 =3D1,r17;				\
+    ;;                     			\
+    br.cloop.sptk 1b;				\
+    ;;
+
+/*
+ *      r33:    point to context_t structure
+ *      ar.lc are corrupted.
+ */
+#define RESTORE_PTK_REGS	    		\
+    add r2=3DCTX(PKR0), r33;			\
+    mov r16=3D7;    				\
+    ;;                         			\
+    mov ar.lc=3Dr16;  				\
+    mov r17=3Dr0;					\
+    ;;						\
+1: 						\
+    ld8 r18=3D[r2], 8;				\
+    ;;						\
+    mov pkr[r17]=3Dr18;				\
+    ;;    					\
+    srlz.i;					\
+    ;; 						\
+    add r17 =3D1,r17;				\
+    ;;                     			\
+    br.cloop.sptk 1b;				\
+    ;;
+
+
+/*
+ * void vmm_trampoline( context_t * from,
+ *			context_t * to)
+ *
+ * 	from:	r32
+ *	to:	r33
+ *  note: interrupt disabled before call this function.
+ */
+GLOBAL_ENTRY(vmm_trampoline)
+    mov r16 =3D psr
+    adds r2 =3D CTX(PSR), r32
+    ;;
+    st8 [r2] =3D r16, 8       // psr
+    mov r17 =3D pr
+    ;;
+    st8 [r2] =3D r17, 8       // pr
+    mov r18 =3D ar.unat
+    ;;
+    st8 [r2] =3D r18
+    mov r17 =3D ar.rsc
+    ;;
+    adds r2 =3D CTX(RSC),r32
+    ;;
+    st8 [r2]=3D r17
+    mov ar.rsc =3D0
+    flushrs
+    ;;
+    SAVE_GENERAL_REGS
+    ;;
+    SAVE_KERNEL_REGS
+    ;;
+    SAVE_APP_REGS
+    ;;
+    SAVE_BRANCH_REGS
+    ;;
+    SAVE_CTL_REGS
+    ;;
+    SAVE_REGION_REGS
+    ;;
+    //SAVE_DEBUG_REGS
+    ;;
+    rsm  psr.dfl
+    ;;
+    srlz.d
+    ;;
+    SAVE_FPU_LOW
+    ;;
+    rsm  psr.dfh
+    ;;
+    srlz.d
+    ;;
+    SAVE_FPU_HIGH
+    ;;
+    SAVE_PTK_REGS
+    ;;
+    RESTORE_PTK_REGS
+    ;;
+    RESTORE_FPU_HIGH
+    ;;
+    RESTORE_FPU_LOW
+    ;;
+    //RESTORE_DEBUG_REGS
+    ;;
+    RESTORE_REGION_REGS
+    ;;
+    RESTORE_CTL_REGS
+    ;;
+    RESTORE_BRANCH_REGS
+    ;;
+    RESTORE_APP_REGS
+    ;;
+    RESTORE_KERNEL_REGS
+    ;;
+    RESTORE_GENERAL_REGS
+    ;;
+    adds r2=3DCTX(PSR), r33
+    ;;
+    ld8 r16=3D[r2], 8       // psr
+    ;;
+    mov psr.l=3Dr16
+    ;;
+    srlz.d
+    ;;
+    ld8 r16=3D[r2], 8       // pr
+    ;;
+    mov pr =3Dr16,-1
+    ld8 r16=3D[r2]       // unat
+    ;;
+    mov ar.unat=3Dr16
+    ;;
+    adds r2=3DCTX(RSC),r33
+    ;;
+    ld8 r16 =3D[r2]
+    ;;
+    mov ar.rsc =3D r16
+    ;;
+    br.ret.sptk.few b0
+END(vmm_trampoline)
+
+
--=20
1.5.2

------_=_NextPart_001_01C893E6.04B0681B
Content-Type: application/octet-stream;
	name="0011-KVM-IA64-Add-trampoline-for-guest-host-mode-switch.patch"
Content-Transfer-Encoding: base64
Content-Description: 0011-KVM-IA64-Add-trampoline-for-guest-host-mode-switch.patch
Content-Disposition: attachment;
	filename="0011-KVM-IA64-Add-trampoline-for-guest-host-mode-switch.patch"

RnJvbSA1OWI0YjJkNTNlY2RjMjdiNjRiYzE1Y2VjNTQ3YWUyYWU2MTQ1ZTk4IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogVHVlLCAxIEFwciAyMDA4IDE0OjU0OjQyICswODAwClN1YmplY3Q6IFtQQVRDSF0g
S1ZNOklBNjQ6IEFkZCB0cmFtcG9saW5lIGZvciBndWVzdC9ob3N0IG1vZGUgc3dpdGNoLgoKdHJh
bXBvbGluZSBjb2RlIHRhcmdldHMgZm9yIGd1ZXN0L2hvc3Qgd29ybGQgc3dpdGNoLgpTaWduZWQt
b2ZmLWJ5OiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNvbT4KLS0tCiBhcmNo
L2lhNjQva3ZtL3RyYW1wb2xpbmUuUyB8IDEwNDAgKysrKysrKysrKysrKysrKysrKysrKysrKysr
KysrKysrKysrKysrKysrKysKIDEgZmlsZXMgY2hhbmdlZCwgMTA0MCBpbnNlcnRpb25zKCspLCAw
IGRlbGV0aW9ucygtKQogY3JlYXRlIG1vZGUgMTAwNjQ0IGFyY2gvaWE2NC9rdm0vdHJhbXBvbGlu
ZS5TCgpkaWZmIC0tZ2l0IGEvYXJjaC9pYTY0L2t2bS90cmFtcG9saW5lLlMgYi9hcmNoL2lhNjQv
a3ZtL3RyYW1wb2xpbmUuUwpuZXcgZmlsZSBtb2RlIDEwMDY0NAppbmRleCAwMDAwMDAwLi5kMzIz
MmI1Ci0tLSAvZGV2L251bGwKKysrIGIvYXJjaC9pYTY0L2t2bS90cmFtcG9saW5lLlMKQEAgLTAs
MCArMSwxMDQwIEBACisvKiBTYXZlIGFsbCBwcm9jZXNzb3Igc3RhdGVzCisgKgorICogQ29weXJp
Z2h0IChjKSAyMDA3IEZsZW1pbmcgRmVuZyA8ZmxlbWluZy5mZW5nQGludGVsLmNvbT4KKyAqIENv
cHlyaWdodCAoYykgMjAwNyBBbnRob255IFh1ICAgPGFudGhvbnkueHVAaW50ZWwuY29tPgorICov
CisKKyNpbmNsdWRlIDxhc20vYXNtbWFjcm8uaD4KKyNpbmNsdWRlICJhc20tb2Zmc2V0cy5oIgor
CisKKyNkZWZpbmUgQ1RYKG5hbWUpICAgIFZNTV9DVFhfIyNuYW1lIyNfT0ZGU0VUCisKKwkvKgor
CSAqCXIzMjoJCWNvbnRleHRfdCBiYXNlIGFkZHJlc3MKKwkgKi8KKyNkZWZpbmUJU0FWRV9CUkFO
Q0hfUkVHUwkJCVwKKwlhZGQJcjIgPSBDVFgoQjApLHIzMjsJCVwKKwlhZGQJcjMgPSBDVFgoQjEp
LHIzMjsJCVwKKwltb3YJcjE2ID0gYjA7CQkJXAorCW1vdglyMTcgPSBiMTsJCQlcCisJOzsJCQkJ
CVwKKwlzdDgJW3IyXT1yMTYsMTY7CQkJXAorCXN0OAlbcjNdPXIxNywxNjsJCQlcCisJOzsJCQkJ
CVwKKwltb3YJcjE2ID0gYjI7CQkJXAorCW1vdglyMTcgPSBiMzsJCQlcCisJOzsJCQkJCVwKKwlz
dDgJW3IyXT1yMTYsMTY7CQkJXAorCXN0OAlbcjNdPXIxNywxNjsJCQlcCisJOzsJCQkJCVwKKwlt
b3YJcjE2ID0gYjQ7CQkJXAorCW1vdglyMTcgPSBiNTsJCQlcCisJOzsJCQkJCVwKKwlzdDgJW3Iy
XT1yMTY7ICAgCQkJXAorCXN0OAlbcjNdPXIxNzsgICAJCQlcCisJOzsKKworCS8qCisJICoJcjMz
OgkJY29udGV4dF90IGJhc2UgYWRkcmVzcworCSAqLworI2RlZmluZQlSRVNUT1JFX0JSQU5DSF9S
RUdTCQkJXAorCWFkZAlyMiA9IENUWChCMCkscjMzOwkJXAorCWFkZAlyMyA9IENUWChCMSkscjMz
OwkJXAorCTs7CQkJCQlcCisJbGQ4CXIxNj1bcjJdLDE2OwkJCVwKKwlsZDgJcjE3PVtyM10sMTY7
CQkJXAorCTs7CQkJCQlcCisJbW92CWIwID0gcjE2OwkJCVwKKwltb3YJYjEgPSByMTc7CQkJXAor
CTs7CQkJCQlcCisJbGQ4CXIxNj1bcjJdLDE2OwkJCVwKKwlsZDgJcjE3PVtyM10sMTY7CQkJXAor
CTs7CQkJCQlcCisJbW92CWIyID0gcjE2OwkJCVwKKwltb3YJYjMgPSByMTc7CQkJXAorCTs7CQkJ
CQlcCisJbGQ4CXIxNj1bcjJdOyAgIAkJCVwKKwlsZDgJcjE3PVtyM107ICAgCQkJXAorCTs7CQkJ
CQlcCisJbW92CWI0PXIxNjsJCQkJXAorCW1vdgliNT1yMTc7CQkJCVwKKwk7OworCisKKwkvKgor
CSAqCXIzMjogY29udGV4dF90IGJhc2UgYWRkcmVzcworCSAqCWJzdyA9PSAxCisJICoJU2F2ZSBh
bGwgYmFuazEgZ2VuZXJhbCByZWdpc3RlcnMsIHI0IH4gcjcKKwkgKi8KKyNkZWZpbmUJU0FWRV9H
RU5FUkFMX1JFR1MJCQlcCisJYWRkCXIyPUNUWChSNCkscjMyOwkJCVwKKwlhZGQJcjM9Q1RYKFI1
KSxyMzI7CQkJXAorCTs7CQkJCQlcCisubWVtLm9mZnNldCAwLDA7ICAgICAgICAJCQlcCisJc3Q4
LnNwaWxsCVtyMl09cjQsMTY7CQlcCisubWVtLm9mZnNldCA4LDA7ICAgICAgICAJCQlcCisJc3Q4
LnNwaWxsCVtyM109cjUsMTY7CQlcCisJOzsJCQkJCVwKKy5tZW0ub2Zmc2V0IDAsMDsgICAgICAg
IAkJCVwKKwlzdDguc3BpbGwJW3IyXT1yNiw0ODsJCVwKKy5tZW0ub2Zmc2V0IDgsMDsgICAgICAg
IAkJCVwKKwlzdDguc3BpbGwJW3IzXT1yNyw0ODsJCVwKKwk7OyAgICAgICAgICAgICAgICAgICAg
ICAgICAgCQlcCisubWVtLm9mZnNldCAwLDA7ICAgICAgICAJCQlcCisgICAgc3Q4LnNwaWxsICAg
IFtyMl09cjEyOwkJCVwKKy5tZW0ub2Zmc2V0IDgsMDsJCQkJXAorICAgIHN0OC5zcGlsbCAgICBb
cjNdPXIxMzsJCQlcCisgICAgOzsKKworCS8qCisJICoJcjMzOiBjb250ZXh0X3QgYmFzZSBhZGRy
ZXNzCisJICoJYnN3ID09IDEKKwkgKi8KKyNkZWZpbmUJUkVTVE9SRV9HRU5FUkFMX1JFR1MJCQlc
CisJYWRkCXIyPUNUWChSNCkscjMzOwkJCVwKKwlhZGQJcjM9Q1RYKFI1KSxyMzM7CQkJXAorCTs7
CQkJCQlcCisJbGQ4LmZpbGwJcjQ9W3IyXSwxNjsJCVwKKwlsZDguZmlsbAlyNT1bcjNdLDE2OwkJ
XAorCTs7CQkJCQlcCisJbGQ4LmZpbGwJcjY9W3IyXSw0ODsJCVwKKwlsZDguZmlsbAlyNz1bcjNd
LDQ4OwkJXAorCTs7CQkJCQlcCisJbGQ4LmZpbGwgICAgcjEyPVtyMl07CQkJXAorCWxkOC5maWxs
ICAgIHIxMyA9W3IzXTsJCQlcCisJOzsKKworCisKKworCS8qCisJICoJcjMyOgkJY29udGV4dF90
IGJhc2UgYWRkcmVzcworCSAqLworI2RlZmluZQlTQVZFX0tFUk5FTF9SRUdTCQkJXAorCWFkZAly
MiA9IENUWChLUjApLHIzMjsJCVwKKwlhZGQJcjMgPSBDVFgoS1IxKSxyMzI7CQlcCisJbW92CXIx
NiA9IGFyLmswOwkJCVwKKwltb3YJcjE3ID0gYXIuazE7CQkJXAorCTs7CQkgICAgICAgIAkJXAor
CXN0OAlbcjJdID0gcjE2LDE2OwkJCVwKKwlzdDgJW3IzXSA9IHIxNywxNjsJCQlcCisJOzsJCSAg
ICAgICAgCQlcCisJbW92CXIxNiA9IGFyLmsyOwkJCVwKKwltb3YJcjE3ID0gYXIuazM7CQkJXAor
CTs7CQkgICAgICAgIAkJXAorCXN0OAlbcjJdID0gcjE2LDE2OwkJCVwKKwlzdDgJW3IzXSA9IHIx
NywxNjsJCQlcCisJOzsJCQkJCVwKKwltb3YJcjE2ID0gYXIuazQ7CQkJXAorCW1vdglyMTcgPSBh
ci5rNTsJCQlcCisJOzsJCQkJICAgIAlcCisJc3Q4CVtyMl0gPSByMTYsMTY7CQkJXAorCXN0OAlb
cjNdID0gcjE3LDE2OwkJCVwKKwk7OwkJCQkJXAorCW1vdglyMTYgPSBhci5rNjsJCQlcCisJbW92
CXIxNyA9IGFyLms3OwkJCVwKKwk7OwkJICAgIAkJCVwKKwlzdDgJW3IyXSA9IHIxNjsgICAgIAkJ
XAorCXN0OAlbcjNdID0gcjE3OwkJCVwKKwk7OworCisKKworCS8qCisJICoJcjMzOgkJY29udGV4
dF90IGJhc2UgYWRkcmVzcworCSAqLworI2RlZmluZQlSRVNUT1JFX0tFUk5FTF9SRUdTCQkJXAor
CWFkZAlyMiA9IENUWChLUjApLHIzMzsJCVwKKwlhZGQJcjMgPSBDVFgoS1IxKSxyMzM7CQlcCisJ
OzsJCSAgICAJCQlcCisJbGQ4CXIxNj1bcjJdLDE2OyAgICAgCQlcCisJbGQ4CXIxNz1bcjNdLDE2
OwkJCVwKKwk7OwkJCQkJXAorCW1vdglhci5rMD1yMTY7ICAJCQlcCisJbW92CWFyLmsxPXIxNzsJ
ICAgIAkJXAorCTs7CQkgICAgICAgIAkJXAorCWxkOAlyMTY9W3IyXSwxNjsJCQlcCisJbGQ4CXIx
Nz1bcjNdLDE2OwkJCVwKKwk7OwkJICAgICAgICAJCVwKKwltb3YJYXIuazI9cjE2OyAgIAkJCVwK
Kwltb3YJYXIuazM9cjE3OwkgICAgCQlcCisJOzsJCSAgICAgICAgCQlcCisJbGQ4CXIxNj1bcjJd
LDE2OwkJCVwKKwlsZDgJcjE3PVtyM10sMTY7CQkJXAorCTs7CQkJCQlcCisJbW92CWFyLms0PXIx
NjsJCQlcCisJbW92CWFyLms1PXIxNzsJICAgIAkJXAorCTs7CQkJCSAgICAJXAorCWxkOAlyMTY9
W3IyXSwxNjsJCQlcCisJbGQ4CXIxNz1bcjNdLDE2OwkJCVwKKwk7OwkJCQkJXAorCW1vdglhci5r
Nj1yMTY7ICAJCQlcCisJbW92CWFyLms3PXIxNzsJICAgIAkJXAorCTs7CisKKworCisJLyoKKwkg
KglyMzI6CQljb250ZXh0X3QgYmFzZSBhZGRyZXNzCisJICovCisjZGVmaW5lCVNBVkVfQVBQX1JF
R1MJCQkJXAorCWFkZCAgcjIgPSBDVFgoQlNQU1RPUkUpLHIzMjsJCVwKKwltb3YgIHIxNiA9IGFy
LmJzcHN0b3JlOwkJCVwKKwk7OwkJCQkJXAorCXN0OCAgW3IyXSA9IHIxNixDVFgoUk5BVCktQ1RY
KEJTUFNUT1JFKTtcCisJbW92ICByMTYgPSBhci5ybmF0OwkJCVwKKwk7OwkJCQkJXAorCXN0OCAg
W3IyXSA9IHIxNixDVFgoRkNSKS1DVFgoUk5BVCk7CVwKKwltb3YgIHIxNiA9IGFyLmZjcjsJCQlc
CisJOzsJCQkJCVwKKwlzdDggIFtyMl0gPSByMTYsQ1RYKEVGTEFHKS1DVFgoRkNSKTsJXAorCW1v
diAgcjE2ID0gYXIuZWZsYWc7CQkJXAorCTs7CQkJCQlcCisJc3Q4ICBbcjJdID0gcjE2LENUWChD
RkxHKS1DVFgoRUZMQUcpOwlcCisJbW92ICByMTYgPSBhci5jZmxnOwkJCVwKKwk7OwkJCQkJXAor
CXN0OCAgW3IyXSA9IHIxNixDVFgoRlNSKS1DVFgoQ0ZMRyk7CVwKKwltb3YgIHIxNiA9IGFyLmZz
cjsJCQlcCisJOzsJCQkJCVwKKwlzdDggIFtyMl0gPSByMTYsQ1RYKEZJUiktQ1RYKEZTUik7CVwK
Kwltb3YgIHIxNiA9IGFyLmZpcjsJCQlcCisJOzsJCQkJCVwKKwlzdDggIFtyMl0gPSByMTYsQ1RY
KEZEUiktQ1RYKEZJUik7CVwKKwltb3YgIHIxNiA9IGFyLmZkcjsJCQlcCisJOzsJCQkJCVwKKwlz
dDggIFtyMl0gPSByMTYsQ1RYKFVOQVQpLUNUWChGRFIpOwlcCisJbW92ICByMTYgPSBhci51bmF0
OwkJCVwKKwk7OwkJCQkJXAorCXN0OCAgW3IyXSA9IHIxNixDVFgoRlBTUiktQ1RYKFVOQVQpOwlc
CisJbW92ICByMTYgPSBhci5mcHNyOwkJCVwKKwk7OwkJCQkJXAorCXN0OCAgW3IyXSA9IHIxNixD
VFgoUEZTKS1DVFgoRlBTUik7CVwKKwltb3YgIHIxNiA9IGFyLnBmczsJCQlcCisJOzsJCQkJCVwK
KwlzdDggIFtyMl0gPSByMTYsQ1RYKExDKS1DVFgoUEZTKTsJXAorCW1vdiAgcjE2ID0gYXIubGM7
CQkJXAorCTs7CQkJCQlcCisJc3Q4ICBbcjJdID0gcjE2OwkJCVwKKwk7OworCisJLyoKKwkgKgly
MzM6CQljb250ZXh0X3QgYmFzZSBhZGRyZXNzCisJICovCisjZGVmaW5lCVJFU1RPUkVfQVBQX1JF
R1MJCQlcCisJYWRkICByMj1DVFgoQlNQU1RPUkUpLHIzMzsJCVwKKwk7OwkJCQkJXAorCWxkOCAg
cjE2PVtyMl0sQ1RYKFJOQVQpLUNUWChCU1BTVE9SRSk7CVwKKwk7OwkJCQkJXAorCW1vdiAgYXIu
YnNwc3RvcmU9cjE2OwkJCVwKKwlsZDggIHIxNj1bcjJdLENUWChGQ1IpLUNUWChSTkFUKTsJXAor
CTs7CQkJCQlcCisJbW92ICBhci5ybmF0PXIxNjsJCQlcCisJbGQ4ICByMTY9W3IyXSxDVFgoRUZM
QUcpLUNUWChGQ1IpOwlcCisJOzsJCQkJCVwKKwltb3YgIGFyLmZjcj1yMTY7CQkJXAorCWxkOCAg
cjE2PVtyMl0sQ1RYKENGTEcpLUNUWChFRkxBRyk7CVwKKwk7OwkJCQkJXAorCW1vdiAgYXIuZWZs
YWc9cjE2OwkJCVwKKwlsZDggIHIxNj1bcjJdLENUWChGU1IpLUNUWChDRkxHKTsJXAorCTs7CQkJ
CQlcCisJbW92ICBhci5jZmxnPXIxNjsJCQlcCisJbGQ4ICByMTY9W3IyXSxDVFgoRklSKS1DVFgo
RlNSKTsJXAorCTs7CQkJCQlcCisJbW92ICBhci5mc3I9cjE2OwkJCVwKKwlsZDggIHIxNj1bcjJd
LENUWChGRFIpLUNUWChGSVIpOwlcCisJOzsJCQkJCVwKKwltb3YgIGFyLmZpcj1yMTY7CQkJXAor
CWxkOCAgcjE2PVtyMl0sQ1RYKFVOQVQpLUNUWChGRFIpOwlcCisJOzsJCQkJCVwKKwltb3YgIGFy
LmZkcj1yMTY7CQkJXAorCWxkOCAgcjE2PVtyMl0sQ1RYKEZQU1IpLUNUWChVTkFUKTsJXAorCTs7
CQkJCQlcCisJbW92ICBhci51bmF0PXIxNjsJCQlcCisJbGQ4ICByMTY9W3IyXSxDVFgoUEZTKS1D
VFgoRlBTUik7CVwKKwk7OwkJCQkJXAorCW1vdiAgYXIuZnBzcj1yMTY7CQkJXAorCWxkOCAgcjE2
PVtyMl0sQ1RYKExDKS1DVFgoUEZTKTsJCVwKKwk7OwkJCQkJXAorCW1vdiAgYXIucGZzPXIxNjsJ
CQlcCisJbGQ4ICByMTY9W3IyXTsJCQkJXAorCTs7CQkJCQlcCisJbW92ICBhci5sYz1yMTY7CQkJ
CVwKKwk7OworCisJLyoKKwkgKglyMzI6CQljb250ZXh0X3QgYmFzZSBhZGRyZXNzCisJICovCisj
ZGVmaW5lCVNBVkVfQ1RMX1JFR1MJCQkJXAorCWFkZAlyMiA9IENUWChEQ1IpLHIzMjsJCVwKKwlt
b3YJcjE2ID0gY3IuZGNyOwkJCVwKKwk7OwkJCQkJXAorCXN0OAlbcjJdID0gcjE2LENUWChJVkEp
LUNUWChEQ1IpOwlcCisJOzsgICAgICAgICAgICAgICAgICAgICAgICAgIAkJXAorCW1vdglyMTYg
PSBjci5pdmE7CQkJXAorCTs7CQkJCQlcCisJc3Q4CVtyMl0gPSByMTYsQ1RYKFBUQSktQ1RYKElW
QSk7CVwKKwk7OwkJCQkJXAorCW1vdiByMTYgPSBjci5wdGE7CQkJXAorCTs7CQkJCQlcCisJc3Q4
IFtyMl0gPSByMTYgOwkJCVwKKwk7OworCisJLyoKKwkgKglyMzM6CQljb250ZXh0X3QgYmFzZSBh
ZGRyZXNzCisJICovCisjZGVmaW5lCVJFU1RPUkVfQ1RMX1JFR1MJCQkJXAorCWFkZAlyMiA9IENU
WChEQ1IpLHIzMzsJICAgICAgICAJXAorCTs7CQkJCQkJXAorCWxkOAlyMTYgPSBbcjJdLENUWChJ
VkEpLUNUWChEQ1IpOwkJXAorCTs7ICAgICAgICAgICAgICAgICAgICAgIAkJCVwKKwltb3YJY3Iu
ZGNyID0gcjE2OwkJCQlcCisJZHZfc2VyaWFsaXplX2RhdGE7CQkJCVwKKwk7OwkJCQkJCVwKKwls
ZDgJcjE2ID0gW3IyXSxDVFgoUFRBKS1DVFgoSVZBKTsJCVwKKwk7OwkJCQkJCVwKKwltb3YJY3Iu
aXZhID0gcjE2OwkJCQlcCisJZHZfc2VyaWFsaXplX2RhdGE7CQkJCVwKKwk7OwkJCQkJCVwKKwls
ZDggcjE2ID0gW3IyXTsJCQkJCVwKKwk7OwkJCQkJCVwKKwltb3YgY3IucHRhID0gcjE2OwkJCQlc
CisJZHZfc2VyaWFsaXplX2RhdGE7CQkJCVwKKwk7OworCisKKwkvKgorCSAqCXIzMjoJCWNvbnRl
eHRfdCBiYXNlIGFkZHJlc3MKKwkgKi8KKyNkZWZpbmUJU0FWRV9SRUdJT05fUkVHUwkJCVwKKwlh
ZGQJcjI9Q1RYKFJSMCkscjMyOwkJXAorCW1vdglyMTY9cnJbcjBdOwkJCVwKKwlkZXAueglyMTg9
MSw2MSwzOwkJCVwKKwk7OwkJCQkJXAorCXN0OAlbcjJdPXIxNiw4OwkJCVwKKwltb3YJcjE3PXJy
W3IxOF07CQkJXAorCWRlcC56CXIxOD0yLDYxLDM7CQkJXAorCTs7CQkJCQlcCisJc3Q4CVtyMl09
cjE3LDg7CQkJXAorCW1vdglyMTY9cnJbcjE4XTsJCQlcCisJZGVwLnoJcjE4PTMsNjEsMzsJCQlc
CisJOzsJCQkJCVwKKwlzdDgJW3IyXT1yMTYsODsJCQlcCisJbW92CXIxNz1ycltyMThdOwkJCVwK
KwlkZXAueglyMTg9NCw2MSwzOwkJCVwKKwk7OwkJCQkJXAorCXN0OAlbcjJdPXIxNyw4OwkJCVwK
Kwltb3YJcjE2PXJyW3IxOF07CQkJXAorCWRlcC56CXIxOD01LDYxLDM7CQkJXAorCTs7CQkJCQlc
CisJc3Q4CVtyMl09cjE2LDg7CQkJXAorCW1vdglyMTc9cnJbcjE4XTsJCQlcCisJZGVwLnoJcjE4
PTcsNjEsMzsJCQlcCisJOzsJCQkJCVwKKwlzdDgJW3IyXT1yMTcsMTY7CQkJXAorCW1vdglyMTY9
cnJbcjE4XTsJCQlcCisJOzsJCQkJCVwKKwlzdDgJW3IyXT1yMTYsODsJCQlcCisJOzsKKworCS8q
CisJICoJcjMzOmNvbnRleHRfdCBiYXNlIGFkZHJlc3MKKwkgKi8KKyNkZWZpbmUJUkVTVE9SRV9S
RUdJT05fUkVHUwlcCisJYWRkCXIyPUNUWChSUjApLHIzMztcCisJbW92IHIxOD1yMDsJCVwKKwk7
OwkJCVwKKwlsZDgJcjIwPVtyMl0sODsJXAorCTs7CS8qIHJyMCAqLwlcCisJbGQ4CXIyMT1bcjJd
LDg7CVwKKwk7OwkvKiBycjEgKi8JXAorCWxkOAlyMjI9W3IyXSw4OwlcCisJOzsJLyogcnIyICov
CVwKKwlsZDgJcjIzPVtyMl0sODsJXAorCTs7CS8qIHJyMyAqLwlcCisJbGQ4CXIyND1bcjJdLDg7
CVwKKwk7OwkvKiBycjQgKi8JXAorCWxkOAlyMjU9W3IyXSwxNjsJXAorCTs7CS8qIHJyNSAqLwlc
CisJbGQ4CXIyNz1bcjJdOwlcCisJOzsJLyogcnI3ICovCVwKKwltb3YgcnJbcjE4XT1yMjA7CVwK
KwlkZXAueglyMTg9MSw2MSwzOwlcCisJOzsgIC8qIHJyMSAqLwkJXAorCW1vdiBycltyMThdPXIy
MTsJXAorCWRlcC56CXIxOD0yLDYxLDM7CVwKKwk7OyAgLyogcnIyICovCQlcCisJbW92IHJyW3Ix
OF09cjIyOwlcCisJZGVwLnoJcjE4PTMsNjEsMzsJXAorCTs7ICAvKiBycjMgKi8JCVwKKwltb3Yg
cnJbcjE4XT1yMjM7CVwKKwlkZXAueglyMTg9NCw2MSwzOwlcCisJOzsgIC8qIHJyNCAqLwkJXAor
CW1vdiBycltyMThdPXIyNDsJXAorCWRlcC56CXIxOD01LDYxLDM7CVwKKwk7OyAgLyogcnI1ICov
CQlcCisJbW92IHJyW3IxOF09cjI1OwlcCisJZGVwLnoJcjE4PTcsNjEsMzsJXAorCTs7ICAvKiBy
cjcgKi8JCVwKKwltb3YgcnJbcjE4XT1yMjc7CVwKKwk7OwkJCVwKKwlzcmx6Lmk7CQkJXAorCTs7
CisKKworCisJLyoKKwkgKglyMzI6CWNvbnRleHRfdCBiYXNlIGFkZHJlc3MKKwkgKglyMzZ+cjM5
OnNjcmF0Y2ggcmVnaXN0ZXJzCisJICovCisjZGVmaW5lCVNBVkVfREVCVUdfUkVHUwkJCQlcCisJ
YWRkCXIyPUNUWChJQlIwKSxyMzI7CQlcCisJYWRkCXIzPUNUWChEQlIwKSxyMzI7CQlcCisJbW92
CXIxNj1pYnJbcjBdOwkJCVwKKwltb3YJcjE3PWRicltyMF07CQkJXAorCTs7CQkJCQlcCisJc3Q4
CVtyMl09cjE2LDg7IAkJCVwKKwlzdDgJW3IzXT1yMTcsODsJICAgIAkJXAorCWFkZAlyMTg9MSxy
MDsJCSAgICAJXAorCTs7CQkJCQlcCisJbW92CXIxNj1pYnJbcjE4XTsJCQlcCisJbW92CXIxNz1k
YnJbcjE4XTsJCQlcCisJOzsJCQkJCVwKKwlzdDgJW3IyXT1yMTYsODsJCSAgICAJXAorCXN0OAlb
cjNdPXIxNyw4OwkJCVwKKwlhZGQJcjE4PTIscjA7CQkJXAorCTs7CQkJCQlcCisJbW92CXIxNj1p
YnJbcjE4XTsJCQlcCisJbW92CXIxNz1kYnJbcjE4XTsJCQlcCisJOzsJCQkJCVwKKwlzdDgJW3Iy
XT1yMTYsODsJCSAgICAJXAorCXN0OAlbcjNdPXIxNyw4OwkJCVwKKwlhZGQJcjE4PTIscjA7CQkJ
XAorCTs7CQkJCQlcCisJbW92CXIxNj1pYnJbcjE4XTsJCQlcCisJbW92CXIxNz1kYnJbcjE4XTsJ
CQlcCisJOzsJCQkJCVwKKwlzdDgJW3IyXT1yMTYsODsJCSAgICAJXAorCXN0OAlbcjNdPXIxNyw4
OwkJCVwKKwlhZGQJcjE4PTMscjA7CQkJXAorCTs7CQkJCQlcCisJbW92CXIxNj1pYnJbcjE4XTsJ
CQlcCisJbW92CXIxNz1kYnJbcjE4XTsJCQlcCisJOzsJCQkJCVwKKwlzdDgJW3IyXT1yMTYsODsJ
CSAgICAJXAorCXN0OAlbcjNdPXIxNyw4OwkJCVwKKwlhZGQJcjE4PTQscjA7CQkJXAorCTs7CQkJ
CQlcCisJbW92CXIxNj1pYnJbcjE4XTsJCQlcCisJbW92CXIxNz1kYnJbcjE4XTsJCQlcCisJOzsJ
CQkJCVwKKwlzdDgJW3IyXT1yMTYsODsJCSAgICAJXAorCXN0OAlbcjNdPXIxNyw4OwkJCVwKKwlh
ZGQJcjE4PTUscjA7CQkJXAorCTs7CQkJCQlcCisJbW92CXIxNj1pYnJbcjE4XTsJCQlcCisJbW92
CXIxNz1kYnJbcjE4XTsJCQlcCisJOzsJCQkJCVwKKwlzdDgJW3IyXT1yMTYsODsJCSAgICAJXAor
CXN0OAlbcjNdPXIxNyw4OwkJCVwKKwlhZGQJcjE4PTYscjA7CQkJXAorCTs7CQkJCQlcCisJbW92
CXIxNj1pYnJbcjE4XTsJCQlcCisJbW92CXIxNz1kYnJbcjE4XTsJCQlcCisJOzsJCQkJCVwKKwlz
dDgJW3IyXT1yMTYsODsJCSAgICAJXAorCXN0OAlbcjNdPXIxNyw4OwkJCVwKKwlhZGQJcjE4PTcs
cjA7CQkJXAorCTs7CQkJCQlcCisJbW92CXIxNj1pYnJbcjE4XTsJCQlcCisJbW92CXIxNz1kYnJb
cjE4XTsJCQlcCisJOzsJCQkJCVwKKwlzdDgJW3IyXT1yMTYsODsJCSAgICAJXAorCXN0OAlbcjNd
PXIxNyw4OwkJCVwKKwk7OworCisKKy8qCisgKiAgICAgIHIzMzogICAgcG9pbnQgdG8gY29udGV4
dF90IHN0cnVjdHVyZQorICogICAgICBhci5sYyBhcmUgY29ycnVwdGVkLgorICovCisjZGVmaW5l
IFJFU1RPUkVfREVCVUdfUkVHUwkJCVwKKwlhZGQJcjI9Q1RYKElCUjApLHIzMzsJCVwKKwlhZGQJ
cjM9Q1RYKERCUjApLHIzMzsJCVwKKwltb3YgcjE2PTc7ICAgIAkJCQlcCisJbW92IHIxNz1yMDsJ
CQkJXAorCTs7ICAgICAgICAgICAgICAgICAgICAJCQlcCisJbW92IGFyLmxjID0gcjE2OwkJCVwK
Kwk7OyAJCQkJCVwKKzE6CQkJCQkJXAorCWxkOCByMTg9W3IyXSw4OwkJICAgIAkJXAorCWxkOCBy
MTk9W3IzXSw4OwkJCQlcCisJOzsJCQkJCVwKKwltb3YgaWJyW3IxN109cjE4OwkJCVwKKwltb3Yg
ZGJyW3IxN109cjE5OwkJCVwKKwk7OyAgIAkJCQkJXAorCXNybHouaTsJCQkJCVwKKwk7OyAJCQkJ
CVwKKwlhZGQgcjE3PTEscjE3OwkJCQlcCisJYnIuY2xvb3Auc3B0ayAxYjsJCQlcCisJOzsKKwor
CisJLyoKKwkgKglyMzI6CQljb250ZXh0X3QgYmFzZSBhZGRyZXNzCisJICovCisjZGVmaW5lCVNB
VkVfRlBVX0xPVwkJCQlcCisJYWRkCXIyPUNUWChGMikscjMyOwkJCVwKKwlhZGQJcjM9Q1RYKEYz
KSxyMzI7CQkJXAorCTs7CQkJCQlcCisJc3RmLnNwaWxsLm50YQlbcjJdPWYyLDMyOwkJXAorCXN0
Zi5zcGlsbC5udGEJW3IzXT1mMywzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3Iy
XT1mNCwzMjsJCVwKKwlzdGYuc3BpbGwubnRhCVtyM109ZjUsMzI7CQlcCisJOzsJCQkJCVwKKwlz
dGYuc3BpbGwubnRhCVtyMl09ZjYsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWY3LDMyOwkJ
XAorCTs7CQkJCQlcCisJc3RmLnNwaWxsLm50YQlbcjJdPWY4LDMyOwkJXAorCXN0Zi5zcGlsbC5u
dGEJW3IzXT1mOSwzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mMTAsMzI7
CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWYxMSwzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGls
bC5udGEJW3IyXT1mMTIsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWYxMywzMjsJCVwKKwk7
OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mMTQsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlb
cjNdPWYxNSwzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mMTYsMzI7CQlc
CisJc3RmLnNwaWxsLm50YQlbcjNdPWYxNywzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5u
dGEJW3IyXT1mMTgsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWYxOSwzMjsJCVwKKwk7OwkJ
CQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mMjAsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNd
PWYyMSwzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mMjIsMzI7CQlcCisJ
c3RmLnNwaWxsLm50YQlbcjNdPWYyMywzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJ
W3IyXT1mMjQsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWYyNSwzMjsJCVwKKwk7OwkJCQkJ
XAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mMjYsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWYy
NywzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mMjgsMzI7CQlcCisJc3Rm
LnNwaWxsLm50YQlbcjNdPWYyOSwzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3Iy
XT1mMzA7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWYzMTsJCVwKKwk7OworCisJLyoKKwkgKgly
MzI6CQljb250ZXh0X3QgYmFzZSBhZGRyZXNzCisJICovCisjZGVmaW5lCVNBVkVfRlBVX0hJR0gJ
CQkJXAorCWFkZAlyMj1DVFgoRjMyKSxyMzI7CQlcCisJYWRkCXIzPUNUWChGMzMpLHIzMjsJCVwK
Kwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mMzIsMzI7CQlcCisJc3RmLnNwaWxsLm50
YQlbcjNdPWYzMywzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mMzQsMzI7
CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWYzNSwzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGls
bC5udGEJW3IyXT1mMzYsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWYzNywzMjsJCVwKKwk7
OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mMzgsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlb
cjNdPWYzOSwzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mNDAsMzI7CQlc
CisJc3RmLnNwaWxsLm50YQlbcjNdPWY0MSwzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5u
dGEJW3IyXT1mNDIsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWY0MywzMjsJCVwKKwk7OwkJ
CQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mNDQsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNd
PWY0NSwzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mNDYsMzI7CQlcCisJ
c3RmLnNwaWxsLm50YQlbcjNdPWY0NywzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJ
W3IyXT1mNDgsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWY0OSwzMjsJCVwKKwk7OwkJCQkJ
XAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mNTAsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWY1
MSwzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mNTIsMzI7CQlcCisJc3Rm
LnNwaWxsLm50YQlbcjNdPWY1MywzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3Iy
XT1mNTQsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWY1NSwzMjsJCVwKKwk7OwkJCQkJXAor
CXN0Zi5zcGlsbC5udGEJW3IyXT1mNTYsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWY1Nywz
MjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mNTgsMzI7CQlcCisJc3RmLnNw
aWxsLm50YQlbcjNdPWY1OSwzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1m
NjAsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWY2MSwzMjsJCVwKKwk7OwkJCQkJXAorCXN0
Zi5zcGlsbC5udGEJW3IyXT1mNjIsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWY2MywzMjsJ
CVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mNjQsMzI7CQlcCisJc3RmLnNwaWxs
Lm50YQlbcjNdPWY2NSwzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mNjYs
MzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWY2NywzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5z
cGlsbC5udGEJW3IyXT1mNjgsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWY2OSwzMjsJCVwK
Kwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mNzAsMzI7CQlcCisJc3RmLnNwaWxsLm50
YQlbcjNdPWY3MSwzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mNzIsMzI7
CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWY3MywzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGls
bC5udGEJW3IyXT1mNzQsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWY3NSwzMjsJCVwKKwk7
OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mNzYsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlb
cjNdPWY3NywzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mNzgsMzI7CQlc
CisJc3RmLnNwaWxsLm50YQlbcjNdPWY3OSwzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5u
dGEJW3IyXT1mODAsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWY4MSwzMjsJCVwKKwk7OwkJ
CQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mODIsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNd
PWY4MywzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mODQsMzI7CQlcCisJ
c3RmLnNwaWxsLm50YQlbcjNdPWY4NSwzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJ
W3IyXT1mODYsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWY4NywzMjsJCVwKKwk7OwkJCQkJ
XAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mODgsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWY4
OSwzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mOTAsMzI7CQlcCisJc3Rm
LnNwaWxsLm50YQlbcjNdPWY5MSwzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3Iy
XT1mOTIsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWY5MywzMjsJCVwKKwk7OwkJCQkJXAor
CXN0Zi5zcGlsbC5udGEJW3IyXT1mOTQsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWY5NSwz
MjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mOTYsMzI7CQlcCisJc3RmLnNw
aWxsLm50YQlbcjNdPWY5NywzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1m
OTgsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWY5OSwzMjsJCVwKKwk7OwkJCQkJXAorCXN0
Zi5zcGlsbC5udGEJW3IyXT1mMTAwLDMyOwkJXAorCXN0Zi5zcGlsbC5udGEJW3IzXT1mMTAxLDMy
OwkJXAorCTs7CQkJCQlcCisJc3RmLnNwaWxsLm50YQlbcjJdPWYxMDIsMzI7CQlcCisJc3RmLnNw
aWxsLm50YQlbcjNdPWYxMDMsMzI7CQlcCisJOzsJCQkJCVwKKwlzdGYuc3BpbGwubnRhCVtyMl09
ZjEwNCwzMjsJCVwKKwlzdGYuc3BpbGwubnRhCVtyM109ZjEwNSwzMjsJCVwKKwk7OwkJCQkJXAor
CXN0Zi5zcGlsbC5udGEJW3IyXT1mMTA2LDMyOwkJXAorCXN0Zi5zcGlsbC5udGEJW3IzXT1mMTA3
LDMyOwkJXAorCTs7CQkJCQlcCisJc3RmLnNwaWxsLm50YQlbcjJdPWYxMDgsMzI7CQlcCisJc3Rm
LnNwaWxsLm50YQlbcjNdPWYxMDksMzI7CQlcCisJOzsJCQkJCVwKKwlzdGYuc3BpbGwubnRhCVty
Ml09ZjExMCwzMjsJCVwKKwlzdGYuc3BpbGwubnRhCVtyM109ZjExMSwzMjsJCVwKKwk7OwkJCQkJ
XAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mMTEyLDMyOwkJXAorCXN0Zi5zcGlsbC5udGEJW3IzXT1m
MTEzLDMyOwkJXAorCTs7CQkJCQlcCisJc3RmLnNwaWxsLm50YQlbcjJdPWYxMTQsMzI7CQlcCisJ
c3RmLnNwaWxsLm50YQlbcjNdPWYxMTUsMzI7CQlcCisJOzsJCQkJCVwKKwlzdGYuc3BpbGwubnRh
CVtyMl09ZjExNiwzMjsJCVwKKwlzdGYuc3BpbGwubnRhCVtyM109ZjExNywzMjsJCVwKKwk7OwkJ
CQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mMTE4LDMyOwkJXAorCXN0Zi5zcGlsbC5udGEJW3Iz
XT1mMTE5LDMyOwkJXAorCTs7CQkJCQlcCisJc3RmLnNwaWxsLm50YQlbcjJdPWYxMjAsMzI7CQlc
CisJc3RmLnNwaWxsLm50YQlbcjNdPWYxMjEsMzI7CQlcCisJOzsJCQkJCVwKKwlzdGYuc3BpbGwu
bnRhCVtyMl09ZjEyMiwzMjsJCVwKKwlzdGYuc3BpbGwubnRhCVtyM109ZjEyMywzMjsJCVwKKwk7
OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mMTI0LDMyOwkJXAorCXN0Zi5zcGlsbC5udGEJ
W3IzXT1mMTI1LDMyOwkJXAorCTs7CQkJCQlcCisJc3RmLnNwaWxsLm50YQlbcjJdPWYxMjY7CQlc
CisJc3RmLnNwaWxsLm50YQlbcjNdPWYxMjc7CQlcCisJOzsKKworICAgICAvKgorICAgICAgKiAg
ICAgIHIzMzogICAgcG9pbnQgdG8gY29udGV4dF90IHN0cnVjdHVyZQorICAgICAgKi8KKyNkZWZp
bmUJUkVTVE9SRV9GUFVfTE9XCQkJCVwKKyAgICBhZGQgICAgIHIyID0gQ1RYKEYyKSwgcjMzOwkJ
CVwKKyAgICBhZGQgICAgIHIzID0gQ1RYKEYzKSwgcjMzOwkJCVwKKyAgICA7OwkJCQkJCVwKKyAg
ICBsZGYuZmlsbC5udGEgZjIgPSBbcjJdLCAzMjsJCQlcCisgICAgbGRmLmZpbGwubnRhIGYzID0g
W3IzXSwgMzI7CQkJXAorICAgIDs7CQkJCQkJXAorICAgIGxkZi5maWxsLm50YSBmNCA9IFtyMl0s
IDMyOwkJCVwKKyAgICBsZGYuZmlsbC5udGEgZjUgPSBbcjNdLCAzMjsJCQlcCisgICAgOzsJCQkJ
CQlcCisgICAgbGRmLmZpbGwubnRhIGY2ID0gW3IyXSwgMzI7CQkJXAorICAgIGxkZi5maWxsLm50
YSBmNyA9IFtyM10sIDMyOwkJCVwKKyAgICA7OwkJCQkJCVwKKyAgICBsZGYuZmlsbC5udGEgZjgg
PSBbcjJdLCAzMjsJCQlcCisgICAgbGRmLmZpbGwubnRhIGY5ID0gW3IzXSwgMzI7CQkJXAorICAg
IDs7CQkJCQkJXAorICAgIGxkZi5maWxsLm50YSBmMTAgPSBbcjJdLCAzMjsJCVwKKyAgICBsZGYu
ZmlsbC5udGEgZjExID0gW3IzXSwgMzI7CQlcCisgICAgOzsJCQkJCQlcCisgICAgbGRmLmZpbGwu
bnRhIGYxMiA9IFtyMl0sIDMyOwkJXAorICAgIGxkZi5maWxsLm50YSBmMTMgPSBbcjNdLCAzMjsJ
CVwKKyAgICA7OwkJCQkJCVwKKyAgICBsZGYuZmlsbC5udGEgZjE0ID0gW3IyXSwgMzI7CQlcCisg
ICAgbGRmLmZpbGwubnRhIGYxNSA9IFtyM10sIDMyOwkJXAorICAgIDs7CQkJCQkJXAorICAgIGxk
Zi5maWxsLm50YSBmMTYgPSBbcjJdLCAzMjsJCVwKKyAgICBsZGYuZmlsbC5udGEgZjE3ID0gW3Iz
XSwgMzI7CQlcCisgICAgOzsJCQkJCQlcCisgICAgbGRmLmZpbGwubnRhIGYxOCA9IFtyMl0sIDMy
OwkJXAorICAgIGxkZi5maWxsLm50YSBmMTkgPSBbcjNdLCAzMjsJCVwKKyAgICA7OwkJCQkJCVwK
KyAgICBsZGYuZmlsbC5udGEgZjIwID0gW3IyXSwgMzI7CQlcCisgICAgbGRmLmZpbGwubnRhIGYy
MSA9IFtyM10sIDMyOwkJXAorICAgIDs7CQkJCQkJXAorICAgIGxkZi5maWxsLm50YSBmMjIgPSBb
cjJdLCAzMjsJCVwKKyAgICBsZGYuZmlsbC5udGEgZjIzID0gW3IzXSwgMzI7CQlcCisgICAgOzsJ
CQkJCQlcCisgICAgbGRmLmZpbGwubnRhIGYyNCA9IFtyMl0sIDMyOwkJXAorICAgIGxkZi5maWxs
Lm50YSBmMjUgPSBbcjNdLCAzMjsJCVwKKyAgICA7OwkJCQkJCVwKKyAgICBsZGYuZmlsbC5udGEg
ZjI2ID0gW3IyXSwgMzI7CQlcCisgICAgbGRmLmZpbGwubnRhIGYyNyA9IFtyM10sIDMyOwkJXAor
CTs7CQkJCQlcCisgICAgbGRmLmZpbGwubnRhIGYyOCA9IFtyMl0sIDMyOwkJXAorICAgIGxkZi5m
aWxsLm50YSBmMjkgPSBbcjNdLCAzMjsJCVwKKyAgICA7OwkJCQkJCVwKKyAgICBsZGYuZmlsbC5u
dGEgZjMwID0gW3IyXSwgMzI7CQlcCisgICAgbGRmLmZpbGwubnRhIGYzMSA9IFtyM10sIDMyOwkJ
XAorICAgIDs7CisKKworCisgICAgLyoKKyAgICAgKiAgICAgIHIzMzogICAgcG9pbnQgdG8gY29u
dGV4dF90IHN0cnVjdHVyZQorICAgICAqLworI2RlZmluZQlSRVNUT1JFX0ZQVV9ISUdICQkJXAor
ICAgIGFkZCAgICAgcjIgPSBDVFgoRjMyKSwgcjMzOwkJCVwKKyAgICBhZGQgICAgIHIzID0gQ1RY
KEYzMyksIHIzMzsJCQlcCisgICAgOzsJCQkJCQlcCisgICAgbGRmLmZpbGwubnRhIGYzMiA9IFty
Ml0sIDMyOwkJXAorICAgIGxkZi5maWxsLm50YSBmMzMgPSBbcjNdLCAzMjsJCVwKKyAgICA7OwkJ
CQkJCVwKKyAgICBsZGYuZmlsbC5udGEgZjM0ID0gW3IyXSwgMzI7CQlcCisgICAgbGRmLmZpbGwu
bnRhIGYzNSA9IFtyM10sIDMyOwkJXAorICAgIDs7CQkJCQkJXAorICAgIGxkZi5maWxsLm50YSBm
MzYgPSBbcjJdLCAzMjsJCVwKKyAgICBsZGYuZmlsbC5udGEgZjM3ID0gW3IzXSwgMzI7CQlcCisg
ICAgOzsJCQkJCQlcCisgICAgbGRmLmZpbGwubnRhIGYzOCA9IFtyMl0sIDMyOwkJXAorICAgIGxk
Zi5maWxsLm50YSBmMzkgPSBbcjNdLCAzMjsJCVwKKyAgICA7OwkJCQkJCVwKKyAgICBsZGYuZmls
bC5udGEgZjQwID0gW3IyXSwgMzI7CQlcCisgICAgbGRmLmZpbGwubnRhIGY0MSA9IFtyM10sIDMy
OwkJXAorICAgIDs7CQkJCQkJXAorICAgIGxkZi5maWxsLm50YSBmNDIgPSBbcjJdLCAzMjsJCVwK
KyAgICBsZGYuZmlsbC5udGEgZjQzID0gW3IzXSwgMzI7CQlcCisgICAgOzsJCQkJCQlcCisgICAg
bGRmLmZpbGwubnRhIGY0NCA9IFtyMl0sIDMyOwkJXAorICAgIGxkZi5maWxsLm50YSBmNDUgPSBb
cjNdLCAzMjsJCVwKKyAgICA7OwkJCQkJCVwKKyAgICBsZGYuZmlsbC5udGEgZjQ2ID0gW3IyXSwg
MzI7CQlcCisgICAgbGRmLmZpbGwubnRhIGY0NyA9IFtyM10sIDMyOwkJXAorICAgIDs7CQkJCQkJ
XAorICAgIGxkZi5maWxsLm50YSBmNDggPSBbcjJdLCAzMjsJCVwKKyAgICBsZGYuZmlsbC5udGEg
ZjQ5ID0gW3IzXSwgMzI7CQlcCisgICAgOzsJCQkJCQlcCisgICAgbGRmLmZpbGwubnRhIGY1MCA9
IFtyMl0sIDMyOwkJXAorICAgIGxkZi5maWxsLm50YSBmNTEgPSBbcjNdLCAzMjsJCVwKKyAgICA7
OwkJCQkJCVwKKyAgICBsZGYuZmlsbC5udGEgZjUyID0gW3IyXSwgMzI7CQlcCisgICAgbGRmLmZp
bGwubnRhIGY1MyA9IFtyM10sIDMyOwkJXAorICAgIDs7CQkJCQkJXAorICAgIGxkZi5maWxsLm50
YSBmNTQgPSBbcjJdLCAzMjsJCVwKKyAgICBsZGYuZmlsbC5udGEgZjU1ID0gW3IzXSwgMzI7CQlc
CisgICAgOzsJCQkJCQlcCisgICAgbGRmLmZpbGwubnRhIGY1NiA9IFtyMl0sIDMyOwkJXAorICAg
IGxkZi5maWxsLm50YSBmNTcgPSBbcjNdLCAzMjsgICAJCVwKKyAgICA7OwkJCQkJCVwKKyAgICBs
ZGYuZmlsbC5udGEgZjU4ID0gW3IyXSwgMzI7CQlcCisgICAgbGRmLmZpbGwubnRhIGY1OSA9IFty
M10sIDMyOwkJXAorICAgIDs7CQkJCQkJXAorICAgIGxkZi5maWxsLm50YSBmNjAgPSBbcjJdLCAz
MjsJCVwKKyAgICBsZGYuZmlsbC5udGEgZjYxID0gW3IzXSwgMzI7CQlcCisgICAgOzsJCQkJCQlc
CisgICAgbGRmLmZpbGwubnRhIGY2MiA9IFtyMl0sIDMyOwkJXAorICAgIGxkZi5maWxsLm50YSBm
NjMgPSBbcjNdLCAzMjsJCVwKKyAgICA7OwkJCQkJCVwKKyAgICBsZGYuZmlsbC5udGEgZjY0ID0g
W3IyXSwgMzI7CQlcCisgICAgbGRmLmZpbGwubnRhIGY2NSA9IFtyM10sIDMyOwkJXAorICAgIDs7
CQkJCQkJXAorICAgIGxkZi5maWxsLm50YSBmNjYgPSBbcjJdLCAzMjsJCVwKKyAgICBsZGYuZmls
bC5udGEgZjY3ID0gW3IzXSwgMzI7CQlcCisgICAgOzsJCQkJCQlcCisgICAgbGRmLmZpbGwubnRh
IGY2OCA9IFtyMl0sIDMyOwkJXAorICAgIGxkZi5maWxsLm50YSBmNjkgPSBbcjNdLCAzMjsJCVwK
KyAgICA7OwkJCQkJCVwKKyAgICBsZGYuZmlsbC5udGEgZjcwID0gW3IyXSwgMzI7CQlcCisgICAg
bGRmLmZpbGwubnRhIGY3MSA9IFtyM10sIDMyOwkJXAorICAgIDs7CQkJCQkJXAorICAgIGxkZi5m
aWxsLm50YSBmNzIgPSBbcjJdLCAzMjsJCVwKKyAgICBsZGYuZmlsbC5udGEgZjczID0gW3IzXSwg
MzI7CQlcCisgICAgOzsJCQkJCQlcCisgICAgbGRmLmZpbGwubnRhIGY3NCA9IFtyMl0sIDMyOwkJ
XAorICAgIGxkZi5maWxsLm50YSBmNzUgPSBbcjNdLCAzMjsJCVwKKyAgICA7OwkJCQkJCVwKKyAg
ICBsZGYuZmlsbC5udGEgZjc2ID0gW3IyXSwgMzI7CQlcCisgICAgbGRmLmZpbGwubnRhIGY3NyA9
IFtyM10sIDMyOwkJXAorICAgIDs7CQkJCQkJXAorICAgIGxkZi5maWxsLm50YSBmNzggPSBbcjJd
LCAzMjsJCVwKKyAgICBsZGYuZmlsbC5udGEgZjc5ID0gW3IzXSwgMzI7CQlcCisgICAgOzsJCQkJ
CQlcCisgICAgbGRmLmZpbGwubnRhIGY4MCA9IFtyMl0sIDMyOwkJXAorICAgIGxkZi5maWxsLm50
YSBmODEgPSBbcjNdLCAzMjsJCVwKKyAgICA7OwkJCQkJCVwKKyAgICBsZGYuZmlsbC5udGEgZjgy
ID0gW3IyXSwgMzI7CQlcCisgICAgbGRmLmZpbGwubnRhIGY4MyA9IFtyM10sIDMyOwkJXAorICAg
IDs7CQkJCQkJXAorICAgIGxkZi5maWxsLm50YSBmODQgPSBbcjJdLCAzMjsJCVwKKyAgICBsZGYu
ZmlsbC5udGEgZjg1ID0gW3IzXSwgMzI7CQlcCisgICAgOzsJCQkJCQlcCisgICAgbGRmLmZpbGwu
bnRhIGY4NiA9IFtyMl0sIDMyOwkJXAorICAgIGxkZi5maWxsLm50YSBmODcgPSBbcjNdLCAzMjsJ
CVwKKyAgICA7OwkJCQkJCVwKKyAgICBsZGYuZmlsbC5udGEgZjg4ID0gW3IyXSwgMzI7CQlcCisg
ICAgbGRmLmZpbGwubnRhIGY4OSA9IFtyM10sIDMyOwkJXAorICAgIDs7CQkJCQkJXAorICAgIGxk
Zi5maWxsLm50YSBmOTAgPSBbcjJdLCAzMjsJCVwKKyAgICBsZGYuZmlsbC5udGEgZjkxID0gW3Iz
XSwgMzI7CQlcCisgICAgOzsJCQkJCQlcCisgICAgbGRmLmZpbGwubnRhIGY5MiA9IFtyMl0sIDMy
OwkJXAorICAgIGxkZi5maWxsLm50YSBmOTMgPSBbcjNdLCAzMjsJCVwKKyAgICA7OwkJCQkJCVwK
KyAgICBsZGYuZmlsbC5udGEgZjk0ID0gW3IyXSwgMzI7CQlcCisgICAgbGRmLmZpbGwubnRhIGY5
NSA9IFtyM10sIDMyOwkJXAorICAgIDs7CQkJCQkJXAorICAgIGxkZi5maWxsLm50YSBmOTYgPSBb
cjJdLCAzMjsJCVwKKyAgICBsZGYuZmlsbC5udGEgZjk3ID0gW3IzXSwgMzI7CQlcCisgICAgOzsJ
CQkJCQlcCisgICAgbGRmLmZpbGwubnRhIGY5OCA9IFtyMl0sIDMyOwkJXAorICAgIGxkZi5maWxs
Lm50YSBmOTkgPSBbcjNdLCAzMjsJCVwKKyAgICA7OwkJCQkJCVwKKyAgICBsZGYuZmlsbC5udGEg
ZjEwMCA9IFtyMl0sIDMyOwkJXAorICAgIGxkZi5maWxsLm50YSBmMTAxID0gW3IzXSwgMzI7CQlc
CisgICAgOzsJCQkJCQlcCisgICAgbGRmLmZpbGwubnRhIGYxMDIgPSBbcjJdLCAzMjsJCVwKKyAg
ICBsZGYuZmlsbC5udGEgZjEwMyA9IFtyM10sIDMyOwkJXAorICAgIDs7CQkJCQkJXAorICAgIGxk
Zi5maWxsLm50YSBmMTA0ID0gW3IyXSwgMzI7CQlcCisgICAgbGRmLmZpbGwubnRhIGYxMDUgPSBb
cjNdLCAzMjsJCVwKKyAgICA7OwkJCQkJCVwKKyAgICBsZGYuZmlsbC5udGEgZjEwNiA9IFtyMl0s
IDMyOwkJXAorICAgIGxkZi5maWxsLm50YSBmMTA3ID0gW3IzXSwgMzI7CQlcCisgICAgOzsJCQkJ
CQlcCisgICAgbGRmLmZpbGwubnRhIGYxMDggPSBbcjJdLCAzMjsJCVwKKyAgICBsZGYuZmlsbC5u
dGEgZjEwOSA9IFtyM10sIDMyOyAgIAkJXAorICAgIDs7CQkJCQkJXAorICAgIGxkZi5maWxsLm50
YSBmMTEwID0gW3IyXSwgMzI7CQlcCisgICAgbGRmLmZpbGwubnRhIGYxMTEgPSBbcjNdLCAzMjsJ
CVwKKyAgICA7OwkJCQkJCVwKKyAgICBsZGYuZmlsbC5udGEgZjExMiA9IFtyMl0sIDMyOwkJXAor
ICAgIGxkZi5maWxsLm50YSBmMTEzID0gW3IzXSwgMzI7CQlcCisgICAgOzsJCQkJCQlcCisgICAg
bGRmLmZpbGwubnRhIGYxMTQgPSBbcjJdLCAzMjsJCVwKKyAgICBsZGYuZmlsbC5udGEgZjExNSA9
IFtyM10sIDMyOwkJXAorICAgIDs7CQkJCQkJXAorICAgIGxkZi5maWxsLm50YSBmMTE2ID0gW3Iy
XSwgMzI7CQlcCisgICAgbGRmLmZpbGwubnRhIGYxMTcgPSBbcjNdLCAzMjsJCVwKKyAgICA7OwkJ
CQkJCVwKKyAgICBsZGYuZmlsbC5udGEgZjExOCA9IFtyMl0sIDMyOwkJXAorICAgIGxkZi5maWxs
Lm50YSBmMTE5ID0gW3IzXSwgMzI7CQlcCisgICAgOzsJCQkJCQlcCisgICAgbGRmLmZpbGwubnRh
IGYxMjAgPSBbcjJdLCAzMjsJCVwKKyAgICBsZGYuZmlsbC5udGEgZjEyMSA9IFtyM10sIDMyOwkJ
XAorICAgIDs7CQkJCQkJXAorICAgIGxkZi5maWxsLm50YSBmMTIyID0gW3IyXSwgMzI7CQlcCisg
ICAgbGRmLmZpbGwubnRhIGYxMjMgPSBbcjNdLCAzMjsJCVwKKyAgICA7OwkJCQkJCVwKKyAgICBs
ZGYuZmlsbC5udGEgZjEyNCA9IFtyMl0sIDMyOwkJXAorICAgIGxkZi5maWxsLm50YSBmMTI1ID0g
W3IzXSwgMzI7CQlcCisgICAgOzsJCQkJCQlcCisgICAgbGRmLmZpbGwubnRhIGYxMjYgPSBbcjJd
LCAzMjsJCVwKKyAgICBsZGYuZmlsbC5udGEgZjEyNyA9IFtyM10sIDMyOwkJXAorICAgIDs7CisK
KwkvKgorCSAqCXIzMjoJCWNvbnRleHRfdCBiYXNlIGFkZHJlc3MKKwkgKi8KKyNkZWZpbmUJU0FW
RV9QVEtfUkVHUwkJCQlcCisgICAgYWRkIHIyPUNUWChQS1IwKSwgcjMyOwkJCVwKKyAgICBtb3Yg
cjE2PTc7ICAgIAkJCQlcCisgICAgOzsgICAgICAgICAgICAgICAgICAgICAgICAgCQkJXAorICAg
IG1vdiBhci5sYz1yMTY7ICAJCQkJXAorICAgIG1vdiByMTc9cjA7CQkJCQlcCisgICAgOzsJCQkJ
CQlcCisxOgkJCQkJCVwKKyAgICBtb3YgcjE4PXBrcltyMTddOwkJCQlcCisgICAgOzsgICAgICAg
ICAgICAgICAgICAgICAJCQlcCisgICAgc3Jsei5pOwkJCQkJXAorICAgIDs7IAkJCQkJCVwKKyAg
ICBzdDggW3IyXT1yMTgsIDg7CQkJCVwKKyAgICA7OyAgICAJCQkJCVwKKyAgICBhZGQgcjE3ID0x
LHIxNzsJCQkJXAorICAgIDs7ICAgICAgICAgICAgICAgICAgICAgCQkJXAorICAgIGJyLmNsb29w
LnNwdGsgMWI7CQkJCVwKKyAgICA7OworCisvKgorICogICAgICByMzM6ICAgIHBvaW50IHRvIGNv
bnRleHRfdCBzdHJ1Y3R1cmUKKyAqICAgICAgYXIubGMgYXJlIGNvcnJ1cHRlZC4KKyAqLworI2Rl
ZmluZSBSRVNUT1JFX1BUS19SRUdTCSAgICAJCVwKKyAgICBhZGQgcjI9Q1RYKFBLUjApLCByMzM7
CQkJXAorICAgIG1vdiByMTY9NzsgICAgCQkJCVwKKyAgICA7OyAgICAgICAgICAgICAgICAgICAg
ICAgICAJCQlcCisgICAgbW92IGFyLmxjPXIxNjsgIAkJCQlcCisgICAgbW92IHIxNz1yMDsJCQkJ
CVwKKyAgICA7OwkJCQkJCVwKKzE6IAkJCQkJCVwKKyAgICBsZDggcjE4PVtyMl0sIDg7CQkJCVwK
KyAgICA7OwkJCQkJCVwKKyAgICBtb3YgcGtyW3IxN109cjE4OwkJCQlcCisgICAgOzsgICAgCQkJ
CQlcCisgICAgc3Jsei5pOwkJCQkJXAorICAgIDs7IAkJCQkJCVwKKyAgICBhZGQgcjE3ID0xLHIx
NzsJCQkJXAorICAgIDs7ICAgICAgICAgICAgICAgICAgICAgCQkJXAorICAgIGJyLmNsb29wLnNw
dGsgMWI7CQkJCVwKKyAgICA7OworCisKKy8qCisgKiB2b2lkIHZtbV90cmFtcG9saW5lKCBjb250
ZXh0X3QgKiBmcm9tLAorICoJCQljb250ZXh0X3QgKiB0bykKKyAqCisgKiAJZnJvbToJcjMyCisg
Kgl0bzoJcjMzCisgKiAgbm90ZTogaW50ZXJydXB0IGRpc2FibGVkIGJlZm9yZSBjYWxsIHRoaXMg
ZnVuY3Rpb24uCisgKi8KK0dMT0JBTF9FTlRSWSh2bW1fdHJhbXBvbGluZSkKKyAgICBtb3YgcjE2
ID0gcHNyCisgICAgYWRkcyByMiA9IENUWChQU1IpLCByMzIKKyAgICA7OworICAgIHN0OCBbcjJd
ID0gcjE2LCA4ICAgICAgIC8vIHBzcgorICAgIG1vdiByMTcgPSBwcgorICAgIDs7CisgICAgc3Q4
IFtyMl0gPSByMTcsIDggICAgICAgLy8gcHIKKyAgICBtb3YgcjE4ID0gYXIudW5hdAorICAgIDs7
CisgICAgc3Q4IFtyMl0gPSByMTgKKyAgICBtb3YgcjE3ID0gYXIucnNjCisgICAgOzsKKyAgICBh
ZGRzIHIyID0gQ1RYKFJTQykscjMyCisgICAgOzsKKyAgICBzdDggW3IyXT0gcjE3CisgICAgbW92
IGFyLnJzYyA9MAorICAgIGZsdXNocnMKKyAgICA7OworICAgIFNBVkVfR0VORVJBTF9SRUdTCisg
ICAgOzsKKyAgICBTQVZFX0tFUk5FTF9SRUdTCisgICAgOzsKKyAgICBTQVZFX0FQUF9SRUdTCisg
ICAgOzsKKyAgICBTQVZFX0JSQU5DSF9SRUdTCisgICAgOzsKKyAgICBTQVZFX0NUTF9SRUdTCisg
ICAgOzsKKyAgICBTQVZFX1JFR0lPTl9SRUdTCisgICAgOzsKKyAgICAvL1NBVkVfREVCVUdfUkVH
UworICAgIDs7CisgICAgcnNtICBwc3IuZGZsCisgICAgOzsKKyAgICBzcmx6LmQKKyAgICA7Owor
ICAgIFNBVkVfRlBVX0xPVworICAgIDs7CisgICAgcnNtICBwc3IuZGZoCisgICAgOzsKKyAgICBz
cmx6LmQKKyAgICA7OworICAgIFNBVkVfRlBVX0hJR0gKKyAgICA7OworICAgIFNBVkVfUFRLX1JF
R1MKKyAgICA7OworICAgIFJFU1RPUkVfUFRLX1JFR1MKKyAgICA7OworICAgIFJFU1RPUkVfRlBV
X0hJR0gKKyAgICA7OworICAgIFJFU1RPUkVfRlBVX0xPVworICAgIDs7CisgICAgLy9SRVNUT1JF
X0RFQlVHX1JFR1MKKyAgICA7OworICAgIFJFU1RPUkVfUkVHSU9OX1JFR1MKKyAgICA7OworICAg
IFJFU1RPUkVfQ1RMX1JFR1MKKyAgICA7OworICAgIFJFU1RPUkVfQlJBTkNIX1JFR1MKKyAgICA7
OworICAgIFJFU1RPUkVfQVBQX1JFR1MKKyAgICA7OworICAgIFJFU1RPUkVfS0VSTkVMX1JFR1MK
KyAgICA7OworICAgIFJFU1RPUkVfR0VORVJBTF9SRUdTCisgICAgOzsKKyAgICBhZGRzIHIyPUNU
WChQU1IpLCByMzMKKyAgICA7OworICAgIGxkOCByMTY9W3IyXSwgOCAgICAgICAvLyBwc3IKKyAg
ICA7OworICAgIG1vdiBwc3IubD1yMTYKKyAgICA7OworICAgIHNybHouZAorICAgIDs7CisgICAg
bGQ4IHIxNj1bcjJdLCA4ICAgICAgIC8vIHByCisgICAgOzsKKyAgICBtb3YgcHIgPXIxNiwtMQor
ICAgIGxkOCByMTY9W3IyXSAgICAgICAvLyB1bmF0CisgICAgOzsKKyAgICBtb3YgYXIudW5hdD1y
MTYKKyAgICA7OworICAgIGFkZHMgcjI9Q1RYKFJTQykscjMzCisgICAgOzsKKyAgICBsZDggcjE2
ID1bcjJdCisgICAgOzsKKyAgICBtb3YgYXIucnNjID0gcjE2CisgICAgOzsKKyAgICBici5yZXQu
c3B0ay5mZXcgYjAKK0VORCh2bW1fdHJhbXBvbGluZSkKKworCi0tIAoxLjUuMgoK

------_=_NextPart_001_01C893E6.04B0681B--
