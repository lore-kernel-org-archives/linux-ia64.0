From: Pavel Machek <pavel@ucw.cz>
Date: Sat, 25 Oct 2003 20:10:10 +0000
Subject: Re: [PATCH 2.4.23-pre8]  Remove broken prefetching in free_one_pgd()
Message-Id: <marc-linux-ia64-106711263906907@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106702916015259@msgid-missing>
In-Reply-To: <marc-linux-ia64-106702916015259@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi!

> This patch was accepted into 2.5.55, attributed to "davej@uk".

Dave Jones?n

> This code will prefetch from beyond the end of the page table
> being cleared ... which is clearly a bad thing if the page table
> in question is allocated from the last page of memory (or precedes
> a hole on a discontig mem system).

Prefetching random addresses should be safe... Well for 2.4 we
probably want to play it safe and kill it, but I guess quite a few
pieces rely on prefretch(NULL) doing nothing...


> diff -ru linux-2.4.23-pre8/mm/memory.c fix/mm/memory.c
> --- linux-2.4.23-pre8/mm/memory.c	Fri Oct 24 13:37:23 2003
> +++ fix/mm/memory.c	Fri Oct 24 13:40:47 2003
> @@ -120,10 +120,8 @@
>  	}
>  	pmd = pmd_offset(dir, 0);
>  	pgd_clear(dir);
> -	for (j = 0; j < PTRS_PER_PMD ; j++) {
> -		prefetchw(pmd+j+(PREFETCH_STRIDE/16));
> +	for (j = 0; j < PTRS_PER_PMD ; j++)
>  		free_one_pmd(pmd+j);
> -	}
>  	pmd_free(pmd);
>  }


-- 
When do you have a heart between your knees?
[Johanka's followup: and *two* hearts?]
