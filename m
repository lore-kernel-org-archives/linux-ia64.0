From: Linus Torvalds <torvalds@transmeta.com>
Date: Fri, 08 Nov 2002 17:28:39 +0000
Subject: Re: [Linux-ia64] reader-writer livelock problem
Message-Id: <marc-linux-ia64-105590709805360@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805355@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805355@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 8 Nov 2002, Linus Torvalds wrote:
> 
> NOTE! I'm not saying the existing practice is necessarily a good tradeoff,
> and maybe we should just make sure to find all such cases and turn the
> read_lock() calls into read_lock_irqsave() and then make the rw-locks
> block readers on pending writers. But it's certainly more work and cause
> for subtler problems than just naively changing the rw implementation.

Actually, giving this som emore thought, I really suspect that the
simplest solution is to alloc a separate "fair_read_lock()", and paths
that need to care about fairness (and know they don't have the irq issue)  
can use that, slowly porting users over one by one...

		Linus


