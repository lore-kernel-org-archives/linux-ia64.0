From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 19 Mar 2008 23:23:59 +0000
Subject: RE: [2.6.25-rc5-mm1][regression] ia64: hackbench doesn't finish
Message-Id: <1205969039.6437.44.camel@lappy>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080318084314.FF0F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <DDF46CB71CB9D647A983FECACF09A886A33019@orsmsx424.amr.corp.intel.com>
	 <20080318094527.FF12.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <DDF46CB71CB9D647A983FECACF09A886A8A6B5@orsmsx424.amr.corp.intel.com>
In-Reply-To: <DDF46CB71CB9D647A983FECACF09A886A8A6B5@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Yu, Fenghua" <fenghua.yu@intel.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Luck, Tony" <tony.luck@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, 2008-03-18 at 17:14 -0700, Yu, Fenghua wrote:
> >this paramter mean use all physical memory and about 1GB swap space.
> >Could you expand swap space?
> 
> We can reproduce the soft lockup issue now and root cause the issue as
> well.
> 
> Since the ptc.g patch uses semaphore ptcg_sem to serialize multiple
> ptc.g instructions in ia64_global_tlb_purge(). This requires the code
> path should be safe to sleep in down(). But the code path can not sleep
> during swap because it holds some spin locks (e.g. anon_vma_lock). Going
> to sleep finally causes soft lockup.
> 
> Actually we though of this issue before releasing the ptcg patch and
> wrote some non-sleeping versions of ptcg patches. But since we couldn't
> see the sleeping issue during our testing, we didn't release a
> non-sleeping ptcg patch. If replacing the ptcg patch in -mm1 tree with
> one of our non-sleeping ptcg patches, the issue goes away.
> 
> Tony and I are working on releasing a final ptcg patch to solve the
> issue.

Which makes me wonder, why did you ever use a semaphore here? Looking at
the code its a straight forward mutex. And when you would have used a
mutex lockdep would have warned about this.

There is hardly ever a good reason to use semaphores in new code, we're
trying very hard to get rid of them.

Hmm, then again, does ia64 have lockdep?

