From: john stultz <johnstul@us.ibm.com>
Date: Wed, 14 Jul 2004 21:15:40 +0000
Subject: Re: gettimeofday nanoseconds patch (makes it possible for the
Message-Id: <1089839740.1388.230.camel@cog.beaverton.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0407140940260.14704@schroedinger.engr.sgi.com>
	 <1089835776.1388.216.camel@cog.beaverton.ibm.com>
	 <Pine.LNX.4.58.0407141323530.15874@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0407141323530.15874@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: lkml <linux-kernel@vger.kernel.org>, ia64 <linux-ia64@vger.kernel.org>

On Wed, 2004-07-14 at 13:28, Christoph Lameter wrote:
> > None the less, I do understand the desire for the change (and am working
> > to address it in 2.7), so could you at least use a better name then
> > gettimeofday()? Maybe get_ns_time() or something? Its just too similar
> > to do_gettimeofday and the syscall gettimeofday().
> 
> Right. I had it named getnstimeofday before but the feeling was that the
> patch should not introduce a new name. Any approach that would allow
> progress on the issue would be fine with me.

Fair enough. getnstimeofday() sounds good enough for me. 

> > Really, I feel the cleaner method is to fix do_gettimeofday() so it
> > returns a timespec and then convert it to a timeval in
> > sys_gettimeofday(). However this would add overhead to the syscall, so I
> > doubt folks would go for it.
> 
> do_gettimeofday is used all over the linux kernel for a variety of
> purposes and lots of code depends on the presence of a timeval struct.

Indeed, it would be a decent amount of work to clean that up as well.

thanks
-john

