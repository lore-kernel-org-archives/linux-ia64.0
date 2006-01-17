From: Jack Steiner <steiner@sgi.com>
Date: Tue, 17 Jan 2006 22:22:18 +0000
Subject: [PATCH] - Update TLB flushing code for SN platform
Message-Id: <20060117222218.GA26725@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


This patch only affects the TLB flushing code for SGI SN platforms. No other
platforms are affected.

This patch finishes support for SHUB2 (the new chipset). Most of the
changes are performance related. A few changes are workarounds for
"interesting" chipset features.

Some temporary debugging code has also been deleted. 



        Signed-off-by: Jack Steiner <steiner@sgi.com>



Index: linux/arch/ia64/sn/kernel/sn2/sn2_smp.c
=================================--- linux.orig/arch/ia64/sn/kernel/sn2/sn2_smp.c	2006-01-17 14:19:11.726791060 -0600
+++ linux/arch/ia64/sn/kernel/sn2/sn2_smp.c	2006-01-17 14:41:40.110493730 -0600
@@ -5,7 +5,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 2000-2005 Silicon Graphics, Inc. All rights reserved.
+ * Copyright (C) 2000-2006 Silicon Graphics, Inc. All rights reserved.
  */
 
 #include <linux/init.h>
@@ -46,104 +46,28 @@ DECLARE_PER_CPU(struct ptc_stats, ptcsta
 
 static  __cacheline_aligned DEFINE_SPINLOCK(sn2_global_ptc_lock);
 
-void sn2_ptc_deadlock_recovery(short *, short, int, volatile unsigned long *, unsigned long data0,
-	volatile unsigned long *, unsigned long data1);
+void sn2_ptc_deadlock_recovery(short *, short, short, int, volatile unsigned long *, unsigned long,
+	volatile unsigned long *, unsigned long);
 
-#ifdef DEBUG_PTC
 /*
- * ptctest:
- *
- * 	xyz - 3 digit hex number:
- * 		x - Force PTC purges to use shub:
- * 			0 - no force
- * 			1 - force
- * 		y - interupt enable
- * 			0 - disable interrupts
- * 			1 - leave interuupts enabled
- * 		z - type of lock:
- * 			0 - global lock
- * 			1 - node local lock
- * 			2 - no lock
- *
- *   	Note: on shub1, only ptctest = 0 is supported. Don't try other values!
+ * Note: some is the following is captured here to make degugging easier
+ * (the macros make more sense if you see the debug patch - not posted)
  */
-
-static unsigned int sn2_ptctest = 0;
-
-static int __init ptc_test(char *str)
-{
-	get_option(&str, &sn2_ptctest);
-	return 1;
-}
-__setup("ptctest=", ptc_test);
-
-static inline int ptc_lock(unsigned long *flagp)
-{
-	unsigned long opt = sn2_ptctest & 255;
-
-	switch (opt) {
-	case 0x00:
-		spin_lock_irqsave(&sn2_global_ptc_lock, *flagp);
-		break;
-	case 0x01:
-		spin_lock_irqsave(&sn_nodepda->ptc_lock, *flagp);
-		break;
-	case 0x02:
-		local_irq_save(*flagp);
-		break;
-	case 0x10:
-		spin_lock(&sn2_global_ptc_lock);
-		break;
-	case 0x11:
-		spin_lock(&sn_nodepda->ptc_lock);
-		break;
-	case 0x12:
-		break;
-	default:
-		BUG();
-	}
-	return opt;
-}
-
-static inline void ptc_unlock(unsigned long flags, int opt)
-{
-	switch (opt) {
-	case 0x00:
-		spin_unlock_irqrestore(&sn2_global_ptc_lock, flags);
-		break;
-	case 0x01:
-		spin_unlock_irqrestore(&sn_nodepda->ptc_lock, flags);
-		break;
-	case 0x02:
-		local_irq_restore(flags);
-		break;
-	case 0x10:
-		spin_unlock(&sn2_global_ptc_lock);
-		break;
-	case 0x11:
-		spin_unlock(&sn_nodepda->ptc_lock);
-		break;
-	case 0x12:
-		break;
-	default:
-		BUG();
-	}
-}
-#else
-
 #define sn2_ptctest	0
+#define local_node_uses_ptc_ga(sh1)	((sh1) ? 1 : 0)
+#define max_active_pio(sh1)		((sh1) ? 32 : 7)
+#define reset_max_active_on_deadlock()	1
+#define PTC_LOCK(sh1)			((sh1) ? &sn2_global_ptc_lock : &sn_nodepda->ptc_lock)
 
-static inline int ptc_lock(unsigned long *flagp)
+static inline void ptc_lock(int sh1, unsigned long *flagp)
 {
-	spin_lock_irqsave(&sn2_global_ptc_lock, *flagp);
-	return 0;
+	spin_lock_irqsave(PTC_LOCK(sh1), *flagp);
 }
 
-static inline void ptc_unlock(unsigned long flags, int opt)
+static inline void ptc_unlock(int sh1, unsigned long flags)
 {
-	spin_unlock_irqrestore(&sn2_global_ptc_lock, flags);
+	spin_unlock_irqrestore(PTC_LOCK(sh1), flags);
 }
-#endif
 
 struct ptc_stats {
 	unsigned long ptc_l;
@@ -151,27 +75,30 @@ struct ptc_stats {
 	unsigned long shub_ptc_flushes;
 	unsigned long nodes_flushed;
 	unsigned long deadlocks;
+	unsigned long deadlocks2;
 	unsigned long lock_itc_clocks;
 	unsigned long shub_itc_clocks;
 	unsigned long shub_itc_clocks_max;
+	unsigned long shub_ptc_flushes_not_my_mm;
 };
 
 static inline unsigned long wait_piowc(void)
 {
-	volatile unsigned long *piows, zeroval;
-	unsigned long ws;
+	volatile unsigned long *piows;
+	unsigned long zeroval, ws;
 
 	piows = pda->pio_write_status_addr;
 	zeroval = pda->pio_write_status_val;
 	do {
 		cpu_relax();
 	} while (((ws = *piows) & SH_PIO_WRITE_STATUS_PENDING_WRITE_COUNT_MASK) != zeroval);
-	return ws;
+	return (ws & SH_PIO_WRITE_STATUS_WRITE_DEADLOCK_MASK) != 0;
 }
 
 void sn_tlb_migrate_finish(struct mm_struct *mm)
 {
-	if (mm = current->mm)
+	/* flush_tlb_mm is inefficient if more than 1 users of mm */
+	if (mm = current->mm && mm && atomic_read(&mm->mm_users) = 1)
 		flush_tlb_mm(mm);
 }
 
@@ -201,12 +128,14 @@ void
 sn2_global_tlb_purge(struct mm_struct *mm, unsigned long start,
 		     unsigned long end, unsigned long nbits)
 {
-	int i, opt, shub1, cnode, mynasid, cpu, lcpu = 0, nasid, flushed = 0;
-	int mymm = (mm = current->active_mm && current->mm);
+	int i, ibegin, shub1, cnode, mynasid, cpu, lcpu = 0, nasid;
+	int mymm = (mm = current->active_mm && mm = current->mm);
+	int use_cpu_ptcga;
 	volatile unsigned long *ptc0, *ptc1;
-	unsigned long itc, itc2, flags, data0 = 0, data1 = 0, rr_value;
+	unsigned long itc, itc2, flags, data0 = 0, data1 = 0, rr_value, old_rr = 0;;
 	short nasids[MAX_NUMNODES], nix;
 	nodemask_t nodes_flushed;
+	int active, max_active, deadlock;
 
 	nodes_clear(nodes_flushed);
 	i = 0;
@@ -267,41 +196,56 @@ sn2_global_tlb_purge(struct mm_struct *m
 	
 
 	mynasid = get_nasid();
+	use_cpu_ptcga = local_node_uses_ptc_ga(shub1);
+	max_active = max_active_pio(shub1);
 
 	itc = ia64_get_itc();
-	opt = ptc_lock(&flags);
+	ptc_lock(shub1, &flags);
 	itc2 = ia64_get_itc();
+
 	__get_cpu_var(ptcstats).lock_itc_clocks += itc2 - itc;
 	__get_cpu_var(ptcstats).shub_ptc_flushes++;
 	__get_cpu_var(ptcstats).nodes_flushed += nix;
+	if (!mymm)
+		 __get_cpu_var(ptcstats).shub_ptc_flushes_not_my_mm++;
 
+	if (use_cpu_ptcga && !mymm) {
+		old_rr = ia64_get_rr(start);
+		ia64_set_rr(start, (old_rr & 0xff) | (rr_value << 8));
+		ia64_srlz_d();
+	}
+
+	wait_piowc();
 	do {
 		if (shub1)
 			data1 = start | (1UL << SH1_PTC_1_START_SHFT);
 		else
 			data0 = (data0 & ~SH2_PTC_ADDR_MASK) | (start & SH2_PTC_ADDR_MASK);
-		for (i = 0; i < nix; i++) {
+		deadlock = 0;
+		active = 0;
+		for (ibegin = 0, i = 0; i < nix; i++) {
 			nasid = nasids[i];
-			if ((!(sn2_ptctest & 3)) && unlikely(nasid = mynasid && mymm)) {
+			if (use_cpu_ptcga && unlikely(nasid = mynasid)) {
 				ia64_ptcga(start, nbits << 2);
 				ia64_srlz_i();
 			} else {
 				ptc0 = CHANGE_NASID(nasid, ptc0);
 				if (ptc1)
 					ptc1 = CHANGE_NASID(nasid, ptc1);
-				pio_atomic_phys_write_mmrs(ptc0, data0, ptc1,
-							   data1);
-				flushed = 1;
+				pio_atomic_phys_write_mmrs(ptc0, data0, ptc1, data1);
+				active++;
+			}
+			if (active >= max_active || i = (nix - 1)) {
+				if ((deadlock = wait_piowc())) {
+					sn2_ptc_deadlock_recovery(nasids, ibegin, i, mynasid, ptc0, data0, ptc1, data1);
+					if (reset_max_active_on_deadlock())
+						max_active = 1;
+				}
+				active = 0;
+				ibegin = i + 1;
 			}
 		}
-		if (flushed
-		    && (wait_piowc() &
-				(SH_PIO_WRITE_STATUS_WRITE_DEADLOCK_MASK))) {
-			sn2_ptc_deadlock_recovery(nasids, nix, mynasid, ptc0, data0, ptc1, data1);
-		}
-
 		start += (1UL << nbits);
-
 	} while (start < end);
 
 	itc2 = ia64_get_itc() - itc2;
@@ -309,7 +253,12 @@ sn2_global_tlb_purge(struct mm_struct *m
 	if (itc2 > __get_cpu_var(ptcstats).shub_itc_clocks_max)
 		__get_cpu_var(ptcstats).shub_itc_clocks_max = itc2;
 
-	ptc_unlock(flags, opt);
+	if (old_rr) {
+		ia64_set_rr(start, old_rr);
+		ia64_srlz_d();
+	}
+
+	ptc_unlock(shub1, flags);
 
 	preempt_enable();
 }
@@ -321,27 +270,30 @@ sn2_global_tlb_purge(struct mm_struct *m
  * TLB flush transaction.  The recovery sequence is somewhat tricky & is
  * coded in assembly language.
  */
-void sn2_ptc_deadlock_recovery(short *nasids, short nix, int mynasid, volatile unsigned long *ptc0, unsigned long data0,
+void sn2_ptc_deadlock_recovery(short *nasids, short ib, short ie, int mynasid, volatile unsigned long *ptc0, unsigned long data0,
 	volatile unsigned long *ptc1, unsigned long data1)
 {
-	extern void sn2_ptc_deadlock_recovery_core(volatile unsigned long *, unsigned long,
+	extern unsigned long sn2_ptc_deadlock_recovery_core(volatile unsigned long *, unsigned long,
 	        volatile unsigned long *, unsigned long, volatile unsigned long *, unsigned long);
 	short nasid, i;
-	unsigned long *piows, zeroval;
+	unsigned long *piows, zeroval, n;
 
 	__get_cpu_var(ptcstats).deadlocks++;
 
 	piows = (unsigned long *) pda->pio_write_status_addr;
 	zeroval = pda->pio_write_status_val;
 
-	for (i=0; i < nix; i++) {
+
+	for (i=ib; i <= ie; i++) {
 		nasid = nasids[i];
-		if (!(sn2_ptctest & 3) && nasid = mynasid)
+		if (local_node_uses_ptc_ga(is_shub1()) && nasid = mynasid)
 			continue;
 		ptc0 = CHANGE_NASID(nasid, ptc0);
 		if (ptc1)
 			ptc1 = CHANGE_NASID(nasid, ptc1);
-		sn2_ptc_deadlock_recovery_core(ptc0, data0, ptc1, data1, piows, zeroval);
+
+		n = sn2_ptc_deadlock_recovery_core(ptc0, data0, ptc1, data1, piows, zeroval);
+		__get_cpu_var(ptcstats).deadlocks2 += n;
 	}
 
 }
@@ -452,20 +404,22 @@ static int sn2_ptc_seq_show(struct seq_f
 	cpu = *(loff_t *) data;
 
 	if (!cpu) {
-		seq_printf(file, "# ptc_l change_rid shub_ptc_flushes shub_nodes_flushed deadlocks lock_nsec shub_nsec shub_nsec_max\n");
+		seq_printf(file,
+			   "# cpu ptc_l newrid ptc_flushes nodes_flushed deadlocks lock_nsec shub_nsec shub_nsec_max not_my_mm deadlock2\n");
 		seq_printf(file, "# ptctest %d\n", sn2_ptctest);
 	}
 
 	if (cpu < NR_CPUS && cpu_online(cpu)) {
 		stat = &per_cpu(ptcstats, cpu);
-		seq_printf(file, "cpu %d %ld %ld %ld %ld %ld %ld %ld %ld\n", cpu, stat->ptc_l,
+		seq_printf(file, "cpu %d %ld %ld %ld %ld %ld %ld %ld %ld %ld %ld\n", cpu, stat->ptc_l,
 				stat->change_rid, stat->shub_ptc_flushes, stat->nodes_flushed,
 				stat->deadlocks,
 				1000 * stat->lock_itc_clocks / per_cpu(cpu_info, cpu).cyc_per_usec,
 				1000 * stat->shub_itc_clocks / per_cpu(cpu_info, cpu).cyc_per_usec,
-				1000 * stat->shub_itc_clocks_max / per_cpu(cpu_info, cpu).cyc_per_usec);
+				1000 * stat->shub_itc_clocks_max / per_cpu(cpu_info, cpu).cyc_per_usec,
+				stat->shub_ptc_flushes_not_my_mm,
+				stat->deadlocks2);
 	}
-
 	return 0;
 }
 
@@ -476,7 +430,7 @@ static struct seq_operations sn2_ptc_seq
 	.show = sn2_ptc_seq_show
 };
 
-int sn2_ptc_proc_open(struct inode *inode, struct file *file)
+static int sn2_ptc_proc_open(struct inode *inode, struct file *file)
 {
 	return seq_open(file, &sn2_ptc_seq_ops);
 }
