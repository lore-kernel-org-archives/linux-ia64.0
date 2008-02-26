From: Ingo Molnar <mingo@elte.hu>
Date: Tue, 26 Feb 2008 11:31:38 +0000
Subject: Re: 2.6.25-rc2-mm1 - boot hangs on ia64
Message-Id: <20080226113138.GC10996@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <1203955017.5046.29.camel@localhost> <20080226202308.FF40.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080226202308.FF40.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-ia64 <linux-ia64@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Ingo Molnar <mingo@redhat.com>, Bob Picco <bob.picco@hp.com>, Eric Whitney <eric.whitney@hp.com>


* KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> Fujitsu machine can't boot too. my bisect indicate git-sched.patch 
> cause regression too.

hm, that's a bit weird - nothing really should have broken it. Could you 
try to do a specific bisection of sched-devel.git:

   http://people.redhat.com/mingo/sched-devel.git/README

it's just a handful of commits so it should be relatively quick to 
figure out. My only guess would be:

  Subject: sched: make early bootup sched_clock() use safer

but i think this has been ruled out before ...

	Ingo
