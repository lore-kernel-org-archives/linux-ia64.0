From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Wed, 23 Feb 2005 21:44:01 +0000
Subject: user-mode interrupt handling
Message-Id: <16924.63777.712927.18129@berry.gelato.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



For your delectation --- here's the stuff to be able to handle
interrupts from user space, for all architectures that use
GENERIC_HARDIRQS (which of course includes IA64).

I'm not expecting this to be included; it's just for comparison with the
ULI patch that Michael Raymond posted a pointer to.

The driver model we use with these, is that the user-mode driver  is
typically linked with its application, so it's natural to wait for an
interrupt then do something.  Congestion control under heavy interrupt
load then becomes fairly natural --- interrupts are ignored until the
last set of events have been processed.

This patch adds a new file to /proc/irq/<nnn>/ called irq.  Suitably 
privileged processes can open this file.  Reading the file returns the 
number of interrupts (if any) that have occurred since the last read.
If the file is opened in blocking mode, reading it blocks until 
an interrupt occurs.  poll(2) and select(2) work as one would expect, to 
allow interrupts to be one of many events to wait for.

Interrupts are usually masked; while a thread is in poll(2) or read(2) on the 
file they are unmasked.  

All architectures that use CONFIG_GENERIC_HARDIRQ are supported by this patch.


Index: linux-2.6.11-usrdrivers/kernel/irq/proc.c
=================================--- linux-2.6.11-usrdrivers.orig/kernel/irq/proc.c	2005-02-23 11:36:08.625016262 +1100
+++ linux-2.6.11-usrdrivers/kernel/irq/proc.c	2005-02-23 13:03:22.482291227 +1100
@@ -9,6 +9,7 @@
 #include <linux/irq.h>
 #include <linux/proc_fs.h>
 #include <linux/interrupt.h>
+#include <linux/poll.h>
 
 static struct proc_dir_entry *root_irq_dir, *irq_dir[NR_IRQS];
 
@@ -90,27 +91,162 @@
 	action->dir = proc_mkdir(name, irq_dir[irq]);
 }
 
+struct irq_proc {
+ 	int irq;
+ 	wait_queue_head_t q;
+ 	atomic_t count;
+ 	char devname[sizeof ((struct task_struct *) 0)->comm];
+};
+ 
+irqreturn_t irq_proc_irq_handler(int irq, void *vidp, struct pt_regs *regs)
+{
+ 	struct irq_proc *idp = (struct irq_proc *)vidp;
+ 
+ 	BUG_ON(idp->irq != irq);
+ 	disable_irq_nosync(irq);
+ 	atomic_inc(&idp->count);
+ 	wake_up(&idp->q);
+ 	return IRQ_HANDLED;
+}
+ 
+
+/*
+ * Signal to userspace an interrupt has occured.
+ */
+ssize_t irq_proc_read(struct file *fp, char *bufp, size_t len, loff_t *where)
+{
+ 	struct irq_proc *ip = (struct irq_proc *)fp->private_data;
+ 	irq_desc_t *idp = irq_desc + ip->irq;
+ 	int i;
+ 	int err;
+	
+ 	DEFINE_WAIT(wait);
+	
+ 	if (len < sizeof(int))
+ 		return -EINVAL;
+	
+ 	if ((i = atomic_read(&ip->count)) = 0) {
+ 		if (idp->status & IRQ_DISABLED)
+ 			enable_irq(ip->irq);
+ 		if (fp->f_flags & O_NONBLOCK)
+ 			return -EWOULDBLOCK;
+ 	}
+	
+ 	while (i = 0) {
+ 		prepare_to_wait(&ip->q, &wait, TASK_INTERRUPTIBLE);
+ 		if ((i = atomic_read(&ip->count)) = 0)
+ 			schedule();
+ 		finish_wait(&ip->q, &wait);
+ 		if (signal_pending(current))
+ 			return -ERESTARTSYS;
+ 	}
+	
+ 	if ((err = copy_to_user(bufp, &i, sizeof i)))
+ 		return err;
+ 	*where += sizeof i;
+	
+ 	atomic_sub(i, &ip->count);
+ 	return sizeof i;
+}
+
+
+int irq_proc_open(struct inode *inop, struct file *fp)
+{
+ 	struct irq_proc *ip;
+ 	struct proc_dir_entry *ent = PDE(inop);
+ 	int error;
+	
+ 	ip = kmalloc(sizeof *ip, GFP_KERNEL);
+ 	if (ip = NULL)
+ 		return -ENOMEM;
+	
+ 	memset(ip, 0, sizeof(*ip));
+ 	strcpy(ip->devname, current->comm);
+ 	init_waitqueue_head(&ip->q);
+ 	atomic_set(&ip->count, 0);
+ 	ip->irq = (int)(unsigned long)ent->data;
+	
+ 	if ((error = request_irq(ip->irq,
+ 				 irq_proc_irq_handler,
+ 				 SA_INTERRUPT,
+ 				 ip->devname,
+ 				 ip)) < 0) {
+ 		kfree(ip);
+ 		return error;
+ 	}
+ 	fp->private_data = (void *)ip;
+	
+ 	return 0;
+}
+
+int irq_proc_release(struct inode *inop, struct file *fp)
+{
+ 	struct irq_proc *ip = (struct irq_proc *)fp->private_data;
+ 	(void)inop;
+ 	free_irq(ip->irq, ip);
+ 	fp->private_data = NULL;
+ 	kfree(ip);
+ 	return 0;
+}
+
+unsigned int irq_proc_poll(struct file *fp, struct poll_table_struct *wait)
+{
+ 	struct irq_proc *ip = (struct irq_proc *)fp->private_data;
+ 	irq_desc_t *idp = irq_desc + ip->irq;
+	
+ 	poll_wait(fp, &ip->q, wait);
+	
+ 	/* if interrupts disabled and we don't have one to process */
+ 	if (idp->status & IRQ_DISABLED && atomic_read(&ip->count) = 0)
+ 		enable_irq(ip->irq);
+	
+ 	if (atomic_read(&ip->count) > 0)
+ 		return POLLIN | POLLRDNORM; /* readable */
+	
+ 	return 0;
+}
+
+struct file_operations irq_proc_file_operations = {
+ 	.read = irq_proc_read,
+ 	.open = irq_proc_open,
+ 	.release = irq_proc_release,
+ 	.poll = irq_proc_poll,
+};
+ 
 #undef MAX_NAMELEN
 
 #define MAX_NAMELEN 10
 
 void register_irq_proc(unsigned int irq)
 {
+	struct proc_dir_entry *entry;
 	char name [MAX_NAMELEN];
 
-	if (!root_irq_dir ||
-		(irq_desc[irq].handler = &no_irq_type) ||
-			irq_dir[irq])
+	if (!root_irq_dir)
 		return;
-
-	memset(name, 0, MAX_NAMELEN);
-	sprintf(name, "%d", irq);
-
-	/* create /proc/irq/1234 */
-	irq_dir[irq] = proc_mkdir(name, root_irq_dir);
+	
+	if (!irq_dir[irq]) {
+		memset(name, 0, MAX_NAMELEN);
+		sprintf(name, "%d", irq);
+
+		/* create /proc/irq/1234 */
+		irq_dir[irq] = proc_mkdir(name, root_irq_dir);
+
+		/* 
+		 * Create handles for user-mode interrupt handlers
+		 * if the kernel hasn't already grabbed the IRQ
+		 */
+ 		entry = create_proc_entry("irq", 0600, irq_dir[irq]);
+ 		if (entry) {
+ 			entry->data = (void *)(unsigned long)irq;
+ 			entry->read_proc = NULL;
+ 			entry->write_proc = NULL;
+ 			entry->proc_fops = &irq_proc_file_operations;
+ 		}
+	}
 
 #ifdef CONFIG_SMP
-	{
+	if (!smp_affinity_entry[irq]) {
 		struct proc_dir_entry *entry;
 
 		/* create /proc/irq/<irq>/smp_affinity */
@@ -118,7 +254,7 @@
 
 		if (entry) {
 			entry->nlink = 1;
-			entry->data = (void *)(long)irq;
+			entry->data = (void *)(unsigned long)irq;
 			entry->read_proc = irq_affinity_read_proc;
 			entry->write_proc = irq_affinity_write_proc;
 		}
