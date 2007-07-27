From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Fri, 27 Jul 2007 14:16:27 +0000
Subject: Re: [PATCH] flush cache fixes for ia64 [2/2] sync icache dcache
Message-Id: <46A9FE3B.7070402@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070727133657.8c9c6803.kamezawa.hiroyu@jp.fujitsu.com> <20070727133936.36b047cd.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070727133936.36b047cd.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "tony.luck@intel.com" <tony.luck@intel.com>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, Christoph Lameter <clameter@sgi.com>

Do you really need a "sync_icache_dcache()" in "do_wp_page()"?
I guess it is only needed when the EXEC bit of the PTE gets turned on.

> --- linux-2.6.23-rc1.test.orig/mm/migrate.c
> +++ linux-2.6.23-rc1.test/mm/migrate.c
> @@ -172,6 +172,7 @@ static void remove_migration_pte(struct 
>  	pte = pte_mkold(mk_pte(new, vma->vm_page_prot));
>  	if (is_write_migration_entry(entry))
>  		pte = pte_mkwrite(pte);
> +	flush_icache_page(vma, new);
>  	set_pte_at(mm, addr, ptep, pte);
>  
>  	if (PageAnon(new))

I think "flush_icache_page()", or rather "flush_cache_page()" is
to be placed where migration tears down the old virtual --> physical
address translation for good.

> --- linux-2.6.23-rc1.test.orig/mm/migrate.c
> +++ linux-2.6.23-rc1.test/mm/migrate.c
> @@ -173,6 +173,7 @@ static void remove_migration_pte(struct 
>  	if (is_write_migration_entry(entry))
>  		pte = pte_mkwrite(pte);
>  	flush_icache_page(vma, new);
> +	sync_icache_dcache(pte);
>  	set_pte_at(mm, addr, ptep, pte);

Sure, I can agree to add "sync_icache_dcache()" here.

Thanks,

Zoltan
