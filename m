From: Christoph Lameter <clameter@sgi.com>
Date: Tue, 02 Nov 2004 23:22:51 +0000
Subject: mmtimer: generate posix timer signals via the SGI SHub timer
Message-Id: <Pine.LNX.4.58.0411021507280.11020@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This is a patch that allows the use of th SGI SHub timer via the posix
standard functions (timer_create, timer_settime, timer_getoverrun) to
schedule a hardware interrupt which will then led to
a signal being delivered to a process. The current Linux kernel is only
able to deliver signals during tick processing every 1/HZ second.

I would appreciate any feedback you may have on this one since this is the
first clock driver that implements these features. The necessary API
changes in the posix layer to make this possible have recently been
accepted by Linus and I would expect that there will be an interest to
also use this for other clock sources.

There is already an existing mmtimer driver in Linux tree that allows the
use of CLOCK_SGI_CYCLE to access the SGI synchronizes SHub clock
which has an accuracy of 40ns. This patch augments that driver.

Limitations:
- A maximum of 3 events may be scheduled per SHub
- Time from interrupt reception to signal processing in user space is
15-100 usec depending on system load. This may at some point be
optimized. A realtime process may be able to react faster.

This a draft but a fully functional implementation. Feedback appreciated
but please do not put this patch into any public tree. We will post an
updated revision in a few days.

Index: linux-2.6.9/drivers/char/mmtimer.c
=================================--- linux-2.6.9.orig/drivers/char/mmtimer.c	2004-11-02 14:47:36.000000000 -0800
+++ linux-2.6.9/drivers/char/mmtimer.c	2004-11-02 15:04:15.000000000 -0800
@@ -13,6 +13,9 @@
  *
  * 11/01/01 - jbarnes - initial revision
  * 9/10/04 - Christoph Lameter - remove interrupt support for kernel inclusion
+ * 10/1/04 - Christoph Lameter - provide posix clock CLOCK_SGI_CYCLE
+ * 10/13/04 - Christoph Lameter, Dimitri Sivanich - provide timer interrupt support
+ *		via the posix timer interface
  */

 #include <linux/types.h>
@@ -26,23 +29,39 @@
 #include <linux/mmtimer.h>
 #include <linux/miscdevice.h>
 #include <linux/posix-timers.h>
+#include <linux/interrupt.h>

 #include <asm/uaccess.h>
 #include <asm/sn/addrs.h>
-#include <asm/sn/clksupport.h>
+#include <asm/sn/intr.h>
 #include <asm/sn/shub_mmr.h>
+#include <asm/sn/nodepda.h>
+
+/* This is ugly and needs to be fixed */
+#include "../../arch/ia64/sn/include/shubio.h"

 MODULE_AUTHOR("Jesse Barnes <jbarnes@sgi.com>");
-MODULE_DESCRIPTION("Multimedia timer support");
+MODULE_DESCRIPTION("SGI Altix RTC Timer");
 MODULE_LICENSE("GPL");

 /* name of the device, usually in /dev */
 #define MMTIMER_NAME "mmtimer"
-#define MMTIMER_DESC "IA-PC Multimedia Timer"
-#define MMTIMER_VERSION "1.0"
+#define MMTIMER_DESC "SGI Altix RTC Timer"
+#define MMTIMER_VERSION "2.0"

 #define RTC_BITS 55 /* 55 bits for this implementation */

+/* Mininum RTC cycles for interrupt intervals */
+#define MIN_RTC_INTERVAL 50
+/* Max time needed to enable interrupts and set up the comparator */
+#define GUARD_CYCLES 500
+
+extern unsigned long sn_rtc_cycles_per_second;
+
+#define RTC_COUNTER_ADDR        ((long *)LOCAL_MMR_ADDR(SH_RTC))
+
+#define rtc_time()              (*RTC_COUNTER_ADDR)
+
 static int mmtimer_ioctl(struct inode *inode, struct file *file,
 			 unsigned int cmd, unsigned long arg);
 static int mmtimer_mmap(struct file *file, struct vm_area_struct *vma);
@@ -58,6 +77,179 @@
 	.ioctl =	mmtimer_ioctl,
 };

+/*
+ * Comparators and their associated info.  Shub has
+ * three comparison registers.
+ */
+
+/*
+ * We only have comparison registers RTC1-4 currently available per
+ * node.  RTC0 is used by SAL.
+ */
+#define NUM_COMPARATORS 3
+/*
+ * Check for an interrupt and clear the pending bit if
+ * one is waiting.
+*/
+static int inline mmtimer_int_pending(int comparator) {
+	int pending = 0;
+
+	switch (comparator) {
+	case 0:
+		if (HUB_L((unsigned long *)LOCAL_MMR_ADDR(SH_EVENT_OCCURRED)) &
+					SH_EVENT_OCCURRED_RTC1_INT_MASK) {
+			HUB_S((u64 *)LOCAL_MMR_ADDR(SH_EVENT_OCCURRED_ALIAS),
+				SH_EVENT_OCCURRED_RTC1_INT_MASK);
+			pending = 1;
+		}
+		break;
+	case 1:
+		if (HUB_L((unsigned long *)LOCAL_MMR_ADDR(SH_EVENT_OCCURRED)) &
+					SH_EVENT_OCCURRED_RTC2_INT_MASK) {
+			HUB_S((u64 *)LOCAL_MMR_ADDR(SH_EVENT_OCCURRED_ALIAS),
+				SH_EVENT_OCCURRED_RTC2_INT_MASK);
+			pending = 1;
+		}
+		break;
+	case 2:
+		if (HUB_L((unsigned long *)LOCAL_MMR_ADDR(SH_EVENT_OCCURRED)) &
+					SH_EVENT_OCCURRED_RTC3_INT_MASK) {
+			HUB_S((u64 *)LOCAL_MMR_ADDR(SH_EVENT_OCCURRED_ALIAS),
+				SH_EVENT_OCCURRED_RTC3_INT_MASK);
+			pending = 1;
+		}
+		break;
+	default:
+		return -EFAULT;
+	}
+	return pending;
+}
+
+static void inline mmtimer_setup_int_0(void) {
+	u64 val;
+
+	/* Disable interrupt */
+	HUB_S((u64 *)LOCAL_MMR_ADDR(SH_RTC1_INT_ENABLE), 0UL);
+
+	HUB_S((u64 *)LOCAL_MMR_ADDR(SH_EVENT_OCCURRED_ALIAS),
+			SH_EVENT_OCCURRED_RTC1_INT_MASK);
+
+	val = ((u64)SGI_MMTIMER_VECTOR << SH_RTC1_INT_CONFIG_IDX_SHFT) |
+		((u64)cpu_physical_id(smp_processor_id()) <<
+			SH_RTC1_INT_CONFIG_PID_SHFT);
+
+	/* Set configuration */
+	HUB_S((u64 *)LOCAL_MMR_ADDR(SH_RTC1_INT_CONFIG), val);
+
+	/* Initialize comparator value to highest value */
+	HUB_S((u64 *)LOCAL_MMR_ADDR(SH_INT_CMPB), -1L);
+
+	/* Enable RTC interrupts */
+	HUB_S((u64 *)LOCAL_MMR_ADDR(SH_RTC1_INT_ENABLE), 1UL);
+
+}
+
+static void inline mmtimer_setup_int_1(void) {
+	u64 val;
+
+	HUB_S((u64 *)LOCAL_MMR_ADDR(SH_RTC2_INT_ENABLE), 0UL);
+
+	HUB_S((u64 *)LOCAL_MMR_ADDR(SH_EVENT_OCCURRED_ALIAS),
+			SH_EVENT_OCCURRED_RTC2_INT_MASK);
+
+	val = ((u64)SGI_MMTIMER_VECTOR << SH_RTC2_INT_CONFIG_IDX_SHFT) |
+		((u64)cpu_physical_id(smp_processor_id()) <<
+			SH_RTC2_INT_CONFIG_PID_SHFT);
+
+	HUB_S((u64 *)LOCAL_MMR_ADDR(SH_RTC2_INT_CONFIG), val);
+
+	HUB_S((u64 *)LOCAL_MMR_ADDR(SH_INT_CMPC), -1L);
+
+	HUB_S((u64 *)LOCAL_MMR_ADDR(SH_RTC2_INT_ENABLE), 1UL);
+}
+
+static void inline mmtimer_setup_int_2(void) {
+	u64 val;
+
+	HUB_S((u64 *)LOCAL_MMR_ADDR(SH_RTC3_INT_ENABLE), 0UL);
+
+	HUB_S((u64 *)LOCAL_MMR_ADDR(SH_EVENT_OCCURRED_ALIAS),
+			SH_EVENT_OCCURRED_RTC3_INT_MASK);
+
+	val = ((u64)SGI_MMTIMER_VECTOR << SH_RTC3_INT_CONFIG_IDX_SHFT) |
+		((u64)cpu_physical_id(smp_processor_id()) <<
+			SH_RTC3_INT_CONFIG_PID_SHFT);
+
+	HUB_S((u64 *)LOCAL_MMR_ADDR(SH_RTC3_INT_CONFIG), val);
+
+	HUB_S((u64 *)LOCAL_MMR_ADDR(SH_INT_CMPD), -1L);
+
+	HUB_S((u64 *)LOCAL_MMR_ADDR(SH_RTC3_INT_ENABLE), 1UL);
+}
+
+/*
+ * This function must be called with interrupts disabled and preemption off
+ * in order to insure that the setup succeeds in a deterministic time frame
+ * given by GUARD_CYCLES. The function checks that the expiration time
+ * given is not too early and will return an error and not set up
+ * an interrupt if the expiration is too early.
+ */
+static int inline mmtimer_setup(int comparator, unsigned long expires) {
+
+	if (unlikely(rtc_time() + GUARD_CYCLES > expires))
+		return 1;
+
+	switch (comparator) {
+	case 0:
+		mmtimer_setup_int_0();
+		HUB_S((u64 *)LOCAL_MMR_ADDR(SH_INT_CMPB), expires);
+		break;
+	case 1:
+		mmtimer_setup_int_1();
+		HUB_S((u64 *)LOCAL_MMR_ADDR(SH_INT_CMPC), expires);
+		break;
+	case 2:
+		mmtimer_setup_int_2();
+		HUB_S((u64 *)LOCAL_MMR_ADDR(SH_INT_CMPD), expires);
+		break;
+	}
+
+	return 0;
+}
+
+static int inline mmtimer_disable_int(long nasid, int comparator) {
+	switch (comparator) {
+	case 0:
+		nasid = -1 ? HUB_S((u64 *)LOCAL_MMR_ADDR(SH_RTC1_INT_ENABLE),
+			0UL) : REMOTE_HUB_S(nasid, SH_RTC1_INT_ENABLE, 0UL);
+		break;
+	case 1:
+		nasid = -1 ? HUB_S((u64 *)LOCAL_MMR_ADDR(SH_RTC2_INT_ENABLE),
+			0UL) : REMOTE_HUB_S(nasid, SH_RTC2_INT_ENABLE, 0UL);
+		break;
+	case 2:
+		nasid = -1 ? HUB_S((u64 *)LOCAL_MMR_ADDR(SH_RTC3_INT_ENABLE),
+			0UL) : REMOTE_HUB_S(nasid, SH_RTC3_INT_ENABLE, 0UL);
+		break;
+	default:
+		return -EFAULT;
+	}
+	return 0;
+}
+
+#define TIMER_OFF 0xbadcabLL
+
+/* There is one of these for each comparator */
+typedef struct mmtimer {
+	spinlock_t lock ____cacheline_aligned;
+	struct k_itimer *timer;
+} mmtimer_t;
+
+/*
+ * Total number of comparators is comparators/node * MAX nodes/running kernel
+ */
+static mmtimer_t timers[NUM_COMPARATORS*MAX_COMPACT_NODES];
+
 /**
  * mmtimer_ioctl - ioctl interface for /dev/mmtimer
  * @inode: inode of the device
@@ -183,10 +375,19 @@
 static struct timespec sgi_clock_offset;
 static int sgi_clock_period;

+/*****
+ * Posix Timer Interface
+ * The posix timer interface provides full support for the posix clock
+ * interface and allows the scheduling of up to three timers.
+ */
+
+static struct timespec sgi_clock_offset;
+static int sgi_clock_period;
+
 static int sgi_clock_get(struct timespec *tp) {
 	u64 nsec;

-	nsec = readq(RTC_COUNTER_ADDR) * sgi_clock_period
+	nsec = rtc_time() * sgi_clock_period
 			+ sgi_clock_offset.tv_nsec;
 	tp->tv_sec = div_long_long_rem(nsec, NSEC_PER_SEC, &tp->tv_nsec)
 			+ sgi_clock_offset.tv_sec;
@@ -194,12 +395,12 @@
 };

 static int sgi_clock_set(struct timespec *tp) {
-
+
 	u64 nsec;
 	u64 rem;

-	nsec = readq(RTC_COUNTER_ADDR) * sgi_clock_period;
-
+	nsec = rtc_time() * sgi_clock_period;
+
 	sgi_clock_offset.tv_sec = tp->tv_sec - div_long_long_rem(nsec, NSEC_PER_SEC, &rem);

 	if (rem <= tp->tv_nsec)
@@ -211,12 +412,233 @@
 	return 0;
 }

+/**
+ * mmtimer_interrupt - timer interrupt handler
+ * @irq: irq received
+ * @dev_id: device the irq came from
+ * @regs: register state upon receipt of the interrupt
+ *
+ * Called when one of the comarators matches the counter, This
+ * routine will send signals to processes that have requested
+ * them.
+ *
+ * This interrupt is run in an interrupt context
+ * by the SHUB. It is therefore safe to locally access SHub
+ * registers.
+ */
+static irqreturn_t
+mmtimer_interrupt(int irq, void *dev_id, struct pt_regs *regs)
+{
+	int i;
+	mmtimer_t *base = timers + cpuid_to_cnodeid(smp_processor_id()) * NUM_COMPARATORS;
+	int result = IRQ_NONE;
+
+	/*
+	 * Do this once for each comparison register
+	 */
+	for (i = 0; i < NUM_COMPARATORS; i++) {
+		unsigned long flags;
+
+		if (mmtimer_int_pending(i) > 0) {
+			struct k_itimer *t;
+			int m = 0;
+
+			mmtimer_disable_int(-1, i);
+			spin_lock(&base[i].lock);
+			t = base[i].timer;
+			base[i].timer = NULL;
+			if (t) {
+				m = t->it_timer.magic;
+				t->it_timer.magic = TIMER_OFF;
+			}
+			spin_unlock(&base[i].lock);
+
+			if (t = NULL || m = TIMER_OFF)
+				/* No timer left here, bail out */
+				goto out;
+
+			spin_lock_irqsave(&t->it_lock, flags);
+
+			if (posix_timer_event(t, 0) = 0) {
+
+				if(t->it_incr) {
+
+					/* Periodic timer */
+					spin_lock(&base[i].lock);
+					if (base[i].timer = NULL) {
+						t->it_timer.expires += t->it_incr;
+						t->it_timer.magic = i;
+						base[i].timer = t;
+
+						while (mmtimer_setup(i, t->it_timer.expires)) {
+							t->it_timer.expires += t->it_incr;
+							t->it_overrun++;
+						}
+					}
+					spin_unlock(&base[i].lock);
+				}
+
+			} else {
+
+				printk(KERN_WARNING "mmtimer unable to deliver signal");
+				t->it_overrun++;
+			}
+
+			spin_unlock_irqrestore(&t->it_lock, flags);
+out:
+			result = IRQ_HANDLED;
+		}
+	}
+	return result;
+}
+
+static int sgi_timer_create(struct k_itimer *timer) {
+	/* Insure that a newly created timer is off */
+	timer->it_timer.magic = TIMER_OFF;
+	return 0;
+}
+
+/* This does not really delete a timer. It just insures
+ * that the timer is not active
+ *
+ * Assumption: it_lock is already held with irq's disabled
+ */
+static int sgi_timer_del(struct k_itimer *timr) {
+	int i = timr->it_timer.magic;
+	cnodeid_t nodeid = timr->it_timer.data;
+	mmtimer_t *t = timers + nodeid * NUM_COMPARATORS +i;
+	unsigned long irqflags;
+
+	if (i != TIMER_OFF) {
+		spin_lock_irqsave(&t->lock, irqflags);
+		mmtimer_disable_int(cnodeid_to_nasid(nodeid),i);
+		t->timer = NULL;
+		timr->it_timer.magic = TIMER_OFF;
+		spin_unlock_irqrestore(&t->lock, irqflags);
+	}
+	return 0;
+}
+
+#define timespec_to_ns(x) ((x).tv_nsec + (x).tv_sec * NSEC_PER_SEC)
+#define ns_to_timespec(ts, nsec) (ts).tv_sec = div_long_long_rem(nsec, NSEC_PER_SEC, &(ts).tv_nsec)
+
+/* Assumption: it_lock is already held with irq's disabled */
+static void sgi_timer_get(struct k_itimer *timr, struct itimerspec *cur_setting) {
+
+	if (timr->it_timer.magic = TIMER_OFF) {
+		cur_setting->it_interval.tv_nsec = 0;
+		cur_setting->it_interval.tv_sec = 0;
+		cur_setting->it_value.tv_nsec = 0;
+		cur_setting->it_value.tv_sec =0;
+		return;
+	}
+
+	ns_to_timespec(cur_setting->it_interval, timr->it_incr * sgi_clock_period);
+	ns_to_timespec(cur_setting->it_value, (timr->it_timer.expires - rtc_time())* sgi_clock_period);
+	return;
+}
+
+
+static int sgi_timer_set(struct k_itimer *timr, int flags,
+	struct itimerspec * new_setting,
+	struct itimerspec * old_setting) {
+
+	int i;
+	unsigned long when, period, irqflags;
+	int err = 0;
+	cnodeid_t nodeid;
+	mmtimer_t *base;
+
+	if (old_setting)
+		sgi_timer_get(timr, old_setting);
+
+	sgi_timer_del(timr);
+	when = timespec_to_ns(new_setting->it_value);
+	period = timespec_to_ns(new_setting->it_interval);
+
+	if (when = 0)
+		/* Clear timer */
+		return 0;
+
+	if (flags & TIMER_ABSTIME) {
+		struct timespec n;
+
+		getnstimeofday(&n);
+		when -= timespec_to_ns(n);
+	}
+
+	/*
+	 * Convert to sgi clock period. Need to keep rtc_time() as near as possible
+	 * to getnstimeofday() in order to be as faithful as possible to the time
+	 * specified.
+	 */
+	when = when / sgi_clock_period + rtc_time();
+	period = period / sgi_clock_period;
+
+	if (period && period < MIN_RTC_INTERVAL)
+		return -EINVAL;
+
+	/*
+	 * We are allocating a local SHub comparator. If we would be moved to another
+	 * cpu then another SHub may be local to us. Prohibit that by switching off
+	 * preemption.
+	 */
+	preempt_disable();
+
+	nodeid =  cpuid_to_cnodeid(smp_processor_id());
+	base = timers + nodeid * NUM_COMPARATORS;
+retry:
+	for(i = 0; i< NUM_COMPARATORS; i++) {
+		if (!base[i].timer) {
+			break;
+		}
+	}
+
+	if (i = NUM_COMPARATORS) {
+		preempt_enable();
+		return -EBUSY;
+	}
+
+	spin_lock_irqsave(&base[i].lock, irqflags);
+
+	if (base[i].timer) {
+		spin_unlock_irqrestore(&base[i].lock, irqflags);
+		goto retry;
+	}
+	base[i].timer = timr;
+
+	timr->it_timer.magic = i;
+	timr->it_timer.data = nodeid;
+	timr->it_incr = period;
+
+	while (mmtimer_setup(i, when)) {
+		if (period) {
+			when += period;
+			timr->it_overrun++;
+		} else {
+			posix_timer_event(timr, 0);
+			goto out;
+		}
+	}
+	timr->it_timer.expires = when;
+
+out:
+	spin_unlock_irqrestore(&base[i].lock, irqflags);
+
+	preempt_enable();
+
+	return err;
+}
+
 static struct k_clock sgi_clock = {
 	.res = 0,
 	.clock_set = sgi_clock_set,
 	.clock_get = sgi_clock_get,
-	.timer_create = do_posix_clock_notimer_create,
-	.nsleep = do_posix_clock_nonanosleep
+	.timer_create = sgi_timer_create,
+	.nsleep = do_posix_clock_nonanosleep,
+	.timer_set = sgi_timer_set,
+	.timer_del = sgi_timer_del,
+	.timer_get = sgi_timer_get
 };

 /**
@@ -226,6 +648,8 @@
  */
 static int __init mmtimer_init(void)
 {
+	unsigned i;
+
 	if (!ia64_platform_is("sn2"))
 		return -1;

@@ -241,6 +665,17 @@
 	mmtimer_femtoperiod = ((unsigned long)1E15 + sn_rtc_cycles_per_second /
 			       2) / sn_rtc_cycles_per_second;

+	for (i=0; i< NUM_COMPARATORS*MAX_COMPACT_NODES; i++) {
+		spin_lock_init(&timers[i].lock);
+		timers[i].timer = NULL;
+	}
+
+	if (request_irq(SGI_MMTIMER_VECTOR, mmtimer_interrupt, SA_PERCPU_IRQ, MMTIMER_NAME, NULL)) {
+		printk(KERN_WARNING "%s: unable to allocate interrupt.",
+			MMTIMER_NAME);
+		return -1;
+	}
+
 	strcpy(mmtimer_miscdev.devfs_name, MMTIMER_NAME);
 	if (misc_register(&mmtimer_miscdev)) {
 		printk(KERN_ERR "%s: failed to register device\n",
Index: linux-2.6.9/include/asm/sn/intr.h
=================================--- linux-2.6.9.orig/include/asm/sn/intr.h	2004-11-02 14:47:37.000000000 -0800
+++ linux-2.6.9/include/asm/sn/intr.h	2004-11-02 14:49:54.000000000 -0800
@@ -18,6 +18,7 @@
 #define SGI_XBOW_ERROR                  (0x32)
 #define SGI_PCIBR_ERROR                 (0x33)
 #define SGI_ACPI_SCI_INT                (0x34)
+#define SGI_MMTIMER_VECTOR		(0x35)
 #define SGI_TIO_ERROR			(0x36)
 #define SGI_XPC_NOTIFY                  (0xe7)

Index: linux-2.6.9/include/asm-ia64/sn/shub_mmr.h
=================================--- linux-2.6.9.orig/include/asm-ia64/sn/shub_mmr.h	2004-10-29 09:15:58.000000000 -0700
+++ linux-2.6.9/include/asm-ia64/sn/shub_mmr.h	2004-11-02 14:49:54.000000000 -0800
@@ -196,4 +196,209 @@
 #define SH_PTC_1_START_SHFT                      63
 #define SH_PTC_1_START_MASK                      0x8000000000000000

+/*
+ * Register definitions
+ */
+
+/* ================================== */
+/*                    Register "SH_RTC1_INT_CONFIG"                     */
+/*                SHub RTC 1 Interrupt Config Registers                 */
+/* ================================== */
+
+#define SH_RTC1_INT_CONFIG                       0x0000000110001480
+#define SH_RTC1_INT_CONFIG_MASK                  0x0ff3ffffffefffff
+#define SH_RTC1_INT_CONFIG_INIT                  0x0000000000000000
+
+/*   SH_RTC1_INT_CONFIG_TYPE                                            */
+/*   Description:  Type of Interrupt: 0=INT, 2=PMI, 4=NMI, 5=INIT       */
+#define SH_RTC1_INT_CONFIG_TYPE_SHFT             0
+#define SH_RTC1_INT_CONFIG_TYPE_MASK             0x0000000000000007
+
+/*   SH_RTC1_INT_CONFIG_AGT                                             */
+/*   Description:  Agent, must be 0 for SHub                            */
+#define SH_RTC1_INT_CONFIG_AGT_SHFT              3
+#define SH_RTC1_INT_CONFIG_AGT_MASK              0x0000000000000008
+
+/*   SH_RTC1_INT_CONFIG_PID                                             */
+/*   Description:  Processor ID, same setting as on targeted McKinley  */
+#define SH_RTC1_INT_CONFIG_PID_SHFT              4
+#define SH_RTC1_INT_CONFIG_PID_MASK              0x00000000000ffff0
+
+/*   SH_RTC1_INT_CONFIG_BASE                                            */
+/*   Description:  Optional interrupt vector area, 2MB aligned          */
+#define SH_RTC1_INT_CONFIG_BASE_SHFT             21
+#define SH_RTC1_INT_CONFIG_BASE_MASK             0x0003ffffffe00000
+
+/*   SH_RTC1_INT_CONFIG_IDX                                             */
+/*   Description:  Targeted McKinley interrupt vector                   */
+#define SH_RTC1_INT_CONFIG_IDX_SHFT              52
+#define SH_RTC1_INT_CONFIG_IDX_MASK              0x0ff0000000000000
+
+/* ================================== */
+/*                    Register "SH_RTC1_INT_ENABLE"                     */
+/*                SHub RTC 1 Interrupt Enable Registers                 */
+/* ================================== */
+
+#define SH_RTC1_INT_ENABLE                       0x0000000110001500
+#define SH_RTC1_INT_ENABLE_MASK                  0x0000000000000001
+#define SH_RTC1_INT_ENABLE_INIT                  0x0000000000000000
+
+/*   SH_RTC1_INT_ENABLE_RTC1_ENABLE                                     */
+/*   Description:  Enable RTC 1 Interrupt                               */
+#define SH_RTC1_INT_ENABLE_RTC1_ENABLE_SHFT      0
+#define SH_RTC1_INT_ENABLE_RTC1_ENABLE_MASK      0x0000000000000001
+
+/* ================================== */
+/*                    Register "SH_RTC2_INT_CONFIG"                     */
+/*                SHub RTC 2 Interrupt Config Registers                 */
+/* ================================== */
+
+#define SH_RTC2_INT_CONFIG                       0x0000000110001580
+#define SH_RTC2_INT_CONFIG_MASK                  0x0ff3ffffffefffff
+#define SH_RTC2_INT_CONFIG_INIT                  0x0000000000000000
+
+/*   SH_RTC2_INT_CONFIG_TYPE                                            */
+/*   Description:  Type of Interrupt: 0=INT, 2=PMI, 4=NMI, 5=INIT       */
+#define SH_RTC2_INT_CONFIG_TYPE_SHFT             0
+#define SH_RTC2_INT_CONFIG_TYPE_MASK             0x0000000000000007
+
+/*   SH_RTC2_INT_CONFIG_AGT                                             */
+/*   Description:  Agent, must be 0 for SHub                            */
+#define SH_RTC2_INT_CONFIG_AGT_SHFT              3
+#define SH_RTC2_INT_CONFIG_AGT_MASK              0x0000000000000008
+
+/*   SH_RTC2_INT_CONFIG_PID                                             */
+/*   Description:  Processor ID, same setting as on targeted McKinley  */
+#define SH_RTC2_INT_CONFIG_PID_SHFT              4
+#define SH_RTC2_INT_CONFIG_PID_MASK              0x00000000000ffff0
+
+/*   SH_RTC2_INT_CONFIG_BASE                                            */
+/*   Description:  Optional interrupt vector area, 2MB aligned          */
+#define SH_RTC2_INT_CONFIG_BASE_SHFT             21
+#define SH_RTC2_INT_CONFIG_BASE_MASK             0x0003ffffffe00000
+
+/*   SH_RTC2_INT_CONFIG_IDX                                             */
+/*   Description:  Targeted McKinley interrupt vector                   */
+#define SH_RTC2_INT_CONFIG_IDX_SHFT              52
+#define SH_RTC2_INT_CONFIG_IDX_MASK              0x0ff0000000000000
+
+/* ================================== */
+/*                    Register "SH_RTC2_INT_ENABLE"                     */
+/*                SHub RTC 2 Interrupt Enable Registers                 */
+/* ================================== */
+
+#define SH_RTC2_INT_ENABLE                       0x0000000110001600
+#define SH_RTC2_INT_ENABLE_MASK                  0x0000000000000001
+#define SH_RTC2_INT_ENABLE_INIT                  0x0000000000000000
+
+/*   SH_RTC2_INT_ENABLE_RTC2_ENABLE                                     */
+/*   Description:  Enable RTC 2 Interrupt                               */
+#define SH_RTC2_INT_ENABLE_RTC2_ENABLE_SHFT      0
+#define SH_RTC2_INT_ENABLE_RTC2_ENABLE_MASK      0x0000000000000001
+
+/* ================================== */
+/*                    Register "SH_RTC3_INT_CONFIG"                     */
+/*                SHub RTC 3 Interrupt Config Registers                 */
+/* ================================== */
+
+#define SH_RTC3_INT_CONFIG                       0x0000000110001680
+#define SH_RTC3_INT_CONFIG_MASK                  0x0ff3ffffffefffff
+#define SH_RTC3_INT_CONFIG_INIT                  0x0000000000000000
+
+/*   SH_RTC3_INT_CONFIG_TYPE                                            */
+/*   Description:  Type of Interrupt: 0=INT, 2=PMI, 4=NMI, 5=INIT       */
+#define SH_RTC3_INT_CONFIG_TYPE_SHFT             0
+#define SH_RTC3_INT_CONFIG_TYPE_MASK             0x0000000000000007
+
+/*   SH_RTC3_INT_CONFIG_AGT                                             */
+/*   Description:  Agent, must be 0 for SHub                            */
+#define SH_RTC3_INT_CONFIG_AGT_SHFT              3
+#define SH_RTC3_INT_CONFIG_AGT_MASK              0x0000000000000008
+
+/*   SH_RTC3_INT_CONFIG_PID                                             */
+/*   Description:  Processor ID, same setting as on targeted McKinley  */
+#define SH_RTC3_INT_CONFIG_PID_SHFT              4
+#define SH_RTC3_INT_CONFIG_PID_MASK              0x00000000000ffff0
+
+/*   SH_RTC3_INT_CONFIG_BASE                                            */
+/*   Description:  Optional interrupt vector area, 2MB aligned          */
+#define SH_RTC3_INT_CONFIG_BASE_SHFT             21
+#define SH_RTC3_INT_CONFIG_BASE_MASK             0x0003ffffffe00000
+
+/*   SH_RTC3_INT_CONFIG_IDX                                             */
+/*   Description:  Targeted McKinley interrupt vector                   */
+#define SH_RTC3_INT_CONFIG_IDX_SHFT              52
+#define SH_RTC3_INT_CONFIG_IDX_MASK              0x0ff0000000000000
+
+/* ================================== */
+/*                    Register "SH_RTC3_INT_ENABLE"                     */
+/*                SHub RTC 3 Interrupt Enable Registers                 */
+/* ================================== */
+
+#define SH_RTC3_INT_ENABLE                       0x0000000110001700
+#define SH_RTC3_INT_ENABLE_MASK                  0x0000000000000001
+#define SH_RTC3_INT_ENABLE_INIT                  0x0000000000000000
+
+/*   SH_RTC3_INT_ENABLE_RTC3_ENABLE                                     */
+/*   Description:  Enable RTC 3 Interrupt                               */
+#define SH_RTC3_INT_ENABLE_RTC3_ENABLE_SHFT      0
+#define SH_RTC3_INT_ENABLE_RTC3_ENABLE_MASK      0x0000000000000001
+
+/*   SH_EVENT_OCCURRED_RTC1_INT                                         */
+/*   Description:  Pending RTC 1 Interrupt                              */
+#define SH_EVENT_OCCURRED_RTC1_INT_SHFT          24
+#define SH_EVENT_OCCURRED_RTC1_INT_MASK          0x0000000001000000
+
+/*   SH_EVENT_OCCURRED_RTC2_INT                                         */
+/*   Description:  Pending RTC 2 Interrupt                              */
+#define SH_EVENT_OCCURRED_RTC2_INT_SHFT          25
+#define SH_EVENT_OCCURRED_RTC2_INT_MASK          0x0000000002000000
+
+/*   SH_EVENT_OCCURRED_RTC3_INT                                         */
+/*   Description:  Pending RTC 3 Interrupt                              */
+#define SH_EVENT_OCCURRED_RTC3_INT_SHFT          26
+#define SH_EVENT_OCCURRED_RTC3_INT_MASK          0x0000000004000000
+
+/* ================================== */
+/*                        Register "SH_INT_CMPB"                        */
+/*                  RTC Compare Value for Processor B                   */
+/* ================================== */
+
+#define SH_INT_CMPB                              0x00000001101b0080
+#define SH_INT_CMPB_MASK                         0x007fffffffffffff
+#define SH_INT_CMPB_INIT                         0x0000000000000000
+
+/*   SH_INT_CMPB_REAL_TIME_CMPB                                         */
+/*   Description:  Real Time Clock Compare                              */
+#define SH_INT_CMPB_REAL_TIME_CMPB_SHFT          0
+#define SH_INT_CMPB_REAL_TIME_CMPB_MASK          0x007fffffffffffff
+
+/* ================================== */
+/*                        Register "SH_INT_CMPC"                        */
+/*                  RTC Compare Value for Processor C                   */
+/* ================================== */
+
+#define SH_INT_CMPC                              0x00000001101b0100
+#define SH_INT_CMPC_MASK                         0x007fffffffffffff
+#define SH_INT_CMPC_INIT                         0x0000000000000000
+
+/*   SH_INT_CMPC_REAL_TIME_CMPC                                         */
+/*   Description:  Real Time Clock Compare                              */
+#define SH_INT_CMPC_REAL_TIME_CMPC_SHFT          0
+#define SH_INT_CMPC_REAL_TIME_CMPC_MASK          0x007fffffffffffff
+
+/* ================================== */
+/*                        Register "SH_INT_CMPD"                        */
+/*                  RTC Compare Value for Processor D                   */
+/* ================================== */
+
+#define SH_INT_CMPD                              0x00000001101b0180
+#define SH_INT_CMPD_MASK                         0x007fffffffffffff
+#define SH_INT_CMPD_INIT                         0x0000000000000000
+
+/*   SH_INT_CMPD_REAL_TIME_CMPD                                         */
+/*   Description:  Real Time Clock Compare                              */
+#define SH_INT_CMPD_REAL_TIME_CMPD_SHFT          0
+#define SH_INT_CMPD_REAL_TIME_CMPD_MASK          0x007fffffffffffff
+
 #endif /* _ASM_IA64_SN_SHUB_MMR_H */
