From: Christoph Hellwig <hch@infradead.org>
Date: Wed, 23 Feb 2005 23:39:43 +0000
Subject: Re: user-mode interrupt handling
Message-Id: <20050223233943.GA22458@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <16924.63777.712927.18129@berry.gelato.unsw.EDU.AU>
In-Reply-To: <16924.63777.712927.18129@berry.gelato.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Feb 24, 2005 at 08:44:01AM +1100, Peter Chubb wrote:
> 
> 
> For your delectation --- here's the stuff to be able to handle
> interrupts from user space, for all architectures that use
> GENERIC_HARDIRQS (which of course includes IA64).
> 
> I'm not expecting this to be included; it's just for comparison with the
> ULI patch that Michael Raymond posted a pointer to.
> 
> The driver model we use with these, is that the user-mode driver  is
> typically linked with its application, so it's natural to wait for an
> interrupt then do something.  Congestion control under heavy interrupt
> load then becomes fairly natural --- interrupts are ignored until the
> last set of events have been processed.
> 
> This patch adds a new file to /proc/irq/<nnn>/ called irq.  Suitably 
> privileged processes can open this file.  Reading the file returns the 
> number of interrupts (if any) that have occurred since the last read.
> If the file is opened in blocking mode, reading it blocks until 
> an interrupt occurs.  poll(2) and select(2) work as one would expect, to 
> allow interrupts to be one of many events to wait for.
> 
> Interrupts are usually masked; while a thread is in poll(2) or read(2) on the 
> file they are unmasked.  
> 
> All architectures that use CONFIG_GENERIC_HARDIRQ are supported by this patch.

This design looks about three magnitudes better than Michaels ;-)

I don't like the procfs-based interface a lot, but I can't come up with
a sane interface fastly.

> @@ -9,6 +9,7 @@
>  #include <linux/irq.h>
>  #include <linux/proc_fs.h>
>  #include <linux/interrupt.h>
> +#include <linux/poll.h>
>  
>  static struct proc_dir_entry *root_irq_dir, *irq_dir[NR_IRQS];
>  
> @@ -90,27 +91,162 @@
>  	action->dir = proc_mkdir(name, irq_dir[irq]);
>  }
>  
> +struct irq_proc {
> + 	int irq;
> + 	wait_queue_head_t q;
> + 	atomic_t count;
> + 	char devname[sizeof ((struct task_struct *) 0)->comm];

please use TASK_COMM_LEN instead.

> +irqreturn_t irq_proc_irq_handler(int irq, void *vidp, struct pt_regs *regs)

should be static (dito for most function you're introducing)

> +{
> + 	struct irq_proc *idp = (struct irq_proc *)vidp;

no need to cast

> + 
> + 	BUG_ON(idp->irq != irq);
> + 	disable_irq_nosync(irq);
> + 	atomic_inc(&idp->count);
> + 	wake_up(&idp->q);
> + 	return IRQ_HANDLED;
> +}
> + 
> +
> +/*
> + * Signal to userspace an interrupt has occured.
> + */
> +ssize_t irq_proc_read(struct file *fp, char *bufp, size_t len, loff_t *where)
> +{

bufp must be marked __user, please run sparse over your code.  Also we
tend to use file or filp as names for struct file * and the loff_t for
read routines is usually called ppos.  Following such idioms makes your
code much easier to read for kernel hackers.

> 
> + 	struct irq_proc *ip = (struct irq_proc *)fp->private_data;
> + 	irq_desc_t *idp = irq_desc + ip->irq;
> + 	int i;
> + 	int err;
> +	
> + 	DEFINE_WAIT(wait);
> +	
> + 	if (len < sizeof(int))
> + 		return -EINVAL;
> +	
> + 	if ((i = atomic_read(&ip->count)) = 0) {

strange variable naming and non-standard style, should read something
like:

	pending_count = atomic_read(&ip->count);
	if (!pending_count) {

> 
> + 		if (idp->status & IRQ_DISABLED)
> + 			enable_irq(ip->irq);
> + 		if (fp->f_flags & O_NONBLOCK)
> + 			return -EWOULDBLOCK;
> + 	}
> +	
> + 	while (i = 0) {
> + 		prepare_to_wait(&ip->q, &wait, TASK_INTERRUPTIBLE);
> + 		if ((i = atomic_read(&ip->count)) = 0)
> + 			schedule();
> + 		finish_wait(&ip->q, &wait);
> + 		if (signal_pending(current))
> + 			return -ERESTARTSYS;
> + 	}
> +	
> + 	if ((err = copy_to_user(bufp, &i, sizeof i)))
> + 		return err;

copy_to_user returns the number of sucessfully copied bytes on failure, so
this must look like:

 	if (copy_to_user(bufp, &i, sizeof(i)))
 		return -EFAULT;

> + 	*where += sizeof i;
> +	
> + 	atomic_sub(i, &ip->count);
> + 	return sizeof i;
> +}
> +

> +int irq_proc_open(struct inode *inop, struct file *fp)
> +{
> + 	struct irq_proc *ip;
> + 	struct proc_dir_entry *ent = PDE(inop);
> + 	int error;
> +	
> + 	ip = kmalloc(sizeof *ip, GFP_KERNEL);
> + 	if (ip = NULL)
> + 		return -ENOMEM;
> +	
> + 	memset(ip, 0, sizeof(*ip));
> + 	strcpy(ip->devname, current->comm);
> + 	init_waitqueue_head(&ip->q);
> + 	atomic_set(&ip->count, 0);
> + 	ip->irq = (int)(unsigned long)ent->data;

Why don't you just make ip->irq unsigned long?

> + 	if ((error = request_irq(ip->irq,
> + 				 irq_proc_irq_handler,
> + 				 SA_INTERRUPT,
> + 				 ip->devname,
> + 				 ip)) < 0) {
> + 		kfree(ip);
> + 		return error;
> + 	}

canoncial style would be:

	error = request_irq(ip->irq, irq_proc_irq_handler,
			SA_INTERRUPT, ip->devname, ip);
	if (error)
		goto out_kfree_ip;

> + 	fp->private_data = (void *)ip;

no need to cast.

> + 	(void)inop;

urgg, what the hell is this supposed to do?

