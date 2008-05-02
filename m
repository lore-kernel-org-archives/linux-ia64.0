From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Date: Fri, 02 May 2008 09:58:12 +0000
Subject: Re: [PATCH 3/3] ia64: Call migration code on correctable errors v2
Message-Id: <84144f020805020258x56d4f915u5d826d8f19294d62@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080502004425.GD12006@sgi.com>
In-Reply-To: <20080502004425.GD12006@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russ Anderson <rja@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Christoph Lameter <clameter@sgi.com>

Hi Russ,

On Fri, May 2, 2008 at 3:44 AM, Russ Anderson <rja@sgi.com> wrote:
> Migrate data off pages with correctable memory errors.  This patch is the
>  ia64 specific piece.  It connects the CPE handler to the page migration
>  code.  It is implemented as a kernel loadable module, similar to the mca
>  recovery code (mca_recovery.ko).  This allows the feature to be turned off
>  by uninstalling the module.  Creates /proc/badram to display bad page
>  information and free bad pages.
>
>  Signed-off-by: Russ Anderson <rja@sgi.com>

I think sparse and checkpatch would have caught most of these but here goes:

>  +int work_scheduled;
>  +spinlock_t cpe_migrate_lock;

static?

>  +void
>  +get_physical_address(void *buffer, u64 *paddr, u16 *node)
>  +{

static?

>  +       sal_log_record_header_t *rh;
>  +       sal_log_mem_dev_err_info_t *mdei;
>  +       ia64_err_rec_t *err_rec;
>  +       sal_log_platform_err_info_t *plat_err;
>  +       efi_guid_t guid;
>  +
>  +       err_rec = (ia64_err_rec_t *)buffer;

Unnecessary cast from void *.

>  +       rh = (sal_log_record_header_t *)&err_rec->sal_elog_header;
>  +       *paddr = 0;
>  +       *node = 0;
>  +
>  +       /*
>  +        * Make sure it is a corrected error.
>  +        */
>  +       if (rh->severity != sal_log_severity_corrected)
>  +               return;
>  +
>  +       plat_err = (sal_log_platform_err_info_t *)&err_rec->proc_err;
>  +
>  +       guid = (efi_guid_t)plat_err->mem_dev_err.header.guid;
>  +       if (efi_guidcmp(guid, SAL_PLAT_MEM_DEV_ERR_SECT_GUID) = 0) {
>  +               /*
>  +                * Memory cpe
>  +                */
>  +               mdei = (sal_log_mem_dev_err_info_t *)&plat_err->mem_dev_err;
>  +               if (mdei->valid.oem_data) {
>  +                       if (mdei->valid.physical_addr)
>  +                               *paddr = mdei->physical_addr;
>  +
>  +                       if (mdei->valid.node) {
>  +                               if (ia64_platform_is("sn2"))
>  +                                       *node = nasid_to_cnodeid(mdei->node);
>  +                               else
>  +                                       *node = mdei->node;
>  +                       }
>  +                       return;

Unnecessary return statement.

>  +               }
>  +       }
>  +       return;

And here.

>  +}
>  +
>  +struct page *
>  +alloc_migrate_page(struct page *ignored, unsigned long node, int **x)

static

>  +{
>  +
>  +       return alloc_pages_node(node, GFP_HIGHUSER_MOVABLE, 0);
>  +}
>  +
>  +static int
>  +ia64_mca_cpe_move_page(u64 paddr, u32 node)
>  +{
>  +       LIST_HEAD(pagelist);
>  +       struct page *page;
>  +       int ret;
>  +       unsigned long irq_flags;
>  +
>  +       local_irq_save(irq_flags);
>  +       /*
>  +        * Validate page
>  +        */
>  +       if (!paddr)
>  +               return -1;

-EINVAL ?

>  +       if (!ia64_phys_addr_valid(paddr))
>  +               return -1;

and here

>  +       if (!pfn_valid(paddr >> PAGE_SHIFT))
>  +               return -1;

ditto

>  +
>  +       /*
>  +        * convert physical address to page number
>  +        */
>  +       page = phys_to_page(paddr);
>  +
>  +       if (!spin_trylock(&cpe_migrate_lock)) {
>  +               local_irq_restore(irq_flags);
>  +               return -1;

-EBUSY?

>  +       }
>  +
>  +       preempt_disable();

Why do we need to disable preempt here?

>  +       migrate_prep();
>  +       ret = isolate_lru_page(page, &pagelist);
>  +       preempt_enable();
>  +       if (ret) {
>  +               spin_unlock_irqrestore(&cpe_migrate_lock, irq_flags);
>  +               return ret;

goto would make the error handling cleaner here

>  +       }
>  +
>  +       SetPageMemError(page);          /* Mark the page as bad */
>  +       ret = migrate_pages(&pagelist, alloc_migrate_page, node);
>  +       if (ret = 0)
>  +               list_add_tail(&page->lru, &badpagelist);
>  +
>  +       spin_unlock_irqrestore(&cpe_migrate_lock, irq_flags);
>  +       return 0;
>  +}
>  +
>  +/*
>  + * ia64_mca_cpe_migrate
>  + *     The worker that does the actual migration.  It pulls a
>  + *     physical address off the list and calls the migration code.
>  + *
>  + *  Inputs
>  + *     none
>  + *  Outputs
>  + *     none
>  + */

kerneldoc?

>  +static void
>  +ia64_mca_cpe_migrate(struct work_struct *unused)
>  +{
>  +       int ret;
>  +       u64 paddr;
>  +       u16 node;
>  +
>  +       do {
>  +               if (cpe_paddr[cpe_tail]) {
>  +                       paddr = cpe_paddr[cpe_tail];
>  +                       node = cpe_node[cpe_tail];
>  +
>  +                       ret = ia64_mca_cpe_move_page(paddr, node);
>  +                       if (ret <= 0)
>  +                               /*
>  +                                * Even though the return status is negative,
>  +                                * clear the entry.  If the same address has
>  +                                * another CPE it will be re-added to the list.
>  +                                */
>  +                               cpe_paddr[cpe_tail] = 0;
>  +
>  +               }
>  +               if (++cpe_tail >= CE_HISTORY_LENGTH)
>  +                       cpe_tail = 0;
>  +
>  +       } while (cpe_tail != cpe_head);
>  +       work_scheduled = 0;
>  +}
>  +static DECLARE_WORK(cpe_enable_work, ia64_mca_cpe_migrate);
>  +
>  +/*
>  + * ce_setup_migrate
>  + *     Get the physical address out of the CPE record, add it
>  + *     to the list of addresses to migrate (if not already on),
>  + *     and schedule the back end worker task.  This is called
>  + *     in interrupt context so cannot directly call the migration
>  + *     code.
>  + *
>  + *  Inputs
>  + *     rec     The CPE record
>  + *  Outputs
>  + *     1 on Success, -1 on failure
>  + */
>  +static int
>  +ce_setup_migrate(void *rec)
>  +{
>  +       u64 paddr;
>  +       u16 node;
>  +       /* int head, tail; */
>  +       int i;
>  +
>  +       if (!rec)
>  +               return -1;

-EINVAL?

>  +
>  +       get_physical_address(rec, &paddr, &node);
>  +       if (!paddr)
>  +               return -1;

and here

>  +
>  +       if (!((cpe_head = cpe_tail) && (cpe_paddr[cpe_head] = 0)))
>  +               /*
>  +                * List not empty
>  +                */
>  +               for (i = 0; i < CE_HISTORY_LENGTH; i++)
>  +                       if ((PAGE_ALIGN(cpe_paddr[i])) = PAGE_ALIGN(paddr))
>  +                               return 1;       /* already on the list */
>  +
>  +       if (cpe_paddr[cpe_head] = 0) {
>  +               cpe_paddr[cpe_head] = paddr;
>  +               cpe_node[cpe_head] = node;
>  +
>  +               if (++cpe_head >= CE_HISTORY_LENGTH)
>  +                       cpe_head = 0;
>  +       }
>  +
>  +       if (!work_scheduled) {
>  +               work_scheduled = 1;
>  +               schedule_work(&cpe_enable_work);

So you must not schedule cpe_enable_work if it's already in progress. Why?

>  +       }
>  +
>  +       return 1;
>  +}
>  +
>  +/*
>  + * ======================================>  + */
>  +
>  +int
>  +freeOneBadPage(unsigned long paddr)

naming and static

>  +{
>  +       struct page *page, *page2, *target;
>  +
>  +       /*
>  +        * Verify page address
>  +        */
>  +       target = phys_to_page(paddr);
>  +       list_for_each_entry_safe(page, page2, &badpagelist, lru) {
>  +               if (page != target)
>  +                       continue;
>  +
>  +               ClearPageMemError(page);        /* Mark the page as good */
>  +               move_to_lru(page);
>  +               list_del(&page->lru);
>  +               totalbad_pages--;
>  +               break;
>  +       }
>  +       return 0;
>  +}
>  +
>  +int
>  +freeAllBadPages(void)

here as well

>  +{
>  +       struct page *page, *page2;
>  +
>  +       list_for_each_entry_safe(page, page2, &badpagelist, lru) {
>  +               ClearPageMemError(page);        /* Mark the page as good */
>  +               totalbad_pages--;
>  +       }
>  +       putback_lru_pages(&badpagelist);
>  +       return 0;
>  +}
>  +
>  +#define OPT_LEN        16
>  +
>  +static ssize_t
>  +padpage_write(struct file *file, const char __user *user,
>  +               size_t count, loff_t *data)
>  +{
>  +       char optstr[OPT_LEN];
>  +       unsigned long opt;
>  +       int len = OPT_LEN;
>  +
>  +       if (count < len)
>  +               len = count;
>  +
>  +       if (copy_from_user(optstr, user, len))
>  +               return -EFAULT;
>  +       optstr[len] = '\0';
>  +
>  +       opt = simple_strtoul(optstr, NULL, 0);
>  +       if (opt = 0)
>  +               freeAllBadPages();
>  +       else
>  +               freeOneBadPage(opt);
>  +
>  +       return count;
>  +}
>  +
>  +int
>  +badpage_show(struct seq_file *file, void *data)
>  +{
>  +       struct page *page, *page2;
>  +       int i = 0;
>  +
>  +       seq_printf(file, "Bad RAM: %d kB, %d pages marked bad\n"
>  +                       "List of bad physical pages\n",
>  +                       totalbad_pages << (PAGE_SHIFT - 10), totalbad_pages);
>  +       list_for_each_entry_safe(page, page2, &badpagelist, lru) {
>  +               seq_printf(file, "  0x%011lx", page_to_phys(page));
>  +               if (!(++i % 5))
>  +                       seq_printf(file, "\n");
>  +       }
>  +       seq_printf(file, "\n");
>  +       return 0;
>  +}
>  +
>  +int
>  +badpage_open(struct inode *inode, struct file *file)
>  +{
>  +       return single_open(file, badpage_show, NULL);
>  +}
>  +
>  +static struct file_operations proc_badpage_operations = {
>  +       .open = badpage_open,
>  +       .write = padpage_write,
>  +       .read = seq_read,
>  +       .llseek = seq_lseek,
>  +       .release = seq_release,
>  +};
>  +
>  +static struct proc_dir_entry *proc_badpage;
>  +
>  +int __init cpe_migrate_external_handler_init(void)
>  +{
>  +       spin_lock_init(&cpe_migrate_lock);
>  +
>  +       /* register external ce handler */
>  +       if (ia64_reg_CE_extension(ce_setup_migrate)) {
>  +               printk(KERN_ERR "ia64_reg_CE_extension failed.\n");
>  +               return -EFAULT;
>  +       }
>  +       cpe_poll_enabled = cpe_polling_enabled;
>  +
>  +       proc_badpage = create_proc_entry(BADRAM_BASENAME, 0644, NULL);

Why is this file not in sysfs?

>  +       if (proc_badpage = NULL) {
>  +               printk(KERN_ERR "unable to create %s proc entry",
>  +                               BADRAM_BASENAME);
>  +               return -EINVAL;
>  +       }
>  +       proc_badpage->proc_fops = &proc_badpage_operations;
>  +       printk(KERN_INFO "Registered badram Driver\n");
>  +       return 0;
>  +}
>  +
>  +void __exit cpe_migrate_external_handler_exit(void)
>  +{
>  +       /* unregister external mca handlers */
>  +       ia64_unreg_CE_extension();
>  +       remove_proc_entry(BADRAM_BASENAME, NULL);
>  +}
>  +
>  +module_init(cpe_migrate_external_handler_init);
>  +module_exit(cpe_migrate_external_handler_exit);
>  +
>  +module_param(cpe_polling_enabled, int, 0644);
>  +MODULE_PARM_DESC(cpe_polling_enabled,
>  +               "Enable polling with migration");
>  +
>  +MODULE_AUTHOR("Russ Anderson <rja@sgi.com>");
>  +MODULE_DESCRIPTION("ia64 Corrected Error page migration driver");
>  +MODULE_LICENSE("GPL");
>  Index: linus/arch/ia64/kernel/mca.c
>  =================================>  --- linus.orig/arch/ia64/kernel/mca.c   2008-05-01 19:36:40.000000000 -0500
>  +++ linus/arch/ia64/kernel/mca.c        2008-05-01 19:36:49.000000000 -0500
>  @@ -68,6 +68,9 @@
>   *
>   * 2007-04-27 Russ Anderson <rja@sgi.com>
>   *           Support multiple cpus going through OS_MCA in the same event.
>  + *
>  + * 2008-04-22 Russ Anderson <rja@sgi.com>
>  + *           Migrate data off pages with correctable memory errors.
>   */
>   #include <linux/jiffies.h>
>   #include <linux/types.h>
>  @@ -163,7 +166,11 @@ static int cmc_polling_enabled = 1;
>   * but encounters problems retrieving CPE logs.  This should only be
>   * necessary for debugging.
>   */
>  -static int cpe_poll_enabled = 1;
>  +int cpe_poll_enabled = 1;
>  +EXPORT_SYMBOL(cpe_poll_enabled);
>  +
>  +LIST_HEAD(badpagelist);
>  +EXPORT_SYMBOL(badpagelist);
>
>   extern void salinfo_log_wakeup(int type, u8 *buffer, u64 size, int irqsafe);
>
>  @@ -525,6 +532,28 @@ EXPORT_SYMBOL_GPL(mca_recover_range);
>
>   #ifdef CONFIG_ACPI
>
>  +/* Function pointer to Corrected Error memory migration driver */
>  +int (*ia64_mca_ce_extension)(void *) = NULL;
>  +
>  +int
>  +ia64_reg_CE_extension(int (*fn)(void *))
>  +{
>  +       if (ia64_mca_ce_extension)
>  +               return 1;
>  +
>  +       ia64_mca_ce_extension = fn;
>  +       return 0;
>  +}
>  +EXPORT_SYMBOL(ia64_reg_CE_extension);
>  +
>  +void
>  +ia64_unreg_CE_extension(void)
>  +{
>  +       if (ia64_mca_ce_extension)
>  +               ia64_mca_ce_extension = NULL;
>  +}
>  +EXPORT_SYMBOL(ia64_unreg_CE_extension);
>  +
>   int cpe_vector = -1;
>   int ia64_cpe_irq = -1;
>
>  @@ -534,6 +563,7 @@ ia64_mca_cpe_int_handler (int cpe_irq, v
>         static unsigned long    cpe_history[CPE_HISTORY_LENGTH];
>         static int              index;
>         static DEFINE_SPINLOCK(cpe_history_lock);
>  +       int recover;
>
>         IA64_MCA_DEBUG("%s: received interrupt vector = %#x on CPU %d\n",
>                        __func__, cpe_irq, smp_processor_id());
>  @@ -580,6 +610,8 @@ ia64_mca_cpe_int_handler (int cpe_irq, v
>   out:
>         /* Get the CPE error record and log it */
>         ia64_mca_log_sal_error_record(SAL_INFO_TYPE_CPE);
>  +       recover = (ia64_mca_ce_extension && ia64_mca_ce_extension(
>  +                               IA64_LOG_CURR_BUFFER(SAL_INFO_TYPE_CPE)));
>
>         return IRQ_HANDLED;
>   }
>  Index: linus/arch/ia64/Kconfig
>  =================================>  --- linus.orig/arch/ia64/Kconfig        2008-05-01 19:36:40.000000000 -0500
>  +++ linus/arch/ia64/Kconfig     2008-05-01 19:36:49.000000000 -0500
>  @@ -456,6 +456,9 @@ config COMPAT_FOR_U64_ALIGNMENT
>   config IA64_MCA_RECOVERY
>         tristate "MCA recovery from errors other than TLB."
>
>  +config IA64_CPE_MIGRATE
>  +       tristate "Migrate data off pages with correctable errors"
>  +
>   config PERFMON
>         bool "Performance monitor support"
>         help
>  Index: linus/include/asm-ia64/mca.h
>  =================================>  --- linus.orig/include/asm-ia64/mca.h   2008-05-01 19:36:40.000000000 -0500
>  +++ linus/include/asm-ia64/mca.h        2008-05-01 19:36:49.000000000 -0500
>  @@ -137,6 +137,7 @@ extern unsigned long __per_cpu_mca[NR_CP
>
>   extern int cpe_vector;
>   extern int ia64_cpe_irq;
>  +extern int cpe_poll_enabled;
>   extern void ia64_mca_init(void);
>   extern void ia64_mca_cpu_init(void *);
>   extern void ia64_os_mca_dispatch(void);
>  @@ -150,9 +151,13 @@ extern void ia64_slave_init_handler(void
>   extern void ia64_mca_cmc_vector_setup(void);
>   extern int  ia64_reg_MCA_extension(int (*fn)(void *, struct ia64_sal_os_state *));
>   extern void ia64_unreg_MCA_extension(void);
>  +extern int  ia64_reg_CE_extension(int (*fn)(void *));
>  +extern void ia64_unreg_CE_extension(void);
>   extern u64 ia64_get_rnat(u64 *);
>   extern void ia64_mca_printk(const char * fmt, ...)
>          __attribute__ ((format (printf, 1, 2)));
>  +
>  +extern struct list_head badpagelist;
>
>   struct ia64_mca_notify_die {
>         struct ia64_sal_os_state *sos;
>  Index: linus/mm/migrate.c
>  =================================>  --- linus.orig/mm/migrate.c     2008-05-01 19:36:40.000000000 -0500
>  +++ linus/mm/migrate.c  2008-05-01 19:36:49.000000000 -0500
>  @@ -64,6 +64,7 @@ int isolate_lru_page(struct page *page,
>         }
>         return ret;
>   }
>  +EXPORT_SYMBOL(isolate_lru_page);
>
>   /*
>   * migrate_prep() needs to be called before we start compiling a list of pages
>  @@ -81,8 +82,9 @@ int migrate_prep(void)
>
>         return 0;
>   }
>  +EXPORT_SYMBOL(migrate_prep);
>
>  -static inline void move_to_lru(struct page *page)
>  +inline void move_to_lru(struct page *page)
>   {
>         if (PageActive(page)) {
>                 /*
>  @@ -96,6 +98,7 @@ static inline void move_to_lru(struct pa
>         }
>         put_page(page);
>   }
>  +EXPORT_SYMBOL(move_to_lru);
>
>   /*
>   * Add isolated pages on the list back to the LRU.
>  @@ -115,6 +118,7 @@ int putback_lru_pages(struct list_head *
>         }
>         return count;
>   }
>  +EXPORT_SYMBOL(putback_lru_pages);
>
>   /*
>   * Restore a potential migration pte to a working pte entry
>  @@ -805,6 +809,7 @@ out:
>
>         return nr_failed + retry;
>   }
>  +EXPORT_SYMBOL(migrate_pages);
>
>   #ifdef CONFIG_NUMA
>   /*
>  Index: linus/include/asm-ia64/page.h
>  =================================>  --- linus.orig/include/asm-ia64/page.h  2008-05-01 19:36:40.000000000 -0500
>  +++ linus/include/asm-ia64/page.h       2008-05-01 19:36:49.000000000 -0500
>  @@ -122,6 +122,7 @@ extern unsigned long max_low_pfn;
>   #endif
>
>   #define page_to_phys(page)     (page_to_pfn(page) << PAGE_SHIFT)
>  +#define        phys_to_page(kaddr)     (pfn_to_page(kaddr >> PAGE_SHIFT))
>   #define virt_to_page(kaddr)    pfn_to_page(__pa(kaddr) >> PAGE_SHIFT)
>   #define pfn_to_kaddr(pfn)      __va((pfn) << PAGE_SHIFT)
>
>  Index: linus/mm/page_alloc.c
>  =================================>  --- linus.orig/mm/page_alloc.c  2008-05-01 19:36:40.000000000 -0500
>  +++ linus/mm/page_alloc.c       2008-05-01 19:36:49.000000000 -0500
>  @@ -72,6 +72,7 @@ unsigned long totalreserve_pages __read_
>   long nr_swap_pages;
>   int percpu_pagelist_fraction;
>   unsigned int totalbad_pages;
>  +EXPORT_SYMBOL(totalbad_pages);
>
>   #ifdef CONFIG_HUGETLB_PAGE_SIZE_VARIABLE
>   int pageblock_order __read_mostly;
>  Index: linus/include/linux/migrate.h
>  =================================>  --- linus.orig/include/linux/migrate.h  2008-05-01 19:36:40.000000000 -0500
>  +++ linus/include/linux/migrate.h       2008-05-01 19:36:49.000000000 -0500
>  @@ -38,6 +38,7 @@ extern int migrate_prep(void);
>   extern int migrate_vmas(struct mm_struct *mm,
>                 const nodemask_t *from, const nodemask_t *to,
>                 unsigned long flags);
>  +extern void move_to_lru(struct page *);
>   #else
>   static inline int vma_migratable(struct vm_area_struct *vma)
>                                         { return 0; }
>  @@ -59,6 +60,7 @@ static inline int migrate_vmas(struct mm
>   {
>         return -ENOSYS;
>   }
>  +static inline void move_to_lru(struct page *p) { return; }

unnecessary return statement

>
>   /* Possible settings for the migrate_page() method in address_operations */
>   #define migrate_page NULL
>  --
>  Russ Anderson, OS RAS/Partitioning Project Lead
>  SGI - Silicon Graphics Inc          rja@sgi.com
>  --
>  To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>  the body of a message to majordomo@vger.kernel.org
>  More majordomo info at  http://vger.kernel.org/majordomo-info.html
>  Please read the FAQ at  http://www.tux.org/lkml/
>
