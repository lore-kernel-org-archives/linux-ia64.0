From: "H. J. Lu" <hjl@lucon.org>
Date: Fri, 13 May 2005 20:50:04 +0000
Subject: Re: heads up: apparent GAS bug in current (CVS) binutils
Message-Id: <20050513205004.GB30928@lucon.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200505122155.j4CLteGX024882@napali.hpl.hp.com>
In-Reply-To: <200505122155.j4CLteGX024882@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, May 13, 2005 at 01:34:10PM -0700, David Mosberger wrote:
> >>>>> On Fri, 13 May 2005 10:32:19 -0700, "Lu, Hongjiu" <hongjiu.lu@intel.com> said:
> 
>   HJ> I tried binutils 2.15.92.0.2 20040927 and got the same
>   HJ> result. What is the version of assembler which you think is
>   HJ> good?
> 
> The standard Debian/sarge as seems fine:
> 
>  $ as -v
>  GNU assembler version 2.15 (ia64-linux) using BFD version 2.15
> 

As I have mentioned before, it is an IPF specific kernel issue.
Basically, when you use weak functions, unwind info may be wrong.
I am enclosing an updated kernel patch.


H.J.

--- linux/arch/ia64/kernel/irq.c.weak	2005-05-10 13:52:00.000000000 -0700
+++ linux/arch/ia64/kernel/irq.c	2005-05-13 13:18:36.000000000 -0700
@@ -103,7 +103,9 @@ static char irq_redir [NR_IRQS]; // = { 
  * Arch specific routine for deferred write to iosapic rte to reprogram
  * intr destination.
  */
-void proc_set_irq_affinity(unsigned int irq, cpumask_t mask_val)
+void
+__comdatfunc (proc_set_irq_affinity)
+proc_set_irq_affinity(unsigned int irq, cpumask_t mask_val)
 {
 	pending_irq_cpumask[irq] = mask_val;
 }
--- linux/arch/ia64/kernel/smpboot.c.weak	2005-05-10 13:52:00.000000000 -0700
+++ linux/arch/ia64/kernel/smpboot.c	2005-05-13 13:18:57.000000000 -0700
@@ -404,7 +404,9 @@ start_secondary (void *unused)
 	return 0;
 }
 
-struct pt_regs * __devinit idle_regs(struct pt_regs *regs)
+struct pt_regs *
+__devinit __comdatfunc (idle_regs)
+idle_regs(struct pt_regs *regs)
 {
 	return NULL;
 }
--- linux/include/linux/compiler.h.weak	2005-05-10 13:52:00.000000000 -0700
+++ linux/include/linux/compiler.h	2005-05-13 13:20:14.000000000 -0700
@@ -155,4 +155,9 @@ extern void __chk_io_ptr(void __iomem *)
 #define __always_inline inline
 #endif
 
+#ifndef __comdatfunc
+#define __comdatfunc(f) \
+  __attribute__ ((__section__ (".gnu.linkonce.t." #f )))
+#endif
+
 #endif /* __LINUX_COMPILER_H */
--- linux/kernel/fork.c.weak	2005-05-10 13:52:00.000000000 -0700
+++ linux/kernel/fork.c	2005-05-13 13:19:40.000000000 -0700
@@ -1148,7 +1148,9 @@ bad_fork_free:
 	goto fork_out;
 }
 
-struct pt_regs * __devinit __attribute__((weak)) idle_regs(struct pt_regs *regs)
+struct pt_regs *
+__devinit __comdatfunc (idle_regs)
+idle_regs(struct pt_regs *regs)
 {
 	memset(regs, 0, sizeof(struct pt_regs));
 	return regs;
--- linux/kernel/irq/proc.c.weak	2005-05-10 13:52:00.000000000 -0700
+++ linux/kernel/irq/proc.c	2005-05-13 13:19:17.000000000 -0700
@@ -19,7 +19,8 @@ static struct proc_dir_entry *root_irq_d
  */
 static struct proc_dir_entry *smp_affinity_entry[NR_IRQS];
 
-void __attribute__((weak))
+void
+__comdatfunc (proc_set_irq_affinity)
 proc_set_irq_affinity(unsigned int irq, cpumask_t mask_val)
 {
 	irq_affinity[irq] = mask_val;
