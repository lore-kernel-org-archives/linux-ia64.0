From: Jes Sorensen <jes@sgi.com>
Date: Mon, 03 Sep 2007 09:37:05 +0000
Subject: Re: [PATCH 1/1] Allow global purge traslation cache (ptc.g) to be disabled - take 2
Message-Id: <yq0y7fodr9a.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <200708301338.34246.protasnb@gmail.com>
In-Reply-To: <200708301338.34246.protasnb@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


> From: Natalie Protasevich <protasnb@gmail.com>

> This patch allows to disable ptc.g. The code used to be in the
> kernel, then was removed in 2.4 since the bug that it was fixing has
> gone away. However, some large system vendors now want this
> capability available through a means that can be controlled by the
> platform in the event that there is an issue with either processor
> or their chipset where global ptc.g is not operational.  They want
> the mechanism for future platforms to work around such issues. It
> is also needed for platform makers when they deliberately do not
> use the global cache purge in their chipset implementation. (For
> such cases, Intel provided a SAL table entry to specify if ptc.g is
> allowed and how many).

Hi Natalie,

I still don't understand the need for this patch given my comment to
your last posting and I'd like to know what the actual usage scenario
is.

That said, a few comments on the coding style and patch submission
below. Please make sure to read Documentation/CodingStyle and
Documentation/SubmittingPatches

1) No Signed-off-by: line.
---

+/*
+ * flush_tlb_no_ptcg is called with ptcg_lock locked
+ */
+static inline void
+flush_tlb_no_ptcg (unsigned long start, unsigned long end,
+		    unsigned long nbits)
+{
+	extern void smp_send_flush_tlb (void);

Ewwwwwwwww! prototypes within the function :-(

+	atomic_set(&ia64_global_tlb_flush_cpu_count, cpus - 1);
+	smp_send_flush_tlb();
+	/*
+	 * Purge local TLB entries. ALAT invalidation is done in ia64_leave_kernel.
+	 */

A column is 80 characters, max.

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

This just underlines why this should be implemented via the machine
vectors.

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

Please, no external prototypes hidden within the function!

Indents are 8 chars - but if you put the extern's in the place where
they belond you won't need the brackets here in the first place.

+				unsigned long saved_rid = ia64_get_rr(ia64_global_tlb_flush_start);
+				unsigned long end = ia64_global_tlb_flush_end;
+				unsigned long start = ia64_global_tlb_flush_start;
+				unsigned long nbits = ia64_global_tlb_flush_nbits;

Again, stick to 80 characters.

+	

Gratitious whitespace.

+				/*
+				 * Current CPU may be running with different RID so we need to
+				 * reload the RID of flushed address.  Purging the translation
+				 * also needs ALAT invalidation; we do not need "invala" here
+				 * since it is done in ia64_leave_kernel.
+				 */

More 80 character problems.

+				ia64_srlz_d();
+				if (saved_rid != ia64_global_tlb_flush_rid) {
+					ia64_set_rr(ia64_global_tlb_flush_start, ia64_global_tlb_flush_rid);

Ditto

+				if (saved_rid != ia64_global_tlb_flush_rid) {
+					ia64_set_rr(ia64_global_tlb_flush_start, saved_rid);

And again....

+					ia64_srlz_d();
+				}
+				atomic_dec(&ia64_global_tlb_flush_cpu_count);
+				break;
+			      }
 			      default:
 				printk(KERN_CRIT "Unknown IPI on CPU %d: %lu\n", this_cpu, which);

And again....

