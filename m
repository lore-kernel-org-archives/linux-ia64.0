From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 07 Jan 2009 23:35:20 +0000
Subject: Re: [Patch V3 0/3] Enable irqs when waiting for rwlocks
Message-Id: <20090107153520.b91b5956.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081104122405.046233722@attica.americas.sgi.com>
In-Reply-To: <20081104122405.046233722@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: holt@sgi.com
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, ptesarik@suse.cz, tee@sgi.com, peterz@infradead.org, mingo@elte.hu, "Luck, Tony" <tony.luck@intel.com>

On Tue, 04 Nov 2008 06:24:05 -0600
holt@sgi.com wrote:

> New in V3:
>  * Handle rearrangement of some arch's include/asm directories.
> 
> New in V2:
>  * get rid of ugly #ifdef's in kernel/spinlock.h
>  * convert __raw_{read|write}_lock_flags to an inline func
> 
> SGI has observed that on large systems, interrupts are not serviced for
> a long period of time when waiting for a rwlock. The following patch
> series re-enables irqs while waiting for the lock, resembling the code
> which is already there for spinlocks.
> 
> I only made the ia64 version, because the patch adds some overhead to
> the fast path. I assume there is currently no demand to have this for
> other architectures, because the systems are not so large. Of course,
> the possibility to implement raw_{read|write}_lock_flags for any
> architecture is still there.
> 

I'm not seeing any Tony Luck acks on this work?
