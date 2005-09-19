From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 19 Sep 2005 22:03:35 +0000
Subject: RE: [RFC] timer_interrupt: Avoid device timeouts by freezing time if system froze
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F046E6487@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0509091501240.12956@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0509091501240.12956@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I don't think that I've followed all the steps and proposed
solutions in this thread.  There are (at least) two issues to
try to solve when the system has been frozen for an extended
period of time (more than a few ticks):

1) The system clock (gettimeofday(2)) needs to catch up the
missed time.  We can either do this in one mighty bound, or
we can creep up on it.  Either is plausible (though each may
have its own issues for applications, neither should be
catastrophic as applications should already deal with jumping
and slewing time due to NTP and other agents setting the
system clock).

2) There are some pending timeouts from the interval of real
time that we skipped.  Dealing with these may be harder, as
some of them may be related to physical limitations of devices,
so almost any choice we make about these (call all the pending
timeouts immediately, call them at some accelerated rate, skip
them) may cause problems for some device driver.  I think to
make any progress on a solution here we need to restrict the
discussion to real device drivers that are currently in the
tree.  Otherwise we will rathole forever discussing theoretical
situations.

Any other issues?

-Tony
