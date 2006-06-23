From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Fri, 23 Jun 2006 08:32:36 +0000
Subject: [PATCH 2.6.17] printing support for MCA/INIT
Message-Id: <449BA724.6070904@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here is the patch for 2.6.17.
I'm not sure that still this work is NAK thing or not, but
sure that this patch make MCA handling more safe and stable.
Every comments are welcome.

H.Seto


MCA/INIT handlers are using oops_in_progress = 1 to enable
printk from these non-maskable interrupts. Originally this
value is designed for situation of oops=panic, therefore
the side effects such as hang up of syslog waiters, lost of
interrupted messages and so on are not matter if the system
is going to down.

However, in case of recoverable MCA, the handler try to
continue the interrupted system. So the side effects become
matters, ex. syslogd/klogd/monitoring-applications hang.
So this oops_in_progress = 1 makes all possible MCA recovery
unstable.

One quick solution is deleting all printk from MCA handler.
But MCA handling is very complicated thing, so printing
messages on the way is quite useful not only for developers
but also indicating result of recovery to system administrator.

This patch adds:
  ia64_mca_printk():
    function that collects messages into temporary-not-so-large
    message buffer during in MCA/INIT environment.

Buffered messages are printed out later; after returning to
normal context from MCA context (if recovered) or sooner; when
handlers determine to down the system (if not recovered).

Flushing this buffer can be invoked by:
  ia64_mlogbuf_dump:
    forward all contents in temporary-buffer to printk's message
    buffer.
  ia64_mlogbuf_finish:
    Disable buffering, shift to oops mode (oops_in_progress = 1)
    and forward all contents in temporary-buffer to printk's
    message buffer. After this call, ia64_mca_printk() is
    redirected to normal printk().

These print functions are exported for use in extensional MCA
handler and/or crash dump functions may placed in INIT handler.


Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>

---
  arch/ia64/kernel/mca.c     |  152 +++++++++++++++++++++++++++++++++++++++------
  arch/ia64/kernel/mca_drv.c |   52 ++++++++++-----
  arch/ia64/kernel/mca_drv.h |    4 +
  arch/ia64/kernel/salinfo.c |    4 +
  4 files changed, 177 insertions(+), 35 deletions(-)

Index: linux-2.6.17/arch/ia64/kernel/mca.c
=================================--- linux-2.6.17.orig/arch/ia64/kernel/mca.c
+++ linux-2.6.17/arch/ia64/kernel/mca.c
@@ -54,6 +54,9 @@
   *
   * 2005-10-07 Keith Owens <kaos@sgi.com>
   *	      Add notify_die() hooks.
+ *
+ * 2006-06-23 Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
+ * 	      Add printing support for MCA/INIT.
   */
  #include <linux/config.h>
  #include <linux/types.h>
@@ -137,11 +140,121 @@

  static int mca_init __initdata;

+/*
+ * limited & delayed printing support for MCA/INIT handler
+ */
+
+#define mprintk(fmt...) ia64_mca_printk(fmt)
+
+#define MLOGBUF_SIZE (512+256*NR_CPUS)
+static char mlogbuf[MLOGBUF_SIZE];
+static DEFINE_SPINLOCK(mlogbuf_wlock);	/* mca context only */
+static DEFINE_SPINLOCK(mlogbuf_rlock);	/* normal context only */
+static unsigned long mlogbuf_start;
+static unsigned long mlogbuf_end;
+
+/*
+ * Push messages into buffer, print them later if not urgent.
+ */
+void ia64_mca_printk(const char *fmt, ...)
+{
+	va_list args;
+	int printed_len;
+	char temp_buf[256];
+	char *p;
+
+	va_start(args, fmt);
+	printed_len = vscnprintf(temp_buf, sizeof(temp_buf), fmt, args);
+	va_end(args);
+
+	/* Copy the output into mlogbuf */
+	if (oops_in_progress) {
+		/* mlogbuf was abandoned, use printk directly instead. */
+		printk(temp_buf);
+	} else {
+		spin_lock(&mlogbuf_wlock);
+		for (p = temp_buf; *p; p++) {
+			unsigned long next = (mlogbuf_end + 1) % MLOGBUF_SIZE;
+			if (next != mlogbuf_start) {
+				mlogbuf[mlogbuf_end] = *p;
+				mlogbuf_end = next;
+			} else {
+				/* buffer full */
+				mlogbuf[mlogbuf_end] = '\0';
+				break;
+			}
+		}
+		spin_unlock(&mlogbuf_wlock);
+	}
+}
+EXPORT_SYMBOL(ia64_mca_printk);
+
+/*
+ * Print buffered messages.
+ *  NOTE: call this after returning normal context. (ex. from salinfod)
+ */
+void ia64_mlogbuf_dump(void)
+{
+	char temp_buf[256];
+	char *p;
+	unsigned long index;
+	unsigned long flags;
+
+	/* Get output from mlogbuf by line */
+	while (mlogbuf_start != mlogbuf_end) {
+		temp_buf[0] = '\0';
+		p = temp_buf;
+
+		spin_lock_irqsave(&mlogbuf_rlock, flags);
+
+		index = mlogbuf_start;
+		while (index != mlogbuf_end) {
+			*p = mlogbuf[index];
+			index = (index + 1) % MLOGBUF_SIZE;
+			if (!*p)
+				break;
+			*p++;
+		}
+		if (temp_buf[0])
+			printk(temp_buf);
+		mlogbuf_start = index;
+
+		spin_unlock_irqrestore(&mlogbuf_rlock, flags);
+	}
+}
+EXPORT_SYMBOL(ia64_mlogbuf_dump);
+
+/*
+ * Call this if system is going to down or if immediate flushing messages to
+ * console is required. (ex. recovery was failed, crash dump is going to be
+ * invoked, long-wait rendezvous etc.)
+ *  NOTE: this should be called from monarch.
+ */
+static void ia64_mlogbuf_finish(int wait)
+{
+	oops_in_progress = 1;   /* zap printk locks. */
+	console_loglevel = 15;	/* make sure printks make it to console */
+
+	spin_lock_init(&mlogbuf_rlock);
+	ia64_mlogbuf_dump();
+	printk(KERN_EMERG "mlogbuf_finish: printing switched to urgent mode, "
+		"recovery might be dodgy or fail.\n");
+
+	if (!wait)
+		return;
+
+	/* wait for console */
+	printk("Delaying for 5 seconds...\n");
+	udelay(5*1000000);
+}
+EXPORT_SYMBOL(ia64_mlogbuf_finish);

  static void inline
  ia64_mca_spin(const char *func)
  {
-	printk(KERN_EMERG "%s: spinning here, not returning to SAL\n", func);
+	if (monarch_cpu = smp_processor_id())
+		ia64_mlogbuf_finish(0);
+	mprintk(KERN_EMERG "%s: spinning here, not returning to SAL\n", func);
  	while (1)
  		cpu_relax();
  }
@@ -989,18 +1102,19 @@
  	}
  	if (!missing)
  		goto all_in;
-	printk(KERN_INFO "OS %s slave did not rendezvous on cpu", type);
+	ia64_mlogbuf_finish(0);
+	mprintk(KERN_INFO "OS %s slave did not rendezvous on cpu", type);
  	for_each_online_cpu(c) {
  		if (c = monarch)
  			continue;
  		if (ia64_mc_info.imi_rendez_checkin[c] = IA64_MCA_RENDEZ_CHECKIN_NOTDONE)
-			printk(" %d", c);
+			mprintk(" %d", c);
  	}
-	printk("\n");
+	mprintk("\n");
  	return;

  all_in:
-	printk(KERN_INFO "All OS %s slaves have reached rendezvous\n", type);
+	mprintk(KERN_INFO "All OS %s slaves have reached rendezvous\n", type);
  	return;
  }

@@ -1028,10 +1142,8 @@
  	struct ia64_mca_notify_die nd   		{ .sos = sos, .monarch_cpu = &monarch_cpu };

-	oops_in_progress = 1;	/* FIXME: make printk NMI/MCA/INIT safe */
-	console_loglevel = 15;	/* make sure printks make it to console */
-	printk(KERN_INFO "Entered OS MCA handler. PSP=%lx cpu=%d monarch=%ld\n",
-		sos->proc_state_param, cpu, sos->monarch);
+	mprintk(KERN_INFO "Entered OS MCA handler. PSP=%lx cpu=%d "
+		"monarch=%ld\n", sos->proc_state_param, cpu, sos->monarch);

  	previous_current = ia64_mca_modify_original_stack(regs, sw, sos, "MCA");
  	monarch_cpu = cpu;
@@ -1067,6 +1179,9 @@
  		rh->severity = sal_log_severity_corrected;
  		ia64_sal_clear_state_info(SAL_INFO_TYPE_MCA);
  		sos->os_status = IA64_MCA_CORRECTED;
+	} else {
+		/* Dump buffered message to console */
+		ia64_mlogbuf_finish(1);
  	}
  	if (notify_die(DIE_MCA_MONARCH_LEAVE, "MCA", regs, (long)&nd, 0, recover)
  			= NOTIFY_STOP)
@@ -1306,6 +1421,10 @@
  	struct task_struct *g, *t;
  	if (val != DIE_INIT_MONARCH_PROCESS)
  		return NOTIFY_DONE;
+
+	/* FIXME: mlogbuf will brim over with stack dumps... */
+	ia64_mlogbuf_finish(0);
+
  	printk(KERN_ERR "Processes interrupted by INIT -");
  	for_each_online_cpu(c) {
  		struct ia64_sal_os_state *s;
@@ -1358,12 +1477,9 @@
  	struct ia64_mca_notify_die nd   		{ .sos = sos, .monarch_cpu = &monarch_cpu };

-	oops_in_progress = 1;	/* FIXME: make printk NMI/MCA/INIT safe */
-	console_loglevel = 15;	/* make sure printks make it to console */
-
  	(void) notify_die(DIE_INIT_ENTER, "INIT", regs, (long)&nd, 0, 0);

-	printk(KERN_INFO "Entered OS INIT handler. PSP=%lx cpu=%d monarch=%ld\n",
+	mprintk(KERN_INFO "Entered OS INIT handler. PSP=%lx cpu=%d monarch=%ld\n",
  		sos->proc_state_param, cpu, sos->monarch);
  	salinfo_log_wakeup(SAL_INFO_TYPE_INIT, NULL, 0, 0);

@@ -1376,7 +1492,7 @@
  	 * fix their proms and get their customers updated.
  	 */
  	if (!sos->monarch && atomic_add_return(1, &slaves) = num_online_cpus()) {
-		printk(KERN_WARNING "%s: Promoting cpu %d to monarch.\n",
+		mprintk(KERN_WARNING "%s: Promoting cpu %d to monarch.\n",
  		       __FUNCTION__, cpu);
  		atomic_dec(&slaves);
  		sos->monarch = 1;
@@ -1388,7 +1504,7 @@
  	 * fix their proms and get their customers updated.
  	 */
  	if (sos->monarch && atomic_add_return(1, &monarchs) > 1) {
-		printk(KERN_WARNING "%s: Demoting cpu %d to slave.\n",
+		mprintk(KERN_WARNING "%s: Demoting cpu %d to slave.\n",
  			       __FUNCTION__, cpu);
  		atomic_dec(&monarchs);
  		sos->monarch = 0;
@@ -1409,7 +1525,7 @@
  		if (notify_die(DIE_INIT_SLAVE_LEAVE, "INIT", regs, (long)&nd, 0, 0)
  				= NOTIFY_STOP)
  			ia64_mca_spin(__FUNCTION__);
-		printk("Slave on cpu %d returning to normal service.\n", cpu);
+		mprintk("Slave on cpu %d returning to normal service.\n", cpu);
  		set_curr_task(cpu, previous_current);
  		ia64_mc_info.imi_rendez_checkin[cpu] = IA64_MCA_RENDEZ_CHECKIN_NOTDONE;
  		atomic_dec(&slaves);
@@ -1427,7 +1543,7 @@
  	 * same serial line, the user will need some time to switch out of the BMC before
  	 * the dump begins.
  	 */
-	printk("Delaying for 5 seconds...\n");
+	mprintk("Delaying for 5 seconds...\n");
  	udelay(5*1000000);
  	ia64_wait_for_slaves(cpu, "INIT");
  	/* If nobody intercepts DIE_INIT_MONARCH_PROCESS then we drop through
@@ -1440,7 +1556,7 @@
  	if (notify_die(DIE_INIT_MONARCH_LEAVE, "INIT", regs, (long)&nd, 0, 0)
  			= NOTIFY_STOP)
  		ia64_mca_spin(__FUNCTION__);
-	printk("\nINIT dump complete.  Monarch on cpu %d returning to normal service.\n", cpu);
+	mprintk("\nINIT dump complete.  Monarch on cpu %d returning to normal service.\n", cpu);
  	atomic_dec(&monarchs);
  	set_curr_task(cpu, previous_current);
  	monarch_cpu = -1;
Index: linux-2.6.17/arch/ia64/kernel/mca_drv.c
=================================--- linux-2.6.17.orig/arch/ia64/kernel/mca_drv.c
+++ linux-2.6.17/arch/ia64/kernel/mca_drv.c
@@ -80,14 +80,30 @@
  fatal_mca(const char *fmt, ...)
  {
  	va_list args;
+	char buf[256];

  	va_start(args, fmt);
-	vprintk(fmt, args);
+	vsnprintf(buf, sizeof(buf), fmt, args);
  	va_end(args);
+	ia64_mca_printk(KERN_ALERT "MCA: %s\n", buf);

  	return MCA_NOT_RECOVERED;
  }

+static int
+mca_recovered(const char *fmt, ...)
+{
+	va_list args;
+	char buf[256];
+
+	va_start(args, fmt);
+	vsnprintf(buf, sizeof(buf), fmt, args);
+	va_end(args);
+	ia64_mca_printk(KERN_INFO "MCA: %s\n", buf);
+
+	return MCA_RECOVERED;
+}
+
  /**
   * mca_page_isolate - isolate a poisoned page in order not to use it later
   * @paddr:	poisoned memory location
@@ -141,6 +157,7 @@
  void
  mca_handler_bh(unsigned long paddr, void *iip, unsigned long ipsr)
  {
+	ia64_mlogbuf_dump();
  	printk(KERN_ERR "OS_MCA: process [cpu %d, pid: %d, uid: %d, "
  		"iip: %p, psr: 0x%lx,paddr: 0x%lx](%s) encounters MCA.\n",
  		raw_smp_processor_id(), current->pid, current->uid,
@@ -441,7 +458,7 @@

  	/* Is target address valid? */
  	if (!pbci->tv)
-		return fatal_mca(KERN_ALERT "MCA: target address not valid\n");
+		return fatal_mca("target address not valid");

  	/*
  	 * cpu read or memory-mapped io read
@@ -459,7 +476,7 @@

  	/* Is minstate valid? */
  	if (!peidx_bottom(peidx) || !(peidx_bottom(peidx)->valid.minstate))
-		return fatal_mca(KERN_ALERT "MCA: minstate not valid\n");
+		return fatal_mca("minstate not valid");
  	psr1 =(struct ia64_psr *)&(peidx_minstate_area(peidx)->pmsa_ipsr);
  	psr2 =(struct ia64_psr *)&(peidx_minstate_area(peidx)->pmsa_xpsr);

@@ -493,13 +510,14 @@
  			psr2->bn  = 1;
  			psr2->i  = 0;

-			return MCA_RECOVERED;
+			return mca_recovered("user memory corruption. "
+				"kill affected process - recovered.");
  		}

  	}

-	return fatal_mca(KERN_ALERT "MCA: kernel context not recovered,"
-			  " iip 0x%lx\n", pmsa->pmsa_iip);
+	return fatal_mca("kernel context not recovered, iip 0x%lx\n",
+			 pmsa->pmsa_iip);
  }

  /**
@@ -585,13 +603,13 @@
  	 * The machine check is corrected.
  	 */
  	if (psp->cm = 1)
-		return MCA_RECOVERED;
+		return mca_recovered("machine check is already corrected.");

  	/*
  	 * The error was not contained.  Software must be reset.
  	 */
  	if (psp->us || psp->ci = 0)
-		return fatal_mca(KERN_ALERT "MCA: error not contained\n");
+		return fatal_mca("error not contained");

  	/*
  	 * The cache check and bus check bits have four possible states
@@ -602,22 +620,22 @@
  	 *    1  1	Memory error, attempt recovery
  	 */
  	if (psp->bc = 0 || pbci = NULL)
-		return fatal_mca(KERN_ALERT "MCA: No bus check\n");
+		return fatal_mca("No bus check");

  	/*
  	 * Sorry, we cannot handle so many.
  	 */
  	if (peidx_bus_check_num(peidx) > 1)
-		return fatal_mca(KERN_ALERT "MCA: Too many bus checks\n");
+		return fatal_mca("Too many bus checks");
  	/*
  	 * Well, here is only one bus error.
  	 */
  	if (pbci->ib)
-		return fatal_mca(KERN_ALERT "MCA: Internal Bus error\n");
+		return fatal_mca("Internal Bus error");
  	if (pbci->cc)
-		return fatal_mca(KERN_ALERT "MCA: Cache-cache error\n");
+		return fatal_mca("Cache-cache error");
  	if (pbci->eb && pbci->bsi > 0)
-		return fatal_mca(KERN_ALERT "MCA: External bus check fatal status\n");
+		return fatal_mca("External bus check fatal status");

  	/*
  	 * This is a local MCA and estimated as recoverble external bus error.
@@ -629,7 +647,7 @@
  	/*
  	 * On account of strange SAL error record, we cannot recover.
  	 */
-	return fatal_mca(KERN_ALERT "MCA: Strange SAL record\n");
+	return fatal_mca("Strange SAL record");
  }

  /**
@@ -658,10 +676,10 @@

  	 /* Now, OS can recover when there is one processor error section */
  	if (n_proc_err > 1)
-		return fatal_mca(KERN_ALERT "MCA: Too Many Errors\n");
+		return fatal_mca("Too Many Errors");
  	else if (n_proc_err = 0)
  		/* Weird SAL record ... We need not to recover */
-		return fatal_mca(KERN_ALERT "MCA: Weird SAL record\n");
+		return fatal_mca("Weird SAL record");

  	/* Make index of processor error section */
  	mca_make_peidx((sal_log_processor_info_t*)
@@ -672,7 +690,7 @@

  	/* Check whether MCA is global or not */
  	if (is_mca_global(&peidx, &pbci, sos))
-		return fatal_mca(KERN_ALERT "MCA: global MCA\n");
+		return fatal_mca("global MCA");
  	
  	/* Try to recover a processor error */
  	return recover_from_processor_error(platform_err, &slidx, &peidx,
Index: linux-2.6.17/arch/ia64/kernel/mca_drv.h
=================================--- linux-2.6.17.orig/arch/ia64/kernel/mca_drv.h
+++ linux-2.6.17/arch/ia64/kernel/mca_drv.h
@@ -118,3 +118,7 @@

  extern const struct mca_table_entry *search_mca_tables (unsigned long addr);
  extern int mca_recover_range(unsigned long);
+extern void ia64_mca_printk(const char * fmt, ...)
+	 __attribute__ ((format (printf, 1, 2)));
+extern void ia64_mlogbuf_dump(void);
+
Index: linux-2.6.17/arch/ia64/kernel/salinfo.c
=================================--- linux-2.6.17.orig/arch/ia64/kernel/salinfo.c
+++ linux-2.6.17/arch/ia64/kernel/salinfo.c
@@ -266,6 +266,7 @@
  /* Check for outstanding MCA/INIT records every minute (arbitrary) */
  #define SALINFO_TIMER_DELAY (60*HZ)
  static struct timer_list salinfo_timer;
+extern void ia64_mlogbuf_dump(void);

  static void
  salinfo_timeout_check(struct salinfo_data *data)
@@ -283,6 +284,7 @@
  static void
  salinfo_timeout (unsigned long arg)
  {
+	ia64_mlogbuf_dump();
  	salinfo_timeout_check(salinfo_data + SAL_INFO_TYPE_MCA);
  	salinfo_timeout_check(salinfo_data + SAL_INFO_TYPE_INIT);
  	salinfo_timer.expires = jiffies + SALINFO_TIMER_DELAY;
@@ -332,6 +334,8 @@
  	if (cpu = -1)
  		goto retry;

+	ia64_mlogbuf_dump();
+
  	/* for next read, start checking at next CPU */
  	data->cpu_check = cpu;
  	if (++data->cpu_check = NR_CPUS)

