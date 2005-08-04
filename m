From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 04 Aug 2005 22:41:07 +0000
Subject: Re: efi_memmapwalk re-write
Message-Id: <200508042241.j74Mf7QV007576@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F040F73E2@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F040F73E2@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Thanks for feedback. I will take a look at these and see if I can
> simplify it further.

Here's part of the solution ... a combination of your gather and trim
functions.  I bypassed the problem of allocating the space for the
kern_memdesc structures for this example ... so you'll have to
integrate this with your code to allocate space.

I think it is a significant improvement in readability, but I'm biased.

Oh, it doesn't print out all the:

efi.trim_top: ignoring 4KB of memory at 0x0 due to granule hole at 0x0
and
efi.trim_bottom: ignoring 8KB of memory at 0x1feffe000 due to granule hole at 0x1fe000000

messages.  If anyone thinks they are useful, then they could be added, but
they seem like a lot of noise to me.

This looks like it runs ok for the memory map on my tiger, but I didn't try it on
anything else.

-Tony

---- cut here and drop into efi.c ----


struct kern_memdesc {
	u64	start;
	u64	npages;
} kern_memdesc[100];

static inline u64
efi_end(efi_memory_desc_t *e)
{
	return e->phys_addr + (e->num_pages<<EFI_PAGE_SHIFT);
}

static inline int
efi_wb(efi_memory_desc_t *e)
{
	return e->attribute & EFI_MEMORY_WB;
}

static inline u64
kern_end(struct kern_memdesc *k)
{
	return k->start + (k->npages<<EFI_PAGE_SHIFT);
}

void
efi_gather(void)
{
	struct kern_memdesc *k = kern_memdesc, *prev = 0;
	u64	contig_low=0, contig_high=0;
	u64	as, ae;
	void *efi_map_start, *efi_map_end, *p, *q;
	efi_memory_desc_t *md, *pmd = NULL, *check_md;
	u64	efi_desc_size;
	unsigned long total_mem = 0;

	efi_map_start = __va(ia64_boot_param->efi_memmap);
	efi_map_end   = efi_map_start + ia64_boot_param->efi_memmap_size;
	efi_desc_size = ia64_boot_param->efi_memdesc_size;

	for (p = efi_map_start; p < efi_map_end; pmd = md, p += efi_desc_size) {
		md = p;
		if (!efi_wb(md))
			continue;
		if (pmd = NULL || !efi_wb(pmd) || efi_end(pmd) != md->phys_addr) {
			contig_low = GRANULEROUNDUP(md->phys_addr);
			contig_high = efi_end(md);
			for (q = p + efi_desc_size; q < efi_map_end; q += efi_desc_size) {
				check_md = q;
				if (!efi_wb(check_md))
					break;
				if (contig_high != check_md->phys_addr)
					break;
				contig_high = efi_end(check_md);
			}
			contig_high = GRANULEROUNDDOWN(contig_high);
		}
		if (!is_available_memory(md))
			continue;

		/* round ends inward to granule boundaries */
		as = max(contig_low, md->phys_addr);
		ae = min(contig_high, efi_end(md));

		/* keep within max_addr= command line arg */
		ae = min(ae, max_addr);
		if (ae <= as)
			continue;

		/* avoid going over mem= command line arg */
		if (total_mem + (ae - as) > mem_limit)
			ae -= total_mem + (ae - as) - mem_limit;

		if (ae <= as)
			continue;
		if (prev && kern_end(prev) = md->phys_addr) {
			prev->npages += (ae - as) >> EFI_PAGE_SHIFT;
			total_mem += ae - as;
			continue;
		}
		k->start = as;
		k->npages = (ae - as) >> EFI_PAGE_SHIFT;
		total_mem += ae - as;
		prev = k++;
	}
	k->start = ~0L; /* end-marker */
}
