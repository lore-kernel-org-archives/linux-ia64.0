From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Fri, 04 Jun 2004 22:06:36 +0000
Subject: Re: GLIBC IA64 HP_TIMING fixes for SMP systems with unsynchronized ITC
Message-Id: <16576.62060.285676.131150@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0406031313420.32412@server.home>
In-Reply-To: <Pine.LNX.4.58.0406031313420.32412@server.home>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:


David> Does anyone else find it annoying that gettimeofday() only
David> provides micro-second resolution?  We can do syscalls
David> significantly faster than that (especially with a light-weight
David> syscall handler).  Time for a kernel extension?

Only problem is that we can get high precision, but unless we can also
get access to the NTP daemon's parameters, we don't know the accuracy
of the result.

Dunno about your systems, but mine drift around the real time by a
couple of *milliseconds* so nanosecond accuracy in gettimeofday()
won't buy much.

For a lot of things, however, all one needs is a precise monotonic
clock; absolute accuracy isn't required.  Making an alternate internal
do_gettimeofday that takes a timespec instead of a timeval, and using
it for the posix monotonic clock might help here.  There's the
standard clock_gettime() function for accessing the values.  Or the
posix time code that George Anzinger wrote (who's CCed on this thread
now, because he understands the issues better than I) could definitely
use a monotonic high precision clock.

--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*

