From: "Pallipadi, Venkatesh" <venkatesh.pallipadi@intel.com>
Date: Tue, 08 Oct 2002 22:36:15 +0000
Subject: [Linux-ia64] [PATCH] Save/Restore of IA32 fpstate in sigcontext
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_000_01C26F1B.1CE9F510"
Message-Id: <marc-linux-ia64-105590709805153@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_000_01C26F1B.1CE9F510
Content-Type: text/plain;
	charset="iso-8859-1"


Hi,

   The IA32 fpstate information is not getting saved/restored during IA32
exception handling. The issue was first observed due to an IA32 binary
(which runs fine on IA32 system), failing on Itanium based system. The
binary was trying to access the fpstate information during an FPE and got a
SEGV, as the fpstate was not getting saved and the sigcontext->fpstate
pointer was NULL.

   The attached patch fixes the issue.

   While fixing this, I also noticed few bugs in the way sys32_ptrace is
saving and restoring the IA32 fpstate. I am currently working on this and
will soon be sending a patch fixing this. 

   Please let me know, if you need any more information on this.

Thanks,
-Venkatesh

 <<fpe.final.ZIP>> 


--- ia64-fpe/arch/ia64/ia32/ia32_signal.c.org	Thu Sep 26 10:50:24 2002
+++ ia64-fpe/arch/ia64/ia32/ia32_signal.c	Fri Oct  4 11:24:02 2002
@@ -39,6 +39,16 @@
 #define __IA32_NR_sigreturn            119
 #define __IA32_NR_rt_sigreturn         173
 
+register double f16 asm ("f16"); register double f17 asm ("f17");
+register double f18 asm ("f18"); register double f19 asm ("f19");
+register double f20 asm ("f20"); register double f21 asm ("f21");
+register double f22 asm ("f22"); register double f23 asm ("f23");
+
+register double f24 asm ("f24"); register double f25 asm ("f25");
+register double f26 asm ("f26"); register double f27 asm ("f27");
+register double f28 asm ("f28"); register double f29 asm ("f29");
+register double f30 asm ("f30"); register double f31 asm ("f31");
+
 struct sigframe_ia32
 {
        int pretcode;
@@ -143,6 +153,274 @@
 	return err;
 }
 
+
+/*
+ *  SAVE and RESTORE of ia32 fpstate info, from ia64 current state
+ *  Used in exception handler to pass the fpstate to the user, and restore 
+ *  the fpstate while returning from the exception handler.
+ *  
+ *    fpstate info and their mapping to IA64 regs:
+ *    fpstate    REG(BITS)      Attribute    Comments
+ *    cw         ar.fcr(0:12)                with bits 7 and 6 not used
+ *    sw         ar.fsr(0:15)
+ *    tag        ar.fsr(16:31)               with odd numbered bits not
used
+ *                                           (read returns 0, writes
ignored)
+ *    ipoff      ar.fir(0:31)   RO
+ *    cssel      ar.fir(32:47)  RO
+ *    dataoff    ar.fdr(0:31)   RO
+ *    datasel    ar.fdr(32:47)  RO
+ *    
+ *    _st[(0+TOS)%8]   f8
+ *    _st[(1+TOS)%8]   f9                    (f8, f9 from ptregs)
+ *      : :            :                     (f10..f15 from live reg)
+ *      : :            :                     
+ *    _st[(7+TOS)%8]   f15                   TOS=sw.top(bits11:13)
+ *
+ *    status     Same as sw     RO
+ *    magic      0                           as X86_FXSR_MAGIC in ia32
+ *    mxcsr      Bits(7:15)=ar.fcr(39:47)
+ *               Bits(0:5) =ar.fsr(32:37)    with bit 6 reserved
+ *    _xmm[0..7] f16..f31                    (live registers)
+ *                                           with _xmm[0] 
+ *                                             Bit(64:127)=f17(0:63)
+ *                                             Bit(0:63)=f16(0:63)
+ *    All other fields unused...
+ */
+
+#define __ldfe(regnum, x)					\
+({								\
+ 	register double __f__ asm ("f"#regnum);			\
+	__asm__ __volatile__ ("ldfe %0=[%1] ;;" :"=f"(__f__): "r"(x)); \
+})
+
+#define __ldf8(regnum, x)					\
+({								\
+ 	register double __f__ asm ("f"#regnum);			\
+	__asm__ __volatile__ ("ldf8 %0=[%1] ;;" :"=f"(__f__): "r"(x)); \
+})
+
+#define __stfe(x, regnum)					\
+({								\
+ 	register double __f__ asm ("f"#regnum);			\
+	__asm__ __volatile__ ("stfe [%0]=%1" :: "r"(x), "f"(__f__) :
"memory");
\
+})
+
+#define __stf8(x, regnum)					\
+({								\
+ 	register double __f__ asm ("f"#regnum);			\
+	__asm__ __volatile__ ("stf8 [%0]=%1" :: "r"(x), "f"(__f__) :
"memory");
\
+})
+
+static int
+save_ia32_fpstate_live (struct _fpstate_ia32 *save)
+{
+	struct task_struct *tsk = current;
+	struct pt_regs *ptp;
+	struct _fpreg_ia32 *fpregp;
+	char buf[32];
+	unsigned long fsr, fcr, fir, fdr;
+	unsigned long num128[2];
+	unsigned long mxcsr=0;
+	int fp_tos, fr8_st_map;
+
+	if (!access_ok(VERIFY_WRITE, save, sizeof(*save)))
+		return -EFAULT;
+
+	/* Readin fsr, fcr, fir, fdr and copy onto fpstate */
+	asm volatile ( "mov %0=ar.fsr;" : "=r"(fsr));
+	asm volatile ( "mov %0=ar.fcr;" : "=r"(fcr));
+	asm volatile ( "mov %0=ar.fir;" : "=r"(fir));
+	asm volatile ( "mov %0=ar.fdr;" : "=r"(fdr));
+
+	__put_user(fcr & 0xffff, &save->cw);
+	__put_user(fsr & 0xffff, &save->sw);
+	__put_user((fsr>>16) & 0xffff, &save->tag);
+	__put_user(fir, &save->ipoff);
+	__put_user((fir>>32) & 0xffff, &save->cssel);
+	__put_user(fdr, &save->dataoff);
+	__put_user((fdr>>32) & 0xffff, &save->datasel);
+	__put_user(fsr & 0xffff, &save->status);
+
+	mxcsr = ((fcr>>32) & 0xff80) | ((fsr>>32) & 0x3f);
+	__put_user(mxcsr & 0xffff, &save->mxcsr);
+	__put_user( 0, &save->magic); //#define X86_FXSR_MAGIC   0x0000
+
+	/* 
+	 * save f8 and f9  from pt_regs
+	 * save f10..f15 from live register set 
+	 */
+	/*
+	 *  Find the location where f8 has to go in fp reg stack 
+	 *  This depends on TOP(11:13) field of sw. Other f reg continue 
+	 *  sequentially from where f8 maps to.
+	 */
+	fp_tos = (fsr>>11)&0x7;
+	fr8_st_map = (8-fp_tos)&0x7;
+	ptp = ia64_task_regs(tsk);
+	fpregp = (struct _fpreg_ia32 *)(((unsigned long)buf + 15) & ~15);
+	ia64f2ia32f(fpregp, &ptp->f8);
+	copy_to_user(&save->_st[(0+fr8_st_map)&0x7], fpregp, sizeof(struct
_fpreg_ia32));
+	ia64f2ia32f(fpregp, &ptp->f9);
+	copy_to_user(&save->_st[(1+fr8_st_map)&0x7], fpregp, sizeof(struct
_fpreg_ia32));
+
+	__stfe(fpregp, 10);
+	copy_to_user(&save->_st[(2+fr8_st_map)&0x7], fpregp, sizeof(struct
_fpreg_ia32));
+	__stfe(fpregp, 11);
+	copy_to_user(&save->_st[(3+fr8_st_map)&0x7], fpregp, sizeof(struct
_fpreg_ia32));
+	__stfe(fpregp, 12);
+	copy_to_user(&save->_st[(4+fr8_st_map)&0x7], fpregp, sizeof(struct
_fpreg_ia32));
+	__stfe(fpregp, 13);
+	copy_to_user(&save->_st[(5+fr8_st_map)&0x7], fpregp, sizeof(struct
_fpreg_ia32));
+	__stfe(fpregp, 14);
+	copy_to_user(&save->_st[(6+fr8_st_map)&0x7], fpregp, sizeof(struct
_fpreg_ia32));
+	__stfe(fpregp, 15);
+	copy_to_user(&save->_st[(7+fr8_st_map)&0x7], fpregp, sizeof(struct
_fpreg_ia32));
+
+	__stf8(&num128[0], 16);
+	__stf8(&num128[1], 17);
+	copy_to_user(&save->_xmm[0], num128, sizeof(struct _xmmreg_ia32));
+
+	__stf8(&num128[0], 18);
+	__stf8(&num128[1], 19);
+	copy_to_user(&save->_xmm[1], num128, sizeof(struct _xmmreg_ia32));
+
+	__stf8(&num128[0], 20);
+	__stf8(&num128[1], 21);
+	copy_to_user(&save->_xmm[2], num128, sizeof(struct _xmmreg_ia32));
+
+	__stf8(&num128[0], 22);
+	__stf8(&num128[1], 23);
+	copy_to_user(&save->_xmm[3], num128, sizeof(struct _xmmreg_ia32));
+
+	__stf8(&num128[0], 24);
+	__stf8(&num128[1], 25);
+	copy_to_user(&save->_xmm[4], num128, sizeof(struct _xmmreg_ia32));
+
+	__stf8(&num128[0], 26);
+	__stf8(&num128[1], 27);
+	copy_to_user(&save->_xmm[5], num128, sizeof(struct _xmmreg_ia32));
+
+	__stf8(&num128[0], 28);
+	__stf8(&num128[1], 29);
+	copy_to_user(&save->_xmm[6], num128, sizeof(struct _xmmreg_ia32));
+
+	__stf8(&num128[0], 30);
+	__stf8(&num128[1], 31);
+	copy_to_user(&save->_xmm[7], num128, sizeof(struct _xmmreg_ia32));
+	return 0;
+}
+
+static int
+restore_ia32_fpstate_live (struct _fpstate_ia32 *save)
+{
+	struct task_struct *tsk = current;
+	struct pt_regs *ptp;
+	unsigned int lo, hi;
+	unsigned long num128[2];
+	unsigned long num64, mxcsr;
+	struct _fpreg_ia32 *fpregp;
+	char buf[32];
+	unsigned long fsr, fcr;
+	int fp_tos, fr8_st_map;
+
+	if (!access_ok(VERIFY_READ, save, sizeof(*save)))
+		return(-EFAULT);
+
+	/*
+	 * Updating fsr, fcr, fir, fdr. 
+	 * Just a bit more complicated than save.
+	 * - Need to make sure that we dont write any value other than the 
+	 *   specific fpstate info
+	 * - Need to make sure that the untouched part of frs, fdr, fir, fcr
+	 *   should remain same while writing.
+	 * So, we do a read, change specific fields and write.
+	 */
+	asm volatile ( "mov %0=ar.fsr;" : "=r"(fsr));
+	asm volatile ( "mov %0=ar.fcr;" : "=r"(fcr));
+
+	__get_user(mxcsr, (unsigned int *)&save->mxcsr);
+	/* setting bits 0..5 8..12 with cw and 39..47 from mxcsr */
+	__get_user(lo, (unsigned int *)&save->cw);
+	num64 = mxcsr & 0xff10;
+	num64 = (num64 << 32) | (lo & 0x1f3f);
+	fcr = (fcr & (~0xff1000001f3f)) | num64;
+
+	/* setting bits 0..31 with sw and tag and 32..37 from mxcsr */
+	__get_user(lo, (unsigned int *)&save->sw);
+	__get_user(hi, (unsigned int *)&save->tag);
+	num64 = mxcsr & 0x3f;
+	num64 = (num64 << 16) | (hi & 0xffff);
+	num64 = (num64 << 16) | (lo & 0xffff);
+	fsr = (fsr & (~0x3fffffffff)) | num64;
+
+	asm volatile ( "mov ar.fsr=%0;" :: "r"(fsr));
+	asm volatile ( "mov ar.fcr=%0;" :: "r"(fcr));
+	/* 
+	 * restore f8, f9 onto pt_regs
+	 * restore f10..f15 onto live registers
+	 */
+	/*
+	 *  Find the location where f8 has to go in fp reg stack 
+	 *  This depends on TOP(11:13) field of sw. Other f reg continue 
+	 *  sequentially from where f8 maps to.
+	 */
+	fp_tos = (fsr>>11)&0x7;
+	fr8_st_map = (8-fp_tos)&0x7;
+	fpregp = (struct _fpreg_ia32 *)(((unsigned long)buf + 15) & ~15);
+
+	ptp = ia64_task_regs(tsk);
+	copy_from_user(fpregp, &save->_st[(0+fr8_st_map)&0x7], sizeof(struct
_fpreg_ia32));
+	ia32f2ia64f(&ptp->f8, fpregp);
+	copy_from_user(fpregp, &save->_st[(1+fr8_st_map)&0x7], sizeof(struct
_fpreg_ia32));
+	ia32f2ia64f(&ptp->f9, fpregp);
+
+	copy_from_user(fpregp, &save->_st[(2+fr8_st_map)&0x7], sizeof(struct
_fpreg_ia32));
+	__ldfe(10, fpregp);
+	copy_from_user(fpregp, &save->_st[(3+fr8_st_map)&0x7], sizeof(struct
_fpreg_ia32));
+	__ldfe(11, fpregp);
+	copy_from_user(fpregp, &save->_st[(4+fr8_st_map)&0x7], sizeof(struct
_fpreg_ia32));
+	__ldfe(12, fpregp);
+	copy_from_user(fpregp, &save->_st[(5+fr8_st_map)&0x7], sizeof(struct
_fpreg_ia32));
+	__ldfe(13, fpregp);
+	copy_from_user(fpregp, &save->_st[(6+fr8_st_map)&0x7], sizeof(struct
_fpreg_ia32));
+	__ldfe(14, fpregp);
+	copy_from_user(fpregp, &save->_st[(7+fr8_st_map)&0x7], sizeof(struct
_fpreg_ia32));
+	__ldfe(15, fpregp);
+
+	copy_from_user(num128, &save->_xmm[0], sizeof(struct _xmmreg_ia32));
+	__ldf8(16, &num128[0]);
+	__ldf8(17, &num128[1]);
+
+	copy_from_user(num128, &save->_xmm[1], sizeof(struct _xmmreg_ia32));
+	__ldf8(18, &num128[0]);
+	__ldf8(19, &num128[1]);
+
+	copy_from_user(num128, &save->_xmm[2], sizeof(struct _xmmreg_ia32));
+	__ldf8(20, &num128[0]);
+	__ldf8(21, &num128[1]);
+
+	copy_from_user(num128, &save->_xmm[3], sizeof(struct _xmmreg_ia32));
+	__ldf8(22, &num128[0]);
+	__ldf8(23, &num128[1]);
+
+	copy_from_user(num128, &save->_xmm[4], sizeof(struct _xmmreg_ia32));
+	__ldf8(24, &num128[0]);
+	__ldf8(25, &num128[1]);
+
+	copy_from_user(num128, &save->_xmm[5], sizeof(struct _xmmreg_ia32));
+	__ldf8(26, &num128[0]);
+	__ldf8(27, &num128[1]);
+
+	copy_from_user(num128, &save->_xmm[6], sizeof(struct _xmmreg_ia32));
+	__ldf8(28, &num128[0]);
+	__ldf8(29, &num128[1]);
+
+	copy_from_user(num128, &save->_xmm[7], sizeof(struct _xmmreg_ia32));
+	__ldf8(30, &num128[0]);
+	__ldf8(31, &num128[1]);
+	return 0;
+}
+
 static inline void
 sigact_set_handler (struct k_sigaction *sa, unsigned int handler, unsigned
int restorer)
 {
@@ -371,6 +649,9 @@
 	int  err = 0;
 	unsigned long flag;
 
+	if (!access_ok(VERIFY_WRITE, sc, sizeof(*sc)))
+		return -EFAULT;
+
 	err |= __put_user((regs->r16 >> 32) & 0xffff, (unsigned int
*)&sc->fs);
 	err |= __put_user((regs->r16 >> 48) & 0xffff, (unsigned int
*)&sc->gs);
 	err |= __put_user((regs->r16 >> 16) & 0xffff, (unsigned int
*)&sc->es);
@@ -397,6 +678,11 @@
 	err |= __put_user(regs->r12, &sc->esp_at_signal);
 	err |= __put_user((regs->r17 >> 16) & 0xffff, (unsigned int
*)&sc->ss);
 
+	if ( save_ia32_fpstate_live(fpstate) < 0 ) 
+		err = -EFAULT;
+	else
+		err |= __put_user((u32)(u64)fpstate, &sc->fpstate);
+
 #if 0
 	tmp = save_i387(fpstate);
 	if (tmp < 0)
@@ -418,6 +704,9 @@
 {
 	unsigned int err = 0;
 
+	if (!access_ok(VERIFY_READ, sc, sizeof(*sc)))
+		return(-EFAULT);
+
 #define COPY(ia64x, ia32x)	err |= __get_user(regs->ia64x, &sc->ia32x)
 
 #define copyseg_gs(tmp)		(regs->r16 |= (unsigned long) tmp <<
48)
@@ -477,6 +766,16 @@
 		regs->r1 = -1;	/* disable syscall checks, r1 is orig_eax */
 	}
 
+	{
+		struct _fpstate_ia32 *buf = NULL;
+		u32    fpstate_ptr;
+		err |= get_user(fpstate_ptr, &(sc->fpstate));
+		buf = (struct _fpstate_ia32 *)(u64)fpstate_ptr;
+		if (buf) {
+			err |= restore_ia32_fpstate_live(buf);
+		}
+	}
+
 #if 0
 	{
 		struct _fpstate * buf;
--- ia64-fpe/arch/ia64/ia32/sys_ia32.c.org	Fri Sep 27 14:53:07 2002
+++ ia64-fpe/arch/ia64/ia32/sys_ia32.c	Mon Sep 30 17:51:02 2002
@@ -2843,20 +2843,6 @@
 	}
 }
 
-static inline void
-ia32f2ia64f (void *dst, void *src)
-{
-	asm volatile ("ldfe f6=[%1];; stf.spill [%0]=f6" :: "r"(dst),
"r"(src) : "memory");
-	return;
-}
-
-static inline void
-ia64f2ia32f (void *dst, void *src)
-{
-	asm volatile ("ldf.fill f6=[%1];; stfe [%0]=f6" :: "r"(dst),
"r"(src) : "memory");
-	return;
-}
-
 static void
 put_fpreg (int regno, struct _fpreg_ia32 *reg, struct pt_regs *ptp, struct
switch_stack *swp,
 	   int tos)
--- ia64-fpe/arch/ia64/kernel/signal.c.org	Tue Oct  1 15:22:38 2002
+++ ia64-fpe/arch/ia64/kernel/signal.c	Wed Oct  2 10:35:14 2002
@@ -41,6 +41,16 @@
 
 extern long ia64_do_signal (sigset_t *, struct sigscratch *, long);	/*
forward decl */
 
+register double f16 asm ("f16"); register double f17 asm ("f17");
+register double f18 asm ("f18"); register double f19 asm ("f19");
+register double f20 asm ("f20"); register double f21 asm ("f21");
+register double f22 asm ("f22"); register double f23 asm ("f23");
+
+register double f24 asm ("f24"); register double f25 asm ("f25");
+register double f26 asm ("f26"); register double f27 asm ("f27");
+register double f28 asm ("f28"); register double f29 asm ("f29");
+register double f30 asm ("f30"); register double f31 asm ("f31");
+
 long
 ia64_rt_sigsuspend (sigset_t *uset, size_t sigsetsize, struct sigscratch
*scr)
 {
--- ia64-fpe/include/asm-ia64/ia32.h.org	Tue Oct  1 13:13:06 2002
+++ ia64-fpe/include/asm-ia64/ia32.h	Wed Oct  2 13:54:04 2002
@@ -73,6 +73,17 @@
        unsigned short exponent;
 };
 
+struct _fpxreg_ia32 {
+        unsigned short significand[4];
+        unsigned short exponent;
+        unsigned short padding[3];
+};
+
+struct _xmmreg_ia32 {
+        unsigned int element[4];
+};
+
+
 struct _fpstate_ia32 {
        unsigned int    cw,
 		       sw,
@@ -82,7 +93,16 @@
 		       dataoff,
 		       datasel;
        struct _fpreg_ia32      _st[8];
-       unsigned int    status;
+       unsigned short  status;
+       unsigned short  magic;          /* 0xffff = regular FPU data only */
+
+       /* FXSR FPU environment */
+       unsigned int         _fxsr_env[6];   /* FXSR FPU env is ignored */
+       unsigned int         mxcsr;
+       unsigned int         reserved;
+       struct _fpxreg_ia32  _fxsr_st[8];    /* FXSR FPU reg data is ignored
*/
+       struct _xmmreg_ia32  _xmm[8];
+       unsigned int         padding[56];
 };
 
 struct sigcontext_ia32 {
@@ -485,6 +505,18 @@
 extern unsigned long ia32_do_mmap (struct file *, unsigned long, unsigned
long, int, int, loff_t);
 extern void ia32_load_segment_descriptors (struct task_struct *task);
 
+#define ia32f2ia64f(dst,src) \
+	do { \
+	register double f6 asm ("f6"); \
+	asm volatile ("ldfe f6=[%2];; stf.spill [%1]=f6" : "=f"(f6):
"r"(dst), "r"(src) : "memory"); \
+	} while(0)
+
+#define ia64f2ia32f(dst,src) \
+	do { \
+	register double f6 asm ("f6"); \
+	asm volatile ("ldf.fill f6=[%2];; stfe [%1]=f6" : "=f"(f6):
"r"(dst),  "r"(src) : "memory"); \
+	} while(0)
+
 #endif /* !CONFIG_IA32_SUPPORT */
 
 #endif /* _ASM_IA64_IA32_H */





------_=_NextPart_000_01C26F1B.1CE9F510
Content-Type: application/octet-stream;
	name="fpe.final.ZIP"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
	filename="fpe.final.ZIP"

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

------_=_NextPart_000_01C26F1B.1CE9F510--

