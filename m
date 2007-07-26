From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 26 Jul 2007 16:08:25 +0000
Subject: Re: [PATCH] flush icache before set_pte on ia64 take3
Message-Id: <20070727010825.a5934cb0.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070726171323.a9c17eda.kamezawa.hiroyu@jp.fujitsu.com>
	<46A8BA30.7000508@bull.net>
In-Reply-To: <46A8BA30.7000508@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Cc: tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, nickpiggin@yahoo.com.au

On Thu, 26 Jul 2007 17:13:52 +0200
Zoltan Menyhart <Zoltan.Menyhart@bull.net> wrote:

> I can agree:
> - lazy_mmu_prot_update() is not the right place for a flush
> - to flush I-cache before inserting PTE (at least for the
>   machines with physical address tagged caches)
> 
> Can we have a separate, specific exec_flush_phtag_icache_page()
> that is to be called before inserting a PTE with the exec bit on
> for physical address tagged I-caches) ?
> It is defined in asm-generic/cacheflush.h as NO-OP.
> 
> Or exec_flush_icache_page_before_set_pte() ?
> 
Thank you for advise. Hmm..how about this ?
=
 /*
  * synchronize icache and dcache if the hardware doesn't do it automatically
  * and the page is executable.
  */
static inline arch_sync_icache_dcache(pte_t pte, page) {

}
=

Anyway, I understand your point. Thanks!

Regards,
- Kame
