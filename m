From: Christoph Lameter <clameter@sgi.com>
Date: Mon, 13 Sep 2004 22:50:33 +0000
Subject: Re: [PATCH] 2.6.9-rc1 Ia64 build broken due to HPET
Message-Id: <Pine.LNX.4.58.0409131546560.616@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040910041200.GN5668@cse.unsw.EDU.AU>
In-Reply-To: <20040910041200.GN5668@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 13 Sep 2004, Alex Williamson wrote:

> > Well. This means that the resolution is broken for any clock > 1GHZ.
>    Yep, and the patch below at least fixes that much:

I checked that only the resolution is broken (unless the interpolator
shift is zero!). So the interpolators should now work fine at >1Ghz.

> > register_time_interpolator allows a later registration of a time
> > interpolator. The question though is: Will it win against the one
> > already installed. It may win if you specify a smaller drift than the ITC
> > interpolator. Gotta look at that.
>
>    Yes, it does win, so apparently the drift is smaller (I only put in
> enough printks so see that it won).  But the HPET interpolator is still
> coming in after init_posix_timers(), so the monotonic and realtime
> resolution isn't going to be updated to match the new timer without an
> additional hook in there.  Thanks,

Hmm... So if it wins and the posix time system is already up when
register time_interpolator is called then we need to redo
the posix timer setup or meddle with CLOCK_REALTIME and CLOCK_MONOTONIC
accuracy? Uggh....
