From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 22 Aug 2007 00:11:29 +0000
Subject: Re: [PATCH][2.6.23-rc2-mm2] small fix for ia64 icache sync patch
Message-Id: <20070822091129.8c300281.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070821201507.36641d76.kamezawa.hiroyu@jp.fujitsu.com>
	<617E1C2C70743745A92448908E030B2A023B2254@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A023B2254@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org

On Tue, 21 Aug 2007 14:12:02 -0700
"Luck, Tony" <tony.luck@intel.com> wrote:

> > +	if (pte_present(pteval) &&// swap out ?
> > +	    pte_exec(pteval) &&    // flush only new executable page.
> > 	    pte_user(pteval) &&    // ignore kernel page
> > 	    (!pte_present(*ptep) ||// do_no_page or swap in, migration,
> > 		pte_pfn(*ptep) != pte_pfn(pteval))) // do_wp_page(), page copy
> 
> David Mosberger was concerned about the increase in code
> size from this inline function.  We can reduce the bloat
> a bit by defining a macro that tests for "present &&
> executable && user-mode" in one go:
> 
> #define pte_pux(pte)            ((pte_val(pte) & (_PAGE_P|_PAGE_PL_MASK|_PAGE_AR_RX)) = \
>                                         (_PAGE_P|_PAGE_PL_3|_PAGE_AR_RX))
> 
Hmm, ok.

> Perhaps there is a better name than "pte_pux"?  I don't know whether
> the code that this generates is faster, but it is smaller (bloat
> is only 3k instead of 4k).
> 
> One last cleanup needed ... don't use C-99/C++ style comments.
> 
ok.

-Kame

