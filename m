From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 01 Nov 2006 00:56:45 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200611010056.kA10ujie017835@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/kernel/mca_drv.c |   95 ++++++++++++++++++++++++++++++++-------------
 arch/ia64/kernel/sal.c     |   11 +++--
 arch/ia64/kernel/setup.c   |    2 
 arch/ia64/kernel/smp.c     |   12 +++--
 include/asm-ia64/sal.h     |    1 
 include/asm-ia64/uaccess.h |    2 
 6 files changed, 86 insertions(+), 37 deletions(-)

Jes Sorensen:
      [IA64] don't double >> PAGE_SHIFT pointer for /dev/kmem access

Keith Owens:
      [IA64] Correct definition of handle_IPI

Kenji Kaneshige:
      [IA64] cpu-hotplug: Fixing confliction between CPU hot-add and IPI

Russ Anderson:
      [IA64] MCA recovery: Montecito support

Troy Heber:
      [IA64] move SAL_CACHE_FLUSH check later in boot

Full diffs & commit messages according to "git whatchanged -p" ...

commit 024e4f2c5175a482c234cf67ed22368d770bf78f
Author: Keith Owens <kaos@sgi.com>
Date:   Wed Oct 18 15:36:49 2006 +1000

    [IA64] Correct definition of handle_IPI
    
    The declaration of handle_IPI in arch/ia64/kernel/smp.c was changed but
    not the definition of this function.  Remove struct pt_regs from
    handle_IPI().
    
    Signed-off-by: Keith Owens <kaos@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/smp.c b/arch/ia64/kernel/smp.c
index 2763e79..6ab95ce 100644
--- a/arch/ia64/kernel/smp.c
+++ b/arch/ia64/kernel/smp.c
@@ -108,7 +108,7 @@ cpu_die(void)
 }
 
 irqreturn_t
-handle_IPI (int irq, void *dev_id, struct pt_regs *regs)
+handle_IPI (int irq, void *dev_id)
 {
 	int this_cpu = get_cpu();
 	unsigned long *pending_ipis = &__ia64_per_cpu_var(ipi_operation);

commit fa1d19e5d9a94120f31e5783ab44758f46892d94
Author: Troy Heber <troy.heber@hp.com>
Date:   Wed Oct 25 14:46:15 2006 -0600

    [IA64] move SAL_CACHE_FLUSH check later in boot
    
    The check to see if the firmware drops interrupts during a
    SAL_CACHE_FLUSH is done to early in the boot. SAL_CACHE_FLUSH expects
    to be able to make PAL calls in virtual mode, on some cell based
    machines a fault occurs causing a MCA. This patch moves the check
    after mmu_context_init so the TLB and VHPT are properly setup.
    
    Signed-off-by Troy Heber <troy.heber@hp.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/sal.c b/arch/ia64/kernel/sal.c
index 642fdc7..20bad78 100644
--- a/arch/ia64/kernel/sal.c
+++ b/arch/ia64/kernel/sal.c
@@ -223,12 +223,13 @@ #endif
  */
 static int sal_cache_flush_drops_interrupts;
 
-static void __init
+void __init
 check_sal_cache_flush (void)
 {
 	unsigned long flags;
 	int cpu;
-	u64 vector;
+	u64 vector, cache_type = 3;
+	struct ia64_sal_retval isrv;
 
 	cpu = get_cpu();
 	local_irq_save(flags);
@@ -243,7 +244,10 @@ check_sal_cache_flush (void)
 	while (!ia64_get_irr(IA64_TIMER_VECTOR))
 		cpu_relax();
 
-	ia64_sal_cache_flush(3);
+	SAL_CALL(isrv, SAL_CACHE_FLUSH, cache_type, 0, 0, 0, 0, 0, 0);
+
+	if (isrv.status)
+		printk(KERN_ERR "SAL_CAL_FLUSH failed with %ld\n", isrv.status);
 
 	if (ia64_get_irr(IA64_TIMER_VECTOR)) {
 		vector = ia64_get_ivr();
@@ -331,7 +335,6 @@ #endif
 		p += SAL_DESC_SIZE(*p);
 	}
 
-	check_sal_cache_flush();
 }
 
 int
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index c4caa80..d10404a 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -457,6 +457,8 @@ #endif
 	cpu_init();	/* initialize the bootstrap CPU */
 	mmu_context_init();	/* initialize context_id bitmap */
 
+	check_sal_cache_flush();
+
 #ifdef CONFIG_ACPI
 	acpi_boot_init();
 #endif
diff --git a/include/asm-ia64/sal.h b/include/asm-ia64/sal.h
index 0b210ab..d000689 100644
--- a/include/asm-ia64/sal.h
+++ b/include/asm-ia64/sal.h
@@ -659,6 +659,7 @@ ia64_sal_freq_base (unsigned long which,
 }
 
 extern s64 ia64_sal_cache_flush (u64 cache_type);
+extern void __init check_sal_cache_flush (void);
 
 /* Initialize all the processor and platform level instruction and data caches */
 static inline s64

commit 264b0f99308436deaee38bab99e586612d012fc1
Author: Russ Anderson <rja@sgi.com>
Date:   Wed Oct 25 17:59:47 2006 -0500

    [IA64] MCA recovery: Montecito support
    
    The information in MCA records is filled in slightly differently on
    Montecito than on Madison/McKinley.  Usually, the cache check and bus
    check target identifiers have the same address.   On Montecito the
    cache check and bus check target identifiers can be different if
    a corrected error (ie SBE or unconsumed poison data) was encountered and
    then an uncorrected error (ie DBE) was consumed.  In that case, the
    cache check target identifier is the physical address of the DBE (that
    caused the MCA to surface) while the bus check target identifier is the
    physical address of the SBE.  This patch correctly finds the target
    identifier that triggered the MCA.
    
    If there are multiple valid cache target identifiers in the same
    error record then use the one with the lowest cache level.
    
    Signed-off-by: Russ Anderson (rja@sgi.com)
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/mca_drv.c b/arch/ia64/kernel/mca_drv.c
index a45009d..afc1403 100644
--- a/arch/ia64/kernel/mca_drv.c
+++ b/arch/ia64/kernel/mca_drv.c
@@ -435,6 +435,50 @@ is_mca_global(peidx_table_t *peidx, pal_
 }
 
 /**
+ * get_target_identifier - Get the valid Cache or Bus check target identifier.
+ * @peidx:	pointer of index of processor error section
+ *
+ * Return value:
+ *	target address on Success / 0 on Failue
+ */
+static u64
+get_target_identifier(peidx_table_t *peidx)
+{
+	u64 target_address = 0;
+	sal_log_mod_error_info_t *smei;
+	pal_cache_check_info_t *pcci;
+	int i, level = 9;
+
+	/*
+	 * Look through the cache checks for a valid target identifier
+	 * If more than one valid target identifier, return the one
+	 * with the lowest cache level.
+	 */
+	for (i = 0; i < peidx_cache_check_num(peidx); i++) {
+		smei = (sal_log_mod_error_info_t *)peidx_cache_check(peidx, i);
+		if (smei->valid.target_identifier && smei->target_identifier) {
+			pcci = (pal_cache_check_info_t *)&(smei->check_info);
+			if (!target_address || (pcci->level < level)) {
+				target_address = smei->target_identifier;
+				level = pcci->level;
+				continue;
+			}
+		}
+	}
+	if (target_address)
+		return target_address;
+
+	/*
+	 * Look at the bus check for a valid target identifier
+	 */
+	smei = peidx_bus_check(peidx, 0);
+	if (smei && smei->valid.target_identifier)
+		return smei->target_identifier;
+
+	return 0;
+}
+
+/**
  * recover_from_read_error - Try to recover the errors which type are "read"s.
  * @slidx:	pointer of index of SAL error record
  * @peidx:	pointer of index of processor error section
@@ -450,13 +494,14 @@ recover_from_read_error(slidx_table_t *s
 			peidx_table_t *peidx, pal_bus_check_info_t *pbci,
 			struct ia64_sal_os_state *sos)
 {
-	sal_log_mod_error_info_t *smei;
+	u64 target_identifier;
 	pal_min_state_area_t *pmsa;
 	struct ia64_psr *psr1, *psr2;
 	ia64_fptr_t *mca_hdlr_bh = (ia64_fptr_t*)mca_handler_bhhook;
 
 	/* Is target address valid? */
-	if (!pbci->tv)
+	target_identifier = get_target_identifier(peidx);
+	if (!target_identifier)
 		return fatal_mca("target address not valid");
 
 	/*
@@ -487,32 +532,28 @@ recover_from_read_error(slidx_table_t *s
 	pmsa = sos->pal_min_state;
 	if (psr1->cpl != 0 ||
 	   ((psr2->cpl != 0) && mca_recover_range(pmsa->pmsa_iip))) {
-		smei = peidx_bus_check(peidx, 0);
-		if (smei->valid.target_identifier) {
-			/*
-			 *  setup for resume to bottom half of MCA,
-			 * "mca_handler_bhhook"
-			 */
-			/* pass to bhhook as argument (gr8, ...) */
-			pmsa->pmsa_gr[8-1] = smei->target_identifier;
-			pmsa->pmsa_gr[9-1] = pmsa->pmsa_iip;
-			pmsa->pmsa_gr[10-1] = pmsa->pmsa_ipsr;
-			/* set interrupted return address (but no use) */
-			pmsa->pmsa_br0 = pmsa->pmsa_iip;
-			/* change resume address to bottom half */
-			pmsa->pmsa_iip = mca_hdlr_bh->fp;
-			pmsa->pmsa_gr[1-1] = mca_hdlr_bh->gp;
-			/* set cpl with kernel mode */
-			psr2 = (struct ia64_psr *)&pmsa->pmsa_ipsr;
-			psr2->cpl = 0;
-			psr2->ri  = 0;
-			psr2->bn  = 1;
-			psr2->i  = 0;
-
-			return mca_recovered("user memory corruption. "
+		/*
+		 *  setup for resume to bottom half of MCA,
+		 * "mca_handler_bhhook"
+		 */
+		/* pass to bhhook as argument (gr8, ...) */
+		pmsa->pmsa_gr[8-1] = target_identifier;
+		pmsa->pmsa_gr[9-1] = pmsa->pmsa_iip;
+		pmsa->pmsa_gr[10-1] = pmsa->pmsa_ipsr;
+		/* set interrupted return address (but no use) */
+		pmsa->pmsa_br0 = pmsa->pmsa_iip;
+		/* change resume address to bottom half */
+		pmsa->pmsa_iip = mca_hdlr_bh->fp;
+		pmsa->pmsa_gr[1-1] = mca_hdlr_bh->gp;
+		/* set cpl with kernel mode */
+		psr2 = (struct ia64_psr *)&pmsa->pmsa_ipsr;
+		psr2->cpl = 0;
+		psr2->ri  = 0;
+		psr2->bn  = 1;
+		psr2->i  = 0;
+
+		return mca_recovered("user memory corruption. "
 				"kill affected process - recovered.");
-		}
-
 	}
 
 	return fatal_mca("kernel context not recovered, iip 0x%lx\n",

commit 5ee7737379b1d7f0c977c0f1661fbaf01a8d4721
Author: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date:   Fri Oct 27 19:49:53 2006 +0900

    [IA64] cpu-hotplug: Fixing confliction between CPU hot-add and IPI
    
    Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
    Acked-by: Satoru Takeuchi <takeuchi_satoru@jp.fujitsu.com>
    Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/smp.c b/arch/ia64/kernel/smp.c
index 657ac99..2763e79 100644
--- a/arch/ia64/kernel/smp.c
+++ b/arch/ia64/kernel/smp.c
@@ -328,10 +328,14 @@ int
 smp_call_function (void (*func) (void *info), void *info, int nonatomic, int wait)
 {
 	struct call_data_struct data;
-	int cpus = num_online_cpus()-1;
+	int cpus;
 
-	if (!cpus)
+	spin_lock(&call_lock);
+	cpus = num_online_cpus() - 1;
+	if (!cpus) {
+		spin_unlock(&call_lock);
 		return 0;
+	}
 
 	/* Can deadlock when called with interrupts disabled */
 	WARN_ON(irqs_disabled());
@@ -343,8 +347,6 @@ smp_call_function (void (*func) (void *i
 	if (wait)
 		atomic_set(&data.finished, 0);
 
-	spin_lock(&call_lock);
-
 	call_data = &data;
 	mb();	/* ensure store to call_data precedes setting of IPI_CALL_FUNC */
 	send_IPI_allbutself(IPI_CALL_FUNC);

commit f2454a1a4b2aca38d3b7887619f43291d773c1ee
Author: Jes Sorensen <jes@sgi.com>
Date:   Wed Oct 25 05:49:53 2006 -0400

    [IA64] don't double >> PAGE_SHIFT pointer for /dev/kmem access
    
    Don't PAGE_SHIFT pointer before handing it to virt_to_page() in
    xlate_dev_kmem_ptr() as it results in a double shift.
    
    Spotted by Bob Montgomery.
    
    Signed-off-by: Jes Sorensen <jes@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/include/asm-ia64/uaccess.h b/include/asm-ia64/uaccess.h
index 9adb512..449c8c0 100644
--- a/include/asm-ia64/uaccess.h
+++ b/include/asm-ia64/uaccess.h
@@ -389,7 +389,7 @@ xlate_dev_kmem_ptr (char * p)
 	struct page *page;
 	char * ptr;
 
-	page = virt_to_page((unsigned long)p >> PAGE_SHIFT);
+	page = virt_to_page((unsigned long)p);
 	if (PageUncached(page))
 		ptr = (char *)__pa(p) + __IA64_UNCACHED_OFFSET;
 	else
