From: Dave Hansen <haveblue@us.ibm.com>
Date: Fri, 14 Oct 2005 05:12:05 +0000
Subject: Re: [Patch 2/2] Special Memory (mspec) driver.
Message-Id: <1129266725.22903.25.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051012194022.GE17458@lnx-holt.americas.sgi.com>
	 <20051012194233.GG17458@lnx-holt.americas.sgi.com>
In-Reply-To: <20051012194233.GG17458@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Robin Holt <holt@sgi.com>
Cc: ia64 list <linux-ia64@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, hch@infradead.org, jgarzik@pobox.com, William Lee Irwin III <wli@holomorphy.com>

On Wed, 2005-10-12 at 14:42 -0500, Robin Holt wrote:
> +static void
> +mspec_close(struct vm_area_struct *vma)
> +{
> +	struct vma_data *vdata;
> +	int i, pages, result;
> +
> +	vdata = vma->vm_private_data;
> +	if (atomic_dec_and_test(&vdata->refcnt)) {
> +		pages = (vma->vm_end - vma->vm_start) >> PAGE_SHIFT;
...

Looks like you could un-indent almost the entire function of you just
did this instead:

	if (!atomic_dec_and_test(&vdata->refcnt))
		return;

> +static __inline__ int
> +mspec_get_one_pte(struct mm_struct *mm, u64 address, pte_t ** page_table)
> +{
> +	pgd_t *pgd;
> +	pmd_t *pmd;
> +	pud_t *pud;
> +
> +	pgd = pgd_offset(mm, address);
> +	if (pgd_present(*pgd)) {
> +		pud = pud_offset(pgd, address);
> +		if (pud_present(*pud)) {
> +			pmd = pmd_offset(pud, address);
> +			if (pmd_present(*pmd)) {
> +				*page_table = pte_offset_map(pmd, address);
> +				if (pte_present(**page_table)) {
> +					return 0;
> +				}
> +			}
> +		}
> +	}
> +
> +	return -1;
> +}

This looks pretty similar to get_one_pte_map().  Is there enough
commonality to use it?

> +static int
> +mspec_mmap(struct file *file, struct vm_area_struct *vma, int type)
> +{
> +	struct vma_data *vdata;
> +	int pages;
> +
> +	if (vma->vm_pgoff != 0)
> +		return -EINVAL;
> +
> +	if ((vma->vm_flags & VM_WRITE) = 0)
> +		return -EPERM;
> +
> +	pages = (vma->vm_end - vma->vm_start) >> PAGE_SHIFT;
> +	if (!
> +	    (vdata > +	     vmalloc(sizeof(struct vma_data) + pages * sizeof(long))))
> +		return -ENOMEM;

How about:

	vdata = vmalloc(sizeof(struct vma_data) + pages * sizeof(long));
	if (!vdata)
		return -ENOMEM;

> +#ifdef CONFIG_PROC_FS
> +static void *
> +mspec_seq_start(struct seq_file *file, loff_t * offset)
> +{
> +	if (*offset < MAX_NUMNODES)
> +		return offset;
> +	return NULL;
> +}

This whole thing really is a driver for a piece of arch-specific
hardware, right?  Does it really belong in /proc?  You already have a
misc device, so you already have some area in sysfs.  Would that make a
better place for it?

> +static int __init
> +mspec_init(void)
> +{
> +	if ((ret = misc_register(&cached_miscdev))) {
> +		printk(KERN_ERR "%s: failed to register device %i\n",
> +		       CACHED_ID, ret);
> +		misc_deregister(&fetchop_miscdev);
> +		return ret;
> +	}

Isn't the general kernel style for these to keep the action out of the
if() condition?

	ret = misc_register(&cached_miscdev);
	if (ret) {
		...
	}

-- Dave

