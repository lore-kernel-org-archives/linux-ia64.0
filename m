From: "Van Maren, Kevin" <kevin.vanmaren@unisys.com>
Date: Fri, 08 Nov 2002 20:17:21 +0000
Subject: RE: [Linux-ia64] reader-writer livelock problem
Message-Id: <marc-linux-ia64-105590709805375@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805355@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805355@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> all that cacheline bouncing can't do your numa boxes any good.

It happens even on our non-NUMA boxes.  But that was the reason
behind developing MCS locks: they are designed to minimize the
cacheline bouncing due to lock contention, and become a win with
a very small number of processors contending the same spinlock.


> i hear x86-64 has a lockless gettimeofday.  maybe that's the solution.

I was using gettimeofday() as ONE example of the problem.
Fixing gettimeofday(), such as with frlocks (see, for example,
http://lwn.net/Articles/7388) fixes ONE occurance of the
problem.

Every reader/writer lock that an application can force
the kernel to acquire can have this problem.  If there
is enough time between acquires, it may take 32 or 64
processors to hang the system, but livelock WILL occur.

> it's really
> not the kernel's fault that your app is badly written.

There are MANY other cases where an application can force the
kernel to acquire a lock needed by other things.
The point is not whether the *application* is badly written,
but point is whether a bad application can mess up the kernel
by causing a livelock.


Spinlocks are a slightly different story.  While there isn't
the starvation issue, livelock can still occur if the kernel
needs to acquire the spinlock more often that it takes to
acquire.  This is why replacing the xtime_lock with a spinlock
fixes the reader/writer livelock, but not the problem: while
the writer can now get the spinlock, it can take an entire
clock tick to acquire/release it.  So the net behavior is the
same: with a 1KHz timer and with 1us cache-cache latency, 32
processors spinning on gettimeofday() using a spinlock would
have a similar result.

Kevin

