From: john stultz <johnstul@us.ibm.com>
Date: Fri, 13 Feb 2004 02:29:35 +0000
Subject: Re: [RFC][PATCH] linux-2.6.3-rc2_ia64-cyclone_A0
Message-Id: <1076639375.8386.101.camel@cog.beaverton.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1076556140.795.119.camel@cog.beaverton.ibm.com>
In-Reply-To: <1076556140.795.119.camel@cog.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2004-02-12 at 17:16, David Mosberger wrote:
> >>>>> On Thu, 12 Feb 2004 17:05:50 -0800, john stultz <johnstul@us.ibm.com> said:
> 
>   John> Hmm. As cyclone is only enabled for x450/x455 systems, I'm not
>   John> sure if that additional check is necessary, but I'll try to
>   John> look into that.
> 
> At the very least, verify that the SAL ITCdrift bit is turned on by
> the firmware.  Otherwise, the lightweight handler of gettimeofday()
> will still use ITC-based interpolation.

I'm not sure I see how gettimeofday will use ITC based interpolation if
the ITCdrift is off. Sure, the ITC will register a timesource, but
init_cyclone_clock runs after time_init and has a negative drift value,
so on the x450/x455 the cyclone interpolator will be used. 

Am I missing something?

thanks
-john


