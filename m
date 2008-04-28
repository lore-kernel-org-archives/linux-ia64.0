From: Russ Anderson <rja@sgi.com>
Date: Mon, 28 Apr 2008 19:24:57 +0000
Subject: [PATCH 2/2] ia64: Call migration code on correctable errors
Message-Id: <20080428192457.GC14629@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Christoph Lameter <clameter@sgi.com>, Russ Anderson <rja@sgi.com>

Migrate data off pages with correctable memory errors.  This patch is the 
ia64 specific piece.  It connects the CPE handler to the page migration
code.  It is implemented as a kernel loadable module, similar to the mca
recovery code (mca_recovery.ko).  This allows the feature to be turned off
by uninstalling the module.  

It exports three symbols (migrate_prep, isolate_lru_page, and migrate_pages).

Signed-off-by: Russ Anderson <rja@sgi.com>

---
 arch/ia64/Kconfig              |    3 
 arch/ia64/kernel/Makefile      |    1 
 arch/ia64/kernel/cpe_migrate.c |  275 +++++++++++++++++++++++++++++++++++++++++
 arch/ia64/kernel/mca.c         |   34 ++++-
 include/asm-ia64/mca.h         |    3 
 include/asm-ia64/page.h        |    1 
 mm/migrate.c                   |    3 
 7 files changed, 319 insertions(+), 1 deletion(-)

Index: test/arch/ia64/kernel/Makefile
=================================--- test.orig/arch/ia64/kernel/Makefile	2008-04-28 13:27:48.682600987 -0500
+++ test/arch/ia64/kernel/Makefile	2008-04-28 13:27:56.511575718 -0500
@@ -27,6 +27,7 @@ obj-$(CONFIG_PERFMON)		+= perfmon_defaul
 obj-$(CONFIG_IA64_CYCLONE)	+= cyclone.o
 obj-$(CONFIG_CPU_FREQ)		+= cpufreq/
 obj-$(CONFIG_IA64_MCA_RECOVERY)	+= mca_recovery.o
+obj-$(CONFIG_IA64_CPE_MIGRATE)	+= cpe_migrate.o
 obj-$(CONFIG_KPROBES)		+= kprobes.o jprobes.o
 obj-$(CONFIG_KEXEC)		+= machine_kexec.o relocate_kernel.o crash.o
 obj-$(CONFIG_CRASH_DUMP)	+= crash_dump.o
Index: test/arch/ia64/kernel/cpe_migrate.c
=================================--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ test/arch/ia64/kernel/cpe_migrate.c	2008-04-28 13:27:56.523577213 -0500
@@ -0,0 +1,275 @@
+/*
+ * File:	cpe_migrate.c
+ * Purpose:	Migrate data from physical pages with excessive correctable
+ *		errors to new physical pages.  Keep the old pages on a discard
+ *		list.
+ *
+ * Copyright (C) 2008 SGI - Silicon Graphics Inc.
+ * Copyright (C) 2008 Russ Anderson <rja@sgi.com>
+ */
+#include <linux/types.h>
+#include <linux/init.h>
+#include <linux/sched.h>
+#include <linux/interrupt.h>
+#include <linux/irq.h>
+#include <linux/kallsyms.h>
+#include <linux/bootmem.h>
+#include <linux/acpi.h>
+#include <linux/timer.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/smp.h>
+#include <linux/workqueue.h>
+#include <linux/mm.h>
+#include <linux/swap.h>
+#include <linux/delay.h>
+#include <linux/ptrace.h>
+#include <linux/irq.h>
+#include <linux/vmalloc.h>
+#include <linux/migrate.h>
+#include <linux/page-isolation.h>
+#include <linux/rmap.h>
+#include <linux/memcontrol.h>
+
+#include <asm/machvec.h>
+#include <asm/page.h>
+#include <asm/system.h>
+#include <asm/sal.h>
+#include <asm/hw_irq.h>
+#include <asm/sn/sn_cpuid.h>
+#include <asm/mca.h>
+
+#define CE_HISTORY_LENGTH	30
+
+static u64 cpe_paddr[CE_HISTORY_LENGTH];
+static u16 cpe_node[CE_HISTORY_LENGTH];
+static int cpe_polling_enabled = 1;
+static int cpe_head;
+static int cpe_tail;
+
+int work_scheduled;
+spinlock_t cpe_migrate_lock;
+
+void
+get_physical_address(void *buffer, u64 *paddr, u16 *node)
+{
+	sal_log_record_header_t *rh;
+	sal_log_mem_dev_err_info_t *mdei;
+	ia64_err_rec_t *err_rec;
+	sal_log_platform_err_info_t *plat_err;
+	efi_guid_t guid;
+
+	err_rec = (ia64_err_rec_t *)buffer;
+	rh = (sal_log_record_header_t *)&err_rec->sal_elog_header;
+	*paddr = 0;
+	*node = 0;
+
+	/*
+	 * Make sure it is a corrected error.
+	 */
+	if (rh->severity != sal_log_severity_corrected)
+		return;
+
+	plat_err = (sal_log_platform_err_info_t *)&err_rec->proc_err;
+
+	guid = (efi_guid_t)plat_err->mem_dev_err.header.guid;
+	if (efi_guidcmp(guid, SAL_PLAT_MEM_DEV_ERR_SECT_GUID) = 0) {
+		/*
+		 * Memory cpe
+		 */
+		mdei = (sal_log_mem_dev_err_info_t *)&plat_err->mem_dev_err;
+		if (mdei->valid.oem_data) {
+			if (mdei->valid.physical_addr)
+				*paddr = mdei->physical_addr;
+
+			if (mdei->valid.node) {
+				if (ia64_platform_is("sn2"))
+					*node = nasid_to_cnodeid(mdei->node);
+				else
+					*node = mdei->node;
+			}
+			return;
+		}
+	}
+	return;
+}
+
+struct page *
+alloc_migrate_page(struct page *ignored, unsigned long node, int **x)
+{
+
+	return alloc_pages_node(node, GFP_HIGHUSER_MOVABLE, 0);
+}
+
+static int
+ia64_mca_cpe_move_page(u64 paddr, u32 node)
+{
+	LIST_HEAD(pagelist);
+	struct page *page;
+	int ret;
+	unsigned long irq_flags;
+	extern struct list_head badpagelist;
+
+	local_irq_save(irq_flags);
+	/*
+	 * Validate page
+	 */
+	if (!paddr)
+		return -1;
+	if (!ia64_phys_addr_valid(paddr))
+		return -1;
+	if (!pfn_valid(paddr >> PAGE_SHIFT))
+		return -1;
+
+	/*
+	 * convert physical address to page number
+	 */
+	page = phys_to_page(paddr);
+
+	if (!spin_trylock(&cpe_migrate_lock)) {
+		local_irq_restore(irq_flags);
+		return -1;
+	}
+
+	preempt_disable();
+	migrate_prep();
+	ret = isolate_lru_page(page, &pagelist);
+	preempt_enable();
+	if (ret) {
+		spin_unlock_irqrestore(&cpe_migrate_lock, irq_flags);
+		return ret;
+	}
+
+	SetPageMemError(page);		/* Mark the page as bad */
+	ret = migrate_pages(&pagelist, alloc_migrate_page, node);
+	if (ret = 0)
+		list_add_tail(&page->lru, &badpagelist);
+
+	spin_unlock_irqrestore(&cpe_migrate_lock, irq_flags);
+	return 0;
+}
+
+/*
+ * ia64_mca_cpe_migrate
+ *	The worker that does the actual migration.  It pulls a
+ *	physical address off the list and calls the migration code.
+ *
+ *  Inputs
+ *	none
+ *  Outputs
+ *	none
+ */
+static void
+ia64_mca_cpe_migrate(struct work_struct *unused)
+{
+	int ret;
+	u64 paddr;
+	u16 node;
+
+	do {
+		if (cpe_paddr[cpe_tail]) {
+			paddr = cpe_paddr[cpe_tail];
+			node = cpe_node[cpe_tail];
+
+			ret = ia64_mca_cpe_move_page(paddr, node);
+			if (ret <= 0)
+				/*
+				 * Even though the return status is negative,
+				 * clear the entry.  If the same address has
+				 * another CPE it will be re-added to the list.
+				 */
+				cpe_paddr[cpe_tail] = 0;
+
+		}
+		if (++cpe_tail >= CE_HISTORY_LENGTH)
+			cpe_tail = 0;
+
+	} while (cpe_tail != cpe_head);
+	work_scheduled = 0;
+}
+static DECLARE_WORK(cpe_enable_work, ia64_mca_cpe_migrate);
+
+/*
+ * ce_setup_migrate
+ *	Get the physical address out of the CPE record, add it
+ *	to the list of addresses to migrate (if not already on),
+ *	and schedule the back end worker task.  This is called
+ *	in interrupt context so cannot directly call the migration
+ *	code.
+ *
+ *  Inputs
+ *	rec	The CPE record
+ *  Outputs
+ *	1 on Success, -1 on failure
+ */
+static int
+ce_setup_migrate(void *rec)
+{
+	u64 paddr;
+	u16 node;
+	/* int head, tail; */
+	int i;
+
+	if (!rec)
+		return -1;
+
+	get_physical_address(rec, &paddr, &node);
+	if (!paddr)
+		return -1;
+
+	if (!((cpe_head = cpe_tail) && (cpe_paddr[cpe_head] = 0)))
+		/*
+		 * List not empty
+		 */
+		for (i = 0; i < CE_HISTORY_LENGTH; i++)
+			if ((PAGE_ALIGN(cpe_paddr[i])) = PAGE_ALIGN(paddr))
+				return 1;	/* already on the list */
+
+	if (cpe_paddr[cpe_head] = 0) {
+		cpe_paddr[cpe_head] = paddr;
+		cpe_node[cpe_head] = node;
+
+		if (++cpe_head >= CE_HISTORY_LENGTH)
+			cpe_head = 0;
+	}
+
+	if (!work_scheduled) {
+		work_scheduled = 1;
+		schedule_work(&cpe_enable_work);
+	}
+
+	return 1;
+}
+
+/*
+ * ======================================+ */
+
+int __init cpe_migrate_external_handler_init(void)
+{
+	spin_lock_init(&cpe_migrate_lock);
+
+	/* register external ce handler */
+	if (ia64_reg_CE_extension(ce_setup_migrate)) {
+		printk(KERN_ERR "ia64_reg_CE_extension failed.\n");
+		return -EFAULT;
+	}
+	cpe_poll_enabled = cpe_polling_enabled;
+	return 0;
+}
+
+void __exit cpe_migrate_external_handler_exit(void)
+{
+	/* unregister external mca handlers */
+	ia64_unreg_CE_extension();
+}
+
+module_init(cpe_migrate_external_handler_init);
+module_exit(cpe_migrate_external_handler_exit);
+
+module_param(cpe_polling_enabled, int, 0644);
+MODULE_PARM_DESC(cpe_polling_enabled,
+		"Enable polling with migration");
+
+MODULE_DESCRIPTION("ia64 Corrected Error page migration driver");
+MODULE_LICENSE("GPL");
Index: test/arch/ia64/kernel/mca.c
=================================--- test.orig/arch/ia64/kernel/mca.c	2008-04-28 13:27:48.682600987 -0500
+++ test/arch/ia64/kernel/mca.c	2008-04-28 13:27:56.543579703 -0500
@@ -68,6 +68,9 @@
  *
  * 2007-04-27 Russ Anderson <rja@sgi.com>
  *	      Support multiple cpus going through OS_MCA in the same event.
+ *
+ * 2008-04-22 Russ Anderson <rja@sgi.com>
+ *	      Migrate data off pages with correctable memory errors.
  */
 #include <linux/jiffies.h>
 #include <linux/types.h>
@@ -163,7 +166,11 @@ static int cmc_polling_enabled = 1;
  * but encounters problems retrieving CPE logs.  This should only be
  * necessary for debugging.
  */
-static int cpe_poll_enabled = 1;
+int cpe_poll_enabled = 1;
+EXPORT_SYMBOL(cpe_poll_enabled);
+
+LIST_HEAD(badpagelist);
+EXPORT_SYMBOL(badpagelist);
 
 extern void salinfo_log_wakeup(int type, u8 *buffer, u64 size, int irqsafe);
 
@@ -525,6 +532,28 @@ EXPORT_SYMBOL_GPL(mca_recover_range);
 
 #ifdef CONFIG_ACPI
 
+/* Function pointer to Corrected Error memory migration driver */
+int (*ia64_mca_ce_extension)(void *) = NULL;
+
+int
+ia64_reg_CE_extension(int (*fn)(void *))
+{
+	if (ia64_mca_ce_extension)
+		return 1;
+
+	ia64_mca_ce_extension = fn;
+	return 0;
+}
+EXPORT_SYMBOL(ia64_reg_CE_extension);
+
+void
+ia64_unreg_CE_extension(void)
+{
+	if (ia64_mca_ce_extension)
+		ia64_mca_ce_extension = NULL;
+}
+EXPORT_SYMBOL(ia64_unreg_CE_extension);
+
 int cpe_vector = -1;
 int ia64_cpe_irq = -1;
 
@@ -534,6 +563,7 @@ ia64_mca_cpe_int_handler (int cpe_irq, v
 	static unsigned long	cpe_history[CPE_HISTORY_LENGTH];
 	static int		index;
 	static DEFINE_SPINLOCK(cpe_history_lock);
+	int recover;
 
 	IA64_MCA_DEBUG("%s: received interrupt vector = %#x on CPU %d\n",
 		       __func__, cpe_irq, smp_processor_id());
@@ -580,6 +610,8 @@ ia64_mca_cpe_int_handler (int cpe_irq, v
 out:
 	/* Get the CPE error record and log it */
 	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_CPE);
+	recover = (ia64_mca_ce_extension && ia64_mca_ce_extension(
+				IA64_LOG_CURR_BUFFER(SAL_INFO_TYPE_CPE)));
 
 	return IRQ_HANDLED;
 }
Index: test/arch/ia64/Kconfig
=================================--- test.orig/arch/ia64/Kconfig	2008-04-28 13:27:48.682600987 -0500
+++ test/arch/ia64/Kconfig	2008-04-28 13:27:56.575583688 -0500
@@ -451,6 +451,9 @@ config COMPAT_FOR_U64_ALIGNMENT
 config IA64_MCA_RECOVERY
 	tristate "MCA recovery from errors other than TLB."
 
+config IA64_CPE_MIGRATE
+	tristate "Migrate data off pages with correctable errors"
+
 config PERFMON
 	bool "Performance monitor support"
 	help
Index: test/include/asm-ia64/mca.h
=================================--- test.orig/include/asm-ia64/mca.h	2008-04-28 13:27:48.682600987 -0500
+++ test/include/asm-ia64/mca.h	2008-04-28 13:27:56.591585680 -0500
@@ -137,6 +137,7 @@ extern unsigned long __per_cpu_mca[NR_CP
 
 extern int cpe_vector;
 extern int ia64_cpe_irq;
+extern int cpe_poll_enabled;
 extern void ia64_mca_init(void);
 extern void ia64_mca_cpu_init(void *);
 extern void ia64_os_mca_dispatch(void);
@@ -150,6 +151,8 @@ extern void ia64_slave_init_handler(void
 extern void ia64_mca_cmc_vector_setup(void);
 extern int  ia64_reg_MCA_extension(int (*fn)(void *, struct ia64_sal_os_state *));
 extern void ia64_unreg_MCA_extension(void);
+extern int  ia64_reg_CE_extension(int (*fn)(void *));
+extern void ia64_unreg_CE_extension(void);
 extern u64 ia64_get_rnat(u64 *);
 extern void ia64_mca_printk(const char * fmt, ...)
 	 __attribute__ ((format (printf, 1, 2)));
Index: test/mm/migrate.c
=================================--- test.orig/mm/migrate.c	2008-04-28 13:27:48.686601486 -0500
+++ test/mm/migrate.c	2008-04-28 13:27:56.615588668 -0500
@@ -64,6 +64,7 @@ int isolate_lru_page(struct page *page, 
 	}
 	return ret;
 }
+EXPORT_SYMBOL(isolate_lru_page);
 
 /*
  * migrate_prep() needs to be called before we start compiling a list of pages
@@ -81,6 +82,7 @@ int migrate_prep(void)
 
 	return 0;
 }
+EXPORT_SYMBOL(migrate_prep);
 
 static inline void move_to_lru(struct page *page)
 {
@@ -798,6 +800,7 @@ out:
 
 	return nr_failed + retry;
 }
+EXPORT_SYMBOL(migrate_pages);
 
 #ifdef CONFIG_NUMA
 /*
Index: test/include/asm-ia64/page.h
=================================--- test.orig/include/asm-ia64/page.h	2008-04-28 13:27:48.682600987 -0500
+++ test/include/asm-ia64/page.h	2008-04-28 13:27:56.639591657 -0500
@@ -125,6 +125,7 @@ extern unsigned long max_low_pfn;
 #endif
 
 #define page_to_phys(page)	(page_to_pfn(page) << PAGE_SHIFT)
+#define	phys_to_page(kaddr)	(pfn_to_page(kaddr >> PAGE_SHIFT))
 #define virt_to_page(kaddr)	pfn_to_page(__pa(kaddr) >> PAGE_SHIFT)
 #define pfn_to_kaddr(pfn)	__va((pfn) << PAGE_SHIFT)
 
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
