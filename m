From: Jesse Barnes <jbarnes@sgi.com>
Date: Wed, 01 Dec 2004 16:36:46 +0000
Subject: Re: [PATCH 2.6.10-rc2] Drop SALINFO_TIMER_DELAY to one minute
Message-Id: <200412010836.46983.jbarnes@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <10903.1101872210@kao2.melbourne.sgi.com>
In-Reply-To: <10903.1101872210@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday, December 01, 2004 5:29 am, Jack Steiner wrote:
> On Wed, Dec 01, 2004 at 02:36:50PM +1100, Keith Owens wrote:
> > Experience with recoverable MCA events shows that a poll interval of 5
> > minutes for new MCA/INIT records is a bit too long.  Drop the poll
> > interval to one minute.
>
> I'm not convinced that shortening the delay is the right solution.

Seems like it can't hurt though.

> It seems to me that either the OS or SAL should do something (ex.,
> interrupt, ...) to cause the MCA error to logged/cleared as quickly
> as possible.  Waiting for the next poll interval does not seem like
> the right solution. If too many MCAs (recovered or not) occur
> before the next poll interval, error state will be lost.

I agree that we should also be clearing records for corrected events.  In the 
I/O error handling patch I'm testing, I actually added a call in the recovery 
path to clear the error before we return to SAL, and that seems to be working 
so far, but you say there are potential deadlocks there (note that I'm not 
logging the error at all, just clearing it, seems like there should be a way 
to promote the error from MCA to CMC or something).

Jesse
