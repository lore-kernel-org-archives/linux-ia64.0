From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 27 Jul 2007 15:02:23 +0000
Subject: Re: [PATCH] flush cache fixes for ia64 [2/2] sync icache dcache
Message-Id: <20070728000223.31492de4.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070727133657.8c9c6803.kamezawa.hiroyu@jp.fujitsu.com>
	<20070727133936.36b047cd.kamezawa.hiroyu@jp.fujitsu.com>
	<46A9FE3B.7070402@bull.net>
In-Reply-To: <46A9FE3B.7070402@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, tony.luck@intel.com, nickpiggin@yahoo.com.au, clameter@sgi.com

On Fri, 27 Jul 2007 16:16:27 +0200
Zoltan Menyhart <Zoltan.Menyhart@bull.net> wrote:

> Do you really need a "sync_icache_dcache()" in "do_wp_page()"?
> I guess it is only needed when the EXEC bit of the PTE gets turned on.
> 
Ah, sorry. do_wp_page() without page copy (reuse case) doesn't need sync.

About page copy case
There was an issue that Java receives SIGILL because lazy_mmu_prot_update()
is called before set_pte(). Then, Only do_wp_page() calls lazy_mmu_prot_update()
before set_pte().

This is because the kernel allocates a new page with filling its contents by
copy (on cache!) from old page.
Then, do_wp_page() uses page copy needs sync.


> > --- linux-2.6.23-rc1.test.orig/mm/migrate.c
> > +++ linux-2.6.23-rc1.test/mm/migrate.c
> > @@ -172,6 +172,7 @@ static void remove_migration_pte(struct 
> >  	pte = pte_mkold(mk_pte(new, vma->vm_page_prot));
> >  	if (is_write_migration_entry(entry))
> >  		pte = pte_mkwrite(pte);
> > +	flush_icache_page(vma, new);
> >  	set_pte_at(mm, addr, ptep, pte);
> >  
> >  	if (PageAnon(new))
> 
> I think "flush_icache_page()", or rather "flush_cache_page()" is
> to be placed where migration tears down the old virtual --> physical
> address translation for good.
migration uses try_to_unmap() when removing old pte. so it seems safe.
This patch above treats creating new page map case.

Thanks,
-Kame
