From: Petr Tesarik <ptesarik@suse.cz>
Date: Wed, 22 Oct 2008 08:33:34 +0000
Subject: [PATCH 0/2] enable irqs when waiting for rwlocks
Message-Id: <1224664414.4430.33.camel@elijah.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
Cc: tee@sgi.com

Hello,

SGI has observed that on large systems, interrupts are not serviced for
a long period of time when waiting for a rwlock. The following patch
series re-enables irqs while waiting for the lock, resembling the code
which is already there for spinlocks.

I only made the ia64 version, because the patch adds some overhead to
the fast path. In particular, I wasn't able to make a reasonably
lightweight implementation for x86, so I assume there are not such large
systems based on x86(_64). Of course, the possibility to implement
raw_{read|write}_lock_flags for any architecture is still there.

Petr Tesarik


