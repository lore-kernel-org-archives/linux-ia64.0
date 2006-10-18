From: Keith Owens <kaos@sgi.com>
Date: Wed, 18 Oct 2006 05:36:49 +0000
Subject: [patch 2.6.19-rc2] Correct definition of handle_IPI
Message-Id: <8916.1161149809@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The declaration of handle_IPI in arch/ia64/kernel/smp.c was changed but
not the definition of this function.  Remove struct pt_regs from
handle_IPI().

The declaration of handle_IPI should really be in a header file instead
of a .c file, but which one?  Adding

  extern irqreturn_t handle_IPI(int irq, void *dev_id);

to include/asm-ia64/smp.h is the obvious place but that leads to
include hell.  Using irqreturn_t requires linux/interrupt.h which
leads to a recursive mess.  sched.h includes smp.h quit early, adding
interrupt.h to smp.h uses data from sched.h before most of sched.h is
expanded.

  CC      arch/ia64/kernel/asm-offsets.s
In file included from linux/include/linux/hardirq.h:5,
                 from linux/include/linux/interrupt.h:11,
                 from include/asm-ia64/smp.h:17,
                 from linux/include/linux/smp.h:18,
                 from linux/include/linux/sched.h:65,
                 from linux/arch/ia64/kernel/asm-offsets.c:9:
linux/include/linux/smp_lock.h: In function reacquire_kernel_lock:
linux/include/linux/smp_lock.h:35: error: dereferencing pointer to incomplete type
In file included from linux/include/linux/slab.h:14,
                 from linux/include/linux/percpu.h:5,
                 from linux/include/asm-generic/irq_regs.h:15,
                 from include/asm-ia64/irq_regs.h:1,
                 from linux/include/linux/irq.h:24,
                 from include/asm-ia64/hardirq.h:11,
                 from linux/include/linux/hardirq.h:7,
                 from linux/include/linux/interrupt.h:11,
                 from include/asm-ia64/smp.h:17,
                 from linux/include/linux/smp.h:18,
                 from linux/include/linux/sched.h:65,
                 from linux/arch/ia64/kernel/asm-offsets.c:9:
linux/include/linux/gfp.h: In function alloc_pages_node:
linux/include/linux/gfp.h:131: warning: implicit declaration of function raw_smp_processor_id
In file included from linux/include/linux/irq.h:185,
                 from include/asm-ia64/hardirq.h:11,
                 from linux/include/linux/hardirq.h:7,
                 from linux/include/linux/interrupt.h:11,
                 from include/asm-ia64/smp.h:17,
                 from linux/include/linux/smp.h:18,
                 from linux/include/linux/sched.h:65,
                 from linux/arch/ia64/kernel/asm-offsets.c:9:
include/asm-ia64/hw_irq.h: In function ia64_resend_irq:
include/asm-ia64/hw_irq.h:102: warning: implicit declaration of function smp_processor_id
make[2]: *** [arch/ia64/kernel/asm-offsets.s] Error 1

Signed-off-by: Keith Owens <kaos@sgi.com>

---

Sorry for any duplicates.  Cut and paste of color gcc messages into
exmh generates MIME8 messages which then get rejected by vger's
bogofilter.

 arch/ia64/kernel/smp.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux/arch/ia64/kernel/smp.c
=================================--- linux.orig/arch/ia64/kernel/smp.c
+++ linux/arch/ia64/kernel/smp.c
@@ -108,7 +108,7 @@ cpu_die(void)
 }
 
 irqreturn_t
-handle_IPI (int irq, void *dev_id, struct pt_regs *regs)
+handle_IPI (int irq, void *dev_id)
 {
 	int this_cpu = get_cpu();
 	unsigned long *pending_ipis = &__ia64_per_cpu_var(ipi_operation);





--k9I8DriA003673.1161159233/omx2.sgi.com--




------- End of Forwarded Message


