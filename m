From: David Hildenbrand <david@redhat.com>
Date: Wed, 08 Feb 2023 14:12:06 +0000
Subject: Re: [PATCH mm-unstable v1 04/26] arm/mm: support __HAVE_ARCH_PTE_SWP_EXCLUSIVE
Message-Id: <39fd91e3-c93b-23c6-afc6-cbe473bb0ca9@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230113171026.582290-1-david@redhat.com>
 <20230113171026.582290-5-david@redhat.com> <Y+GcDFMNHw2cdDN1@sirena.org.uk>
In-Reply-To: <Y+GcDFMNHw2cdDN1@sirena.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mark Brown <broonie@kernel.org>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, John Hubbard <jhubbard@nvidia.com>, Jason Gunthorpe <jgg@nvidia.com>, Mike Rapoport <rppt@linux.ibm.com>, Yang Shi <shy828301@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Nadav Amit <namit@vmware.com>, Andrea Arcangeli <aarcange@redhat.com>, Peter Xu <peterx@redhat.com>, linux-mm@kvack.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, Russell King <linux@armlinux.org.uk>

On 07.02.23 01:32, Mark Brown wrote:
> On Fri, Jan 13, 2023 at 06:10:04PM +0100, David Hildenbrand wrote:
>> Let's support __HAVE_ARCH_PTE_SWP_EXCLUSIVE by stealing one bit from the
>> offset. This reduces the maximum swap space per file to 64 GiB (was 128
>> GiB).
>>
>> While at it drop the PTE_TYPE_FAULT from __swp_entry_to_pte() which is
>> defined to be 0 and is rather confusing because we should be dealing
>> with "Linux PTEs" not "hardware PTEs". Also, properly mask the type in
>> __swp_entry().
> 
> Today's -next (and at least back to Friday, older logs are unclear - I
> only noticed -next issues today) fails to NFS boot on an AT91SAM9G20-EK
> (an old ARMv5 platform) with multi_v5_defconfig, a bisect appears to
> point to this patch (20aae9eff5acd8f5 in today's -next) as the culprit.

It's been in -next for quite a while, thanks for the report!

> 
> The failure happens at some point after starting userspace, the kernel
> starts spamming the console with messages in the form:
> 
>      get_swap_device: Bad swap file entry 10120d20
> 

_swap_info_get() tells us that the swp type seems to be bad.
I assume we're dealing with a migration entry, if swap is disabled, and fail to
detect is_migration_entry() correctly because the type is messed up.

Could you give the following a test?


 From 8c4bdbd9862f85782d5919d044c172b584063e83 Mon Sep 17 00:00:00 2001
From: David Hildenbrand <david@redhat.com>
Date: Wed, 8 Feb 2023 15:08:01 +0100
Subject: [PATCH] arm/mm: Fix swp type masking in __swp_entry()

We're masking with the number of type bits instead of the type mask, which
is obviously wrong.

Fixes: 20aae9eff5ac ("arm/mm: support __HAVE_ARCH_PTE_SWP_EXCLUSIVE")
Reported-by: Mark Brown <broonie@kernel.org>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
  arch/arm/include/asm/pgtable.h | 2 +-
  1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/arm/include/asm/pgtable.h b/arch/arm/include/asm/pgtable.h
index 2e626e6da9a3..a58ccbb406ad 100644
--- a/arch/arm/include/asm/pgtable.h
+++ b/arch/arm/include/asm/pgtable.h
@@ -292,7 +292,7 @@ static inline pte_t pte_modify(pte_t pte, pgprot_t newprot)
  
  #define __swp_type(x)		(((x).val >> __SWP_TYPE_SHIFT) & __SWP_TYPE_MASK)
  #define __swp_offset(x)		((x).val >> __SWP_OFFSET_SHIFT)
-#define __swp_entry(type, offset) ((swp_entry_t) { (((type) & __SWP_TYPE_BITS) << __SWP_TYPE_SHIFT) | \
+#define __swp_entry(type, offset) ((swp_entry_t) { (((type) & __SWP_TYPE_MASK) << __SWP_TYPE_SHIFT) | \
  						   ((offset) << __SWP_OFFSET_SHIFT) })
  
  #define __pte_to_swp_entry(pte)	((swp_entry_t) { pte_val(pte) })
-- 
2.39.1


-- 
Thanks,

David / dhildenb
