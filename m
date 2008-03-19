From: "Yu, Fenghua" <fenghua.yu@intel.com>
Date: Wed, 19 Mar 2008 00:14:39 +0000
Subject: RE: [2.6.25-rc5-mm1][regression] ia64: hackbench doesn't finish >12 hour
Message-Id: <DDF46CB71CB9D647A983FECACF09A886A8A6B5@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080318084314.FF0F.KOSAKI.MOTOHIRO@jp.fujitsu.com> <DDF46CB71CB9D647A983FECACF09A886A33019@orsmsx424.amr.corp.intel.com> <20080318094527.FF12.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080318094527.FF12.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>


>this paramter mean use all physical memory and about 1GB swap space.
>Could you expand swap space?

We can reproduce the soft lockup issue now and root cause the issue as
well.

Since the ptc.g patch uses semaphore ptcg_sem to serialize multiple
ptc.g instructions in ia64_global_tlb_purge(). This requires the code
path should be safe to sleep in down(). But the code path can not sleep
during swap because it holds some spin locks (e.g. anon_vma_lock). Going
to sleep finally causes soft lockup.

Actually we though of this issue before releasing the ptcg patch and
wrote some non-sleeping versions of ptcg patches. But since we couldn't
see the sleeping issue during our testing, we didn't release a
non-sleeping ptcg patch. If replacing the ptcg patch in -mm1 tree with
one of our non-sleeping ptcg patches, the issue goes away.

Tony and I are working on releasing a final ptcg patch to solve the
issue.

Thanks.

-Fenghua
