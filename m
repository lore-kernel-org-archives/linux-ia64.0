From: Alex Williamson <alex.williamson@hp.com>
Date: Mon, 13 Sep 2004 22:11:55 +0000
Subject: Re: [PATCH] 2.6.9-rc1 Ia64 build broken due to HPET
Message-Id: <1095113515.20631.108.camel@tdi>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040910041200.GN5668@cse.unsw.EDU.AU>
In-Reply-To: <20040910041200.GN5668@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2004-09-13 at 13:28 -0700, Christoph Lameter wrote:
> On Mon, 13 Sep 2004, Alex Williamson wrote:
> 
> >
> >           Gettimeofday() = 1095104931.812600000
> >            CLOCK_REALTIME= 1095104931.812639404 resolution= 3712.000240992
> >           CLOCK_MONOTONIC=        369.103451704 resolution= 3712.000240992
> >  CLOCK_PROCESS_CPUTIME_ID=          0.000782450 resolution= 0.000000001
> >   CLOCK_THREAD_CPUTIME_ID=          0.000794115 resolution= 0.000000001
> >
> 
> That looks better but the resolution is still screwed up. The nanoseconds
> should be 3712 not the seconds.... The kernel clock_getres always sets the
> second part to zero. So does glibc when emulating CLOCK_REALTIME....
> 
> Could you figure out what is going on there? If the nsecs are 3712 or 4000
> or so then all is fine. My small program does not check for errors and
> may be screwing up here. Adding some error reporting may help. Or could
> you give me access to a system with hpet timer? I could also test some
> other things like the accuracy of time interpolation.

   There are several problems here.  The HPET really isn't coming into
play, and won't until we have systems that have a drifty ITC.  Here's
what's happening:

      * The itc_interpolator gets registered with a frequency of 1.2GHz
      * init_posix_timers() runs, setting the realtime and monotonic
        clock resolutions via time_interpolator_resolution().
        Unfortunately, 1*10^9/1.2*10^9 = 0.
      * hpet_init gets called after the fact, registering the hpet
        interpolator, but it's got nowhere near the frequency of the
        ITC.
      * sys_clock_getres() returns EINVAL because the clock resolutions
        are zero.

So, first and foremost, the ITC interpolator is broken for any ITC
greater than 1GHz.  Secondary, the HPET interpolator comes in too late,
and the code doesn't really seem to be able to support that.

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab

