From: Linus Torvalds <torvalds@transmeta.com>
Date: Fri, 08 Nov 2002 17:25:24 +0000
Subject: Re: [Linux-ia64] reader-writer livelock problem
Message-Id: <marc-linux-ia64-105590709805359@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805355@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805355@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 8 Nov 2002, Jeremy Fitzhardinge wrote:
> 
> The normal way of solving this fairness problem is to make pending write
> locks block read lock attempts, so that the reader count is guaranteed
> to drop to zero as read locks are released.  I haven't looked at the
> Linux implementation of rwlocks, so I don't know how hard this is to
> do.  Or perhaps there's some other reason for not implementing it this
> way?

There's another reason for not doing it that way: allowing readers to keep 
interrupts on even in the presense of interrupt uses of readers.

If you do the "pending writes stop readers" approach, you get

		cpu1			cpu2

		read_lock() - get

					write_lock_irq() - pending

		irq happens
		 - read_lock() - deadlock

and that means that you need to make readers protect against interrupts 
even if the interrupts only read themselves.

NOTE! I'm not saying the existing practice is necessarily a good tradeoff,
and maybe we should just make sure to find all such cases and turn the
read_lock() calls into read_lock_irqsave() and then make the rw-locks
block readers on pending writers. But it's certainly more work and cause
for subtler problems than just naively changing the rw implementation.

		Linus


