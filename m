From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Wed, 27 Feb 2008 01:42:22 +0000
Subject: Re: 2.6.25-rc2-mm1 - boot hangs on ia64
Message-Id: <20080227103831.423F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080226202308.FF40.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080226113138.GC10996@elte.hu>
In-Reply-To: <20080226113138.GC10996@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>
Cc: kosaki.motohiro@jp.fujitsu.com, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-ia64 <linux-ia64@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Ingo Molnar <mingo@redhat.com>, Bob Picco <bob.picco@hp.com>, Eric Whitney <eric.whitney@hp.com>

Hi Ingo

> > Fujitsu machine can't boot too. my bisect indicate git-sched.patch 
> > cause regression too.
> 
> hm, that's a bit weird - nothing really should have broken it. Could you 
> try to do a specific bisection of sched-devel.git:
> 
>    http://people.redhat.com/mingo/sched-devel.git/README

How do I know revision of git-sched.patch of 2.6.25-rc2-mm1?
Should I do bisect from HEAD of sched-devel.git?

> it's just a handful of commits so it should be relatively quick to 
> figure out. My only guess would be:
> 
>   Subject: sched: make early bootup sched_clock() use safer
> 
> but i think this has been ruled out before ...

rc2-mm1 + that patch doesn't boot too.
stop at the same point ;)



