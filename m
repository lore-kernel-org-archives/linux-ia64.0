From: David Hildenbrand <david@redhat.com>
Date: Tue, 07 Jul 2020 07:26:43 +0000
Subject: Re: [PATCH V4 1/3] mm/sparsemem: Enable vmem_altmap support in vmemmap_populate_basepages()
Message-Id: <d9801165-025f-f226-9f9b-623a2bab58ff@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1594004178-8861-1-git-send-email-anshuman.khandual@arm.com>
 <1594004178-8861-2-git-send-email-anshuman.khandual@arm.com>
 <eeeb44f9-bc0a-2c3d-8e8f-7e3d9e066c7e@redhat.com>
 <7ac5ff78-378c-37e2-444f-9f72844b8697@arm.com>
In-Reply-To: <7ac5ff78-378c-37e2-444f-9f72844b8697@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org
Cc: justin.he@arm.com, catalin.marinas@arm.com, akpm@linux-foundation.org, Will Deacon <will@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Mike Rapoport <rppt@linux.ibm.com>, Michal Hocko <mhocko@suse.com>, "Matthew Wilcox (Oracle)" <willy@infradead.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Pavel Tatashin <pasha.tatashin@soleen.com>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-riscv@lists.infradead.org, x86@kernel.org, linux-kernel@vger.kernel.org

> Hmm, I assume these are some decisions that x86 platform will have to
> make going forward in a subsequent patch as the third patch does for
> the arm64 platform. But it is clearly beyond the scope of this patch
> which never intended to change existing behavior on a given platform.
> 

Yeah, I would be curious if my assumption is correct.

>>
>> [...]
>>
>>>  
>>> -pte_t * __meminit vmemmap_pte_populate(pmd_t *pmd, unsigned long addr, int node)
>>> +pte_t * __meminit vmemmap_pte_populate(pmd_t *pmd, unsigned long addr, int node,
>>> +				       struct vmem_altmap *altmap)
>>>  {
>>>  	pte_t *pte = pte_offset_kernel(pmd, addr);
>>>  	if (pte_none(*pte)) {
>>>  		pte_t entry;
>>> -		void *p = vmemmap_alloc_block_buf(PAGE_SIZE, node);
>>> +		void *p;
>>> +
>>> +		if (altmap)
>>> +			p = altmap_alloc_block_buf(PAGE_SIZE, altmap);
>>> +		else
>>> +			p = vmemmap_alloc_block_buf(PAGE_SIZE, node);
>>>  		if (!p)
>>>  			return NULL;
>>
>> I was wondering if
>>
>> if (altmap)
>> 	p = altmap_alloc_block_buf(PAGE_SIZE, altmap);
>> if (!p)
>> 	p = vmemmap_alloc_block_buf(PAGE_SIZE, node);
>> if (!p)
>> 	return NULL
>>
>> Would make sense. But I guess this isn't really relevant in practice,
>> because the altmap is usually sized properly.
>>
>> In general, LGTM.
> 
> Okay, I assume that no further changes are required here.
> 

Jep,

Reviewed-by: David Hildenbrand <david@redhat.com>

-- 
Thanks,

David / dhildenb
