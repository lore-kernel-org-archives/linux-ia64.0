From: "David Mosberger-Tang" <dmosberger@gmail.com>
Date: Fri, 10 Aug 2007 18:46:36 +0000
Subject: Re: [PATCH] flush icache before set_pte() on ia64 take9 [2/2] flush icache at set_pte
Message-Id: <ed5aea430708101146w3c08b499g99317930c7ecbd79@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070809135311.0676a947.kamezawa.hiroyu@jp.fujitsu.com>
	 <20070809135721.08841cd7.kamezawa.hiroyu@jp.fujitsu.com>
	 <617E1C2C70743745A92448908E030B2A0224C511@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A0224C511@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, davem@davemloft.net, Zoltan.Menyhart@bull.net, nickpiggin@yahoo.com.au

On 8/10/07, Luck, Tony <tony.luck@intel.com> wrote:

> +       if (pte_exec(pteval) &&    // flush only new executable page.
> +           pte_present(pteval) && // swap out ?
> +           pte_user(pteval) &&    // ignore kernel page
> +           (!pte_present(*ptep) ||// do_no_page or swap in, migration,
> +               pte_pfn(*ptep) != pte_pfn(pteval))) // do_wp_page(), page copy
> +               /* load_module() calles flush_icache_range() explicitly*/
> +               __ia64_sync_icache_dcache(pteval);
>

> So now the only remaining task is to convince myself that this
> new version covers all the cases.

What about code-size?

Also, is it OK to call a function from all places where a set_pte() is
being done?  I'd hope so, but it's a really low-level operation...

  --david
-- 
Mosberger Consulting LLC, http://www.mosberger-consulting.com/
