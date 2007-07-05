From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 05 Jul 2007 22:27:07 +0000
Subject: Re: [BUGFIX][PATCH] DO flush icache before set_pte() on ia64.
Message-Id: <20070706072707.6d71b198.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070704150504.423f6c54.kamezawa.hiroyu@jp.fujitsu.com>
	<20070705181308.GB8320@stroyan.net>
In-Reply-To: <20070705181308.GB8320@stroyan.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Stroyan <mike@stroyan.net>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-mm@kvack.org, clameter@sgi.com, y-goto@jp.fujitsu.com, dmosberger@gmail.com, hugh@veritas.com, nickpiggin@yahoo.com.au

On Thu, 5 Jul 2007 12:13:09 -0600
Mike Stroyan <mike@stroyan.net> wrote:

> You don't seem to have removed the lazy_mmu_prot_update() calls from
> mm/hugetlb.c.  Will that build with HUGETLBFS configured?
> 
Thanks, it's my patch refresh miss... Sigh..

-Kame

