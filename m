From: Christoph Lameter <clameter@engr.sgi.com>
Date: Mon, 19 Sep 2005 19:21:56 +0000
Subject: RE: [RFC] timer_interrupt: Avoid device timeouts by freezing time
Message-Id: <Pine.LNX.4.62.0509191209130.26247@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0509091501240.12956@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0509091501240.12956@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 19 Sep 2005, Luck, Tony wrote:

> >Ok then we can simply remove the time_interpolator_reset() call from 
> >my patch. Then the self-tuning interpolator logic will compensate for the 
> >difference over time.
> 
> Can you provide a bit more detail in the form of a concrete example
> or two.  Suppose I stop the system (e.g. by entering a debugger) and
> after poking around for sixty seconds, I restart the OS.
> 
> How long does it take for the interpolator to compensate for the
> lost minute?

The first thing that happens is that the interpolator will generate a huge 
offset of 60 seconds. This means that the result of gettimeofday is 60 
seconds offset from xtime.

The interpolator typically looses a few nanoseconds (around 10-100 
nanoseconds) on each timer tick. If the clock source is tuned properly 
then this will be less than 10 nanoseconds per tick.

The interpolator adjusts itself every minute or so. At the next check 
of the accuracy of the time interpolator clock the interpolator will find 
that the clock source is running too slow since there is a huge offset 
and slightly tune the clock rate. This will increase the decrease of the offset
by the factor 2 ^ time_interpolator->shift.

The interpolator will continue detuning itself until the offset is 
consumed and xtime =~ gettimeofday(). 

Then the interval will be suddenly too short so the interpolator will 
gradually increase the interpolator clock rate again in 2 ^ 
time_interpolator->shift steps until a minimal offset is produced.

So gettimeofday will continue running just fine, The time jumps forward 
in the time interval may increase to a couple of hundred nanoseconds per 
tick intermittendly and then return to the default of around 10 
nanoseconds per interval.

I think the main issue will be the deviation of xtime from gettimeofday(). 
Some kernel subsystem use do_gettimeofday() and some others may access 
xtime.

> What is the relative rate of time while this compensation happens?

That depends on the time source and the tuning factor. I guestimate 
it will take about an hour to compensate for 60 seconds. The compensation 
is not linear but should be almost logarithmic since the interpolator will 
detune further if the time difference is greater.

> Does it make a difference if NTP is running?

NTP Time adjustment wont work right until time is okay again. But this 
should only result in relatively small deviations of up to a milisecond.

Guess we should test this approach. But this is bad hack.

