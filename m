From: Catalin Marinas <catalin.marinas@arm.com>
Date: Thu, 02 Jul 2020 14:03:55 +0000
Subject: Re: [PATCH V3 (RESEND) 1/3] mm/sparsemem: Enable vmem_altmap support in vmemmap_populate_basepages()
Message-Id: <20200702140355.GE22241@gaia>
List-Id: <linux-ia64.vger.kernel.org>
References: <1592442930-9380-1-git-send-email-anshuman.khandual@arm.com>
 <1592442930-9380-2-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1592442930-9380-2-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, Will Deacon <will@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, David Hildenbrand <david@redhat.com>, Mike Rapoport <rppt@linux.ibm.com>, Michal Hocko <mhocko@suse.com>, "Matthew Wilcox (Oracle)" <willy@infradead.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Pavel Tatashin <pasha.tatashin@soleen.com>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-riscv@lists.infradead.org, x86@kernel.org, linux-kernel@vger.kernel.org

On Thu, Jun 18, 2020 at 06:45:28AM +0530, Anshuman Khandual wrote:
> vmemmap_populate_basepages() is used across platforms to allocate backing
> memory for vmemmap mapping. This is used as a standard default choice or
> as a fallback when intended huge pages allocation fails. This just creates
> entire vmemmap mapping with base pages (PAGE_SIZE).
> 
> On arm64 platforms, vmemmap_populate_basepages() is called instead of the
> platform specific vmemmap_populate() when ARM64_SWAPPER_USES_SECTION_MAPS
> is not enabled as in case for ARM64_16K_PAGES and ARM64_64K_PAGES configs.
> 
> At present vmemmap_populate_basepages() does not support allocating from
> driver defined struct vmem_altmap while trying to create vmemmap mapping
> for a device memory range. It prevents ARM64_16K_PAGES and ARM64_64K_PAGES
> configs on arm64 from supporting device memory with vmemap_altmap request.
> 
> This enables vmem_altmap support in vmemmap_populate_basepages() unlocking
> device memory allocation for vmemap mapping on arm64 platforms with 16K or
> 64K base page configs.
> 
> Each architecture should evaluate and decide on subscribing device memory
> based base page allocation through vmemmap_populate_basepages(). Hence lets
> keep it disabled on all archs in order to preserve the existing semantics.
> A subsequent patch enables it on arm64.
> 
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Will Deacon <will@kernel.org>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: Paul Walmsley <paul.walmsley@sifive.com>
> Cc: Palmer Dabbelt <palmer@dabbelt.com>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Fenghua Yu <fenghua.yu@intel.com>
> Cc: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Mike Rapoport <rppt@linux.ibm.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Cc: linux-arm-kernel@lists.infradead.org
> Cc: linux-ia64@vger.kernel.org
> Cc: linux-riscv@lists.infradead.org
> Cc: x86@kernel.org
> Cc: linux-kernel@vger.kernel.org
> Tested-by: Jia He <justin.he@arm.com>
> Acked-by: Will Deacon <will@kernel.org>
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>

For arm64:

Acked-by: Catalin Marinas <catalin.marinas@arm.com>
