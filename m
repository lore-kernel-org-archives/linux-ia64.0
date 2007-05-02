From: john stultz <johnstul@us.ibm.com>
Date: Wed, 02 May 2007 17:50:01 +0000
Subject: Re: [PATCH 1/3] ia64: convert to use clocksource code
Message-Id: <1178128202.6183.1.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070426202632.23343.54944.sendpatchset@rambler.zko.hp.com>
	 <1177622301.6031.16.camel@localhost.localdomain>  <4631F26D.7080404@hp.com>
In-Reply-To: <4631F26D.7080404@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Keilty <peter.keilty@hp.com>
Cc: linux-ia64@vger.kernel.org, Eric Whitney <eric.whitney@hp.com>, linux-kernel@vger.kernel.org

On Fri, 2007-04-27 at 08:54 -0400, Peter Keilty wrote:
> john stultz wrote:
> >On Thu, 2007-04-26 at 16:26 -0400, Peter Keilty wrote:
> >>From: Peter Keilty <peter.keilty@hp.com>
> >>
> >>Initial ia64 conversion to the generic timekeeping/clocksource code.
> >>
> >>Signed-off-by: Peter Keilty <peter.keilty@hp.com>
> >>Signed-off-by: John Stultz <johnstul@us.ibm.com>
> >>    
> >	Thanks so much for pushing this on! I suspect this patch needs to be
> >updated a touch, as I'm not sure if it still compiles in light of recent
> >changes...
> >
> You are correct, you need patch 3/3 for it to compile and run.
> I did a patch to the orginal patch, thought that was correct thing to do.
> But I can make a new patch 1 from the orginal of ours and my #3.
> I would also make an update to the #2 patch from #3 for ntp correct change.
> That would be just 2 patches then, the enable_ia64 and remove_interpolater.
> What do you think?

Yep. That sounds like the right path to me. Its a good idea to make sure
your patch set compiles each step of the way, so later folks can
properly bisect through it looking for other issues.

thanks
-john




