From: Brian Gerst <bgerst@didntduck.org>
Date: Tue, 04 Jan 2005 21:21:03 +0000
Subject: Re: page fault scalability patch V14 [5/7]: x86_64 atomic pte operations
Message-Id: <41DB08BF.4000700@didntduck.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.44.0411221457240.2970-100000@localhost.localdomain> <Pine.LNX.4.58.0411221343410.22895@schroedinger.engr.sgi.com> <Pine.LNX.4.58.0411221419440.20993@ppc970.osdl.org> <Pine.LNX.4.58.0411221424580.22895@schroedinger.engr.sgi.com> <Pine.LNX.4.58.0411221429050.20993@ppc970.osdl.org> <Pine.LNX.4.58.0412011539170.5721@schroedinger.engr.sgi.com> <Pine.LNX.4.58.0412011545060.5721@schroedinger.engr.sgi.com> <Pine.LNX.4.58.0501041129030.805@schroedinger.engr.sgi.com> <Pine.LNX.4.58.0501041137410.805@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0501041137410.805@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: Linus Torvalds <torvalds@osdl.org>, Hugh Dickins <hugh@veritas.com>, akpm@osdl.org, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Christoph Lameter wrote:
> Changelog
>         * Provide atomic pte operations for x86_64
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> Index: linux-2.6.10/include/asm-x86_64/pgalloc.h
> =================================> --- linux-2.6.10.orig/include/asm-x86_64/pgalloc.h	2005-01-03 10:31:31.000000000 -0800
> +++ linux-2.6.10/include/asm-x86_64/pgalloc.h	2005-01-03 12:21:28.000000000 -0800
> @@ -7,6 +7,10 @@
>  #include <linux/threads.h>
>  #include <linux/mm.h>
> 
> +#define PMD_NONE 0
> +#define PUD_NONE 0
> +#define PGD_NONE 0
> +
>  #define pmd_populate_kernel(mm, pmd, pte) \
>  		set_pmd(pmd, __pmd(_PAGE_TABLE | __pa(pte)))
>  #define pud_populate(mm, pud, pmd) \
> @@ -14,11 +18,24 @@
>  #define pgd_populate(mm, pgd, pud) \
>  		set_pgd(pgd, __pgd(_PAGE_TABLE | __pa(pud)))
> 
> +#define pmd_test_and_populate(mm, pmd, pte) \
> +		(cmpxchg((int *)pmd, PMD_NONE, _PAGE_TABLE | __pa(pte)) = PMD_NONE)
> +#define pud_test_and_populate(mm, pud, pmd) \
> +		(cmpxchg((int *)pgd, PUD_NONE, _PAGE_TABLE | __pa(pmd)) = PUD_NONE)
                                 ^^^
Shouldn't this be pud?

> +#define pgd_test_and_populate(mm, pgd, pud) \
> +		(cmpxchg((int *)pgd, PGD_NONE, _PAGE_TABLE | __pa(pud)) = PGD_NONE)
> +
> +

--
				Brian Gerst
