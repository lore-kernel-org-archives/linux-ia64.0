From: Christoph Lameter <clameter@engr.sgi.com>
Date: Fri, 06 May 2005 00:59:39 +0000
Subject: Simple Performance Counters V2
Message-Id: <Pine.LNX.4.58.0505051757450.6506@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Changelog:
- Use a structure to store the processor id and the timestamp in order
  to allow the processor to optimize ITC access
- Move conversion from ITC counter -> real time into proc functions.


This patch allows the use of simple performance counters to measure time
intervals in the kernel source code. This allows a detailed analysis of the
time spend and the amount of data processed in specific code sections of the
kernel.

Time is measured using the cycle counter (TSC on IA32, ITC on IA64) which has
a very low latency.

To use add #include <linux/perf.h> to the header of the file where the
measurement needs to take place.

Then add the folowing to the code:

To declare a time stamp do

	PC_T xx;

To mark the beginning of the time measurement do

	PC_START(xx)

(If measurement from the beginning of a function is desired one may use
INITIALIZED_PC_T(xx) instead).

To mark the end of the time frame do:

	PC_STOP(x, "name-for-proc");

or if the amount of data transferred needs to be measured as well:

	PC_THROUGHPUT(xx, "name-for-proc", number-of-bytes);


The patch puts three performance counters into critical kernel paths to show
how its done.

The measurements will show up in /proc/perf/all. Processor specific statistics
may be obtained via /proc/perf/<nr-of-processor>. Writing to /proc/perf/reset
will reset all counters. F.e.

echo >/proc/perf/reset

Sample output:

AllocPages               786882 (+  0) 9.9s(223ns/12.6us/48.6us) 12.9gb(16.4kb/16.4kb/32.8kb)
FaultTime                786855 (+192) 10.4s(198ns/13.2us/323.6us)
PrepZeroPage             786765 (+  0) 9.2s(549ns/11.7us/48.1us) 12.9gb(16.4kb/16.4kb/16.4kb)

The first countr is the number of times that the time measurement was performed.
(+ xx) is the number of samples that were thrown away since the processor on
which the process is running changed. Cycle counters are not consistent
across different processors.

Then follows the sum of the time spend in the code segment followed in parentheses
by the minimum / average / maximum time spent there. The second block are the sizes
of data processed. In this sample 12.9 GB was allocated via AllocPages. Most
allocations were 16k = 1 page although there were also 32K (2 page) allocations.

This patch is IA64 specific for now. To support other arches one needs
to define cycles_to_ns in kernel/proc.c

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.11/mm/memory.c
=================================--- linux-2.6.11.orig/mm/memory.c	2005-04-29 12:12:02.000000000 -0700
+++ linux-2.6.11/mm/memory.c	2005-05-02 17:37:34.000000000 -0700
@@ -57,6 +57,7 @@

 #include <linux/swapops.h>
 #include <linux/elf.h>
+#include <linux/perf.h>

 #ifndef CONFIG_DISCONTIGMEM
 /* use the per-pgdat data instead for discontigmem - mbligh */
@@ -2031,6 +2032,10 @@ int handle_mm_fault(struct mm_struct *mm
 	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
+	int rc;
+	PC_T faulttime;
+
+	PC_START(faulttime);

 	__set_current_state(TASK_RUNNING);

@@ -2057,8 +2062,10 @@ int handle_mm_fault(struct mm_struct *mm
 	pte = pte_alloc_map(mm, pmd, address);
 	if (!pte)
 		goto oom;
-
-	return handle_pte_fault(mm, vma, address, write_access, pte, pmd);
+
+	rc = handle_pte_fault(mm, vma, address, write_access, pte, pmd);
+	PC_STOP(faulttime, "FaultTime");
+	return rc;

  oom:
 	spin_unlock(&mm->page_table_lock);
Index: linux-2.6.11/kernel/Makefile
=================================--- linux-2.6.11.orig/kernel/Makefile	2005-04-29 12:12:02.000000000 -0700
+++ linux-2.6.11/kernel/Makefile	2005-05-02 17:37:34.000000000 -0700
@@ -7,7 +7,7 @@ obj-y     = sched.o fork.o exec_domain.o
 	    sysctl.o capability.o ptrace.o timer.o user.o \
 	    signal.o sys.o kmod.o workqueue.o pid.o \
 	    rcupdate.o intermodule.o extable.o params.o posix-timers.o \
-	    kthread.o wait.o kfifo.o sys_ni.o posix-cpu-timers.o
+	    kthread.o wait.o kfifo.o sys_ni.o posix-cpu-timers.o perf.o

 obj-$(CONFIG_FUTEX) += futex.o
 obj-$(CONFIG_GENERIC_ISA_DMA) += dma.o
Index: linux-2.6.11/include/linux/perf.h
=================================--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.11/include/linux/perf.h	2005-05-02 17:47:27.000000000 -0700
@@ -0,0 +1,37 @@
+/*
+ * Performance Counters and Measurement macros
+ * (C) 2005 Silicon Graphics Incorporated
+ * by Christoph Lameter <clameter@sgi.com>, April 2005
+ *
+ * Counters are calculated using the cycle counter. If a process
+ * is migrated to another cpu during the measurement then the measurement
+ * is invalid.
+ *
+ * We cannot disable preemption during measurement since that may interfere
+ * with other things in the kernel and limit the usefulness of the counters.
+ */
+
+#include <linux/smp.h>
+
+struct meas_t {
+	unsigned long timestamp;
+	short int processor;
+};
+
+extern void pc(const char *name, struct meas_t t1, unsigned long bytes);
+
+/* Type for measurements */
+#define PC_T struct meas_t
+
+/* Macro for setting the startpoint of the stopwatch */
+#define PC_START(x) (x).timestamp = get_cycles(); (x).processor = smp_processor_id()
+
+/* Combination of the two. Define startpoint and set it */
+#define INITIALIZED_PC_T(x) struct meas_t x = { get_cycles(), smp_processor_id() }
+
+/* Macro to set the endpoint of the stopwatch w/o throughput information */
+#define PC_STOP(x, name) pc(name, x, 0)
+
+/* Macro to set the end point where we also provide throughput information */
+#define PC_THROUGHPUT(x, name, bytes) pc(name, x, bytes)
+
Index: linux-2.6.11/kernel/perf.c
=================================--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.11/kernel/perf.c	2005-05-02 17:44:34.000000000 -0700
@@ -0,0 +1,341 @@
+/*
+ * Simple Performance Counter subsystem
+ *
+ * (C) 2005 Silicon Graphics Incorporated.
+ *
+ * April 2005, Christoph Lameter <clameter@sgi.com>
+ */
+
+#include <linux/config.h>
+#include <linux/module.h>
+#include <linux/percpu.h>
+#include <linux/seq_file.h>
+#include <linux/fs.h>
+#include <linux/proc_fs.h>
+#include <linux/cpumask.h>
+#include <linux/perf.h>
+/* For the hash function */
+#include <linux/dcache.h>
+
+#ifdef CONFIG_IA64
+#define CYCLE_FACTOR local_cpu_data->nsec_per_cyc
+#define CYCLE_SHIFT IA64_NSEC_PER_CYC_SHIFT
+#else
+#error "cycles_to_ns not defined for this architecture"
+#endif
+
+
+#define MAXCOUNT 128
+struct pc_s {
+	u32 events;
+	u32 mintime;
+	u32 maxtime;
+	u32 minbytes;
+	u32 maxbytes;
+	u32 skipped;
+	u64 time;
+	u64 bytes;
+	const char *text;
+};
+
+DEFINE_PER_CPU(struct pc_s [MAXCOUNT], counters);
+
+void pc(const char *text, struct meas_t t1, unsigned long bytes)
+{
+	struct pc_s *p = &get_cpu_var(counters)[0];
+	unsigned long time = get_cycles();
+	int h = full_name_hash(text, strlen(text)) % MAXCOUNT;
+	int count = MAXCOUNT;
+
+	while (count && p[h].text && strcmp(p[h].text,text)) {
+		h = (h+1) % MAXCOUNT;
+		count--;
+	}
+
+	if (unlikely(!count)) {
+		printk(KERN_ERR "perfcount: too many counters. Measurement ignored.\n");
+		goto out;
+	}
+
+	p += h;
+	p->text = text;
+
+	/* Check if the processor was changed during our measurement attempt */
+	if (t1.processor != smp_processor_id()) {
+		/* Only record the failure in the new cpu .... */
+		p->skipped++;
+		goto out;
+	}
+	p->events++;
+	time = time -t1.timestamp;
+	if (unlikely(time > (1UL << (BITS_PER_LONG - 9)))) {
+		printk(KERN_ERR "perfcount: invalid time difference. Measurement ignored.\n");
+		goto out;
+	};
+
+	if (time > 0) {
+		/* Time information */
+		p->time += time;
+		if (unlikely(time > p->maxtime))
+			p->maxtime = time;
+
+		if (unlikely(p->mintime =0 || time < p->mintime))
+			p->mintime = time;
+	}
+
+	if (unlikely(bytes)) {
+		/* Bytes information */
+		p->bytes += bytes;
+		if (bytes > p->maxbytes)
+			p->maxbytes = bytes;
+		if (p->minbytes = 0 || bytes < p->minbytes)
+			p->minbytes = bytes;
+	}
+out:
+	put_cpu_var();
+};
+
+EXPORT_SYMBOL(pc);
+
+void pc_reset(void) {
+	int i,j;
+
+	for (i = 0; i < num_possible_cpus(); i++)
+		for(j=0; j<MAXCOUNT;j++) {
+			struct pc_s *c = &per_cpu(counters, i)[0] + j;
+			c->events =0;
+			c->time =0;
+			c->maxtime =0;
+			c->mintime =0;
+			c->bytes =0;
+			c->minbytes =0;
+			c->maxbytes =0;
+		}
+}
+EXPORT_SYMBOL(pc_reset);
+
+struct unit_v_s {
+	unsigned int n;
+	const char * s;
+};
+
+const struct unit_v_s event_units[] = {
+	{ 1000, "" },
+	{ 1000, "K" },
+	{ 1000, "M" },
+	{ 1000, "G" },
+	{ 1000, "T" },
+	{ 1000, "P" },
+	{ 1000, "XX" },
+};
+
+
+const struct unit_v_s time_units[] = {
+	{ 1000, "ns" },
+	{ 1000, "us" },
+	{ 1000, "ms" },
+	{ 60, "s" },
+	{ 60, "m" },
+	{ 24, "h" },
+	{ 365, "d" },
+	{ 1000, "y" },
+};
+
+const struct unit_v_s byte_units[] = {
+	{ 1000, "b" },
+	{ 1000, "kb" },
+	{ 1000, "mb" },
+	{ 1000, "gb" },
+	{ 1000, "tb" },
+	{ 1000, "pb" },
+	{ 1000, "xb" }
+};
+
+/* Print a value using the given array of units and scale it properly */
+static void pval(struct seq_file *s, unsigned long x, const struct unit_v_s *u, int scale, int shift)
+{
+	unsigned n = 0;
+	unsigned rem = 0;
+	unsigned last_divisor = 0;
+
+	x = (x * scale) >> shift;
+
+	while (x >= u[n].n) {
+		last_divisor = u[n].n;
+		rem = x % last_divisor;
+		x = x / last_divisor;
+		n++;
+	}
+
+	/* Calculate a rounded possible fractional decimal digit */
+	rem = (rem*10 + last_divisor/2) / last_divisor;
+
+	/*
+	 * Rounding may have resulted in the need to go
+	 * to the next number
+	 */
+	if (rem = 10) {
+		x++;
+		rem = 0;
+	};
+
+	seq_printf(s, "%lu", x);
+	if (rem) {
+		seq_putc(s, '.');
+		seq_putc(s, '0' + rem);
+	}
+	seq_puts(s, u[n].s);
+}
+
+/* Print a set of statistical values in the form sum(max/avg/min) */
+static void pc_print(struct seq_file *s, const struct unit_v_s *u, unsigned long count,
+		 unsigned long sum, unsigned long min, unsigned long max, int scale, int shift)
+{
+	pval(s, sum, u, scale, shift);
+	seq_putc(s,'(');
+	pval(s, min, u, scale, shift);
+	seq_putc(s,'/');
+	pval(s, (sum + count/2 ) / count, u, scale, shift);
+	seq_putc(s,'/');
+	pval(s, max, u, scale, shift);
+	seq_putc(s,')');
+}
+
+
+static int perf_show(struct seq_file *s, void *v)
+{
+	int cpu = (unsigned long)s->private;
+	int counter = (unsigned long)v - 1;
+	int n;
+	struct pc_s summary, *x;
+	const char *text;
+
+	if (cpu >= 0)
+		x = &per_cpu(counters, cpu)[0] + counter;
+	else {
+		memcpy(&summary, &per_cpu(counters, 0)[counter], sizeof(summary));
+		for(n = 1; n < num_possible_cpus(); n++) {
+			struct pc_s *c = &per_cpu(counters, n)[counter];
+
+			summary.events += c->events;
+			summary.skipped += c->skipped;
+			summary.time += c->time;
+			summary.bytes += c->bytes;
+
+			if (summary.maxtime < c->maxtime)
+				summary.maxtime = c->maxtime;
+			if (summary.mintime = 0 ||
+				(c->mintime != 0 && summary.mintime > c->mintime))
+					summary.mintime = c->mintime;
+
+			if (summary.maxbytes < c->maxbytes)
+				summary.maxbytes = c->maxbytes;
+			if (summary.minbytes = 0 ||
+				(c->minbytes != 0 && summary.minbytes > c->minbytes))
+					summary.minbytes = c->minbytes;
+
+			if (summary.text = NULL)
+				summary.text = c->text;
+		}
+		x = &summary;
+	}
+
+	if (!x->events)
+		return 0;
+
+	text = x->text;
+	if (!text)
+		text = "UNKNOWN";
+
+	seq_printf(s, "%-20s %10u (+%3u) ", text, x->events, x->skipped);
+	pc_print(s, time_units, x->events, x->time, x->mintime, x->maxtime,CYCLE_FACTOR,CYCLE_SHIFT);
+	if (x->bytes) {
+		/* Only print throughput information if its available */
+		seq_putc(s,' ');
+		pc_print(s, byte_units, x->events, x->bytes, x->minbytes, x->maxbytes, 1, 0);
+	}
+	seq_putc(s, '\n');
+	return 0;
+}
+
+static void *perf_start(struct seq_file *m, loff_t *pos)
+{
+	return (*pos < MAXCOUNT) ? (void *)(*pos +1) : NULL;
+}
+
+static void *perf_next(struct seq_file *m, void *v, loff_t *pos)
+{
+	++*pos;
+	return perf_start(m, pos);
+}
+
+static void perf_stop(struct seq_file *m, void *v)
+{
+}
+
+struct seq_operations perf_data_ops = {
+	.start  = perf_start,
+	.next   = perf_next,
+	.stop   = perf_stop,
+	.show   = perf_show,
+};
+
+static int perf_data_open(struct inode *inode, struct file *file)
+{
+	int res;
+
+	res = seq_open(file, &perf_data_ops);
+	if (!res)
+		((struct seq_file *)file->private_data)->private = PDE(inode)->data;
+
+	return res;
+};
+
+static struct file_operations perf_data_fops = {
+	.open		= perf_data_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
+
+static int perf_reset_write(struct file *file, const char __user *buffer,
+	unsigned long count, void *data)
+{
+	pc_reset();
+	return count;
+}
+
+static __init int init_pc(void) {
+	int i;
+
+	/* Procfs registrations */
+	struct proc_dir_entry *proc_perf, *perf_reset, *perf_all;
+
+	proc_perf = proc_mkdir("perf", NULL);
+	if (!proc_perf)
+		return -ENOMEM;
+
+	perf_reset = create_proc_entry("reset", S_IWUGO, proc_perf);
+	perf_reset->write_proc = perf_reset_write;
+
+	perf_all = create_proc_entry("all", S_IRUGO, proc_perf);
+	perf_all->proc_fops = &perf_data_fops;
+	perf_all->data = (void *)-1;
+
+	for(i = 0; i < num_possible_cpus(); i++) {
+		char name[20];
+		struct proc_dir_entry *p;
+
+		sprintf(name, "%d", i);
+		p = create_proc_entry(name, S_IRUGO, proc_perf);
+
+		p->proc_fops = &perf_data_fops;
+		p->data = (void *)(unsigned long)i;
+	}
+
+	pc_reset();
+	return 0;
+}
+
+__initcall(init_pc);
+
Index: linux-2.6.11/mm/page_alloc.c
=================================--- linux-2.6.11.orig/mm/page_alloc.c	2005-04-29 12:12:02.000000000 -0700
+++ linux-2.6.11/mm/page_alloc.c	2005-05-02 17:37:34.000000000 -0700
@@ -34,6 +34,7 @@
 #include <linux/cpuset.h>
 #include <linux/nodemask.h>
 #include <linux/vmalloc.h>
+#include <linux/perf.h>

 #include <asm/tlbflush.h>
 #include "internal.h"
@@ -636,10 +637,12 @@ void fastcall free_cold_page(struct page
 static inline void prep_zero_page(struct page *page, int order, unsigned int __nocast gfp_flags)
 {
 	int i;
+	INITIALIZED_PC_T(t);

 	BUG_ON((gfp_flags & (__GFP_WAIT | __GFP_HIGHMEM)) = __GFP_HIGHMEM);
 	for(i = 0; i < (1 << order); i++)
 		clear_highpage(page + i);
+	PC_THROUGHPUT(t,"PrepZeroPage", PAGE_SIZE << order );
 }

 /*
@@ -739,6 +742,7 @@ __alloc_pages(unsigned int __nocast gfp_
 	int do_retry;
 	int can_try_harder;
 	int did_some_progress;
+	INITIALIZED_PC_T(t);

 	might_sleep_if(wait);

@@ -903,6 +907,7 @@ nopage:
 	return NULL;
 got_pg:
 	zone_statistics(zonelist, z);
+	PC_THROUGHPUT(t,"AllocPages", PAGE_SIZE << order);
 	return page;
 }

