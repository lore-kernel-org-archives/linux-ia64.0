From: Andrew Morton <akpm@linux-foundation.org>
Date: Fri, 09 May 2008 20:52:11 +0000
Subject: Re: [PATCH 3/3] ia64: Call migration code on correctable errors v3
Message-Id: <20080509135211.bdc62558.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080509151135.GD16523@sgi.com>
In-Reply-To: <20080509151135.GD16523@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russ Anderson <rja@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, torvalds@linux-foundation.org, tony.luck@intel.com, clameter@sgi.com

On Fri, 9 May 2008 10:11:35 -0500
Russ Anderson <rja@sgi.com> wrote:

> Migrate data off pages with correctable memory errors.  This patch is the 
> ia64 specific piece.  It connects the CPE handler to the page migration
> code.  It is implemented as a kernel loadable module, similar to the mca
> recovery code (mca_recovery.ko).  This allows the feature to be turned off
> by uninstalling the module.  
> 
> It exports three symbols (migrate_prep, isolate_lru_page, and migrate_pages).
> 
>
> ...
>
> +#define BADRAM_BASENAME		"badram"
> +#define CE_HISTORY_LENGTH	30
> +
> +struct cpe_info {
> +	u64 	paddr;
> +	u16	node;
> +};
> +static struct cpe_info cpe[CE_HISTORY_LENGTH];
> +
> +static int cpe_polling_enabled = 1;
> +static int cpe_head;
> +static int cpe_tail;
> +
> +int work_scheduled;

static

> +static spinlock_t cpe_migrate_lock;

Use compile-time DEFINE_SPINLOCK(), remove runtime spin_lock_init()

> +void static

`static void' would be more conventional.

> +get_physical_address(void *buffer, u64 *paddr, u16 *node)
> +{
> +	sal_log_record_header_t *rh;
> +	sal_log_mem_dev_err_info_t *mdei;
> +	ia64_err_rec_t *err_rec;
> +	sal_log_platform_err_info_t *plat_err;
> +	efi_guid_t guid;
> +
> +	err_rec = buffer;
> +	rh = (sal_log_record_header_t *)&err_rec->sal_elog_header;

The cast appears to be unneeded?

> +	*paddr = 0;
> +	*node = 0;
> +
> +	/*
> +	 * Make sure it is a corrected error.
> +	 */
> +	if (rh->severity != sal_log_severity_corrected)
> +		return;
> +
> +	plat_err = (sal_log_platform_err_info_t *)&err_rec->proc_err;

Ditto.

> +	guid = (efi_guid_t)plat_err->mem_dev_err.header.guid;

Tritto.

> +	if (efi_guidcmp(guid, SAL_PLAT_MEM_DEV_ERR_SECT_GUID) = 0) {
> +		/*
> +		 * Memory cpe
> +		 */
> +		mdei = (sal_log_mem_dev_err_info_t *)&plat_err->mem_dev_err;

Quitto?

> +		if (mdei->valid.oem_data) {
> +			if (mdei->valid.physical_addr)
> +				*paddr = mdei->physical_addr;
> +
> +			if (mdei->valid.node) {
> +				if (ia64_platform_is("sn2"))
> +					*node = nasid_to_cnodeid(mdei->node);
> +				else
> +					*node = mdei->node;
> +			}
> +		}
> +	}
> +}
>
> ...
>
> +static int
> +ia64_mca_cpe_move_page(u64 paddr, u32 node)
> +{
> +	LIST_HEAD(pagelist);
> +	struct page *page;
> +	int ret;
> +	unsigned long irq_flags;
> +
> +	ret = validate_paddr_page(paddr);
> +	if (ret < 0)
> +		return EINVAL;
> +
> +	local_irq_save(irq_flags);

I think local_irq_disable() would suffice here.  Although local_irq_save()
is less risky.

> +	/*
> +	 * convert physical address to page number
> +	 */
> +	page = phys_to_page(paddr);
> +
> +	if (!spin_trylock(&cpe_migrate_lock)) {

eek.  The correlation between trylocks and ill-thought-through hackery is
high.  A trylock pretty much always requires a comprehensive comment
explaining why the unusual and suspicious facility is being used.  I'd
suggest that this one needs a comment too, coz this little reader doesn't
have a clue why it's here.

> +		local_irq_restore(irq_flags);
> +		return EBUSY;

I think you wanted -EBUSY there.

(janitorial project: grep the tree for Efoo's which are missing their "-")

> +	}
> +
> +	migrate_prep();
> +	ret = isolate_lru_page(page, &pagelist);

See, here's a problem.  You've carefully surrounded this code with
irqsave/restore, but isolate_lru_page() will do an unconditional
local_irq_enable(), thus undoing all your good work.

> +	if (ret)
> +		goto out;
> +
> +	SetPageMemError(page);		/* Mark the page as bad */
> +	ret = migrate_pages(&pagelist, alloc_migrate_page, node);
> +	if (ret = 0)
> +		list_add_tail(&page->lru, &badpagelist);
> +out:
> +	spin_unlock_irqrestore(&cpe_migrate_lock, irq_flags);
> +	return 0;
> +}
>
> ...
>
> +static spinlock_t cpe_list_lock;

Use compile-time DEFINE_SPINLOCK(), remove runtime spin_lock_init()

> +/*
> + * cpe_setup_migrate
> + *	Get the physical address out of the CPE record, add it
> + *	to the list of addresses to migrate (if not already on),
> + *	and schedule the back end worker task.  This is called
> + *	in interrupt context so cannot directly call the migration
> + *	code.
> + *
> + *  Inputs
> + *	rec	The CPE record
> + *  Outputs
> + *	1 on Success, -1 on failure
> + */
> +static int
> +cpe_setup_migrate(void *rec)
> +{
> +	u64 paddr;
> +	u16 node;
> +	/* int head, tail; */
> +	int i, ret;
> +
> +	if (!rec)
> +		return EINVAL;
> +
> +
> +	get_physical_address(rec, &paddr, &node);
> +	ret = validate_paddr_page(paddr);
> +	if (ret < 0)
> +		return EINVAL;

More non-negative Efoo's.  Please check the whole patchset.

> +
> +	if (!((cpe_head = cpe_tail) && (cpe[cpe_head].paddr = 0)))

DeMorgan says

	if ((cpe_head != cpe_tail) || (cpe[cpe_head].paddr != 0))

and I'd agree with him ;)

> +		/*
> +		 * List not empty
> +		 */
> +		for (i = 0; i < CE_HISTORY_LENGTH; i++) {
> +			if (PAGE_ALIGN(cpe[i].paddr) = PAGE_ALIGN(paddr))
> +				return 1;	/* already on the list */
> +		}
> +
> +	if (!spin_trylock(&cpe_list_lock)) {
> +		/*
> +		 * Someone else has the lock.  To avoid spinning in interrupt
> +		 * handler context, bail.
> +		 */

OK, there's a bit of explanation.

> +		return 1;
> +	}
> +
> +	if (cpe[cpe_head].paddr = 0) {
> +		cpe[cpe_head].node = node;
> +		cpe[cpe_head].paddr = paddr;
> +
> +		if (++cpe_head >= CE_HISTORY_LENGTH)
> +			cpe_head = 0;
> +	}
> +	spin_unlock(&cpe_list_lock);
> +
> +	if (!work_scheduled) {
> +		work_scheduled = 1;
> +		schedule_work(&cpe_enable_work);
> +	}
> +
> +	return 1;
> +}
> +
> +/*
> + * ======================================> + */
> +
> +/*
> + * free_one_bad_page
> + *	Free one page from the list of bad pages.
> + */
> +static int
> +free_one_bad_page(unsigned long paddr)
> +{
> +	LIST_HEAD(pagelist);
> +	struct page *page, *page2, *target;
> +
> +	/*
> +	 * Verify page address
> +	 */
> +	target = phys_to_page(paddr);
> +	list_for_each_entry_safe(page, page2, &badpagelist, lru) {
> +		if (page != target)
> +			continue;
> +
> +		ClearPageMemError(page);        /* Mark the page as good */
> +		totalbad_pages--;
> +		list_del(&page->lru);
> +		list_add_tail(&page->lru, &pagelist);

list_move_tail()?

> +		putback_lru_pages(&pagelist);
> +		break;
> +	}
> +	return 0;
> +}
>
> ...
>
> +static ssize_t
> +badpage_store(struct kobject *kobj,
> +	      struct kobj_attribute *attr, const char *buf, size_t count)
> +{
> +	char optstr[OPT_LEN];
> +	unsigned long opt;
> +	int len = OPT_LEN;
> +	int err;
> +
> +	if (count < len)
> +		len = count;
> +
> +	memcpy(optstr, buf, len);
> +	optstr[len] = '\0';

strlcpy() might be appropriate here.

> +	err = strict_strtoul(optstr, 16, &opt);
> +	if (err)
> +		return err;
> +
> +	if (opt = 0)
> +		free_all_bad_pages();
> +	else
> +		free_one_bad_page(opt);
> +
> +	return count;
> +}
> +
> +/*
> + * badpage_show
> + *	Display the number, size, and addresses of all the pages on the
> + *	bad page list.
> + *
> + *	Note that sysfs provides buf of PAGE_SIZE length.  bufsize tracks
> + *	the remaining space in buf to avoid overflowing.
> + */
> +static ssize_t
> +badpage_show(struct kobject *kobj,
> +	     struct kobj_attribute *attr, char *buf)
> +
> +{
> +	struct page *page, *page2;
> +	int i = 0, cnt;
> +	int bufsize = PAGE_SIZE;
> +
> +	cnt = snprintf(buf, bufsize, "Bad RAM: %d kB, %d pages marked bad\n"
> +			"List of bad physical pages\n",
> +			totalbad_pages << (PAGE_SHIFT - 10), totalbad_pages);
> +
> +	list_for_each_entry_safe(page, page2, &badpagelist, lru) {
> +		bufsize = PAGE_SIZE - cnt;
> +		if (bufsize < 20)
> +			break;
> +		cnt += snprintf(buf + cnt, bufsize,
> +				" 0x%011lx", page_to_phys(page));
> +		if (!(++i % 5))
> +			cnt += snprintf(buf + cnt, bufsize, "\n");
> +	}
> +	cnt += snprintf(buf + cnt, bufsize, "\n");
> +
> +	return cnt;
> +}

The whole point of snprintf() is to tell the function to avoid overrunning
the buffer.  But the above code only partially handles the `size' arg for
snprintf().

Something like

	char *bufend = buf;

	...

	cnt += snprintf(buf + cnt, bufend - (buf + cnt), ...);

might suit.


> +static struct kobj_attribute badram_attr = {
> +	.attr    = {
> +		.name = "badram",
> +		.mode = S_IWUSR | S_IRUGO,
> +	},
> +	.show = badpage_show,
> +	.store = badpage_store,
> +};
> +
> +int __init cpe_migrate_external_handler_init(void)

static

> +{
> +	int error;
> +
> +	error = sysfs_create_file(kernel_kobj, &badram_attr.attr);
> +	if (error)
> +		return -EINVAL;
> +
> +	spin_lock_init(&cpe_migrate_lock);
> +	spin_lock_init(&cpe_list_lock);

Remove these (see above).

> +	/*
> +	 * register external ce handler
> +	 */
> +	if (ia64_reg_CE_extension(cpe_setup_migrate)) {
> +		printk(KERN_ERR "ia64_reg_CE_extension failed.\n");
> +		return -EFAULT;
> +	}
> +	cpe_poll_enabled = cpe_polling_enabled;
> +
> +	printk(KERN_INFO "Registered badram Driver\n");
> +	return 0;
> +}
> +
> +void __exit cpe_migrate_external_handler_exit(void)

static

> +{
> +	/* unregister external mca handlers */
> +	ia64_unreg_CE_extension();
> +
> +	sysfs_remove_file(kernel_kobj, &badram_attr.attr);
> +}
> +
>
> ...
>
>  #ifdef CONFIG_ACPI
>  
> +/* Function pointer to Corrected Error memory migration driver */
> +int (*ia64_mca_ce_extension)(void *) = NULL;

Unneeded initialisation (checkpatch missed this).

Is this really supposed to be ACPI-dependent?  I didn't see that in the
Kconfig change anywhere.

otoh one suspect that acpi-free ia64 isn't viable...

> +
> +int
> +ia64_reg_CE_extension(int (*fn)(void *))
> +{
> +	if (ia64_mca_ce_extension)
> +		return 1;
> +
> +	ia64_mca_ce_extension = fn;
> +	return 0;
> +}
> +EXPORT_SYMBOL(ia64_reg_CE_extension);
> +
> +void
> +ia64_unreg_CE_extension(void)
> +{
> +	if (ia64_mca_ce_extension)
> +		ia64_mca_ce_extension = NULL;
> +}
> +EXPORT_SYMBOL(ia64_unreg_CE_extension);
> +
>  int cpe_vector = -1;
>  int ia64_cpe_irq = -1;
>  
> @@ -534,6 +563,7 @@ ia64_mca_cpe_int_handler (int cpe_irq, v
>  	static unsigned long	cpe_history[CPE_HISTORY_LENGTH];
>  	static int		index;
>  	static DEFINE_SPINLOCK(cpe_history_lock);
> +	int recover;
>  
>  	IA64_MCA_DEBUG("%s: received interrupt vector = %#x on CPU %d\n",
>  		       __func__, cpe_irq, smp_processor_id());
> @@ -580,6 +610,8 @@ ia64_mca_cpe_int_handler (int cpe_irq, v
>  out:
>  	/* Get the CPE error record and log it */
>  	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_CPE);
> +	recover = (ia64_mca_ce_extension && ia64_mca_ce_extension(
> +				IA64_LOG_CURR_BUFFER(SAL_INFO_TYPE_CPE)));
>  
>  	return IRQ_HANDLED;
>  }
> Index: linus/arch/ia64/Kconfig
> =================================> --- linus.orig/arch/ia64/Kconfig	2008-05-09 09:50:58.379235657 -0500
> +++ linus/arch/ia64/Kconfig	2008-05-09 09:51:23.190322572 -0500
> @@ -456,6 +456,9 @@ config COMPAT_FOR_U64_ALIGNMENT
>  config IA64_MCA_RECOVERY
>  	tristate "MCA recovery from errors other than TLB."
>  
> +config IA64_CPE_MIGRATE
> +	tristate "Migrate data off pages with correctable errors"
> +

No Kconfig help?

>  extern void ia64_mca_cmc_vector_setup(void);
>  extern int  ia64_reg_MCA_extension(int (*fn)(void *, struct ia64_sal_os_state *));
>  extern void ia64_unreg_MCA_extension(void);
> +extern int  ia64_reg_CE_extension(int (*fn)(void *));
> +extern void ia64_unreg_CE_extension(void);
>  extern u64 ia64_get_rnat(u64 *);
>  extern void ia64_mca_printk(const char * fmt, ...)
>  	 __attribute__ ((format (printf, 1, 2)));
> +
> +extern struct list_head badpagelist;
> +extern struct kobject *kernel_kobj;

These are rather generic-sounding identifiers.  If Greg comes along later
and adds a kernel_kobj, he'd be justified in wondering why some obscure
ia64 thing stole his identifier.

> --- linus.orig/include/asm-ia64/page.h	2008-05-09 09:50:58.379235657 -0500
> +++ linus/include/asm-ia64/page.h	2008-05-09 09:51:23.254330535 -0500
> @@ -122,6 +122,7 @@ extern unsigned long max_low_pfn;
>  #endif
>  
>  #define page_to_phys(page)	(page_to_pfn(page) << PAGE_SHIFT)
> +#define	phys_to_page(kaddr)	(pfn_to_page(kaddr >> PAGE_SHIFT))

hm. I'm surprised that ia64's phys_to_page() would be so simple.


