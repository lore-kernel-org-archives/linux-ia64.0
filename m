From: Christoph Hellwig <hch@infradead.org>
Date: Thu, 17 Jun 2004 19:22:29 +0000
Subject: Re: [PATCH 3/4] SGI Altix cross partition functionality
Message-Id: <20040617192229.GA4923@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040617183638.GA3712@sgi.com>
In-Reply-To: <20040617183638.GA3712@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jun 17, 2004 at 01:36:38PM -0500, Dean Nelson wrote:
> This patch contains the communication module (XPC) for cross partition
> communication on a partitioned SGI Altix.
>                                                                                 
> XPC creates kthreads to manage the channel activity between partitions.
> There is an EFI version of XPC (called XPBOOT) that polls rather than uses
> multiple kthreads. It's purpose is to provide a diskless boot capability.
> It is the reason for the '#if[n]def SN_PROM' code and xpc_stubs.h file.
> XPBOOT is included in the PROM/SAL code and can not be released due to
> Intel copyright.

Please don't include all that mess.  If you want to use it in two enviroments
and do the license assignment mess that's your choice but please keep the
compat gunk out of the actual kernel files.


+obj-$(CONFIG_IA64_SGI_SN_XPC)	+= xpc.o
+xpc-y				:= xpc_main.o xpc_kdb.o xpc_channel.o xpc_partition.o
+CFLAGS_xpc_main.o += -I $(TOPDIR)/arch/$(ARCH)/kdb
+CFLAGS_xpc_kdb.o += -I $(TOPDIR)/arch/$(ARCH)/kdb
+CFLAGS_xpc_channel.o += -I $(TOPDIR)/arch/$(ARCH)/kdb
+CFLAGS_xpc_partition.o += -I $(TOPDIR)/arch/$(ARCH)/kdb

We already told you not to do this yesterday.  Als please make all that
xp* stuff into a single module instead of three and kill all the useless
layering.

+#define __XPC_MAIN__

Where is that checked?  And even if it is somewhere that's no the kind
of code we want.

+
+#ifndef	SN_PROM
+#include <asm/pgtable.h>
+#include <linux/autoconf.h>
+#include <linux/interrupt.h>
+#include <asm/sn/clksupport.h>
+#include <asm/sn/fetchop.h>
+#include <linux/sysctl.h>
+#include <asm/processor.h>
+#include <asm/sn/xp.h>
+#include "xpc_dbgtk.h"

<asm/*.h> after <linux/*.h> please, and never ever include autoconf.h
directly.

+// >>> Where does the following two macros belong?
+/*
+ * Define a macro that does exactly what wait_event_interruptible() does except
+ * that it adds the current task to the wait queue as an exclusive task (i.e.,
+ * sets the WQ_FLAG_EXCLUSIVE flag) rather than as a non-exclusive task as
+ * wait_event_interruptible() does. (Linux doesn't seem to provide this option
+ * so I've written my own.)
+ */
+#define __wait_event_exclusive_interruptible(wq, condition, ret)	\

please submit a patch to add this to <linux/wait.h> instead.

+} xpc_vars_t;

please kill all the typedef gunk.

+#define XPC_MSGQUEUE_REF(_ch)	atomic_inc(&(_ch)->references)
+#define XPC_MSGQUEUE_DEREF(_ch)						\
+	{								\
+		xpc_partition_t *_p;					\
+		s32 _refs;						\
+		_refs = atomic_dec_return(&(_ch)->references);		\
+		XP_ASSERT(_refs >= 0);					\
+		if (_refs = 0) {					\
+			_p = &xpc_partitions[(_ch)->partid];		\
+			xpc_wakeup_channel_mgr(_p);			\
+		}							\
+	}

yikes.  For monster-macros like that please use inline function instead.

+	/*
+	 * Zero out MOST of the entry for this partition. Only the fields
+	 * following `references' will be zeroed. The others must remain
+	 * `viable' across partition ups and downs, since they may be
+	 * referenced during this memset() operation.
+	 */
+	memset((u8 *)&part->references + sizeof(part->references), 0,

cast to u8 * in memset? Ummm..

+//>>> #define DBGTK_USE_DPRINTK
+#include <asm/sn/xp_dbgtk.h>

Can't find that in my tree.  And if it's the good old SGI dbgtk stuff
it's totally crap and you're better of stopping to use it.

+#define __KERNEL_SYSCALLS__		/* needed for waitpid() */
+#include <asm/unistd.h>			/* needed for waitpid() */

which you shouldn't use..

+#include "xpc.h"
+

+/* once Linux 2.4 is no longer supported, eliminate these gyrations */
+
+#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,4,0) && \
+    LINUX_VERSION_CODE <  KERNEL_VERSION(2,5,0)
+
+#define IRQ_HANDLED
+
+#define THREAD_INFO  task_struct
+#define CURRENT_THREAD_INFO()  current
+
+#define NASID_SLICE_TO_CPUID_ERROR  smp_num_cpus
+
+#define sys_sched_setscheduler sched_setscheduler
+static inline _syscall3(long, sched_setscheduler, pid_t, pid,
+			int, policy, struct sched_param *, param);
+
+#define DAEMONIZE(name...)  { daemonize(); sprintf(current->comm, name); }
+#define DEQUEUE_SIGNAL(task, mask, info)  dequeue_signal(mask, info)
+
+#define cpumask_of_cpu(cpu) \
+	({ \
+		cpumask_t __cpu_mask = CPU_MASK_NONE; \
+		__set_bit(cpu, &__cpu_mask); \
+		&__cpu_mask; \
+	})

there's not cpumask_t in 2.4.  But anyway, all this 2.4 compat gunk doesn't
belong here.

+#include <linux/syscalls.h>
+
+#define EXPORT_NO_SYMBOLS

Not needed in 2.6.

+
+#define THREAD_INFO  thread_info
+#define CURRENT_THREAD_INFO  current_thread_info
+
+#define NASID_SLICE_TO_CPUID_ERROR  NR_CPUS
+
+#define DAEMONIZE(name...)  daemonize(name)
+#define DEQUEUE_SIGNAL(task, mask, info)  dequeue_signal(task, mask, info)

Please call all this stuff directly.

+volatile static unsigned long xpc_hb_check_timeout;

please use a proper atomic datatype for this.

+	DAEMONIZE(XPC_HB_CHECK_THREAD_NAME);
+
+	set_user_nice(current, 19);
+
+	spin_lock_irq(&current->sighand->siglock);
+	/*
+	 * The following allows SIGCHLD to be delivered.  Without it,
+	 * SIGCHLD gets dropped on the floor.
+	 */
+	current->sighand->action[SIGCHLD-1].sa.sa_handler = SIG_IGN;
+	siginitsetinv(&current->blocked, sigmask(SIGCHLD) | sigmask(SIGHUP));
+	recalc_sigpending();
+	spin_unlock_irq(&current->sighand->siglock);

I think you want allow_signal(), and please drop that renicing stuff.

+			spin_lock_irq(&current->sighand->siglock);
+			sig = DEQUEUE_SIGNAL(current, &current->blocked,
+								&sig_info);
+			spin_unlock_irq(&current->sighand->siglock);

there's a nice little dequeue_signal_lock() wrapper for you.  And with that
you can even get it to compile with 2.4 more easily without all the shouting
macro junk.  (And even your 2.4 version won't even compile because in 2.4
the lock is somewhere else)

+ *
+ * There seems to be some inconsistency in the meaning and usage of
+ * the word 'slice'.  Some places equate slice with CPU, others seem to
+ * equate it with the Front Side Bus slot. There are two CPUs (numbered 0 & 1)
+ * and two FSB slots (numbered 0 & 2) per nasid. The function
+ * nasid_slice_to_cpuid() equates slice to the FSB slot.
+ */
+static int
+xpc_next_cpu(void)
+{
+	static int last_cnodeid = 0;
+	static int last_slice = 2;
+	int next_cpu;
+	nasid_t nasid;
+
+
+	next_cpu = -1;
+	while (next_cpu = -1) {
+		if (++last_cnodeid >= numnodes) {
+			last_cnodeid = 0;
+			last_slice = (last_slice + 2) % 4;

locking?  Also such an iterator is probably better placed in core SN2
code and export instead of numnodes.

+	spin_lock_irqsave(&part->act_lock, irq_flags);
+
+	pid = kernel_thread(xpc_activating, (void *) ((u64) partid), SIGCHLD);

What about using the kthread infrastructure?  With an emulation of that
on 2.4 you could get rid of all your messy version abstractions.

+MODULE_PARM(xpc_hb_interval, "1i");

please use module_param.

+/* XPC is exiting flag */
+volatile int xpc_exiting = 0;

volatile again.  Please use proper primitives.

+
+
+/* SH_IPI_ACCESS shub register value on startup */
+static u64 xpc_sh_ipi_access = 0;

no need to initialize static/global variales to 0.

