From: "Van Maren, Kevin" <kevin.vanmaren@unisys.com>
Date: Fri, 08 Nov 2002 17:41:57 +0000
Subject: RE: [Linux-ia64] reader-writer livelock problem
Message-Id: <marc-linux-ia64-105590709805363@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805355@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805355@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Yes, that was one of the options I suggested in the original post
to the IA64 list.  I'll bounce it to LKML for reference, now that
the discussion has moved there.

In my proposal, however, I proposed making (the current) reader
locks recursive spinlocks (to eliminate the starvation problem,
at the expense of eliminating reader parallelism), which would
have the added benefit of "encouraging" people to move to the
fair locks.  But your proposal is probably at least as good.

Of course, normal spinlocks do not scale either, since they
currently require N cache-cache transfers for a processor to
drop the lock, which results in N^2 cache transfers for each
processor to acquire/release the lock once.  So with 32 processors
contending for the lock, at 1us per cache-cache transfer (picked
for easy math, but that is reasonable for large systems), it
takes 1ms for each processor to acquire the spinlock and hold it
for 10 cpu cycles.

So I'd _also_ like to see an MCS lock implementation replace the current
spinlock code (IBM "NMCS" lock patch can be trivially used to replace
all spinlocks).

Kevin

-----Original Message-----
From: Linus Torvalds
To: Jeremy Fitzhardinge
Cc: William Lee Irwin III; Van Maren, Kevin; linux-ia64@linuxia64.org; Linux
Kernel List; rusty@rustcorp.com.au; dhowells@redhat.com; mingo@elte.hu
Sent: 11/8/02 12:28 PM
Subject: Re: [Linux-ia64] reader-writer livelock problem


On Fri, 8 Nov 2002, Linus Torvalds wrote:
> 
> NOTE! I'm not saying the existing practice is necessarily a good
tradeoff,
> and maybe we should just make sure to find all such cases and turn the
> read_lock() calls into read_lock_irqsave() and then make the rw-locks
> block readers on pending writers. But it's certainly more work and
cause
> for subtler problems than just naively changing the rw implementation.

Actually, giving this som emore thought, I really suspect that the
simplest solution is to alloc a separate "fair_read_lock()", and paths
that need to care about fairness (and know they don't have the irq
issue)  
can use that, slowly porting users over one by one...

  Linus

