From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 17 Feb 2006 00:13:55 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200602170013.k1H0Dtlr031034@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

More ia64 bugfixes and cleanups for 2.6.16.  Special notes:
1) The drivers/ide/pci/sgiioc4.c change is just deleting an out of date
   address for SGI from a comment.
2) In the shortlog it looks like I have two identical commits from Ashok.
   The second is actually a minor update to the first, but I forgot to
   edit the first line of the commit comment.

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.

Thanks!

-Tony

 Documentation/cpu-hotplug.txt             |   14 +++-
 arch/ia64/kernel/acpi.c                   |   75 +++++++++++++++++++----
 arch/ia64/kernel/entry.S                  |    4 -
 arch/ia64/kernel/ia64_ksyms.c             |   15 ----
 arch/ia64/kernel/setup.c                  |    4 +
 arch/ia64/kernel/smpboot.c                |    5 -
 arch/ia64/kernel/time.c                   |   39 +++++-------
 arch/ia64/kernel/traps.c                  |    8 ++
 arch/ia64/sn/kernel/io_init.c             |   97 ++++++++++++------------------
 arch/ia64/sn/kernel/setup.c               |    4 -
 arch/ia64/sn/kernel/sn2/prominfo_proc.c   |   25 ++++---
 arch/ia64/sn/kernel/sn2/sn2_smp.c         |   35 +++++-----
 arch/ia64/sn/kernel/sn2/sn_proc_fs.c      |   22 +++---
 arch/ia64/sn/kernel/sn2/timer.c           |   19 +++++
 arch/ia64/sn/kernel/sn2/timer_interrupt.c |    7 --
 arch/ia64/sn/kernel/tiocx.c               |    4 -
 arch/ia64/sn/kernel/xpc_channel.c         |    8 +-
 arch/ia64/sn/kernel/xpc_main.c            |   20 ++++--
 arch/ia64/sn/pci/pci_dma.c                |   16 ++--
 arch/ia64/sn/pci/pcibr/pcibr_ate.c        |   29 ++------
 arch/ia64/sn/pci/pcibr/pcibr_dma.c        |   14 +---
 arch/ia64/sn/pci/pcibr/pcibr_provider.c   |    9 +-
 drivers/ide/pci/sgiioc4.c                 |    5 -
 include/asm-ia64/acpi.h                   |    2 
 include/asm-ia64/machvec_sn2.h            |    7 --
 include/asm-ia64/sn/arch.h                |    2 
 include/asm-ia64/sn/bte.h                 |    6 -
 include/asm-ia64/sn/pcibr_provider.h      |   14 ----
 include/asm-ia64/sn/sn_feature_sets.h     |    3 
 include/asm-ia64/sn/xpc.h                 |   31 +++++----
 include/asm-ia64/timex.h                  |    2 
 31 files changed, 286 insertions(+), 259 deletions(-)

Andreas Schwab:
      [IA64] Remove duplicate EXPORT_SYMBOLs

Ashok Raj:
      [IA64] Dont set NR_CPUS for cpu_possible_map when CPU hotplug is enabled.
      [IA64] Count disabled cpus as potential hot-pluggable CPUs
      [IA64] Count disabled cpus as potential hot-pluggable CPUs

Dean Nelson:
      [IA64-SGI] enforce proper ordering of callouts by XPC

Dean Roe:
      [IA64-SGI] fix the size of __sn_cnodeid_to_nasid

hawkes@sgi.com:
      [IA64] ia64: simplify and fix udelay()

Horms:
      [IA64] support panic_on_oops sysctl

Jack Steiner:
      [IA64] Missing check for TIF_WORK if trace/audit enabled

Jes Sorensen:
      [IA64-SGI] sn2 minor fixes and cleanups
      [IA64] remove obsolete corporate address
      [IA64-SGI] remove compile time warning

Mark Maule:
      [IA64-SGI] export sn_pcidev_info_get


diff-tree 8f8b1138fc9f65e3591aac83a4ee394fef34ac1d (from 6f6d75825dc49b082906b84537b4df28293c2977)
Author: Ashok Raj <ashok.raj@intel.com>
Date:   Thu Feb 16 14:01:48 2006 -0800

    [IA64] Count disabled cpus as potential hot-pluggable CPUs
    
    Minor updates to earlier patch.
    - Added to documentation to add ia64 as well.
    - Minor clarification on how to use disabled cpus
    - used plain max instead of max_t per Andew Morton.
    
    Signed-off-by: Ashok Raj <ashok.raj@intel.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/Documentation/cpu-hotplug.txt b/Documentation/cpu-hotplug.txt
index 08c5d04..e052780 100644
--- a/Documentation/cpu-hotplug.txt
+++ b/Documentation/cpu-hotplug.txt
@@ -44,10 +44,20 @@ maxcpus=n    Restrict boot time cpus to 
              maxcpus=2 will only boot 2. You can choose to bring the
              other cpus later online, read FAQ's for more info.
 
-additional_cpus=n	[x86_64 only] use this to limit hotpluggable cpus.
-                        This option sets
+additional_cpus*=n	Use this to limit hotpluggable cpus. This option sets
 			cpu_possible_map = cpu_present_map + additional_cpus
 
+(*) Option valid only for following architectures
+- x86_64, ia64
+
+ia64 and x86_64 use the number of disabled local apics in ACPI tables MADT
+to determine the number of potentially hot-pluggable cpus. The implementation
+should only rely on this to count the #of cpus, but *MUST* not rely on the
+apicid values in those tables for disabled apics. In the event BIOS doesnt
+mark such hot-pluggable cpus as disabled entries, one could use this
+parameter "additional_cpus=x" to represent those cpus in the cpu_possible_map.
+
+
 CPU maps and such
 -----------------
 [More on cpumaps and primitive to manipulate, please check
diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
index 34795ed..ecd44bd 100644
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -794,24 +794,21 @@ __init void prefill_possible_map(void)
 	int possible, disabled_cpus;
 
 	disabled_cpus = total_cpus - available_cpus;
+
  	if (additional_cpus = -1) {
- 		if (disabled_cpus > 0) {
- 			possible = total_cpus;
+ 		if (disabled_cpus > 0)
 			additional_cpus = disabled_cpus;
-		}
- 		else {
-			possible = available_cpus;
+ 		else
 			additional_cpus = 0;
-		}
- 	} else {
-		possible = available_cpus + additional_cpus;
-	}
+ 	}
+
+	possible = available_cpus + additional_cpus;
+
 	if (possible > NR_CPUS)
 		possible = NR_CPUS;
 
 	printk(KERN_INFO "SMP: Allowing %d CPUs, %d hotplug CPUs\n",
-		possible,
-	        max_t(int, additional_cpus, 0));
+		possible, max((possible - available_cpus), 0));
 
 	for (i = 0; i < possible; i++)
 		cpu_set(i, cpu_possible_map);

diff-tree 6f6d75825dc49b082906b84537b4df28293c2977 (from 72166c35f0e15e5081e51304de48e73f8fdf5498)
Author: Jack Steiner <steiner@sgi.com>
Date:   Wed Feb 15 19:46:50 2006 -0600

    [IA64] Missing check for TIF_WORK if trace/audit enabled
    
    It appears that if auditing is enabled, the kernel fails to
    check for pending signals before returning to user mode.
    
    Signed-off-by: Jack Steiner <steiner@sgi.com>
    Acked-by: Ken Chen <kenneth.w.chen@intel.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
index 27b222c..930fdfc 100644
--- a/arch/ia64/kernel/entry.S
+++ b/arch/ia64/kernel/entry.S
@@ -569,7 +569,9 @@ GLOBAL_ENTRY(ia64_trace_syscall)
 .mem.offset 0,0; st8.spill [r2]=r8		// store return value in slot for r8
 .mem.offset 8,0; st8.spill [r3]=r10		// clear error indication in slot for r10
 	br.call.sptk.many rp=syscall_trace_leave // give parent a chance to catch return value
-.ret3:	br.cond.sptk .work_pending_syscall_end
+.ret3:
+(pUStk)	cmp.eq.unc p6,p0=r0,r0			// p6 <- pUStk
+	br.cond.sptk .work_pending_syscall_end
 
 strace_error:
 	ld8 r3=[r2]				// load pt_regs.r8

diff-tree b05de01ae1c76b7d61da21bbcc26345bf7a9052f (from defbb2c929cbe89dc92239b303cd33d3c85e9a83)
Author: Horms <horms@verge.net.au>
Date:   Wed Feb 15 17:23:09 2006 +0900

    [IA64] support panic_on_oops sysctl
    
    Trivial port of this feature from i386
    As it stands, panic_on_oops but does nothing on ia64
    
    Signed-Off-By: Horms <horms@verge.net.au>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/traps.c b/arch/ia64/kernel/traps.c
index 5539190..dabd6c3 100644
--- a/arch/ia64/kernel/traps.c
+++ b/arch/ia64/kernel/traps.c
@@ -16,6 +16,7 @@
 #include <linux/module.h>       /* for EXPORT_SYMBOL */
 #include <linux/hardirq.h>
 #include <linux/kprobes.h>
+#include <linux/delay.h>		/* for ssleep() */
 
 #include <asm/fpswa.h>
 #include <asm/ia32.h>
@@ -116,6 +117,13 @@ die (const char *str, struct pt_regs *re
 	bust_spinlocks(0);
 	die.lock_owner = -1;
 	spin_unlock_irq(&die.lock);
+
+	if (panic_on_oops) {
+		printk(KERN_EMERG "Fatal exception: panic in 5 seconds\n");
+		ssleep(5);
+		panic("Fatal exception");
+	}
+
   	do_exit(SIGSEGV);
 }
 

diff-tree defbb2c929cbe89dc92239b303cd33d3c85e9a83 (from 4c2cd96696ae0896ce4bcf725b9f0eaffafeb640)
Author: hawkes@sgi.com <hawkes@sgi.com>
Date:   Tue Feb 14 10:40:17 2006 -0800

    [IA64] ia64: simplify and fix udelay()
    
    The original ia64 udelay() was simple, but flawed for platforms without
    synchronized ITCs:  a preemption and migration to another CPU during the
    while-loop likely resulted in too-early termination or very, very
    lengthy looping.
    
    The first fix (now in 2.6.15) broke the delay loop into smaller,
    non-preemptible chunks, reenabling preemption between the chunks.  This
    fix is flawed in that the total udelay is computed to be the sum of just
    the non-premptible while-loop pieces, i.e., not counting the time spent
    in the interim preemptible periods.  If an interrupt or a migration
    occurs during one of these interim periods, then that time is invisible
    and only serves to lengthen the effective udelay().
    
    This new fix backs out the current flawed fix and returns to a simple
    udelay(), fully preemptible and interruptible.  It implements two simple
    alternative udelay() routines:  one a default generic version that uses
    ia64_get_itc(), and the other an sn-specific version that uses that
    platform's RTC.
    
    Signed-off-by: John Hawkes <hawkes@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/time.c b/arch/ia64/kernel/time.c
index a094ec4..307d01e 100644
--- a/arch/ia64/kernel/time.c
+++ b/arch/ia64/kernel/time.c
@@ -250,32 +250,27 @@ time_init (void)
 	set_normalized_timespec(&wall_to_monotonic, -xtime.tv_sec, -xtime.tv_nsec);
 }
 
-#define SMALLUSECS 100
+/*
+ * Generic udelay assumes that if preemption is allowed and the thread
+ * migrates to another CPU, that the ITC values are synchronized across
+ * all CPUs.
+ */
+static void
+ia64_itc_udelay (unsigned long usecs)
+{
+	unsigned long start = ia64_get_itc();
+	unsigned long end = start + usecs*local_cpu_data->cyc_per_usec;
+
+	while (time_before(ia64_get_itc(), end))
+		cpu_relax();
+}
+
+void (*ia64_udelay)(unsigned long usecs) = &ia64_itc_udelay;
 
 void
 udelay (unsigned long usecs)
 {
-	unsigned long start;
-	unsigned long cycles;
-	unsigned long smallusecs;
-
-	/*
-	 * Execute the non-preemptible delay loop (because the ITC might
-	 * not be synchronized between CPUS) in relatively short time
-	 * chunks, allowing preemption between the chunks.
-	 */
-	while (usecs > 0) {
-		smallusecs = (usecs > SMALLUSECS) ? SMALLUSECS : usecs;
-		preempt_disable();
-		cycles = smallusecs*local_cpu_data->cyc_per_usec;
-		start = ia64_get_itc();
-
-		while (ia64_get_itc() - start < cycles)
-			cpu_relax();
-
-		preempt_enable();
-		usecs -= smallusecs;
-	}
+	(*ia64_udelay)(usecs);
 }
 EXPORT_SYMBOL(udelay);
 
diff --git a/arch/ia64/sn/kernel/sn2/timer.c b/arch/ia64/sn/kernel/sn2/timer.c
index deb9baf..56a88b6 100644
--- a/arch/ia64/sn/kernel/sn2/timer.c
+++ b/arch/ia64/sn/kernel/sn2/timer.c
@@ -14,6 +14,7 @@
 
 #include <asm/hw_irq.h>
 #include <asm/system.h>
+#include <asm/timex.h>
 
 #include <asm/sn/leds.h>
 #include <asm/sn/shub_mmr.h>
@@ -28,9 +29,27 @@ static struct time_interpolator sn2_inte
 	.source = TIME_SOURCE_MMIO64
 };
 
+/*
+ * sn udelay uses the RTC instead of the ITC because the ITC is not
+ * synchronized across all CPUs, and the thread may migrate to another CPU
+ * if preemption is enabled.
+ */
+static void
+ia64_sn_udelay (unsigned long usecs)
+{
+	unsigned long start = rtc_time();
+	unsigned long end = start +
+			usecs * sn_rtc_cycles_per_second / 1000000;
+
+	while (time_before((unsigned long)rtc_time(), end))
+		cpu_relax();
+}
+
 void __init sn_timer_init(void)
 {
 	sn2_interpolator.frequency = sn_rtc_cycles_per_second;
 	sn2_interpolator.addr = RTC_COUNTER_ADDR;
 	register_time_interpolator(&sn2_interpolator);
+
+	ia64_udelay = &ia64_sn_udelay;
 }
diff --git a/include/asm-ia64/timex.h b/include/asm-ia64/timex.h
index 414aae0..05a6baf 100644
--- a/include/asm-ia64/timex.h
+++ b/include/asm-ia64/timex.h
@@ -15,6 +15,8 @@
 
 typedef unsigned long cycles_t;
 
+extern void (*ia64_udelay)(unsigned long usecs);
+
 /*
  * For performance reasons, we don't want to define CLOCK_TICK_TRATE as
  * local_cpu_data->itc_rate.  Fortunately, we don't have to, either: according to George

diff-tree 4c2cd96696ae0896ce4bcf725b9f0eaffafeb640 (from c2a4969ba14e852bf4ee92c7db3b0cf82405a0c9)
Author: Dean Nelson <dcn@sgi.com>
Date:   Wed Feb 15 08:02:21 2006 -0600

    [IA64-SGI] enforce proper ordering of callouts by XPC
    
    Fix XPC so that it does not deliver any messages until the connected
    callout has returned, as well as, prevent the disconnected callout to
    occur before the disconnecting callout has returned.
    
    Signed-off-by: Dean Nelson <dcn@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/sn/kernel/xpc_channel.c b/arch/ia64/sn/kernel/xpc_channel.c
index 36e5437..cdf6856 100644
--- a/arch/ia64/sn/kernel/xpc_channel.c
+++ b/arch/ia64/sn/kernel/xpc_channel.c
@@ -738,7 +738,9 @@ xpc_process_disconnect(struct xpc_channe
 
 	/* make sure all activity has settled down first */
 
-	if (atomic_read(&ch->references) > 0) {
+	if (atomic_read(&ch->references) > 0 ||
+			((ch->flags & XPC_C_CONNECTEDCALLOUT_MADE) &&
+			!(ch->flags & XPC_C_DISCONNECTINGCALLOUT_MADE))) {
 		return;
 	}
 	DBUG_ON(atomic_read(&ch->kthreads_assigned) != 0);
@@ -775,7 +777,7 @@ xpc_process_disconnect(struct xpc_channe
 
 	/* both sides are disconnected now */
 
-	if (ch->flags & XPC_C_CONNECTCALLOUT) {
+	if (ch->flags & XPC_C_DISCONNECTINGCALLOUT_MADE) {
 		spin_unlock_irqrestore(&ch->lock, *irq_flags);
 		xpc_disconnect_callout(ch, xpcDisconnected);
 		spin_lock_irqsave(&ch->lock, *irq_flags);
@@ -1300,7 +1302,7 @@ xpc_process_msg_IPI(struct xpc_partition
 				"delivered=%d, partid=%d, channel=%d\n",
 				nmsgs_sent, ch->partid, ch->number);
 
-			if (ch->flags & XPC_C_CONNECTCALLOUT) {
+			if (ch->flags & XPC_C_CONNECTEDCALLOUT_MADE) {
 				xpc_activate_kthreads(ch, nmsgs_sent);
 			}
 		}
diff --git a/arch/ia64/sn/kernel/xpc_main.c b/arch/ia64/sn/kernel/xpc_main.c
index 9cd460d..8cbf164 100644
--- a/arch/ia64/sn/kernel/xpc_main.c
+++ b/arch/ia64/sn/kernel/xpc_main.c
@@ -750,12 +750,16 @@ xpc_daemonize_kthread(void *args)
 		/* let registerer know that connection has been established */
 
 		spin_lock_irqsave(&ch->lock, irq_flags);
-		if (!(ch->flags & XPC_C_CONNECTCALLOUT)) {
-			ch->flags |= XPC_C_CONNECTCALLOUT;
+		if (!(ch->flags & XPC_C_CONNECTEDCALLOUT)) {
+			ch->flags |= XPC_C_CONNECTEDCALLOUT;
 			spin_unlock_irqrestore(&ch->lock, irq_flags);
 
 			xpc_connected_callout(ch);
 
+			spin_lock_irqsave(&ch->lock, irq_flags);
+			ch->flags |= XPC_C_CONNECTEDCALLOUT_MADE;
+			spin_unlock_irqrestore(&ch->lock, irq_flags);
+
 			/*
 			 * It is possible that while the callout was being
 			 * made that the remote partition sent some messages.
@@ -777,15 +781,17 @@ xpc_daemonize_kthread(void *args)
 
 	if (atomic_dec_return(&ch->kthreads_assigned) = 0) {
 		spin_lock_irqsave(&ch->lock, irq_flags);
-		if ((ch->flags & XPC_C_CONNECTCALLOUT) &&
-				!(ch->flags & XPC_C_DISCONNECTCALLOUT)) {
-			ch->flags |= XPC_C_DISCONNECTCALLOUT;
+		if ((ch->flags & XPC_C_CONNECTEDCALLOUT_MADE) &&
+				!(ch->flags & XPC_C_DISCONNECTINGCALLOUT)) {
+			ch->flags |= XPC_C_DISCONNECTINGCALLOUT;
 			spin_unlock_irqrestore(&ch->lock, irq_flags);
 
 			xpc_disconnect_callout(ch, xpcDisconnecting);
-		} else {
-			spin_unlock_irqrestore(&ch->lock, irq_flags);
+
+			spin_lock_irqsave(&ch->lock, irq_flags);
+			ch->flags |= XPC_C_DISCONNECTINGCALLOUT_MADE;
 		}
+		spin_unlock_irqrestore(&ch->lock, irq_flags);
 		if (atomic_dec_return(&part->nchannels_engaged) = 0) {
 			xpc_mark_partition_disengaged(part);
 			xpc_IPI_send_disengage(part);
diff --git a/include/asm-ia64/sn/xpc.h b/include/asm-ia64/sn/xpc.h
index 0c36928..df7f5f4 100644
--- a/include/asm-ia64/sn/xpc.h
+++ b/include/asm-ia64/sn/xpc.h
@@ -508,19 +508,24 @@ struct xpc_channel {
 #define	XPC_C_OPENREQUEST	0x00000010 /* local open channel request */
 
 #define	XPC_C_SETUP		0x00000020 /* channel's msgqueues are alloc'd */
-#define	XPC_C_CONNECTCALLOUT	0x00000040 /* channel connected callout made */
-#define	XPC_C_CONNECTED		0x00000080 /* local channel is connected */
-#define	XPC_C_CONNECTING	0x00000100 /* channel is being connected */
-
-#define	XPC_C_RCLOSEREPLY	0x00000200 /* remote close channel reply */
-#define	XPC_C_CLOSEREPLY	0x00000400 /* local close channel reply */
-#define	XPC_C_RCLOSEREQUEST	0x00000800 /* remote close channel request */
-#define	XPC_C_CLOSEREQUEST	0x00001000 /* local close channel request */
-
-#define	XPC_C_DISCONNECTED	0x00002000 /* channel is disconnected */
-#define	XPC_C_DISCONNECTING	0x00004000 /* channel is being disconnected */
-#define	XPC_C_DISCONNECTCALLOUT	0x00008000 /* chan disconnected callout made */
-#define	XPC_C_WDISCONNECT	0x00010000 /* waiting for channel disconnect */
+#define	XPC_C_CONNECTEDCALLOUT	0x00000040 /* connected callout initiated */
+#define	XPC_C_CONNECTEDCALLOUT_MADE \
+				0x00000080 /* connected callout completed */
+#define	XPC_C_CONNECTED		0x00000100 /* local channel is connected */
+#define	XPC_C_CONNECTING	0x00000200 /* channel is being connected */
+
+#define	XPC_C_RCLOSEREPLY	0x00000400 /* remote close channel reply */
+#define	XPC_C_CLOSEREPLY	0x00000800 /* local close channel reply */
+#define	XPC_C_RCLOSEREQUEST	0x00001000 /* remote close channel request */
+#define	XPC_C_CLOSEREQUEST	0x00002000 /* local close channel request */
+
+#define	XPC_C_DISCONNECTED	0x00004000 /* channel is disconnected */
+#define	XPC_C_DISCONNECTING	0x00008000 /* channel is being disconnected */
+#define	XPC_C_DISCONNECTINGCALLOUT \
+				0x00010000 /* disconnecting callout initiated */
+#define	XPC_C_DISCONNECTINGCALLOUT_MADE \
+				0x00020000 /* disconnecting callout completed */
+#define	XPC_C_WDISCONNECT	0x00040000 /* waiting for channel disconnect */
 
 
 

diff-tree c2a4969ba14e852bf4ee92c7db3b0cf82405a0c9 (from 9c65cb9be62ac4993a5b392304b82e4f04f010fd)
Author: Dean Roe <roe@sgi.com>
Date:   Tue Feb 14 15:01:23 2006 -0600

    [IA64-SGI] fix the size of __sn_cnodeid_to_nasid
    
    The __sn_cnodeid_to_nasid array was incorrectly sized at MAX_NUMNODES.
    On a large system, this array could overflow.  The following patch
    corrects this by defining it to MAX_COMPACT_NODES.
    
    Signed-off-by: Dean Roe <roe@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
index 1672eca..5b84836 100644
--- a/arch/ia64/sn/kernel/setup.c
+++ b/arch/ia64/sn/kernel/setup.c
@@ -75,7 +75,7 @@ EXPORT_SYMBOL(sn_rtc_cycles_per_second);
 DEFINE_PER_CPU(struct sn_hub_info_s, __sn_hub_info);
 EXPORT_PER_CPU_SYMBOL(__sn_hub_info);
 
-DEFINE_PER_CPU(short, __sn_cnodeid_to_nasid[MAX_NUMNODES]);
+DEFINE_PER_CPU(short, __sn_cnodeid_to_nasid[MAX_COMPACT_NODES]);
 EXPORT_PER_CPU_SYMBOL(__sn_cnodeid_to_nasid);
 
 DEFINE_PER_CPU(struct nodepda_s *, __sn_nodepda);
diff --git a/include/asm-ia64/sn/arch.h b/include/asm-ia64/sn/arch.h
index 1a3831c..91c31be 100644
--- a/include/asm-ia64/sn/arch.h
+++ b/include/asm-ia64/sn/arch.h
@@ -70,7 +70,7 @@ DECLARE_PER_CPU(struct sn_hub_info_s, __
  * Compact node ID to nasid mappings kept in the per-cpu data areas of each
  * cpu.
  */
-DECLARE_PER_CPU(short, __sn_cnodeid_to_nasid[MAX_NUMNODES]);
+DECLARE_PER_CPU(short, __sn_cnodeid_to_nasid[MAX_COMPACT_NODES]);
 #define sn_cnodeid_to_nasid	(&__get_cpu_var(__sn_cnodeid_to_nasid[0]))
 
 

diff-tree 9c65cb9be62ac4993a5b392304b82e4f04f010fd (from 26d10915de3030a55253dba3b2b145402cdf6429)
Author: Mark Maule <maule@sgi.com>
Date:   Tue Feb 14 10:23:37 2006 -0600

    [IA64-SGI] export sn_pcidev_info_get
    
    Export sn_pcidev_info_get.
    
    Signed-off-by Mark Maule <maule@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/sn/kernel/io_init.c b/arch/ia64/sn/kernel/io_init.c
index dfb3f29..3edef0d 100644
--- a/arch/ia64/sn/kernel/io_init.c
+++ b/arch/ia64/sn/kernel/io_init.c
@@ -716,3 +716,4 @@ EXPORT_SYMBOL(sn_pci_unfixup_slot);
 EXPORT_SYMBOL(sn_pci_controller_fixup);
 EXPORT_SYMBOL(sn_bus_store_sysdata);
 EXPORT_SYMBOL(sn_bus_free_sysdata);
+EXPORT_SYMBOL(sn_pcidev_info_get);

diff-tree 26d10915de3030a55253dba3b2b145402cdf6429 (from d3454344b3507042e5d561d0cfed19e99cf2fc88)
Author: Jes Sorensen <jes@sgi.com>
Date:   Mon Feb 13 05:35:01 2006 -0500

    [IA64-SGI] remove compile time warning
    
    This one falls into the "present for Andrew Morton" category to address
    his wishlist for a compiler warning free build ;-)
    
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
index 48645ac..1672eca 100644
--- a/arch/ia64/sn/kernel/setup.c
+++ b/arch/ia64/sn/kernel/setup.c
@@ -317,6 +317,7 @@ struct pcdp_vga_device {
 #define PCDP_PCI_TRANS_IOPORT	0x02
 #define PCDP_PCI_TRANS_MMIO	0x01
 
+#if defined(CONFIG_VT) && defined(CONFIG_VGA_CONSOLE)
 static void
 sn_scan_pcdp(void)
 {
@@ -358,6 +359,7 @@ sn_scan_pcdp(void)
 		break; /* once we find the primary, we're done */
 	}
 }
+#endif
 
 static unsigned long sn2_rtc_initial;
 

diff-tree d3454344b3507042e5d561d0cfed19e99cf2fc88 (from 8ed9b2c7a804335004e4bd3b4c6989c5b6bc243f)
Author: Jes Sorensen <jes@sgi.com>
Date:   Mon Feb 13 05:32:09 2006 -0500

    [IA64] remove obsolete corporate address
    
    Remove obsolete SGI address
    
    Signed-off-by: Jes Sorensen <jes@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/sn/kernel/sn2/timer_interrupt.c b/arch/ia64/sn/kernel/sn2/timer_interrupt.c
index adf5db2..fa7f699 100644
--- a/arch/ia64/sn/kernel/sn2/timer_interrupt.c
+++ b/arch/ia64/sn/kernel/sn2/timer_interrupt.c
@@ -1,7 +1,7 @@
 /*
  *
  *
- * Copyright (c) 2005 Silicon Graphics, Inc.  All Rights Reserved.
+ * Copyright (c) 2005, 2006 Silicon Graphics, Inc.  All Rights Reserved.
  * 
  * This program is free software; you can redistribute it and/or modify it 
  * under the terms of version 2 of the GNU General Public License 
@@ -22,11 +22,6 @@
  * License along with this program; if not, write the Free Software 
  * Foundation, Inc., 59 Temple Place - Suite 330, Boston MA 02111-1307, USA.
  * 
- * Contact information:  Silicon Graphics, Inc., 1600 Amphitheatre Pkwy, 
- * Mountain View, CA  94043, or:
- * 
- * http://www.sgi.com 
- * 
  * For further information regarding this notice, see: 
  * 
  * http://oss.sgi.com/projects/GenInfo/NoticeExplan
diff --git a/drivers/ide/pci/sgiioc4.c b/drivers/ide/pci/sgiioc4.c
index 2b286e8..43b96e2 100644
--- a/drivers/ide/pci/sgiioc4.c
+++ b/drivers/ide/pci/sgiioc4.c
@@ -13,11 +13,6 @@
  * License along with this program; if not, write the Free Software
  * Foundation, Inc., 59 Temple Place - Suite 330, Boston MA 02111-1307, USA.
  *
- * Contact information:  Silicon Graphics, Inc., 1600 Amphitheatre Pkwy,
- * Mountain View, CA  94043, or:
- *
- * http://www.sgi.com
- *
  * For further information regarding this notice, see:
  *
  * http://oss.sgi.com/projects/GenInfo/NoticeExplan
diff --git a/include/asm-ia64/machvec_sn2.h b/include/asm-ia64/machvec_sn2.h
index e1b6cd6..03d00fa 100644
--- a/include/asm-ia64/machvec_sn2.h
+++ b/include/asm-ia64/machvec_sn2.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2002-2003 Silicon Graphics, Inc.  All Rights Reserved.
+ * Copyright (c) 2002-2003, 2006 Silicon Graphics, Inc.  All Rights Reserved.
  * 
  * This program is free software; you can redistribute it and/or modify it 
  * under the terms of version 2 of the GNU General Public License 
@@ -20,11 +20,6 @@
  * License along with this program; if not, write the Free Software 
  * Foundation, Inc., 59 Temple Place - Suite 330, Boston MA 02111-1307, USA.
  * 
- * Contact information:  Silicon Graphics, Inc., 1600 Amphitheatre Pkwy, 
- * Mountain View, CA  94043, or:
- * 
- * http://www.sgi.com 
- * 
  * For further information regarding this notice, see: 
  * 
  * http://oss.sgi.com/projects/GenInfo/NoticeExplan

diff-tree 8ed9b2c7a804335004e4bd3b4c6989c5b6bc243f (from 50d8e59038703c4da5acaed9afaa37ae416d3153)
Author: Jes Sorensen <jes@sgi.com>
Date:   Mon Feb 13 05:29:57 2006 -0500

    [IA64-SGI] sn2 minor fixes and cleanups
    
    General SN2 code cleanup:
     - Do not initialize global variables to zero
     - Use kzalloc instead of kmalloc+memset
     - Check kmalloc return values
     - Do not obfuscate spin lock calls
     - Remove some unused code
     - Various formatting cleanups
    
    Signed-off-by: Jes Sorensen <jes@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/sn/kernel/io_init.c b/arch/ia64/sn/kernel/io_init.c
index 3437c23..dfb3f29 100644
--- a/arch/ia64/sn/kernel/io_init.c
+++ b/arch/ia64/sn/kernel/io_init.c
@@ -23,6 +23,10 @@
 #include "xtalk/hubdev.h"
 #include "xtalk/xwidgetdev.h"
 
+
+extern void sn_init_cpei_timer(void);
+extern void register_sn_procfs(void);
+
 static struct list_head sn_sysdata_list;
 
 /* sysdata list struct */
@@ -40,12 +44,12 @@ struct brick {
 	struct slab_info slab_info[MAX_SLABS + 1];
 };
 
-int sn_ioif_inited = 0;		/* SN I/O infrastructure initialized? */
+int sn_ioif_inited;		/* SN I/O infrastructure initialized? */
 
 struct sn_pcibus_provider *sn_pci_provider[PCIIO_ASIC_MAX_TYPES];	/* indexed by asic type */
 
-static int max_segment_number = 0; /* Default highest segment number */
-static int max_pcibus_number = 255; /* Default highest pci bus number */
+static int max_segment_number;		 /* Default highest segment number */
+static int max_pcibus_number = 255;	/* Default highest pci bus number */
 
 /*
  * Hooks and struct for unsupported pci providers
@@ -84,7 +88,6 @@ static inline u64
 sal_get_device_dmaflush_list(u64 nasid, u64 widget_num, u64 device_num,
 			     u64 address)
 {
-
 	struct ia64_sal_retval ret_stuff;
 	ret_stuff.status = 0;
 	ret_stuff.v0 = 0;
@@ -94,7 +97,6 @@ sal_get_device_dmaflush_list(u64 nasid, 
 			(u64) nasid, (u64) widget_num,
 			(u64) device_num, (u64) address, 0, 0, 0);
 	return ret_stuff.status;
-
 }
 
 /*
@@ -102,7 +104,6 @@ sal_get_device_dmaflush_list(u64 nasid, 
  */
 static inline u64 sal_get_hubdev_info(u64 handle, u64 address)
 {
-
 	struct ia64_sal_retval ret_stuff;
 	ret_stuff.status = 0;
 	ret_stuff.v0 = 0;
@@ -118,7 +119,6 @@ static inline u64 sal_get_hubdev_info(u6
  */
 static inline u64 sal_get_pcibus_info(u64 segment, u64 busnum, u64 address)
 {
-
 	struct ia64_sal_retval ret_stuff;
 	ret_stuff.status = 0;
 	ret_stuff.v0 = 0;
@@ -215,7 +215,7 @@ static void __init sn_fixup_ionodes(void
 	struct hubdev_info *hubdev;
 	u64 status;
 	u64 nasid;
-	int i, widget, device;
+	int i, widget, device, size;
 
 	/*
 	 * Get SGI Specific HUB chipset information.
@@ -251,48 +251,37 @@ static void __init sn_fixup_ionodes(void
 		if (!hubdev->hdi_flush_nasid_list.widget_p)
 			continue;
 
+		size = (HUB_WIDGET_ID_MAX + 1) *
+			sizeof(struct sn_flush_device_kernel *);
 		hubdev->hdi_flush_nasid_list.widget_p -		    kmalloc((HUB_WIDGET_ID_MAX + 1) *
-			    sizeof(struct sn_flush_device_kernel *),
-			    GFP_KERNEL);
-		memset(hubdev->hdi_flush_nasid_list.widget_p, 0x0,
-		       (HUB_WIDGET_ID_MAX + 1) *
-		       sizeof(struct sn_flush_device_kernel *));
+			kzalloc(size, GFP_KERNEL);
+		if (!hubdev->hdi_flush_nasid_list.widget_p)
+			BUG();
 
 		for (widget = 0; widget <= HUB_WIDGET_ID_MAX; widget++) {
-			sn_flush_device_kernel = kmalloc(DEV_PER_WIDGET *
-						         sizeof(struct
-						        sn_flush_device_kernel),
-						        GFP_KERNEL);
+			size = DEV_PER_WIDGET *
+				sizeof(struct sn_flush_device_kernel);
+			sn_flush_device_kernel = kzalloc(size, GFP_KERNEL);
 			if (!sn_flush_device_kernel)
 				BUG();
-			memset(sn_flush_device_kernel, 0x0,
-			       DEV_PER_WIDGET *
-			       sizeof(struct sn_flush_device_kernel));
 
 			dev_entry = sn_flush_device_kernel;
 			for (device = 0; device < DEV_PER_WIDGET;
 			     device++,dev_entry++) {
-				dev_entry->common = kmalloc(sizeof(struct
-					      	        sn_flush_device_common),
-					                    GFP_KERNEL);
+				size = sizeof(struct sn_flush_device_common);
+				dev_entry->common = kzalloc(size, GFP_KERNEL);
 				if (!dev_entry->common)
 					BUG();
-				memset(dev_entry->common, 0x0, sizeof(struct
-					     	       sn_flush_device_common));
 
 				if (sn_prom_feature_available(
 						       PRF_DEVICE_FLUSH_LIST))
 					status = sal_get_device_dmaflush_list(
-									  nasid,
-									 widget,
-								       	 device,
-						      (u64)(dev_entry->common));
+						     nasid, widget, device,
+						     (u64)(dev_entry->common));
 				else
 					status = sn_device_fixup_war(nasid,
-								     widget,
-							    	     device,
-							     dev_entry->common);
+						     widget, device,
+						     dev_entry->common);
 				if (status != SALRET_OK)
 					panic("SAL call failed: %s\n",
 					      ia64_sal_strerror(status));
@@ -383,13 +372,12 @@ void sn_pci_fixup_slot(struct pci_dev *d
 
 	pci_dev_get(dev); /* for the sysdata pointer */
 	pcidev_info = kzalloc(sizeof(struct pcidev_info), GFP_KERNEL);
-	if (pcidev_info <= 0)
+	if (!pcidev_info)
 		BUG();		/* Cannot afford to run out of memory */
 
-	sn_irq_info = kmalloc(sizeof(struct sn_irq_info), GFP_KERNEL);
-	if (sn_irq_info <= 0)
+	sn_irq_info = kzalloc(sizeof(struct sn_irq_info), GFP_KERNEL);
+	if (!sn_irq_info)
 		BUG();		/* Cannot afford to run out of memory */
-	memset(sn_irq_info, 0, sizeof(struct sn_irq_info));
 
 	/* Call to retrieve pci device information needed by kernel. */
 	status = sal_get_pcidev_info((u64) segment, (u64) dev->bus->number, 
@@ -482,13 +470,13 @@ void sn_pci_fixup_slot(struct pci_dev *d
  */
 void sn_pci_controller_fixup(int segment, int busnum, struct pci_bus *bus)
 {
-	int status = 0;
+	int status;
 	int nasid, cnode;
 	struct pci_controller *controller;
 	struct sn_pci_controller *sn_controller;
 	struct pcibus_bussoft *prom_bussoft_ptr;
 	struct hubdev_info *hubdev_info;
-	void *provider_soft = NULL;
+	void *provider_soft;
 	struct sn_pcibus_provider *provider;
 
  	status = sal_get_pcibus_info((u64) segment, (u64) busnum,
@@ -535,6 +523,8 @@ void sn_pci_controller_fixup(int segment
 	bus->sysdata = controller;
 	if (provider->bus_fixup)
 		provider_soft = (*provider->bus_fixup) (prom_bussoft_ptr, controller);
+	else
+		provider_soft = NULL;
 
 	if (provider_soft = NULL) {
 		/* fixup failed or not applicable */
@@ -638,13 +628,8 @@ void sn_bus_free_sysdata(void)
 
 static int __init sn_pci_init(void)
 {
-	int i = 0;
-	int j = 0;
+	int i, j;
 	struct pci_dev *pci_dev = NULL;
-	extern void sn_init_cpei_timer(void);
-#ifdef CONFIG_PROC_FS
-	extern void register_sn_procfs(void);
-#endif
 
 	if (!ia64_platform_is("sn2") || IS_RUNNING_ON_FAKE_PROM())
 		return 0;
@@ -700,32 +685,29 @@ static int __init sn_pci_init(void)
  */
 void hubdev_init_node(nodepda_t * npda, cnodeid_t node)
 {
-
 	struct hubdev_info *hubdev_info;
+	int size;
+	pg_data_t *pg;
+
+	size = sizeof(struct hubdev_info);
 
 	if (node >= num_online_nodes())	/* Headless/memless IO nodes */
-		hubdev_info -		    (struct hubdev_info *)alloc_bootmem_node(NODE_DATA(0),
-							     sizeof(struct
-								    hubdev_info));
+		pg = NODE_DATA(0);
 	else
-		hubdev_info -		    (struct hubdev_info *)alloc_bootmem_node(NODE_DATA(node),
-							     sizeof(struct
-								    hubdev_info));
-	npda->pdinfo = (void *)hubdev_info;
+		pg = NODE_DATA(node);
 
+	hubdev_info = (struct hubdev_info *)alloc_bootmem_node(pg, size);
+
+	npda->pdinfo = (void *)hubdev_info;
 }
 
 geoid_t
 cnodeid_get_geoid(cnodeid_t cnode)
 {
-
 	struct hubdev_info *hubdev;
 
 	hubdev = (struct hubdev_info *)(NODEPDA(cnode)->pdinfo);
 	return hubdev->hdi_geoid;
-
 }
 
 subsys_initcall(sn_pci_init);
diff --git a/arch/ia64/sn/kernel/sn2/prominfo_proc.c b/arch/ia64/sn/kernel/sn2/prominfo_proc.c
index 81c63b2..6ae276d 100644
--- a/arch/ia64/sn/kernel/sn2/prominfo_proc.c
+++ b/arch/ia64/sn/kernel/sn2/prominfo_proc.c
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 1999,2001-2004 Silicon Graphics, Inc.  All Rights Reserved.
+ * Copyright (C) 1999,2001-2004, 2006 Silicon Graphics, Inc.  All Rights Reserved.
  *
  * Module to export the system's Firmware Interface Tables, including
  * PROM revision numbers and banners, in /proc
@@ -190,7 +190,7 @@ static int
 read_version_entry(char *page, char **start, off_t off, int count, int *eof,
 		   void *data)
 {
-	int len = 0;
+	int len;
 
 	/* data holds the NASID of the node */
 	len = dump_version(page, (unsigned long)data);
@@ -202,7 +202,7 @@ static int
 read_fit_entry(char *page, char **start, off_t off, int count, int *eof,
 	       void *data)
 {
-	int len = 0;
+	int len;
 
 	/* data holds the NASID of the node */
 	len = dump_fit(page, (unsigned long)data);
@@ -229,13 +229,16 @@ int __init prominfo_init(void)
 	struct proc_dir_entry *p;
 	cnodeid_t cnodeid;
 	unsigned long nasid;
+	int size;
 	char name[NODE_NAME_LEN];
 
 	if (!ia64_platform_is("sn2"))
 		return 0;
 
-	proc_entries = kmalloc(num_online_nodes() * sizeof(struct proc_dir_entry *),
-			       GFP_KERNEL);
+	size = num_online_nodes() * sizeof(struct proc_dir_entry *);
+	proc_entries = kzalloc(size, GFP_KERNEL);
+	if (!proc_entries)
+		return -ENOMEM;
 
 	sgi_prominfo_entry = proc_mkdir("sgi_prominfo", NULL);
 
@@ -244,14 +247,12 @@ int __init prominfo_init(void)
 		sprintf(name, "node%d", cnodeid);
 		*entp = proc_mkdir(name, sgi_prominfo_entry);
 		nasid = cnodeid_to_nasid(cnodeid);
-		p = create_proc_read_entry(
-			"fit", 0, *entp, read_fit_entry,
-			(void *)nasid);
+		p = create_proc_read_entry("fit", 0, *entp, read_fit_entry,
+					   (void *)nasid);
 		if (p)
 			p->owner = THIS_MODULE;
-		p = create_proc_read_entry(
-			"version", 0, *entp, read_version_entry,
-			(void *)nasid);
+		p = create_proc_read_entry("version", 0, *entp,
+					   read_version_entry, (void *)nasid);
 		if (p)
 			p->owner = THIS_MODULE;
 		entp++;
@@ -263,7 +264,7 @@ int __init prominfo_init(void)
 void __exit prominfo_exit(void)
 {
 	struct proc_dir_entry **entp;
-	unsigned cnodeid;
+	unsigned int cnodeid;
 	char name[NODE_NAME_LEN];
 
 	entp = proc_entries;
diff --git a/arch/ia64/sn/kernel/sn2/sn2_smp.c b/arch/ia64/sn/kernel/sn2/sn2_smp.c
index f153a4c..24eefb2 100644
--- a/arch/ia64/sn/kernel/sn2/sn2_smp.c
+++ b/arch/ia64/sn/kernel/sn2/sn2_smp.c
@@ -46,8 +46,14 @@ DECLARE_PER_CPU(struct ptc_stats, ptcsta
 
 static  __cacheline_aligned DEFINE_SPINLOCK(sn2_global_ptc_lock);
 
-void sn2_ptc_deadlock_recovery(short *, short, short, int, volatile unsigned long *, unsigned long,
-	volatile unsigned long *, unsigned long);
+extern unsigned long
+sn2_ptc_deadlock_recovery_core(volatile unsigned long *, unsigned long,
+			       volatile unsigned long *, unsigned long,
+			       volatile unsigned long *, unsigned long);
+void
+sn2_ptc_deadlock_recovery(short *, short, short, int,
+			  volatile unsigned long *, unsigned long,
+			  volatile unsigned long *, unsigned long);
 
 /*
  * Note: some is the following is captured here to make degugging easier
@@ -59,16 +65,6 @@ void sn2_ptc_deadlock_recovery(short *, 
 #define reset_max_active_on_deadlock()	1
 #define PTC_LOCK(sh1)			((sh1) ? &sn2_global_ptc_lock : &sn_nodepda->ptc_lock)
 
-static inline void ptc_lock(int sh1, unsigned long *flagp)
-{
-	spin_lock_irqsave(PTC_LOCK(sh1), *flagp);
-}
-
-static inline void ptc_unlock(int sh1, unsigned long flags)
-{
-	spin_unlock_irqrestore(PTC_LOCK(sh1), flags);
-}
-
 struct ptc_stats {
 	unsigned long ptc_l;
 	unsigned long change_rid;
@@ -82,6 +78,8 @@ struct ptc_stats {
 	unsigned long shub_ptc_flushes_not_my_mm;
 };
 
+#define sn2_ptctest	0
+
 static inline unsigned long wait_piowc(void)
 {
 	volatile unsigned long *piows;
@@ -200,7 +198,7 @@ sn2_global_tlb_purge(struct mm_struct *m
 	max_active = max_active_pio(shub1);
 
 	itc = ia64_get_itc();
-	ptc_lock(shub1, &flags);
+	spin_lock_irqsave(PTC_LOCK(shub1), flags);
 	itc2 = ia64_get_itc();
 
 	__get_cpu_var(ptcstats).lock_itc_clocks += itc2 - itc;
@@ -258,7 +256,7 @@ sn2_global_tlb_purge(struct mm_struct *m
 		ia64_srlz_d();
 	}
 
-	ptc_unlock(shub1, flags);
+	spin_unlock_irqrestore(PTC_LOCK(shub1), flags);
 
 	preempt_enable();
 }
@@ -270,11 +268,12 @@ sn2_global_tlb_purge(struct mm_struct *m
  * TLB flush transaction.  The recovery sequence is somewhat tricky & is
  * coded in assembly language.
  */
-void sn2_ptc_deadlock_recovery(short *nasids, short ib, short ie, int mynasid, volatile unsigned long *ptc0, unsigned long data0,
-	volatile unsigned long *ptc1, unsigned long data1)
+
+void
+sn2_ptc_deadlock_recovery(short *nasids, short ib, short ie, int mynasid,
+			  volatile unsigned long *ptc0, unsigned long data0,
+			  volatile unsigned long *ptc1, unsigned long data1)
 {
-	extern unsigned long sn2_ptc_deadlock_recovery_core(volatile unsigned long *, unsigned long,
-	        volatile unsigned long *, unsigned long, volatile unsigned long *, unsigned long);
 	short nasid, i;
 	unsigned long *piows, zeroval, n;
 
diff --git a/arch/ia64/sn/kernel/sn2/sn_proc_fs.c b/arch/ia64/sn/kernel/sn2/sn_proc_fs.c
index a06719d..c686d9c 100644
--- a/arch/ia64/sn/kernel/sn2/sn_proc_fs.c
+++ b/arch/ia64/sn/kernel/sn2/sn_proc_fs.c
@@ -6,11 +6,11 @@
  * Copyright (C) 2000-2005 Silicon Graphics, Inc. All rights reserved.
  */
 #include <linux/config.h>
-#include <asm/uaccess.h>
 
 #ifdef CONFIG_PROC_FS
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
+#include <asm/uaccess.h>
 #include <asm/sn/sn_sal.h>
 
 static int partition_id_show(struct seq_file *s, void *p)
@@ -90,10 +90,10 @@ static int coherence_id_open(struct inod
 	return single_open(file, coherence_id_show, NULL);
 }
 
-static struct proc_dir_entry *sn_procfs_create_entry(
-	const char *name, struct proc_dir_entry *parent,
-	int (*openfunc)(struct inode *, struct file *),
-	int (*releasefunc)(struct inode *, struct file *))
+static struct proc_dir_entry
+*sn_procfs_create_entry(const char *name, struct proc_dir_entry *parent,
+			int (*openfunc)(struct inode *, struct file *),
+			int (*releasefunc)(struct inode *, struct file *))
 {
 	struct proc_dir_entry *e = create_proc_entry(name, 0444, parent);
 
@@ -126,24 +126,24 @@ void register_sn_procfs(void)
 		return;
 
 	sn_procfs_create_entry("partition_id", sgi_proc_dir,
-		partition_id_open, single_release);
+			       partition_id_open, single_release);
 
 	sn_procfs_create_entry("system_serial_number", sgi_proc_dir,
-		system_serial_number_open, single_release);
+			       system_serial_number_open, single_release);
 
 	sn_procfs_create_entry("licenseID", sgi_proc_dir, 
-		licenseID_open, single_release);
+			       licenseID_open, single_release);
 
 	e = sn_procfs_create_entry("sn_force_interrupt", sgi_proc_dir, 
-		sn_force_interrupt_open, single_release);
+				   sn_force_interrupt_open, single_release);
 	if (e) 
 		e->proc_fops->write = sn_force_interrupt_write_proc;
 
 	sn_procfs_create_entry("coherence_id", sgi_proc_dir, 
-		coherence_id_open, single_release);
+			       coherence_id_open, single_release);
 	
 	sn_procfs_create_entry("sn_topology", sgi_proc_dir,
-		sn_topology_open, sn_topology_release);
+			       sn_topology_open, sn_topology_release);
 }
 
 #endif /* CONFIG_PROC_FS */
diff --git a/arch/ia64/sn/kernel/tiocx.c b/arch/ia64/sn/kernel/tiocx.c
index d263d3e..8a56f8b 100644
--- a/arch/ia64/sn/kernel/tiocx.c
+++ b/arch/ia64/sn/kernel/tiocx.c
@@ -284,12 +284,10 @@ struct sn_irq_info *tiocx_irq_alloc(nasi
 	if ((nasid & 1) = 0)
 		return NULL;
 
-	sn_irq_info = kmalloc(sn_irq_size, GFP_KERNEL);
+	sn_irq_info = kzalloc(sn_irq_size, GFP_KERNEL);
 	if (sn_irq_info = NULL)
 		return NULL;
 
-	memset(sn_irq_info, 0x0, sn_irq_size);
-
 	status = tiocx_intr_alloc(nasid, widget, __pa(sn_irq_info), irq,
 				  req_nasid, slice);
 	if (status) {
diff --git a/arch/ia64/sn/pci/pci_dma.c b/arch/ia64/sn/pci/pci_dma.c
index 5a36292..b4b84c2 100644
--- a/arch/ia64/sn/pci/pci_dma.c
+++ b/arch/ia64/sn/pci/pci_dma.c
@@ -335,10 +335,10 @@ int sn_pci_legacy_read(struct pci_bus *b
 	 */
 
 	SAL_CALL(isrv, SN_SAL_IOIF_PCI_SAFE,
-		pci_domain_nr(bus), bus->number,
-		0, /* io */
-		0, /* read */
-		port, size, __pa(val));
+		 pci_domain_nr(bus), bus->number,
+		 0, /* io */
+		 0, /* read */
+		 port, size, __pa(val));
 
 	if (isrv.status = 0)
 		return size;
@@ -381,10 +381,10 @@ int sn_pci_legacy_write(struct pci_bus *
 	 */
 
 	SAL_CALL(isrv, SN_SAL_IOIF_PCI_SAFE,
-		pci_domain_nr(bus), bus->number,
-		0, /* io */
-		1, /* write */
-		port, size, __pa(&val));
+		 pci_domain_nr(bus), bus->number,
+		 0, /* io */
+		 1, /* write */
+		 port, size, __pa(&val));
 
 	if (isrv.status = 0)
 		return size;
diff --git a/arch/ia64/sn/pci/pcibr/pcibr_ate.c b/arch/ia64/sn/pci/pcibr/pcibr_ate.c
index aa3fa51..1f0253b 100644
--- a/arch/ia64/sn/pci/pcibr/pcibr_ate.c
+++ b/arch/ia64/sn/pci/pcibr/pcibr_ate.c
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 2001-2004 Silicon Graphics, Inc. All rights reserved.
+ * Copyright (C) 2001-2006 Silicon Graphics, Inc. All rights reserved.
  */
 
 #include <linux/types.h>
@@ -12,7 +12,7 @@
 #include <asm/sn/pcibus_provider_defs.h>
 #include <asm/sn/pcidev.h>
 
-int pcibr_invalidate_ate = 0;	/* by default don't invalidate ATE on free */
+int pcibr_invalidate_ate;	/* by default don't invalidate ATE on free */
 
 /*
  * mark_ate: Mark the ate as either free or inuse.
@@ -20,14 +20,12 @@ int pcibr_invalidate_ate = 0;	/* by defa
 static void mark_ate(struct ate_resource *ate_resource, int start, int number,
 		     u64 value)
 {
-
 	u64 *ate = ate_resource->ate;
 	int index;
 	int length = 0;
 
 	for (index = start; length < number; index++, length++)
 		ate[index] = value;
-
 }
 
 /*
@@ -37,7 +35,6 @@ static void mark_ate(struct ate_resource
 static int find_free_ate(struct ate_resource *ate_resource, int start,
 			 int count)
 {
-
 	u64 *ate = ate_resource->ate;
 	int index;
 	int start_free;
@@ -70,12 +67,10 @@ static int find_free_ate(struct ate_reso
 static inline void free_ate_resource(struct ate_resource *ate_resource,
 				     int start)
 {
-
 	mark_ate(ate_resource, start, ate_resource->ate[start], 0);
 	if ((ate_resource->lowest_free_index > start) ||
 	    (ate_resource->lowest_free_index < 0))
 		ate_resource->lowest_free_index = start;
-
 }
 
 /*
@@ -84,7 +79,6 @@ static inline void free_ate_resource(str
 static inline int alloc_ate_resource(struct ate_resource *ate_resource,
 				     int ate_needed)
 {
-
 	int start_index;
 
 	/*
@@ -118,19 +112,12 @@ static inline int alloc_ate_resource(str
  */
 int pcibr_ate_alloc(struct pcibus_info *pcibus_info, int count)
 {
-	int status = 0;
-	u64 flag;
+	int status;
+	unsigned long flags;
 
-	flag = pcibr_lock(pcibus_info);
+	spin_lock_irqsave(&pcibus_info->pbi_lock, flags);
 	status = alloc_ate_resource(&pcibus_info->pbi_int_ate_resource, count);
-
-	if (status < 0) {
-		/* Failed to allocate */
-		pcibr_unlock(pcibus_info, flag);
-		return -1;
-	}
-
-	pcibr_unlock(pcibus_info, flag);
+	spin_unlock_irqrestore(&pcibus_info->pbi_lock, flags);
 
 	return status;
 }
@@ -182,7 +169,7 @@ void pcibr_ate_free(struct pcibus_info *
 		ate_write(pcibus_info, index, count, (ate & ~PCI32_ATE_V));
 	}
 
-	flags = pcibr_lock(pcibus_info);
+	spin_lock_irqsave(&pcibus_info->pbi_lock, flags);
 	free_ate_resource(&pcibus_info->pbi_int_ate_resource, index);
-	pcibr_unlock(pcibus_info, flags);
+	spin_unlock_irqrestore(&pcibus_info->pbi_lock, flags);
 }
diff --git a/arch/ia64/sn/pci/pcibr/pcibr_dma.c b/arch/ia64/sn/pci/pcibr/pcibr_dma.c
index 54ce5b7..9f86bb6 100644
--- a/arch/ia64/sn/pci/pcibr/pcibr_dma.c
+++ b/arch/ia64/sn/pci/pcibr/pcibr_dma.c
@@ -137,14 +137,12 @@ pcibr_dmatrans_direct64(struct pcidev_in
 		pci_addr |= PCI64_ATTR_VIRTUAL;
 
 	return pci_addr;
-
 }
 
 static dma_addr_t
 pcibr_dmatrans_direct32(struct pcidev_info * info,
 			u64 paddr, size_t req_size, u64 flags)
 {
-
 	struct pcidev_info *pcidev_info = info->pdi_host_pcidev_info;
 	struct pcibus_info *pcibus_info = (struct pcibus_info *)pcidev_info->
 	    pdi_pcibus_info;
@@ -171,7 +169,6 @@ pcibr_dmatrans_direct32(struct pcidev_in
 	}
 
 	return PCI32_DIRECT_BASE | offset;
-
 }
 
 /*
@@ -218,9 +215,8 @@ void sn_dma_flush(u64 addr)
 	u64 flags;
 	u64 itte;
 	struct hubdev_info *hubinfo;
-	volatile struct sn_flush_device_kernel *p;
-	volatile struct sn_flush_device_common *common;
-
+	struct sn_flush_device_kernel *p;
+	struct sn_flush_device_common *common;
 	struct sn_flush_nasid_entry *flush_nasid_list;
 
 	if (!sn_ioif_inited)
@@ -310,8 +306,7 @@ void sn_dma_flush(u64 addr)
 					     (common->sfdl_slot - 1));
 		}
 	} else {
-		spin_lock_irqsave((spinlock_t *)&p->sfdl_flush_lock,
-				  flags);
+		spin_lock_irqsave(&p->sfdl_flush_lock, flags);
 		*common->sfdl_flush_addr = 0;
 
 		/* force an interrupt. */
@@ -322,8 +317,7 @@ void sn_dma_flush(u64 addr)
 			cpu_relax();
 
 		/* okay, everything is synched up. */
-		spin_unlock_irqrestore((spinlock_t *)&p->sfdl_flush_lock,
-				       flags);
+		spin_unlock_irqrestore(&p->sfdl_flush_lock, flags);
 	}
 	return;
 }
diff --git a/arch/ia64/sn/pci/pcibr/pcibr_provider.c b/arch/ia64/sn/pci/pcibr/pcibr_provider.c
index 2fac270..98f716b 100644
--- a/arch/ia64/sn/pci/pcibr/pcibr_provider.c
+++ b/arch/ia64/sn/pci/pcibr/pcibr_provider.c
@@ -163,9 +163,12 @@ pcibr_bus_fixup(struct pcibus_bussoft *p
 	/* Setup the PMU ATE map */
 	soft->pbi_int_ate_resource.lowest_free_index = 0;
 	soft->pbi_int_ate_resource.ate -	    kmalloc(soft->pbi_int_ate_size * sizeof(u64), GFP_KERNEL);
-	memset(soft->pbi_int_ate_resource.ate, 0,
- 	       (soft->pbi_int_ate_size * sizeof(u64)));
+	    kzalloc(soft->pbi_int_ate_size * sizeof(u64), GFP_KERNEL);
+
+	if (!soft->pbi_int_ate_resource.ate) {
+		kfree(soft);
+		return NULL;
+	}
 
 	if (prom_bussoft->bs_asic_type = PCIIO_ASIC_TYPE_TIOCP) {
 		/* TIO PCI Bridge: find nearest node with CPUs */
diff --git a/include/asm-ia64/sn/bte.h b/include/asm-ia64/sn/bte.h
index 01e5b41..5335d87 100644
--- a/include/asm-ia64/sn/bte.h
+++ b/include/asm-ia64/sn/bte.h
@@ -46,7 +46,7 @@
 #define BTES_PER_NODE (is_shub2() ? 4 : 2)
 #define MAX_BTES_PER_NODE 4
 
-#define BTE2OFF_CTRL	(0)
+#define BTE2OFF_CTRL	0
 #define BTE2OFF_SRC	(SH2_BT_ENG_SRC_ADDR_0 - SH2_BT_ENG_CSR_0)
 #define BTE2OFF_DEST	(SH2_BT_ENG_DEST_ADDR_0 - SH2_BT_ENG_CSR_0)
 #define BTE2OFF_NOTIFY	(SH2_BT_ENG_NOTIF_ADDR_0 - SH2_BT_ENG_CSR_0)
@@ -75,11 +75,11 @@
 		: base + (BTEOFF_NOTIFY/8))
 
 /* Define hardware modes */
-#define BTE_NOTIFY (IBCT_NOTIFY)
+#define BTE_NOTIFY IBCT_NOTIFY
 #define BTE_NORMAL BTE_NOTIFY
 #define BTE_ZERO_FILL (BTE_NOTIFY | IBCT_ZFIL_MODE)
 /* Use a reserved bit to let the caller specify a wait for any BTE */
-#define BTE_WACQUIRE (0x4000)
+#define BTE_WACQUIRE 0x4000
 /* Use the BTE on the node with the destination memory */
 #define BTE_USE_DEST (BTE_WACQUIRE << 1)
 /* Use any available BTE interface on any node for the transfer */
diff --git a/include/asm-ia64/sn/pcibr_provider.h b/include/asm-ia64/sn/pcibr_provider.h
index 9334078..a601d3a 100644
--- a/include/asm-ia64/sn/pcibr_provider.h
+++ b/include/asm-ia64/sn/pcibr_provider.h
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 1992-1997,2000-2004 Silicon Graphics, Inc. All rights reserved.
+ * Copyright (C) 1992-1997,2000-2006 Silicon Graphics, Inc. All rights reserved.
  */
 #ifndef _ASM_IA64_SN_PCI_PCIBR_PROVIDER_H
 #define _ASM_IA64_SN_PCI_PCIBR_PROVIDER_H
@@ -115,18 +115,6 @@ struct pcibus_info {
 	spinlock_t              pbi_lock;
 };
 
-/*
- * pcibus_info structure locking macros
- */
-inline static unsigned long
-pcibr_lock(struct pcibus_info *pcibus_info)
-{
-	unsigned long flag;
-	spin_lock_irqsave(&pcibus_info->pbi_lock, flag);
-	return(flag);
-}
-#define pcibr_unlock(pcibus_info, flag)  spin_unlock_irqrestore(&pcibus_info->pbi_lock, flag)
-
 extern int  pcibr_init_provider(void);
 extern void *pcibr_bus_fixup(struct pcibus_bussoft *, struct pci_controller *);
 extern dma_addr_t pcibr_dma_map(struct pci_dev *, unsigned long, size_t);
diff --git a/include/asm-ia64/sn/sn_feature_sets.h b/include/asm-ia64/sn/sn_feature_sets.h
index 9ca642c..ff33e3b 100644
--- a/include/asm-ia64/sn/sn_feature_sets.h
+++ b/include/asm-ia64/sn/sn_feature_sets.h
@@ -12,9 +12,6 @@
  */
 
 
-#include <asm/types.h>
-#include <asm/bitops.h>
-
 /* --------------------- PROM Features -----------------------------*/
 extern int sn_prom_feature_available(int id);
 

diff-tree 50d8e59038703c4da5acaed9afaa37ae416d3153 (from 5ecfbae093f0c37311e89b29bfc0c9d586eace87)
Author: Andreas Schwab <schwab@suse.de>
Date:   Sun Feb 12 17:01:35 2006 +0100

    [IA64] Remove duplicate EXPORT_SYMBOLs
    
    Remove symbol exports from ia64_ksyms.c that are already exported in
    lib/string.c.
    
    Signed-off-by: Andreas Schwab <schwab@suse.de>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/ia64_ksyms.c b/arch/ia64/kernel/ia64_ksyms.c
index e72de58..bbcfd08 100644
--- a/arch/ia64/kernel/ia64_ksyms.c
+++ b/arch/ia64/kernel/ia64_ksyms.c
@@ -10,23 +10,8 @@
 
 #include <linux/string.h>
 EXPORT_SYMBOL(memset);
-EXPORT_SYMBOL(memchr);
-EXPORT_SYMBOL(memcmp);
 EXPORT_SYMBOL(memcpy);
-EXPORT_SYMBOL(memmove);
-EXPORT_SYMBOL(memscan);
-EXPORT_SYMBOL(strcat);
-EXPORT_SYMBOL(strchr);
-EXPORT_SYMBOL(strcmp);
-EXPORT_SYMBOL(strcpy);
 EXPORT_SYMBOL(strlen);
-EXPORT_SYMBOL(strncat);
-EXPORT_SYMBOL(strncmp);
-EXPORT_SYMBOL(strncpy);
-EXPORT_SYMBOL(strnlen);
-EXPORT_SYMBOL(strrchr);
-EXPORT_SYMBOL(strstr);
-EXPORT_SYMBOL(strpbrk);
 
 #include <asm/checksum.h>
 EXPORT_SYMBOL(ip_fast_csum);		/* hand-coded assembly */

diff-tree a6b14fa6fdc01ab3519c2729624f808677539b59 (from 69aa234b918c0d9bc4a20cd6d4453aaa3418f457)
Author: Ashok Raj <ashok.raj@intel.com>
Date:   Tue Feb 14 15:01:12 2006 -0800

    [IA64] Count disabled cpus as potential hot-pluggable CPUs
    
    Have a facility to account for potentially hot-pluggable CPUs. ACPI doesnt
    give a determinstic method to find hot-pluggable CPUs. Hence we use 2 methods
    to assist.
    
    - BIOS can mark potentially hot-pluggable CPUs as disabled in the MADT tables.
    - User can specify the number of hot-pluggable CPUs via parameter
      additional_cpus=X
    
    The option is enabled only if ACPI_CONFIG_HOTPLUG_CPU=y which enables the
    physical hotplug option. Without which user can still use logical onlining
    and offlining of CPUs by enabling CONFIG_HOTPLUG_CPU=y
    
    Adds more bits to cpu_possible_map for potentially hot-pluggable cpus.
    
    Signed-off-by: Ashok Raj <ashok.raj@intel.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
index d2702c4..34795ed 100644
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -761,6 +761,62 @@ int acpi_map_cpu2node(acpi_handle handle
 	return (0);
 }
 
+int additional_cpus __initdata = -1;
+
+static __init int setup_additional_cpus(char *s)
+{
+	if (s)
+		additional_cpus = simple_strtol(s, NULL, 0);
+
+	return 0;
+}
+
+early_param("additional_cpus", setup_additional_cpus);
+
+/*
+ * cpu_possible_map should be static, it cannot change as cpu's
+ * are onlined, or offlined. The reason is per-cpu data-structures
+ * are allocated by some modules at init time, and dont expect to
+ * do this dynamically on cpu arrival/departure.
+ * cpu_present_map on the other hand can change dynamically.
+ * In case when cpu_hotplug is not compiled, then we resort to current
+ * behaviour, which is cpu_possible = cpu_present.
+ * - Ashok Raj
+ *
+ * Three ways to find out the number of additional hotplug CPUs:
+ * - If the BIOS specified disabled CPUs in ACPI/mptables use that.
+ * - The user can overwrite it with additional_cpus=NUM
+ * - Otherwise don't reserve additional CPUs.
+ */
+__init void prefill_possible_map(void)
+{
+	int i;
+	int possible, disabled_cpus;
+
+	disabled_cpus = total_cpus - available_cpus;
+ 	if (additional_cpus = -1) {
+ 		if (disabled_cpus > 0) {
+ 			possible = total_cpus;
+			additional_cpus = disabled_cpus;
+		}
+ 		else {
+			possible = available_cpus;
+			additional_cpus = 0;
+		}
+ 	} else {
+		possible = available_cpus + additional_cpus;
+	}
+	if (possible > NR_CPUS)
+		possible = NR_CPUS;
+
+	printk(KERN_INFO "SMP: Allowing %d CPUs, %d hotplug CPUs\n",
+		possible,
+	        max_t(int, additional_cpus, 0));
+
+	for (i = 0; i < possible; i++)
+		cpu_set(i, cpu_possible_map);
+}
+
 int acpi_map_lsapic(acpi_handle handle, int *pcpu)
 {
 	struct acpi_buffer buffer = { ACPI_ALLOCATE_BUFFER, NULL };
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index 35f7835..3258e09 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -430,6 +430,7 @@ setup_arch (char **cmdline_p)
 	if (early_console_setup(*cmdline_p) = 0)
 		mark_bsp_online();
 
+	parse_early_param();
 #ifdef CONFIG_ACPI
 	/* Initialize the ACPI boot-time table parser */
 	acpi_table_init();
@@ -688,6 +689,9 @@ void
 setup_per_cpu_areas (void)
 {
 	/* start_kernel() requires this... */
+#ifdef CONFIG_ACPI_HOTPLUG_CPU
+	prefill_possible_map();
+#endif
 }
 
 /*
diff --git a/include/asm-ia64/acpi.h b/include/asm-ia64/acpi.h
index 3a544ff..f7a5176 100644
--- a/include/asm-ia64/acpi.h
+++ b/include/asm-ia64/acpi.h
@@ -106,6 +106,8 @@ extern unsigned int can_cpei_retarget(vo
 extern unsigned int is_cpu_cpei_target(unsigned int cpu);
 extern void set_cpei_target_cpu(unsigned int cpu);
 extern unsigned int get_cpei_target_cpu(void);
+extern void prefill_possible_map(void);
+extern int additional_cpus;
 
 #ifdef CONFIG_ACPI_NUMA
 /* Proximity bitmap length; _PXM is at most 255 (8 bit)*/

diff-tree 69aa234b918c0d9bc4a20cd6d4453aaa3418f457 (from 303794400992b907b7cac0d91788603636c7e0fe)
Author: Ashok Raj <ashok.raj@intel.com>
Date:   Tue Feb 14 15:01:11 2006 -0800

    [IA64] Dont set NR_CPUS for cpu_possible_map when CPU hotplug is enabled.
    
    Do not set cpu_possible_map for NR_CPUS when ACPI_CONFIG_HOTPLUG_CPU is set.
    
    Signed-off-by: Ashok Raj <ashok.raj@intel.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
index 8f44e7d..b681ef3 100644
--- a/arch/ia64/kernel/smpboot.c
+++ b/arch/ia64/kernel/smpboot.c
@@ -129,7 +129,7 @@ DEFINE_PER_CPU(int, cpu_state);
 /* Bitmasks of currently online, and possible CPUs */
 cpumask_t cpu_online_map;
 EXPORT_SYMBOL(cpu_online_map);
-cpumask_t cpu_possible_map;
+cpumask_t cpu_possible_map = CPU_MASK_NONE;
 EXPORT_SYMBOL(cpu_possible_map);
 
 cpumask_t cpu_core_map[NR_CPUS] __cacheline_aligned;
@@ -506,9 +506,6 @@ smp_build_cpu_map (void)
 
 	for (cpu = 0; cpu < NR_CPUS; cpu++) {
 		ia64_cpu_to_sapicid[cpu] = -1;
-#ifdef CONFIG_HOTPLUG_CPU
-		cpu_set(cpu, cpu_possible_map);
-#endif
 	}
 
 	ia64_cpu_to_sapicid[0] = boot_cpu_id;
