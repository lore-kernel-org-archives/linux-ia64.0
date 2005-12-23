From: Zwane Mwaikambo <zwane@arm.linux.org.uk>
Date: Fri, 23 Dec 2005 05:58:51 +0000
Subject: Re: [PATCH] ia64: disable preemption in udelay()
Message-Id: <Pine.LNX.4.64.0512222202190.3822@montezuma.fsmlabs.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <8270.1135296864@kao2.melbourne.sgi.com>
In-Reply-To: <8270.1135296864@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Keith Owens <kaos@sgi.com>
Cc: Bill Davidsen <davidsen@tmr.com>, Lee Revell <rlrevell@joe-job.com>, "Luck, Tony" <tony.luck@intel.com>, Tony Luck <tony.luck@gmail.com>, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Jack Steiner <steiner@sgi.com>, Dimitri Sivanich <sivanich@sgi.com>

On Fri, 23 Dec 2005, Keith Owens wrote:

> Agreed.  See [RFC] Add thread_info flag for "no cpu migration"[1] on
> lkml.  It got no response.
> 
> [1] http://marc.theaimsgroup.com/?l=linux-kernel&m3471059115107&w=2

I read it and it would make fixing cpuhotplug + cpufreq also easier. 
However you could also argue that the whole locking in cpufreq should be 
fixed instead.
