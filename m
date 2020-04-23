From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Thu, 23 Apr 2020 05:22:44 +0000
Subject: Re: [PATCH V3 0/3] arm64: Enable vmemmap mapping from device memory
Message-Id: <ff29a6a3-a75d-878d-75a0-2c458be429f4@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1585631387-18819-1-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1585631387-18819-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-mm@kvack.org
Cc: robin.murphy@arm.com, dan.j.williams@intel.com, jglisse@redhat.com, jgg@mellanox.com, rcampbell@nvidia.com, aneesh.kumar@linux.ibm.com, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, David Hildenbrand <david@redhat.com>, Mike Rapoport <rppt@linux.ibm.com>, Michal Hocko <mhocko@suse.com>, "Matthew Wilcox (Oracle)" <willy@infradead.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Tatashin <pasha.tatashin@soleen.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-riscv@lists.infradead.org, x86@kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org


On 03/31/2020 10:39 AM, Anshuman Khandual wrote:
> This series enables vmemmap backing memory allocation from device memory
> ranges on arm64. But before that, it enables vmemmap_populate_basepages()
> and vmemmap_alloc_block_buf() to accommodate struct vmem_altmap based
> alocation requests.
> 
> This series applies after latest (v14) arm64 memory hot remove series
> (https://lkml.org/lkml/2020/3/3/1746) on Linux 5.6.
> 
> Pending Question:
> 
> altmap_alloc_block_buf() does not have any other remaining users in the
> tree after this change. Should it be converted into a static function and
> it's declaration be dropped from the header (include/linux/mm.h). Avoided
> doing so because I was not sure if there are any off-tree users or not.
> 
> Changes in V3:
> 
> - Dropped comment from free_hotplug_page_range() per Robin
> - Modified comment in unmap_hotplug_range() per Robin
> - Enabled altmap support in vmemmap_alloc_block_buf() per Robin

Just a gentle ping. Any updates on this series ? In particular, is there
any comments or suggestions or concerns with respect to the first two
patches here that change the core MM and relevant call sites on some
platforms. Thank you.

- Anshuman
