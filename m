From: Jeremy Fitzhardinge <jeremy@goop.org>
Date: Fri, 08 Nov 2002 17:38:25 +0000
Subject: Re: [Linux-ia64] reader-writer livelock problem
Message-Id: <marc-linux-ia64-105590709805362@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805355@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805355@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2002-11-08 at 09:25, Linus Torvalds wrote:
> There's another reason for not doing it that way: allowing readers to keep 
> interrupts on even in the presense of interrupt uses of readers.
> 
> If you do the "pending writes stop readers" approach, you get
> 
> 		cpu1			cpu2
> 
> 		read_lock() - get
> 
> 					write_lock_irq() - pending
> 
> 		irq happens
> 		 - read_lock() - deadlock
> 
> and that means that you need to make readers protect against interrupts 
> even if the interrupts only read themselves.

Even without interrupts that would be a bug.  It isn't ever safe to
attempt to retake a read lock if you already hold it, because you may
deadlock with a pending writer.  Fair multi-reader locks aren't
recursive locks.

> NOTE! I'm not saying the existing practice is necessarily a good tradeoff,
> and maybe we should just make sure to find all such cases and turn the
> read_lock() calls into read_lock_irqsave() and then make the rw-locks
> block readers on pending writers. But it's certainly more work and cause
> for subtler problems than just naively changing the rw implementation.

Yes, I'd agree.  It would definitely be a behavioural change with
respect to the legality of retaking a lock for reading, which would
probably be quite irritating to find (since they'd only cause a problem
if they actually coincide with an attempted write lock).

> Actually, giving this som emore thought, I really suspect that the
> simplest solution is to alloc a separate "fair_read_lock()", and paths
> that need to care about fairness (and know they don't have the irq
> issue)  
> can use that, slowly porting users over one by one...

Do you mean have a separate lock type, or have two different read_lock
operations on the current type?

	J


