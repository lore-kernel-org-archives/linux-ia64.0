From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Sat, 19 Apr 2008 10:04:30 +0000
Subject: [PATCH][trivial][0/2] mm/pagewalk.c break const constraint. take2
Message-Id: <20080419185723.A8F1.KOSAKI.MOTOHIRO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <19f34abd0804190234m190f7ec4ga2a652029a83bab6@mail.gmail.com> <20080419184918.A8EE.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080419184918.A8EE.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Vegard Nossum <vegard.nossum@gmail.com>, Matt Mackall <mpm@selenic.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, dev-etrax@axis.com, "Luck, Tony" <tony.luck@intel.com>, linux-ia64 <linux-ia64@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com

this patch is against 2.6.25


when compile 2.6.25 on ia64, following warnings was outputed.

  CC      mm/pagewalk.o
mm/pagewalk.c: In function 'walk_page_range':
mm/pagewalk.c:111: warning: passing argument 1 of 'pgd_offset' discards qualifiers from p\
ointer target type

the type of mm argument of walk_page_range() is "const struct mm *",
but pgd_offset() on ia64 declare "struct mm*".
cris port has the same problems.

I propse add const to pgd_offset() for solve this problem.

Thanks!


