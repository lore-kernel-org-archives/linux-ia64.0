From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 13 Oct 2004 16:03:42 +0000
Subject: Re: Periodic posix timer support broke between 2.6.9-rc1 and
Message-Id: <Pine.LNX.4.58.0410130902490.9272@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 12 Oct 2004, George Anzinger wrote:

> Christoph Lameter wrote:
> > I ran some test programs and discovered that the periodic timer support
> > is broken. The timer is triggered once and then never again. Single shot
> > timers work fine. 2.6.9-rc1 is fine. The first kernel that I tested where
> > I noticed the breakage was 2.6.9-rc1-bk17. 2.6.9-rc2 and following all
> > cannot do periodic timer signals.
> >
> > I looked through the changelog but I cannot see anything that would cause
> > the problem. Roland's patch surely could not have done this.
> >
> > Will try to track this down further, time permitting...
>
> The most likely thing would be failure to do the call back from the signal
> delivery code.

The problem is IA64 arch specific. Works fine on i386.

