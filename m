From: Dimitri Sivanich <sivanich@sgi.com>
Date: Wed, 15 Mar 2006 14:39:06 +0000
Subject: [PATCH] Fix percpu interrupt allocation in mmtimer code
Message-Id: <20060315143906.GE29195@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The timer interrupt in the mmtimer code needs to be allocated as
a percpu interrupt for acceptable performance on larger systems.

The code needs to be updated to set this up properly, as the
SA_PERCPU_IRQ flag to request_interrupt is not supported.

Signed-off-by: Dimitri Sivanich <sivanich@sgi.com>

Index: linux/arch/ia64/kernel/irq_ia64.c
=================================--- linux.orig/arch/ia64/kernel/irq_ia64.c	2006-03-14 14:52:39.735003644 -0600
+++ linux/arch/ia64/kernel/irq_ia64.c	2006-03-14 14:53:20.219310264 -0600
@@ -239,6 +239,7 @@ register_percpu_irq (ia64_vector vec, st
 				setup_irq(irq, action);
 		}
 }
+EXPORT_SYMBOL(register_percpu_irq);
 
 void __init
 init_IRQ (void)
Index: linux/drivers/char/mmtimer.c
=================================--- linux.orig/drivers/char/mmtimer.c	2006-03-14 14:52:39.736956577 -0600
+++ linux/drivers/char/mmtimer.c	2006-03-14 15:59:04.662279315 -0600
@@ -59,6 +59,8 @@ static int mmtimer_ioctl(struct inode *i
 			 unsigned int cmd, unsigned long arg);
 static int mmtimer_mmap(struct file *file, struct vm_area_struct *vma);
 
+static irqreturn_t mmtimer_interrupt(int irq, void *dev_id, struct pt_regs *regs);
+
 /*
  * Period in femtoseconds (10^-15 s)
  */
@@ -70,6 +72,12 @@ static struct file_operations mmtimer_fo
 	.ioctl =	mmtimer_ioctl,
 };
 
+static struct irqaction mmt_irqaction = {
+	.handler =	mmtimer_interrupt,
+	.flags =	SA_INTERRUPT,
+	.name =		MMTIMER_NAME
+};
+
 /*
  * We only have comparison registers RTC1-4 currently available per
  * node.  RTC0 is used by SAL.
@@ -689,11 +697,7 @@ static int __init mmtimer_init(void)
 	mmtimer_femtoperiod = ((unsigned long)1E15 + sn_rtc_cycles_per_second /
 			       2) / sn_rtc_cycles_per_second;
 
-	if (request_irq(SGI_MMTIMER_VECTOR, mmtimer_interrupt, SA_PERCPU_IRQ, MMTIMER_NAME, NULL)) {
-		printk(KERN_WARNING "%s: unable to allocate interrupt.",
-			MMTIMER_NAME);
-		return -1;
-	}
+	register_percpu_irq(SGI_MMTIMER_VECTOR, &mmt_irqaction);
 
 	strcpy(mmtimer_miscdev.devfs_name, MMTIMER_NAME);
 	if (misc_register(&mmtimer_miscdev)) {
