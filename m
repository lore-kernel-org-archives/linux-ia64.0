From: Randy Dunlap <rdunlap@infradead.org>
Date: Sat, 13 Mar 2021 04:59:37 +0000
Subject: Re: [PATCH] ia64: include: asm: Minor typo fixes in the file pgtable.h
Message-Id: <8804bf7a-6fb9-6eff-2461-f1a31e444ac7@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210313045519.9310-1-unixbhaskar@gmail.com>
In-Reply-To: <20210313045519.9310-1-unixbhaskar@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bhaskar Chowdhury <unixbhaskar@gmail.com>, rppt@kernel.org, akpm@linux-foundation.org, deller@gmx.de, shorne@gmail.com, anshuman.khandual@arm.com, jrtc27@jrtc27.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On 3/12/21 8:55 PM, Bhaskar Chowdhury wrote:
> 
> s/migraton/migration/
> 
> Signed-off-by: Bhaskar Chowdhury <unixbhaskar@gmail.com>

Acked-by: Randy Dunlap <rdunlap@infradead.org>


> ---
>  arch/ia64/include/asm/pgtable.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/arch/ia64/include/asm/pgtable.h b/arch/ia64/include/asm/pgtable.h
> index 9b4efe89e62d..00a76ed7e018 100644
> --- a/arch/ia64/include/asm/pgtable.h
> +++ b/arch/ia64/include/asm/pgtable.h
> @@ -328,7 +328,7 @@ extern void __ia64_sync_icache_dcache(pte_t pteval);
>  static inline void set_pte(pte_t *ptep, pte_t pteval)
>  {
>  	/* page is present && page is user  && page is executable
> -	 * && (page swapin or new page or page migraton
> +	 * && (page swapin or new page or page migration
>  	 *	|| copy_on_write with page copying.)
>  	 */
>  	if (pte_present_exec_user(pteval) &&
> --


-- 
~Randy
