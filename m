From: Will Deacon <will@kernel.org>
Date: Wed, 31 Jul 2019 16:10:48 +0000
Subject: Re: [RFC 1/2] mm/sparsemem: Add vmem_altmap support in vmemmap_populate_basepages()
Message-Id: <20190731161047.ypye54x5c5jje5sq@willie-the-truck>
List-Id: <linux-ia64.vger.kernel.org>
References: <1561697083-7329-1-git-send-email-anshuman.khandual@arm.com>
 <1561697083-7329-2-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1561697083-7329-2-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, Fenghua Yu <fenghua.yu@intel.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Will Deacon <will.deacon@arm.com>, x86@kernel.org, linux-kernel@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org

On Fri, Jun 28, 2019 at 10:14:42AM +0530, Anshuman Khandual wrote:
> Generic vmemmap_populate_basepages() is used across platforms for vmemmap
> as standard or as fallback when huge pages mapping fails. On arm64 it is
> used for configs with ARM64_SWAPPER_USES_SECTION_MAPS applicable both for
> ARM64_16K_PAGES and ARM64_64K_PAGES which cannot use huge pages because of
> alignment requirements.
> 
> This prevents those configs from allocating from device memory for vmemap
> mapping as vmemmap_populate_basepages() does not support vmem_altmap. This
> enables that required support. Each architecture should evaluate and decide
> on enabling device based base page allocation when appropriate. Hence this
> keeps it disabled for all architectures to preserve the existing semantics.

This commit message doesn't really make sense to me. There's a huge amount
of arm64-specific detail, followed by vague references to "this" and
"those" and "that" and I lost track of what you're trying to solve.

However, I puzzled through the code and I think it does make sense, so:

Acked-by: Will Deacon <will@kernel.org>

assuming you rewrite the commit message.

However, this has a dependency on your hot remove series which has open
comments from Mark Rutland afaict.

Will
