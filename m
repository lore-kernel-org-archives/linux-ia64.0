From: Jesse Barnes <jbarnes@sgi.com>
Date: Thu, 12 Dec 2002 20:23:20 +0000
Subject: [Linux-ia64] Re: [PATCH] fill in si_code for fpu faults
MIME-Version: 1
Content-Type: multipart/mixed; boundary="h31gzZEtNLTqOjlF"
Message-Id: <marc-linux-ia64-105590709805557@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--h31gzZEtNLTqOjlF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Dec 12, 2002 at 11:14:31AM -0800, David Mosberger wrote:
> Basically OK with me, however:
> 
>  o What's the point of declaring fp_fault_info in a header file?  It's
>    used only in one place.

No particular reason.  Fixed.

>  o si_code is NOT a bitmask; it makes no sense at all for
>    fp_fault_si_code() to OR multiple values together; this makes me
>    highly suspicious that there is a misunderstanding somewhere...

Yes, there was a misunderstanding, but I think I get it now.  Fixed.

>  o Who defined FP_SWASST and FPE_DENORM?  I don't recall seeing them
>    in the ia64 psABI and they definitely look ia64-specific, so their
>    names should at least be prefixed by a double-underscore
>    (siginfo.h).

Yeah, they're ia64 specific, so I've prefixed them, but I'm not sure if
they're valid from an ABI perspective.  Should we just return FPE_FLTINV
for those cases?

>  o If you add stuff to asm/siginfo.h, don't forget to update glibc (in
>    sysdeps/unix/sysv/linux/ia64/bits/siginfo.h).

Ok.

Hope this is a little better.

Thanks for looking at this,
Jesse

--h31gzZEtNLTqOjlF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="fpswa-si_code-decode-2.4.19-ia64.patch"

diff -Naur -X /home/jbarnes/dontdiff linux-2.4.19-ia64/arch/ia64/kernel/traps.c linux-2.4.19-ia64-fpswa/arch/ia64/kernel/traps.c
--- linux-2.4.19-ia64/arch/ia64/kernel/traps.c	Thu Dec 12 10:15:57 2002
+++ linux-2.4.19-ia64-fpswa/arch/ia64/kernel/traps.c	Thu Dec 12 12:22:24 2002
@@ -45,6 +45,37 @@
 
 static fpswa_interface_t *fpswa_interface;
 
+/*
+ * fp fault isr.code <-> siginfo.si_code mapping
+ */
+static struct _fp_fault_info {
+	unsigned long isr_code_bit;
+	int si_code; /* SIGFPE si_code */
+} fp_fault_info[] = {
+	{ 1<<0, FPE_FLTINV },
+	{ 1<<1, __FPE_DENORM },
+	{ 1<<2, FPE_FLTDIV },
+	{ 1<<3, __FPE_SWASST },
+	{ 1<<4, FPE_FLTINV },
+	{ 1<<5, __FPE_DENORM },
+	{ 1<<6, FPE_FLTDIV },
+	{ 1<<7, __FPE_SWASST },
+};
+
+static inline int
+fp_fault_si_code(__u64 isr)
+{
+	int i;
+	int nr_entries;
+	nr_entries = sizeof(fp_fault_info)/sizeof(struct fp_fault_info);
+	
+	for (i = 0; i < nr_entries; i++) {
+		if (isr & fp_fault_info[i].isr_code_bit)
+			return fp_fault_info[i].si_code;
+	}
+	return FPE_FLTINV; /* no code found? */
+}
+
 void __init
 trap_init (void)
 {
@@ -336,8 +367,9 @@
 		fpu_swa_count = 0;
 	if ((++fpu_swa_count < 5) && !(current->thread.flags & IA64_THREAD_FPEMU_NOPRINT)) {
 		last_time = jiffies;
-		printk(KERN_WARNING "%s(%d): floating-point assist fault at ip %016lx\n",
-		       current->comm, current->pid, regs->cr_iip + ia64_psr(regs)->ri);
+		printk(KERN_WARNING "%s(%d): floating-point assist %s ",
+		       current->comm, current->pid, fp_fault ? "fault:" : "trap");
+		printk("ip=%016lx, isr=%16lx\n", regs->cr_iip + ia64_psr(regs)->ri, isr);
 	}
 
 	exception = fp_emulate(fp_fault, bundle, &regs->cr_ipsr, &regs->ar_fpsr, &isr, &regs->pr,
@@ -556,6 +588,8 @@
 			siginfo.si_signo = SIGFPE;
 			siginfo.si_errno = 0;
 			siginfo.si_code = FPE_FLTINV;
+			if (vector == 32) /* decode fault into si_code */
+				siginfo.si_code = fp_fault_si_code(isr);
 			siginfo.si_addr = (void *) (regs->cr_iip + ia64_psr(regs)->ri);
 			siginfo.si_flags = __ISR_VALID;
 			siginfo.si_isr = isr;
diff -Naur -X /home/jbarnes/dontdiff linux-2.4.19-ia64/include/asm-ia64/#fpu.h# linux-2.4.19-ia64-fpswa/include/asm-ia64/#fpu.h#
--- linux-2.4.19-ia64/include/asm-ia64/#fpu.h#	Wed Dec 31 16:00:00 1969
+++ linux-2.4.19-ia64-fpswa/include/asm-ia64/#fpu.h#	Thu Dec 12 12:14:31 2002
@@ -0,0 +1,65 @@
+#ifndef _ASM_IA64_FPU_H
+#define _ASM_IA64_FPU_H
+
+/*
+ * Copyright (C) 1998, 1999 Hewlett-Packard Co
+ * Copyright (C) 1998, 1999 David Mosberger-Tang <davidm@hpl.hp.com>
+ */
+
+#include <asm/types.h>
+
+/* floating point status register: */
+#define FPSR_TRAP_VD	(1 << 0)	/* invalid op trap disabled */
+#define FPSR_TRAP_DD	(1 << 1)	/* denormal trap disabled */
+#define FPSR_TRAP_ZD	(1 << 2)	/* zero-divide trap disabled */
+#define FPSR_TRAP_OD	(1 << 3)	/* overflow trap disabled */
+#define FPSR_TRAP_UD	(1 << 4)	/* underflow trap disabled */
+#define FPSR_TRAP_ID	(1 << 5)	/* inexact trap disabled */
+#define FPSR_S0(x)	((x) <<  6)
+#define FPSR_S1(x)	((x) << 19)
+#define FPSR_S2(x)	(__IA64_UL(x) << 32)
+#define FPSR_S3(x)	(__IA64_UL(x) << 45)
+
+/* floating-point status field controls: */
+#define FPSF_FTZ	(1 << 0)		/* flush-to-zero */
+#define FPSF_WRE	(1 << 1)		/* widest-range exponent */
+#define FPSF_PC(x)	(((x) & 0x3) << 2)	/* precision control */
+#define FPSF_RC(x)	(((x) & 0x3) << 4)	/* rounding control */
+#define FPSF_TD		(1 << 6)		/* trap disabled */
+
+/* floating-point status field flags: */
+#define FPSF_V		(1 <<  7)		/* invalid operation flag */
+#define FPSF_D		(1 <<  8)		/* denormal/unnormal operand flag */
+#define FPSF_Z		(1 <<  9)		/* zero divide (IEEE) flag */
+#define FPSF_O		(1 << 10)		/* overflow (IEEE) flag */
+#define FPSF_U		(1 << 11)		/* underflow (IEEE) flag */
+#define FPSF_I		(1 << 12)		/* inexact (IEEE) flag) */
+
+/* floating-point rounding control: */
+#define FPRC_NEAREST	0x0
+#define FPRC_NEGINF	0x1
+#define FPRC_POSINF	0x2
+#define FPRC_TRUNC	0x3
+
+#define FPSF_DEFAULT	(FPSF_PC (0x3) | FPSF_RC (FPRC_NEAREST))
+
+/* This default value is the same as HP-UX uses.  Don't change it
+   without a very good reason.  */
+#define FPSR_DEFAULT	(FPSR_TRAP_VD | FPSR_TRAP_DD | FPSR_TRAP_ZD	\
+			 | FPSR_TRAP_OD | FPSR_TRAP_UD | FPSR_TRAP_ID	\
+			 | FPSR_S0 (FPSF_DEFAULT)			\
+			 | FPSR_S1 (FPSF_DEFAULT | FPSF_TD | FPSF_WRE)	\
+			 | FPSR_S2 (FPSF_DEFAULT | FPSF_TD)		\
+			 | FPSR_S3 (FPSF_DEFAULT | FPSF_TD))
+
+# ifndef __ASSEMBLY__
+
+struct ia64_fpreg {
+	union {
+		unsigned long bits[2];
+	} u;
+} __attribute__ ((aligned (16)));
+
+# endif /* __ASSEMBLY__ */
+
+#endif /* _ASM_IA64_FPU_H */
diff -Naur -X /home/jbarnes/dontdiff linux-2.4.19-ia64/include/asm-ia64/fpu.h linux-2.4.19-ia64-fpswa/include/asm-ia64/fpu.h
--- linux-2.4.19-ia64/include/asm-ia64/fpu.h	Sun Feb  6 18:42:40 2000
+++ linux-2.4.19-ia64-fpswa/include/asm-ia64/fpu.h	Thu Dec 12 10:11:45 2002
@@ -54,6 +54,11 @@
 
 # ifndef __ASSEMBLY__
 
+struct fp_fault_info {
+	unsigned long isr_code_bit;
+	int si_code; /* SIGFPE si_code */
+};
+
 struct ia64_fpreg {
 	union {
 		unsigned long bits[2];
diff -Naur -X /home/jbarnes/dontdiff linux-2.4.19-ia64/include/asm-ia64/siginfo.h linux-2.4.19-ia64-fpswa/include/asm-ia64/siginfo.h
--- linux-2.4.19-ia64/include/asm-ia64/siginfo.h	Thu Dec 12 10:15:59 2002
+++ linux-2.4.19-ia64-fpswa/include/asm-ia64/siginfo.h	Thu Dec 12 12:18:52 2002
@@ -172,6 +172,8 @@
 #define __FPE_DECERR	(__SI_FAULT|11)	/* packed decimal error */
 #define __FPE_INVASC	(__SI_FAULT|12)	/* invalid ASCII digit */
 #define __FPE_INVDEC	(__SI_FAULT|13)	/* invalid decimal digit */
+#define __FPE_SWASST	(__SI_FAULT|14) /* software assist fault */
+#define __FPE_DENORM	(__SI_FAULT|15) /* denormal/unnormal operand */
 #define NSIGFPE		13
 
 /*

--h31gzZEtNLTqOjlF--

