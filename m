From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Thu, 01 Aug 2019 03:21:01 +0000
Subject: Re: [RFC 1/2] mm/sparsemem: Add vmem_altmap support in vmemmap_populate_basepages()
Message-Id: <a753a841-c344-c708-fccd-39d838637bcb@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1561697083-7329-1-git-send-email-anshuman.khandual@arm.com>
 <1561697083-7329-2-git-send-email-anshuman.khandual@arm.com>
 <20190731161047.ypye54x5c5jje5sq@willie-the-truck>
In-Reply-To: <20190731161047.ypye54x5c5jje5sq@willie-the-truck>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Will Deacon <will@kernel.org>
Cc: linux-mm@kvack.org, Fenghua Yu <fenghua.yu@intel.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Will Deacon <will.deacon@arm.com>, x86@kernel.org, linux-kernel@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org



On 07/31/2019 09:40 PM, Will Deacon wrote:
> On Fri, Jun 28, 2019 at 10:14:42AM +0530, Anshuman Khandual wrote:
>> Generic vmemmap_populate_basepages() is used across platforms for vmemmap
>> as standard or as fallback when huge pages mapping fails. On arm64 it is
>> used for configs with ARM64_SWAPPER_USES_SECTION_MAPS applicable both for
>> ARM64_16K_PAGES and ARM64_64K_PAGES which cannot use huge pages because of
>> alignment requirements.
>>
>> This prevents those configs from allocating from device memory for vmemap
>> mapping as vmemmap_populate_basepages() does not support vmem_altmap. This
>> enables that required support. Each architecture should evaluate and decide
>> on enabling device based base page allocation when appropriate. Hence this
>> keeps it disabled for all architectures to preserve the existing semantics.
> 
> This commit message doesn't really make sense to me. There's a huge amount
> of arm64-specific detail, followed by vague references to "this" and
> "those" and "that" and I lost track of what you're trying to solve.

Hmm, will clean up.

> 
> However, I puzzled through the code and I think it does make sense, so:
> 
> Acked-by: Will Deacon <will@kernel.org>
> 
> assuming you rewrite the commit message.

Thanks, will do.

> 
> However, this has a dependency on your hot remove series which has open
> comments from Mark Rutland afaict.

Yeah it has dependency on the hot-remove series. The only outstanding issue
there being whether to call free_empty_tables() in vmemmap tear down path
or not. Mark had asked for more details regarding the implications in cases
where free_empty_tables() is called or is not called. I did evaluate those
details recently and we should be able to take a decision sooner.
