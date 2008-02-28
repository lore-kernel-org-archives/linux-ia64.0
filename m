From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Thu, 28 Feb 2008 12:13:39 +0000
Subject: Re: 2.6.25-rc2-mm1 - boot hangs on ia64
Message-Id: <20080228211044.BDD5.KOSAKI.MOTOHIRO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080228192509.BDCF.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080228115041.GA22082@elte.hu>
In-Reply-To: <20080228115041.GA22082@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>
Cc: kosaki.motohiro@jp.fujitsu.com, Steven Rostedt <srostedt@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-ia64 <linux-ia64@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Ingo Molnar <mingo@redhat.com>, Bob Picco <bob.picco@hp.com>, Eric Whitney <eric.whitney@hp.com>

Hi Ingo,

> thanks for bisecting it down! Could ia64 have trouble accessing the 
> percpu data structures of the scheduler?
> 
> does the patch below resolve the hang?

Thanks!
that patch works well on my test environment.

Tested-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


BTW: Your work is ultimate fast. it's wonderful :)




