From: Davide Libenzi <davidel@xmailserver.org>
Date: Sat, 24 May 2003 00:20:13 +0000
Subject: RE: [Linux-ia64] Re: web page on O(1) scheduler
Message-Id: <marc-linux-ia64-105590723706025@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705966@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705966@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 23 May 2003, Boehm, Hans wrote:

> Pthread_spin_lock() under the NPTL version in RH9 does basically what my
> custom locks do in the uncontested case, aside from the function call.
> But remember that this began with a discussion about whether it was
> reasonable for user locking code to explicitly yield rather than relying
> on pthreads to suspend the thread.  I don't think pthread_spin_lock is
> relevant in this context, for two reasons:
>
> 1) At least the RH9 version of pthread_spin_lock in NPTL literally spins
> and makes no attempt to yield or block.  This only makes sense at user
> level if you are 100% certain that the processors won't be
> overcommitted. Otherwise there is little to be lost by blocking once you
> have spun for sufficiently long.  You could use pthread_spin_trylock and
> block explicitly, but that gets us back to custom blocking code.

Yes, that would be a spinlock. Your code was basically a spinlock that
instead of spinning was doing abort() in contention case. Again, you
measured two different things. Even if the pthread mutex does something
very simple like :

	spinlock(mtx->lock);
	while (mtx->busy) {
		spinunlock(mtx->lock);
		waitforunlocks();
		spinlock(mtx->lock);
	}
	mtx->busy++;
	spinunlock(mtx->lock);

Only the fact that this code likely reside inside a deeper call lever will
make you pay in a tight loop like your.


> 2) AFAICT, pthread_spin_lock is currently a little too bleeding edge to
> be widely used.  I tried to time it, but failed.  Pthread.h doesn't
> include the declaration for pthread_spin_lock_t by default, at least not
> yet.  It doesn't seem to have a Linux man page, yet.  I tried to define
> the magic macro to get it declared, but that broke something else.

$ gcc -D_GNU_SOURCE ...



- Davide


