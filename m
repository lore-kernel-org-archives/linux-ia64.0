From: john stultz <johnstul@us.ibm.com>
Date: Thu, 15 Jul 2004 01:35:20 +0000
Subject: Re: gettimeofday nanoseconds patch (makes it possible for the
Message-Id: <1089855319.1388.295.camel@cog.beaverton.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0407140940260.14704@schroedinger.engr.sgi.com>
	 <1089835776.1388.216.camel@cog.beaverton.ibm.com>
	 <Pine.LNX.4.58.0407141323530.15874@schroedinger.engr.sgi.com>
	 <1089839740.1388.230.camel@cog.beaverton.ibm.com>
	 <Pine.LNX.4.58.0407141703360.17055@schroedinger.engr.sgi.com>
	 <1089852486.1388.256.camel@cog.beaverton.ibm.com>
	 <16629.56037.120532.779793@napali.hpl.hp.com>
In-Reply-To: <16629.56037.120532.779793@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Mosberger <davidm@hpl.hp.com>
Cc: Christoph Lameter <clameter@sgi.com>, george anzinger <george@mvista.com>, lkml <linux-kernel@vger.kernel.org>, ia64 <linux-ia64@vger.kernel.org>

On Wed, 2004-07-14 at 18:16, David Mosberger wrote:
> >>>>> On Wed, 14 Jul 2004 17:48:06 -0700, john stultz <johnstul@us.ibm.com> said:
> 
>   John> Although you still have the issue w/ NTP adjustments being
>   John> ignored, but last time I looked at the time_interpolator code,
>   John> it seemed it was being ignored there too, so at least your not
>   John> doing worse then the ia64 do_gettimeofday(). [If I'm doing the
>   John> time_interpolator code a great injustice with the above,
>   John> someone please correct me]
> 
> The existing time-interpolator code for ia64 never lets time go
> backwards (in the absence of a settimeofday(), of course).  There is
> no need to special-case NTP.

I guess I don't understand then, from my looking over it I didn't see
where the time_interpolator_get_offset() is scaled back when NTP is
slewing the clock. It seems that while the time-interpolator code does
keep time from going backwards, it also inadvertently ends up
compensating for NTP slow down. Thus the slewing is not visible to
userspace. 

In order for this to happen, time_interpolator_get_offset() would need
to be scaled or capped as to that it would not return more then the
length of the *NTP adjusted tick* during an actual tick interval.

I may be missing something, so please let me know if I'm wrong.

thanks
-john

