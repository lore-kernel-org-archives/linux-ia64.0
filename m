From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 14 Oct 2004 04:49:40 +0000
Subject: Re: bug in 2.6.9-rc4-mm1 ia64/mm/init.c
Message-Id: <416E0564.9030002@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.33.0410121705510.31839-100000@localhost.localdomain>
 <16748.57721.66330.638048@napali.hpl.hp.com> <416CEADA.2060207@jp.fujitsu.com>
 <16748.60002.875945.950324@napali.hpl.hp.com> <416CEF0E.1060406@jp.fujitsu.com>
In-Reply-To: <416CEF0E.1060406@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: davidm@hpl.hp.com, akepner@sgi.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, jbarnes@sgi.com

Hi Andrew

this patch removes problematic GRANULEROUNDDOWN/GRANULEROUNDUP lines
from 2.6.9-rc4-mm1, arch/ia64m/mm/init.c.

I think aligning memmap patch should be removed now,
and be discussed when it really looks necessary.

Thanks.

Kame <kamezawa.hiroyu@jp.fujitsu.com>

---

  linux-2.6.9-rc4-mm1-kamezawa/arch/ia64/mm/init.c |    2 --
  1 files changed, 2 deletions(-)

diff -puN arch/ia64/mm/init.c~ia64_bugfix arch/ia64/mm/init.c
--- linux-2.6.9-rc4-mm1/arch/ia64/mm/init.c~ia64_bugfix	2004-10-14 07:26:04.283256397 +0900
+++ linux-2.6.9-rc4-mm1-kamezawa/arch/ia64/mm/init.c	2004-10-14 07:26:23.644584285 +0900
@@ -410,8 +410,6 @@ virtual_memmap_init (u64 start, u64 end,
  	struct page *map_start, *map_end;

  	args = (struct memmap_init_callback_data *) arg;
-	start = GRANULEROUNDDOWN(start);
-	end = GRANULEROUNDUP(end);
  	map_start = vmem_map + (__pa(start) >> PAGE_SHIFT);
  	map_end   = vmem_map + (__pa(end) >> PAGE_SHIFT);


_

