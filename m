From: Tim Schmielau <tim@physik3.uni-rostock.de>
Date: Mon, 17 Mar 2003 13:55:14 +0000
Subject: [Linux-ia64] Re: [BUG] nanosleep() granularity bumps up in 2.5.64
Message-Id: <marc-linux-ia64-105590709806137@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806094@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806094@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 17 Mar 2003, Vitezslav Samel wrote:

> On Fri, Mar 14, 2003 at 02:48:59PM +0000, Matthew Wilcox wrote:
> > On Fri, Mar 14, 2003 at 03:34:36PM +0100, Eric Piel wrote:
> > > I think lines like that from patch-2.5.64 are very suspicious to be
> > > related to the bug:
> > > +	base->timer_jiffies = INITIAL_JIFFIES;
> > > +	base->tv1.index = INITIAL_JIFFIES & TVR_MASK;
> > > +	base->tv2.index = (INITIAL_JIFFIES >> TVR_BITS) & TVN_MASK;
> > > +	base->tv3.index = (INITIAL_JIFFIES >> (TVR_BITS+TVN_BITS)) & TVN_MASK;
> > > +	base->tv4.index = (INITIAL_JIFFIES >> (TVR_BITS+2*TVN_BITS)) &
> > > TVN_MASK;
> > > +	base->tv5.index = (INITIAL_JIFFIES >> (TVR_BITS+3*TVN_BITS)) &
> > > TVN_MASK;
> >
> > No, I don't think so.  Those lines are for starting `jiffies' at a very
> > high number so we spot jiffie-wrap bugs early on.
>
>   The nanosleep() bug narrowed down to 2.5.63-bk2. That's version, the "initial
> jiffies" patch went in. And yes, it's on i686 machine.

You can easily check whether it's connected with this change by setting
INITIAL_JIFFIES to zero. This should exactly recover the previous
situation.
I.e., something like the following (untested, hand-crafted) patch:

--- linux-2.5.64/include/linux/time.h
+++ linux-2.5.64/include/linux/time.h
@@ -28,7 +28,7 @@
  * Have the 32 bit jiffies value wrap 5 minutes after boot
  * so jiffies wrap bugs show up earlier.
  */
- #define INITIAL_JIFFIES ((unsigned int) (-300*HZ))
+ #define INITIAL_JIFFIES 0

 /*
  * Change timeval to jiffies, trying to avoid the


Tim


