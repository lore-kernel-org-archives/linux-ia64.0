From: "H. J. Lu" <hjl@lucon.org>
Date: Fri, 13 May 2005 19:10:51 +0000
Subject: PATCH: Don't use weak function
Message-Id: <20050513191051.GA29540@lucon.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, May 13, 2005 at 11:48:35AM -0700, Lu, Hongjiu wrote:
> Hi David,
> 
> I think it is the result of the usage of weak function. I am enclosing a
> testcase to show it. The correct approach is to use comdat section group
> or linkonce section. The problem will go away. I will see if I can come
> up with a kernel patch.
> 

This patch works for me. The key here is the arch dependent file
has to come before generic one during the final link.


H.J.
---
--- linux/arch/ia64/kernel/irq.c.weak	2005-05-10 13:52:00.000000000 -0700
+++ linux/arch/ia64/kernel/irq.c	2005-05-13 12:04:34.427204360 -0700
@@ -103,7 +103,9 @@ static char irq_redir [NR_IRQS]; // = { 
  * Arch specific routine for deferred write to iosapic rte to reprogram
  * intr destination.
  */
-void proc_set_irq_affinity(unsigned int irq, cpumask_t mask_val)
+void
+__attribute__ ((__section__ (".gnu.linkonce.t.proc_set_irq_affinity")))
+proc_set_irq_affinity(unsigned int irq, cpumask_t mask_val)
 {
 	pending_irq_cpumask[irq] = mask_val;
 }
--- linux/arch/ia64/kernel/smpboot.c.weak	2005-05-10 13:52:00.000000000 -0700
+++ linux/arch/ia64/kernel/smpboot.c	2005-05-13 12:04:16.115259501 -0700
@@ -404,7 +404,9 @@ start_secondary (void *unused)
 	return 0;
 }
 
-struct pt_regs * __devinit idle_regs(struct pt_regs *regs)
+struct pt_regs *
+__devinit __attribute__ ((__section__ (".gnu.linkonce.t.idle_regs")))
+idle_regs(struct pt_regs *regs)
 {
 	return NULL;
 }
--- linux/kernel/fork.c.weak	2005-05-10 13:52:00.000000000 -0700
+++ linux/kernel/fork.c	2005-05-13 12:03:10.156710316 -0700
@@ -1148,7 +1148,9 @@ bad_fork_free:
 	goto fork_out;
 }
 
-struct pt_regs * __devinit __attribute__((weak)) idle_regs(struct pt_regs *regs)
+struct pt_regs *
+__devinit __attribute__ ((__section__ (".gnu.linkonce.t.idle_regs")))
+idle_regs(struct pt_regs *regs)
 {
 	memset(regs, 0, sizeof(struct pt_regs));
 	return regs;
--- linux/kernel/irq/proc.c.weak	2005-05-10 13:52:00.000000000 -0700
+++ linux/kernel/irq/proc.c	2005-05-13 12:02:41.095494642 -0700
@@ -19,7 +19,8 @@ static struct proc_dir_entry *root_irq_d
  */
 static struct proc_dir_entry *smp_affinity_entry[NR_IRQS];
 
-void __attribute__((weak))
+void
+__attribute__ ((__section__ (".gnu.linkonce.t.proc_set_irq_affinity")))
 proc_set_irq_affinity(unsigned int irq, cpumask_t mask_val)
 {
 	irq_affinity[irq] = mask_val;
