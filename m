From: "Van Maren, Kevin" <kevin.vanmaren@unisys.com>
Date: Mon, 29 Jul 2002 21:29:09 +0000
Subject: RE: [Linux-ia64] Linux kernel deadlock caused by spinlock bug
Message-Id: <marc-linux-ia64-105590701905847@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905843@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905843@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> On Mon, Jul 29, 2002 at 04:05:35PM -0500, Van Maren, Kevin wrote:
> > Recursive read locks certainly make it more difficult to fix the
> > problem.  Placing a band-aid on gettimeofday will fix the symptom
> > in one location, but will not fix the general problem, which is
> > writer starvation with heavy read lock load.  The only way to fix
> > that is to make writer locks fair or to eliminate them (make them
> > _all_ stateless).
> 
> The basic principle is that if you see contention on a spinlock, you
> should eliminate the spinlock somehow.  making spinlocks 
> `fair' doesn't
> help that you're spending lots of time spinning on a lock.

Yes, but that isn't the point: unless you eliminate all rw locks,
it is conceptually possible to cause a kernel deadlock by forcing
contention on the locks you didn't remove, if the user can force
the kernel to acquire a reader lock and if something else needs to
acquire the writer lock.  Correctness is the issue, not performance.
You have locks because there _could_ be contention, and locks handle
that contention _correctly_.  If you can eliminate the contention,
you can eliminate the locks, but if there is a chance for contention,
the locks have to remain, _and_ they have to handle contention
_correctly_, which does not occur with the current reader/writer
lock code, which can hang the kernel just as dead as a writer
between recursive reader lock calls with my code.

Kevin

