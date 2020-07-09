From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Thu, 09 Jul 2020 03:42:17 +0000
Subject: Re: [PATCH V4 0/3] arm64: Enable vmemmap mapping from device memory
Message-Id: <a9157943-d033-f9a8-87fc-dce78540df78@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1594004178-8861-1-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1594004178-8861-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: justin.he@arm.com, catalin.marinas@arm.com, akpm@linux-foundation.org, Will Deacon <will@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, David Hildenbrand <david@redhat.com>, Mike Rapoport <rppt@linux.ibm.com>, Michal Hocko <mhocko@suse.com>, "Matthew Wilcox (Oracle)" <willy@infradead.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Pavel Tatashin <pasha.tatashin@soleen.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-riscv@lists.infradead.org, x86@kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org



On 07/06/2020 08:26 AM, Anshuman Khandual wrote:
> This series enables vmemmap backing memory allocation from device memory
> ranges on arm64. But before that, it enables vmemmap_populate_basepages()
> and vmemmap_alloc_block_buf() to accommodate struct vmem_altmap based
> alocation requests.
> 
> This series applies on 5.8-rc4.
> 
> Changes in V4:
> 
> - Dropped 'fallback' from vmemmap_alloc_block_buf() per Catalin

Hello Andrew,

This series has been a long running one :) Now that all the three patches
here have been reviewed, could you please consider this series for merging
towards 5.9-rc1. Catalin had suggested earlier [1] that it should go via
the MM tree instead, as it touches multiple architecture. Thank you.

[1] https://patchwork.kernel.org/patch/11611103/

- Anshuman
