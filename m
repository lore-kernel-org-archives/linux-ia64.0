From: Mike Rapoport <rppt@linux.ibm.com>
Date: Tue, 11 Aug 2020 20:13:52 +0000
Subject: Re: [PATCH v2] arch/ia64: Restore arch-specific pgd_offset_k implementation
Message-Id: <20200811201352.GY163101@linux.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <fe587e09-2835-87b9-ceed-89cdb81f327c@physik.fu-berlin.de>
 <fa71f38e-b191-597a-6359-502cba197050@physik.fu-berlin.de>
 <AA5E212C-56ED-4DB9-9CC1-EB13745DD5AF@jrtc27.com>
 <20200811182457.57957-1-jrtc27@jrtc27.com>
In-Reply-To: <20200811182457.57957-1-jrtc27@jrtc27.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jessica Clarke <jrtc27@jrtc27.com>
Cc: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, Tony Luck <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Anatoly Pugachev <matorola@gmail.com>, Sergei Trofimovich <slyfox@gentoo.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Frank Scheiner <frank.scheiner@web.de>

On Tue, Aug 11, 2020 at 07:24:57PM +0100, Jessica Clarke wrote:
> IA-64 is special and treats pgd_offset_k differently from pgd_offset by
> not including the region number, and init_mm's PGD is such that it only
> points to the kernel's region's PGD. This was broken in 974b9b2c68 which
> unified the two and therefore included the region number, causing it to
> go way out of bounds of the kernel's PGD, which made the kernel hang
> during early boot. Thus, permit pgd_offset_k to be overridden like the
> other macros and override it on IA-64 with the old implementation. Also
> update the comment to clarify that this is not just an optimisation but
> a required implementation detail.

If I may suggest:

IA-64 is special and treats pgd_offset_k() differently from pgd_offset() by
using different formulas to calculate index into kernel and user PGD
tables. The index into user PGDs takes into account the region number
and the index into the kernel (init_mm) PGD always presumes predefined
kernel region number. Commit 974b9b2c68 ("mm: consolidate pte_index()
and pte_offset_*() definitions") made IA-64 to use generic
pgd_offset_k() which wrongly used pgd_index() for user page tables. As
the result, the index into kernel PGD was going out of bounds and the
kernel hang during early boot.

Allow overrides of pgd_offset_k() and use an override on IA-64 with the
old implementation that will correctly index kernel PGD.

> Fixes: 974b9b2c68 ("mm: consolidate pte_index() and pte_offset_*() definitions")
> Reported-by: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
> Signed-off-by: Jessica Clarke <jrtc27@jrtc27.com>
> Tested-by: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>

Thanks for the fix, I don't insist on the changelog update, so with the
nit below

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>

> ---
> Changes since v1:
>  * Fixed typo in commit message
>  * Slightly reworded commit message to sound less weird
>  * Included Adrian's Tested-by
> 
>  arch/ia64/include/asm/pgtable.h | 8 ++++++++
>  include/linux/pgtable.h         | 2 ++
>  2 files changed, 10 insertions(+)
> 
> diff --git a/arch/ia64/include/asm/pgtable.h b/arch/ia64/include/asm/pgtable.h
> index 10850897a91c..2ac2199d99ce 100644
> --- a/arch/ia64/include/asm/pgtable.h
> +++ b/arch/ia64/include/asm/pgtable.h
> @@ -366,6 +366,14 @@ pgd_index (unsigned long address)
>  }
>  #define pgd_index pgd_index
>  
> +/*
> + * In the kernel's mapped region we know everything is in region number 5, so
> + * as an optimisation its PGD already points to the area for that region, but
> + * that means not adding the region here is required, not just an optimisation.
> + */

How about:

/*
 * In the kernel's mapped region we know everything is in region number 5, so
 * as an optimisation its PGD already points to the area for that region.
 * However, this also means that we cannot use pgd_index() and we never
 * should add the region here.
 */

> +#define pgd_offset_k(addr) \
> +	(init_mm.pgd + (((addr) >> PGDIR_SHIFT) & (PTRS_PER_PGD - 1)))
> +
>  /* Look up a pgd entry in the gate area.  On IA-64, the gate-area
>     resides in the kernel-mapped segment, hence we use pgd_offset_k()
>     here.  */
> diff --git a/include/linux/pgtable.h b/include/linux/pgtable.h
> index 53e97da1e8e2..73c64fe098ba 100644
> --- a/include/linux/pgtable.h
> +++ b/include/linux/pgtable.h
> @@ -117,7 +117,9 @@ static inline pgd_t *pgd_offset_pgd(pgd_t *pgd, unsigned long address)
>   * a shortcut which implies the use of the kernel's pgd, instead
>   * of a process's
>   */
> +#ifndef pgd_offset_k
>  #define pgd_offset_k(address)		pgd_offset(&init_mm, (address))
> +#endif
>  
>  /*
>   * In many cases it is known that a virtual address is mapped at PMD or PTE
> -- 
> 2.23.0
> 

-- 
Sincerely yours,
Mike.
