From: Jesse Barnes <jbarnes@sgi.com>
Date: Thu, 12 Dec 2002 18:25:57 +0000
Subject: Re: [Linux-ia64] fpswa logging redux
MIME-Version: 1
Content-Type: multipart/mixed; boundary="oyUTqETQ0mS9luUI"
Message-Id: <marc-linux-ia64-105590709805554@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805545@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805545@msgid-missing>
To: linux-ia64@vger.kernel.org

--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Dec 11, 2002 at 03:42:52PM -0800, David Mosberger wrote:
> >>>>> On Wed, 11 Dec 2002 14:25:14 -0800, Jesse Barnes <jbarnes@sgi.com> said:
> 
>   Jesse> I'd like to fully decode the information in the isr about
>   Jesse> what type of fault occured (whether it be a software assist
>   Jesse> fault, some sort of IEEE filter fault, etc.) and print it
>   Jesse> along with the ip when faults occur.  While I'm at it, I may
>   Jesse> as well the proper SIGFPE subcode into si_info in case of
>   Jesse> signal delivery is selected.
> 
> Like Keith, I'd like to keep the amount of decoding in the kernel as
> minimal as possible.  We already have si_isr in the siginfo structure,
> so apps/libraries can decode things themselves.  Having said that, we
> ought to decode things sufficiently so that si_code can be set to the
> correct value (where this makes sense).  Hopefully, that won't add
> tons of code and it would help application portability.

How about something like this then?  It just prints out the isr in
addition to the ip for the case of printk, and decodes the right si_code
for signals.  If this approach looks ok, I can add trap decoding too.

Thanks,
Jesse

--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="fpswa-si_code-decode-2.4.19-ia64.patch"

diff -Naur -X /home/jbarnes/dontdiff linux-2.4.19-ia64/arch/ia64/kernel/traps.c linux-2.4.19-ia64-fpswa/arch/ia64/kernel/traps.c
--- linux-2.4.19-ia64/arch/ia64/kernel/traps.c	Thu Dec 12 10:15:57 2002
+++ linux-2.4.19-ia64-fpswa/arch/ia64/kernel/traps.c	Thu Dec 12 10:23:25 2002
@@ -45,6 +45,34 @@
 
 static fpswa_interface_t *fpswa_interface;
 
+/*
+ * fp fault isr.code <-> siginfo.si_code mapping
+ */
+struct fp_fault_info fp_fault_info[] = {
+	{ 1<<0, FPE_FLTINV },
+	{ 1<<1, FPE_DENORM },
+	{ 1<<2, FPE_FLTDIV },
+	{ 1<<3, FPE_SWASST },
+	{ 1<<4, FPE_FLTINV },
+	{ 1<<5, FPE_DENORM },
+	{ 1<<6, FPE_FLTDIV },
+	{ 1<<7, FPE_SWASST },
+};
+
+static inline int
+fp_fault_si_code(__u64 isr)
+{
+	int i, ret = 0;
+	int nr_entries;
+	nr_entries = sizeof(fp_fault_info)/sizeof(struct fp_fault_info);
+	
+	for (i = 0; i < nr_entries; i++) {
+		if (isr & fp_fault_info[i].isr_code_bit)
+			ret |= fp_fault_info[i].si_code;
+	}
+	return ret;
+}
+
 void __init
 trap_init (void)
 {
@@ -336,8 +364,9 @@
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
@@ -556,6 +585,8 @@
 			siginfo.si_signo = SIGFPE;
 			siginfo.si_errno = 0;
 			siginfo.si_code = FPE_FLTINV;
+			if (vector == 32) /* decode fault into si_code */
+				siginfo.si_code = fp_fault_si_code(isr);
 			siginfo.si_addr = (void *) (regs->cr_iip + ia64_psr(regs)->ri);
 			siginfo.si_flags = __ISR_VALID;
 			siginfo.si_isr = isr;
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
+++ linux-2.4.19-ia64-fpswa/include/asm-ia64/siginfo.h	Thu Dec 12 10:19:47 2002
@@ -172,6 +172,8 @@
 #define __FPE_DECERR	(__SI_FAULT|11)	/* packed decimal error */
 #define __FPE_INVASC	(__SI_FAULT|12)	/* invalid ASCII digit */
 #define __FPE_INVDEC	(__SI_FAULT|13)	/* invalid decimal digit */
+#define FPE_SWASST	(__SI_FAULT|14) /* software assist fault */
+#define FPE_DENORM	(__SI_FAULT|15) /* denormal/unnormal operand */
 #define NSIGFPE		13
 
 /*

--oyUTqETQ0mS9luUI--

