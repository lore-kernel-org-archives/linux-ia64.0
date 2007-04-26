From: john stultz <johnstul@us.ibm.com>
Date: Thu, 26 Apr 2007 20:52:47 +0000
Subject: Re: [PATCH 2/3] ia64: remove interpolater code
Message-Id: <1177620767.6031.7.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070426202632.23343.54944.sendpatchset@rambler.zko.hp.com>
	 <20070426202702.23343.10036.sendpatchset@rambler.zko.hp.com>
In-Reply-To: <20070426202702.23343.10036.sendpatchset@rambler.zko.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Keilty <peter.keilty@hp.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Eric Whitney <eric.whitney@hp.com>, davem@davemloft.net

On Thu, 2007-04-26 at 16:27 -0400, Peter Keilty wrote:
> From: Peter Keilty <peter.keilty@hp.com>
> 
> Remove time_interpolator code.
> 
> Signed-off-by: Peter Keilty <peter.keilty@hp.com>
> Signed-off-by: John Stultz <johnstul@us.ibm.com>
> 
> ---
> 
>  include/linux/timex.h |   60 ---------------
>  kernel/time.c         |    1 
>  kernel/timer.c        |  193 --------------------------------------------------
>  3 files changed, 254 deletions(-)

This specific patch may need to be held off until Dave Miller pushes his
SPARC64 GENERIC_TIME conversion (as SPARC64 currently uses the
time_interpolator code). 

I think Dave intends to push it soon, so it shouldn't be a long wait.

thanks
-john


