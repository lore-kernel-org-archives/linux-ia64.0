From: Jessica Clarke <jrtc27@jrtc27.com>
Date: Thu, 13 Aug 2020 19:12:25 +0000
Subject: Re: [PATCH v3] arch/ia64: Restore arch-specific pgd_offset_k implementation
Message-Id: <13B46F16-1E82-4E15-8F6B-E8C24D6800AA@jrtc27.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200813190546.4788-1-rppt@kernel.org>
In-Reply-To: <20200813190546.4788-1-rppt@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Rapoport <rppt@kernel.org>
Cc: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Anatoly Pugachev <matorola@gmail.com>, Sergei Trofimovich <slyfox@gentoo.org>, linux-mm@kvack.org, Frank Scheiner <frank.scheiner@web.de>, Mike Rapoport <rppt@linux.ibm.com>

On 13 Aug 2020, at 20:05, Mike Rapoport <rppt@kernel.org> wrote:
> 
> From: Jessica Clarke <jrtc27@jrtc27.com>

Given this commit is being attributed to me please apply these grammatical
fixes (and tweaks) to your wording, as well as a technical correction.

(I have not re-wrapped, for easier diffing, and due to my laziness)

> IA-64 is special and treats pgd_offset_k() differently from pgd_offset() by
> using different formulas to calculate index into kernel and user PGD
> tables. The index into user PGDs takes into account the region number
> and the index into the kernel (init_mm) PGD always presumes predefined
> kernel region number. Commit 974b9b2c68 ("mm: consolidate pte_index()
> and pte_offset_*() definitions") made IA-64 to use generic
> pgd_offset_k() which wrongly used pgd_index() for user page tables. As
> the result, the index into kernel PGD was going out of bounds and the
> kernel hang during early boot.
> 
> Allow overrides of pgd_offset_k() and use an override on IA-64 with the
> old implementation that will correctly index kernel PGD.

IA-64 is special and treats pgd_offset_k() differently to pgd_offset(),
using different formulae to calculate the indices into the kernel and user PGDs.
The index into the user PGDs takes into account the region number,
but the index into the kernel (init_mm) PGD always assumes a predefined
kernel region number. Commit 974b9b2c68 ("mm: consolidate pte_index()
and pte_offset_*() definitions") made IA-64 use a generic
pgd_offset_k() which incorrectly used pgd_index() for kernel page tables. As
a result, the index into the kernel PGD was going out of bounds and the
kernel hung during early boot.

Allow overrides of pgd_offset_k() and override it on IA-64 with the
old implementation that will correctly index the kernel PGD.

> Fixes: 974b9b2c68 ("mm: consolidate pte_index() and pte_offset_*() definitions")
> Reported-by: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
> Signed-off-by: Jessica Clarke <jrtc27@jrtc27.com>
> Tested-by: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> ---
> Changes since v2:
> * Rephrase commit message and comment about pgd_offset_k()
> 
> Changes since v1:
> * Fixed typo in commit message
> * Slightly reworded commit message to sound less weird
> * Included Adrian's Tested-by
> 
> arch/ia64/include/asm/pgtable.h | 9 +++++++++
> include/linux/pgtable.h         | 2 ++
> 2 files changed, 11 insertions(+)
> 
> diff --git a/arch/ia64/include/asm/pgtable.h b/arch/ia64/include/asm/pgtable.h
> index 10850897a91c..6ef501cd0166 100644
> --- a/arch/ia64/include/asm/pgtable.h
> +++ b/arch/ia64/include/asm/pgtable.h
> @@ -366,6 +366,15 @@ pgd_index (unsigned long address)
> }
> #define pgd_index pgd_index
> 
> +/*
> + * In the kernel's mapped region we know everything is in region number 5, so
> + * as an optimisation its PGD already points to the area for that region.
> + * However, this also means that we cannot use pgd_index() and we never
> + * should add the region here.
> + */

/*
 * In the kernel's mapped region we know everything is in region number 5, so
 * as an optimisation its PGD already points to the area for that region.
 * However, this also means that we cannot use pgd_index() and we must
 * never add the region here.
 */

Jess

> +#define pgd_offset_k(addr) \
> +	(init_mm.pgd + (((addr) >> PGDIR_SHIFT) & (PTRS_PER_PGD - 1)))
> +
> /* Look up a pgd entry in the gate area.  On IA-64, the gate-area
>    resides in the kernel-mapped segment, hence we use pgd_offset_k()
>    here.  */
> diff --git a/include/linux/pgtable.h b/include/linux/pgtable.h
> index a124c21e3204..e8cbc2e795d5 100644
> --- a/include/linux/pgtable.h
> +++ b/include/linux/pgtable.h
> @@ -117,7 +117,9 @@ static inline pgd_t *pgd_offset_pgd(pgd_t *pgd, unsigned long address)
>  * a shortcut which implies the use of the kernel's pgd, instead
>  * of a process's
>  */
> +#ifndef pgd_offset_k
> #define pgd_offset_k(address)		pgd_offset(&init_mm, (address))
> +#endif
> 
> /*
>  * In many cases it is known that a virtual address is mapped at PMD or PTE
> -- 
> 2.26.2
> 
