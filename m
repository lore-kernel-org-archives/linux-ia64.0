From: john stultz <johnstul@us.ibm.com>
Date: Thu, 15 Jul 2004 00:48:06 +0000
Subject: Re: gettimeofday nanoseconds patch (makes it possible for the
Message-Id: <1089852486.1388.256.camel@cog.beaverton.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0407140940260.14704@schroedinger.engr.sgi.com>
	 <1089835776.1388.216.camel@cog.beaverton.ibm.com>
	 <Pine.LNX.4.58.0407141323530.15874@schroedinger.engr.sgi.com>
	 <1089839740.1388.230.camel@cog.beaverton.ibm.com>
	 <Pine.LNX.4.58.0407141703360.17055@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0407141703360.17055@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>, george anzinger <george@mvista.com>
Cc: lkml <linux-kernel@vger.kernel.org>, ia64 <linux-ia64@vger.kernel.org>

On Wed, 2004-07-14 at 17:08, Christoph Lameter wrote:
> On Wed, 14 Jul 2004, john stultz wrote:
> > On Wed, 2004-07-14 at 13:28, Christoph Lameter wrote:
> > > > None the less, I do understand the desire for the change (and am working
> > > > to address it in 2.7), so could you at least use a better name then
> > > > gettimeofday()? Maybe get_ns_time() or something? Its just too similar
> > > > to do_gettimeofday and the syscall gettimeofday().
> > >
> > > Right. I had it named getnstimeofday before but the feeling was that the
> > > patch should not introduce a new name. Any approach that would allow
> > > progress on the issue would be fine with me.
> >
> > Fair enough. getnstimeofday() sounds good enough for me.
> 
> Ok. A modified patch is following.

I guess it looks good enough for me. I'd say send it to Andrew when
you're ready.

George, do you have any additional comments?

Although you still have the issue w/ NTP adjustments being ignored, but
last time I looked at the time_interpolator code, it seemed it was being
ignored there too, so at least your not doing worse then the ia64
do_gettimeofday(). [If I'm doing the time_interpolator code a great
injustice with the above, someone please correct me]

> > > > Really, I feel the cleaner method is to fix do_gettimeofday() so it
> > > > returns a timespec and then convert it to a timeval in
> > > > sys_gettimeofday(). However this would add overhead to the syscall, so I
> > > > doubt folks would go for it.
> > >
> > > do_gettimeofday is used all over the linux kernel for a variety of
> > > purposes and lots of code depends on the presence of a timeval struct.
> >
> > Indeed, it would be a decent amount of work to clean that up as well.
> 
> The cleanup can be done gradually after this patch is in. I volunteer
> to work on this (hoping that my employer may support that  ;-) ).

I'll try to remember to cc you on the 2.7 code when I get the first pass
ready (re-implementing the NTP mechanism is the last blocker). I'm sure
to appreciate additional feedback from non i386 arch specific views.

thanks
-john

