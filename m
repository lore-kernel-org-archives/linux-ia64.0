From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Thu, 31 Jan 2008 10:29:59 +0000
Subject: [PATCH] [13]Add trampoline for guest/host mode switch.
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDCD31FD0@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C863F4.3B53F3BF"
List-Id: <linux-ia64.vger.kernel.org>
To: Avi Kivity <avi-atKUWr5tajBWk0Htik3J/w@public.gmane.org>, "Luck, Tony" <tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, "Xu, Anthony" <anthony.xu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, "Zhang, Xiantao" <xiantao.zhang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kvm-ia64-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C863F4.3B53F3BF
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From: Zhang Xiantao <xiantao.zhang@intel.com>
Date: Tue, 29 Jan 2008 14:32:14 +0800
Subject: [PATCH] kvm/ia64: Add trampoline for guest/host mode switch.

trampoline.S is for guest/host mode switch.

Signed-off-by: Anthony Xu <anthony.xu@intel.com>
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
1.5.1

------_=_NextPart_001_01C863F4.3B53F3BF
Content-Type: application/octet-stream;
	name="0013-kvm-ia64-Add-trampoline-for-guest-host-mode-switch.patch"
Content-Transfer-Encoding: base64
Content-Description: 0013-kvm-ia64-Add-trampoline-for-guest-host-mode-switch.patch
Content-Disposition: attachment;
	filename="0013-kvm-ia64-Add-trampoline-for-guest-host-mode-switch.patch"

RnJvbSA2Mzg4YmJkMjhkY2UzYmZhNzhiOGU4MTk0NjE1NDIxZGQzYTA5MjIyIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBaaGFuZyBYaWFudGFvIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogVHVlLCAyOSBKYW4gMjAwOCAxNDozMjoxNCArMDgwMApTdWJqZWN0OiBbUEFUQ0hd
IGt2bS9pYTY0OiBBZGQgdHJhbXBvbGluZSBmb3IgZ3Vlc3QvaG9zdCBtb2RlIHN3aXRjaC4KCnRy
YW1wb2xpbmUuUyBpcyBmb3IgZ3Vlc3QvaG9zdCBtb2RlIHN3aXRjaC4KClNpZ25lZC1vZmYtYnk6
IEFudGhvbnkgWHUgPGFudGhvbnkueHVAaW50ZWwuY29tPgpTaWduZWQtb2ZmLWJ5OiBYaWFudGFv
IFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNvbT4KLS0tCiBhcmNoL2lhNjQva3ZtL3RyYW1w
b2xpbmUuUyB8IDEwNDAgKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysr
KysKIDEgZmlsZXMgY2hhbmdlZCwgMTA0MCBpbnNlcnRpb25zKCspLCAwIGRlbGV0aW9ucygtKQog
Y3JlYXRlIG1vZGUgMTAwNjQ0IGFyY2gvaWE2NC9rdm0vdHJhbXBvbGluZS5TCgpkaWZmIC0tZ2l0
IGEvYXJjaC9pYTY0L2t2bS90cmFtcG9saW5lLlMgYi9hcmNoL2lhNjQva3ZtL3RyYW1wb2xpbmUu
UwpuZXcgZmlsZSBtb2RlIDEwMDY0NAppbmRleCAwMDAwMDAwLi5kMzIzMmI1Ci0tLSAvZGV2L251
bGwKKysrIGIvYXJjaC9pYTY0L2t2bS90cmFtcG9saW5lLlMKQEAgLTAsMCArMSwxMDQwIEBACisv
KiBTYXZlIGFsbCBwcm9jZXNzb3Igc3RhdGVzCisgKgorICogQ29weXJpZ2h0IChjKSAyMDA3IEZs
ZW1pbmcgRmVuZyA8ZmxlbWluZy5mZW5nQGludGVsLmNvbT4KKyAqIENvcHlyaWdodCAoYykgMjAw
NyBBbnRob255IFh1ICAgPGFudGhvbnkueHVAaW50ZWwuY29tPgorICovCisKKyNpbmNsdWRlIDxh
c20vYXNtbWFjcm8uaD4KKyNpbmNsdWRlICJhc20tb2Zmc2V0cy5oIgorCisKKyNkZWZpbmUgQ1RY
KG5hbWUpICAgIFZNTV9DVFhfIyNuYW1lIyNfT0ZGU0VUCisKKwkvKgorCSAqCXIzMjoJCWNvbnRl
eHRfdCBiYXNlIGFkZHJlc3MKKwkgKi8KKyNkZWZpbmUJU0FWRV9CUkFOQ0hfUkVHUwkJCVwKKwlh
ZGQJcjIgPSBDVFgoQjApLHIzMjsJCVwKKwlhZGQJcjMgPSBDVFgoQjEpLHIzMjsJCVwKKwltb3YJ
cjE2ID0gYjA7CQkJXAorCW1vdglyMTcgPSBiMTsJCQlcCisJOzsJCQkJCVwKKwlzdDgJW3IyXT1y
MTYsMTY7CQkJXAorCXN0OAlbcjNdPXIxNywxNjsJCQlcCisJOzsJCQkJCVwKKwltb3YJcjE2ID0g
YjI7CQkJXAorCW1vdglyMTcgPSBiMzsJCQlcCisJOzsJCQkJCVwKKwlzdDgJW3IyXT1yMTYsMTY7
CQkJXAorCXN0OAlbcjNdPXIxNywxNjsJCQlcCisJOzsJCQkJCVwKKwltb3YJcjE2ID0gYjQ7CQkJ
XAorCW1vdglyMTcgPSBiNTsJCQlcCisJOzsJCQkJCVwKKwlzdDgJW3IyXT1yMTY7ICAgCQkJXAor
CXN0OAlbcjNdPXIxNzsgICAJCQlcCisJOzsKKworCS8qCisJICoJcjMzOgkJY29udGV4dF90IGJh
c2UgYWRkcmVzcworCSAqLworI2RlZmluZQlSRVNUT1JFX0JSQU5DSF9SRUdTCQkJXAorCWFkZAly
MiA9IENUWChCMCkscjMzOwkJXAorCWFkZAlyMyA9IENUWChCMSkscjMzOwkJXAorCTs7CQkJCQlc
CisJbGQ4CXIxNj1bcjJdLDE2OwkJCVwKKwlsZDgJcjE3PVtyM10sMTY7CQkJXAorCTs7CQkJCQlc
CisJbW92CWIwID0gcjE2OwkJCVwKKwltb3YJYjEgPSByMTc7CQkJXAorCTs7CQkJCQlcCisJbGQ4
CXIxNj1bcjJdLDE2OwkJCVwKKwlsZDgJcjE3PVtyM10sMTY7CQkJXAorCTs7CQkJCQlcCisJbW92
CWIyID0gcjE2OwkJCVwKKwltb3YJYjMgPSByMTc7CQkJXAorCTs7CQkJCQlcCisJbGQ4CXIxNj1b
cjJdOyAgIAkJCVwKKwlsZDgJcjE3PVtyM107ICAgCQkJXAorCTs7CQkJCQlcCisJbW92CWI0PXIx
NjsJCQkJXAorCW1vdgliNT1yMTc7CQkJCVwKKwk7OworCisKKwkvKgorCSAqCXIzMjogY29udGV4
dF90IGJhc2UgYWRkcmVzcworCSAqCWJzdyA9PSAxCisJICoJU2F2ZSBhbGwgYmFuazEgZ2VuZXJh
bCByZWdpc3RlcnMsIHI0IH4gcjcKKwkgKi8KKyNkZWZpbmUJU0FWRV9HRU5FUkFMX1JFR1MJCQlc
CisJYWRkCXIyPUNUWChSNCkscjMyOwkJCVwKKwlhZGQJcjM9Q1RYKFI1KSxyMzI7CQkJXAorCTs7
CQkJCQlcCisubWVtLm9mZnNldCAwLDA7ICAgICAgICAJCQlcCisJc3Q4LnNwaWxsCVtyMl09cjQs
MTY7CQlcCisubWVtLm9mZnNldCA4LDA7ICAgICAgICAJCQlcCisJc3Q4LnNwaWxsCVtyM109cjUs
MTY7CQlcCisJOzsJCQkJCVwKKy5tZW0ub2Zmc2V0IDAsMDsgICAgICAgIAkJCVwKKwlzdDguc3Bp
bGwJW3IyXT1yNiw0ODsJCVwKKy5tZW0ub2Zmc2V0IDgsMDsgICAgICAgIAkJCVwKKwlzdDguc3Bp
bGwJW3IzXT1yNyw0ODsJCVwKKwk7OyAgICAgICAgICAgICAgICAgICAgICAgICAgCQlcCisubWVt
Lm9mZnNldCAwLDA7ICAgICAgICAJCQlcCisgICAgc3Q4LnNwaWxsICAgIFtyMl09cjEyOwkJCVwK
Ky5tZW0ub2Zmc2V0IDgsMDsJCQkJXAorICAgIHN0OC5zcGlsbCAgICBbcjNdPXIxMzsJCQlcCisg
ICAgOzsKKworCS8qCisJICoJcjMzOiBjb250ZXh0X3QgYmFzZSBhZGRyZXNzCisJICoJYnN3ID09
IDEKKwkgKi8KKyNkZWZpbmUJUkVTVE9SRV9HRU5FUkFMX1JFR1MJCQlcCisJYWRkCXIyPUNUWChS
NCkscjMzOwkJCVwKKwlhZGQJcjM9Q1RYKFI1KSxyMzM7CQkJXAorCTs7CQkJCQlcCisJbGQ4LmZp
bGwJcjQ9W3IyXSwxNjsJCVwKKwlsZDguZmlsbAlyNT1bcjNdLDE2OwkJXAorCTs7CQkJCQlcCisJ
bGQ4LmZpbGwJcjY9W3IyXSw0ODsJCVwKKwlsZDguZmlsbAlyNz1bcjNdLDQ4OwkJXAorCTs7CQkJ
CQlcCisJbGQ4LmZpbGwgICAgcjEyPVtyMl07CQkJXAorCWxkOC5maWxsICAgIHIxMyA9W3IzXTsJ
CQlcCisJOzsKKworCisKKworCS8qCisJICoJcjMyOgkJY29udGV4dF90IGJhc2UgYWRkcmVzcwor
CSAqLworI2RlZmluZQlTQVZFX0tFUk5FTF9SRUdTCQkJXAorCWFkZAlyMiA9IENUWChLUjApLHIz
MjsJCVwKKwlhZGQJcjMgPSBDVFgoS1IxKSxyMzI7CQlcCisJbW92CXIxNiA9IGFyLmswOwkJCVwK
Kwltb3YJcjE3ID0gYXIuazE7CQkJXAorCTs7CQkgICAgICAgIAkJXAorCXN0OAlbcjJdID0gcjE2
LDE2OwkJCVwKKwlzdDgJW3IzXSA9IHIxNywxNjsJCQlcCisJOzsJCSAgICAgICAgCQlcCisJbW92
CXIxNiA9IGFyLmsyOwkJCVwKKwltb3YJcjE3ID0gYXIuazM7CQkJXAorCTs7CQkgICAgICAgIAkJ
XAorCXN0OAlbcjJdID0gcjE2LDE2OwkJCVwKKwlzdDgJW3IzXSA9IHIxNywxNjsJCQlcCisJOzsJ
CQkJCVwKKwltb3YJcjE2ID0gYXIuazQ7CQkJXAorCW1vdglyMTcgPSBhci5rNTsJCQlcCisJOzsJ
CQkJICAgIAlcCisJc3Q4CVtyMl0gPSByMTYsMTY7CQkJXAorCXN0OAlbcjNdID0gcjE3LDE2OwkJ
CVwKKwk7OwkJCQkJXAorCW1vdglyMTYgPSBhci5rNjsJCQlcCisJbW92CXIxNyA9IGFyLms3OwkJ
CVwKKwk7OwkJICAgIAkJCVwKKwlzdDgJW3IyXSA9IHIxNjsgICAgIAkJXAorCXN0OAlbcjNdID0g
cjE3OwkJCVwKKwk7OworCisKKworCS8qCisJICoJcjMzOgkJY29udGV4dF90IGJhc2UgYWRkcmVz
cworCSAqLworI2RlZmluZQlSRVNUT1JFX0tFUk5FTF9SRUdTCQkJXAorCWFkZAlyMiA9IENUWChL
UjApLHIzMzsJCVwKKwlhZGQJcjMgPSBDVFgoS1IxKSxyMzM7CQlcCisJOzsJCSAgICAJCQlcCisJ
bGQ4CXIxNj1bcjJdLDE2OyAgICAgCQlcCisJbGQ4CXIxNz1bcjNdLDE2OwkJCVwKKwk7OwkJCQkJ
XAorCW1vdglhci5rMD1yMTY7ICAJCQlcCisJbW92CWFyLmsxPXIxNzsJICAgIAkJXAorCTs7CQkg
ICAgICAgIAkJXAorCWxkOAlyMTY9W3IyXSwxNjsJCQlcCisJbGQ4CXIxNz1bcjNdLDE2OwkJCVwK
Kwk7OwkJICAgICAgICAJCVwKKwltb3YJYXIuazI9cjE2OyAgIAkJCVwKKwltb3YJYXIuazM9cjE3
OwkgICAgCQlcCisJOzsJCSAgICAgICAgCQlcCisJbGQ4CXIxNj1bcjJdLDE2OwkJCVwKKwlsZDgJ
cjE3PVtyM10sMTY7CQkJXAorCTs7CQkJCQlcCisJbW92CWFyLms0PXIxNjsJCQlcCisJbW92CWFy
Lms1PXIxNzsJICAgIAkJXAorCTs7CQkJCSAgICAJXAorCWxkOAlyMTY9W3IyXSwxNjsJCQlcCisJ
bGQ4CXIxNz1bcjNdLDE2OwkJCVwKKwk7OwkJCQkJXAorCW1vdglhci5rNj1yMTY7ICAJCQlcCisJ
bW92CWFyLms3PXIxNzsJICAgIAkJXAorCTs7CisKKworCisJLyoKKwkgKglyMzI6CQljb250ZXh0
X3QgYmFzZSBhZGRyZXNzCisJICovCisjZGVmaW5lCVNBVkVfQVBQX1JFR1MJCQkJXAorCWFkZCAg
cjIgPSBDVFgoQlNQU1RPUkUpLHIzMjsJCVwKKwltb3YgIHIxNiA9IGFyLmJzcHN0b3JlOwkJCVwK
Kwk7OwkJCQkJXAorCXN0OCAgW3IyXSA9IHIxNixDVFgoUk5BVCktQ1RYKEJTUFNUT1JFKTtcCisJ
bW92ICByMTYgPSBhci5ybmF0OwkJCVwKKwk7OwkJCQkJXAorCXN0OCAgW3IyXSA9IHIxNixDVFgo
RkNSKS1DVFgoUk5BVCk7CVwKKwltb3YgIHIxNiA9IGFyLmZjcjsJCQlcCisJOzsJCQkJCVwKKwlz
dDggIFtyMl0gPSByMTYsQ1RYKEVGTEFHKS1DVFgoRkNSKTsJXAorCW1vdiAgcjE2ID0gYXIuZWZs
YWc7CQkJXAorCTs7CQkJCQlcCisJc3Q4ICBbcjJdID0gcjE2LENUWChDRkxHKS1DVFgoRUZMQUcp
OwlcCisJbW92ICByMTYgPSBhci5jZmxnOwkJCVwKKwk7OwkJCQkJXAorCXN0OCAgW3IyXSA9IHIx
NixDVFgoRlNSKS1DVFgoQ0ZMRyk7CVwKKwltb3YgIHIxNiA9IGFyLmZzcjsJCQlcCisJOzsJCQkJ
CVwKKwlzdDggIFtyMl0gPSByMTYsQ1RYKEZJUiktQ1RYKEZTUik7CVwKKwltb3YgIHIxNiA9IGFy
LmZpcjsJCQlcCisJOzsJCQkJCVwKKwlzdDggIFtyMl0gPSByMTYsQ1RYKEZEUiktQ1RYKEZJUik7
CVwKKwltb3YgIHIxNiA9IGFyLmZkcjsJCQlcCisJOzsJCQkJCVwKKwlzdDggIFtyMl0gPSByMTYs
Q1RYKFVOQVQpLUNUWChGRFIpOwlcCisJbW92ICByMTYgPSBhci51bmF0OwkJCVwKKwk7OwkJCQkJ
XAorCXN0OCAgW3IyXSA9IHIxNixDVFgoRlBTUiktQ1RYKFVOQVQpOwlcCisJbW92ICByMTYgPSBh
ci5mcHNyOwkJCVwKKwk7OwkJCQkJXAorCXN0OCAgW3IyXSA9IHIxNixDVFgoUEZTKS1DVFgoRlBT
Uik7CVwKKwltb3YgIHIxNiA9IGFyLnBmczsJCQlcCisJOzsJCQkJCVwKKwlzdDggIFtyMl0gPSBy
MTYsQ1RYKExDKS1DVFgoUEZTKTsJXAorCW1vdiAgcjE2ID0gYXIubGM7CQkJXAorCTs7CQkJCQlc
CisJc3Q4ICBbcjJdID0gcjE2OwkJCVwKKwk7OworCisJLyoKKwkgKglyMzM6CQljb250ZXh0X3Qg
YmFzZSBhZGRyZXNzCisJICovCisjZGVmaW5lCVJFU1RPUkVfQVBQX1JFR1MJCQlcCisJYWRkICBy
Mj1DVFgoQlNQU1RPUkUpLHIzMzsJCVwKKwk7OwkJCQkJXAorCWxkOCAgcjE2PVtyMl0sQ1RYKFJO
QVQpLUNUWChCU1BTVE9SRSk7CVwKKwk7OwkJCQkJXAorCW1vdiAgYXIuYnNwc3RvcmU9cjE2OwkJ
CVwKKwlsZDggIHIxNj1bcjJdLENUWChGQ1IpLUNUWChSTkFUKTsJXAorCTs7CQkJCQlcCisJbW92
ICBhci5ybmF0PXIxNjsJCQlcCisJbGQ4ICByMTY9W3IyXSxDVFgoRUZMQUcpLUNUWChGQ1IpOwlc
CisJOzsJCQkJCVwKKwltb3YgIGFyLmZjcj1yMTY7CQkJXAorCWxkOCAgcjE2PVtyMl0sQ1RYKENG
TEcpLUNUWChFRkxBRyk7CVwKKwk7OwkJCQkJXAorCW1vdiAgYXIuZWZsYWc9cjE2OwkJCVwKKwls
ZDggIHIxNj1bcjJdLENUWChGU1IpLUNUWChDRkxHKTsJXAorCTs7CQkJCQlcCisJbW92ICBhci5j
ZmxnPXIxNjsJCQlcCisJbGQ4ICByMTY9W3IyXSxDVFgoRklSKS1DVFgoRlNSKTsJXAorCTs7CQkJ
CQlcCisJbW92ICBhci5mc3I9cjE2OwkJCVwKKwlsZDggIHIxNj1bcjJdLENUWChGRFIpLUNUWChG
SVIpOwlcCisJOzsJCQkJCVwKKwltb3YgIGFyLmZpcj1yMTY7CQkJXAorCWxkOCAgcjE2PVtyMl0s
Q1RYKFVOQVQpLUNUWChGRFIpOwlcCisJOzsJCQkJCVwKKwltb3YgIGFyLmZkcj1yMTY7CQkJXAor
CWxkOCAgcjE2PVtyMl0sQ1RYKEZQU1IpLUNUWChVTkFUKTsJXAorCTs7CQkJCQlcCisJbW92ICBh
ci51bmF0PXIxNjsJCQlcCisJbGQ4ICByMTY9W3IyXSxDVFgoUEZTKS1DVFgoRlBTUik7CVwKKwk7
OwkJCQkJXAorCW1vdiAgYXIuZnBzcj1yMTY7CQkJXAorCWxkOCAgcjE2PVtyMl0sQ1RYKExDKS1D
VFgoUEZTKTsJCVwKKwk7OwkJCQkJXAorCW1vdiAgYXIucGZzPXIxNjsJCQlcCisJbGQ4ICByMTY9
W3IyXTsJCQkJXAorCTs7CQkJCQlcCisJbW92ICBhci5sYz1yMTY7CQkJCVwKKwk7OworCisJLyoK
KwkgKglyMzI6CQljb250ZXh0X3QgYmFzZSBhZGRyZXNzCisJICovCisjZGVmaW5lCVNBVkVfQ1RM
X1JFR1MJCQkJXAorCWFkZAlyMiA9IENUWChEQ1IpLHIzMjsJCVwKKwltb3YJcjE2ID0gY3IuZGNy
OwkJCVwKKwk7OwkJCQkJXAorCXN0OAlbcjJdID0gcjE2LENUWChJVkEpLUNUWChEQ1IpOwlcCisJ
OzsgICAgICAgICAgICAgICAgICAgICAgICAgIAkJXAorCW1vdglyMTYgPSBjci5pdmE7CQkJXAor
CTs7CQkJCQlcCisJc3Q4CVtyMl0gPSByMTYsQ1RYKFBUQSktQ1RYKElWQSk7CVwKKwk7OwkJCQkJ
XAorCW1vdiByMTYgPSBjci5wdGE7CQkJXAorCTs7CQkJCQlcCisJc3Q4IFtyMl0gPSByMTYgOwkJ
CVwKKwk7OworCisJLyoKKwkgKglyMzM6CQljb250ZXh0X3QgYmFzZSBhZGRyZXNzCisJICovCisj
ZGVmaW5lCVJFU1RPUkVfQ1RMX1JFR1MJCQkJXAorCWFkZAlyMiA9IENUWChEQ1IpLHIzMzsJICAg
ICAgICAJXAorCTs7CQkJCQkJXAorCWxkOAlyMTYgPSBbcjJdLENUWChJVkEpLUNUWChEQ1IpOwkJ
XAorCTs7ICAgICAgICAgICAgICAgICAgICAgIAkJCVwKKwltb3YJY3IuZGNyID0gcjE2OwkJCQlc
CisJZHZfc2VyaWFsaXplX2RhdGE7CQkJCVwKKwk7OwkJCQkJCVwKKwlsZDgJcjE2ID0gW3IyXSxD
VFgoUFRBKS1DVFgoSVZBKTsJCVwKKwk7OwkJCQkJCVwKKwltb3YJY3IuaXZhID0gcjE2OwkJCQlc
CisJZHZfc2VyaWFsaXplX2RhdGE7CQkJCVwKKwk7OwkJCQkJCVwKKwlsZDggcjE2ID0gW3IyXTsJ
CQkJCVwKKwk7OwkJCQkJCVwKKwltb3YgY3IucHRhID0gcjE2OwkJCQlcCisJZHZfc2VyaWFsaXpl
X2RhdGE7CQkJCVwKKwk7OworCisKKwkvKgorCSAqCXIzMjoJCWNvbnRleHRfdCBiYXNlIGFkZHJl
c3MKKwkgKi8KKyNkZWZpbmUJU0FWRV9SRUdJT05fUkVHUwkJCVwKKwlhZGQJcjI9Q1RYKFJSMCks
cjMyOwkJXAorCW1vdglyMTY9cnJbcjBdOwkJCVwKKwlkZXAueglyMTg9MSw2MSwzOwkJCVwKKwk7
OwkJCQkJXAorCXN0OAlbcjJdPXIxNiw4OwkJCVwKKwltb3YJcjE3PXJyW3IxOF07CQkJXAorCWRl
cC56CXIxOD0yLDYxLDM7CQkJXAorCTs7CQkJCQlcCisJc3Q4CVtyMl09cjE3LDg7CQkJXAorCW1v
dglyMTY9cnJbcjE4XTsJCQlcCisJZGVwLnoJcjE4PTMsNjEsMzsJCQlcCisJOzsJCQkJCVwKKwlz
dDgJW3IyXT1yMTYsODsJCQlcCisJbW92CXIxNz1ycltyMThdOwkJCVwKKwlkZXAueglyMTg9NCw2
MSwzOwkJCVwKKwk7OwkJCQkJXAorCXN0OAlbcjJdPXIxNyw4OwkJCVwKKwltb3YJcjE2PXJyW3Ix
OF07CQkJXAorCWRlcC56CXIxOD01LDYxLDM7CQkJXAorCTs7CQkJCQlcCisJc3Q4CVtyMl09cjE2
LDg7CQkJXAorCW1vdglyMTc9cnJbcjE4XTsJCQlcCisJZGVwLnoJcjE4PTcsNjEsMzsJCQlcCisJ
OzsJCQkJCVwKKwlzdDgJW3IyXT1yMTcsMTY7CQkJXAorCW1vdglyMTY9cnJbcjE4XTsJCQlcCisJ
OzsJCQkJCVwKKwlzdDgJW3IyXT1yMTYsODsJCQlcCisJOzsKKworCS8qCisJICoJcjMzOmNvbnRl
eHRfdCBiYXNlIGFkZHJlc3MKKwkgKi8KKyNkZWZpbmUJUkVTVE9SRV9SRUdJT05fUkVHUwlcCisJ
YWRkCXIyPUNUWChSUjApLHIzMztcCisJbW92IHIxOD1yMDsJCVwKKwk7OwkJCVwKKwlsZDgJcjIw
PVtyMl0sODsJXAorCTs7CS8qIHJyMCAqLwlcCisJbGQ4CXIyMT1bcjJdLDg7CVwKKwk7OwkvKiBy
cjEgKi8JXAorCWxkOAlyMjI9W3IyXSw4OwlcCisJOzsJLyogcnIyICovCVwKKwlsZDgJcjIzPVty
Ml0sODsJXAorCTs7CS8qIHJyMyAqLwlcCisJbGQ4CXIyND1bcjJdLDg7CVwKKwk7OwkvKiBycjQg
Ki8JXAorCWxkOAlyMjU9W3IyXSwxNjsJXAorCTs7CS8qIHJyNSAqLwlcCisJbGQ4CXIyNz1bcjJd
OwlcCisJOzsJLyogcnI3ICovCVwKKwltb3YgcnJbcjE4XT1yMjA7CVwKKwlkZXAueglyMTg9MSw2
MSwzOwlcCisJOzsgIC8qIHJyMSAqLwkJXAorCW1vdiBycltyMThdPXIyMTsJXAorCWRlcC56CXIx
OD0yLDYxLDM7CVwKKwk7OyAgLyogcnIyICovCQlcCisJbW92IHJyW3IxOF09cjIyOwlcCisJZGVw
LnoJcjE4PTMsNjEsMzsJXAorCTs7ICAvKiBycjMgKi8JCVwKKwltb3YgcnJbcjE4XT1yMjM7CVwK
KwlkZXAueglyMTg9NCw2MSwzOwlcCisJOzsgIC8qIHJyNCAqLwkJXAorCW1vdiBycltyMThdPXIy
NDsJXAorCWRlcC56CXIxOD01LDYxLDM7CVwKKwk7OyAgLyogcnI1ICovCQlcCisJbW92IHJyW3Ix
OF09cjI1OwlcCisJZGVwLnoJcjE4PTcsNjEsMzsJXAorCTs7ICAvKiBycjcgKi8JCVwKKwltb3Yg
cnJbcjE4XT1yMjc7CVwKKwk7OwkJCVwKKwlzcmx6Lmk7CQkJXAorCTs7CisKKworCisJLyoKKwkg
KglyMzI6CWNvbnRleHRfdCBiYXNlIGFkZHJlc3MKKwkgKglyMzZ+cjM5OnNjcmF0Y2ggcmVnaXN0
ZXJzCisJICovCisjZGVmaW5lCVNBVkVfREVCVUdfUkVHUwkJCQlcCisJYWRkCXIyPUNUWChJQlIw
KSxyMzI7CQlcCisJYWRkCXIzPUNUWChEQlIwKSxyMzI7CQlcCisJbW92CXIxNj1pYnJbcjBdOwkJ
CVwKKwltb3YJcjE3PWRicltyMF07CQkJXAorCTs7CQkJCQlcCisJc3Q4CVtyMl09cjE2LDg7IAkJ
CVwKKwlzdDgJW3IzXT1yMTcsODsJICAgIAkJXAorCWFkZAlyMTg9MSxyMDsJCSAgICAJXAorCTs7
CQkJCQlcCisJbW92CXIxNj1pYnJbcjE4XTsJCQlcCisJbW92CXIxNz1kYnJbcjE4XTsJCQlcCisJ
OzsJCQkJCVwKKwlzdDgJW3IyXT1yMTYsODsJCSAgICAJXAorCXN0OAlbcjNdPXIxNyw4OwkJCVwK
KwlhZGQJcjE4PTIscjA7CQkJXAorCTs7CQkJCQlcCisJbW92CXIxNj1pYnJbcjE4XTsJCQlcCisJ
bW92CXIxNz1kYnJbcjE4XTsJCQlcCisJOzsJCQkJCVwKKwlzdDgJW3IyXT1yMTYsODsJCSAgICAJ
XAorCXN0OAlbcjNdPXIxNyw4OwkJCVwKKwlhZGQJcjE4PTIscjA7CQkJXAorCTs7CQkJCQlcCisJ
bW92CXIxNj1pYnJbcjE4XTsJCQlcCisJbW92CXIxNz1kYnJbcjE4XTsJCQlcCisJOzsJCQkJCVwK
KwlzdDgJW3IyXT1yMTYsODsJCSAgICAJXAorCXN0OAlbcjNdPXIxNyw4OwkJCVwKKwlhZGQJcjE4
PTMscjA7CQkJXAorCTs7CQkJCQlcCisJbW92CXIxNj1pYnJbcjE4XTsJCQlcCisJbW92CXIxNz1k
YnJbcjE4XTsJCQlcCisJOzsJCQkJCVwKKwlzdDgJW3IyXT1yMTYsODsJCSAgICAJXAorCXN0OAlb
cjNdPXIxNyw4OwkJCVwKKwlhZGQJcjE4PTQscjA7CQkJXAorCTs7CQkJCQlcCisJbW92CXIxNj1p
YnJbcjE4XTsJCQlcCisJbW92CXIxNz1kYnJbcjE4XTsJCQlcCisJOzsJCQkJCVwKKwlzdDgJW3Iy
XT1yMTYsODsJCSAgICAJXAorCXN0OAlbcjNdPXIxNyw4OwkJCVwKKwlhZGQJcjE4PTUscjA7CQkJ
XAorCTs7CQkJCQlcCisJbW92CXIxNj1pYnJbcjE4XTsJCQlcCisJbW92CXIxNz1kYnJbcjE4XTsJ
CQlcCisJOzsJCQkJCVwKKwlzdDgJW3IyXT1yMTYsODsJCSAgICAJXAorCXN0OAlbcjNdPXIxNyw4
OwkJCVwKKwlhZGQJcjE4PTYscjA7CQkJXAorCTs7CQkJCQlcCisJbW92CXIxNj1pYnJbcjE4XTsJ
CQlcCisJbW92CXIxNz1kYnJbcjE4XTsJCQlcCisJOzsJCQkJCVwKKwlzdDgJW3IyXT1yMTYsODsJ
CSAgICAJXAorCXN0OAlbcjNdPXIxNyw4OwkJCVwKKwlhZGQJcjE4PTcscjA7CQkJXAorCTs7CQkJ
CQlcCisJbW92CXIxNj1pYnJbcjE4XTsJCQlcCisJbW92CXIxNz1kYnJbcjE4XTsJCQlcCisJOzsJ
CQkJCVwKKwlzdDgJW3IyXT1yMTYsODsJCSAgICAJXAorCXN0OAlbcjNdPXIxNyw4OwkJCVwKKwk7
OworCisKKy8qCisgKiAgICAgIHIzMzogICAgcG9pbnQgdG8gY29udGV4dF90IHN0cnVjdHVyZQor
ICogICAgICBhci5sYyBhcmUgY29ycnVwdGVkLgorICovCisjZGVmaW5lIFJFU1RPUkVfREVCVUdf
UkVHUwkJCVwKKwlhZGQJcjI9Q1RYKElCUjApLHIzMzsJCVwKKwlhZGQJcjM9Q1RYKERCUjApLHIz
MzsJCVwKKwltb3YgcjE2PTc7ICAgIAkJCQlcCisJbW92IHIxNz1yMDsJCQkJXAorCTs7ICAgICAg
ICAgICAgICAgICAgICAJCQlcCisJbW92IGFyLmxjID0gcjE2OwkJCVwKKwk7OyAJCQkJCVwKKzE6
CQkJCQkJXAorCWxkOCByMTg9W3IyXSw4OwkJICAgIAkJXAorCWxkOCByMTk9W3IzXSw4OwkJCQlc
CisJOzsJCQkJCVwKKwltb3YgaWJyW3IxN109cjE4OwkJCVwKKwltb3YgZGJyW3IxN109cjE5OwkJ
CVwKKwk7OyAgIAkJCQkJXAorCXNybHouaTsJCQkJCVwKKwk7OyAJCQkJCVwKKwlhZGQgcjE3PTEs
cjE3OwkJCQlcCisJYnIuY2xvb3Auc3B0ayAxYjsJCQlcCisJOzsKKworCisJLyoKKwkgKglyMzI6
CQljb250ZXh0X3QgYmFzZSBhZGRyZXNzCisJICovCisjZGVmaW5lCVNBVkVfRlBVX0xPVwkJCQlc
CisJYWRkCXIyPUNUWChGMikscjMyOwkJCVwKKwlhZGQJcjM9Q1RYKEYzKSxyMzI7CQkJXAorCTs7
CQkJCQlcCisJc3RmLnNwaWxsLm50YQlbcjJdPWYyLDMyOwkJXAorCXN0Zi5zcGlsbC5udGEJW3Iz
XT1mMywzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mNCwzMjsJCVwKKwlz
dGYuc3BpbGwubnRhCVtyM109ZjUsMzI7CQlcCisJOzsJCQkJCVwKKwlzdGYuc3BpbGwubnRhCVty
Ml09ZjYsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWY3LDMyOwkJXAorCTs7CQkJCQlcCisJ
c3RmLnNwaWxsLm50YQlbcjJdPWY4LDMyOwkJXAorCXN0Zi5zcGlsbC5udGEJW3IzXT1mOSwzMjsJ
CVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mMTAsMzI7CQlcCisJc3RmLnNwaWxs
Lm50YQlbcjNdPWYxMSwzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mMTIs
MzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWYxMywzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5z
cGlsbC5udGEJW3IyXT1mMTQsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWYxNSwzMjsJCVwK
Kwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mMTYsMzI7CQlcCisJc3RmLnNwaWxsLm50
YQlbcjNdPWYxNywzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mMTgsMzI7
CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWYxOSwzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGls
bC5udGEJW3IyXT1mMjAsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWYyMSwzMjsJCVwKKwk7
OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mMjIsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlb
cjNdPWYyMywzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mMjQsMzI7CQlc
CisJc3RmLnNwaWxsLm50YQlbcjNdPWYyNSwzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5u
dGEJW3IyXT1mMjYsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWYyNywzMjsJCVwKKwk7OwkJ
CQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mMjgsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNd
PWYyOSwzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mMzA7CQlcCisJc3Rm
LnNwaWxsLm50YQlbcjNdPWYzMTsJCVwKKwk7OworCisJLyoKKwkgKglyMzI6CQljb250ZXh0X3Qg
YmFzZSBhZGRyZXNzCisJICovCisjZGVmaW5lCVNBVkVfRlBVX0hJR0gJCQkJXAorCWFkZAlyMj1D
VFgoRjMyKSxyMzI7CQlcCisJYWRkCXIzPUNUWChGMzMpLHIzMjsJCVwKKwk7OwkJCQkJXAorCXN0
Zi5zcGlsbC5udGEJW3IyXT1mMzIsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWYzMywzMjsJ
CVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mMzQsMzI7CQlcCisJc3RmLnNwaWxs
Lm50YQlbcjNdPWYzNSwzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mMzYs
MzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWYzNywzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5z
cGlsbC5udGEJW3IyXT1mMzgsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWYzOSwzMjsJCVwK
Kwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mNDAsMzI7CQlcCisJc3RmLnNwaWxsLm50
YQlbcjNdPWY0MSwzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mNDIsMzI7
CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWY0MywzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGls
bC5udGEJW3IyXT1mNDQsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWY0NSwzMjsJCVwKKwk7
OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mNDYsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlb
cjNdPWY0NywzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mNDgsMzI7CQlc
CisJc3RmLnNwaWxsLm50YQlbcjNdPWY0OSwzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5u
dGEJW3IyXT1mNTAsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWY1MSwzMjsJCVwKKwk7OwkJ
CQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mNTIsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNd
PWY1MywzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mNTQsMzI7CQlcCisJ
c3RmLnNwaWxsLm50YQlbcjNdPWY1NSwzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJ
W3IyXT1mNTYsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWY1NywzMjsJCVwKKwk7OwkJCQkJ
XAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mNTgsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWY1
OSwzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mNjAsMzI7CQlcCisJc3Rm
LnNwaWxsLm50YQlbcjNdPWY2MSwzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3Iy
XT1mNjIsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWY2MywzMjsJCVwKKwk7OwkJCQkJXAor
CXN0Zi5zcGlsbC5udGEJW3IyXT1mNjQsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWY2NSwz
MjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mNjYsMzI7CQlcCisJc3RmLnNw
aWxsLm50YQlbcjNdPWY2NywzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1m
NjgsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWY2OSwzMjsJCVwKKwk7OwkJCQkJXAorCXN0
Zi5zcGlsbC5udGEJW3IyXT1mNzAsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWY3MSwzMjsJ
CVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mNzIsMzI7CQlcCisJc3RmLnNwaWxs
Lm50YQlbcjNdPWY3MywzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mNzQs
MzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWY3NSwzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5z
cGlsbC5udGEJW3IyXT1mNzYsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWY3NywzMjsJCVwK
Kwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mNzgsMzI7CQlcCisJc3RmLnNwaWxsLm50
YQlbcjNdPWY3OSwzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mODAsMzI7
CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWY4MSwzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGls
bC5udGEJW3IyXT1mODIsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWY4MywzMjsJCVwKKwk7
OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mODQsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlb
cjNdPWY4NSwzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mODYsMzI7CQlc
CisJc3RmLnNwaWxsLm50YQlbcjNdPWY4NywzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5u
dGEJW3IyXT1mODgsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWY4OSwzMjsJCVwKKwk7OwkJ
CQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mOTAsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNd
PWY5MSwzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mOTIsMzI7CQlcCisJ
c3RmLnNwaWxsLm50YQlbcjNdPWY5MywzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJ
W3IyXT1mOTQsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWY5NSwzMjsJCVwKKwk7OwkJCQkJ
XAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mOTYsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWY5
NywzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3IyXT1mOTgsMzI7CQlcCisJc3Rm
LnNwaWxsLm50YQlbcjNdPWY5OSwzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJW3Iy
XT1mMTAwLDMyOwkJXAorCXN0Zi5zcGlsbC5udGEJW3IzXT1mMTAxLDMyOwkJXAorCTs7CQkJCQlc
CisJc3RmLnNwaWxsLm50YQlbcjJdPWYxMDIsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNdPWYx
MDMsMzI7CQlcCisJOzsJCQkJCVwKKwlzdGYuc3BpbGwubnRhCVtyMl09ZjEwNCwzMjsJCVwKKwlz
dGYuc3BpbGwubnRhCVtyM109ZjEwNSwzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5udGEJ
W3IyXT1mMTA2LDMyOwkJXAorCXN0Zi5zcGlsbC5udGEJW3IzXT1mMTA3LDMyOwkJXAorCTs7CQkJ
CQlcCisJc3RmLnNwaWxsLm50YQlbcjJdPWYxMDgsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlbcjNd
PWYxMDksMzI7CQlcCisJOzsJCQkJCVwKKwlzdGYuc3BpbGwubnRhCVtyMl09ZjExMCwzMjsJCVwK
KwlzdGYuc3BpbGwubnRhCVtyM109ZjExMSwzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGlsbC5u
dGEJW3IyXT1mMTEyLDMyOwkJXAorCXN0Zi5zcGlsbC5udGEJW3IzXT1mMTEzLDMyOwkJXAorCTs7
CQkJCQlcCisJc3RmLnNwaWxsLm50YQlbcjJdPWYxMTQsMzI7CQlcCisJc3RmLnNwaWxsLm50YQlb
cjNdPWYxMTUsMzI7CQlcCisJOzsJCQkJCVwKKwlzdGYuc3BpbGwubnRhCVtyMl09ZjExNiwzMjsJ
CVwKKwlzdGYuc3BpbGwubnRhCVtyM109ZjExNywzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5zcGls
bC5udGEJW3IyXT1mMTE4LDMyOwkJXAorCXN0Zi5zcGlsbC5udGEJW3IzXT1mMTE5LDMyOwkJXAor
CTs7CQkJCQlcCisJc3RmLnNwaWxsLm50YQlbcjJdPWYxMjAsMzI7CQlcCisJc3RmLnNwaWxsLm50
YQlbcjNdPWYxMjEsMzI7CQlcCisJOzsJCQkJCVwKKwlzdGYuc3BpbGwubnRhCVtyMl09ZjEyMiwz
MjsJCVwKKwlzdGYuc3BpbGwubnRhCVtyM109ZjEyMywzMjsJCVwKKwk7OwkJCQkJXAorCXN0Zi5z
cGlsbC5udGEJW3IyXT1mMTI0LDMyOwkJXAorCXN0Zi5zcGlsbC5udGEJW3IzXT1mMTI1LDMyOwkJ
XAorCTs7CQkJCQlcCisJc3RmLnNwaWxsLm50YQlbcjJdPWYxMjY7CQlcCisJc3RmLnNwaWxsLm50
YQlbcjNdPWYxMjc7CQlcCisJOzsKKworICAgICAvKgorICAgICAgKiAgICAgIHIzMzogICAgcG9p
bnQgdG8gY29udGV4dF90IHN0cnVjdHVyZQorICAgICAgKi8KKyNkZWZpbmUJUkVTVE9SRV9GUFVf
TE9XCQkJCVwKKyAgICBhZGQgICAgIHIyID0gQ1RYKEYyKSwgcjMzOwkJCVwKKyAgICBhZGQgICAg
IHIzID0gQ1RYKEYzKSwgcjMzOwkJCVwKKyAgICA7OwkJCQkJCVwKKyAgICBsZGYuZmlsbC5udGEg
ZjIgPSBbcjJdLCAzMjsJCQlcCisgICAgbGRmLmZpbGwubnRhIGYzID0gW3IzXSwgMzI7CQkJXAor
ICAgIDs7CQkJCQkJXAorICAgIGxkZi5maWxsLm50YSBmNCA9IFtyMl0sIDMyOwkJCVwKKyAgICBs
ZGYuZmlsbC5udGEgZjUgPSBbcjNdLCAzMjsJCQlcCisgICAgOzsJCQkJCQlcCisgICAgbGRmLmZp
bGwubnRhIGY2ID0gW3IyXSwgMzI7CQkJXAorICAgIGxkZi5maWxsLm50YSBmNyA9IFtyM10sIDMy
OwkJCVwKKyAgICA7OwkJCQkJCVwKKyAgICBsZGYuZmlsbC5udGEgZjggPSBbcjJdLCAzMjsJCQlc
CisgICAgbGRmLmZpbGwubnRhIGY5ID0gW3IzXSwgMzI7CQkJXAorICAgIDs7CQkJCQkJXAorICAg
IGxkZi5maWxsLm50YSBmMTAgPSBbcjJdLCAzMjsJCVwKKyAgICBsZGYuZmlsbC5udGEgZjExID0g
W3IzXSwgMzI7CQlcCisgICAgOzsJCQkJCQlcCisgICAgbGRmLmZpbGwubnRhIGYxMiA9IFtyMl0s
IDMyOwkJXAorICAgIGxkZi5maWxsLm50YSBmMTMgPSBbcjNdLCAzMjsJCVwKKyAgICA7OwkJCQkJ
CVwKKyAgICBsZGYuZmlsbC5udGEgZjE0ID0gW3IyXSwgMzI7CQlcCisgICAgbGRmLmZpbGwubnRh
IGYxNSA9IFtyM10sIDMyOwkJXAorICAgIDs7CQkJCQkJXAorICAgIGxkZi5maWxsLm50YSBmMTYg
PSBbcjJdLCAzMjsJCVwKKyAgICBsZGYuZmlsbC5udGEgZjE3ID0gW3IzXSwgMzI7CQlcCisgICAg
OzsJCQkJCQlcCisgICAgbGRmLmZpbGwubnRhIGYxOCA9IFtyMl0sIDMyOwkJXAorICAgIGxkZi5m
aWxsLm50YSBmMTkgPSBbcjNdLCAzMjsJCVwKKyAgICA7OwkJCQkJCVwKKyAgICBsZGYuZmlsbC5u
dGEgZjIwID0gW3IyXSwgMzI7CQlcCisgICAgbGRmLmZpbGwubnRhIGYyMSA9IFtyM10sIDMyOwkJ
XAorICAgIDs7CQkJCQkJXAorICAgIGxkZi5maWxsLm50YSBmMjIgPSBbcjJdLCAzMjsJCVwKKyAg
ICBsZGYuZmlsbC5udGEgZjIzID0gW3IzXSwgMzI7CQlcCisgICAgOzsJCQkJCQlcCisgICAgbGRm
LmZpbGwubnRhIGYyNCA9IFtyMl0sIDMyOwkJXAorICAgIGxkZi5maWxsLm50YSBmMjUgPSBbcjNd
LCAzMjsJCVwKKyAgICA7OwkJCQkJCVwKKyAgICBsZGYuZmlsbC5udGEgZjI2ID0gW3IyXSwgMzI7
CQlcCisgICAgbGRmLmZpbGwubnRhIGYyNyA9IFtyM10sIDMyOwkJXAorCTs7CQkJCQlcCisgICAg
bGRmLmZpbGwubnRhIGYyOCA9IFtyMl0sIDMyOwkJXAorICAgIGxkZi5maWxsLm50YSBmMjkgPSBb
cjNdLCAzMjsJCVwKKyAgICA7OwkJCQkJCVwKKyAgICBsZGYuZmlsbC5udGEgZjMwID0gW3IyXSwg
MzI7CQlcCisgICAgbGRmLmZpbGwubnRhIGYzMSA9IFtyM10sIDMyOwkJXAorICAgIDs7CisKKwor
CisgICAgLyoKKyAgICAgKiAgICAgIHIzMzogICAgcG9pbnQgdG8gY29udGV4dF90IHN0cnVjdHVy
ZQorICAgICAqLworI2RlZmluZQlSRVNUT1JFX0ZQVV9ISUdICQkJXAorICAgIGFkZCAgICAgcjIg
PSBDVFgoRjMyKSwgcjMzOwkJCVwKKyAgICBhZGQgICAgIHIzID0gQ1RYKEYzMyksIHIzMzsJCQlc
CisgICAgOzsJCQkJCQlcCisgICAgbGRmLmZpbGwubnRhIGYzMiA9IFtyMl0sIDMyOwkJXAorICAg
IGxkZi5maWxsLm50YSBmMzMgPSBbcjNdLCAzMjsJCVwKKyAgICA7OwkJCQkJCVwKKyAgICBsZGYu
ZmlsbC5udGEgZjM0ID0gW3IyXSwgMzI7CQlcCisgICAgbGRmLmZpbGwubnRhIGYzNSA9IFtyM10s
IDMyOwkJXAorICAgIDs7CQkJCQkJXAorICAgIGxkZi5maWxsLm50YSBmMzYgPSBbcjJdLCAzMjsJ
CVwKKyAgICBsZGYuZmlsbC5udGEgZjM3ID0gW3IzXSwgMzI7CQlcCisgICAgOzsJCQkJCQlcCisg
ICAgbGRmLmZpbGwubnRhIGYzOCA9IFtyMl0sIDMyOwkJXAorICAgIGxkZi5maWxsLm50YSBmMzkg
PSBbcjNdLCAzMjsJCVwKKyAgICA7OwkJCQkJCVwKKyAgICBsZGYuZmlsbC5udGEgZjQwID0gW3Iy
XSwgMzI7CQlcCisgICAgbGRmLmZpbGwubnRhIGY0MSA9IFtyM10sIDMyOwkJXAorICAgIDs7CQkJ
CQkJXAorICAgIGxkZi5maWxsLm50YSBmNDIgPSBbcjJdLCAzMjsJCVwKKyAgICBsZGYuZmlsbC5u
dGEgZjQzID0gW3IzXSwgMzI7CQlcCisgICAgOzsJCQkJCQlcCisgICAgbGRmLmZpbGwubnRhIGY0
NCA9IFtyMl0sIDMyOwkJXAorICAgIGxkZi5maWxsLm50YSBmNDUgPSBbcjNdLCAzMjsJCVwKKyAg
ICA7OwkJCQkJCVwKKyAgICBsZGYuZmlsbC5udGEgZjQ2ID0gW3IyXSwgMzI7CQlcCisgICAgbGRm
LmZpbGwubnRhIGY0NyA9IFtyM10sIDMyOwkJXAorICAgIDs7CQkJCQkJXAorICAgIGxkZi5maWxs
Lm50YSBmNDggPSBbcjJdLCAzMjsJCVwKKyAgICBsZGYuZmlsbC5udGEgZjQ5ID0gW3IzXSwgMzI7
CQlcCisgICAgOzsJCQkJCQlcCisgICAgbGRmLmZpbGwubnRhIGY1MCA9IFtyMl0sIDMyOwkJXAor
ICAgIGxkZi5maWxsLm50YSBmNTEgPSBbcjNdLCAzMjsJCVwKKyAgICA7OwkJCQkJCVwKKyAgICBs
ZGYuZmlsbC5udGEgZjUyID0gW3IyXSwgMzI7CQlcCisgICAgbGRmLmZpbGwubnRhIGY1MyA9IFty
M10sIDMyOwkJXAorICAgIDs7CQkJCQkJXAorICAgIGxkZi5maWxsLm50YSBmNTQgPSBbcjJdLCAz
MjsJCVwKKyAgICBsZGYuZmlsbC5udGEgZjU1ID0gW3IzXSwgMzI7CQlcCisgICAgOzsJCQkJCQlc
CisgICAgbGRmLmZpbGwubnRhIGY1NiA9IFtyMl0sIDMyOwkJXAorICAgIGxkZi5maWxsLm50YSBm
NTcgPSBbcjNdLCAzMjsgICAJCVwKKyAgICA7OwkJCQkJCVwKKyAgICBsZGYuZmlsbC5udGEgZjU4
ID0gW3IyXSwgMzI7CQlcCisgICAgbGRmLmZpbGwubnRhIGY1OSA9IFtyM10sIDMyOwkJXAorICAg
IDs7CQkJCQkJXAorICAgIGxkZi5maWxsLm50YSBmNjAgPSBbcjJdLCAzMjsJCVwKKyAgICBsZGYu
ZmlsbC5udGEgZjYxID0gW3IzXSwgMzI7CQlcCisgICAgOzsJCQkJCQlcCisgICAgbGRmLmZpbGwu
bnRhIGY2MiA9IFtyMl0sIDMyOwkJXAorICAgIGxkZi5maWxsLm50YSBmNjMgPSBbcjNdLCAzMjsJ
CVwKKyAgICA7OwkJCQkJCVwKKyAgICBsZGYuZmlsbC5udGEgZjY0ID0gW3IyXSwgMzI7CQlcCisg
ICAgbGRmLmZpbGwubnRhIGY2NSA9IFtyM10sIDMyOwkJXAorICAgIDs7CQkJCQkJXAorICAgIGxk
Zi5maWxsLm50YSBmNjYgPSBbcjJdLCAzMjsJCVwKKyAgICBsZGYuZmlsbC5udGEgZjY3ID0gW3Iz
XSwgMzI7CQlcCisgICAgOzsJCQkJCQlcCisgICAgbGRmLmZpbGwubnRhIGY2OCA9IFtyMl0sIDMy
OwkJXAorICAgIGxkZi5maWxsLm50YSBmNjkgPSBbcjNdLCAzMjsJCVwKKyAgICA7OwkJCQkJCVwK
KyAgICBsZGYuZmlsbC5udGEgZjcwID0gW3IyXSwgMzI7CQlcCisgICAgbGRmLmZpbGwubnRhIGY3
MSA9IFtyM10sIDMyOwkJXAorICAgIDs7CQkJCQkJXAorICAgIGxkZi5maWxsLm50YSBmNzIgPSBb
cjJdLCAzMjsJCVwKKyAgICBsZGYuZmlsbC5udGEgZjczID0gW3IzXSwgMzI7CQlcCisgICAgOzsJ
CQkJCQlcCisgICAgbGRmLmZpbGwubnRhIGY3NCA9IFtyMl0sIDMyOwkJXAorICAgIGxkZi5maWxs
Lm50YSBmNzUgPSBbcjNdLCAzMjsJCVwKKyAgICA7OwkJCQkJCVwKKyAgICBsZGYuZmlsbC5udGEg
Zjc2ID0gW3IyXSwgMzI7CQlcCisgICAgbGRmLmZpbGwubnRhIGY3NyA9IFtyM10sIDMyOwkJXAor
ICAgIDs7CQkJCQkJXAorICAgIGxkZi5maWxsLm50YSBmNzggPSBbcjJdLCAzMjsJCVwKKyAgICBs
ZGYuZmlsbC5udGEgZjc5ID0gW3IzXSwgMzI7CQlcCisgICAgOzsJCQkJCQlcCisgICAgbGRmLmZp
bGwubnRhIGY4MCA9IFtyMl0sIDMyOwkJXAorICAgIGxkZi5maWxsLm50YSBmODEgPSBbcjNdLCAz
MjsJCVwKKyAgICA7OwkJCQkJCVwKKyAgICBsZGYuZmlsbC5udGEgZjgyID0gW3IyXSwgMzI7CQlc
CisgICAgbGRmLmZpbGwubnRhIGY4MyA9IFtyM10sIDMyOwkJXAorICAgIDs7CQkJCQkJXAorICAg
IGxkZi5maWxsLm50YSBmODQgPSBbcjJdLCAzMjsJCVwKKyAgICBsZGYuZmlsbC5udGEgZjg1ID0g
W3IzXSwgMzI7CQlcCisgICAgOzsJCQkJCQlcCisgICAgbGRmLmZpbGwubnRhIGY4NiA9IFtyMl0s
IDMyOwkJXAorICAgIGxkZi5maWxsLm50YSBmODcgPSBbcjNdLCAzMjsJCVwKKyAgICA7OwkJCQkJ
CVwKKyAgICBsZGYuZmlsbC5udGEgZjg4ID0gW3IyXSwgMzI7CQlcCisgICAgbGRmLmZpbGwubnRh
IGY4OSA9IFtyM10sIDMyOwkJXAorICAgIDs7CQkJCQkJXAorICAgIGxkZi5maWxsLm50YSBmOTAg
PSBbcjJdLCAzMjsJCVwKKyAgICBsZGYuZmlsbC5udGEgZjkxID0gW3IzXSwgMzI7CQlcCisgICAg
OzsJCQkJCQlcCisgICAgbGRmLmZpbGwubnRhIGY5MiA9IFtyMl0sIDMyOwkJXAorICAgIGxkZi5m
aWxsLm50YSBmOTMgPSBbcjNdLCAzMjsJCVwKKyAgICA7OwkJCQkJCVwKKyAgICBsZGYuZmlsbC5u
dGEgZjk0ID0gW3IyXSwgMzI7CQlcCisgICAgbGRmLmZpbGwubnRhIGY5NSA9IFtyM10sIDMyOwkJ
XAorICAgIDs7CQkJCQkJXAorICAgIGxkZi5maWxsLm50YSBmOTYgPSBbcjJdLCAzMjsJCVwKKyAg
ICBsZGYuZmlsbC5udGEgZjk3ID0gW3IzXSwgMzI7CQlcCisgICAgOzsJCQkJCQlcCisgICAgbGRm
LmZpbGwubnRhIGY5OCA9IFtyMl0sIDMyOwkJXAorICAgIGxkZi5maWxsLm50YSBmOTkgPSBbcjNd
LCAzMjsJCVwKKyAgICA7OwkJCQkJCVwKKyAgICBsZGYuZmlsbC5udGEgZjEwMCA9IFtyMl0sIDMy
OwkJXAorICAgIGxkZi5maWxsLm50YSBmMTAxID0gW3IzXSwgMzI7CQlcCisgICAgOzsJCQkJCQlc
CisgICAgbGRmLmZpbGwubnRhIGYxMDIgPSBbcjJdLCAzMjsJCVwKKyAgICBsZGYuZmlsbC5udGEg
ZjEwMyA9IFtyM10sIDMyOwkJXAorICAgIDs7CQkJCQkJXAorICAgIGxkZi5maWxsLm50YSBmMTA0
ID0gW3IyXSwgMzI7CQlcCisgICAgbGRmLmZpbGwubnRhIGYxMDUgPSBbcjNdLCAzMjsJCVwKKyAg
ICA7OwkJCQkJCVwKKyAgICBsZGYuZmlsbC5udGEgZjEwNiA9IFtyMl0sIDMyOwkJXAorICAgIGxk
Zi5maWxsLm50YSBmMTA3ID0gW3IzXSwgMzI7CQlcCisgICAgOzsJCQkJCQlcCisgICAgbGRmLmZp
bGwubnRhIGYxMDggPSBbcjJdLCAzMjsJCVwKKyAgICBsZGYuZmlsbC5udGEgZjEwOSA9IFtyM10s
IDMyOyAgIAkJXAorICAgIDs7CQkJCQkJXAorICAgIGxkZi5maWxsLm50YSBmMTEwID0gW3IyXSwg
MzI7CQlcCisgICAgbGRmLmZpbGwubnRhIGYxMTEgPSBbcjNdLCAzMjsJCVwKKyAgICA7OwkJCQkJ
CVwKKyAgICBsZGYuZmlsbC5udGEgZjExMiA9IFtyMl0sIDMyOwkJXAorICAgIGxkZi5maWxsLm50
YSBmMTEzID0gW3IzXSwgMzI7CQlcCisgICAgOzsJCQkJCQlcCisgICAgbGRmLmZpbGwubnRhIGYx
MTQgPSBbcjJdLCAzMjsJCVwKKyAgICBsZGYuZmlsbC5udGEgZjExNSA9IFtyM10sIDMyOwkJXAor
ICAgIDs7CQkJCQkJXAorICAgIGxkZi5maWxsLm50YSBmMTE2ID0gW3IyXSwgMzI7CQlcCisgICAg
bGRmLmZpbGwubnRhIGYxMTcgPSBbcjNdLCAzMjsJCVwKKyAgICA7OwkJCQkJCVwKKyAgICBsZGYu
ZmlsbC5udGEgZjExOCA9IFtyMl0sIDMyOwkJXAorICAgIGxkZi5maWxsLm50YSBmMTE5ID0gW3Iz
XSwgMzI7CQlcCisgICAgOzsJCQkJCQlcCisgICAgbGRmLmZpbGwubnRhIGYxMjAgPSBbcjJdLCAz
MjsJCVwKKyAgICBsZGYuZmlsbC5udGEgZjEyMSA9IFtyM10sIDMyOwkJXAorICAgIDs7CQkJCQkJ
XAorICAgIGxkZi5maWxsLm50YSBmMTIyID0gW3IyXSwgMzI7CQlcCisgICAgbGRmLmZpbGwubnRh
IGYxMjMgPSBbcjNdLCAzMjsJCVwKKyAgICA7OwkJCQkJCVwKKyAgICBsZGYuZmlsbC5udGEgZjEy
NCA9IFtyMl0sIDMyOwkJXAorICAgIGxkZi5maWxsLm50YSBmMTI1ID0gW3IzXSwgMzI7CQlcCisg
ICAgOzsJCQkJCQlcCisgICAgbGRmLmZpbGwubnRhIGYxMjYgPSBbcjJdLCAzMjsJCVwKKyAgICBs
ZGYuZmlsbC5udGEgZjEyNyA9IFtyM10sIDMyOwkJXAorICAgIDs7CisKKwkvKgorCSAqCXIzMjoJ
CWNvbnRleHRfdCBiYXNlIGFkZHJlc3MKKwkgKi8KKyNkZWZpbmUJU0FWRV9QVEtfUkVHUwkJCQlc
CisgICAgYWRkIHIyPUNUWChQS1IwKSwgcjMyOwkJCVwKKyAgICBtb3YgcjE2PTc7ICAgIAkJCQlc
CisgICAgOzsgICAgICAgICAgICAgICAgICAgICAgICAgCQkJXAorICAgIG1vdiBhci5sYz1yMTY7
ICAJCQkJXAorICAgIG1vdiByMTc9cjA7CQkJCQlcCisgICAgOzsJCQkJCQlcCisxOgkJCQkJCVwK
KyAgICBtb3YgcjE4PXBrcltyMTddOwkJCQlcCisgICAgOzsgICAgICAgICAgICAgICAgICAgICAJ
CQlcCisgICAgc3Jsei5pOwkJCQkJXAorICAgIDs7IAkJCQkJCVwKKyAgICBzdDggW3IyXT1yMTgs
IDg7CQkJCVwKKyAgICA7OyAgICAJCQkJCVwKKyAgICBhZGQgcjE3ID0xLHIxNzsJCQkJXAorICAg
IDs7ICAgICAgICAgICAgICAgICAgICAgCQkJXAorICAgIGJyLmNsb29wLnNwdGsgMWI7CQkJCVwK
KyAgICA7OworCisvKgorICogICAgICByMzM6ICAgIHBvaW50IHRvIGNvbnRleHRfdCBzdHJ1Y3R1
cmUKKyAqICAgICAgYXIubGMgYXJlIGNvcnJ1cHRlZC4KKyAqLworI2RlZmluZSBSRVNUT1JFX1BU
S19SRUdTCSAgICAJCVwKKyAgICBhZGQgcjI9Q1RYKFBLUjApLCByMzM7CQkJXAorICAgIG1vdiBy
MTY9NzsgICAgCQkJCVwKKyAgICA7OyAgICAgICAgICAgICAgICAgICAgICAgICAJCQlcCisgICAg
bW92IGFyLmxjPXIxNjsgIAkJCQlcCisgICAgbW92IHIxNz1yMDsJCQkJCVwKKyAgICA7OwkJCQkJ
CVwKKzE6IAkJCQkJCVwKKyAgICBsZDggcjE4PVtyMl0sIDg7CQkJCVwKKyAgICA7OwkJCQkJCVwK
KyAgICBtb3YgcGtyW3IxN109cjE4OwkJCQlcCisgICAgOzsgICAgCQkJCQlcCisgICAgc3Jsei5p
OwkJCQkJXAorICAgIDs7IAkJCQkJCVwKKyAgICBhZGQgcjE3ID0xLHIxNzsJCQkJXAorICAgIDs7
ICAgICAgICAgICAgICAgICAgICAgCQkJXAorICAgIGJyLmNsb29wLnNwdGsgMWI7CQkJCVwKKyAg
ICA7OworCisKKy8qCisgKiB2b2lkIHZtbV90cmFtcG9saW5lKCBjb250ZXh0X3QgKiBmcm9tLAor
ICoJCQljb250ZXh0X3QgKiB0bykKKyAqCisgKiAJZnJvbToJcjMyCisgKgl0bzoJcjMzCisgKiAg
bm90ZTogaW50ZXJydXB0IGRpc2FibGVkIGJlZm9yZSBjYWxsIHRoaXMgZnVuY3Rpb24uCisgKi8K
K0dMT0JBTF9FTlRSWSh2bW1fdHJhbXBvbGluZSkKKyAgICBtb3YgcjE2ID0gcHNyCisgICAgYWRk
cyByMiA9IENUWChQU1IpLCByMzIKKyAgICA7OworICAgIHN0OCBbcjJdID0gcjE2LCA4ICAgICAg
IC8vIHBzcgorICAgIG1vdiByMTcgPSBwcgorICAgIDs7CisgICAgc3Q4IFtyMl0gPSByMTcsIDgg
ICAgICAgLy8gcHIKKyAgICBtb3YgcjE4ID0gYXIudW5hdAorICAgIDs7CisgICAgc3Q4IFtyMl0g
PSByMTgKKyAgICBtb3YgcjE3ID0gYXIucnNjCisgICAgOzsKKyAgICBhZGRzIHIyID0gQ1RYKFJT
QykscjMyCisgICAgOzsKKyAgICBzdDggW3IyXT0gcjE3CisgICAgbW92IGFyLnJzYyA9MAorICAg
IGZsdXNocnMKKyAgICA7OworICAgIFNBVkVfR0VORVJBTF9SRUdTCisgICAgOzsKKyAgICBTQVZF
X0tFUk5FTF9SRUdTCisgICAgOzsKKyAgICBTQVZFX0FQUF9SRUdTCisgICAgOzsKKyAgICBTQVZF
X0JSQU5DSF9SRUdTCisgICAgOzsKKyAgICBTQVZFX0NUTF9SRUdTCisgICAgOzsKKyAgICBTQVZF
X1JFR0lPTl9SRUdTCisgICAgOzsKKyAgICAvL1NBVkVfREVCVUdfUkVHUworICAgIDs7CisgICAg
cnNtICBwc3IuZGZsCisgICAgOzsKKyAgICBzcmx6LmQKKyAgICA7OworICAgIFNBVkVfRlBVX0xP
VworICAgIDs7CisgICAgcnNtICBwc3IuZGZoCisgICAgOzsKKyAgICBzcmx6LmQKKyAgICA7Owor
ICAgIFNBVkVfRlBVX0hJR0gKKyAgICA7OworICAgIFNBVkVfUFRLX1JFR1MKKyAgICA7OworICAg
IFJFU1RPUkVfUFRLX1JFR1MKKyAgICA7OworICAgIFJFU1RPUkVfRlBVX0hJR0gKKyAgICA7Owor
ICAgIFJFU1RPUkVfRlBVX0xPVworICAgIDs7CisgICAgLy9SRVNUT1JFX0RFQlVHX1JFR1MKKyAg
ICA7OworICAgIFJFU1RPUkVfUkVHSU9OX1JFR1MKKyAgICA7OworICAgIFJFU1RPUkVfQ1RMX1JF
R1MKKyAgICA7OworICAgIFJFU1RPUkVfQlJBTkNIX1JFR1MKKyAgICA7OworICAgIFJFU1RPUkVf
QVBQX1JFR1MKKyAgICA7OworICAgIFJFU1RPUkVfS0VSTkVMX1JFR1MKKyAgICA7OworICAgIFJF
U1RPUkVfR0VORVJBTF9SRUdTCisgICAgOzsKKyAgICBhZGRzIHIyPUNUWChQU1IpLCByMzMKKyAg
ICA7OworICAgIGxkOCByMTY9W3IyXSwgOCAgICAgICAvLyBwc3IKKyAgICA7OworICAgIG1vdiBw
c3IubD1yMTYKKyAgICA7OworICAgIHNybHouZAorICAgIDs7CisgICAgbGQ4IHIxNj1bcjJdLCA4
ICAgICAgIC8vIHByCisgICAgOzsKKyAgICBtb3YgcHIgPXIxNiwtMQorICAgIGxkOCByMTY9W3Iy
XSAgICAgICAvLyB1bmF0CisgICAgOzsKKyAgICBtb3YgYXIudW5hdD1yMTYKKyAgICA7OworICAg
IGFkZHMgcjI9Q1RYKFJTQykscjMzCisgICAgOzsKKyAgICBsZDggcjE2ID1bcjJdCisgICAgOzsK
KyAgICBtb3YgYXIucnNjID0gcjE2CisgICAgOzsKKyAgICBici5yZXQuc3B0ay5mZXcgYjAKK0VO
RCh2bW1fdHJhbXBvbGluZSkKKworCi0tIAoxLjUuMQoK

------_=_NextPart_001_01C863F4.3B53F3BF--
