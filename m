From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 04 Apr 2008 23:52:29 +0000
Subject: RE: [2.6.25-rc5-mm1][regression] ia64: hackbench doesn't finish >12 hour
Message-Id: <1FE6DD409037234FAB833C420AA843EC01011FE8@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080318084314.FF0F.KOSAKI.MOTOHIRO@jp.fujitsu.com> <DDF46CB71CB9D647A983FECACF09A886A33019@orsmsx424.amr.corp.intel.com> <20080318094527.FF12.KOSAKI.MOTOHIRO@jp.fujitsu.com> <DDF46CB71CB9D647A983FECACF09A886A8A6B5@orsmsx424.amr.corp.intel.com>
In-Reply-To: <DDF46CB71CB9D647A983FECACF09A886A8A6B5@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Yu, Fenghua" <fenghua.yu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>

> We can reproduce the soft lockup issue now and root cause the issue as
well.
>
> Since the ptc.g patch uses semaphore ptcg_sem to serialize multiple
> ptc.g instructions in ia64_global_tlb_purge(). This requires the code
> path should be safe to sleep in down(). But the code path can not
> sleep during swap because it holds some spin locks (e.g.
anon_vma_lock).
> Going to sleep finally causes soft lockup.

I've just pushed a new version of this patch into my test tree (so
it will show up in -mm and linux-next when they pull and rebuild).
It now uses the Piggin/Wilcox "spinaphore" primitives.  It passes
all my tests, and some runs of "hackbench" that tried to match the
tests that failed before at Fujitsu by forcing moderate amounts of
swapping.

-Tony
