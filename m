From: David Miller <davem@davemloft.net>
Date: Thu, 09 Aug 2007 05:08:38 +0000
Subject: Re: [PATCH] flush icache before set_pte() on ia64 take9 [2/2]
Message-Id: <20070808.220838.88002572.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070809135311.0676a947.kamezawa.hiroyu@jp.fujitsu.com>
	<20070809135721.08841cd7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070809135721.08841cd7.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, tony.luck@intel.com, Zoltan.Menyhart@bull.net, nickpiggin@yahoo.com.au

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 9 Aug 2007 13:57:21 +0900

> Changelog v8 -> v9.
>  - removed sync_icache_dcache().
>  - modified set_pte() rather than adding new complexed macro.
> 
> Old stories
>  - For synching icache and dcache before set_pte(), I added a new macro for
>    ia64, sync_icache_dcache(). I inserted it in proper places.
>    Comments from reviewer was negative becasue ia64 specific codes are
>    scattered over vm codes and it will not be able to be maintained.
>    An advice was hide all in set_pte() because flush_xxx_cache cannot pass
>    enough information to arch.
> 
> Current ia64 kernel flushes icache by lazy_mmu_prot_update() *after*
> set_pte(). This is too late. This patch removes lazy_mmu_prot_update and
> add modfied set_pte() for flushing if necessary.
> 
> This patch flush icache of a page when
> 	new pte has exec bit.
> 	&& new pte has present bit
> 	&& new pte is user's page.
> 	&& (old *ptep is not present 
>             || new pte's pfn is not same to old *ptep's ptn)
> 	&& new pte's page has no Pg_arch_1 bit.
> 	   Pg_arch_1 is set when a page is cache consistent.
> 
> I think this condition checks are much easier to understand than considering
> "Where sync_icache_dcache() should be inserted ?".
> 
> pte_user() for ia64 was removed by http://lkml.org/lkml/2007/6/12/67 as
> clean-up. So, I added it again.
> 
> Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

If this patch works I am very happy with it, since lazy_mmu_prot_update()
is now completely gone as a result.

Acked-by: David S. Miller <davem@davemloft.net>
