From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 14 Jul 2004 20:28:39 +0000
Subject: Re: gettimeofday nanoseconds patch (makes it possible for the
Message-Id: <Pine.LNX.4.58.0407141323530.15874@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0407140940260.14704@schroedinger.engr.sgi.com>
 <1089835776.1388.216.camel@cog.beaverton.ibm.com>
In-Reply-To: <1089835776.1388.216.camel@cog.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: john stultz <johnstul@us.ibm.com>
Cc: lkml <linux-kernel@vger.kernel.org>, ia64 <linux-ia64@vger.kernel.org>

On Wed, 14 Jul 2004, john stultz wrote:

> Honestly, I'm not a fan of the patch. It realistically only helps ia64
> and and adds more confusing code to the generic time code. If there
> isn't an real/immediate need for this, I'd wait to 2.7 for a better
> cleanup.

The immediate need is that clock_gettime only returns microseconds scaled
to nanoseconds.

> None the less, I do understand the desire for the change (and am working
> to address it in 2.7), so could you at least use a better name then
> gettimeofday()? Maybe get_ns_time() or something? Its just too similar
> to do_gettimeofday and the syscall gettimeofday().

Right. I had it named getnstimeofday before but the feeling was that the
patch should not introduce a new name. Any approach that would allow
progress on the issue would be fine with me.

> Really, I feel the cleaner method is to fix do_gettimeofday() so it
> returns a timespec and then convert it to a timeval in
> sys_gettimeofday(). However this would add overhead to the syscall, so I
> doubt folks would go for it.

do_gettimeofday is used all over the linux kernel for a variety of
purposes and lots of code depends on the presence of a timeval struct.

> I think the ia64 time interpolation code is a step in the right
> direction (def better then the i386 bits), but it still isn't the
> cleanest and clearest way. My plan is to select a reliable timesource
> for the system, then use a periodic interrupt to accumulate time from
> the timesource (in order to avoid overflows). This avoids lost tick
> issues and cleanly separates the timer subsystem from the time of day
> subsystem.

That is what the changes to the time_interpolator do.

