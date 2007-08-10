From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 10 Aug 2007 22:23:52 +0000
Subject: Re: [PATCH] flush icache before set_pte() on ia64  take9 [2/2]
Message-Id: <20070811072352.6be17307.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070809135311.0676a947.kamezawa.hiroyu@jp.fujitsu.com>
	<20070809135721.08841cd7.kamezawa.hiroyu@jp.fujitsu.com>
	<617E1C2C70743745A92448908E030B2A0224C511@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A0224C511@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, davem@davemloft.net, Zoltan.Menyhart@bull.net, nickpiggin@yahoo.com.au

On Fri, 10 Aug 2007 11:17:30 -0700
"Luck, Tony" <tony.luck@intel.com> wrote:

> 1) In arch/ia64/mm/init.c: __ia64_sync_icache_dcache()
> 
> -	if (!pte_exec(pte))
> -		return;				/* not an executable page... */
> +	BUG_ON(!pte_exec(pte));
> 
> In this latest version the only route to this routine is from set_pte()
> inside the test :
> 
> 	if (pte_exec(pteval) && ....) {
> 	}
> 
> So this BUG_ON is now redundant.
> 
I see.

> 2) In include/asm-ia64/pgtable.h
> 
> +	if (pte_exec(pteval) &&    // flush only new executable page.
> +	    pte_present(pteval) && // swap out ?
> +	    pte_user(pteval) &&    // ignore kernel page
> +	    (!pte_present(*ptep) ||// do_no_page or swap in, migration,
> +		pte_pfn(*ptep) != pte_pfn(pteval))) // do_wp_page(), page copy
> +		/* load_module() calles flush_icache_range() explicitly*/
> +		__ia64_sync_icache_dcache(pteval);
> 
> Just above this there is a comment saying that pte_exec() only works
> when pte_present() is true.  So we must re-order the conditions so that
> we check that the pteval satisfies pte_present() before using either of
> pte_exec() or pte_user() on it like this:
> 
> 	if (pte_present(pteval) &&
>           pte_exec(pteval) &&
>           pte_user(pteval) &&
> 
> I put in some crude counters to see whether we should check pte_exec() or
> pte_user() next ... and it was very clear that the pte_exec() check gets
> us out of the if() faster (at least during a kernel build).
> 
ok.

I'm sorry that I'll be offlined until next Wednesday. So, I'll post above
fix in a week or so.


> I also compared how often the old code called lazy_mmu_prot_update()
> with how often the new code calls __ia64_sync_icache_dcache() (again
> using kernel build as my workload) ... and the answer is about the
> same (less than 0.2% change ... probably less than run-to-run variation).
> 
> 
> So now the only remaining task is to convince myself that this
> new version covers all the cases.
> 
yes. I want more eyes for review. 

Thanks,
-Kame

