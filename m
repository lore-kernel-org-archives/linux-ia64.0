From: "Ameya Mitragotri" <ameya.mitragotri@wipro.com>
Date: Sat, 08 Nov 2003 04:28:38 +0000
Subject: Problem with accessing page tables
Message-Id: <marc-linux-ia64-106826502101883@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

 I wrote following piece of code to traverse the page table for a
particular
Kernel variable. But the PMD access is always a failure.

 I'm using Itanium 2 with linux-2.6.0-test5.
Any pointers will be really helpful. 
Thanks and regards,
Ameya

	pgd_t *pgd;
	pmd_t *pmd;
	pte_t *ptep, pte;
	unsigned long pfn;

	printk(KERN_EMERG "The address is %lx\n\n\n",address);

	pgd = pgd_offset_k(address);
	if (pgd_none(*pgd) || pgd_bad(*pgd))
		goto out;

>>	pmd = pmd_offset(pgd, address); <<<
One of the checks below fails because the call pmd_offset gives pmd 
With value o.

	if (pmd_none(*pmd))
		goto out;
	if (pmd_bad(*pmd))
		goto out;

	ptep = pte_offset_kernel(pmd, address);
	if (!ptep)
		goto out;
	pte = *ptep;
	pte_unmap(ptep);
	if (pte_present(pte)) {
		if (!write || (pte_write(pte) && pte_dirty(pte))) {
			pfn = pte_pfn(pte);
			if (pfn_valid(pfn)) {
				struct page *page = pfn_to_page(pfn);

				//mark_page_accessed(page);
				return page;
			}
		}
	}
	else
	{
		printk(KERN_EMERG "pte entry not present \n");
	}

out:
	printk(KERN_EMERG "At out \n");
