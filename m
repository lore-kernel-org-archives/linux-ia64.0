From: Jesse Barnes <jbarnes@sgi.com>
Date: Fri, 26 Oct 2001 17:09:47 +0000
Subject: [Linux-ia64] itc sync & clock_*
Message-Id: <marc-linux-ia64-105590698805400@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David, you mentinoned awhile back that you don't expect the itc counters
to be synchronized in future machines and that apps should use
gettimeofday and the posix clock_* routines to get timestamps.  However,
the clock_* routines in recent versions of glibc for ia64 look at ar.itc
as the source of clock tick information.  Does that need to be
fixed?  This problem is more immediate on our hardware, as the clocks are
not synchronized, so I'd like to come up with a solution.  I'm not sure I
understand all the issues yet, but I'd like to solicit people for ideas
and/or explaination about this issue.

Thanks,
Jesse



