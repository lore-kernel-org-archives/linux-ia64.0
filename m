From: Matthew Wilcox <willy@debian.org>
Date: Mon, 29 Jul 2002 21:18:49 +0000
Subject: Re: [Linux-ia64] Linux kernel deadlock caused by spinlock bug
Message-Id: <marc-linux-ia64-105590701905846@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905843@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905843@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Jul 29, 2002 at 04:05:35PM -0500, Van Maren, Kevin wrote:
> Recursive read locks certainly make it more difficult to fix the
> problem.  Placing a band-aid on gettimeofday will fix the symptom
> in one location, but will not fix the general problem, which is
> writer starvation with heavy read lock load.  The only way to fix
> that is to make writer locks fair or to eliminate them (make them
> _all_ stateless).

The basic principle is that if you see contention on a spinlock, you
should eliminate the spinlock somehow.  making spinlocks `fair' doesn't
help that you're spending lots of time spinning on a lock.

-- 
Revolutions do not require corporate support.

