From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 20 Jan 2006 00:03:46 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200601200003.k0K03k7L016303@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

A few post-rc1 fixes and cleanups.  Please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/ia32/sys_ia32.c               |   28 ++----
 arch/ia64/kernel/perfmon.c              |   11 +-
 arch/ia64/kernel/uncached.c             |    1 
 arch/ia64/sn/include/xtalk/hubdev.h     |    9 ++
 arch/ia64/sn/kernel/io_init.c           |   54 ++++++++++++-
 arch/ia64/sn/kernel/mca.c               |    7 -
 arch/ia64/sn/kernel/xp_main.c           |   17 ++--
 arch/ia64/sn/kernel/xpc_channel.c       |   34 +++-----
 arch/ia64/sn/kernel/xpc_main.c          |   17 ++--
 arch/ia64/sn/pci/pcibr/pcibr_provider.c |   12 +-
 drivers/serial/sn_console.c             |  129 ++++++++++++++------------------
 include/asm-ia64/semaphore.h            |    8 -
 include/asm-ia64/sn/xp.h                |    3 
 include/asm-ia64/sn/xpc.h               |    9 +-
 include/asm-ia64/topology.h             |    4 
 15 files changed, 196 insertions(+), 147 deletions(-)

Jack Steiner:
      [IA64] Zonelists for nodes without cpus

Jes Sorensen:
      [IA64-SGI] sn2 mutex conversion
      [IA64-SGI] sn_console.c minor cleanup
      [IA64] sem2mutex: arch/ia64/ia32/sys_ia32.c
      [IA64] sem2mutex: arch/ia64/kernel/perfmon.c

John Hawkes:
      [IA64] eliminate softlockup warning

Mike Habeck:
      [IA64-SGI] pass segment# on SN_SAL_IOIF_SLOT_{DIS,EN}ABLE calls

Prarit Bhargava:
      [IA64-SGI] Older PROM WAR for device flush code

Zoltan Menyhart:
      [IA64] Fix bug in ia64 specific down() function

diff-tree 386d1d50c8eef254653b1015fde06622ef38ba76 (from 60f1c4443c4d391d8dfbe709f13296067b6c8021)
Author: John Hawkes <hawkes@sgi.com>
Date:   Wed Jan 18 23:46:53 2006 -0800

    [IA64] eliminate softlockup warning
    
    Fix an unnecessary softlockup watchdog warning in the ia64
    uncached_build_memmap() that occurs occasionally at 256p and always at
    512p.  The problem occurs at boot time.
    
    Signed-off-by: John Hawkes <hawkes@sgi.com>
    Signed-off-by: Andrew Morton <akpm@osdl.org>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/uncached.c b/arch/ia64/kernel/uncached.c
index b631cf8..fcd2bad 100644
--- a/arch/ia64/kernel/uncached.c
+++ b/arch/ia64/kernel/uncached.c
@@ -210,6 +210,7 @@ uncached_build_memmap(unsigned long star
 
 	dprintk(KERN_ERR "uncached_build_memmap(%lx %lx)\n", start, end);
 
+	touch_softlockup_watchdog();
 	memset((char *)start, 0, length);
 
 	node = paddr_to_nid(start - __IA64_UNCACHED_OFFSET);

diff-tree 60f1c4443c4d391d8dfbe709f13296067b6c8021 (from 92ff2ecd0deddc4c5fb2140d5861d0ddd50e9e57)
Author: Jes Sorensen <jes@sgi.com>
Date:   Wed Jan 18 23:46:52 2006 -0800

    [IA64] sem2mutex: arch/ia64/kernel/perfmon.c
    
    Migrate perfmon from using an old semaphore to a completion handler.
    
    Signed-off-by: Jes Sorensen <jes@sgi.com>
    Signed-off-by: Ingo Molnar <mingo@elte.hu>
    Signed-off-by: Andrew Morton <akpm@osdl.org>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index 2ea4b39..9c5194b 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -40,6 +40,7 @@
 #include <linux/bitops.h>
 #include <linux/capability.h>
 #include <linux/rcupdate.h>
+#include <linux/completion.h>
 
 #include <asm/errno.h>
 #include <asm/intrinsics.h>
@@ -286,7 +287,7 @@ typedef struct pfm_context {
 
 	unsigned long		ctx_ovfl_regs[4];	/* which registers overflowed (notification) */
 
-	struct semaphore	ctx_restart_sem;   	/* use for blocking notification mode */
+	struct completion	ctx_restart_done;  	/* use for blocking notification mode */
 
 	unsigned long		ctx_used_pmds[4];	/* bitmask of PMD used            */
 	unsigned long		ctx_all_pmds[4];	/* bitmask of all accessible PMDs */
@@ -1991,7 +1992,7 @@ pfm_close(struct inode *inode, struct fi
 		/*
 		 * force task to wake up from MASKED state
 		 */
-		up(&ctx->ctx_restart_sem);
+		complete(&ctx->ctx_restart_done);
 
 		DPRINT(("waking up ctx_state=%d\n", state));
 
@@ -2706,7 +2707,7 @@ pfm_context_create(pfm_context_t *ctx, v
 	/*
 	 * init restart semaphore to locked
 	 */
-	sema_init(&ctx->ctx_restart_sem, 0);
+	init_completion(&ctx->ctx_restart_done);
 
 	/*
 	 * activation is used in SMP only
@@ -3687,7 +3688,7 @@ pfm_restart(pfm_context_t *ctx, void *ar
 	 */
 	if (CTX_OVFL_NOBLOCK(ctx) = 0 && state = PFM_CTX_MASKED) {
 		DPRINT(("unblocking [%d] \n", task->pid));
-		up(&ctx->ctx_restart_sem);
+		complete(&ctx->ctx_restart_done);
 	} else {
 		DPRINT(("[%d] armed exit trap\n", task->pid));
 
@@ -5089,7 +5090,7 @@ pfm_handle_work(void)
 	 * may go through without blocking on SMP systems
 	 * if restart has been received already by the time we call down()
 	 */
-	ret = down_interruptible(&ctx->ctx_restart_sem);
+	ret = wait_for_completion_interruptible(&ctx->ctx_restart_done);
 
 	DPRINT(("after block sleeping ret=%d\n", ret));
 

diff-tree 92ff2ecd0deddc4c5fb2140d5861d0ddd50e9e57 (from 4b16bfbf8f8013fefb49592d030ff87651ab48cb)
Author: Jes Sorensen <jes@sgi.com>
Date:   Wed Jan 18 23:46:51 2006 -0800

    [IA64] sem2mutex: arch/ia64/ia32/sys_ia32.c
    
    Migrate arch/ia64/ia32/sys_ia32 to using a mutex for mmap protection.
    
    Signed-off-by: Jes Sorensen <jes@sgi.com>
    Signed-off-by: Ingo Molnar <mingo@elte.hu>
    Signed-off-by: Andrew Morton <akpm@osdl.org>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/ia32/sys_ia32.c b/arch/ia64/ia32/sys_ia32.c
index 3945d37..70dba1f 100644
--- a/arch/ia64/ia32/sys_ia32.c
+++ b/arch/ia64/ia32/sys_ia32.c
@@ -52,9 +52,9 @@
 #include <linux/compat.h>
 #include <linux/vfs.h>
 #include <linux/mman.h>
+#include <linux/mutex.h>
 
 #include <asm/intrinsics.h>
-#include <asm/semaphore.h>
 #include <asm/types.h>
 #include <asm/uaccess.h>
 #include <asm/unistd.h>
@@ -86,7 +86,7 @@
  * while doing so.
  */
 /* XXX make per-mm: */
-static DECLARE_MUTEX(ia32_mmap_sem);
+static DEFINE_MUTEX(ia32_mmap_mutex);
 
 asmlinkage long
 sys32_execve (char __user *name, compat_uptr_t __user *argv, compat_uptr_t __user *envp,
@@ -895,11 +895,11 @@ ia32_do_mmap (struct file *file, unsigne
 	prot = get_prot32(prot);
 
 #if PAGE_SHIFT > IA32_PAGE_SHIFT
-	down(&ia32_mmap_sem);
+	mutex_lock(&ia32_mmap_mutex);
 	{
 		addr = emulate_mmap(file, addr, len, prot, flags, offset);
 	}
-	up(&ia32_mmap_sem);
+	mutex_unlock(&ia32_mmap_mutex);
 #else
 	down_write(&current->mm->mmap_sem);
 	{
@@ -1000,11 +1000,9 @@ sys32_munmap (unsigned int start, unsign
 	if (start >= end)
 		return 0;
 
-	down(&ia32_mmap_sem);
-	{
-		ret = sys_munmap(start, end - start);
-	}
-	up(&ia32_mmap_sem);
+	mutex_lock(&ia32_mmap_mutex);
+	ret = sys_munmap(start, end - start);
+	mutex_unlock(&ia32_mmap_mutex);
 #endif
 	return ret;
 }
@@ -1056,7 +1054,7 @@ sys32_mprotect (unsigned int start, unsi
 	if (retval < 0)
 		return retval;
 
-	down(&ia32_mmap_sem);
+	mutex_lock(&ia32_mmap_mutex);
 	{
 		if (offset_in_page(start)) {
 			/* start address is 4KB aligned but not page aligned. */
@@ -1080,7 +1078,7 @@ sys32_mprotect (unsigned int start, unsi
 		retval = sys_mprotect(start, end - start, prot);
 	}
   out:
-	up(&ia32_mmap_sem);
+	mutex_unlock(&ia32_mmap_mutex);
 	return retval;
 #endif
 }
@@ -1124,11 +1122,9 @@ sys32_mremap (unsigned int addr, unsigne
 	old_len = PAGE_ALIGN(old_end) - addr;
 	new_len = PAGE_ALIGN(new_end) - addr;
 
-	down(&ia32_mmap_sem);
-	{
-		ret = sys_mremap(addr, old_len, new_len, flags, new_addr);
-	}
-	up(&ia32_mmap_sem);
+	mutex_lock(&ia32_mmap_mutex);
+	ret = sys_mremap(addr, old_len, new_len, flags, new_addr);
+	mutex_unlock(&ia32_mmap_mutex);
 
 	if ((ret >= 0) && (old_len < new_len)) {
 		/* mremap expanded successfully */

diff-tree 4b16bfbf8f8013fefb49592d030ff87651ab48cb (from 8d08aed8d7714683b33666cc066e20f957dda01d)
Author: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date:   Fri Jan 13 17:25:23 2006 +0100

    [IA64] Fix bug in ia64 specific down() function
    
    Chen, Kenneth W wrote:
    > The memory order semantics for include/asm-ia64/semaphore.h:down()
    > doesn't look right.  It is using atomic_dec_return, which eventually
    > translate into ia64_fetch_and_add() that uses release semantics.
    > Shouldn't it use acquire semantics?
    
    Use ia64_fetchadd() instead of atomic_dec_return()
    
    Acked-by: Ken Chen <kenneth.w.chen@intel.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/include/asm-ia64/semaphore.h b/include/asm-ia64/semaphore.h
index bb89062..f483eeb 100644
--- a/include/asm-ia64/semaphore.h
+++ b/include/asm-ia64/semaphore.h
@@ -61,7 +61,7 @@ static inline void
 down (struct semaphore *sem)
 {
 	might_sleep();
-	if (atomic_dec_return(&sem->count) < 0)
+	if (ia64_fetchadd(-1, &sem->count.counter, acq) < 1)
 		__down(sem);
 }
 
@@ -75,7 +75,7 @@ down_interruptible (struct semaphore * s
 	int ret = 0;
 
 	might_sleep();
-	if (atomic_dec_return(&sem->count) < 0)
+	if (ia64_fetchadd(-1, &sem->count.counter, acq) < 1)
 		ret = __down_interruptible(sem);
 	return ret;
 }
@@ -85,7 +85,7 @@ down_trylock (struct semaphore *sem)
 {
 	int ret = 0;
 
-	if (atomic_dec_return(&sem->count) < 0)
+	if (ia64_fetchadd(-1, &sem->count.counter, acq) < 1)
 		ret = __down_trylock(sem);
 	return ret;
 }
@@ -93,7 +93,7 @@ down_trylock (struct semaphore *sem)
 static inline void
 up (struct semaphore * sem)
 {
-	if (atomic_inc_return(&sem->count) <= 0)
+	if (ia64_fetchadd(1, &sem->count.counter, rel) <= -1)
 		__up(sem);
 }
 

diff-tree 8d08aed8d7714683b33666cc066e20f957dda01d (from d171e519da635a82ab759cbfd46617ac160c9ec0)
Author: Jack Steiner <steiner@sgi.com>
Date:   Tue Jan 17 15:42:46 2006 -0600

    [IA64] Zonelists for nodes without cpus
    
    If a node runs out of memory, ensure that memory on nodes w/o cpus is used
    before using memory on nodes with cpus.
    
    Signed-off-by: Jack Steiner <steiner@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/include/asm-ia64/topology.h b/include/asm-ia64/topology.h
index d8aae4d..412ef8e 100644
--- a/include/asm-ia64/topology.h
+++ b/include/asm-ia64/topology.h
@@ -18,6 +18,10 @@
 #include <asm/smp.h>
 
 #ifdef CONFIG_NUMA
+
+/* Nodes w/o CPUs are preferred for memory allocations, see build_zonelists */
+#define PENALTY_FOR_NODE_WITH_CPUS 255
+
 /*
  * Returns the number of the node containing CPU 'cpu'
  */

diff-tree d171e519da635a82ab759cbfd46617ac160c9ec0 (from f9e505a9a03df5acace6e758c8d12982635a1c64)
Author: Jes Sorensen <jes@sgi.com>
Date:   Tue Jan 17 13:05:12 2006 -0500

    [IA64-SGI] sn_console.c minor cleanup
    
    Fix printk level and remove unnecessary CONFIG_SMP|CONFIG_PREEMPT tests
    as this is taken care through the spinlock macros anyway.
    
    Signed-off-by: Jes Sorensen <jes@sgi.com>
    Signed-off-by: Pat Gefre <pfg@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/drivers/serial/sn_console.c b/drivers/serial/sn_console.c
index 5468e5a..43e67d6 100644
--- a/drivers/serial/sn_console.c
+++ b/drivers/serial/sn_console.c
@@ -6,7 +6,7 @@
  * driver for that.
  *
  *
- * Copyright (c) 2004-2005 Silicon Graphics, Inc.  All Rights Reserved.
+ * Copyright (c) 2004-2006 Silicon Graphics, Inc.  All Rights Reserved.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of version 2 of the GNU General Public License
@@ -829,8 +829,8 @@ static int __init sn_sal_module_init(voi
 		misc.name = DEVICE_NAME_DYNAMIC;
 		retval = misc_register(&misc);
 		if (retval != 0) {
-			printk
-			    ("Failed to register console device using misc_register.\n");
+			printk(KERN_WARNING "Failed to register console "
+			       "device using misc_register.\n");
 			return -ENODEV;
 		}
 		sal_console_uart.major = MISC_MAJOR;
@@ -942,88 +942,75 @@ sn_sal_console_write(struct console *co,
 {
 	unsigned long flags = 0;
 	struct sn_cons_port *port = &sal_console_port;
-#if defined(CONFIG_SMP) || defined(CONFIG_PREEMPT)
 	static int stole_lock = 0;
-#endif
 
 	BUG_ON(!port->sc_is_asynch);
 
 	/* We can't look at the xmit buffer if we're not registered with serial core
 	 *  yet.  So only do the fancy recovery after registering
 	 */
-	if (port->sc_port.info) {
-
-		/* somebody really wants this output, might be an
-		 * oops, kdb, panic, etc.  make sure they get it. */
-#if defined(CONFIG_SMP) || defined(CONFIG_PREEMPT)
-		if (spin_is_locked(&port->sc_port.lock)) {
-			int lhead = port->sc_port.info->xmit.head;
-			int ltail = port->sc_port.info->xmit.tail;
-			int counter, got_lock = 0;
+	if (!port->sc_port.info) {
+		/* Not yet registered with serial core - simple case */
+		puts_raw_fixed(port->sc_ops->sal_puts_raw, s, count);
+		return;
+	}
 
-			/*
-			 * We attempt to determine if someone has died with the
-			 * lock. We wait ~20 secs after the head and tail ptrs
-			 * stop moving and assume the lock holder is not functional
-			 * and plow ahead. If the lock is freed within the time out
-			 * period we re-get the lock and go ahead normally. We also
-			 * remember if we have plowed ahead so that we don't have
-			 * to wait out the time out period again - the asumption
-			 * is that we will time out again.
-			 */
+	/* somebody really wants this output, might be an
+	 * oops, kdb, panic, etc.  make sure they get it. */
+	if (spin_is_locked(&port->sc_port.lock)) {
+		int lhead = port->sc_port.info->xmit.head;
+		int ltail = port->sc_port.info->xmit.tail;
+		int counter, got_lock = 0;
+
+		/*
+		 * We attempt to determine if someone has died with the
+		 * lock. We wait ~20 secs after the head and tail ptrs
+		 * stop moving and assume the lock holder is not functional
+		 * and plow ahead. If the lock is freed within the time out
+		 * period we re-get the lock and go ahead normally. We also
+		 * remember if we have plowed ahead so that we don't have
+		 * to wait out the time out period again - the asumption
+		 * is that we will time out again.
+		 */
 
-			for (counter = 0; counter < 150; mdelay(125), counter++) {
-				if (!spin_is_locked(&port->sc_port.lock)
-				    || stole_lock) {
-					if (!stole_lock) {
-						spin_lock_irqsave(&port->
-								  sc_port.lock,
-								  flags);
-						got_lock = 1;
-					}
-					break;
-				} else {
-					/* still locked */
-					if ((lhead !-					     port->sc_port.info->xmit.head)
-					    || (ltail !-						port->sc_port.info->xmit.
-						tail)) {
-						lhead -						    port->sc_port.info->xmit.
-						    head;
-						ltail -						    port->sc_port.info->xmit.
-						    tail;
-						counter = 0;
-					}
+		for (counter = 0; counter < 150; mdelay(125), counter++) {
+			if (!spin_is_locked(&port->sc_port.lock)
+			    || stole_lock) {
+				if (!stole_lock) {
+					spin_lock_irqsave(&port->sc_port.lock,
+							  flags);
+					got_lock = 1;
 				}
-			}
-			/* flush anything in the serial core xmit buffer, raw */
-			sn_transmit_chars(port, 1);
-			if (got_lock) {
-				spin_unlock_irqrestore(&port->sc_port.lock,
-						       flags);
-				stole_lock = 0;
+				break;
 			} else {
-				/* fell thru */
-				stole_lock = 1;
+				/* still locked */
+				if ((lhead != port->sc_port.info->xmit.head)
+				    || (ltail !+					port->sc_port.info->xmit.tail)) {
+					lhead +						port->sc_port.info->xmit.head;
+					ltail +						port->sc_port.info->xmit.tail;
+					counter = 0;
+				}
 			}
-			puts_raw_fixed(port->sc_ops->sal_puts_raw, s, count);
-		} else {
-			stole_lock = 0;
-#endif
-			spin_lock_irqsave(&port->sc_port.lock, flags);
-			sn_transmit_chars(port, 1);
+		}
+		/* flush anything in the serial core xmit buffer, raw */
+		sn_transmit_chars(port, 1);
+		if (got_lock) {
 			spin_unlock_irqrestore(&port->sc_port.lock, flags);
-
-			puts_raw_fixed(port->sc_ops->sal_puts_raw, s, count);
-#if defined(CONFIG_SMP) || defined(CONFIG_PREEMPT)
+			stole_lock = 0;
+		} else {
+			/* fell thru */
+			stole_lock = 1;
 		}
-#endif
-	}
-	else {
-		/* Not yet registered with serial core - simple case */
+		puts_raw_fixed(port->sc_ops->sal_puts_raw, s, count);
+	} else {
+		stole_lock = 0;
+		spin_lock_irqsave(&port->sc_port.lock, flags);
+		sn_transmit_chars(port, 1);
+		spin_unlock_irqrestore(&port->sc_port.lock, flags);
+
 		puts_raw_fixed(port->sc_ops->sal_puts_raw, s, count);
 	}
 }

diff-tree f9e505a9a03df5acace6e758c8d12982635a1c64 (from ac354a899b91239aac4d5893fc4288bc400e82b4)
Author: Jes Sorensen <jes@sgi.com>
Date:   Tue Jan 17 12:52:21 2006 -0500

    [IA64-SGI] sn2 mutex conversion
    
    Migrate sn2 code to use mutex and completion events rather than
    semaphores.
    
    Signed-off-by: Jes Sorensen <jes@sgi.com>
    Acked-by: Dean Nelson <dcn@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/sn/kernel/mca.c b/arch/ia64/sn/kernel/mca.c
index 6546db6..9ab684d 100644
--- a/arch/ia64/sn/kernel/mca.c
+++ b/arch/ia64/sn/kernel/mca.c
@@ -10,6 +10,7 @@
 #include <linux/kernel.h>
 #include <linux/timer.h>
 #include <linux/vmalloc.h>
+#include <linux/mutex.h>
 #include <asm/mca.h>
 #include <asm/sal.h>
 #include <asm/sn/sn_sal.h>
@@ -27,7 +28,7 @@ void sn_init_cpei_timer(void);
 /* Printing oemdata from mca uses data that is not passed through SAL, it is
  * global.  Only one user at a time.
  */
-static DECLARE_MUTEX(sn_oemdata_mutex);
+static DEFINE_MUTEX(sn_oemdata_mutex);
 static u8 **sn_oemdata;
 static u64 *sn_oemdata_size, sn_oemdata_bufsize;
 
@@ -89,7 +90,7 @@ static int
 sn_platform_plat_specific_err_print(const u8 * sect_header, u8 ** oemdata,
 				    u64 * oemdata_size)
 {
-	down(&sn_oemdata_mutex);
+	mutex_lock(&sn_oemdata_mutex);
 	sn_oemdata = oemdata;
 	sn_oemdata_size = oemdata_size;
 	sn_oemdata_bufsize = 0;
@@ -107,7 +108,7 @@ sn_platform_plat_specific_err_print(cons
 		*sn_oemdata_size = 0;
 		ia64_sn_plat_specific_err_print(print_hook, (char *)sect_header);
 	}
-	up(&sn_oemdata_mutex);
+	mutex_unlock(&sn_oemdata_mutex);
 	return 0;
 }
 
diff --git a/arch/ia64/sn/kernel/xp_main.c b/arch/ia64/sn/kernel/xp_main.c
index 3be52a3..b7ea466 100644
--- a/arch/ia64/sn/kernel/xp_main.c
+++ b/arch/ia64/sn/kernel/xp_main.c
@@ -19,6 +19,7 @@
 #include <linux/kernel.h>
 #include <linux/interrupt.h>
 #include <linux/module.h>
+#include <linux/mutex.h>
 #include <asm/sn/intr.h>
 #include <asm/sn/sn_sal.h>
 #include <asm/sn/xp.h>
@@ -136,13 +137,13 @@ xpc_connect(int ch_number, xpc_channel_f
 
 	registration = &xpc_registrations[ch_number];
 
-	if (down_interruptible(&registration->sema) != 0) {
+	if (mutex_lock_interruptible(&registration->mutex) != 0) {
 		return xpcInterrupted;
 	}
 
 	/* if XPC_CHANNEL_REGISTERED(ch_number) */
 	if (registration->func != NULL) {
-		up(&registration->sema);
+		mutex_unlock(&registration->mutex);
 		return xpcAlreadyRegistered;
 	}
 
@@ -154,7 +155,7 @@ xpc_connect(int ch_number, xpc_channel_f
 	registration->key = key;
 	registration->func = func;
 
-	up(&registration->sema);
+	mutex_unlock(&registration->mutex);
 
 	xpc_interface.connect(ch_number);
 
@@ -190,11 +191,11 @@ xpc_disconnect(int ch_number)
 	 * figured XPC's users will just turn around and call xpc_disconnect()
 	 * again anyways, so we might as well wait, if need be.
 	 */
-	down(&registration->sema);
+	mutex_lock(&registration->mutex);
 
 	/* if !XPC_CHANNEL_REGISTERED(ch_number) */
 	if (registration->func = NULL) {
-		up(&registration->sema);
+		mutex_unlock(&registration->mutex);
 		return;
 	}
 
@@ -208,7 +209,7 @@ xpc_disconnect(int ch_number)
 
 	xpc_interface.disconnect(ch_number);
 
-	up(&registration->sema);
+	mutex_unlock(&registration->mutex);
 
 	return;
 }
@@ -250,9 +251,9 @@ xp_init(void)
 		xp_nofault_PIOR_target = SH1_IPI_ACCESS;
 	}
 
-	/* initialize the connection registration semaphores */
+	/* initialize the connection registration mutex */
 	for (ch_number = 0; ch_number < XPC_NCHANNELS; ch_number++) {
-		sema_init(&xpc_registrations[ch_number].sema, 1);  /* mutex */
+		mutex_init(&xpc_registrations[ch_number].mutex);
 	}
 
 	return 0;
diff --git a/arch/ia64/sn/kernel/xpc_channel.c b/arch/ia64/sn/kernel/xpc_channel.c
index 0c0a689..8d950c7 100644
--- a/arch/ia64/sn/kernel/xpc_channel.c
+++ b/arch/ia64/sn/kernel/xpc_channel.c
@@ -22,6 +22,8 @@
 #include <linux/cache.h>
 #include <linux/interrupt.h>
 #include <linux/slab.h>
+#include <linux/mutex.h>
+#include <linux/completion.h>
 #include <asm/sn/bte.h>
 #include <asm/sn/sn_sal.h>
 #include <asm/sn/xpc.h>
@@ -56,8 +58,8 @@ xpc_initialize_channels(struct xpc_parti
 		atomic_set(&ch->n_to_notify, 0);
 
 		spin_lock_init(&ch->lock);
-		sema_init(&ch->msg_to_pull_sema, 1);	/* mutex */
-		sema_init(&ch->wdisconnect_sema, 0);	/* event wait */
+		mutex_init(&ch->msg_to_pull_mutex);
+		init_completion(&ch->wdisconnect_wait);
 
 		atomic_set(&ch->n_on_msg_allocate_wq, 0);
 		init_waitqueue_head(&ch->msg_allocate_wq);
@@ -534,7 +536,6 @@ static enum xpc_retval
 xpc_allocate_msgqueues(struct xpc_channel *ch)
 {
 	unsigned long irq_flags;
-	int i;
 	enum xpc_retval ret;
 
 
@@ -552,11 +553,6 @@ xpc_allocate_msgqueues(struct xpc_channe
 		return ret;
 	}
 
-	for (i = 0; i < ch->local_nentries; i++) {
-		/* use a semaphore as an event wait queue */
-		sema_init(&ch->notify_queue[i].sema, 0);
-	}
-
 	spin_lock_irqsave(&ch->lock, irq_flags);
 	ch->flags |= XPC_C_SETUP;
 	spin_unlock_irqrestore(&ch->lock, irq_flags);
@@ -799,10 +795,8 @@ xpc_process_disconnect(struct xpc_channe
 	}
 
 	if (ch->flags & XPC_C_WDISCONNECT) {
-		spin_unlock_irqrestore(&ch->lock, *irq_flags);
-		up(&ch->wdisconnect_sema);
-		spin_lock_irqsave(&ch->lock, *irq_flags);
-
+		/* we won't lose the CPU since we're holding ch->lock */
+		complete(&ch->wdisconnect_wait);
 	} else if (ch->delayed_IPI_flags) {
 		if (part->act_state != XPC_P_DEACTIVATING) {
 			/* time to take action on any delayed IPI flags */
@@ -1092,12 +1086,12 @@ xpc_connect_channel(struct xpc_channel *
 	struct xpc_registration *registration = &xpc_registrations[ch->number];
 
 
-	if (down_trylock(&registration->sema) != 0) {
+	if (mutex_trylock(&registration->mutex) = 0) {
 		return xpcRetry;
 	}
 
 	if (!XPC_CHANNEL_REGISTERED(ch->number)) {
-		up(&registration->sema);
+		mutex_unlock(&registration->mutex);
 		return xpcUnregistered;
 	}
 
@@ -1108,7 +1102,7 @@ xpc_connect_channel(struct xpc_channel *
 
 	if (ch->flags & XPC_C_DISCONNECTING) {
 		spin_unlock_irqrestore(&ch->lock, irq_flags);
-		up(&registration->sema);
+		mutex_unlock(&registration->mutex);
 		return ch->reason;
 	}
 
@@ -1140,7 +1134,7 @@ xpc_connect_channel(struct xpc_channel *
 			 * channel lock be locked and will unlock and relock
 			 * the channel lock as needed.
 			 */
-			up(&registration->sema);
+			mutex_unlock(&registration->mutex);
 			XPC_DISCONNECT_CHANNEL(ch, xpcUnequalMsgSizes,
 								&irq_flags);
 			spin_unlock_irqrestore(&ch->lock, irq_flags);
@@ -1155,7 +1149,7 @@ xpc_connect_channel(struct xpc_channel *
 		atomic_inc(&xpc_partitions[ch->partid].nchannels_active);
 	}
 
-	up(&registration->sema);
+	mutex_unlock(&registration->mutex);
 
 
 	/* initiate the connection */
@@ -2089,7 +2083,7 @@ xpc_pull_remote_msg(struct xpc_channel *
 	enum xpc_retval ret;
 
 
-	if (down_interruptible(&ch->msg_to_pull_sema) != 0) {
+	if (mutex_lock_interruptible(&ch->msg_to_pull_mutex) != 0) {
 		/* we were interrupted by a signal */
 		return NULL;
 	}
@@ -2125,7 +2119,7 @@ xpc_pull_remote_msg(struct xpc_channel *
 
 			XPC_DEACTIVATE_PARTITION(part, ret);
 
-			up(&ch->msg_to_pull_sema);
+			mutex_unlock(&ch->msg_to_pull_mutex);
 			return NULL;
 		}
 
@@ -2134,7 +2128,7 @@ xpc_pull_remote_msg(struct xpc_channel *
 		ch->next_msg_to_pull += nmsgs;
 	}
 
-	up(&ch->msg_to_pull_sema);
+	mutex_unlock(&ch->msg_to_pull_mutex);
 
 	/* return the message we were looking for */
 	msg_offset = (get % ch->remote_nentries) * ch->msg_size;
diff --git a/arch/ia64/sn/kernel/xpc_main.c b/arch/ia64/sn/kernel/xpc_main.c
index 8930586..c75f8ae 100644
--- a/arch/ia64/sn/kernel/xpc_main.c
+++ b/arch/ia64/sn/kernel/xpc_main.c
@@ -55,6 +55,7 @@
 #include <linux/slab.h>
 #include <linux/delay.h>
 #include <linux/reboot.h>
+#include <linux/completion.h>
 #include <asm/sn/intr.h>
 #include <asm/sn/sn_sal.h>
 #include <asm/kdebug.h>
@@ -177,10 +178,10 @@ static DECLARE_WAIT_QUEUE_HEAD(xpc_act_I
 static unsigned long xpc_hb_check_timeout;
 
 /* notification that the xpc_hb_checker thread has exited */
-static DECLARE_MUTEX_LOCKED(xpc_hb_checker_exited);
+static DECLARE_COMPLETION(xpc_hb_checker_exited);
 
 /* notification that the xpc_discovery thread has exited */
-static DECLARE_MUTEX_LOCKED(xpc_discovery_exited);
+static DECLARE_COMPLETION(xpc_discovery_exited);
 
 
 static struct timer_list xpc_hb_timer;
@@ -321,7 +322,7 @@ xpc_hb_checker(void *ignore)
 
 
 	/* mark this thread as having exited */
-	up(&xpc_hb_checker_exited);
+	complete(&xpc_hb_checker_exited);
 	return 0;
 }
 
@@ -341,7 +342,7 @@ xpc_initiate_discovery(void *ignore)
 	dev_dbg(xpc_part, "discovery thread is exiting\n");
 
 	/* mark this thread as having exited */
-	up(&xpc_discovery_exited);
+	complete(&xpc_discovery_exited);
 	return 0;
 }
 
@@ -893,7 +894,7 @@ xpc_disconnect_wait(int ch_number)
 			continue;
 		}
 
-		(void) down(&ch->wdisconnect_sema);
+		wait_for_completion(&ch->wdisconnect_wait);
 
 		spin_lock_irqsave(&ch->lock, irq_flags);
 		DBUG_ON(!(ch->flags & XPC_C_DISCONNECTED));
@@ -946,10 +947,10 @@ xpc_do_exit(enum xpc_retval reason)
 	free_irq(SGI_XPC_ACTIVATE, NULL);
 
 	/* wait for the discovery thread to exit */
-	down(&xpc_discovery_exited);
+	wait_for_completion(&xpc_discovery_exited);
 
 	/* wait for the heartbeat checker thread to exit */
-	down(&xpc_hb_checker_exited);
+	wait_for_completion(&xpc_hb_checker_exited);
 
 
 	/* sleep for a 1/3 of a second or so */
@@ -1367,7 +1368,7 @@ xpc_init(void)
 		dev_err(xpc_part, "failed while forking discovery thread\n");
 
 		/* mark this new thread as a non-starter */
-		up(&xpc_discovery_exited);
+		complete(&xpc_discovery_exited);
 
 		xpc_do_exit(xpcUnloading);
 		return -EBUSY;
diff --git a/include/asm-ia64/sn/xp.h b/include/asm-ia64/sn/xp.h
index 203945a..9bd2f9b 100644
--- a/include/asm-ia64/sn/xp.h
+++ b/include/asm-ia64/sn/xp.h
@@ -18,6 +18,7 @@
 
 #include <linux/cache.h>
 #include <linux/hardirq.h>
+#include <linux/mutex.h>
 #include <asm/sn/types.h>
 #include <asm/sn/bte.h>
 
@@ -359,7 +360,7 @@ typedef void (*xpc_notify_func)(enum xpc
  * the channel.
  */
 struct xpc_registration {
-	struct semaphore sema;
+	struct mutex mutex;
 	xpc_channel_func func;		/* function to call */
 	void *key;			/* pointer to user's key */
 	u16 nentries;			/* #of msg entries in local msg queue */
diff --git a/include/asm-ia64/sn/xpc.h b/include/asm-ia64/sn/xpc.h
index 87e9cd5..0c36928 100644
--- a/include/asm-ia64/sn/xpc.h
+++ b/include/asm-ia64/sn/xpc.h
@@ -19,6 +19,8 @@
 #include <linux/interrupt.h>
 #include <linux/sysctl.h>
 #include <linux/device.h>
+#include <linux/mutex.h>
+#include <linux/completion.h>
 #include <asm/pgtable.h>
 #include <asm/processor.h>
 #include <asm/sn/bte.h>
@@ -335,8 +337,7 @@ struct xpc_openclose_args {
  * and consumed by the intended recipient.
  */
 struct xpc_notify {
-	struct semaphore sema;		/* notify semaphore */
-	volatile u8 type;			/* type of notification */
+	volatile u8 type;		/* type of notification */
 
 	/* the following two fields are only used if type = XPC_N_CALL */
 	xpc_notify_func func;		/* user's notify function */
@@ -465,8 +466,8 @@ struct xpc_channel {
 	xpc_channel_func func;		/* user's channel function */
 	void *key;			/* pointer to user's key */
 
-	struct semaphore msg_to_pull_sema; /* next msg to pull serialization */
-	struct semaphore wdisconnect_sema; /* wait for channel disconnect */
+	struct mutex msg_to_pull_mutex;	/* next msg to pull serialization */
+	struct completion wdisconnect_wait; /* wait for channel disconnect */
 
 	struct xpc_openclose_args *local_openclose_args; /* args passed on */
 					/* opening or closing of channel */

diff-tree ac354a899b91239aac4d5893fc4288bc400e82b4 (from 5f7f5b0c99c9c913b649d065a9773e6ed4ed8168)
Author: Mike Habeck <habeck@sgi.com>
Date:   Wed Jan 11 16:40:24 2006 -0600

    [IA64-SGI] pass segment# on SN_SAL_IOIF_SLOT_{DIS,EN}ABLE calls
    
    Bugfix... the altix SN_SAL_IOIF_SLOT_ENABLE & SN_SAL_IOIF_SLOT_DISABLE
    SAL calls need to pass the segment# down
    
    Signed-off-by: Mike Habeck <habeck@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/sn/pci/pcibr/pcibr_provider.c b/arch/ia64/sn/pci/pcibr/pcibr_provider.c
index 77a1262..2fac270 100644
--- a/arch/ia64/sn/pci/pcibr/pcibr_provider.c
+++ b/arch/ia64/sn/pci/pcibr/pcibr_provider.c
@@ -24,13 +24,15 @@ sal_pcibr_slot_enable(struct pcibus_info
 {
 	struct ia64_sal_retval ret_stuff;
 	u64 busnum;
+	u64 segment;
 
 	ret_stuff.status = 0;
 	ret_stuff.v0 = 0;
 
+	segment = soft->pbi_buscommon.bs_persist_segment;
 	busnum = soft->pbi_buscommon.bs_persist_busnum;
-	SAL_CALL_NOLOCK(ret_stuff, (u64) SN_SAL_IOIF_SLOT_ENABLE, (u64) busnum,
-			(u64) device, (u64) resp, 0, 0, 0, 0);
+	SAL_CALL_NOLOCK(ret_stuff, (u64) SN_SAL_IOIF_SLOT_ENABLE, segment,
+			busnum, (u64) device, (u64) resp, 0, 0, 0);
 
 	return (int)ret_stuff.v0;
 }
@@ -41,14 +43,16 @@ sal_pcibr_slot_disable(struct pcibus_inf
 {
 	struct ia64_sal_retval ret_stuff;
 	u64 busnum;
+	u64 segment;
 
 	ret_stuff.status = 0;
 	ret_stuff.v0 = 0;
 
+	segment = soft->pbi_buscommon.bs_persist_segment;
 	busnum = soft->pbi_buscommon.bs_persist_busnum;
 	SAL_CALL_NOLOCK(ret_stuff, (u64) SN_SAL_IOIF_SLOT_DISABLE,
-			(u64) busnum, (u64) device, (u64) action,
-			(u64) resp, 0, 0, 0);
+			segment, busnum, (u64) device, (u64) action,
+			(u64) resp, 0, 0);
 
 	return (int)ret_stuff.v0;
 }

diff-tree 5f7f5b0c99c9c913b649d065a9773e6ed4ed8168 (from 2664b25051f7ab96b22b199aa2f5ef6a949a4296)
Author: Prarit Bhargava <prarit@sgi.com>
Date:   Mon Jan 16 15:31:52 2006 -0500

    [IA64-SGI] Older PROM WAR for device flush code
    
    Work-around to temporarily support older PROMs with new flush device code.
    
    This code allows systems running older PROMs to continue to run on the new
    kernel base until a new official PROM is released.
    
    Signed-off-by: Prarit Bhargava <prarit@sgi.com>
    Acked-by: Jes Sorensen <jes@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/sn/include/xtalk/hubdev.h b/arch/ia64/sn/include/xtalk/hubdev.h
index 7c88e9a..8182583 100644
--- a/arch/ia64/sn/include/xtalk/hubdev.h
+++ b/arch/ia64/sn/include/xtalk/hubdev.h
@@ -51,6 +51,15 @@ struct sn_flush_device_kernel {
 	struct sn_flush_device_common *common;
 };
 
+/* 01/16/06 This struct is the old PROM/kernel struct and needs to be included
+ * for older official PROMs to function on the new kernel base.  This struct
+ * will be removed when the next official PROM release occurs. */
+
+struct sn_flush_device_war {
+	struct sn_flush_device_common common;
+	u32 filler; /* older PROMs expect the default size of a spinlock_t */
+};
+
 /*
  * **widget_p - Used as an array[wid_num][device] of sn_flush_device_kernel.
  */
diff --git a/arch/ia64/sn/kernel/io_init.c b/arch/ia64/sn/kernel/io_init.c
index 233d551..00700f7 100644
--- a/arch/ia64/sn/kernel/io_init.c
+++ b/arch/ia64/sn/kernel/io_init.c
@@ -165,8 +165,45 @@ sn_pcidev_info_get(struct pci_dev *dev)
 	return NULL;
 }
 
+/* Older PROM flush WAR
+ *
+ * 01/16/06 -- This war will be in place until a new official PROM is released.
+ * Additionally note that the struct sn_flush_device_war also has to be
+ * removed from arch/ia64/sn/include/xtalk/hubdev.h
+ */
+static u8 war_implemented = 0;
+
+static void sn_device_fixup_war(u64 nasid, u64 widget, int device,
+				struct sn_flush_device_common *common)
+{
+	struct sn_flush_device_war *war_list;
+	struct sn_flush_device_war *dev_entry;
+	struct ia64_sal_retval isrv = {0,0,0,0};
+
+	if (!war_implemented) {
+		printk(KERN_WARNING "PROM version < 4.50 -- implementing old "
+		       "PROM flush WAR\n");
+		war_implemented = 1;
+	}
+
+	war_list = kzalloc(DEV_PER_WIDGET * sizeof(*war_list), GFP_KERNEL);
+	if (!war_list)
+		BUG();
+
+	SAL_CALL_NOLOCK(isrv, SN_SAL_IOIF_GET_WIDGET_DMAFLUSH_LIST,
+			nasid, widget, __pa(war_list), 0, 0, 0 ,0);
+	if (isrv.status)
+		panic("sn_device_fixup_war failed: %s\n",
+		      ia64_sal_strerror(isrv.status));
+
+	dev_entry = war_list + device;
+	memcpy(common,dev_entry, sizeof(*common));
+
+	kfree(war_list);
+}
+
 /*
- * sn_fixup_ionodes() - This routine initializes the HUB data strcuture for 
+ * sn_fixup_ionodes() - This routine initializes the HUB data strcuture for
  *	each node in the system.
  */
 static void sn_fixup_ionodes(void)
@@ -246,8 +283,19 @@ static void sn_fixup_ionodes(void)
 									widget,
 								       	device,
 						      (u64)(dev_entry->common));
-				if (status)
-					BUG();
+				if (status) {
+					if (sn_sal_rev() < 0x0450) {
+						/* shortlived WAR for older
+						 * PROM images
+						 */
+						sn_device_fixup_war(nasid,
+								    widget,
+								    device,
+							     dev_entry->common);
+					}
+					else
+						BUG();
+				}
 
 				spin_lock_init(&dev_entry->sfdl_flush_lock);
 			}
