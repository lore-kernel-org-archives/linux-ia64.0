From: "Yu, Fenghua" <fenghua.yu@intel.com>
Date: Wed, 19 Mar 2008 23:50:28 +0000
Subject: RE: [2.6.25-rc5-mm1][regression] ia64: hackbench doesn't finish>12 hour
Message-Id: <DDF46CB71CB9D647A983FECACF09A886A8AEB4@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080318084314.FF0F.KOSAKI.MOTOHIRO@jp.fujitsu.com> <DDF46CB71CB9D647A983FECACF09A886A33019@orsmsx424.amr.corp.intel.com> <20080318094527.FF12.KOSAKI.MOTOHIRO@jp.fujitsu.com> <DDF46CB71CB9D647A983FECACF09A886A8A6B5@orsmsx424.amr.corp.intel.com> <1205969039.6437.44.camel@lappy>
In-Reply-To: <1205969039.6437.44.camel@lappy>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Luck, Tony" <tony.luck@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>


>Which makes me wonder, why did you ever use a semaphore here? Looking
at
>the code its a straight forward mutex. And when you would have used a
>mutex lockdep would have warned about this.

>There is hardly ever a good reason to use semaphores in new code, we're
>trying very hard to get rid of them.

The real issue here is the code path can not go to sleep. If simply 
replacing semaphore with mutex, the issue still happens. First of all we

need to have a lock system which doesn't allow the code go to sleep. We
are 
working on a new patch now.

But one step back, if without considering this sleeping issue, I agree
with 
you that mutex would be a better approach than semaphore.

>Hmm, then again, does ia64 have lockdep?

IA64 doesn't support lockdep yet.

Thanks.

-Fenghua
