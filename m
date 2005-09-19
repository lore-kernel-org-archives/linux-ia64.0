From: Christoph Lameter <clameter@engr.sgi.com>
Date: Mon, 19 Sep 2005 21:26:12 +0000
Subject: Re: [RFC] timer_interrupt: Avoid device timeouts by freezing time
Message-Id: <Pine.LNX.4.62.0509191421420.26388@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0509091501240.12956@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0509091501240.12956@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 19 Sep 2005, David Mosberger-Tang wrote:

> > That depends on the time source and the tuning factor. I guestimate
> > it will take about an hour to compensate for 60 seconds. The compensation
> > is not linear but should be almost logarithmic since the interpolator will
> > detune further if the time difference is greater.
> 
> That seems rather slow to me.  Of course, you don't want to catch up
> by more than the smallest timeout that you'd like to avoid triggering.
>  By that logic, it should be almost guaranteed to be save to account
> for 2 ticks per timer interrupt.  That way, it would only take 30 sec
> to correct from a 60 sec stand-still.  My gut feeling is that you
> could be much more aggressive (e.g., 8 ticks/interrupt) but it might
> be a good idea to experiment with this a bit, to get a feel for how
> sensitive things really are.  If you wanted to be super-safe, you
> could account an extra tick only every other interrupt (i.e., 1.5
> ticks/interrupt on average), since timeouts have a rounding-error of
> 1/2 tick anyhow.

Doing two ticks per interrupt may cause hardware to fail that relies on 
the interval accurately being observed. I.e. lets say we have a device 
that typically responds after 10 ticks but times out after 15.

If we use 2 ticks per interrupt then we will timeout after 15/2 = 7 ticks 
before the device had a chance to do anything.

I think all these additional tricks just make the situation worse. My 
patch is already a bad hack and adding more logic just makes follow-on 
failures difficult to analyze. I'd say the cleanest solution is still to 
stick with freezing time. I also do not feel too enthusiastic about 
abusing the time interpolator tuning logic for compenstation.
