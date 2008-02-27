From: Ingo Molnar <mingo@elte.hu>
Date: Wed, 27 Feb 2008 07:11:19 +0000
Subject: Re: 2.6.25-rc2-mm1 - boot hangs on ia64
Message-Id: <20080227071118.GA4638@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080226202308.FF40.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080226113138.GC10996@elte.hu> <20080227103831.423F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080227103831.423F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-ia64 <linux-ia64@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Ingo Molnar <mingo@redhat.com>, Bob Picco <bob.picco@hp.com>, Eric Whitney <eric.whitney@hp.com>


* KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > hm, that's a bit weird - nothing really should have broken it. Could you 
> > try to do a specific bisection of sched-devel.git:
> > 
> >    http://people.redhat.com/mingo/sched-devel.git/README
> 
> How do I know revision of git-sched.patch of 2.6.25-rc2-mm1? Should I 
> do bisect from HEAD of sched-devel.git?

yeah, please. If it's caused by sched-devel.git then you should see the 
hang there too.

	Ingo
