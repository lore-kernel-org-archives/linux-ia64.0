From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Tue, 18 Mar 2008 00:47:04 +0000
Subject: Re: [2.6.25-rc5-mm1][regression] ia64: hackbench doesn't finish >12 hour
Message-Id: <20080318094527.FF12.KOSAKI.MOTOHIRO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080318084314.FF0F.KOSAKI.MOTOHIRO@jp.fujitsu.com> <DDF46CB71CB9D647A983FECACF09A886A33019@orsmsx424.amr.corp.intel.com>
In-Reply-To: <DDF46CB71CB9D647A983FECACF09A886A33019@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Yu, Fenghua" <fenghua.yu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, "Luck, Tony" <tony.luck@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>

Hi Yu-san,

> > > % ./hackbench 130 process 500
> > > 2.6.25-rc5:     works well
> > > 2.6.25-rc5-mm1: doesn't finish >12 hour
> >cpu: Itanium2 x8
> >mem: 8GB(4GB x2 node)
> 
> On Itanium2x8 w/ 8GB on 1 node, All of 2.6.24, 2.6.25-rc5 and
> 2.6.25-rc5-mm1 shows same "out of memory" within one minute. I haven't
> seen spinlock lockup issue yet.

this paramter mean use all physical memory and about 1GB swap space.
Could you expand swap space?


- kosaki


