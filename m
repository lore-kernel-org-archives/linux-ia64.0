From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Date: Wed, 04 Sep 2019 20:16:18 +0000
Subject: Re: [PATCH 1/1] mm/pgtable/debug: Add test validating architecture page table helpers
Message-Id: <20190904221618.1b624a98@thinkpad>
List-Id: <linux-ia64.vger.kernel.org>
References: <1567497706-8649-1-git-send-email-anshuman.khandual@arm.com>
 <1567497706-8649-2-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1567497706-8649-2-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Mark Rutland <mark.rutland@arm.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, James Hogan <jhogan@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-s390@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Russell King - ARM Linux <linux@armlinux.org.uk>, Matthew Wilcox <willy@infradead.org>, Steven Price <Steven.Price@arm.com>, Jason Gunthorpe <jgg@ziepe.ca>, linux-arm-kernel@lists.infradead.org, linux-snps-arc@lists.infradead.org, Kees Cook <keescook@chromium.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Mark Brown <broonie@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Sri Krishna chowdary <schowdary@nvidia.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mips@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org, Paul Burton <paul.burton@mips.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vineet Gupta <vgupta@synopsys.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>

On Tue,  3 Sep 2019 13:31:46 +0530
Anshuman Khandual <anshuman.khandual@arm.com> wrote:

> This adds a test module which will validate architecture page table helpers
> and accessors regarding compliance with generic MM semantics expectations.
> This will help various architectures in validating changes to the existing
> page table helpers or addition of new ones.
> 
> Test page table and memory pages creating it's entries at various level are
> all allocated from system memory with required alignments. If memory pages
> with required size and alignment could not be allocated, then all depending
> individual tests are skipped.

This looks very useful, thanks. Of course, s390 is quite special and does
not work nicely with this patch (yet), mostly because of our dynamic page
table levels/folding. Still need to figure out what can be fixed in the arch
code and what would need to be changed in the test module. See below for some
generic comments/questions.

At least one real bug in the s390 code was already revealed by this, which
is very nice. In pmd/pud_bad(), we also check large pmds/puds for sanity,
instead of reporting them as bad, which is apparently not how it is expected.

[...]
> +/*
> + * Basic operations
> + *
> + * mkold(entry)			= An old and not a young entry
> + * mkyoung(entry)		= A young and not an old entry
> + * mkdirty(entry)		= A dirty and not a clean entry
> + * mkclean(entry)		= A clean and not a dirty entry
> + * mkwrite(entry)		= A write and not a write protected entry
> + * wrprotect(entry)		= A write protected and not a write entry
> + * pxx_bad(entry)		= A mapped and non-table entry
> + * pxx_same(entry1, entry2)	= Both entries hold the exact same value
> + */
> +#define VADDR_TEST	(PGDIR_SIZE + PUD_SIZE + PMD_SIZE + PAGE_SIZE)

Why is P4D_SIZE missing in the VADDR_TEST calculation?

[...]
> +
> +#if !defined(__PAGETABLE_PMD_FOLDED) && !defined(__ARCH_HAS_4LEVEL_HACK)
> +static void pud_clear_tests(pud_t *pudp)
> +{
> +	memset(pudp, RANDOM_NZVALUE, sizeof(pud_t));
> +	pud_clear(pudp);
> +	WARN_ON(!pud_none(READ_ONCE(*pudp)));
> +}

For pgd/p4d/pud_clear(), we only clear if the page table level is present
and not folded. The memset() here overwrites the table type bits, so
pud_clear() will not clear anything on s390 and the pud_none() check will
fail.
Would it be possible to OR a (larger) random value into the table, so that
the lower 12 bits would be preserved?

> +
> +static void pud_populate_tests(struct mm_struct *mm, pud_t *pudp, pmd_t *pmdp)
> +{
> +	/*
> +	 * This entry points to next level page table page.
> +	 * Hence this must not qualify as pud_bad().
> +	 */
> +	pmd_clear(pmdp);
> +	pud_clear(pudp);
> +	pud_populate(mm, pudp, pmdp);
> +	WARN_ON(pud_bad(READ_ONCE(*pudp)));
> +}

This will populate the pud with a pmd pointer that does not point to the
beginning of the pmd table, but to the second entry (because of how
VADDR_TEST is constructed). This will result in failing pud_bad() check
on s390. Not sure why/how it works on other archs, but would it be possible
to align pmdp down to the beginning of the pmd table (and similar for the
other pxd_populate_tests)?

[...]
> +
> +	p4d_free(mm, saved_p4dp);
> +	pud_free(mm, saved_pudp);
> +	pmd_free(mm, saved_pmdp);
> +	pte_free(mm, (pgtable_t) virt_to_page(saved_ptep));

pgtable_t is arch-specific, and on s390 it is not a struct page pointer,
but a pte pointer. So this will go wrong, also on all other archs (if any)
where pgtable_t is not struct page.
Would it be possible to use pte_free_kernel() instead, and just pass
saved_ptep directly?

Regards,
Gerald
