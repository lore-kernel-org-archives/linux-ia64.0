From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 17 Mar 2008 16:09:15 +0000
Subject: RE: [2.6.25-rc5-mm1][regression] ia64: hackbench doesn't finish >12 hour
Message-Id: <1FE6DD409037234FAB833C420AA843ECD410F3@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080317200924.7B4C.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080317204810.7B4F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080317204810.7B4F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-ia64@vger.kernel.org, "Yu, Fenghua" <fenghua.yu@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>

> seto-san teach me method of more investigate.
> and I found the root cause is contained by following patch.
>
>   [IA64] Multiple outstanding ptc.g instruction support

Thank you very much for your testing, and for isolating the
cause of this regression.

> 2.6.25-rc5:     works well
> 2.6.25-rc5-mm1: doesn't finish >12 hour

How long does hackbench take to complete on 2.6.25-rc5?
Does -mm1 hang completely?  Or is it making slow progress?

> Could you please revert that patch from ia64?

I'll revert it while I investigate the cause of this
problem and try to find a way to avoid this problem.

> I dislike its strong regression.

Me too!

-Tony
