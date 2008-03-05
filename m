From: Matthew Chapman <matthewc@cse.unsw.edu.au>
Date: Wed, 05 Mar 2008 09:41:28 +0000
Subject: Interval timer
Message-Id: <20080305094128.GA30069@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Is there any interval timer on HP zx1 platforms, other than the
CPU-based ITC/ITM?

All I need is some mechanism that can deliver an interrupt "after a
short time", where I don't care exactly how long that is, but preferably
of the order of several microseconds (pinging the chipset is a bit short
I think).

I used to use the PMU for this - the PMU is useful for an incredible
number of things - but this was causing a bug (because of the 'freeze'
behaviour on an interrupt, I miss important events in other counters).

Multiplexing ITC/ITM complicates my common path so I'm trying to avoid
doing that if I can find any other way...

Any ideas?

Matt

