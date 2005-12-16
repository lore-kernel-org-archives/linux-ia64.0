From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 16 Dec 2005 21:12:21 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200512162112.jBGLCL1i027170@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

Could this be the real, final ia64 pull?  Only time will  tell.

The "disable preemption in udelay()" patch should have had a better
one-line description ... we break long udelay() calls into a series
of short non-preemptible pauses.  See the patch at the bottom of this
e-mail.  This will probably get more tuning post 2.6.15.

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/configs/sn2_defconfig   |    2 +-
 arch/ia64/kernel/time.c           |   29 +++++++++++++++++++++++++++++
 arch/ia64/kernel/uncached.c       |    6 +++---
 arch/ia64/kernel/vmlinux.lds.S    |    3 +++
 arch/ia64/sn/kernel/sn2/sn2_smp.c |    2 +-
 include/asm-ia64/delay.h          |   10 +---------
 include/linux/cache.h             |    2 +-
 7 files changed, 39 insertions(+), 15 deletions(-)

Christoph Lameter:
      [IA64] Add __read_mostly support for IA64

hawkes@sgi.com:
      [IA64-SGI] change default_sn2 to NR_CPUS=1024

Jack Steiner:
      [IA64-SGI] Missed TLB flush

Jes Sorensen:
      [IA64] uncached ref count leak

John Hawkes:
      [IA64] disable preemption in udelay()

diff-tree dc86e88c2bb8a7603ee175fbb6a9e92cf3293dd8 (from d5bf3165b6fbb879a4658f9da9ca2fe002b75f08)
Author: Christoph Lameter <clameter@engr.sgi.com>
Date:   Mon Dec 12 09:34:32 2005 -0800

    [IA64] Add __read_mostly support for IA64
    
    sparc64, i386 and x86_64 have support for a special data section dedicated
    to rarely updated data that is frequently read. The section was created to
    avoid false sharing of those rarely read data with frequently written kernel
    data.
    
    This patch creates such a data section for ia64 and will group rarely written
    data into this section.
    
    Signed-off-by: Christoph Lameter <clameter@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/vmlinux.lds.S b/arch/ia64/kernel/vmlinux.lds.S
index 30d8564..73af626 100644
--- a/arch/ia64/kernel/vmlinux.lds.S
+++ b/arch/ia64/kernel/vmlinux.lds.S
@@ -177,6 +177,9 @@ SECTIONS
 	}
   . = ALIGN(PAGE_SIZE);		/* make sure the gate page doesn't expose kernel data */
 
+  .data.read_mostly : AT(ADDR(.data.read_mostly) - LOAD_OFFSET)
+        { *(.data.read_mostly) }
+
   .data.cacheline_aligned : AT(ADDR(.data.cacheline_aligned) - LOAD_OFFSET)
         { *(.data.cacheline_aligned) }
 
diff --git a/include/linux/cache.h b/include/linux/cache.h
index f6b5a46..0b7ecf3 100644
--- a/include/linux/cache.h
+++ b/include/linux/cache.h
@@ -13,7 +13,7 @@
 #define SMP_CACHE_BYTES L1_CACHE_BYTES
 #endif
 
-#if defined(CONFIG_X86) || defined(CONFIG_SPARC64)
+#if defined(CONFIG_X86) || defined(CONFIG_SPARC64) || defined(CONFIG_IA64)
 #define __read_mostly __attribute__((__section__(".data.read_mostly")))
 #else
 #define __read_mostly

diff-tree d5bf3165b6fbb879a4658f9da9ca2fe002b75f08 (from d74700e604db717eef7a3112176e6350fb00d0e3)
Author: hawkes@sgi.com <hawkes@sgi.com>
Date:   Tue Dec 13 13:45:44 2005 -0800

    [IA64-SGI] change default_sn2 to NR_CPUS=1024
    
    Change the NR_CPUS default for ia64/sn up to 1024.
    
    Signed-off-by: John Hawkes <hawkes@sgi.com>
    Signed-off-by: John Hesterberg <jh@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/configs/sn2_defconfig b/arch/ia64/configs/sn2_defconfig
index e1924cc..ff8bb37 100644
--- a/arch/ia64/configs/sn2_defconfig
+++ b/arch/ia64/configs/sn2_defconfig
@@ -113,7 +113,7 @@ CONFIG_IOSAPIC=y
 CONFIG_IA64_SGI_SN_XP=m
 CONFIG_FORCE_MAX_ZONEORDER
 CONFIG_SMP=y
-CONFIG_NR_CPUSQ2
+CONFIG_NR_CPUS24
 # CONFIG_HOTPLUG_CPU is not set
 CONFIG_SCHED_SMT=y
 CONFIG_PREEMPT=y

diff-tree d74700e604db717eef7a3112176e6350fb00d0e3 (from 3bd7f01713f30e7c616ab975ebb84ab7eb58a60a)
Author: Jack Steiner <steiner@sgi.com>
Date:   Thu Dec 15 12:41:22 2005 -0600

    [IA64-SGI] Missed TLB flush
    
    I see why the problem exists only on SN. SN uses a different hardware
    mechanism to purge TLB entries across nodes.
    
    It looks like there is a bug in the SN TLB flushing code. During context switch,
    kernel threads inherit the mm of the task that was previously running on the
    cpu. This confuses the code in sn2_global_tlb_purge().
    
    The result is a missed TLB purge for the task that owns the "borrowed" mm.
    
    (I hit the problem running heavy stress where kswapd was purging code pages of
    a user task that woke kswapd. The user task took a SIGILL fault trying to
    execute code in the page that had been ripped out from underneath it).
    
    Signed-off-by: Jack Steiner <steiner@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/sn/kernel/sn2/sn2_smp.c b/arch/ia64/sn/kernel/sn2/sn2_smp.c
index 5d54f5f..471bbaa 100644
--- a/arch/ia64/sn/kernel/sn2/sn2_smp.c
+++ b/arch/ia64/sn/kernel/sn2/sn2_smp.c
@@ -202,7 +202,7 @@ sn2_global_tlb_purge(struct mm_struct *m
 		     unsigned long end, unsigned long nbits)
 {
 	int i, opt, shub1, cnode, mynasid, cpu, lcpu = 0, nasid, flushed = 0;
-	int mymm = (mm = current->active_mm);
+	int mymm = (mm = current->active_mm && current->mm);
 	volatile unsigned long *ptc0, *ptc1;
 	unsigned long itc, itc2, flags, data0 = 0, data1 = 0, rr_value;
 	short nasids[MAX_NUMNODES], nix;

diff-tree 3bd7f01713f30e7c616ab975ebb84ab7eb58a60a (from f5899b5d4fa806403f547dc41312d017d94ec273)
Author: Jes Sorensen <jes@trained-monkey.org>
Date:   Fri Dec 16 11:00:03 2005 -0500

    [IA64] uncached ref count leak
    
    Use raw_smp_processor_id() instead of get_cpu() as we don't need the
    extra features of get_cpu().
    
    Signed-off-by: Jes Sorensen <jes@trained-monkey.org>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/uncached.c b/arch/ia64/kernel/uncached.c
index c6d4044..b631cf8 100644
--- a/arch/ia64/kernel/uncached.c
+++ b/arch/ia64/kernel/uncached.c
@@ -53,7 +53,7 @@ static void uncached_ipi_visibility(void
 	if ((status != PAL_VISIBILITY_OK) &&
 	    (status != PAL_VISIBILITY_OK_REMOTE_NEEDED))
 		printk(KERN_DEBUG "pal_prefetch_visibility() returns %i on "
-		       "CPU %i\n", status, get_cpu());
+		       "CPU %i\n", status, raw_smp_processor_id());
 }
 
 
@@ -63,7 +63,7 @@ static void uncached_ipi_mc_drain(void *
 	status = ia64_pal_mc_drain();
 	if (status)
 		printk(KERN_WARNING "ia64_pal_mc_drain() failed with %i on "
-		       "CPU %i\n", status, get_cpu());
+		       "CPU %i\n", status, raw_smp_processor_id());
 }
 
 
@@ -105,7 +105,7 @@ uncached_get_new_chunk(struct gen_pool *
 	status = ia64_pal_prefetch_visibility(PAL_VISIBILITY_PHYSICAL);
 
 	dprintk(KERN_INFO "pal_prefetch_visibility() returns %i on cpu %i\n",
-		status, get_cpu());
+		status, raw_smp_processor_id());
 
 	if (!status) {
 		status = smp_call_function(uncached_ipi_visibility, NULL, 0, 1);

diff-tree f5899b5d4fa806403f547dc41312d017d94ec273 (from 7b6666530e2736f190a2629c8abe34275054449f)
Author: John Hawkes <hawkes@sgi.com>
Date:   Fri Dec 16 10:00:24 2005 -0800

    [IA64] disable preemption in udelay()
    
    The udelay() inline for ia64 uses the ITC.  If CONFIG_PREEMPT is enabled
    and the platform has unsynchronized ITCs and the calling task migrates
    to another CPU while doing the udelay loop, then the effective delay may
    be too short or very, very long.
    
    This patch disables preemption around 100 usec chunks of the overall
    desired udelay time.  This minimizes preemption-holdoffs.
    
    udelay() is now too big to be inline, move it out of line and export it.
    
    Signed-off-by: John Hawkes <hawkes@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/time.c b/arch/ia64/kernel/time.c
index 5b7e736..028a2b9 100644
--- a/arch/ia64/kernel/time.c
+++ b/arch/ia64/kernel/time.c
@@ -249,3 +249,32 @@ time_init (void)
 	 */
 	set_normalized_timespec(&wall_to_monotonic, -xtime.tv_sec, -xtime.tv_nsec);
 }
+
+#define SMALLUSECS 100
+
+void
+udelay (unsigned long usecs)
+{
+	unsigned long start;
+	unsigned long cycles;
+	unsigned long smallusecs;
+
+	/*
+	 * Execute the non-preemptible delay loop (because the ITC might
+	 * not be synchronized between CPUS) in relatively short time
+	 * chunks, allowing preemption between the chunks.
+	 */
+	while (usecs > 0) {
+		smallusecs = (usecs > SMALLUSECS) ? SMALLUSECS : usecs;
+		preempt_disable();
+		cycles = smallusecs*local_cpu_data->cyc_per_usec;
+		start = ia64_get_itc();
+
+		while (ia64_get_itc() - start < cycles)
+			cpu_relax();
+
+		preempt_enable();
+		usecs -= smallusecs;
+	}
+}
+EXPORT_SYMBOL(udelay);
diff --git a/include/asm-ia64/delay.h b/include/asm-ia64/delay.h
index 57182d6..bba7020 100644
--- a/include/asm-ia64/delay.h
+++ b/include/asm-ia64/delay.h
@@ -84,14 +84,6 @@ __delay (unsigned long loops)
 	ia64_delay_loop (loops - 1);
 }
 
-static __inline__ void
-udelay (unsigned long usecs)
-{
-	unsigned long start = ia64_get_itc();
-	unsigned long cycles = usecs*local_cpu_data->cyc_per_usec;
-
-	while (ia64_get_itc() - start < cycles)
-		cpu_relax();
-}
+extern void udelay (unsigned long usecs);
 
 #endif /* _ASM_IA64_DELAY_H */
