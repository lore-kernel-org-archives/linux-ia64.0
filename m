From: Jack Steiner <steiner@sgi.com>
Date: Wed, 01 Dec 2004 16:44:21 +0000
Subject: Re: [PATCH 2.6.10-rc2] Drop SALINFO_TIMER_DELAY to one minute
Message-Id: <20041201164421.GA12672@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <10903.1101872210@kao2.melbourne.sgi.com>
In-Reply-To: <10903.1101872210@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Dec 01, 2004 at 08:36:46AM -0800, Jesse Barnes wrote:
> On Wednesday, December 01, 2004 5:29 am, Jack Steiner wrote:
> > On Wed, Dec 01, 2004 at 02:36:50PM +1100, Keith Owens wrote:
> > > Experience with recoverable MCA events shows that a poll interval of 5
> > > minutes for new MCA/INIT records is a bit too long.  Drop the poll
> > > interval to one minute.
> >
> > I'm not convinced that shortening the delay is the right solution.
> 
> Seems like it can't hurt though.

But it doesnt fix anything either - at least IMHO.
The periodic call does add a small amount of extra system "noise" but I 
don't know if it is significant.

> 
> > It seems to me that either the OS or SAL should do something (ex.,
> > interrupt, ...) to cause the MCA error to logged/cleared as quickly
> > as possible.  Waiting for the next poll interval does not seem like
> > the right solution. If too many MCAs (recovered or not) occur
> > before the next poll interval, error state will be lost.
> 
> I agree that we should also be clearing records for corrected events.  In the 
> I/O error handling patch I'm testing, I actually added a call in the recovery 
> path to clear the error before we return to SAL, and that seems to be working 
> so far, but you say there are potential deadlocks there (note that I'm not 
> logging the error at all, just clearing it, seems like there should be a way 
> to promote the error from MCA to CMC or something).

In your IO code, I think you are probably safe if all you do is clear the error. 
The potential deadlocks are in the logging code. I'm assuming that the IO error 
truely is an error that SHOULD not be logged, right?

I agree that the spec really doesn't address MCAs that are usually fatal but
software managed to ride thru the error. In one sense the error is corrected
but in another sense it is uncorrected. The spec AFAICT doesn't cover this very well.



-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


