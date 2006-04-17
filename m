From: Jesper Juhl <jesper.juhl@gmail.com>
Date: Mon, 17 Apr 2006 01:28:42 +0000
Subject: [PATCH 3/5] Remove redundant NULL checks before [kv]free - in  arch/
Message-Id: <200604170328.42599.jesper.juhl@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@osdl.org>, Erich Focht <efocht@ess.nec.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, eranian@hpl.hp.com, davidm@hpl.hp.com, Ben Herrenschmidt <benh@kernel.crashing.org>, paulus@samba.org, Jeff Dike <jdike@karaya.com>, user-mode-linux-devel@lists.sourceforge.net, Jan Engelhardt <jengelh@linux01.gwdg.de>, Jesper Juhl <jesper.juhl@gmail.com>

Remove redundant NULL checks before [kv]free + small CodingStyle cleanup
for arch/

Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
---

 arch/ia64/kernel/topology.c               |    7 --
 arch/ia64/sn/kernel/xpc_partition.c       |    8 --
 arch/powerpc/platforms/powermac/low_i2c.c |    3
 arch/um/kernel/irq.c                      |   93 +++++++++++++++----------=
-----
 arch/um/os-Linux/irq.c                    |   47 +++++++--------
 5 files changed, 74 insertions(+), 84 deletions(-)

diff -upr linux-2.6.17-rc1-git12-orig/arch/ia64/kernel/topology.c linux-2.6=
.17-rc1-git12/arch/ia64/kernel/topology.c
--- linux-2.6.17-rc1-git12-orig/arch/ia64/kernel/topology.c	2006-04-09 13:5=
8:12.000000000 +0200
+++ linux-2.6.17-rc1-git12/arch/ia64/kernel/topology.c	2006-04-16 15:18:24.=
000000000 +0200
@@ -305,13 +305,10 @@ static struct kobj_type cache_ktype_perc
=20
 static void __cpuinit cpu_cache_sysfs_exit(unsigned int cpu)
 {
-	if (all_cpu_cache_info[cpu].cache_leaves) {
-		kfree(all_cpu_cache_info[cpu].cache_leaves);
-		all_cpu_cache_info[cpu].cache_leaves =3D NULL;
-	}
+	kfree(all_cpu_cache_info[cpu].cache_leaves);
+	all_cpu_cache_info[cpu].cache_leaves =3D NULL;
 	all_cpu_cache_info[cpu].num_cache_leaves =3D 0;
 	memset(&all_cpu_cache_info[cpu].kobj, 0, sizeof(struct kobject));
-
 	return;
 }
=20
diff -upr linux-2.6.17-rc1-git12-orig/arch/ia64/sn/kernel/xpc_partition.c l=
inux-2.6.17-rc1-git12/arch/ia64/sn/kernel/xpc_partition.c
--- linux-2.6.17-rc1-git12-orig/arch/ia64/sn/kernel/xpc_partition.c	2006-04=
-09 13:58:12.000000000 +0200
+++ linux-2.6.17-rc1-git12/arch/ia64/sn/kernel/xpc_partition.c	2006-04-16 1=
5:17:38.000000000 +0200
@@ -136,9 +136,7 @@ xpc_get_rsvd_page_pa(int nasid)
 		}
=20
 		if (L1_CACHE_ALIGN(len) > buf_len) {
-			if (buf_base !=3D NULL) {
-				kfree(buf_base);
-			}
+			kfree(buf_base);
 			buf_len =3D L1_CACHE_ALIGN(len);
 			buf =3D (u64) xpc_kmalloc_cacheline_aligned(buf_len,
 							GFP_KERNEL, &buf_base);
@@ -159,9 +157,7 @@ xpc_get_rsvd_page_pa(int nasid)
 		}
 	}
=20
-	if (buf_base !=3D NULL) {
-		kfree(buf_base);
-	}
+	kfree(buf_base);
=20
 	if (status !=3D SALRET_OK) {
 		rp_pa =3D 0;
diff -upr linux-2.6.17-rc1-git12-orig/arch/powerpc/platforms/powermac/low_i=
2c.c linux-2.6.17-rc1-git12/arch/powerpc/platforms/powermac/low_i2c.c
--- linux-2.6.17-rc1-git12-orig/arch/powerpc/platforms/powermac/low_i2c.c	2=
006-04-09 13:58:12.000000000 +0200
+++ linux-2.6.17-rc1-git12/arch/powerpc/platforms/powermac/low_i2c.c	2006-0=
4-16 15:19:56.000000000 +0200
@@ -1265,8 +1265,7 @@ static void pmac_i2c_do_end(struct pmf_f
 	if (inst =3D NULL)
 		return;
 	pmac_i2c_close(inst->bus);
-	if (inst)
-		kfree(inst);
+	kfree(inst);
 }
=20
 static int pmac_i2c_do_read(PMF_STD_ARGS, u32 len)
diff -upr linux-2.6.17-rc1-git12-orig/arch/um/kernel/irq.c linux-2.6.17-rc1=
-git12/arch/um/kernel/irq.c
--- linux-2.6.17-rc1-git12-orig/arch/um/kernel/irq.c	2006-04-09 13:58:13.00=
0000000 +0200
+++ linux-2.6.17-rc1-git12/arch/um/kernel/irq.c	2006-04-17 02:34:38.0000000=
00 +0200
@@ -89,16 +89,18 @@ void sigio_handler(int sig, union uml_pt
 	struct irq_fd *irq_fd;
 	int n;
=20
-	if(smp_sigio_handler()) return;
-	while(1){
+	if (smp_sigio_handler())
+		return;
+
+	while (1) {
 		n =3D os_waiting_for_events(active_fds);
 		if (n <=3D 0) {
 			if(n =3D -EINTR) continue;
 			else break;
 		}
=20
-		for(irq_fd =3D active_fds; irq_fd !=3D NULL; irq_fd =3D irq_fd->next){
-			if(irq_fd->current_events !=3D 0){
+		for (irq_fd =3D active_fds; irq_fd !=3D NULL; irq_fd =3D irq_fd->next) {
+			if (irq_fd->current_events !=3D 0) {
 				irq_fd->current_events =3D 0;
 				do_IRQ(irq_fd->irq, regs);
 			}
@@ -110,19 +112,17 @@ void sigio_handler(int sig, union uml_pt
=20
 static void maybe_sigio_broken(int fd, int type)
 {
-	if(os_isatty(fd)){
-		if((type =3D IRQ_WRITE) && !pty_output_sigio){
+	if (os_isatty(fd)) {
+		if ((type =3D IRQ_WRITE) && !pty_output_sigio) {
 			write_sigio_workaround();
 			add_sigio_fd(fd, 0);
-		}
-		else if((type =3D IRQ_READ) && !pty_close_sigio){
+		} else if ((type =3D IRQ_READ) && !pty_close_sigio) {
 			write_sigio_workaround();
 			add_sigio_fd(fd, 1);
 		}
 	}
 }
=20
-
 int activate_fd(int irq, int fd, int type, void *dev_id)
 {
 	struct pollfd *tmp_pfd;
@@ -132,16 +132,18 @@ int activate_fd(int irq, int fd, int typ
=20
 	pid =3D os_getpid();
 	err =3D os_set_fd_async(fd, pid);
-	if(err < 0)
+	if (err < 0)
 		goto out;
=20
 	new_fd =3D um_kmalloc(sizeof(*new_fd));
 	err =3D -ENOMEM;
-	if(new_fd =3D NULL)
+	if (new_fd =3D NULL)
 		goto out;
=20
-	if(type =3D IRQ_READ) events =3D UM_POLLIN | UM_POLLPRI;
-	else events =3D UM_POLLOUT;
+	if (type =3D IRQ_READ)
+		events =3D UM_POLLIN | UM_POLLPRI;
+	else
+		events =3D UM_POLLOUT;
 	*new_fd =3D ((struct irq_fd) { .next  		=3D NULL,
 				     .id 		=3D dev_id,
 				     .fd 		=3D fd,
@@ -165,8 +167,8 @@ int activate_fd(int irq, int fd, int typ
 	 * a semaphore.
 	 */
 	flags =3D irq_lock();
-	for(irq_fd =3D active_fds; irq_fd !=3D NULL; irq_fd =3D irq_fd->next){
-		if((irq_fd->fd =3D fd) && (irq_fd->type =3D type)){
+	for (irq_fd =3D active_fds; irq_fd !=3D NULL; irq_fd =3D irq_fd->next) {
+		if ((irq_fd->fd =3D fd) && (irq_fd->type =3D type)) {
 			printk("Registering fd %d twice\n", fd);
 			printk("Irqs : %d, %d\n", irq_fd->irq, irq);
 			printk("Ids : 0x%p, 0x%p\n", irq_fd->id, dev_id);
@@ -175,13 +177,13 @@ int activate_fd(int irq, int fd, int typ
 	}
=20
 	/*-------------*/
-	if(type =3D IRQ_WRITE)
+	if (type =3D IRQ_WRITE)
 		fd =3D -1;
=20
 	tmp_pfd =3D NULL;
 	n =3D 0;
=20
-	while(1){
+	while (1) {
 		n =3D os_create_pollfd(fd, events, tmp_pfd, n);
 		if (n =3D 0)
 			break;
@@ -198,10 +200,8 @@ int activate_fd(int irq, int fd, int typ
 		 * then we free the buffer tmp_fds and try again.
 		 */
 		irq_unlock(flags);
-		if (tmp_pfd !=3D NULL) {
-			kfree(tmp_pfd);
-			tmp_pfd =3D NULL;
-		}
+		kfree(tmp_pfd);
+		tmp_pfd =3D NULL;
=20
 		tmp_pfd =3D um_kmalloc(n);
 		if (tmp_pfd =3D NULL)
@@ -249,7 +249,7 @@ static int same_irq_and_dev(struct irq_f
 {
 	struct irq_and_dev *data =3D d;
=20
-	return((irq->irq =3D data->irq) && (irq->id =3D data->dev));
+	return ((irq->irq =3D data->irq) && (irq->id =3D data->dev));
 }
=20
 void free_irq_by_irq_and_dev(unsigned int irq, void *dev)
@@ -262,7 +262,7 @@ void free_irq_by_irq_and_dev(unsigned in
=20
 static int same_fd(struct irq_fd *irq, void *fd)
 {
-	return(irq->fd =3D *((int *) fd));
+	return (irq->fd =3D *((int *)fd));
 }
=20
 void free_irq_by_fd(int fd)
@@ -276,16 +276,17 @@ static struct irq_fd *find_irq_by_fd(int
 	int i =3D 0;
 	int fdi;
=20
-	for(irq=ACtive_fds; irq !=3D NULL; irq =3D irq->next){
-		if((irq->fd =3D fd) && (irq->irq =3D irqnum)) break;
+	for (irq =3D active_fds; irq !=3D NULL; irq =3D irq->next) {
+		if ((irq->fd =3D fd) && (irq->irq =3D irqnum))
+			break;
 		i++;
 	}
-	if(irq =3D NULL){
+	if (irq =3D NULL) {
 		printk("find_irq_by_fd doesn't have descriptor %d\n", fd);
 		goto out;
 	}
 	fdi =3D os_get_pollfd(i);
-	if((fdi !=3D -1) && (fdi !=3D fd)){
+	if ((fdi !=3D -1) && (fdi !=3D fd)) {
 		printk("find_irq_by_fd - mismatch between active_fds and "
 		       "pollfds, fd %d vs %d, need %d\n", irq->fd,
 		       fdi, fd);
@@ -294,7 +295,7 @@ static struct irq_fd *find_irq_by_fd(int
 	}
 	*index_out =3D i;
  out:
-	return(irq);
+	return irq;
 }
=20
 void reactivate_fd(int fd, int irqnum)
@@ -305,7 +306,7 @@ void reactivate_fd(int fd, int irqnum)
=20
 	flags =3D irq_lock();
 	irq =3D find_irq_by_fd(fd, irqnum, &i);
-	if(irq =3D NULL){
+	if (irq =3D NULL) {
 		irq_unlock(flags);
 		return;
 	}
@@ -326,7 +327,7 @@ void deactivate_fd(int fd, int irqnum)
=20
 	flags =3D irq_lock();
 	irq =3D find_irq_by_fd(fd, irqnum, &i);
-	if(irq =3D NULL)
+	if (irq =3D NULL)
 		goto out;
 	os_set_pollfd(i, -1);
  out:
@@ -338,15 +339,15 @@ int deactivate_all_fds(void)
 	struct irq_fd *irq;
 	int err;
=20
-	for(irq=ACtive_fds;irq !=3D NULL;irq =3D irq->next){
+	for (irq =3D active_fds; irq !=3D NULL; irq =3D irq->next) {
 		err =3D os_clear_fd_async(irq->fd);
-		if(err)
-			return(err);
+		if (err)
+			return err;
 	}
 	/* If there is a signal already queued, after unblocking ignore it */
 	os_set_ioignore();
=20
-	return(0);
+	return 0;
 }
=20
 void forward_interrupts(int pid)
@@ -356,9 +357,9 @@ void forward_interrupts(int pid)
 	int err;
=20
 	flags =3D irq_lock();
-	for(irq=ACtive_fds;irq !=3D NULL;irq =3D irq->next){
+	for (irq =3D active_fds; irq !=3D NULL; irq =3D irq->next) {
 		err =3D os_set_owner(irq->fd, pid);
-		if(err < 0){
+		if (err < 0) {
 			/* XXX Just remove the irq rather than
 			 * print out an infinite stream of these
 			 */
@@ -379,7 +380,7 @@ void forward_interrupts(int pid)
 unsigned int do_IRQ(int irq, union uml_pt_regs *regs)
 {
        irq_enter();
-       __do_IRQ(irq, (struct pt_regs *) regs);
+       __do_IRQ(irq, (struct pt_regs *)regs);
        irq_exit();
        return 1;
 }
@@ -392,12 +393,12 @@ int um_request_irq(unsigned int irq, int
 	int err;
=20
 	err =3D request_irq(irq, handler, irqflags, devname, dev_id);
-	if(err)
-		return(err);
+	if (err)
+		return err;
=20
-	if(fd !=3D -1)
+	if (fd !=3D -1)
 		err =3D activate_fd(irq, fd, type, dev_id);
-	return(err);
+	return err;
 }
 EXPORT_SYMBOL(um_request_irq);
 EXPORT_SYMBOL(reactivate_fd);
@@ -409,7 +410,7 @@ unsigned long irq_lock(void)
 	unsigned long flags;
=20
 	spin_lock_irqsave(&irq_spinlock, flags);
-	return(flags);
+	return flags;
 }
=20
 void irq_unlock(unsigned long flags)
@@ -452,7 +453,7 @@ void __init init_IRQ(void)
 	irq_desc[TIMER_IRQ].depth =3D 1;
 	irq_desc[TIMER_IRQ].handler =3D &SIGVTALRM_irq_type;
 	enable_irq(TIMER_IRQ);
-	for(i=3D1;i<NR_IRQS;i++){
+	for (i =3D 1; i < NR_IRQS; i++) {
 		irq_desc[i].status =3D IRQ_DISABLED;
 		irq_desc[i].action =3D NULL;
 		irq_desc[i].depth =3D 1;
@@ -467,7 +468,7 @@ int init_aio_irq(int irq, char *name, ir
 	int fds[2], err;
=20
 	err =3D os_pipe(fds, 1, 1);
-	if(err){
+	if (err) {
 		printk("init_aio_irq - os_pipe failed, err =3D %d\n", -err);
 		goto out;
 	}
@@ -475,7 +476,7 @@ int init_aio_irq(int irq, char *name, ir
 	err =3D um_request_irq(irq, fds[0], IRQ_READ, handler,
 			     SA_INTERRUPT | SA_SAMPLE_RANDOM, name,
 			     (void *) (long) fds[0]);
-	if(err){
+	if (err) {
 		printk("init_aio_irq - : um_request_irq failed, err =3D %d\n",
 		       err);
 		goto out_close;
@@ -488,5 +489,5 @@ int init_aio_irq(int irq, char *name, ir
 	os_close_file(fds[0]);
 	os_close_file(fds[1]);
  out:
-	return(err);
+	return err;
 }
diff -upr linux-2.6.17-rc1-git12-orig/arch/um/os-Linux/irq.c linux-2.6.17-r=
c1-git12/arch/um/os-Linux/irq.c
--- linux-2.6.17-rc1-git12-orig/arch/um/os-Linux/irq.c	2006-04-09 13:58:13.=
000000000 +0200
+++ linux-2.6.17-rc1-git12/arch/um/os-Linux/irq.c	2006-04-17 02:42:13.00000=
0000 +0200
@@ -29,21 +29,21 @@ int os_waiting_for_events(struct irq_fd=20
 	int i, n, err;
=20
 	n =3D poll(pollfds, pollfds_num, 0);
-	if(n < 0){
+	if (n < 0) {
 		err =3D -errno;
-		if(errno !=3D EINTR)
+		if (errno !=3D EINTR)
 			printk("sigio_handler: os_waiting_for_events:"
 			       " poll returned %d, errno =3D %d\n", n, errno);
 		return err;
 	}
=20
-	if(n =3D 0)
+	if (n =3D 0)
 		return 0;
=20
 	irq_fd =3D active_fds;
=20
-	for(i =3D 0; i < pollfds_num; i++){
-		if(pollfds[i].revents !=3D 0){
+	for (i =3D 0; i < pollfds_num; i++) {
+		if (pollfds[i].revents !=3D 0) {
 			irq_fd->current_events =3D pollfds[i].revents;
 			pollfds[i].fd =3D -1;
 		}
@@ -54,7 +54,7 @@ int os_waiting_for_events(struct irq_fd=20
=20
 int os_isatty(int fd)
 {
-	return(isatty(fd));
+	return isatty(fd);
 }
=20
 int os_create_pollfd(int fd, int events, void *tmp_pfd, int size_tmpfds)
@@ -65,7 +65,7 @@ int os_create_pollfd(int fd, int events,
 			return((pollfds_size + 1) * sizeof(pollfds[0]));
 		}
=20
-		if(pollfds !=3D NULL){
+		if (pollfds !=3D NULL) {
 			memcpy(tmp_pfd, pollfds,
 			       sizeof(pollfds[0]) * pollfds_size);
 			/* remove old pollfds */
@@ -73,18 +73,15 @@ int os_create_pollfd(int fd, int events,
 		}
 		pollfds =3D tmp_pfd;
 		pollfds_size++;
-	} else {
-		/* remove not used tmp_pfd */
-		if (tmp_pfd !=3D NULL)
-			kfree(tmp_pfd);
-	}
+	} else
+		kfree(tmp_pfd);	/* remove not used tmp_pfd */
=20
-	pollfds[pollfds_num] =3D ((struct pollfd) { .fd 	=3D fd,
-						  .events 	=3D events,
-						  .revents 	=3D 0 });
+	pollfds[pollfds_num] =3D ((struct pollfd) { .fd		=3D fd,
+						  .events	=3D events,
+						  .revents	=3D 0 });
 	pollfds_num++;
=20
-	return(0);
+	return 0;
 }
=20
 void os_free_irq_by_cb(int (*test)(struct irq_fd *, void *), void *arg,
@@ -94,11 +91,11 @@ void os_free_irq_by_cb(int (*test)(struc
 	int i =3D 0;
=20
 	prev =3D &active_fds;
-	while(*prev !=3D NULL){
-		if((*test)(*prev, arg)){
+	while (*prev !=3D NULL) {
+		if ((*test)(*prev, arg)) {
 			struct irq_fd *old_fd =3D *prev;
-			if((pollfds[i].fd !=3D -1) &&
-			   (pollfds[i].fd !=3D (*prev)->fd)){
+			if ((pollfds[i].fd !=3D -1) &&
+			    (pollfds[i].fd !=3D (*prev)->fd)) {
 				printk("os_free_irq_by_cb - mismatch between "
 				       "active_fds and pollfds, fd %d vs %d\n",
 				       (*prev)->fd, pollfds[i].fd);
@@ -110,7 +107,6 @@ void os_free_irq_by_cb(int (*test)(struc
 			/* This moves the *whole* array after pollfds[i]
 			 * (though it doesn't spot as such)!
 			 */
-
 			memmove(&pollfds[i], &pollfds[i + 1],
 			       (pollfds_num - i) * sizeof(pollfds[0]));
 			if(*last_irq_ptr2 =3D &old_fd->next)
@@ -129,10 +125,9 @@ void os_free_irq_by_cb(int (*test)(struc
 	return;
 }
=20
-
 int os_get_pollfd(int i)
 {
-	return(pollfds[i].fd);
+	return pollfds[i].fd;
 }
=20
 void os_set_pollfd(int i, int fd)
@@ -151,8 +146,10 @@ void init_irq_signals(int on_sigstack)
 	int flags;
=20
 	flags =3D on_sigstack ? SA_ONSTACK : 0;
-	if(timer_irq_inited) h =3D (__sighandler_t) alarm_handler;
-	else h =3D boot_timer_handler;
+	if (timer_irq_inited)
+		h =3D (__sighandler_t)alarm_handler;
+	else
+		h =3D boot_timer_handler;
=20
 	set_handler(SIGVTALRM, h, flags | SA_RESTART,
 		    SIGUSR1, SIGIO, SIGWINCH, SIGALRM, -1);
