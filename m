From: Natalie Protasevich <protasnb@gmail.com>
Date: Mon, 03 Sep 2007 08:06:20 +0000
Subject: [PATCH 1/1] Allow global purge traslation cache (ptc.g) to be disabled - take 2
Message-Id: <200709030106.20654.protasnb@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200708301338.34246.protasnb@gmail.com>
In-Reply-To: <200708301338.34246.protasnb@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


From: Natalie Protasevich <protasnb@gmail.com>

This patch allows to disable ptc.g. The code used to be in the kernel, then was removed 
in 2.4 since the bug that it was fixing has gone away. However, some large system vendors 
now want this capability available through a means that can be controlled by the platform 
in the event that there is an issue with either processor or their chipset where global 
ptc.g is not operational.  They want the mechanism for future platforms to work around 
such issues. It is also needed for platform makers when they deliberately do not use the 
global cache purge in their chipset implementation. (For such cases, Intel provided a SAL 
table entry to specify if ptc.g is allowed and how many).

---

  arch/ia64/kernel/smp.c |   50 +++++++++++++++++++++++++++++
  arch/ia64/mm/tlb.c     |   84 +++++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 132 insertions(+), 2 deletions(-)

diff -puN arch/ia64/mm/tlb.c~ptcg arch/ia64/mm/tlb.c
--- linux-2.6.23-rc5/arch/ia64/mm/tlb.c~ptcg	2007-09-02 23:58:54.000000000 -0700
+++ linux-2.6.23-rc5-nataliep/arch/ia64/mm/tlb.c	2007-09-03 00:48:31.000000000 -0700
@@ -18,6 +18,7 @@
 #include <linux/smp.h>
 #include <linux/mm.h>
 #include <linux/bootmem.h>
+#include <linux/irq.h>
 
 #include <asm/delay.h>
 #include <asm/mmu_context.h>
@@ -83,6 +84,77 @@ wrap_mmu_context (struct mm_struct *mm)
 	local_flush_tlb_all();
 }
 
+unsigned long ia64_global_tlb_flush_end, ia64_global_tlb_flush_start,	
+              ia64_global_tlb_flush_nbits, ia64_global_tlb_flush_rid;
+atomic_t ia64_global_tlb_flush_cpu_count;
+
+static int noptcg;
+
+static int __init 
+noptcg_setup(char *str)
+{
+	noptcg = 1;
+	return 1;
+}
+__setup("noptcg", noptcg_setup);
+
+/*
+ * flush_tlb_no_ptcg is called with ptcg_lock locked
+ */
+static inline void
+flush_tlb_no_ptcg (unsigned long start, unsigned long end,
+		    unsigned long nbits)
+{
+	extern void smp_send_flush_tlb (void);
+	unsigned long saved_tpr = 0;
+	unsigned long flags;
+	int cpus = num_online_cpus();
+
+	/*
+	 * Sometimes this is called with interrupts disabled and causes
+	 * deadlock; to avoid this we enable interrupt and raise the TPR
+	 * to enable ONLY IPI.
+	 */
+	local_save_flags(flags);
+	if (!(flags & IA64_PSR_I)) {
+		saved_tpr = ia64_getreg(_IA64_REG_CR_TPR);
+		ia64_srlz_d();
+		ia64_setreg(_IA64_REG_CR_TPR, saved_tpr);
+		ia64_srlz_d();
+		local_irq_enable();
+	}
+
+	ia64_global_tlb_flush_rid = ia64_get_rr(start);
+	ia64_srlz_d();
+	ia64_global_tlb_flush_start = start;
+	ia64_global_tlb_flush_end = end;
+	ia64_global_tlb_flush_nbits = nbits;
+	atomic_set(&ia64_global_tlb_flush_cpu_count, cpus - 1);
+	smp_send_flush_tlb();
+	/*
+	 * Purge local TLB entries. ALAT invalidation is done in ia64_leave_kernel.
+	 */
+	do {
+		ia64_ptcl(start, nbits<<2);
+		start += (1UL << nbits);
+	} while (start < end);
+
+	ia64_srlz_i();			/* srlz.i implies srlz.d */
+
+	/*
+	 * Wait for other CPUs to finish purging entries.
+	 */
+	while (atomic_read(&ia64_global_tlb_flush_cpu_count)) {
+		/* Nothing */
+	}
+
+	if (!(flags & IA64_PSR_I)) {
+		local_irq_disable();
+	 	ia64_setreg(_IA64_REG_CR_TPR, saved_tpr);
+		ia64_srlz_d();
+	}
+}
+
 void
 ia64_global_tlb_purge (struct mm_struct *mm, unsigned long start,
 		       unsigned long end, unsigned long nbits)
@@ -94,9 +166,17 @@ ia64_global_tlb_purge (struct mm_struct 
 		return;
 	}
 
-	/* HW requires global serialization of ptc.ga.  */
+	/* 
+	 * HW requires global serialization of ptc.ga, and same does
+	 * IPI based implementation of global TLB purge
+	 */
 	spin_lock(&ptcg_lock);
-	{
+	if (noptcg) {
+		/*
+		 * Handle the case when ptc.ga is not available in HW
+		 */
+		flush_tlb_no_ptcg(start, end, nbits);
+	} else {
 		do {
 			/*
 			 * Flush ALAT entries also.
diff -puN arch/ia64/kernel/smp.c~ptcg arch/ia64/kernel/smp.c
--- linux-2.6.23-rc5/arch/ia64/kernel/smp.c~ptcg	2007-09-02 23:58:54.000000000 -0700
+++ linux-2.6.23-rc5-nataliep/arch/ia64/kernel/smp.c	2007-09-02 23:59:25.000000000 -0700
@@ -79,6 +79,7 @@ static volatile struct call_data_struct 
 
 #define IPI_CALL_FUNC		0
 #define IPI_CPU_STOP		1
+#define IPI_FLUSH_TLB		2
 #define IPI_KDUMP_CPU_STOP	3
 
 /* This needs to be cacheline aligned because it is written to by *other* CPUs.  */
@@ -174,6 +175,48 @@ handle_IPI (int irq, void *dev_id)
 				unw_init_running(kdump_cpu_freeze, NULL);
 				break;
 #endif
+
+			      case IPI_FLUSH_TLB:
+			      {
+				extern unsigned long ia64_global_tlb_flush_start, 
+				       ia64_global_tlb_flush_end, ia64_global_tlb_flush_nbits, 
+				       ia64_global_tlb_flush_rid;
+				extern atomic_t ia64_global_tlb_flush_cpu_count;
+				unsigned long saved_rid = ia64_get_rr(ia64_global_tlb_flush_start);
+				unsigned long end = ia64_global_tlb_flush_end;
+				unsigned long start = ia64_global_tlb_flush_start;
+				unsigned long nbits = ia64_global_tlb_flush_nbits;
+	
+				/*
+				 * Current CPU may be running with different RID so we need to
+				 * reload the RID of flushed address.  Purging the translation
+				 * also needs ALAT invalidation; we do not need "invala" here
+				 * since it is done in ia64_leave_kernel.
+				 */
+				ia64_srlz_d();
+				if (saved_rid != ia64_global_tlb_flush_rid) {
+					ia64_set_rr(ia64_global_tlb_flush_start, ia64_global_tlb_flush_rid);
+					ia64_srlz_d();
+				}
+
+				do {
+					/*
+					 * Purge local TLB entries.
+				 	 */
+					ia64_ptcl(start, nbits<<2);
+					start += (1UL << nbits);
+				} while (start < end);
+
+				ia64_barrier();
+				ia64_srlz_i();			/* srlz.i implies srlz.d */
+
+				if (saved_rid != ia64_global_tlb_flush_rid) {
+					ia64_set_rr(ia64_global_tlb_flush_start, saved_rid);
+					ia64_srlz_d();
+				}
+				atomic_dec(&ia64_global_tlb_flush_cpu_count);
+				break;
+			      }
 			      default:
 				printk(KERN_CRIT "Unknown IPI on CPU %d: %lu\n", this_cpu, which);
 				break;
@@ -317,6 +360,13 @@ smp_flush_tlb_cpumask(cpumask_t xcpumask
 }
 
 void
+smp_send_flush_tlb (void)
+{
+	send_IPI_allbutself(IPI_FLUSH_TLB);
+}
+
+
+void
 smp_flush_tlb_all (void)
 {
 	on_each_cpu((void (*)(void *))local_flush_tlb_all, NULL, 1, 1);
_
