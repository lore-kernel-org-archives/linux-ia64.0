From: Matthew Wilcox <willy@debian.org>
Date: Fri, 08 Nov 2002 20:39:42 +0000
Subject: Re: [Linux-ia64] reader-writer livelock problem
Message-Id: <marc-linux-ia64-105590709805376@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805355@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805355@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Nov 08, 2002 at 02:17:21PM -0600, Van Maren, Kevin wrote:
> > all that cacheline bouncing can't do your numa boxes any good.
> 
> It happens even on our non-NUMA boxes.  But that was the reason
> behind developing MCS locks: they are designed to minimize the
> cacheline bouncing due to lock contention, and become a win with
> a very small number of processors contending the same spinlock.

that's not my point... a resource occupies a number of cachelines;
bouncing those cachelines between processors is expensive.  if there's
a real workload that all the processors are contending for the same
resource, it's time to split up that resource.

> I was using gettimeofday() as ONE example of the problem.
> Fixing gettimeofday(), such as with frlocks (see, for example,
> http://lwn.net/Articles/7388) fixes ONE occurance of the
> problem.
> 
> Every reader/writer lock that an application can force
> the kernel to acquire can have this problem.  If there
> is enough time between acquires, it may take 32 or 64
> processors to hang the system, but livelock WILL occur.

not true.  every reader/writer lock which guards a global resource can
have this problem.  if the lock only guards your own task's resources,
there can be no problem. 

> There are MANY other cases where an application can force the
> kernel to acquire a lock needed by other things.

and i agree they should be fixed.

> Spinlocks are a slightly different story.  While there isn't
> the starvation issue, livelock can still occur if the kernel
> needs to acquire the spinlock more often that it takes to
> acquire.  This is why replacing the xtime_lock with a spinlock
> fixes the reader/writer livelock, but not the problem: while
> the writer can now get the spinlock, it can take an entire
> clock tick to acquire/release it.  So the net behavior is the
> same: with a 1KHz timer and with 1us cache-cache latency, 32
> processors spinning on gettimeofday() using a spinlock would
> have a similar result.

right.  so spinlocking this resource is also not good enough.  did
you see the "Voyager subarchitecture for 2.5.46" thread earlier this
week which discussed making it per-cpu?
http://www.uwsg.iu.edu/hypermail/linux/kernel/0211.0/1799.html
this seems like the right way to go to me.

-- 
Revolutions do not require corporate support.

