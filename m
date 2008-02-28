From: Ingo Molnar <mingo@elte.hu>
Date: Thu, 28 Feb 2008 19:32:33 +0000
Subject: Re: 2.6.25-rc2-mm1 - boot hangs on ia64
Message-Id: <20080228193233.GA26735@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080227103831.423F.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080227071118.GA4638@elte.hu> <20080228192509.BDCF.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080228115041.GA22082@elte.hu> <20080228101343.1b9548e6.akpm@linux-foundation.org> <20080228191214.GA17872@elte.hu> <20080228112423.fed6add2.akpm@linux-foundation.org>
In-Reply-To: <20080228112423.fed6add2.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, srostedt@redhat.com, Lee.Schermerhorn@hp.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, tony.luck@intel.com, mingo@redhat.com, bob.picco@hp.com, eric.whitney@hp.com


* Andrew Morton <akpm@linux-foundation.org> wrote:

> > > I don't think we shoudl have added that hack in the first place.  
> > > It solves a problem which about three developers hit four times in 
> > > five years but it has made kernel logging less reliable for 
> > > everyone.
> > 
> > well, the problem was ia64, not a problem on x86 or other platforms.
> 
> I am referring to the original change which made klogd wakeups 
> unreliable.

oh, indeed - agreed - i missed the fact that is_locked check is sporadic 
and can cause other CPUs to prevent the wakeup of klogd. I've zapped the 
change.

	Ingo
