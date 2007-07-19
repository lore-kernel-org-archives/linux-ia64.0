From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 19 Jul 2007 06:56:32 +0000
Subject: Re: [BUGFIX]{PATCH] flush icache on ia64 take2
Message-Id: <20070719155632.7dbfb110.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070706112901.16bb5f8a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070706112901.16bb5f8a.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "tony.luck@intel.com" <tony.luck@intel.com>, nickpiggin@yahoo.com.au, mike@stroyan.net, Zoltan.Menyhart@bull.net, dmosberger@gmail.com, GOTO <y-goto@jp.fujitsu.com>

On Fri, 6 Jul 2007 11:29:01 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> This is a patch for fixing icache flush race in ia64(Montecito) by implementing
> flush_icache_page() at el.
> 
> Changelog:
>  - updated against 2.6.22-rc7 (previous one was against 2.6.21)
>  - removed hugetlbe's lazy_mmu_prot_update().
>  - rewrote patch description.
>  - removed patch against mprotect() if flushes cache.
> 
Then, what should I do more for fixing this SIGILL problem ?

-Kame

