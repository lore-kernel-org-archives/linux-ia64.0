From: Hans Boehm <Hans.Boehm@hp.com>
Date: Sat, 24 May 2003 16:50:59 +0000
Subject: RE: [Linux-ia64] Re: web page on O(1) scheduler
Message-Id: <marc-linux-ia64-105590723706030@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705966@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705966@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, 24 May 2003, Davide Libenzi wrote:

> On Fri, 23 May 2003, Davide Libenzi wrote:
> 
> > You need a write memory barrier even on the unlock. Consider this :
> >
> > 	spinlock = 1;
> > 	...
> > 	protected_resource = NEWVAL;
> > 	spinlock = 0;
> >
> > ( where spinlock = 0/1 strip down, but do not lose the concept, the lock
> > operation ). If a CPU reorder those writes, another CPU might see the lock
> > drop before the protected resource assignment. And this is usually bad
> > for obvious reasons.
> 
> David made me notice about a brain misfire here. You need protection even
> for loads crossing the unlock. For the same obvious reasons :) Yes, a
> realease barrier will be sufficent for ia64, while you'll need an mfence
> on P4.
> 
Agreed.  The problem is that pthreads arguably requires a full barrier,
not just a release barrier, though on second though that's not completely
clear.  At the moment the IA64 spin_unlock code just uses st.rel, which is what
I would do in my own lock implementation.  On the other hand, the code to
acquire the lock uses

	mf;;
	cmpxchg4.acq

which is more expensive than what I would use.

Clearly the two are inconsistent.  I would vote for dropping the fence
in the lock acquisition code, since it's really useless, AFAICT.

(I think the standards require that memory be "synchronized" at locks
and unlocks, which would tend to argue for a full barrier.  On the other
hand, accessing shared variables outside of locks invokes undefined
behavior, so there's probably no way to tell if it's really only a one-way
barrier.)

-- 
Hans Boehm
(hboehm@hpl.hp.com)


