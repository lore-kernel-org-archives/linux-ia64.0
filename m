From: David Hildenbrand <david@redhat.com>
Date: Mon, 06 Jul 2020 09:03:47 +0000
Subject: Re: [PATCH V4 1/3] mm/sparsemem: Enable vmem_altmap support in vmemmap_populate_basepages()
Message-Id: <eeeb44f9-bc0a-2c3d-8e8f-7e3d9e066c7e@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1594004178-8861-1-git-send-email-anshuman.khandual@arm.com>
 <1594004178-8861-2-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1594004178-8861-2-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org
Cc: justin.he@arm.com, catalin.marinas@arm.com, akpm@linux-foundation.org, Will Deacon <will@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Mike Rapoport <rppt@linux.ibm.com>, Michal Hocko <mhocko@suse.com>, "Matthew Wilcox (Oracle)" <willy@infradead.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Pavel Tatashin <pasha.tatashin@soleen.com>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-riscv@lists.infradead.org, x86@kernel.org, linux-kernel@vger.kernel.org

>  	return 0;
> @@ -1505,7 +1505,7 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
>  	int err;
>  
>  	if (end - start < PAGES_PER_SECTION * sizeof(struct page))
> -		err = vmemmap_populate_basepages(start, end, node);
> +		err = vmemmap_populate_basepages(start, end, node, NULL);
>  	else if (boot_cpu_has(X86_FEATURE_PSE))
>  		err = vmemmap_populate_hugepages(start, end, node, altmap);
>  	else if (altmap) {

It's somewhat weird that we don't allocate basepages from altmap on x86
(both for sub-sections and without PSE). I wonder if we can simply
unlock that with your change. Especially, also handle the
!X86_FEATURE_PSE case below properly with an altmap.

a) all hw with PMEM has PSE - except special QEMU setups, so nobody
cared to implement. For the sub-section special case, nobody cared about
a handfull of memmap not ending up on the altmap. (but it's still wasted
system memory IIRC).

b) the pagetable overhead for small pages is not-neglectable and might
result in similar issues as solved by the switch to altmap on very huge
PMEM (with small amount of system RAM).

I guess it is due to a).

[...]

>  
> -pte_t * __meminit vmemmap_pte_populate(pmd_t *pmd, unsigned long addr, int node)
> +pte_t * __meminit vmemmap_pte_populate(pmd_t *pmd, unsigned long addr, int node,
> +				       struct vmem_altmap *altmap)
>  {
>  	pte_t *pte = pte_offset_kernel(pmd, addr);
>  	if (pte_none(*pte)) {
>  		pte_t entry;
> -		void *p = vmemmap_alloc_block_buf(PAGE_SIZE, node);
> +		void *p;
> +
> +		if (altmap)
> +			p = altmap_alloc_block_buf(PAGE_SIZE, altmap);
> +		else
> +			p = vmemmap_alloc_block_buf(PAGE_SIZE, node);
>  		if (!p)
>  			return NULL;

I was wondering if

if (altmap)
	p = altmap_alloc_block_buf(PAGE_SIZE, altmap);
if (!p)
	p = vmemmap_alloc_block_buf(PAGE_SIZE, node);
if (!p)
	return NULL

Would make sense. But I guess this isn't really relevant in practice,
because the altmap is usually sized properly.

In general, LGTM.

-- 
Thanks,

David / dhildenb
