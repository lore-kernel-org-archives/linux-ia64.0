From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Thu, 26 Jul 2007 16:25:55 +0000
Subject: Re: [PATCH] flush icache before set_pte on ia64 take3
Message-Id: <46A8CB13.1020306@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070726171323.a9c17eda.kamezawa.hiroyu@jp.fujitsu.com>	<46A8BA30.7000508@bull.net> <20070727010825.a5934cb0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070727010825.a5934cb0.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, nickpiggin@yahoo.com.au

KAMEZAWA Hiroyuki wrote:

> Thank you for advise. Hmm..how about this ?
> =
>  /*
>   * synchronize icache and dcache if the hardware doesn't do it automatically
>   * and the page is executable.
>   */
> static inline arch_sync_icache_dcache(pte_t pte, page) {
> 
> }

Why not?

I just wanted to see if you change the existing interface or not.

Thanks,

Zoltan
