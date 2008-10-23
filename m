From: Petr Tesarik <ptesarik@suse.cz>
Date: Thu, 23 Oct 2008 15:57:31 +0000
Subject: [PATCH V2 0/2] enable irqs when waiting for rwlocks
Message-Id: <1224777451.11530.52.camel@elijah.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
Cc: tee@sgi.com, Robin Holt <holt@sgi.com>

New in V2:
 * get rid of ugly #ifdef's in kernel/spinlock.h
 * convert __raw_{read|write}_lock_flags to an inline func

SGI has observed that on large systems, interrupts are not serviced for
a long period of time when waiting for a rwlock. The following patch
series re-enables irqs while waiting for the lock, resembling the code
which is already there for spinlocks.

I only made the ia64 version, because the patch adds some overhead to
the fast path. I assume there is currently no demand to have this for
other architectures, because the systems are not so large. Of course,
the possibility to implement raw_{read|write}_lock_flags for any
architecture is still there.

Petr Tesarik


