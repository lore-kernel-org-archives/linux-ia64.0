From: Davide Libenzi <davidel@xmailserver.org>
Date: Sat, 24 May 2003 21:41:48 +0000
Subject: RE: [Linux-ia64] Re: web page on O(1) scheduler
Message-Id: <marc-linux-ia64-105590723706031@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705966@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705966@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, 24 May 2003, Hans Boehm wrote:

> Agreed.  The problem is that pthreads arguably requires a full barrier,
> not just a release barrier, though on second though that's not completely
> clear.  At the moment the IA64 spin_unlock code just uses st.rel, which is what
> I would do in my own lock implementation.  On the other hand, the code to
> acquire the lock uses
>
> 	mf;;
> 	cmpxchg4.acq
>
> which is more expensive than what I would use.
>
> Clearly the two are inconsistent.  I would vote for dropping the fence
> in the lock acquisition code, since it's really useless, AFAICT.
>
> (I think the standards require that memory be "synchronized" at locks
> and unlocks, which would tend to argue for a full barrier.  On the other
> hand, accessing shared variables outside of locks invokes undefined
> behavior, so there's probably no way to tell if it's really only a one-way
> barrier.)

The problem is the abstraction used by pthread. It uses a system dependent
testandset() and a system independent __pthread_acquire(). The problem is
the the system dependent testandset() carry with it some "useful"
properties in many CPUs. Sadly enough those properties are not enough to
guarantee the complete spinlock semantics. So some extra memory fencing is
required to complete it. This extra memory fencing might indeed hurt some
CPU performance. My suggestion would be to move __pthread_acquire() and
__pthread_release() inside the system dependent bits so that we can take
full advantage of the more consistent memory fencing mechanism.



- Davide


