From: Jack Steiner <steiner@sgi.com>
Date: Thu, 11 Aug 2005 17:28:01 +0000
Subject: [PATCH 7/7] - New SN hardware support - ptc_fixes
Message-Id: <20050811172801.GA20243@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


Shub2 provides a much improved mechanism for issuing internode
TLB purges. Add code to support the newer mechanism. There is also=20
some debug code (disabled) that is useful for testing.

Collect statistics on the number, type & duration of TLB purges.
This data will be useful for making future improvements in the algorithms.


	Signed-off-by: Jack Steiner <steiner@sgi.com>


 arch/ia64/sn/kernel/setup.c            |    1=20
 arch/ia64/sn/kernel/sn2/ptc_deadlock.S |   11 +
 arch/ia64/sn/kernel/sn2/sn2_smp.c      |  255 ++++++++++++++++++++++++++++=
++---
 include/asm-ia64/sn/nodepda.h          |    3=20
 4 files changed, 244 insertions(+), 26 deletions(-)




Index: linux/arch/ia64/sn/kernel/setup.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig/arch/ia64/sn/kernel/setup.c	2005-08-=
11 09:09:20.020027235 -0500
+++ linux/arch/ia64/sn/kernel/setup.c	2005-08-11 09:09:20.161614623 -0500
@@ -403,6 +403,7 @@ static void __init sn_init_pdas(char **c
 		memset(nodepdaindr[cnode], 0, sizeof(nodepda_t));
 		memset(nodepdaindr[cnode]->phys_cpuid, -1,
 		    sizeof(nodepdaindr[cnode]->phys_cpuid));
+		spin_lock_init(&nodepdaindr[cnode]->ptc_lock);
 	}
=20
 	/*
Index: linux/arch/ia64/sn/kernel/sn2/ptc_deadlock.S
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig/arch/ia64/sn/kernel/sn2/ptc_deadlock=
.S	2005-08-11 09:09:04.408308988 -0500
+++ linux/arch/ia64/sn/kernel/sn2/ptc_deadlock.S	2005-08-11 09:09:20.164544=
017 -0500
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 2000-2004 Silicon Graphics, Inc. All rights reserved.
+ * Copyright (C) 2000-2005 Silicon Graphics, Inc. All rights reserved.
  */
=20
 #include <asm/types.h>
@@ -11,7 +11,7 @@
=20
 #define DEADLOCKBIT	SH_PIO_WRITE_STATUS_WRITE_DEADLOCK_SHFT
 #define WRITECOUNTMASK	SH_PIO_WRITE_STATUS_PENDING_WRITE_COUNT_MASK
-#define ALIAS_OFFSET	(SH1_PIO_WRITE_STATUS_0_ALIAS-SH1_PIO_WRITE_STATUS_0)
+#define ALIAS_OFFSET	8
=20
=20
 	.global	sn2_ptc_deadlock_recovery_core
@@ -36,13 +36,15 @@ sn2_ptc_deadlock_recovery_core:
 	extr.u	piowcphy=3Dpiowc,0,61;;	// Convert piowc to uncached physical addr=
ess
 	dep	piowcphy=3D-1,piowcphy,63,1
 	movl	mask=3DWRITECOUNTMASK
+	mov	r8=3Dr0
=20
 1:
 	add	scr2=3DALIAS_OFFSET,piowc	// Address of WRITE_STATUS alias register=20
-	mov	scr1=3D7;;		// Clear DEADLOCK, WRITE_ERROR, MULTI_WRITE_ERROR
-	st8.rel	[scr2]=3Dscr1;;
+	;;
+	ld8.acq	scr1=3D[scr2];;
=20
 5:	ld8.acq	scr1=3D[piowc];;		// Wait for PIOs to complete.
+	hint	@pause
 	and	scr2=3Dscr1,mask;;	// mask of writecount bits
 	cmp.ne	p6,p0=3Dzeroval,scr2
 (p6)	br.cond.sptk 5b
@@ -57,6 +59,7 @@ sn2_ptc_deadlock_recovery_core:
 	st8.rel [ptc0]=DAta0		// Write PTC0 & wait for completion.
=20
 5:	ld8.acq	scr1=3D[piowcphy];;	// Wait for PIOs to complete.
+	hint	@pause
 	and	scr2=3Dscr1,mask;;	// mask of writecount bits
 	cmp.ne	p6,p0=3Dzeroval,scr2
 (p6)	br.cond.sptk 5b;;
@@ -67,6 +70,7 @@ sn2_ptc_deadlock_recovery_core:
 (p7)	st8.rel [ptc1]=DAta1;;		// Now write PTC1.
=20
 5:	ld8.acq	scr1=3D[piowcphy];;	// Wait for PIOs to complete.
+	hint	@pause
 	and	scr2=3Dscr1,mask;;	// mask of writecount bits
 	cmp.ne	p6,p0=3Dzeroval,scr2
 (p6)	br.cond.sptk 5b
@@ -77,6 +81,7 @@ sn2_ptc_deadlock_recovery_core:
 	srlz.i;;
 	////////////// END   PHYSICAL MODE ////////////////////
=20
+(p8)	add	r8=3D1,r8
 (p8)	br.cond.spnt 1b;;		// Repeat if DEADLOCK occurred.
=20
 	br.ret.sptk	rp
Index: linux/arch/ia64/sn/kernel/sn2/sn2_smp.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig/arch/ia64/sn/kernel/sn2/sn2_smp.c	20=
05-08-11 09:09:04.408308988 -0500
+++ linux/arch/ia64/sn/kernel/sn2/sn2_smp.c	2005-08-11 09:09:30.988655656 -=
0500
@@ -5,7 +5,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 2000-2004 Silicon Graphics, Inc. All rights reserved.
+ * Copyright (C) 2000-2005 Silicon Graphics, Inc. All rights reserved.
  */
=20
 #include <linux/init.h>
@@ -20,6 +20,8 @@
 #include <linux/module.h>
 #include <linux/bitops.h>
 #include <linux/nodemask.h>
+#include <linux/proc_fs.h>
+#include <linux/seq_file.h>
=20
 #include <asm/processor.h>
 #include <asm/irq.h>
@@ -39,12 +41,120 @@
 #include <asm/sn/nodepda.h>
 #include <asm/sn/rw_mmr.h>
=20
-void sn2_ptc_deadlock_recovery(volatile unsigned long *, unsigned long dat=
a0,=20
-	volatile unsigned long *, unsigned long data1);
+DEFINE_PER_CPU(struct ptc_stats, ptcstats);
+DECLARE_PER_CPU(struct ptc_stats, ptcstats);
=20
 static  __cacheline_aligned DEFINE_SPINLOCK(sn2_global_ptc_lock);
=20
-static unsigned long sn2_ptc_deadlock_count;
+void sn2_ptc_deadlock_recovery(short *, short, int, volatile unsigned long=
 *, unsigned long data0,
+	volatile unsigned long *, unsigned long data1);
+
+#ifdef DEBUG_PTC
+/*
+ * ptctest:
+ *
+ * 	xyz - 3 digit hex number:
+ * 		x - Force PTC purges to use shub:
+ * 			0 - no force
+ * 			1 - force
+ * 		y - interupt enable
+ * 			0 - disable interrupts
+ * 			1 - leave interuupts enabled
+ * 		z - type of lock:
+ * 			0 - global lock
+ * 			1 - node local lock
+ * 			2 - no lock
+ *
+ *   	Note: on shub1, only ptctest =3D 0 is supported. Don't try other val=
ues!
+ */
+
+static unsigned int sn2_ptctest =3D 0;
+
+static int __init ptc_test(char *str)
+{
+	get_option(&str, &sn2_ptctest);
+	return 1;
+}
+__setup("ptctest=3D", ptc_test);
+
+static inline int ptc_lock(unsigned long *flagp)
+{
+	unsigned long opt =3D sn2_ptctest & 255;
+
+	switch (opt) {
+	case 0x00:
+		spin_lock_irqsave(&sn2_global_ptc_lock, *flagp);
+		break;
+	case 0x01:
+		spin_lock_irqsave(&sn_nodepda->ptc_lock, *flagp);
+		break;
+	case 0x02:
+		local_irq_save(*flagp);
+		break;
+	case 0x10:
+		spin_lock(&sn2_global_ptc_lock);
+		break;
+	case 0x11:
+		spin_lock(&sn_nodepda->ptc_lock);
+		break;
+	case 0x12:
+		break;
+	default:
+		BUG();
+	}
+	return opt;
+}
+
+static inline void ptc_unlock(unsigned long flags, int opt)
+{
+	switch (opt) {
+	case 0x00:
+		spin_unlock_irqrestore(&sn2_global_ptc_lock, flags);
+		break;
+	case 0x01:
+		spin_unlock_irqrestore(&sn_nodepda->ptc_lock, flags);
+		break;
+	case 0x02:
+		local_irq_restore(flags);
+		break;
+	case 0x10:
+		spin_unlock(&sn2_global_ptc_lock);
+		break;
+	case 0x11:
+		spin_unlock(&sn_nodepda->ptc_lock);
+		break;
+	case 0x12:
+		break;
+	default:
+		BUG();
+	}
+}
+#else
+
+#define sn2_ptctest	0
+
+static inline int ptc_lock(unsigned long *flagp)
+{
+	spin_lock_irqsave(&sn2_global_ptc_lock, *flagp);
+	return 0;
+}
+
+static inline void ptc_unlock(unsigned long flags, int opt)
+{
+	spin_unlock_irqrestore(&sn2_global_ptc_lock, flags);
+}
+#endif
+
+struct ptc_stats {
+	unsigned long ptc_l;
+	unsigned long change_rid;
+	unsigned long shub_ptc_flushes;
+	unsigned long nodes_flushed;
+	unsigned long deadlocks;
+	unsigned long lock_itc_clocks;
+	unsigned long shub_itc_clocks;
+	unsigned long shub_itc_clocks_max;
+};
=20
 static inline unsigned long wait_piowc(void)
 {
@@ -89,9 +199,9 @@ void
 sn2_global_tlb_purge(unsigned long start, unsigned long end,
 		     unsigned long nbits)
 {
-	int i, shub1, cnode, mynasid, cpu, lcpu =3D 0, nasid, flushed =3D 0;
+	int i, opt, shub1, cnode, mynasid, cpu, lcpu =3D 0, nasid, flushed =3D 0;
 	volatile unsigned long *ptc0, *ptc1;
-	unsigned long flags =3D 0, data0 =3D 0, data1 =3D 0;
+	unsigned long itc, itc2, flags, data0 =3D 0, data1 =3D 0;
 	struct mm_struct *mm =3D current->active_mm;
 	short nasids[MAX_NUMNODES], nix;
 	nodemask_t nodes_flushed;
@@ -114,16 +224,19 @@ sn2_global_tlb_purge(unsigned long start
 			start +=3D (1UL << nbits);
 		} while (start < end);
 		ia64_srlz_i();
+		__get_cpu_var(ptcstats).ptc_l++;
 		preempt_enable();
 		return;
 	}
=20
 	if (atomic_read(&mm->mm_users) =3D 1) {
 		flush_tlb_mm(mm);
+		__get_cpu_var(ptcstats).change_rid++;
 		preempt_enable();
 		return;
 	}
=20
+	itc =3D ia64_get_itc();
 	nix =3D 0;
 	for_each_node_mask(cnode, nodes_flushed)
 		nasids[nix++] =3D cnodeid_to_nasid(cnode);
@@ -148,7 +261,12 @@ sn2_global_tlb_purge(unsigned long start
=20
 	mynasid =3D get_nasid();
=20
-	spin_lock_irqsave(&sn2_global_ptc_lock, flags);
+	itc =3D ia64_get_itc();
+	opt =3D ptc_lock(&flags);
+	itc2 =3D ia64_get_itc();
+	__get_cpu_var(ptcstats).lock_itc_clocks +=3D itc2 - itc;
+	__get_cpu_var(ptcstats).shub_ptc_flushes++;
+	__get_cpu_var(ptcstats).nodes_flushed +=3D nix;
=20
 	do {
 		if (shub1)
@@ -157,7 +275,7 @@ sn2_global_tlb_purge(unsigned long start
 			data0 =3D (data0 & ~SH2_PTC_ADDR_MASK) | (start & SH2_PTC_ADDR_MASK);
 		for (i =3D 0; i < nix; i++) {
 			nasid =3D nasids[i];
-			if (unlikely(nasid =3D mynasid)) {
+			if ((!(sn2_ptctest & 3)) && unlikely(nasid =3D mynasid)) {
 				ia64_ptcga(start, nbits << 2);
 				ia64_srlz_i();
 			} else {
@@ -169,18 +287,22 @@ sn2_global_tlb_purge(unsigned long start
 				flushed =3D 1;
 			}
 		}
-
 		if (flushed
 		    && (wait_piowc() &
-			SH_PIO_WRITE_STATUS_WRITE_DEADLOCK_MASK)) {
-			sn2_ptc_deadlock_recovery(ptc0, data0, ptc1, data1);
+				(SH_PIO_WRITE_STATUS_WRITE_DEADLOCK_MASK))) {
+			sn2_ptc_deadlock_recovery(nasids, nix, mynasid, ptc0, data0, ptc1, data=
1);
 		}
=20
 		start +=3D (1UL << nbits);
=20
 	} while (start < end);
=20
-	spin_unlock_irqrestore(&sn2_global_ptc_lock, flags);
+	itc2 =3D ia64_get_itc() - itc2;
+	__get_cpu_var(ptcstats).shub_itc_clocks +=3D itc2;
+	if (itc2 > __get_cpu_var(ptcstats).shub_itc_clocks_max)
+		__get_cpu_var(ptcstats).shub_itc_clocks_max =3D itc2;
+
+	ptc_unlock(flags, opt);
=20
 	preempt_enable();
 }
@@ -192,31 +314,29 @@ sn2_global_tlb_purge(unsigned long start
  * TLB flush transaction.  The recovery sequence is somewhat tricky & is
  * coded in assembly language.
  */
-void sn2_ptc_deadlock_recovery(volatile unsigned long *ptc0, unsigned long=
 data0,
+void sn2_ptc_deadlock_recovery(short *nasids, short nix, int mynasid, vola=
tile unsigned long *ptc0, unsigned long data0,
 	volatile unsigned long *ptc1, unsigned long data1)
 {
 	extern void sn2_ptc_deadlock_recovery_core(volatile unsigned long *, unsi=
gned long,
 	        volatile unsigned long *, unsigned long, volatile unsigned long *=
, unsigned long);
-	int cnode, mycnode, nasid;
-	volatile unsigned long *piows;
-	volatile unsigned long zeroval;
+	short nasid, i;
+	unsigned long *piows, zeroval;
=20
-	sn2_ptc_deadlock_count++;
+	__get_cpu_var(ptcstats).deadlocks++;
=20
-	piows =3D pda->pio_write_status_addr;
+	piows =3D (unsigned long *) pda->pio_write_status_addr;
 	zeroval =3D pda->pio_write_status_val;
=20
-	mycnode =3D numa_node_id();
-
-	for_each_online_node(cnode) {
-		if (is_headless_node(cnode) || cnode =3D mycnode)
+	for (i=3D0; i < nix; i++) {
+		nasid =3D nasids[i];
+		if (!(sn2_ptctest & 3) && nasid =3D mynasid)
 			continue;
-		nasid =3D cnodeid_to_nasid(cnode);
 		ptc0 =3D CHANGE_NASID(nasid, ptc0);
 		if (ptc1)
 			ptc1 =3D CHANGE_NASID(nasid, ptc1);
 		sn2_ptc_deadlock_recovery_core(ptc0, data0, ptc1, data1, piows, zeroval);
 	}
+
 }
=20
 /**
@@ -293,3 +413,93 @@ void sn2_send_IPI(int cpuid, int vector,
=20
 	sn_send_IPI_phys(nasid, physid, vector, delivery_mode);
 }
+
+#ifdef CONFIG_PROC_FS
+
+#define PTC_BASENAME	"sgi_sn/ptc_statistics"
+
+static void *sn2_ptc_seq_start(struct seq_file *file, loff_t * offset)
+{
+	if (*offset < NR_CPUS)
+		return offset;
+	return NULL;
+}
+
+static void *sn2_ptc_seq_next(struct seq_file *file, void *data, loff_t * =
offset)
+{
+	(*offset)++;
+	if (*offset < NR_CPUS)
+		return offset;
+	return NULL;
+}
+
+static void sn2_ptc_seq_stop(struct seq_file *file, void *data)
+{
+}
+
+static int sn2_ptc_seq_show(struct seq_file *file, void *data)
+{
+	struct ptc_stats *stat;
+	int cpu;
+
+	cpu =3D *(loff_t *) data;
+
+	if (!cpu) {
+		seq_printf(file, "# ptc_l change_rid shub_ptc_flushes shub_nodes_flushed=
 deadlocks lock_nsec shub_nsec shub_nsec_max\n");
+		seq_printf(file, "# ptctest %d\n", sn2_ptctest);
+	}
+
+	if (cpu < NR_CPUS && cpu_online(cpu)) {
+		stat =3D &per_cpu(ptcstats, cpu);
+		seq_printf(file, "cpu %d %ld %ld %ld %ld %ld %ld %ld %ld\n", cpu, stat->=
ptc_l,
+				stat->change_rid, stat->shub_ptc_flushes, stat->nodes_flushed,
+				stat->deadlocks,
+				1000 * stat->lock_itc_clocks / per_cpu(cpu_info, cpu).cyc_per_usec,
+				1000 * stat->shub_itc_clocks / per_cpu(cpu_info, cpu).cyc_per_usec,
+				1000 * stat->shub_itc_clocks_max / per_cpu(cpu_info, cpu).cyc_per_usec=
);
+	}
+
+	return 0;
+}
+
+static struct seq_operations sn2_ptc_seq_ops =3D {
+	.start =3D sn2_ptc_seq_start,
+	.next =3D sn2_ptc_seq_next,
+	.stop =3D sn2_ptc_seq_stop,
+	.show =3D sn2_ptc_seq_show
+};
+
+int sn2_ptc_proc_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &sn2_ptc_seq_ops);
+}
+
+static struct file_operations proc_sn2_ptc_operations =3D {
+	.open =3D sn2_ptc_proc_open,
+	.read =3D seq_read,
+	.llseek =3D seq_lseek,
+	.release =3D seq_release,
+};
+
+static struct proc_dir_entry *proc_sn2_ptc;
+
+static int __init sn2_ptc_init(void)
+{
+	if (!(proc_sn2_ptc =3D create_proc_entry(PTC_BASENAME, 0444, NULL))) {
+		printk(KERN_ERR "unable to create %s proc entry", PTC_BASENAME);
+		return -EINVAL;
+	}
+	proc_sn2_ptc->proc_fops =3D &proc_sn2_ptc_operations;
+	spin_lock_init(&sn2_global_ptc_lock);
+	return 0;
+}
+
+static void __exit sn2_ptc_exit(void)
+{
+	remove_proc_entry(PTC_BASENAME, NULL);
+}
+
+module_init(sn2_ptc_init);
+module_exit(sn2_ptc_exit);
+#endif /* CONFIG_PROC_FS */
+
Index: linux/include/asm-ia64/sn/nodepda.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig/include/asm-ia64/sn/nodepda.h	2005-0=
8-11 09:09:04.421003030 -0500
+++ linux/include/asm-ia64/sn/nodepda.h	2005-08-11 09:09:20.170402805 -0500
@@ -37,7 +37,6 @@ struct phys_cpuid {
=20
 struct nodepda_s {
 	void 		*pdinfo;	/* Platform-dependent per-node info */
-	spinlock_t		bist_lock;
=20
 	/*
 	 * The BTEs on this node are shared by the local cpus
@@ -55,6 +54,8 @@ struct nodepda_s {
 	 * Array of physical cpu identifiers. Indexed by cpuid.
 	 */
 	struct phys_cpuid	phys_cpuid[NR_CPUS];
+	spinlock_t		ptc_lock ____cacheline_aligned_in_smp;
+	spinlock_t		bist_lock;
 };
=20
 typedef struct nodepda_s nodepda_t;
--=20
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


