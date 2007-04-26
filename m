From: john stultz <johnstul@us.ibm.com>
Date: Thu, 26 Apr 2007 20:48:41 +0000
Subject: Re: [PATCH 1/3] ia64: convert to use clocksource code
Message-Id: <1177620521.6031.2.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070426202632.23343.54944.sendpatchset@rambler.zko.hp.com>
	 <20070426204146.GA25142@uranus.ravnborg.org>
In-Reply-To: <20070426204146.GA25142@uranus.ravnborg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sam Ravnborg <sam@ravnborg.org>
Cc: Peter Keilty <peter.keilty@hp.com>, linux-ia64@vger.kernel.org, Eric Whitney <eric.whitney@hp.com>, linux-kernel@vger.kernel.org

On Thu, 2007-04-26 at 22:41 +0200, Sam Ravnborg wrote:
> On Thu, Apr 26, 2007 at 04:26:32PM -0400, Peter Keilty wrote:
> > From: Peter Keilty <peter.keilty@hp.com>
> > 
> > Initial ia64 conversion to the generic timekeeping/clocksource code.
> > 
> > Signed-off-by: Peter Keilty <peter.keilty@hp.com>
> > Signed-off-by: John Stultz <johnstul@us.ibm.com>
> 
> The "Signed-off-by:" should reflect the order in which a path is processed
> with the last submitter at the bottom of the list.
> So if this patch came from John then he should be first in the list
> and since the patch passes you and you submit it you should be in the bottom
> of the list.
> 
> And "Signed-off-by:" tell the path that the patch takes. It is not to be used
> to let others say "I have seen it and I think the patch is ok".
> For the latter we have "Acked-by:".

Yea. Its a little odd in this case, because Peter sent me the signed off
code, then I've made tweaks to it and signed it off, then peter picked
that up and has made further improvements.

So I don't think it is inaccurate, but I see how it could be confusing.
Maybe Peter should add an extra signed-off so its more clear?

thanks
-john




