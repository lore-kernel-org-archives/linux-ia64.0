From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Fri, 19 Jun 2020 01:46:35 +0000
Subject: Re: [PATCH V3 (RESEND) 0/3] arm64: Enable vmemmap mapping from device memory
Message-Id: <27f8c6f9-3970-6f02-dff4-7ca15bee7138@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1592442930-9380-1-git-send-email-anshuman.khandual@arm.com>
 <20200618085641.GE6493@linux.ibm.com>
In-Reply-To: <20200618085641.GE6493@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-mm@kvack.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, David Hildenbrand <david@redhat.com>, Michal Hocko <mhocko@suse.com>, "Matthew Wilcox (Oracle)" <willy@infradead.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Pavel Tatashin <pasha.tatashin@soleen.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-riscv@lists.infradead.org, x86@kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org



On 06/18/2020 02:26 PM, Mike Rapoport wrote:
> On Thu, Jun 18, 2020 at 06:45:27AM +0530, Anshuman Khandual wrote:
>> This series enables vmemmap backing memory allocation from device memory
>> ranges on arm64. But before that, it enables vmemmap_populate_basepages()
>> and vmemmap_alloc_block_buf() to accommodate struct vmem_altmap based
>> alocation requests.
>>
>> This series applies on 5.8-rc1.
>>
>> Pending Question:
>>
>> altmap_alloc_block_buf() does not have any other remaining users in
>> the tree after this change. Should it be converted into a static
>> function and it's declaration be dropped from the header
>> (include/linux/mm.h). Avoided doing so because I was not sure if there
>> are any off-tree users or not.
> 
> Well, off-tree users probably have an active fork anyway so they could
> switch to vmemmap_alloc_block_buf()...

Sure, will make the function a static and remove it's declaration
from the header.

> 
> Regardless, can you please update Documentation/vm/memory-model.rst to
> keep it in sync with the code?
Sure, will do.
