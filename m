From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 17 Mar 2008 17:38:18 +0000
Subject: RE: [2.6.25-rc5-mm1][regression] ia64: hackbench doesn't finish >12 hour
Message-Id: <1FE6DD409037234FAB833C420AA843ECD412F8@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080317200924.7B4C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080317200924.7B4C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, "Yu, Fenghua" <fenghua.yu@intel.com>, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>

> % ./hackbench 130 process 500

I'd like to reproduce your results so I can make a new
version of the ptc.g patch that doesn't have this regression.

I found this version (that claims to be the latest) of hackbench.c

http://people.redhat.com/mingo/cfs-scheduler/tools/hackbench.c

Is this the one you used?


What was the configuration of your machine (how many cpus, how
much memory)?

Thanks

-Tony
