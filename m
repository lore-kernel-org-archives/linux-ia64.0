From: john stultz <johnstul@us.ibm.com>
Date: Tue, 17 Feb 2004 02:46:58 +0000
Subject: Re: [RFC][PATCH] linux-2.6.3-rc2_ia64-cyclone_A0
Message-Id: <1076986018.8386.226.camel@cog.beaverton.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1076556140.795.119.camel@cog.beaverton.ibm.com>
In-Reply-To: <1076556140.795.119.camel@cog.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2004-02-12 at 23:09, David Mosberger wrote:
> >>>>> On Thu, 12 Feb 2004 18:29:35 -0800, john stultz <johnstul@us.ibm.com> said:
> 
>   John> I'm not sure I see how gettimeofday will use ITC based
>   John> interpolation if the ITCdrift is off. Sure, the ITC will
>   John> register a timesource, but init_cyclone_clock runs after
>   John> time_init and has a negative drift value, so on the x450/x455
>   John> the cyclone interpolator will be used.
> 
>   John> Am I missing something?
> 
> Yes: it's the _lightweight_ gettimeofday() handler that will get
> you.  See arch/ia64/kernel/fsys.S:fsys_gettimeofday().
> 
> To date no distribution ships with light-weight syscall supported
> enabled, but the support is in the current glibc, so it's only a
> matter of time before this would start to bite.

Ah! Thanks for the pointer! I wouldn't have caught that otherwise.

So, as it seems the hardware currently doesn't set the ITCdrift flag,
should I then set it in my init code? Or is there some other way of
disabling fsys support, possibly on a per-syscall basis?

thanks
-john


