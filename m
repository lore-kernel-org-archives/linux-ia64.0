From: Matthew Wilcox <willy@infradead.org>
Date: Fri, 03 Mar 2023 14:36:10 +0000
Subject: Re: [PATCH v3 11/34] ia64: Implement the new page table range API
Message-Id: <ZAIF2t8HxjUm/45d@casper.infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230228213738.272178-1-willy@infradead.org>
 <20230228213738.272178-12-willy@infradead.org>
 <ZAHgdEzqWk4Peyjh@kernel.org>
In-Reply-To: <ZAHgdEzqWk4Peyjh@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Rapoport <rppt@kernel.org>
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Fri, Mar 03, 2023 at 01:56:36PM +0200, Mike Rapoport wrote:
> On Tue, Feb 28, 2023 at 09:37:14PM +0000, Matthew Wilcox (Oracle) wrote:
> >  void arch_dma_mark_clean(phys_addr_t paddr, size_t size)
> >  {
> > -	unsigned long pfn = PHYS_PFN(paddr);
> > +	struct folio *folio = page_folio(phys_to_page(paddr));
> > +	ssize_t left = size;
> > +	size_t offset = offset_in_folio(folio, paddr);
> 
> Build of defconfig failed miserably for me without this:
> 
> diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
> index 12aef25944aa..0775e7870257 100644
> --- a/arch/ia64/mm/init.c
> +++ b/arch/ia64/mm/init.c
> @@ -69,7 +69,8 @@ __ia64_sync_icache_dcache (pte_t pte)
>   */
>  void arch_dma_mark_clean(phys_addr_t paddr, size_t size)
>  {
> -	struct folio *folio = page_folio(phys_to_page(paddr));
> +	unsigned long pfn = __phys_to_pfn(paddr);
> +	struct folio *folio = page_folio(pfn_to_page(pfn));

Huh, TIL that only some architectures have phys_to_page().  Thanks.
I'm going to use PHYS_PFN instead of __phys_to_pfn just to reduce the
diff.
