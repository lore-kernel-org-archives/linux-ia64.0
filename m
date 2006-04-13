From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 13 Apr 2006 23:01:41 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200604132301.k3DN1fLP016815@agluck-lia64.sc.intel.com>
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

 arch/ia64/kernel/mca.c   |   10 +++----
 arch/ia64/mm/discontig.c |   66 ++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 70 insertions(+), 6 deletions(-)

Keith Owens:
      [IA64] ia64_wait_for_slaves() incorrectly reports MCA

Robin Holt:
      [IA64] Make show_mem() skip holes in a pgdat

diff-tree ace1d816a13ff42d4f41989862552032f9c19853 (from 356a5c1c6fdfb8eed6dbb3979d90c7cc7060017a)
Author: Robin Holt <holt@sgi.com>
Date:   Thu Apr 13 15:34:45 2006 -0700

    [IA64] Make show_mem() skip holes in a pgdat
    
    This patch modifies ia64's show_mem() to walk the vmem_map page tables and
    rapidly skip forward across regions where the page tables are missing.
    This prevents the pfn_valid() check from causing numerous unnecessary
    page faults.
    
    Without this patch on a 512 node 512 cpu system where every node has four
    memory holes, the show_mem() call takes 1 hour 18 minutes.  With this
    patch, it takes less than 3 seconds.
    
    Signed-off-by: Robin Holt <holt@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
index ec9eeb8..b6bcc9f 100644
--- a/arch/ia64/mm/discontig.c
+++ b/arch/ia64/mm/discontig.c
@@ -519,6 +519,68 @@ void __cpuinit *per_cpu_init(void)
 }
 #endif /* CONFIG_SMP */
 
+#ifdef CONFIG_VIRTUAL_MEM_MAP
+static inline int find_next_valid_pfn_for_pgdat(pg_data_t *pgdat, int i)
+{
+	unsigned long end_address, hole_next_pfn;
+	unsigned long stop_address;
+
+	end_address = (unsigned long) &vmem_map[pgdat->node_start_pfn + i];
+	end_address = PAGE_ALIGN(end_address);
+
+	stop_address = (unsigned long) &vmem_map[
+		pgdat->node_start_pfn + pgdat->node_spanned_pages];
+
+	do {
+		pgd_t *pgd;
+		pud_t *pud;
+		pmd_t *pmd;
+		pte_t *pte;
+
+		pgd = pgd_offset_k(end_address);
+		if (pgd_none(*pgd)) {
+			end_address += PGDIR_SIZE;
+			continue;
+		}
+
+		pud = pud_offset(pgd, end_address);
+		if (pud_none(*pud)) {
+			end_address += PUD_SIZE;
+			continue;
+		}
+
+		pmd = pmd_offset(pud, end_address);
+		if (pmd_none(*pmd)) {
+			end_address += PMD_SIZE;
+			continue;
+		}
+
+		pte = pte_offset_kernel(pmd, end_address);
+retry_pte:
+		if (pte_none(*pte)) {
+			end_address += PAGE_SIZE;
+			pte++;
+			if ((end_address < stop_address) &&
+			    (end_address != ALIGN(end_address, 1UL << PMD_SHIFT)))
+				goto retry_pte;
+			continue;
+		}
+		/* Found next valid vmem_map page */
+		break;
+	} while (end_address < stop_address);
+
+	end_address = min(end_address, stop_address);
+	end_address = end_address - (unsigned long) vmem_map + sizeof(struct page) - 1;
+	hole_next_pfn = end_address / sizeof(struct page);
+	return hole_next_pfn - pgdat->node_start_pfn;
+}
+#else
+static inline int find_next_valid_pfn_for_pgdat(pg_data_t *pgdat, int i)
+{
+	return i + 1;
+}
+#endif
+
 /**
  * show_mem - give short summary of memory stats
  *
@@ -547,8 +609,10 @@ void show_mem(void)
 			struct page *page;
 			if (pfn_valid(pgdat->node_start_pfn + i))
 				page = pfn_to_page(pgdat->node_start_pfn + i);
-			else
+			else {
+				i = find_next_valid_pfn_for_pgdat(pgdat, i) - 1;
 				continue;
+			}
 			if (PageReserved(page))
 				reserved++;
 			else if (PageSwapCache(page))

diff-tree 356a5c1c6fdfb8eed6dbb3979d90c7cc7060017a (from 907d91d708d9999bec0185d630062576ac4181a7)
Author: Keith Owens <kaos@sgi.com>
Date:   Tue Apr 11 14:59:41 2006 +1000

    [IA64] ia64_wait_for_slaves() incorrectly reports MCA
    
    ia64_wait_for_slaves() was changed in 2.6.17-rc1 to report the slave
    state.  It incorrectly assumes that all slaves are for MCA, but
    ia64_wait_for_slaves() is also called from the INIT monarch handler.
    The existing message is very misleading, so correct it.
    
    Signed-off-by: Keith Owens <kaos@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index 5e6fdbe..6a08806 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -963,7 +963,7 @@ no_mod:
  */
 
 static void
-ia64_wait_for_slaves(int monarch)
+ia64_wait_for_slaves(int monarch, const char *type)
 {
 	int c, wait = 0, missing = 0;
 	for_each_online_cpu(c) {
@@ -989,7 +989,7 @@ ia64_wait_for_slaves(int monarch)
 	}
 	if (!missing)
 		goto all_in;
-	printk(KERN_INFO "OS MCA slave did not rendezvous on cpu");
+	printk(KERN_INFO "OS %s slave did not rendezvous on cpu", type);
 	for_each_online_cpu(c) {
 		if (c = monarch)
 			continue;
@@ -1000,7 +1000,7 @@ ia64_wait_for_slaves(int monarch)
 	return;
 
 all_in:
-	printk(KERN_INFO "All OS MCA slaves have reached rendezvous\n");
+	printk(KERN_INFO "All OS %s slaves have reached rendezvous\n", type);
 	return;
 }
 
@@ -1038,7 +1038,7 @@ ia64_mca_handler(struct pt_regs *regs, s
 	if (notify_die(DIE_MCA_MONARCH_ENTER, "MCA", regs, (long)&nd, 0, 0)
 			= NOTIFY_STOP)
 		ia64_mca_spin(__FUNCTION__);
-	ia64_wait_for_slaves(cpu);
+	ia64_wait_for_slaves(cpu, "MCA");
 
 	/* Wakeup all the processors which are spinning in the rendezvous loop.
 	 * They will leave SAL, then spin in the OS with interrupts disabled
@@ -1429,7 +1429,7 @@ ia64_init_handler(struct pt_regs *regs, 
 	 */
 	printk("Delaying for 5 seconds...\n");
 	udelay(5*1000000);
-	ia64_wait_for_slaves(cpu);
+	ia64_wait_for_slaves(cpu, "INIT");
 	/* If nobody intercepts DIE_INIT_MONARCH_PROCESS then we drop through
 	 * to default_monarch_init_process() above and just print all the
 	 * tasks.
