From: Chris McDermott <lcm@us.ibm.com>
Date: Fri, 13 Feb 2004 01:41:44 +0000
Subject: Re: [RFC][PATCH] linux-2.6.3-rc2_ia64-cyclone_A0
Message-Id: <20040213014144.GA6683@us.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1076556140.795.119.camel@cog.beaverton.ibm.com>
In-Reply-To: <1076556140.795.119.camel@cog.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Feb 12, 2004 at 17:16 -0800, David Mosberger wrote: 
> >>>>> On Thu, 12 Feb 2004 17:05:50 -0800, john stultz <johnstul@us.ibm.com> said:
> 
>   John> Hmm. As cyclone is only enabled for x450/x455 systems, I'm not
>   John> sure if that additional check is necessary, but I'll try to
>   John> look into that.
> 
> At the very least, verify that the SAL ITCdrift bit is turned on by
> the firmware.  Otherwise, the lightweight handler of gettimeofday()
> will still use ITC-based interpolation.
> 
> 	--david
> -
David,

The x450/x455 doesn't set/implement the SAL ITC drift bit. Could you point 
us to where this is documentated?  The latest SAL spec (Dec 2003) didn't 
have reference to this flag being implemented in the Platform Features 
Descriptor Entry in the SST.

thanks,
-- 
-chris

Chris McDermott
IBM Linux Technology Center (LTC)
xSeries Platform Enablement

